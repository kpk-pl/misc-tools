#!/bin/bash

DEBUG=0

function log() {
  if [[ $DEBUG -ne 0 ]] ; then
    >&2 echo "$@"
  fi
}

function error() {
  >&2 echo "$@"
}

if ! [[ -d "$STARTPOINT" ]] ; then
  error "STARTPOINT ($STARTPOINT) is not a directory"
  exit 1
fi

