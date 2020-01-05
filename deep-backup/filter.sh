DEBUG=0
FAILED_FIFO=
SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while [[ $1 == --* ]] ; do
  case "$1" in
--debug)
    DEBUG=1
    shift
    ;;
--failed)
    FAILED_FIFO="$2"
    shift ; shift
    ;;
  esac
done
STARTPOINT="$1"
SUMSDIR="$2"
TYPE="$3"

source $SOURCE/common.sh

if [[ "$TYPE" != new ]] && [[ "$TYPE" != existing ]] ; then
  error "Incorrect TYPE: 'new' or 'existing' expected"
  exit 1
fi

# ensure proper dir
cd "$STARTPOINT"

if [[ -n "$FAILED_FIFO" ]] ; then
  if ! [[ -p "$FAILED_FIFO" ]] ; then
    error "Fifo $FAILED_FIFO does not exist'" ;
    exit 2
  fi
  exec 3>"$FAILED_FIFO"
fi


while read entry ; do
  [[ -z "$entry" ]] && continue

  log "Processing entry $entry"
  if ! [[ -f "$entry" ]] ; then
    error "Entry $entry does not exist"
    exit 1
  fi

  if [[ -f "$SUMSDIR/$entry" ]] ; then
    if [[ $TYPE == existing ]] ; then
      echo "$entry"
    elif [[ -n "$FAILED_FIFO" ]] ; then
      echo "$entry" >&3
    fi
  else
    if [[ $TYPE == new ]] ; then
      echo "$entry"
    elif [[ -n "$FAILED_FIFO" ]] ; then
      echo "$entry" >&3
    fi
  fi
done

[[ -n "$FAILED_FIFO" ]] && exec 3>&-

exit 0
