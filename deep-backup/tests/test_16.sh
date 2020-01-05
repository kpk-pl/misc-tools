#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="sum_verify.sh - Prints passed checks and returns error on mismatch"
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
flat/file3.txt"

mkdir -p $TESTFILES/sums/flat
md5sum $TESTFILES/flat/file1.txt > $TESTFILES/sums/flat/file1.txt
echo "---invalid---" > $TESTFILES/sums/flat/file2.txt
md5sum $TESTFILES/flat/file3.txt > $TESTFILES/sums/flat/file3.txt

# Execute
output=$(echo "$filelist" | $TARGET $TESTFILES $TESTFILES/sums)

target_result=$?
if [[ $target_result -ne 3 ]] ; then
  log_exit "Script did not exit with expected (3) error code: got $target_result"
fi

expectedoutput="flat/file1.txt
flat/file3.txt"
outputmd5=$(echo "$output" | md5sum)
expectedmd5=$(echo "$expectedoutput" | md5sum)

if [[ $outputmd5 != $expectedmd5 ]] ; then
  log "Expected:"
  log "$expectedoutput"
  log "Got:"
  log "$output"
  log_exit "Script did not return expected list of entries"
fi

test_end
