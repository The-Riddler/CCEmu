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