package authentication

import (
	_ "github.com/go-playground/validator/v10"
)

type RegisterRequest struct {
	UserId      string `json:"userId" db:"userId"`
	UserName    string `json:"userName" validate:"required" db:"userName"`
	AliasName   string `json:"aliasName" db:"aliasName"`
	Age         int    `json:"age" validate:"required,numeric" db:"age"`
	PhoneNumber string `json:"phoneNumber" validate:"required" db:"phoneNumber"`
	Sex         int    `json:"sex" validate:"required,numeric" db:"sex"`
	Password    string `json:"password" validate:"required" db:"password"`
	Email       string `json:"email" validate:"required,email,min=6,max=32" db:"email"`
}

func RegisterBuilder() *RegisterRequest {
	return &RegisterRequest{
		UserId:      "",
		UserName:    "",
		AliasName:   "",
		Age:         0,
		PhoneNumber: "",
		Sex:         0,
		Password:    "",
		Email:       "",
	}
}

type LoginRequest struct {
	Email    string `json:"email" validate:"required"`
	Password string `json:"password" validate:"required"`
}
