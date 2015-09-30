# lcomp
Dynamic language made in lua (not actually a language, but yeah)

#Implemented so far
Printing to screen, sleep function, comments, built-in doc, variables (only strings), user input, load other scripts and execute external commands

#What I'm planning to implement
More data types (lists, numbers, etc), operations, functions with arguments, command-line args

#Docs
lout: Prints to stdout. Usage: 'lout [string]'

exit: Exits program. Usage: 'exit'

sleep: Waits until the specified time has passed. It supports floats. Usage: 'sleep [number]'

comments: Ignored by the compiler, only work at the start of a line. Usage: '_[comment]'

doc: Shows documentation of a function/statement. Usage: 'doc [query]'

set: Sets a variable. Usage: 'set <name> = [value]'

lin: Gets user input, has to be used with 'set'. Usage: 'set [name] = %lin'

execute: Executes a system command, which could be potentially dangerous, use carefully! Usage: 'execute [command]

load: Loads another lc script. Usage: 'load [filename]'

variables: Once you have defined them with set (see 'doc set') you can call them with a dollar sign ($) like this:

    set foo = bar
    lout Foo value is $foo
    --Output: Foo value is bar
