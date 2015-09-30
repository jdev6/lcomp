require "os"

compiler = {inFile = false} --The compiler object

compiler.variables = {} --Variables are stored here

compiler.docs = { --Doc entries are stored here
lout = "Prints to stdout.\nUsage: 'lout <string>'",
exit = "Exits program.\nUsage: 'exit'",
sleep = "Waits until the specified time has passed. It supports floats.\nUsage: 'sleep <number>'",
comments = "Ignored by the compiler, only work at the start of a line.\nUsage: '_<comment>'",
doc = "Shows documentation of a function/statement.\nUsage: 'doc <query>'",
set = "Sets a variable.\nUsage: 'set <name> = <value>'",
lin = "Gets user input, has to be used with 'set'.\nUsage: 'set <name> = %lin'",
execute = "Executes a system command, which could be potentially dangerous, use carefully!\nUsage: 'execute <command>'",
list = function()
		for content,ln in pairs(compiler.docs) do
			print(content)
		end
	end
}

function compiler.error(msg)
	print("ERROR: "..msg)
	if compiler.inFile then os.exit() end --Exits if lc is executing a file
	return 1
end

function compiler.lout(parts)
	if parts[2] ~= nil then
		for i=2, #parts, 1 do
			io.write(parts[i].." ")
		end
		print()
	else
		return compiler.error("Expected string after expression 'lout'")
	end
end

function compiler.sleep(sec)
	--Checks if you inputed a valid number
	if tonumber(sec) == nil then return compiler.error("Incorrect usage, number expected after expression 'sleep'") end
	local ntime = os.time() + sec
	repeat until os.time() > ntime
end

function compiler.set(name, eq, value)
	if name == nil or eq == nil or value == nil then --Checks if you inputed everything correctly
		return compiler.error("Incorrect usage, name and value expected after expression 'set'")

	elseif eq ~= "=" then
		return compiler.error("Unexpected symbol '"..eq.."' near '"..name.."'")
	end

	if value == "%lin" then compiler.variables[name] = io.read() --To get user input
	else compiler.variables[name] = value
	end
end

function compiler.doc(query)
	--Checks if you entered a query
	if query == nil then return compiler.error("Incorrect usage, query expected after expresion 'doc'")
	elseif compiler.docs[query] == nil then --Checks if doc entry exists
		return compiler.error("No entry for "..query)
	end

	if type(compiler.docs[query]) ~= "string" then compiler.docs[query]() --To execute functions
	else print(compiler.docs[query]) --To print normal entries
	end

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
	command = split(string, nil) --Splits into words

	for i=1, #command, 1 do --Very important: Replaces every word starting with '$' to its variable value
		if command[i]:sub(1,1) == "$" then
			command[i] = compiler.variables[command[i]:sub(2, #command[i])]
		end
	end

	--Commands
	if command[1] == "exit" then
		os.exit()

	elseif command[1] == "lout" then
		compiler.lout(command)

	elseif command[1] == "sleep" then
		compiler.sleep(command[2])

	elseif command[1] == "doc" then
		compiler.doc(command[2])

	elseif command[1] == "execute" then
		local exe = ""
		for i=2, #command, 1 do
			if exe == "" then exe = command[i]
			else exe = exe.." "..command[i]
			end
		end
		os.execute(exe)

	elseif command[1] == "set" then
		local val = ""
		for i=4, #command, 1 do
			if val == "" then val = command[i]
			else val = val.." "..command[i]
			end
		end
		compiler.set(command[2], command[3], val)

	elseif command[1]:sub(1,1) == "_" then
		return 0

	else --If the command isn't recognised
		if command[1] == nil then return 0 end
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
