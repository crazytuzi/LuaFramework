local patcher 

function setPatchCode(str)
    if str == nil or str == "" then
        return 
    end


    local patchFunc  = loadstring(str)
    if patchFunc ~= nil and type(patchFunc) == "function" then
        local result = patchFunc()    
        if result ~= nil and type(result) == "table" then
            patcher = result
        end
    end   

    -- local a = loadstring("local b = {} b.test = function(object) object.test1 = function() print 'hack test1' end  end  return b  ")

end


function patchMe(...)
    if  patcher == nil or patcher.patchMe == nil then
        return false
    end 
    --返回true则表示obj需要马上返回!

    return patcher.patchMe(...)
end