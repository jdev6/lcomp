local compiler = require "src.compiler"
local readline = require "readline"
main = {}

function main.start(opt)
	if #opt > 0 then
		file = io.open(opt[1], "r")
		if file then compiler.readf(file)
		else compiler.error("File not found.") end
	else
		print("jdev6 2015, lcomp 1.0")
		while true do
			inp = readline.readline(compiler.prompt)
			compiler.proccess(inp)
		end
	end
end

return main
