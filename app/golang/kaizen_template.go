package main

import "html/template"

// templateで毎回読み込むのではなく、最初で読み込んでおく
var (
	loginTemplate = template.Must(template.ParseFiles(
		getTemplPath("layout.html"),
		getTemplPath("login.html")),
	)
	registerTemplate = template.Must(template.ParseFiles(
		getTemplPath("layout.html"),
		getTemplPath("register.html")),
	)
	getIndexTemplate = template.Must(template.New("layout.html").Funcs(template.FuncMap{
		"imageURL": imageURL,
	}).ParseFiles(
		getTemplPath("layout.html"),
		getTemplPath("index.html"),
		getTemplPath("posts.html"),
		getTemplPath("post.html"),
	))
	getAccountNameTemplate = template.Must(template.New("layout.html").Funcs(template.FuncMap{
		"imageURL": imageURL,
	}).ParseFiles(
		getTemplPath("layout.html"),
		getTemplPath("user.html"),
		getTemplPath("posts.html"),
		getTemplPath("post.html"),
	))
	getPostsTemplate = template.Must(template.New("posts.html").Funcs(template.FuncMap{
		"imageURL": imageURL,
	}).ParseFiles(
		getTemplPath("posts.html"),
		getTemplPath("post.html"),
	))
	getPostsIDTemplate = template.Must(template.New("layout.html").Funcs(template.FuncMap{
		"imageURL": imageURL,
	}).ParseFiles(
		getTemplPath("layout.html"),
		getTemplPath("post_id.html"),
		getTemplPath("post.html"),
	))
	getAdminBannedTemplate = template.Must(template.ParseFiles(
		getTemplPath("layout.html"),
		getTemplPath("banned.html")),
	)
)
