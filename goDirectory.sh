#!/usr/bin/env bash

## @file        goDirectory.sh
## @brief       Source variables and functions to extend 'cd' command line by pushd and popd commands.
## @version:    1.0.7
## @author:     Leandro D. Huff
## @license:    CC BY 4.0 - https://creativecommons.org/licenses/by/4.0/
## @details:    source goDirectory.sh

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
    echo -e "\033[1;91m  error\033[0m: $(basename $0) must be sourced not running."
    return 1
fi

if [ "x$logFile" = 'x' ]
then
    echo -e "\033[1;91m  error\033[0m: logFile dependence must be loaded."
    return 2
fi

## @brief   Check a string presence by regex parameter.
function reMatch() { echo -n "$1" | grep --color=never -qaoP "$2" 2> /dev/null ; }

## @brief   Check a string presence by regex parameter and return only matching string.
function reGetStringMatch() { echo -n "$1" | grep --color=never -aoP "$2" 2> /dev/null ; }

## @brief   Pop dir from top of stack and change to that dir.
function popDirChange()  { popd &> /dev/null ; }

## @brief   Push dir to top of stack and change to that dir.
function pushDirChange() { pushd "$1" &> /dev/null ; }

## @brief   Push dir if it is not the current directory.
function pushDirNotCurrent() { if [ "$1" != "$PWD" ] ; then pushDirChange "$1" ; fi ; }

## @brief   Pop dir from stack top-1 and let current dir on top.
function popDirOnly()  { popd -n &> /dev/null ; }

## @brief   Push dir to stack top-1 and let current dir on top.
function pushDirOnly() { pushd -n "$1" &> /dev/null ; }

## @brief   Remove last dash from string and return reminings.
function removeLastDash() { echo -n ${1%-*} ; }

## @brief   Change to dir.
function changeDir() { if [ "$1" != "$PWD" ] ; then cd "$1" 2> /dev/null ; fi ; }

## @brief   Push dir if it is not on top of stack and do not change to dir.
function pushDirNotOnTopOnly()
{
    local regex="^$1 "
    local list="$(dirs)"
    if ! reMatch "$list" "$regex" ; then pushDirOnly "$1" ; fi
}

## @brief   Push dir if it is not on top of stack and change to dir.
function pushDirNotOnTop()
{
    local regex="^$1 "
    local list="$(dirs)"
    if ! reMatch "$list" "$regex" ; then pushDirChange "$1" ; fi
}

## @brief   Go to directory and back by a stack of dirs.
function goDir()
{
    local version='1.0.7'
    local path=''
    local -i len=0
    if [ $# -gt 0 ]
    then
        while [ -n "$1" ]
        do
            case "$1" in
            -V|--version)
                version "$version"
                break
                ;;
            -h|--help)
                echo -e "\
Function 'goDir()' (go dir) extend 'cd' command line using 'pushd' and 'popd' commands.
Version: ${version}
Usage: goDir  [options]
[options]:
  empty                 Show the stack content list.
  -V|--version          Show application version.
  -h|--help             Show this usage information.
  -c|-clr|--clear       Clear stack, let current path on stack, do not move from current directory.
  - |--back             Remove current path from the stack, move to the next available on stack.
  -[ - - ... -]         Remove count '-' paths from the stack, move to the next available on stack.
  - N                   Remove N paths from the stack after the current one, stay at current directory.
  -N                    Remove current and N-1 paths from the stack, move to the next path available on stack.
  /path                 Push path to the stack and move to it.
  /path/1 .. /path/N    Push N path(s) to the stack, move to the last one for list (N).
  ..[/]                 Move 1 level back, push it on the stack.
  ../..[/]              Move 2 levels back, push last one on the stack.
  ..[/]N                Move N levels back, push last one on the stack.
"
                break
                ;;
            -c|-clr|--clear)
                while popDirOnly
                do
                    :
                done
                ;;
            -[0-9])
                if (($1 < 0))
                then
                    for ((i=$1 ; i<-1 ; i++)) ; do popDirOnly || return $? ; done
                    popDirChange || return $?
                fi
                ;;
            -*)
                local reNumericParam='^- *[1-9] *$'
                local reDashParam='^(- *){2,}$'
                local reNumberOnly='[1-9]'
                if reMatch "$*" "$reNumericParam"
                then
                    if reMatch "$*" "$reNumberOnly"
                    then
                        len=$(reGetStringMatch "$*" "$reNumberOnly")
                        while ((len > 1))
                        do
                            popDirOnly || return $?
                            ((len--))
                        done
                    fi
                elif reMatch "$*" "$reDashParam"
                then
                    path="$*"
                    while reMatch "$path" "$reDashParam"
                    do
                        popDirOnly || return $?
                        path="$(removeLastDash ${path})"
                    done
                fi
                popDirChange || return $?
                ;;
            *)
                local reNumericParam='^ *\.\./? *[1-9] *$'
                local reDotsParam='^ *(\.\./?)|((\.\./)+) *$'
                local reNumberOnly='[0-9]'
                local stepBack='../'
                local rootDir='/'
                path="$1"
                if reMatch "$path" "$reNumericParam"
                then
                    pushDirNotOnTopOnly "$PWD"
                    len=$(reGetStringMatch "$path" "$reNumberOnly")
                    if ((len > 0))
                    then
                        while ((len > 0)) && ! [ "$PWD" = "$rootDir" ]
                        do
                            changeDir "$stepBack" || return $?
                            ((len--))
                        done
                    fi
                    pushDirNotOnTop "$PWD" || return $?
                elif reMatch "$path" "$reDotsParam"
                then
                    if ! [ "$PWD" = "$rootDir" ]
                    then
                        pushDirNotOnTop "$path" || return $?
                    fi
                else
                    pushDirNotCurrent "$path"
                fi
                ;;
            esac
            shift
        done
    else
        dirs
    fi

    return 0
}

declare goDirFile='loaded'
