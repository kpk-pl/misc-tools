#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="filter.sh - Returns failed entries to fifo"
source "$SOURCE/common.sh"

function test_cleanup()
{
  rm -rf $TESTFILES/sums
  rm -f $TESTFILES/failed.fifo
  rm -f $TESTFILES/output.txt
  rm -f $TESTFILES/failed.fifo.txt
}

test_start

TARGET="$SOURCE/../filter.sh"
[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

listoffiles="flat/file1.txt
flat/file2.txt
complex/A/file1.txt
complex/B/file2.txt"

expectedlist="flat/file2.txt
complex/A/file1.txt"

failedlist="flat/file1.txt
complex/B/file2.txt"

mkdir -p $TESTFILES/sums/flat
mkdir -p $TESTFILES/sums/complex/B
touch $TESTFILES/sums/flat/file1.txt
touch $TESTFILES/sums/complex/B/file2.txt

# Execute
mkfifo $TESTFILES/failed.fifo
cat $TESTFILES/failed.fifo > $TESTFILES/failed.fifo.txt &
echo "$listoffiles" | $TARGET --failed $TESTFILES/failed.fifo $TESTFILES $TESTFILES/sums new > $TESTFILES/output.txt

target_res=$?
[[ $target_res -eq 0 ]] || log_exit "Script ended with unexpected error ($target_res)"

outputmd5=$(cat $TESTFILES/output.txt | md5sum)
expectedmd5=$(echo "$expectedlist" | md5sum)

if [[ $outputmd5 != $expectedmd5 ]] ; then
  log "Expected:"
  log "$expectedlist"
  log "Got:"
  log "$(cat $TESTFILES/output.txt)"
  log_exit "Did not receive correct list of files"
fi

failedmd5=$(echo "$failedlist" | md5sum)
fifomd5=$(cat $TESTFILES/failed.fifo.txt | md5sum)

if [[ $failedmd5 != $fifomd5 ]] ; then
  log "Expected:"
  log "$failedlist"
  log "Got:"
  log "$(cat $TESTFILES/failed.fifo.txt)"
  log_exit "Did not receive correct list of failed files from fifo"
fi

test_end
