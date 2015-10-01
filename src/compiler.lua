require "os"
local readline = require "readline"

compiler = {inFile = false, mode = "normal", ifOrElse = "none", prompt = "::"} --The compiler object

compiler.variables = {} --Variables are stored here

compiler.docs = { --Doc entries are stored here
lout = "Prints to stdout.\nUsage: 'lout <string>'",
exit = "Exits program.\nUsage: 'exit'",
sleep = "Waits until the specified time has passed. It supports floats.\nUsage: 'sleep <number>'",
comments = "Ignored by the compiler, only work at the start of a line.\nUsage: '_<comment>'",
doc = "Shows documentation of a function/statement.\nUsage: 'doc <query>'",
set = "Sets a variable.\nUsage: 'set <name> = <value>'",
lin = "Gets user input.\nUsage: 'lin <varname>'",
execute = "Executes a system command, which could be potentially dangerous, use carefully!\nUsage: 'execute <command>'",
load = "Loads another lc script.\nUsage: 'load <filename>'",
variables = "Once you have defined them with set (see 'doc set') you can call them with a dollar sign ($).\nUsage example:\n'set foo = bar', 'lout $foo'",
math = "Perform an operation with <>.\nUsage example:\n'lout 5+5 is <>5+5<> !', 'set foo = <>5/2*3-6<>'",
if_else = [[Compare expressions.
Usage example:
  set foo = bar
  if $foo == bar
    lout yes
  else
    lout no
  end
_Output: yes]],
list = function()
  for content,ln in pairs(compiler.docs) do print(content) end
end
}

function compiler.error(msg)
	print("ERROR: "..msg)
	if compiler.inFile then os.exit() end --Exits if lc is executing a file
	return 1
end

function compiler.lout(parts)
  if parts[2] == nil then parts[2] = "" end
	for i=2, #parts, 1 do
    io.write(parts[i].." ")
	end
	print()
end

function compiler.lin(v)
  if v == nil then readline.readline() else
  compiler.variables[v] = readline.readline() end
end

function compiler.load(f)
	if f == nil then return compiler.error("Filename expected after expression 'load'") end
	file = io.open(f, "r")
	if file then
		compiler.readf(file)
		if not compiler.inFile then local tmpinf = false else local tmpinf = true end
	else return compiler.error("File can't be found/executed.") end
	compiler.inFile = tmpinf
end

function compiler.sleep(sec)
	--Checks if you inputed a valid number
	if tonumber(sec) == nil then return compiler.error("Number expected after expression 'sleep'") end
	local ntime = os.time() + sec
	repeat until os.time() > ntime
end

function compiler.set(name, eq, value)
	if name == nil or eq == nil or value == nil then --Checks if you inputed everything correctly
		return compiler.error("Name and value expected after expression 'set'")

	elseif eq ~= "=" then
		return compiler.error("Unexpected symbol '"..eq.."' near '"..name.."'")
  else
    compiler.variables[name] = value
	end
end

function compiler.ifelse(words)
  compiler.mode = "ifelse"
  compiler.prompt = ".."
  words[1] = nil
  local cond = split(join(words), " == ")
  if cond[2] ~= nil then
    if cond[1] == cond[2] then --equal
      compiler.ifOrElse = "if"
    else
      compiler.ifOrElse = "else"
    end
    
  else
    compiler.prompt = "::"
    compiler.mode = "normal"
    return compiler.error("Malformed condition after expression 'if'")
  end
end
  
function compiler.doc(query)
	--Checks if you entered a query
	if query == nil then return compiler.error("Query expected after expresion 'doc'")
	elseif compiler.docs[query] == nil then --Checks if doc entry exists
		return compiler.error("No entry for "..query)
	end

	if type(compiler.docs[query]) ~= "string" then compiler.docs[query]() --To execute functions
	else print(compiler.docs[query]) --To print normal entries
	end

end

function join(t)
	x = ""
	for key, value in pairs(t) do
		if x == "" then x = value
		else x = x.." "..value end
	end
	return x
end

function split(inputstr, sep) --Function that splits a string by the separator you entered. Default is space
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end



function compiler.proccess(string) --Main function, executes strings
  command = split(string) --Splits into words

	for i=1, #command, 1 do --Very important: Replaces every word starting with '$' to its variable value
		if command[i]:sub(1,1) == "$" then
			command[i] = compiler.variables[command[i]:sub(2, #command[i])]
		end
	end

	string = join(command) --Converts again into string

	halfs = split(string, "<>") --Splits by '<>' to make operations separately
	if halfs[2] ~= nil then
		opr = loadstring("opr = "..halfs[2])
		opr()
		halfs[2] = opr
		string = join(halfs) --Transforms in string again
	end
	command = split(string) --Splits into words again
  
  if command[1] == "end" then --Exit if/else clauses
      compiler.mode = "normal"
      compiler.prompt = "::"
      compiler.didIf = false
      return 0
  end
  
  if compiler.mode == "ifelse" then
    --print("--"..compiler.ifOrElse.."--") --For debugging
    if command[1] == "else" then
      compiler.didIf = true
      
    elseif compiler.didIf and compiler.ifOrElse == "if" then
      return 0
    
    elseif not compiler.didIf and compiler.ifOrElse == "else" then
      return 0
      
    elseif compiler.didIf and compiler.ifOrElse == "else" then
      _a = nil
    end
  end
  
	--Commandss
	if command[1] == "exit" then
		os.exit()

	elseif command[1] == "lout" then
		compiler.lout(command)
    
  elseif command[1] == "lin" then
    compiler.lin(command[2])

  elseif command[1] == "if" then
		compiler.ifelse(command)
    
	elseif command[1] == "sleep" then
		compiler.sleep(command[2])

	elseif command[1] == "doc" then
		compiler.doc(command[2])

	elseif command[1] == "execute" then
		local _command = command
		_command[1] = nil
		exe = join(_command)
		os.execute(exe)

	elseif command[1] == "load" then
		compiler.load(command[2])

	elseif command[1] == "set" then
		local val = ""
		for i=4, #command, 1 do
			if val == "" then val = command[i]
			else val = val.." "..command[i]
			end
		end
		compiler.set(command[2], command[3], val)
  
  elseif command[1] == "else" then return 0
  
	elseif command[1] == nil then return 0

	elseif command[1]:sub(1,1) == "_" then
		return 0

	else --If the command isn't recognised
		return compiler.error("'"..command[1].. "' is not recognized")
	end
	return 0
end

function compiler.readf(file) --Execute files
	--Transform file into table
	compiler.inFile = true
	local data = {}
	for line in file:lines() do
		table.insert(data, line)
	end
	--Process each string
	for x, y in pairs(data) do
		compiler.proccess(y)
	end
end

return compiler
