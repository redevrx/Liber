package friend

import (
	_ "github.com/go-playground/validator/v10"
)

type BuddyRequest struct {
	Id       string `db:"id"`
	UserId   string `db:"userId"`
	FromId   string `json:"fromId" validate:"required" db:"fromId"`
	ToId     string `json:"toId" validate:"required" db:"toId"`
	CreateAt string `json:"createAt" validate:"required" db:"createAt"`
	Relation string `json:"relation" validate:"required" db:"relation"`
	Status   string `json:"status" validate:"required" db:"status"`
}

const (
	Request    string = "request_friend"
	WaitAccept string = "wait_accept_friend"
	Accept     string = "accept"
	Bloc       string = "bloc_friend"
	IsFriend   string = "make_friend"
	UnFriend   string = "un_friend"
)

func BuildFriend() *BuddyRequest {
	return &BuddyRequest{
		Id:       "",
		FromId:   "",
		ToId:     "",
		CreateAt: "",
		Relation: "",
		Status:   "",
	}
}
