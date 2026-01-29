################################################################################
# @file         goDirectory.sh
# @brief        Source variables and functions to extend 'cd' command line by pushd and popd commands.
# @version:     1.0
# @author:      Leandro D. Huff
# @license:     CC BY 4.0 - https://creativecommons.org/licenses/by/4.0/
# @details:     source goDirectory.sh
################################################################################

# Must be sourced not running
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && exit 1

# version number
declare -a gdVersion=(1 0 0)

# declare a variable to control the load of source code.
declare godirectory=''

# function to check if goDirectory was loaded.
function isGoDirectoryLoaded() { if [[ "${godirectory}" == 'loaded' ]]; then true; else false; fi; }

# set aliases for goDir()
alias godir='goDir'
alias gd='goDir'

# uncomment next lines to assign 'go' to goDir() as an alias.
#alias go='goDir'

# function to show a help and usage information.
function usageGoDir()
{
    printf "\
Function 'gDir()' (go dir) extend 'cd' command line using 'pushd' and 'popd' commands.
Version: ${gdVersion[0]}.${gdVersion[1]}.${gdVersion[2]}
Usage: gDir|[gdir|gd] [options]
Where:
  gDir                  List the stack content.
  [gdir|gd]             Aliases for goDir() function.
[options]:
  --help                Show this usage information.
  --clear               Clear stack, let current path in stack, do no move from current directory.
  -                     Remove current path from the stack, move to the next available in stack.
  - - - -[.. -]         Remove count '-' paths from the stack, move to the next available in stack.
  - N                   Remove N paths from the stack after the current one, stay in current directory.
  -N                    Remove current and N-1 paths from the stack, move to the next path available in stack.
  /path                 Push path to the stack and move to it.
  /path/1 .. /path/N    Push N path(s) to the stack, move to last one in the list (N).
  ..[/]                 Move 1 level back, push it into the stack.
  ../..[/]              Move 2 levels back, push last one into the stack.
  ..[/]N                Move N levels back, push last one into the stack.
"
}

# function go change to/from directories by a stack using pushd and popd commands.
# goDir() function accept some arguments, look at usageGoDir() or pass -h as an argument.
function goDir()
{
    if [ $# -gt 0 ]
    then
        while [ -n "$1" ]
        do
            case "$1" in
            --help)
                usageGD
                break
                ;;
            --clear)
                while popd -n > /dev/null 2>&1
                do
                    :
                done
                ;;
            -)
                if echo -n "${2}" | grep -aoP '^[0-9]$' > /dev/null 2>&1
                then
                    shift
                    declare -i items=$1
                    while (( $items == 1 ))
                    do
                        popd -n > /dev/null 2>&1 || return $?
                        items=$((items-1))
                    done
                    if (( $items == 1 ))
                    then
                        popd > /dev/null 2>&1 || return $?
                    fi
                else
                    popd > /dev/null 2>&1 || return $?
                fi
                ;;
            -[1-9])
                for ((i=$1 ; i<0 ; i++))
                do
                    popd > /dev/null 2>&1 || return $?
                done
                ;;
            *)
                local path="$1"
                declare -i len=0
                if echo -n "${path}" | grep -aoP '^\.\.\/? *[0-9]$' > /dev/null 2>&1
                then
                    pushd -n "${PWD}" > /dev/null 2>&1 || return $?
                    len=$(echo -n "${path}" | grep -aoP '[0-9]$')
                    while (( $len > 0 )) && ! [ "$PWD" = '/' ]
                    do
                        cd ../ > /dev/null 2>&1 || return $?
                        ((len--))
                    done
                    pushd "${PWD}" > /dev/null 2>&1 || return $?
                else
                    pushd "${path}" > /dev/null 2>&1 || return $?
                fi
                ;;
            esac
            shift
        done
    else
        dirs
    fi
}

# set a variable to control if source code was loaded successfully.
godirectory='loaded'
