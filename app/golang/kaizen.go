package main

import (
	"fmt"
	"log/slog"
	"os"
	"strconv"
	"strings"
)

func writeImage(postId int64, mime string, imgData []byte) error {
	var ext string
	switch mime {
	case "image/jpeg":
		ext = "jpg"
	case "image/png":
		ext = "png"
	case "image/gif":
		ext = "gif"
	default:
		ext = "jpg"
	}
	filePath := fmt.Sprintf("/home/isucon/private_isu/webapp/image/%d.%s", postId, ext)
	return os.WriteFile(filePath, imgData, 0644)
}

// /home/isucon/private_isu/webapp/image/ 以下の10000番以降の画像ファイルを削除
func deleteImages() {
	files, err := os.ReadDir("/home/isucon/private_isu/webapp/image")
	if err != nil {
		slog.Error("os.ReadDirに失敗", err)
		return
	}

	for _, file := range files {
		filename := file.Name()
		split := strings.Split(filename, ".")
		idx, err := strconv.Atoi(split[0])
		if err != nil {
			slog.Error("画像ファイル名が不正", err, "filename", filename)
			continue
		}
		if 10000 < idx {
			filepath := fmt.Sprintf("/home/isucon/private_isu/webapp/image/%s", filename)
			err := os.Remove(filepath)
			if err != nil {
				slog.Error("画像ファイルの削除に失敗", err, "filepath", filepath)
			}
		}
	}
}