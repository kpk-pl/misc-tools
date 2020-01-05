#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="sum_gen.sh - Fails when checksum file already exist"
source "$SOURCE/common.sh"

function test_cleanup()
{
  rm -rf $TESTFILES/sums
}

test_start

TARGET="$SOURCE/../sum_gen.sh"
[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

mkdir -p $TESTFILES/sums/flat
touch $TESTFILES/sums/flat/file1.txt

# Execute
echo "flat/file1.txt" | $TARGET $TESTFILES $TESTFILES/sums

target_result=$?
if [[ $target_result -ne 2 ]] ; then
  log_exit "Script did not exit with expected (2) error code: got $target_result"
fi

test_end
