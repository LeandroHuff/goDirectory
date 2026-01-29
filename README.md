# [goDirectory](https://github.com/LeandroHuff/goDirectory)

Author: [Leandro D. Huff](https://github.com/LeandroHuff)

Function gDir() (go directory) extend 'cd' command line using 'pushd' and 'popd' commands over a stack path list.

### Source and load

``` sh
source goDirectory.sh
```

### Usage and parameters

``` sh
goDir [option]
```

### Options and arguments

Function 'goDir()' accept some command line parameters that control how it move paths in/out a stack list and move/change forward and backward to and from directories stack list.

| Parameter                | Description                                                                                     |
|:-------------------------|:------------------------------------------------------------------------------------------------|
| **gDir**                 | With no parameters, list the stack content.                                                     |
| **--help**               | Show this usage information.                                                                    |
| **--clear**              | Clear stack, let current path in stack, do no change from current directory.                    |
| **-**                    | Remove current path from stack, move to the next available in stack.                            |
| **-** **-** [**-**]      | Remove count (-) paths from stack, move to the next available in stack.                         |
| **- N**                  | Remove N (number) paths from the stack after the current one, stay in current directory.        |
| **-N**                   | Remove current and N-1 (number) paths from the stack, move to the next path available in stack. |
| **/path**                | Push path to stack and move to it.                                                              |
| **/path/1**..**/path/N** | Push path list into stack, move to last one in the list (N).                                    |
| **..**[**/**]            | Move 1 level back, push it into stack.                                                          |
| **../..**[**/**]         | Move 2 levels back, push last one into stack.                                                   |
| **..**[**/**]_N_         | Move N (number) levels back, push last one into stack.                                          |

### Stack list

All **goDir**() functionalities is based on _pushd_ and _popd_ Linux commands, for more details can be obtained by **pushd** _--help_ or **pophd** _--help_ command line and parameters.
The internal main part of this resource is the path list, it's an internal system stack that store the a path list of last paths moved in or from.
Over this path the script can move into directories by getting path from the stack or storing new ones into the stack for next movies.

        Last [0]      N [1]         N [2]         N [3]         N [4] 
[*top*] _/path/dir5_  _/path/dir4_  _/path/dir3_  _/path/dir2_  _/path/dir1_  [*bottom*]

Some parameters use an integer number 'N' as parameter value to control its behaviour, this number is the counter number of positions in the list, starting from the first [0|top] until the last one [N|bottom] item in the stack list.

Understand this resource is fundamental to understand the source code functionality.

Supose a path stack list as follow:

[**top**] _/path/dir5_  _/path/dir4_  _/path/dir3_  _/path/dir2_  _/path/dir1_  [**bottom**]

We'd like to remove current path from [**top**] position and N-1 paths from the stack list as:

``` sh
# list the stack content
/path/dir5> goDir
'/path/dir5' '/path/dir4' '/path/dir3' '/path/dir2' '/path/dir1'
# remove 3 paths from the stack and move to next
/path/dir5> goDir -3
# list the stack content
/path/dir2> goDir
'/path/dir2' '/path/dir1'
/path/dir2> |
```

In this example, -N mean number of items in the stack list, not the index position.
The result will be something like:

[**top**] _/path/dir2_  _/path/dir1_  [**bottom**]

Where _/path/dir2_ will be new current directory at prompt command line.

For more information about options and parameters use the follow command line:

``` sh
goDir -h
```

This source code can be updated and extended adding new parameters and functionalities, the information can be obtained by **pushd** and **popd** _help_ and man pages.

Be free to contact the author for sugestions and contribute to add new (or fix) any functionality(ies) in this source code.

#### [License](https://creativecommons.org/licenses/by/4.0/)
