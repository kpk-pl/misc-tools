#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="filter.sh - Handles commandline options"
source "$SOURCE/common.sh"

function test_cleanup()
{
  rm -f $TESTFILES/failed.fifo
}

test_start

TARGET="$SOURCE/../filter.sh"
[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

# Execute
output=$(echo "" | $TARGET --debug $TESTFILES $TESTFILES/sums new)
[[ $? -eq 0 ]] || log_exit "Script ended with unexpected error while checking '--debug' option"

mkfifo $TESTFILES/failed.fifo
cat $TESTFILES/failed.fifo &>/dev/null &
output=$(echo "" | $TARGET --failed $TESTFILES/failed.fifo $TESTFILES $TESTFILES/sums new)
[[ $? -eq 0 ]] || log_exit "Script ended with unexpected error while checking '--failed' option"

test_end
