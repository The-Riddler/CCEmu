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
local outputfile = ...
print("Outputfile: ", outputfile)
print("This is your output terminal, this shows what the PC sees")

--Read from file
local errorcount = 0
local lastpos = 0

while true do
    local fh = io.open(outputfile)
    if fh == nil then
        errorcount = errorcount + 1
        if errorcount >= 3 then
            error("Error opening output file")
        end
    else
        errorcount = 0
        fh:seek("set", lastpos)
        local str = fh:read("*a")
        if str ~= nil and str ~= "" then
            io.write(str)
            lastpos = lastpos+string.len(str)
        end
        fh:close()
    end
    
    local nexttime = os.time() + 1
    while os.time() < nexttime do
    end
end