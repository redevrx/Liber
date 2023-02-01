package authentication

import (
	"feel/service/authentication"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v4"
)

type AuthRepository struct{}

func AuthRepositoryBuild() *AuthRepository {
	return &AuthRepository{}
}

var service = authentication.AuthServiceBuild()

func (repository AuthRepository) Register(ctx *fiber.Ctx) error {
	return service.Register(ctx)
}

func (repository AuthRepository) ValidateJWT(mToken string) (*jwt.Token, error) {
	return service.ValidateJWT(mToken)
}

func (repository AuthRepository) Login(ctx *fiber.Ctx) error {
	return service.Login(ctx)
}

func (repository AuthRepository) RefreshToken(ctx *fiber.Ctx) error {
	return service.RefreshToken(ctx)
}

func (repository AuthRepository) LogOut(ctx *fiber.Ctx) error {
	return service.Logout(ctx)
}
