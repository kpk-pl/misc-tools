#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

TEST_NAME="main.sh - Notifies about errors and updates in backup"
source "$SOURCE/common.sh"

function test_cleanup()
{
  rm -rf $TESTFILES/sums
  rm -f $TESTFILES/flat/newly_created.txt
  rm -rf $TESTFILES/remote
}

test_start

TARGET="$SOURCE/../main.sh"
[ -f "$TARGET" ] || log_exit "$TARGET does not exist"

log "Cleaning /tmp log entries"
$TARGET --clean || log_exit "Cannot execute --clean action for script"

function confirm_notif()
{
    local ans
    read -n1 -p "Did you receive notification about $1? [Y/n]" ans ; echo
    [[ "$ans" == Y ]] || log_exit "Notification failed"
}

log "Executing to create checksums for all entries"
$TARGET $TESTFILES $TESTFILES/sums
target_res=$?
[[ $target_res -eq 0 ]] || log_exit "Script ended with unexpected error ($target_res)"

confirm_notif "script startup"
confirm_notif "finding $(find $TESTFILES -type f -not -path $TESTFILES/sums/\* -not -name checksum_list | wc -l) new files"
confirm_notif "script finishing"

NEW_FILE=$TESTFILES/flat/newly_created.txt
log "Creating new file $NEW_FILE"
echo "some content" > $NEW_FILE

log "Executing with remote to check file synchronization"
mkdir $TESTFILES/remote
$TARGET --remote "127.0.0.1:$TESTFILES/remote" $TESTFILES $TESTFILES/sums
target_res=$?
[[ $target_res -eq 0 ]] || log_exit "Script ended with unexpected error ($target_res)"

confirm_notif "finding 1 new file"
confirm_notif "starting file synchronization process"
confirm_notif "starting sums synchronization process"
[[ -f $TESTFILES/remote/flat/newly_created.txt ]] || log_exit "Cannot find file copied to fake remote"
[[ -f $TESTFILES/remote/sums/flat/newly_created.txt ]] || log_exit "Cannot find sum copied to fake remote"

REMOVED_FILES="$TESTFILES/sums/flat/file1.txt $TESTFILES/sums/complex/A/file1.txt"
log "Removing sums for $REMOVED_FILES"
rm $REMOVED_FILES

DAMAGED_SUMS="$TESTFILES/sums/flat/file2.txt"
log "Damaging sums for $DAMAGED_SUMS"
for sum in $DAMAGED_SUMS ; do echo "DAMAGED" > $sum ; done

log "Executing to perform updates and report errors"
$TARGET $TESTFILES $TESTFILES/sums
target_res=$?
[[ $target_res -ne 0 ]] || log_exit "Script ended without error code"

confirm_notif "script returning error during validation"
confirm_notif "finding 1 checksum mismatch"
confirm_notif "finding 2 new files"

test_end
