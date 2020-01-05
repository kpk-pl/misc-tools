#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="sum_verify.sh - Verifies all checksums"
source "$SOURCE/common.sh"

function test_cleanup()
{
  rm -rf $TESTFILES/sums
}

test_start

TARGET="$SOURCE/../sum_verify.sh"
[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

filelist="flat/file1.txt
flat/file2.txt
complex/A/file1.txt
complex/B/file2.txt
special/space dir/space file.txt"

mkdir -p $TESTFILES/sums/flat
md5sum $TESTFILES/flat/file1.txt > $TESTFILES/sums/flat/file1.txt
md5sum $TESTFILES/flat/file2.txt > $TESTFILES/sums/flat/file2.txt
mkdir -p $TESTFILES/sums/complex/A
md5sum $TESTFILES/complex/A/file1.txt > $TESTFILES/sums/complex/A/file1.txt
mkdir -p $TESTFILES/sums/complex/B
md5sum $TESTFILES/complex/B/file2.txt > $TESTFILES/sums/complex/B/file2.txt
mkdir -p $TESTFILES/sums/special/"space dir"
md5sum $TESTFILES/special/"space dir/space file.txt" > $TESTFILES/sums/special/"space dir/space file.txt"

# Execute
output=$(echo "$filelist" | $TARGET $TESTFILES $TESTFILES/sums)

target_result=$?
if [[ $target_result -ne 0 ]] ; then
  log_exit "Script failed with error code $target_result"
fi

outputmd5=$(echo "$output" | md5sum)
filelistmd5=$(echo "$filelist" | md5sum)

if [[ $outputmd5 != $filelistmd5 ]] ; then
  log "Expected:"
  log "$filelist"
  log "Got:"
  log "$output"
  log_exit "Script did not return expected list of entries"
fi

test_end
