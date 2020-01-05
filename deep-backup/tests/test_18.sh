#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="filter.sh - Fails when fifo does not exist"
source "$SOURCE/common.sh"

function test_cleanup()
{
  true;
}

test_start

TARGET="$SOURCE/../filter.sh"
[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

# Execute
echo "" | $TARGET --failed $TESTFILES/failed.fifo $TESTFILES $TESTFILES/sums new >/dev/null
err_code=$?
[[ $err_code -eq 2 ]] || log_exit "Script did not exit with expected (2) error code: got $err_code"

test_end
