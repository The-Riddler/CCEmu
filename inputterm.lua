--[[
Copyright (C) 2012  Jordan (Riddler)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Contact: PM Riddler80 on http://www.minecraftforum.net
]]--
local inputfile = ...
print("Inputfile: ",inputfile)
print("This is your input terminal, use it to send input to the script")
print("-Pressing enter will cause the typed characters to be sent to the pc")
print("-To send a newline type '\n' and send it")

function select (n, ...)
    return arg[n]
end

local errcount = 0
while true do
    local char = io.read()
    
    local fh = nil
    local errorcount = 0
    repeat
        fh = io.open(tmpfname, "a")
        if not fh then
            errcount = errcount + 1
            if errorcount >= 3 then
                error("Error opening tempfile")
            else
                --sleep 1
            end
        end
    until fh ~= nil
    
    fh:write(select(1, string.gsub(char, "\\n", "\n")))
    fh:close()
end