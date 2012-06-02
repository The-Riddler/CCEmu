return function(osname, autoclose, file, ...)
    local targs = {...}
    
    local execstring = "lua5.1.exe "..file
    if #targs then
        execstring = execstring.." "..table.concat(targs, " ")
    end

    if osname == "windows" then
        if autoclose == true then
            execstring = "start cmd /c "..execstring
        else
            execstring = "start cmd /k "..execstring
        end
    else
        execstring = execstring.."&"
    end
    
    --execute it
    return os.execute(execstring) == 0
end