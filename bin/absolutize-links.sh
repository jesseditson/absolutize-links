#!/bin/bash -e

# absolutize-links.sh - changes all links in node_modules to absolute links
# usage:
# ./absolutize-links.sh [node_modules_dir]
# where [node_modules_dir] is an absolute path to the local node_modules folder

# grab the last argument as the node_modules_dir, so we can use this script from any context (even if we curry arguments)
NODE_MODULES="${@:$#}"

[[ -z "$NODE_MODULES" ]] && NODE_MODULES='node_modules'

if [ -d "$NODE_MODULES" ]; then
  # find all root modules that are relative links
  # explanation:
  #   find -type l: returns all symbolic links in node_modules
  #   -lname '../': finds only relative links (those beginning with a ../)
  #   -maxdepth 1 : avoids recursion, so we don't get .bin or deep links.
  FILES=$(find $NODE_MODULES -type l -lname '../*' -maxdepth 1)
  for f in $FILES; do
    # get the pointed path of this link
    l=$(readlink "$f")
    # generate an absolute path to the linked file
    s="$(cd "$(dirname "$l")"; pwd)/$(basename "$l")"
    # remove the original link
    rm $f
    # create a new link, absolute this time (npm defaults to relative).
    ln -sv $s $f
  done
fi
