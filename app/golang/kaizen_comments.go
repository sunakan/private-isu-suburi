package main

import (
	cmap "github.com/orcaman/concurrent-map/v2"
	"log/slog"
	"strconv"
	"sync/atomic"
	"time"
)

var (
	commentsCacheByPostId     = cmap.New[[]*Comment]()
	commentsCacheByUserId     = cmap.New[[]*Comment]()
	commentsCacheByPostUserId = cmap.New[[]*Comment]()
	commentId                 atomic.Int32
)

type CommentWithPostUserId struct {
	ID         int       `db:"comment_id"`
	PostID     int       `db:"comment_post_id"`
	UserID     int       `db:"comment_user_id"`
	Comment    string    `db:"comment_comment"`
	CreatedAt  time.Time `db:"comment_created_at"`
	PostUserId int       `db:"post_user_id"`
}

func initializeCommentsCache() {
	var comments []*CommentWithPostUserId
	query := `
SELECT
  comments.id as comment_id
  , comments.post_id as comment_post_id
  , comments.user_id as comment_user_id	
  , comments.comment as comment_comment
  , comments.created_at as comment_created_at
  , posts.user_id as post_user_id
FROM comments
JOIN posts ON posts.id = comments.post_id
JOIN users ON users.id = posts.user_id and users.del_flg = 0
ORDER BY comments.id ASC
;
`
	if err := db.Select(&comments, query); err != nil {
		slog.Error("コメント一覧取得に失敗", err)
		return
	}
	commentsCacheByPostId.Clear()
	commentsCacheByUserId.Clear()
	commentsCacheByPostUserId.Clear()
	for _, comment := range comments {
		setCommentCache(comment)
		commentId.Store(int32(comment.ID))
	}
}

func setCommentCache(commentWithPostUserId *CommentWithPostUserId) {
	comment := &Comment{
		ID:        commentWithPostUserId.ID,
		PostID:    commentWithPostUserId.PostID,
		UserID:    commentWithPostUserId.UserID,
		Comment:   commentWithPostUserId.Comment,
		CreatedAt: commentWithPostUserId.CreatedAt,
	}
	// PostID毎にコメントをキャッシュ
	postId := strconv.Itoa(comment.PostID)
	if comments, ok := commentsCacheByPostId.Get(postId); ok {
		comments = append(comments, comment)
		commentsCacheByPostId.Set(postId, comments)
	} else {
		commentsCacheByPostId.Set(postId, []*Comment{comment})
	}

	// コメントしたUserId毎にコメントをキャッシュ
	userId := strconv.Itoa(comment.UserID)
	if comments, ok := commentsCacheByUserId.Get(userId); ok {
		comments = append(comments, comment)
		commentsCacheByUserId.Set(userId, comments)
	} else {
		commentsCacheByUserId.Set(userId, []*Comment{comment})
	}

	// PostしたUserId毎にコメントをキャッシュ
	postUserId := strconv.Itoa(commentWithPostUserId.PostUserId)
	if comments, ok := commentsCacheByPostUserId.Get(postUserId); ok {
		comments = append(comments, comment)
		commentsCacheByPostUserId.Set(postUserId, comments)
	} else {
		commentsCacheByPostUserId.Set(postUserId, []*Comment{comment})
	}
}

func getCommentsByPostId(postId int) []*Comment {
	if comments, ok := commentsCacheByPostId.Get(strconv.Itoa(postId)); ok {
		return comments
	} else {
		return []*Comment{}
	}
}

func getCommentsByUserId(userId int) []*Comment {
	if comments, ok := commentsCacheByUserId.Get(strconv.Itoa(userId)); ok {
		return comments
	} else {
		return []*Comment{}
	}
}

func getCommentsByPostUserId(userId int) []*Comment {
	if comments, ok := commentsCacheByPostUserId.Get(strconv.Itoa(userId)); ok {
		return comments
	} else {
		return []*Comment{}
	}
}

func incrementCommentId() int {
	return int(commentId.Add(1))
}
