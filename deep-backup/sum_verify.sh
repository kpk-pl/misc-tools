DEBUG=0

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $1 == "--debug" ]] ; then
  DEBUG=1
  shift
fi
STARTPOINT="$1"
SUMSPOINT="$2"

source $SOURCE/common.sh

# ensure proper dir
cd "$STARTPOINT"

result=0

while read entry ; do
  [[ -z "$entry" ]] && continue

  if ! [[ -f "$entry" ]] ; then
    error "$entry: file does not exist"
    exit 1
  fi

  sumfile="$SUMSPOINT/$entry"
  if ! [[ -f "$sumfile" ]] ; then
    error "$entry: Checksum file "$sumfile" does not exists!"
    exit 2
  fi

  filesum=$(md5sum "$entry" | cut -f1 -d' ')  
  storedsum=$(cat "$sumfile" | cut -f1 -d' ')

  if [[ $filesum != $storedsum ]] ; then
    error "$entry: checksum mismatch: expected $storedsum calculated $filesum"
    let result++
  else
    echo "$entry"
  fi
done

[[ $result -eq 0 ]] || exit 3
