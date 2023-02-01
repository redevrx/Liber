package authentication

import (
	"context"
	"database/sql"
	"feel/db"
	model "feel/model/authentication"
	modelJWT "feel/model/jwt"
	res "feel/model/wrap_response"
	"feel/utils"
	"fmt"
	"github.com/go-redis/redis/v8"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v4"
	"log"
	"os"
	"sync"
	"time"
)

type AuthService struct{}

func AuthServiceBuild() *AuthService {
	return &AuthService{}
}

func (auth AuthService) Register(ctx *fiber.Ctx) error {
	body := model.RegisterBuilder()
	err := ctx.BodyParser(body)
	uid := utils.GetUUId()

	if err != nil {
		log.Fatal(err)
	}

	var wg sync.WaitGroup
	mErr := make(chan error)
	aToken := make(chan string, 1)
	rToken := make(chan string, 1)

	defer close(mErr)
	defer close(aToken)
	defer close(rToken)

	go saveUser(mErr, uid, body)

	if (<-mErr) != nil {
		return <-mErr
	}

	wg.Add(1)
	go generateJWT(&wg, aToken, rToken, uid)

	//wait generate jwt
	for rT := range rToken {
		return ctx.JSON(res.WrapResponse{
			StatusCode:     fiber.StatusOK,
			IsError:        false,
			ErrorMessage:   "",
			SuccessMessage: map[string]string{"userId": uid, "accessToken": <-aToken, "refreshToken": rT},
		})
	}

	return nil
}

func saveUser(mErr chan error, uid string, body *model.RegisterRequest) {
	// connection database
	var conn = db.GetDb()
	defer func(conn *sql.DB) {
		err := conn.Close()
		if err != nil {
			log.Printf("close database error :%v",err)
		}
	}(conn)

	mSql := "INSERT INTO User(userId,userName,aliasName,age,phoneNumber,sex,email,password) values (?,?,?,?,?,?,?,?)"
	_, err := conn.Exec(mSql, uid, body.UserName, body.AliasName, body.Age, body.PhoneNumber, body.Sex, body.Email, body.Password)
	mErr <- err
}

func generateJWT(wg *sync.WaitGroup, aJwt chan string, rJwt chan string, userId string) {
	defer wg.Done()
	//create access token
	claims := &modelJWT.TokenClaims{
		AccessUUID: utils.GetUUId(),
		UserId:     userId,
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    getSecretKey(),
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Minute * 15)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		}}

	mToken := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	mT, err := mToken.SignedString([]byte(getSecretKey()))

	if err != nil {
		log.Fatal(err)
	}

	aJwt <- mT

	//create refresh token
	rClaims := jwt.MapClaims{
		"userId":      userId,
		"refreshUUID": utils.GetUUId(),
		"expiresAt":   jwt.NewNumericDate(time.Now().Add(time.Hour * 24 * 7)),
	}
	rToken := jwt.NewWithClaims(jwt.SigningMethodHS256, rClaims)

	rT, err := rToken.SignedString([]byte(getSecretKey()))

	if err != nil {
		log.Fatal(err)
	}

	rJwt <- rT

	log.Printf("access -> %v refresh -> %v", claims.AccessUUID, rClaims["refreshUUID"].(string))

	go func(access string, refresh string, userId string) {
		ctx := context.Background()
		rdb := db.GetRedis()
		defer func(rdb *redis.Client) {
			err := rdb.Close()
			if err != nil {
				log.Printf("close redis cache error :%v",err)
			}
		}(rdb)

		aErr := rdb.Set(ctx, access, userId, time.Minute*15).Err()
		if aErr != nil {
			panic(aErr)
		}

		rErr := rdb.Set(ctx, refresh, userId, time.Hour*24*7).Err()

		if rErr != nil {
			panic(rErr)
		}
	}(claims.AccessUUID, rClaims["refreshUUID"].(string), userId)
}
func ValidClaims(token *jwt.Token) (jwt.MapClaims, error) {
	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		return claims, nil
	}
	return nil, nil
}

func ValidMetaData(claims jwt.MapClaims) (string, error) {
	rdb := db.GetRedis()
	defer func(rdb *redis.Client) {
		err := rdb.Close()
		if err != nil {
			log.Printf("close redis cache error :%v",err)
		}
	}(rdb)
	ctx := context.Background()
	value, err := rdb.Get(ctx, claims["accessUUID"].(string)).Result()

	return value, err
}
func (auth AuthService) ValidateJWT(mJWT string) (*jwt.Token, error) {
	return jwt.Parse(mJWT, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(getSecretKey()), nil
	})
}

func getSecretKey() string {
	secret := os.Getenv("SECRET")
	if secret == "" {
		secret = "1209839-012803ijkasdnkjashndkjh23897dhajksndbkjashd9823"
	}
	print(secret)
	return secret
}

type validateData struct {
	mUser  string
	mToken string
	mUId   string
	err    error
}

func (auth AuthService) Login(ctx *fiber.Ctx) error {
	request := new(model.LoginRequest)
	err := ctx.BodyParser(&request)

	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(res.ToErrorResponse(fiber.StatusBadRequest, err.Error()))
	}

	var wg sync.WaitGroup
	aToken := make(chan string, 1)
	rToken := make(chan string, 1)
	mValidate := make(chan validateData, 1)

	defer close(aToken)
	defer close(rToken)
	defer close(mValidate)

	wg.Add(2)
	go validateAuthen(request, mValidate, &wg)

	for value := range mValidate {
		if value.err != nil {
			return ctx.JSON(res.ToErrorResponse(fiber.StatusUnauthorized, "Login Failed User Or Password invalid"))
		} else {
			//get new token
			go generateJWT(&wg, aToken, rToken, value.mUId)
			time.Sleep(time.Second)
			return ctx.Status(fiber.StatusOK).JSON(res.WrapResponse{
				StatusCode:     fiber.StatusOK,
				IsError:        false,
				ErrorMessage:   "",
				SuccessMessage: map[string]string{"accessToken": <-aToken, "refreshToken": <-rToken, "userId": value.mUId},
			})
		}
	}

	return nil
}

func validateAuthen(request *model.LoginRequest, mValidate chan validateData, wg *sync.WaitGroup) {
	conn := db.GetDb()
	defer func(conn *sql.DB) {
		err := conn.Close()
		if err != nil {
			log.Printf("close database error :%v",err)
		}
	}(conn)
	defer wg.Done()

	var (
		userName = ""
		userId   = ""
	)

	err := conn.QueryRow("Select userName ,userId from User where email=? and password=?",
		request.Email, request.Password).Scan(&userName, &userId)

	mValidate <- validateData{
		mUser:  userName,
		mToken: "",
		mUId:   userId,
		err:    err,
	}

}

func (auth AuthService) Logout(ctx *fiber.Ctx) error {
	type tokenStruct struct {
		RefreshUUID string `json:"refreshUUID"`
		AccessUUID  string `json:"accessUUID"`
	}
	var tBody tokenStruct
	err := ctx.BodyParser(&tBody)

	log.Printf("%v", tBody)

	if err != nil || tBody == (tokenStruct{}) {
		return ctx.Status(fiber.StatusUnauthorized).JSON(res.ToErrorResponse(
			fiber.StatusUnauthorized, "Not Fond User Credentials"))
	}

	var wg sync.WaitGroup
	//delete refresh token error
	delRTErr := make(chan error, 1)
	//delete access token error
	delATErr := make(chan error, 1)

	defer close(delRTErr)
	defer close(delATErr)

	wg.Add(1)
	go func() {
		rdb := db.GetRedis()
		defer func(rdb *redis.Client) {
			err := rdb.Close()
			if err != nil {
				log.Printf("close redis cache error :%v",err)
			}
		}(rdb)
		defer wg.Done()

		ctx := context.Background()

		_, aerr := rdb.Del(ctx, tBody.AccessUUID).Result()
		delATErr <- aerr

		_, rerr := rdb.Del(ctx, tBody.RefreshUUID).Result()
		delRTErr <- rerr
	}()

	for del := range delRTErr {
		if del != nil && (<-delATErr) != nil {
			return ctx.Status(fiber.StatusUnauthorized).JSON(res.ToErrorResponse(
				fiber.StatusUnauthorized, "Not Fond User Credentials :"+del.Error()+"<->"+(<-delATErr).Error()))
		} else {
			return ctx.Status(fiber.StatusOK).JSON(res.WrapResponse{
				StatusCode:     fiber.StatusOK,
				IsError:        false,
				SuccessMessage: "LogOut Complete",
			})
		}
	}

	return nil
}

func (auth AuthService) RefreshToken(ctx *fiber.Ctx) error {
	type tokenStruct struct {
		RefreshToken string `json:"refreshToken"`
	}

	var rToken tokenStruct
	_ = ctx.BodyParser(&rToken)
	token, err := auth.ValidateJWT(rToken.RefreshToken)

	if err != nil {
		return ctx.Status(fiber.StatusUnauthorized).JSON(res.ToUnauthorized(err.Error()))
	}

	claim, err := ValidClaims(token)

	if err != nil {
		return ctx.Status(fiber.StatusUnauthorized).JSON(res.ToUnauthorized(err.Error()))
	}

	rUUID := claim["refreshUUID"].(string)

	var wg sync.WaitGroup
	mErr := make(chan error, 1)
	aToken := make(chan string, 1)
	rfToken := make(chan string, 1)

	defer close(mErr)
	defer close(aToken)
	defer close(rfToken)

	wg.Add(2)
	///remove old refresh token
	go func() {
		rdb := db.GetRedis()
		defer func(rdb *redis.Client) {
			err := rdb.Close()
			if err != nil {
				log.Printf("close redis cache error :%v",err)
			}
		}(rdb)
		defer wg.Done()

		ctx := context.Background()
		err := rdb.Del(ctx, rUUID).Err()
		mErr <- err
	}()

	if <-mErr != nil {
		return utils.ToError(ctx, fiber.StatusInternalServerError, <-mErr)
	}

	go generateJWT(&wg, aToken, rfToken, claim["userId"].(string))

	for rt := range rfToken {
		return ctx.JSON(res.WrapResponse{
			StatusCode:     fiber.StatusOK,
			IsError:        false,
			ErrorMessage:   "",
			SuccessMessage: map[string]string{"userId": claim["userId"].(string), "accessToken": <-aToken, "refreshToken": rt},
		})
	}

	return nil
}
