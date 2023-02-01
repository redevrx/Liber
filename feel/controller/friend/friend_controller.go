package friend

import (
	"feel/repository/friend"
	"github.com/gofiber/fiber/v2"
)

type FController struct {
}

// BuildFController f is friend
func BuildFController() *FController {
	return &FController{}
}

var repository = friend.BuildFRepository()

func (controller FController) VFriend(ctx *fiber.Ctx) error {
	return controller.VFriend(ctx)
}

// VFriendCache v is validate
func (controller FController) VFriendCache(ctx *fiber.Ctx) error {
	return controller.VFriendCache(ctx)
}

func (controller FController) RequestFriend(ctx *fiber.Ctx) error {
	return repository.RequestFriend(ctx)
}

func (controller FController) ValidateRequest(ctx *fiber.Ctx) error {
	return repository.ValidateRequest(ctx)
}
