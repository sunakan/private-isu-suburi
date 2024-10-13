package main

import (
	"log/slog"
	"slices"
	"strconv"

	cmap "github.com/orcaman/concurrent-map/v2"
)

var (
	postCacheById      = cmap.New[*Post]()
	postsCacheByUserId = cmap.New[[]*Post]()
)

func initializePostsCache() {
	var posts []*Post
	if err := db.Select(&posts, "SELECT id, user_id, body, mime, created_at FROM posts ORDER BY id;"); err != nil {
		slog.Error("投稿一覧取得に失敗", err)
		return
	}
	postCacheById.Clear()
	postsCacheByUserId.Clear()
	for _, post := range posts {
		setPostCache(post)
	}
}

func setPostCache(post *Post) {
	// 投稿ID毎に投稿をキャッシュ
	postCacheById.Set(strconv.Itoa(post.ID), post)
	// user_id毎に投稿をキャッシュ
	userId := strconv.Itoa(post.UserID)
	if posts, ok := postsCacheByUserId.Get(userId); ok {
		posts = append(posts, post)
		postsCacheByUserId.Set(userId, posts)
	} else {
		postsCacheByUserId.Set(userId, []*Post{post})
	}
}

func getPostById(id int) *Post {
	if post, ok := postCacheById.Get(strconv.Itoa(id)); ok {
		return post
	} else {
		return nil
	}
}

func getPostsByUserId(id int) []*Post {
	if posts, ok := postsCacheByUserId.Get(strconv.Itoa(id)); ok {
		return posts
	} else {
		return nil
	}
}

// 最新max20件のPost群
func getPosts20ByUserId(id int) []*Post {
	if posts, ok := postsCacheByUserId.Get(strconv.Itoa(id)); ok {
		if 20 < len(posts) {
			last20 := posts[len(posts)-20:]
			slices.Reverse(last20)
			return last20
		} else {
			all := slices.Clone(posts)
			slices.Reverse(all)
			return all
		}
	} else {
		return []*Post{}
	}
}