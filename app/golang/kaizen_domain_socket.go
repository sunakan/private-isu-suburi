package main

import (
	"log"
	"log/slog"
	"net"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
)

// ドメインソケットを利用したサーバーのListen
func listenUseDomainSocket(r *chi.Mux) {
	path := "/var/run/isu-go"
	if err := os.MkdirAll(path, 0755); err != nil {
		slog.Error("os.MkdirAllでエラー", err)
		return
	}

	socketFile := "/var/run/isu-go/app.sock"
	os.Remove(socketFile)
	l, err := net.Listen("unix", socketFile)
	if err != nil {
		panic(err)
	}
	// go runユーザとnginxのユーザ（グループ）を同じにすれば777じゃなくてok
	err = os.Chmod(socketFile, 0777)
	if err != nil {
		panic(err)
	}
	defer l.Close()

	// Unixドメインソケット上でHTTPサーバーを起動
	httpServer := &http.Server{
		Handler: r,
	}
	if err := httpServer.Serve(l); err != nil {
		log.Fatal("Failed to serve:", err)
	}
}
