package router

import (
	"feel/controller/authentication"
	"feel/controller/friend"
	res "feel/model/wrap_response"
	"feel/router/middleware"
	"github.com/gofiber/fiber/v2"
	"os"
)

// build instance all controller
var authController = authentication.BuildAuthController()

// BuildFController f is friend
var friendController = friend.BuildFController()

func Router(app *fiber.App) {
	apiPath := os.Getenv("API_PATH")
	//auth path
	app.Post(apiPath+"register", authController.ValidateRegister, register)
	app.Post(apiPath+"login", authController.ValidateLogin, authController.Login)
	app.Post(apiPath+"refresh_token", authController.RefreshToken)

	//
	v1 := app.Group(apiPath, middleware.AuthMiddleware)
	v1.Post("logout", authController.LogOut)
	v1.Post("friend/request", friendController.ValidateRequest, friendController.RequestFriend)
	v1.Get("friend/validate/:friendId", friendController.VFriendCache, friendController.VFriend)
	v1.Get("test", func(ctx *fiber.Ctx) error {
		return ctx.JSON("Suc")
	})
}

func register(ctx *fiber.Ctx) error {
	err := authController.Register(ctx)
	if err != nil {
		return ctx.JSON(res.WrapResponse{
			StatusCode:   fiber.StatusBadRequest,
			IsError:      true,
			ErrorMessage: err.Error(),
		})
	}
	return nil
}
