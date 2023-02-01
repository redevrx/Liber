package friend

import (
	"context"
	"database/sql"
	"feel/db"
	"feel/model"
	"feel/model/friend"
	res "feel/model/wrap_response"
	"feel/utils"
	"github.com/go-playground/validator/v10"
	"github.com/go-redis/redis/v8"
	"github.com/gofiber/fiber/v2"
	"log"
	"sync"
	"time"
)

// FService F is friend
type FService struct{}

func BuildFriendService() *FService {
	return &FService{}
}

func (f FService) RequestFriend(ctx *fiber.Ctx) error {
	var request friend.BuddyRequest
	err := ctx.BodyParser(&request)

	if err != nil || request == (friend.BuddyRequest{}) {
		return ctx.Status(fiber.StatusBadRequest).JSON(
			res.ToErrorResponse(fiber.StatusBadRequest, "Not Fond Request Body."))
	}

	//qid = request friend id
	qID := utils.GetUUId()

	var wg sync.WaitGroup
	dbErr := make(chan error)
	rdbErrFrom := make(chan error)
	rdbErrTo := make(chan error)

	wg.Add(2)
	go saveRequestDB(&wg, request, dbErr, qID)
	go saveRequestRDB(&wg, request, rdbErrFrom, rdbErrTo, qID)

	for err := range rdbErrFrom {
		if err != nil && (<-dbErr) != nil && (<-rdbErrTo) != nil {
			return ctx.Status(fiber.StatusInternalServerError).JSON(
				res.ToErrorResponse(fiber.StatusInternalServerError,
					"Request Friend Error :"+err.Error()+"<-->"+(<-dbErr).Error()))
		} else {
			return ctx.Status(fiber.StatusOK).JSON(res.WrapResponse{
				StatusCode:     fiber.StatusOK,
				IsError:        false,
				ErrorMessage:   "",
				SuccessMessage: map[string]string{"requestId": qID, "status": "complete"},
			})
		}
	}

	defer close(rdbErrFrom)
	defer close(rdbErrTo)
	defer close(dbErr)

	return nil
}

// /save request friend to redis
func saveRequestRDB(wg *sync.WaitGroup, request friend.BuddyRequest, rdbErrFrom chan error, rdbErrTo chan error, id string) {
	rdb := db.GetRedis()
	defer func(rdb *redis.Client) {
		err := rdb.Close()
		if err != nil {
			log.Printf("close redis cache error :%v",err)
		}
	}(rdb)
	defer wg.Done()

	ctx := context.Background()
	request.Id = id
	json := utils.ToJson(request)
	//keep cache 1 hour
	_, err := rdb.Set(ctx, request.FromId, json, time.Second*60).Result()
	rdbErrFrom <- err

	_, terr := rdb.Set(ctx, request.ToId, json, time.Second*60).Result()
	rdbErrTo <- terr
}

// save request friend to db
func saveRequestDB(wg *sync.WaitGroup, request friend.BuddyRequest, dbErr chan error, id string) {
	mClient := db.GetDb()
	defer func(mClient *sql.DB) {
		err := mClient.Close()
		if err != nil {
			log.Printf("close database error :%v",err)
		}
	}(mClient)
	defer wg.Done()

	_, err := mClient.Exec("INSERT INTO RequestFriend (id,userId,fromId,toId,status) values(?,?,?,?,?)",
		id, request.FromId, request.FromId, request.ToId, request.Status)
	dbErr <- err
}

// ValidateFriendCache validate friend cache
func (f FService) ValidateFriendCache(ctx *fiber.Ctx) error {
	//var request friend.ValidateFriend
	userId := ctx.Query("id", "")

	if userId == "" {
		return ctx.Status(fiber.StatusBadRequest).JSON(
			res.ToErrorResponse(fiber.StatusBadRequest, "Not Fond Request Body."))
	}

	mResult := make(chan string, 1)
	mErr := make(chan error, 1)

	go func() {
		rdb := db.GetRedis()
		defer func(rdb *redis.Client) {
			err := rdb.Close()
			if err != nil {
				log.Printf("close redis cache error :%v",err)
			}
		}(rdb)

		ctx := context.Background()

		result, err := rdb.Get(ctx, userId).Result()
		mResult <- result
		mErr <- err
	}()

	for result := range mResult {
		if result != "" && (<-mErr) == nil {
			var data friend.BuddyRequest
			utils.DecodeJson([]byte(result), &data)
			return ctx.Status(fiber.StatusOK).JSON(res.WrapResponse{
				StatusCode:     fiber.StatusOK,
				IsError:        false,
				ErrorMessage:   "",
				SuccessMessage: data,
			})
		} else {
			// not found cache data
			return ctx.Next()
		}
	}

	defer close(mResult)
	defer close(mErr)

	return nil
}

// ValidateFriend validate friend
func (f FService) ValidateFriend(ctx *fiber.Ctx) error {
	userId := ctx.Query("id")

	if userId == "" {
		return ctx.Status(fiber.StatusBadRequest).JSON(
			res.ToErrorResponse(fiber.StatusBadRequest, "Not Fond Request Body."))
	}

	mResult := make(chan struct {
		data friend.BuddyRequest
		err  error
	}, 1)
	var wg sync.WaitGroup

	wg.Add(1)
	go func() {
		mClient := db.GetDb()
		defer func(mClient *sql.DB) {
			err := mClient.Close()
			if err != nil {
				log.Printf("close database error :%v",err)
			}
		}(mClient)
		defer wg.Done()

		mData := new(struct {
			data friend.BuddyRequest
			err  error
		})

		row, err := mClient.Query("SELECT * from RequestFriend where id=?", userId)

		mData.err = err

		for row.Next() {
			err := row.Scan(&mData.data.Id, &mData.data.UserId, &mData.data.FromId, &mData.data.ToId, &mData.data.Status)
			if err != nil {
				return
			}
		}

		mResult <- *mData
	}()

	for data := range mResult {
		if data.err != nil {
			return ctx.Status(fiber.StatusInternalServerError).JSON(
				res.ToErrorResponse(fiber.StatusInternalServerError,
					"Check Friend Error :"+data.err.Error()))
		} else {
			return ctx.Status(fiber.StatusOK).JSON(res.WrapResponse{
				StatusCode:     fiber.StatusOK,
				IsError:        false,
				ErrorMessage:   "",
				SuccessMessage: data.data,
			})
		}
	}
	defer close(mResult)

	return nil
}

// ValidateRequest /validate request body data
func (f FService) ValidateRequest(ctx *fiber.Ctx) error {
	var errors []*model.IError
	var request friend.BuddyRequest
	err := ctx.BodyParser(&request)

	if err != nil {
		return ctx.Status(fiber.StatusBadRequest).JSON(
			res.ToErrorResponse(fiber.StatusBadRequest, "Decode Request Body Error :"+err.Error()))
	}

	var validate = validator.New()
	err = validate.Struct(request)

	if err != nil {
		for _, err := range err.(validator.ValidationErrors) {
			var el model.IError
			el.Field = err.Field()
			el.Tag = err.Tag()
			el.Value = err.Param()
			errors = append(errors, &el)
		}
		return ctx.Status(fiber.StatusBadRequest).JSON(errors)
	}
	return ctx.Next()
}
