

---@classdef record_rookie_buff_info
local record_rookie_buff_info = {}
  
record_rookie_buff_info.id = 0 --id  
record_rookie_buff_info.day = 0 --注册天数  
record_rookie_buff_info.open_level = 0 --开启等级  
record_rookie_buff_info.close_level = 0 --截止等级  
record_rookie_buff_info.buff = 0 --增加buff


rookie_buff_info = {
   _data = {
    [1] = {1,2,5,35,20,},
    [2] = {2,3,5,40,30,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,

}

local __key_map = {
  id = 1,
  day = 2,
  open_level = 3,
  close_level = 4,
  buff = 5,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_rookie_buff_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function rookie_buff_info.getLength()
    return #rookie_buff_info._data
end



function rookie_buff_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_rookie_buff_info
function rookie_buff_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = rookie_buff_info._data[index]}, m)
    
end

---
--@return @class record_rookie_buff_info
function rookie_buff_info.get(id)
    
    return rookie_buff_info.indexOf(__index_id[id])
        
end



function rookie_buff_info.set(id, key, value)
    local record = rookie_buff_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function rookie_buff_info.get_index_data()
    return __index_id
end