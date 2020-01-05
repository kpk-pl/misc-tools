#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="filter.sh - Returns list of new files"
source "$SOURCE/common.sh"

function test_cleanup()
{
  rm -rf $TESTFILES/sums
}

test_start

TARGET="$SOURCE/../filter.sh"
[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

listoffiles="flat/file1.txt
flat/file2.txt
complex/A/file1.txt
complex/B/file2.txt"

expectedlist="flat/file2.txt
complex/A/file1.txt"

mkdir -p $TESTFILES/sums/flat
mkdir -p $TESTFILES/sums/complex/B
touch $TESTFILES/sums/flat/file1.txt
touch $TESTFILES/sums/complex/B/file2.txt

# Execute
output=$(echo "$listoffiles" | $TARGET $TESTFILES $TESTFILES/sums new)
[[ $? -eq 0 ]] || log_exit "Script ended with unexpected error"

outputmd5=$(echo "$output" | md5sum)
expectedmd5=$(echo "$expectedlist" | md5sum)

if [[ $outputmd5 != $expectedmd5 ]] ; then
  log "Expected:"
  log "$expectedlist"
  log "Got:"
  log "$output"
  log_exit "Did not receive correct list of files"
fi

test_end
