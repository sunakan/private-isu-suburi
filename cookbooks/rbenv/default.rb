node.reverse_merge!(
  rbenv: {
    user: 'isucon',
    global: '3.3.0',
    versions: %w[
      3.3.0
    ],
  }
)

include_recipe 'rbenv::user'
