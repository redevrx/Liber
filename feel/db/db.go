package db

import (
	"database/sql"
	"github.com/go-redis/redis/v8"
	_ "github.com/go-sql-driver/mysql"
	"log"
)

func GetDb() *sql.DB {
	db, err := sql.Open("mysql", "redevrx:redevrx@tcp(127.0.0.1:3306)/redevdb?parseTime=true")

	if err != nil {
		log.Fatal(err)
	}

	return db
}

func GetRedis() *redis.Client {
	rdb := redis.NewClient(&redis.Options{
		Addr:     "localhost:6379",
		Password: "redevrx",
		DB:       0,
	})

	return rdb
}
