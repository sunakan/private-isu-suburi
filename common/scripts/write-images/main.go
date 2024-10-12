package main

import (
	"fmt"
	"log/slog"
	"os"

	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
)

type Post struct {
	ID      int    `db:"id"`
	Mime    string `db:"mime"`
	Imgdata []byte `db:"imgdata"`
}

// 事前にid<=10000のpostsテーブルの画像を書き出しておく
func writeImages() {
	imgPath := "/home/isucon/private_isu/webapp/image"
	if err := os.MkdirAll(imgPath, 0755); err != nil {
		slog.Error("os.MkdirAllでエラー", err)
		return
	}

	db, err := sqlx.Open("mysql", "isuconp:isuconp@tcp(localhost:3306)/isuconp?charset=utf8mb4&parseTime=true&loc=Local&interpolateParams=true")
	if err != nil {
		slog.Error("sqlx.Openでエラー", err)
	}
	defer db.Close()

	//select mime, count(1) from posts where id <= 10000 group by mime;
	//image/jpeg,9744
	//image/gif,128
	//image/png,128
	//合計10,000
	offset := 0
	limit := 100
	for {
		posts := []Post{}
		err := db.Select(&posts, "SELECT id, mime, imgdata FROM posts WHERE id <= 10000 ORDER BY id ASC LIMIT ? OFFSET ?", limit, offset)
		if err != nil {
			slog.Error("db.Selectでエラー", err, "limit", limit, "offset", offset)
			return
		}
		if len(posts) == 0 {
			break
		}

		for _, post := range posts {
			filename := fmt.Sprintf("%s/%d.%s", imgPath, post.ID, getExtension(post.Mime))
			err := os.WriteFile(filename, post.Imgdata, 0644)
			if err != nil {
				slog.Error("ioutil.WriteFileでエラー", err, "filename", filename)
				return
			}
			slog.Info("画像書き出し成功", "filename", filename)
		}
		offset += limit
	}
}

func getExtension(mime string) string {
	switch mime {
	case "image/jpeg":
		return "jpg"
	case "image/png":
		return "png"
	case "image/gif":
		return "gif"
	default:
		return "jpg"
	}
}

func main() {
	fmt.Println("画像の書き出し")
	writeImages()
}
