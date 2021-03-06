package main

import (
	"github.com/labstack/echo/v4"
	"net/http"
)

func main() {
	e := echo.New()
	e.GET("/hello-world", func(c echo.Context) error {
		return c.String(http.StatusOK, "Hello World!!")
	})
	e.GET("", func(c echo.Context) error {
		return c.String(http.StatusNotFound, "Not Found!!")
	})

	e.Start(":3000")
}
