#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="sum_gen.sh - Returns list of files"
source "$SOURCE/common.sh"

function test_cleanup()
{
  rm -rf $TESTFILES/sums
}

test_start

TARGET="$SOURCE/../sum_gen.sh"
[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

listoffiles="flat/file1.txt
flat/file2.txt
complex/A/file1.txt
complex/B/file2.txt"

# Execute
outputmd5=$(echo "$listoffiles" | $TARGET $TESTFILES $TESTFILES/sums | md5sum)

listmd5=$(echo "$listoffiles" | md5sum)

[[ $outputmd5 == $listmd5 ]] || log_exit "Output does not match input"

test_end
