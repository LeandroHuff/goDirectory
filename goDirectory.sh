################################################################################
# @file         goDirectory.sh
# @brief        Source variables and functions to extend 'cd' command line using
#               pushd and popd commands.
# @author:      Leandro D. Huff
# @copyright:   https://creativecommons.org/licenses/by/4.0/
# @sintaxe:     source goDirectory.sh
################################################################################

# Must be sourced not running
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && exit 1

# declare a variable to control the load of source code.
declare godirectory=''

# function to check if goDirectory was loaded.
function isGoDirectoryLoaded() {if [[ "${godirectory}" == 'loaded' ]]; then true; else false; fi; }

# set aliases for goDir()
alias gdir='goDir'
alias gd='goDir'
alias go='goDir'

# uncomment next line to let assign 'cd' to 'goDir()' as an alias.
#alias cd='goDir'

# function to show a help and usage information.
function usageGoDir()
{
    printf "\
Function 'gDir()' (go dir) extend 'cd' command line using 'pushd' and 'popd' commands:
Usage: gDir|[gdir|gd|go] [options]
Where:
  gDir                  List the stack content.
  [gdir|gd|go]          Aliases for goDir() function.
[options]:
  -h                    Show this usage information.
  -c|--clear            Clear stack, let current path in stack, do no move from current directory.
  -                     Remove current path from stack, move to the next available in stack.
  - - - - -[ -]         Remove count (-) paths from stack, move to the next available in stack.
  - N                   Remove N paths from the stack after the current one, stay in current directory.
  -N                    Remove current and N-1 paths from the stack, move to the next path available in stack.
  /path                 Push path to stack and move to it.
  /path/1 .. /path/N    Push N path(s) to stack, move to last one in the list (N).
  ..[/]                 Move 1 level back, push it into stack.
  ../..[/]              Move 2 levels back, push last one into stack.
  ..[/]N                Move N levels back, push last one into stack.
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
            -h) usageGD ; break ;;
            -)  if echo -n "${2}" | grep -aoP '^[0-9]$' > /dev/null 2>&1
                then
                    shift
                    declare -i items=$1
                    while [ $items -gt 1 ] ; do popd -n > /dev/null 2>&1 || return $? ; items=$((items-1)) ; done
                    if [ $items -eq 1 ] ; then popd > /dev/null 2>&1 || return $? ; fi
                else
                    popd > /dev/null 2>&1 || return $?
                fi
                ;;
            -?) for ((i=$1 ; i<0 ; i++)) ; do popd > /dev/null 2>&1 || return $? ; done ;;
            -c|--clear) while true ; do popd -n > /dev/null 2>&1 || break ; done ;;
            *)  local path="$1"
                declare -i len=0
                if echo -n "${path}" | grep -aoP '^\.\.\/? *[0-9]$' > /dev/null 2>&1 ; then
                    len=$(echo -n "${path}" | grep -aoP '[0-9]$')
                    pushd -n "${PWD}" > /dev/null 2>&1 || return $?
                    while [ $len -gt 0 ] && ! [ "$PWD" = '/' ] ; do cd ../ > /dev/null 2>&1 || return $? ; len=$((len-1)) ; done
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
