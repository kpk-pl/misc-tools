#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="sum_gen.sh - Fails for missing files"
source "$SOURCE/common.sh"

function test_cleanup()
{
  rm -rf $TESTFILES/sums
}

test_start

TARGET="$SOURCE/../sum_gen.sh"
[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

# Execute
echo "missginfile.missing
flat/file1.txt" | $TARGET $TESTFILES $TESTFILES/sums

target_result=$?
if [[ $target_result -ne 4 ]] ; then
  log_exit "Script did not exit with expected (4) error code: got $target_result"
fi

test_end
