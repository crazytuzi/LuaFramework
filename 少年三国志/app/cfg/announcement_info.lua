

---@classdef record_announcement_info
local record_announcement_info = {}
  
record_announcement_info.id = 0 --id  
record_announcement_info.type = 0 --公告类型  
record_announcement_info.value = "" --公告内容


announcement_info = {
   _data = {
    [1] = {1,1,"#name#牛逼了，闯过了#关卡名#，主线副本测试",},
    [2] = {2,2,"#name#牛逼了，闯过了#关卡名#，三国无双测试",},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,

}

local __key_map = {
  id = 1,
  type = 2,
  value = 3,

}



local m = { 
    __index = function(t, k) 
        if k == "toObject" then
            return function()  
                local o = {}
                for key, v in pairs (__key_map) do 
                    o[key] = t._raw[v]
                end
                return o
            end 
        end
        
        assert(__key_map[k], "cannot find " .. k .. " in record_announcement_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function announcement_info.getLength()
    return #announcement_info._data
end



function announcement_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_announcement_info
function announcement_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = announcement_info._data[index]}, m)
    
end

---
--@return @class record_announcement_info
function announcement_info.get(id)
    
    return announcement_info.indexOf(__index_id[id])
        
end



function announcement_info.set(id, key, value)
    local record = announcement_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function announcement_info.get_index_data()
    return __index_id
end