

---@classdef record_tower_reset_info
local record_tower_reset_info = {}
  
record_tower_reset_info.id = 0 --编号  
record_tower_reset_info.num = 0 --重置次数  
record_tower_reset_info.cost = 0 --花费金币


tower_reset_info = {
   _data = {
    [1] = {1,1,0,},
    [2] = {2,2,20,},
    [3] = {3,3,40,},
    [4] = {4,4,60,},
    [5] = {5,5,80,},
    [6] = {6,6,100,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,

}

local __key_map = {
  id = 1,
  num = 2,
  cost = 3,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_tower_reset_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function tower_reset_info.getLength()
    return #tower_reset_info._data
end



function tower_reset_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_tower_reset_info
function tower_reset_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = tower_reset_info._data[index]}, m)
    
end

---
--@return @class record_tower_reset_info
function tower_reset_info.get(id)
    
    return tower_reset_info.indexOf(__index_id[id])
        
end



function tower_reset_info.set(id, key, value)
    local record = tower_reset_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function tower_reset_info.get_index_data()
    return __index_id
end