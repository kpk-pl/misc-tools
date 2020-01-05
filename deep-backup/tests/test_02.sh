#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="list_files.sh - List of files is correct when not in main directory"
source "$SOURCE/common.sh"

test_start

TARGET="$SOURCE/../list_files.sh"

[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

#Execute and compare
output="$($TARGET $TESTFILES/..)"
target_result=$?
if [[ $target_result -ne 0 ]] ; then
  log_exit "Script did not exit cleanly ($target_result)"
fi

expected="testfiles/complex/file0.txt
testfiles/complex/A/file0.txt
testfiles/complex/A/file1.txt
testfiles/complex/A/file2.txt
testfiles/complex/file1.txt
testfiles/complex/B/file0.txt
testfiles/complex/B/file1.txt
testfiles/complex/B/file2.txt
testfiles/complex/file2.txt
testfiles/flat/file0.txt
testfiles/flat/file3.txt
testfiles/flat/flat
testfiles/flat/file1.txt
testfiles/flat/file2.txt
testfiles/flat/complex
testfiles/special/space dir/space file.txt"

outputsum=$(echo "$output" | md5sum)
expectedsum=$(echo "$expected" | md5sum)

if [[ $outputsum != $expectedsum ]] ; then
  log "Expected:"
  log "$expected"
  log "Got:"
  log "$output"
  log_exit "List of files does not match expected one"
fi

test_end
