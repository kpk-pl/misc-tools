#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="filter.sh - Commandline checking"
source "$SOURCE/common.sh"

test_start

TARGET="$SOURCE/../filter.sh"
[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

# Execute
echo "" | $TARGET $TESTFILES $TESTFILES/sums new
[[ $? -eq 0 ]] || log_exit "Script failed with 'new' cmdline param"

echo "" | $TARGET $TESTFILES $TESTFILES/sums existing
[[ $? -eq 0 ]] || log_exit "Script failed with 'existing' cmdline param"

echo "" | $TARGET $TESTFILES $TESTFILES/sums invalid 
[[ $? -ne 0 ]] || log_exit "Script did not return error when invalid cmdline param was given"

test_end
