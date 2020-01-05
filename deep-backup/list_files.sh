#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $1 == "--debug" ]] ; then
  DEBUG=1
  shift
fi
STARTPOINT="$1"

source $SOURCE/common.sh

# ensure proper dir
cd "$STARTPOINT"

while read checksum_list ; do
  log "Processing checksum list $checksum_list"
  
  reldir="${checksum_list%/*}"
  cd "$reldir"

  prefix=${reldir#.}
  prefix=${prefix#/}

  cat "${checksum_list##*/}" | while read entry ; do
    if [[ -f "$entry" ]] ; then
      echo "${prefix:+$prefix/}$entry"
    elif [[ -d "$entry" ]] ; then
      log "Processing directory entry $entry"
      while read f ; do
        echo "${prefix:+$prefix/}$f"
      done <<< "$(find "$entry" -type f 2>/dev/null)"
    fi
  done
  
  cd - >/dev/null
done <<< "$(find . -name checksum_list -type f 2>/dev/null)"

