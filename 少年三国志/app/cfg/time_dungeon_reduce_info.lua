

---@classdef record_time_dungeon_reduce_info
local record_time_dungeon_reduce_info = {}
  
record_time_dungeon_reduce_info.id = 0 --id  
record_time_dungeon_reduce_info.gold = 0 --消耗元宝  
record_time_dungeon_reduce_info.buff1 = 0 --鼓舞buff1  
record_time_dungeon_reduce_info.buff2 = 0 --鼓舞buff2


time_dungeon_reduce_info = {
   _data = {
    [1] = {1,100,4201,4202,},
    [2] = {2,200,4203,4204,},
    [3] = {3,500,4205,4206,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,

}

local __key_map = {
  id = 1,
  gold = 2,
  buff1 = 3,
  buff2 = 4,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_time_dungeon_reduce_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function time_dungeon_reduce_info.getLength()
    return #time_dungeon_reduce_info._data
end



function time_dungeon_reduce_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_time_dungeon_reduce_info
function time_dungeon_reduce_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = time_dungeon_reduce_info._data[index]}, m)
    
end

---
--@return @class record_time_dungeon_reduce_info
function time_dungeon_reduce_info.get(id)
    
    return time_dungeon_reduce_info.indexOf(__index_id[id])
        
end



function time_dungeon_reduce_info.set(id, key, value)
    local record = time_dungeon_reduce_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function time_dungeon_reduce_info.get_index_data()
    return __index_id
end