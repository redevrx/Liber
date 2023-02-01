package wrap_response

import (
	"github.com/gofiber/fiber/v2"
)

type WrapResponse struct {
	StatusCode     int    `json:"statusCode"`
	IsError        bool   `json:"isError"`
	ErrorMessage   string `json:"errorMessage"`
	SuccessMessage any    `json:"successMessage"`
}

func (response WrapResponse) ToResponse() *WrapResponse {
	return &WrapResponse{
		StatusCode:     response.StatusCode,
		IsError:        response.IsError,
		ErrorMessage:   response.ErrorMessage,
		SuccessMessage: response.SuccessMessage,
	}
}

func ToUnauthorized(err string) *WrapResponse {
	return &WrapResponse{
		StatusCode:     fiber.StatusUnauthorized,
		IsError:        true,
		ErrorMessage:   err,
		SuccessMessage: "",
	}
}

func ToErrorResponse(code int, err string) *WrapResponse {
	return &WrapResponse{
		StatusCode:     code,
		IsError:        true,
		ErrorMessage:   err,
		SuccessMessage: "",
	}
}
