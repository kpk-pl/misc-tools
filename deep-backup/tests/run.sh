#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FAILURES=0
for testfile in "$SOURCE"/test_* ; do
    if ! "$testfile" run ; then
        let FAILURES++
    fi
done

if [[ $FAILURES -eq 0 ]] ; then
    echo "All tests successfull"
else
    echo "$FAILURES tests failed"
    exit $FAILURES
fi

