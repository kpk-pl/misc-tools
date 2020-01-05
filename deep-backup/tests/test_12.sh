#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="sum_gen.sh - Handles input with spaces"
source "$SOURCE/common.sh"

function test_cleanup()
{
  rm -rf $TESTFILES/sums
}

test_start

TARGET="$SOURCE/../sum_gen.sh"
[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

filelist="flat/file0.txt
special/space dir/space file.txt
complex/B/file2.txt" 

# Execute
echo "$filelist" | $TARGET $TESTFILES $TESTFILES/sums &>/dev/null

target_result=$?
if [[ $target_result -ne 0 ]] ; then
  log_exit "Script did not exit cleanly ($target_result)"
fi

echo "$filelist" | while IFS= read -r file ; do
  [[ -f "$TESTFILES/sums/$file" ]] || log_exit "Checksum for $file was not created"
  
  chsum=$(cat "$TESTFILES/sums/$file" | cut -f1 -d' ')
  calcsum=$(md5sum "$TESTFILES/$file" | cut -f1 -d' ') 
  [[ $chsum == $calcsum ]] || log_exit "Checksum for $file is invalid. Expected $calcsum got $chsum"
done 

test_end
