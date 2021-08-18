--[[
generateIDs.lua

Lua script to convert Arma 3 launcher presets into lists of Workshop mod IDs and folder names. 

Arguments:-
	1 - input file, a path to a preset file exported from the Arma 3 Official Launcher
	2 - output file, a path to a file, to which the output will be appended

Both arguments are optional; they will default to "input.html" and "output.txt". 

BE AWARE: There's no input validation; if you give it bad arguments, it will fuck up and it'll be all your fault. 
Also note that some manual verification may be required, as the folder names taken from the preset file are not guaranteed to match those that are actually created for the mods. They also may have esoteric HTML escapes that are not caught by the script. 
Also also: local mods that use the bar (|) may break the name detection.

by Professor Cupcake
]]

local input, output = ...

input = input or "input.html"
output = output or "output.txt"

local f = assert(io.open(input, 'r'))

-- skip header etc. to actual mod list
local l = f:read("*line")
while not string.find(l, [[<div class="mod%-list">]]) do
	l = f:read("*line")
end

l = f:read("*line")

local idList = {}
local nameList = {}

while l do
	if string.find(l, [[<tr data%-type="ModContainer"]]) then
		repeat
			l = f:read("*line")
		until string.find(l, [[<td data%-type="DisplayName]])
		local modName = string.match(l, [[<td data%-type="DisplayName">(.+)</td>]])
		repeat
			l = f:read("*line")
		until string.find(l, [[<span class="from]])
		local from = string.match(l, [[<span class="from%-(%a+)">]])
		if from == "local" then
			repeat
				l = f:read("*line")
			until string.find(l, [[<span class="whups" data%-type="Link"]])
			modName = string.match(l, [[<span class="whups" data%-type="Link" data%-meta="local:.-|(.-)|]])
			table.insert(nameList, modName)
		elseif from == "steam" then
			table.insert(nameList, "@"..modName)
			repeat
				l = f:read("*line")
			until string.find(l, [[<a href="http://steamcommunity%.com]])
			local modId = string.match(l, [[<a href="http://steamcommunity%.com/sharedfiles/filedetails/%?id=(%d+)"]])
			table.insert(idList, modId)
		end
	end
	l = f:read("*line")
end

f:close()

-- HTML/XML unescape function taken from https://stackoverflow.com/a/14899740
function unescape(str)
	local map = {["lt"]="<", ["gt"]=">", ["amp"]="&", ["quot"]='"', ["apos"]="'"}
	str = string.gsub(str, '(&(#?x?)([%d%a]+);)', function(orig,n,s)
		return (n=="" and map[s])
			or (n=="#x" and tonumber(s,16)) and string.char(tonumber(s,16))
			or (n=="#" and tonumber(s)) and string.char(s)
			or orig
		end
	)
	return str
end

nameString = table.concat(nameList, ";")
nameString = unescape(nameString);
nameString = string.gsub(nameString, ":","-") -- Arma's Workshop folder names replace colons with hyphens

idString = table.concat(idList, ",")

f = assert(io.open(output, 'a+'))
f:write("IDs from \"",input,"\"\n",idString,"\n\n",nameString,"\n\n")