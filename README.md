# lcomp
Dynamic language made in lua (not actually a language, but yeah)

#Implemented so far
Printing to screen, sleep function, comments, built-in doc, variables (only strings and numbers), user input, load other scripts, functions, if-else and execute external commands

#What I'm planning to implement
Lists, function args, command-line args

#Docs
lout: Prints to stdout. Usage: 'lout [string]'

exit: Exits program. Usage: 'exit'

sleep: Waits until the specified time has passed. It supports floats. Usage: 'sleep [number]'

comments: Ignored by the compiler, only work at the start of a line. Usage: '_[comment]'

doc: Shows documentation of a function/statement. Usage: 'doc [query]'

set: Sets a variable. Usage: 'set [name] = [value]'

lin: Gets user input. Usage: 'lin [varname]'

execute: Executes a system command, which could be potentially dangerous, use carefully! Usage: 'execute [command]

load: Loads another lc script. Usage: 'load [filename]'

variables: Once you have defined them with set (see 'doc set') you can call them with a dollar sign ($) like this:

    set foo = bar
    lout Foo value is $foo
    --Output: Foo value is bar

math: Perform an operation with '<>' Usage example:

    lout 5+5 is <>5+5<> ! 
    _Output: '5+5 is 10 !'
    set foo = <>5/2<>
    lout result is <> $foo + 3<>!
    _Output: 'result is 5.5 !'
    
    _Note: variables have to be surrounded by spaces to work

if/else: Compare expressions (only '==').
Usage:
  if condition
    _Code
  else
    _Code
  end
Usage example:
  set foo = bar
  if $foo == bar
    lout yes
  else
    lout no
  end
  _Output: yes

functions: Create reusable functions.
Usage:
  _To create them
  func <name>
    _Code
  end
  _To call them
  %<name>
Usage example:
  func foo
    lout bar
  end
  %foo
  _Output = 'bar'