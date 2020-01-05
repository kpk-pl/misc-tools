#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MAIL_BIN=/opt/mail/send_mail_admin.sh

# log for failed verification of existing files
VERIFY_ERRORLOG=/tmp/deep_bkp_failed_ver.log
# log for failed verification of new files
CREATE_VERIFY_ERRORLOG=/tmp/deep_bkp_failed_new.log
# log for new entries
NEW_ENTRIES_LOG=/tmp/deep_bkp_added.log
# fifo for filtering entries
NEW_ENTRIES=/tmp/deep_bkp.fifo
# temp dir for marking new entries being processed
NEW_TMP=/tmp/deep_bkp_new_tmp

RSYNC_CMD="rsync --files-from=$NEW_ENTRIES_LOG --quiet --perms --owner --group --times --perms --ignore-existing --protect-args"
RESOURCES="$VERIFY_ERRORLOG $CREATE_VERIFY_ERRORLOG $NEW_ENTRIES_LOG"
REMOTE=

if [[ "$1" == --clean ]] ; then
    rm -r $VERIFY_ERRORLOG $CREATE_VERIFY_ERRORLOG $NEW_ENTRIES_LOG $NEW_ENTRIES $NEW_TMP 2>/dev/null
    exit 0
fi
if [[ "$1" == --remote ]] ; then
    REMOTE="$2"
    shift ; shift 
fi

STARTPOINT="$1"
SUMSPOINT="$2"

mkdir -p $NEW_TMP || { $MAIL_BIN "[deep-backup] Cannot create $NEW_TMP" "Cannot continue" ; exit 1 ; }
LEFT_FILES="$(find $NEW_TMP -type f)"
[[ -n "$LEFT_FILES" ]] && { $MAIL_BIN "[deep-backup] Found leftover files" "$LEFT_FILES" "Cannot continue" ; exit 2 ; }

mkfifo $NEW_ENTRIES || $MAIL_BIN "[deep-backup] Cannot create fifo $NEW_ENTRIES"
RESOURCES+=" $NEW_ENTRIES"

$MAIL_BIN "[deep-backup] Starting" "\
REMOTE     = $REMOTE
SOURCE     = $SOURCE
STARTPOINT = $STARTPOINT
SUMSPOINT  = $SUMSPOINT"

cat $NEW_ENTRIES | \
    while read entry ; do
        ent=$NEW_TMP/"$entry"
        mkdir -p "${ent%/*}"
        touch "$ent"
        echo "$entry"
    done | \
    $SOURCE/sum_gen.sh $STARTPOINT $SUMSPOINT | \
    $SOURCE/sum_verify.sh $STARTPOINT $SUMSPOINT 2>$CREATE_VERIFY_ERRORLOG | \
    while read entry ; do
        rm $NEW_TMP/"$entry"
        echo "$entry"
    done > $NEW_ENTRIES_LOG &

$SOURCE/list_files.sh $STARTPOINT | \
    $SOURCE/filter.sh --failed $NEW_ENTRIES $STARTPOINT $SUMSPOINT existing | \
    $SOURCE/sum_verify.sh $STARTPOINT $SUMSPOINT >/dev/null 2>$VERIFY_ERRORLOG
VERIFICATION_RETCODE=$?

wait %1
CREATION_RETCODE=$?

# check all post-conditions and notify user

MAIN_RETCODE=0
if [[ $CREATION_RETCODE -ne 0 ]] || [[ $VERIFICATION_RETCODE -ne 0 ]] ; then
    MAIN_RETCODE=1
    $MAIL_BIN "[deep-backup] Error returned" "verification($VERIFICATION_RETCODE) creation($CREATION_RETCODE)"
fi

LEFT_FILES="$(find $NEW_TMP -type f)"
[[ -n "$LEFT_FILES" ]] && MAIN_RETCODE=2 && \
    $MAIL_BIN "[deep-backup] Found leftover files after processing" "$LEFT_FILES"

[[ -s $VERIFY_ERRORLOG ]] && MAIN_RETCODE=3 && \
    $MAIL_BIN -f "[deep-backup] $(cat $VERIFY_ERRORLOG | wc -l) errors during validation" $VERIFY_ERRORLOG

[[ -s $CREATE_VERIFY_ERRORLOG ]] && MAIN_RETCODE=4 && \
    $MAIL_BIN -f "[deep-backup] $(cat $CREATE_VERIFY_ERRORLOG | wc -l) errors during checksum creation" $CREATE_VERIFY_ERRORLOG

[[ -s $NEW_ENTRIES_LOG ]] && \
    $MAIL_BIN -f "[deep-backup] $(cat $NEW_ENTRIES_LOG | wc -l) new files found and processed" $NEW_ENTRIES_LOG

if [[ $MAIN_RETCODE -eq 0 ]] && [[ -s $NEW_ENTRIES_LOG ]] && [[ -n "$REMOTE" ]] ; then
    $MAIL_BIN "[deep-backup] Starting rsync over to remote (files)"
    if ! $RSYNC_CMD $STARTPOINT $REMOTE ; then
        MAIN_RETCODE=10 
        $MAIL_BIN "[deep-backup] Rsync error while copying files to remote"
    else
        $MAIL_BIN "[deep-backup] Starting rsync over to remote (sums)"
        if ! $RSYNC_CMD $SUMSPOINT $REMOTE/sums ; then
            MAIN_RETCODE=11
            $MAIL_BIN "[deep-backup] Rsync error whole copying sums to remote"
        fi
    fi

    if [[ $MAIN_RETCODE -ne 0 ]] ; then
        NEW_ENTRIES_COPY=$(mktemp)
        cp $NEW_ENTRIES_LOG $NEW_ENTRIES_COPY
        $MAIN_BIN "[deep-backup] Remote operation failed" "List of files saved in $NEW_ENTRIES_COPY"
    fi
fi

$MAIL_BIN "[deep-backup] Finished" "main_retcode=$MAIN_RETCODE"

rm $RESOURCES
exit $MAIN_RETCODE
