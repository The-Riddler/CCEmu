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