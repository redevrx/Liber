package jwt

import "github.com/golang-jwt/jwt/v4"

type TokenClaims struct {
	UserId     string `json:"userId"`
	AccessUUID string `json:"accessUUID"`
	jwt.RegisteredClaims
}
