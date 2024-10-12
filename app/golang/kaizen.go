package main

import (
	"fmt"
	"os"
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
