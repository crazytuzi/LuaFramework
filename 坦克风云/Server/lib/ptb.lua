local ptb={}
function ptb:p (lua_table, indent)
    if type(lua_table) ~= 'table' then 
        print '------------------ptb--------------------\n'
        print (lua_table) 
        print '------------------ptb--------------------\n'
        return
    end
    indent = indent or 0
        for k, v in pairs(lua_table) do
                if type(k) == "string" then
                        k = string.format("%q", k)
                end
                local szSuffix = ""
                if type(v) == "table" then
                        szSuffix = "{"
                end
                local szPrefix = string.rep("    ", indent)
                formatting = szPrefix.."["..k.."]".." = "..szSuffix
                if type(v) == "table" then
                        print(formatting)
                        ptb:p(v, indent + 1)
                        print(szPrefix.."},")
                else
                        local szValue = ""
                        if type(v) == "string" then
                                szValue = string.format("%q", v)
                        else
                                szValue = tostring(v)
                        end
                        print(formatting..szValue..",")
                end
        end
end
return ptb
