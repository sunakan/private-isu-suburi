#!/bin/bash -eux

#
# MySQLのindex
#
while read server; do
  # SELECT * FROM `comments` WHERE `post_id` = 9989 ORDER BY `created_at` DESC LIMIT 3\G
  ssh -n $server "sudo mysql isuconp -e 'create index idx_post_id_and_created_at_desc on comments (post_id, created_at desc);'" || echo '既にindex有り'
  # explain SELECT `id`, `user_id`, `body`, `mime`, `created_at` FROM `posts` ORDER BY `created_at` DESC\G
  ssh -n $server "sudo mysql isuconp -e 'create index idx_created_at_desc on posts (created_at desc);'" || echo '既にindex有り'
done < <(head -n1 tmp/app-servers)
