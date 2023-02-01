package friend

import (
	"feel/service/friend"
	"github.com/gofiber/fiber/v2"
)

type FRepository struct {
}

func BuildFRepository() *FRepository {
	return &FRepository{}
}

var service = friend.BuildFriendService()

func (repository FRepository) VFriend(ctx *fiber.Ctx) error {
	return service.ValidateFriend(ctx)
}

// VFriendCache v is validate
func (repository FRepository) VFriendCache(ctx *fiber.Ctx) error {
	return service.ValidateFriendCache(ctx)
}

func (repository FRepository) RequestFriend(ctx *fiber.Ctx) error {
	return service.RequestFriend(ctx)
}

func (repository FRepository) ValidateRequest(ctx *fiber.Ctx) error {
	return service.ValidateRequest(ctx)
}
