#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="sum_verify.sh - Fails when checksum file is missing"
source "$SOURCE/common.sh"

function test_cleanup()
{
  rm -rf $TESTFILES/sums
}

test_start

TARGET="$SOURCE/../sum_verify.sh"
[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

filelist="flat/file0.txt" 

mkdir -p $TESTFILES/sums/flat

# Execute
echo "$filelist" | $TARGET $TESTFILES $TESTFILES/sums &>/dev/null

target_result=$?
if [[ $target_result -ne 2 ]] ; then
  log_exit "Script did not exit with expected (2) error code: got $target_result"
fi

test_end
