package authentication

import (
	"encoding/json"
	"feel/model"
	authModel "feel/model/authentication"
	"feel/repository/authentication"
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v4"
	"log"
)

type AuthController struct{}

func BuildAuthController() *AuthController {
	return &AuthController{}
}

// /new instance auth repo
var repository = authentication.AuthRepositoryBuild()

func (controller AuthController) Register(ctx *fiber.Ctx) error {
	return repository.Register(ctx)
}

func (controller AuthController) ValidateJWT(mJWT string) (*jwt.Token, error) {
	return repository.ValidateJWT(mJWT)
}

func (controller AuthController) Login(ctx *fiber.Ctx) error {
	return repository.Login(ctx)
}

// Validator validate
var validate = validator.New()

// ValidateRegister validate register
func (controller AuthController) ValidateRegister(ctx *fiber.Ctx) error {
	var errors []*model.IError
	body := authModel.RegisterBuilder()
	_ = ctx.BodyParser(body)

	s, _ := json.Marshal(body)
	log.Printf("body rg -> %v", string(s))

	err := validate.Struct(body)

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

func (controller AuthController) ValidateLogin(ctx *fiber.Ctx) error {
	var errors []*model.IError
	request := new(authModel.LoginRequest)
	_ = ctx.BodyParser(&request)

	err := validate.Struct(request)

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

func (controller AuthController) RefreshToken(ctx *fiber.Ctx) error {
	return repository.RefreshToken(ctx)
}

func (controller AuthController) LogOut(ctx *fiber.Ctx) error {
	return repository.LogOut(ctx)
}
