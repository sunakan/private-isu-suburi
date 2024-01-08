#!/bin/bash

#
# 参考: https://github.com/k0kubun/dotfiles/blob/master/install.sh
#

set -ex

bin/setup-mitamae

#case "$(uname)" in
#  "Linux")
#    sudo -E bin/mitamae local $@ cookbooks/default.rb
#    ;;
#  *)
#    echo "OSが想定外です uname: $(uname)"
#    exit 1
#    ;;
#esac
