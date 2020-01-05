#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="sum_gen.sh - Does not fail when directory for sums exists"
source "$SOURCE/common.sh"

function test_cleanup()
{
  rm -rf $TESTFILES/sums
}

test_start

TARGET="$SOURCE/../sum_gen.sh"
[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

mkdir -p $TESTFILES/sums

# Execute
echo "" | $TARGET $TESTFILES $TESTFILES/sums
target_result=$?
if [[ $target_result -ne 0 ]] ; then
  log_exit "Script did not exit cleanly ($target_result)"
fi

[[ -d $TESTFILES/sums ]] || log_exit "$TESTFILES/sums does not exist"

test_end
