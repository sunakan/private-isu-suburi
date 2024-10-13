#!/bin/bash -eux

#
# MySQLのindex
#
while read server; do
  # explain SELECT * FROM `comments` WHERE `post_id` = 10006 ORDER BY `id` ASC LIMIT 3\G
  ssh -n $server "sudo mysql isuconp -e 'create index idx_post_id on comments (post_id);'" || echo '既にindex有り'
done < <(head -n1 tmp/app-servers)
