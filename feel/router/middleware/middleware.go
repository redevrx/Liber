package middleware

import (
	con "feel/controller/authentication"
	res "feel/model/wrap_response"
	"feel/service/authentication"
	"github.com/gofiber/fiber/v2"
)

func AuthMiddleware(ctx *fiber.Ctx) error {
	mJwt := ctx.GetReqHeaders()["Authorization"]
	mToken, err := con.BuildAuthController().ValidateJWT(mJwt)

	if err != nil {
		return ctx.Status(fiber.StatusUnauthorized).JSON(res.ToUnauthorized("Token End Session" + err.Error()))
	}

	claims, err := authentication.ValidClaims(mToken)

	if err != nil && claims != nil {
		return ctx.Status(fiber.StatusUnauthorized).JSON(res.ToUnauthorized("Token End Session"))
	}

	userId, err := authentication.ValidMetaData(claims)

	if err != nil && userId == "" {
		return ctx.Status(fiber.StatusUnauthorized).JSON(res.ToUnauthorized("Token End Session"))
	} else {
		return ctx.Next()
	}
}
