#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TESTFILES="$SOURCE/testfiles"
TESTTEMPDIR=$TESTFILES/temp

TEST_NAME="${TEST_NAME:-Test}"

function test_cleanup()
{
    true;
}

function log()
{
    echo "  $@"
}

function log_exit()
{
    echo "/\/\/\ ERROR: $@ /\/\/\ "
    test_end noexit
    exit 1
}

function test_start()
{
    echo "---- Starting ${0##*/}: \"$TEST_NAME\""
}

function test_end()
{
    echo "---- Ending   ${0##*/}"
    test_cleanup
    [[ $1 == noexit ]] && return 0
    exit 0
}

