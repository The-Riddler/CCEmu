local osname = ...
return function()
    local tmpfname = os.tmpname()
    if osname == "windows" then
        tmpfname = os.getenv("TMP")..tmpfname
    end
    local fh = io.open(tmpfname, "w")
    fh:write("")
    fh:close()
    return tmpfname
end