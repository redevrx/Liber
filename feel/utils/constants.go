package utils

import (
	"encoding/json"
	res "feel/model/wrap_response"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"log"
)

func DecodeJson(raw []byte, data any) {
	err := json.Unmarshal(raw, data)

	if err != nil {
		log.Fatalf("decode json error %v", err)
	}
}

func ToJson(raw any) []byte {
	mJson, err := json.Marshal(raw)

	if err != nil {
		log.Fatal(err)
		return nil
	}

	return mJson
}

func GetUUId() string {
	return uuid.New().String()
}

func ToError(ctx *fiber.Ctx, code int, err error) error {
	if err != nil {
		return ctx.Status(code).JSON(res.WrapResponse{
			StatusCode:   code,
			IsError:      true,
			ErrorMessage: "error ->" + err.Error(),
		})
	}
	return nil
}

//user table
//"create table user (userId varchar(40), userName varchar(20), aliasName varchar(20), age int , phoneNumber varchar(13), sex varchar(2), primary key (userId))"
