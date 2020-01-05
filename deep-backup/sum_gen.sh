DEBUG=0

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $1 == "--debug" ]] ; then
  DEBUG=1
  shift
fi
STARTPOINT="$1"
SUMSPOINT="$2"

source $SOURCE/common.sh

if [[ -d "$SUMSPOINT" ]] ; then
  log "Directory for storing sums exists already"
fi

# ensure proper dir
cd "$STARTPOINT"

# create directory for sums if does not exists yet
if ! [[ -d "$SUMSPOINT" ]] ; then
  if ! mkdir -p "$SUMSPOINT" ; then
    error "Cannot create $SUMSPOINT"
    exit 1
  fi
fi

while read entry ; do
  [[ -z "$entry" ]] && continue

  sumfile="$SUMSPOINT/$entry"
  if [[ -f "$sumfile" ]] ; then
    error "Checksum file "$sumfile" exists!"
    exit 2
  fi

  if ! [[ -f "$entry" ]] ; then
    error "File $entry does not exist"
    exit 4
  fi

  if ! mkdir -p "${sumfile%/*}" ; then
    error "Cannot create directory for file $entry"
    exit 3
  fi

  if ! md5sum "$entry" > "$sumfile" ; then 
    error "md5sum creation failed"
    exit 5
  fi

  echo "$entry"
done
