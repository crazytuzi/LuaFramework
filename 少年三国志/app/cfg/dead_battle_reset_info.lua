

---@classdef record_dead_battle_reset_info
local record_dead_battle_reset_info = {}
  
record_dead_battle_reset_info.id = 0 --编号  
record_dead_battle_reset_info.num = 0 --重置次数  
record_dead_battle_reset_info.cost = 0 --花费金币


dead_battle_reset_info = {
   _data = {
    [1] = {1,1,0,},
    [2] = {2,2,50,},
    [3] = {3,3,100,},
    [4] = {4,4,300,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_dead_battle_reset_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function dead_battle_reset_info.getLength()
    return #dead_battle_reset_info._data
end



function dead_battle_reset_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_dead_battle_reset_info
function dead_battle_reset_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = dead_battle_reset_info._data[index]}, m)
    
end

---
--@return @class record_dead_battle_reset_info
function dead_battle_reset_info.get(id)
    
    return dead_battle_reset_info.indexOf(__index_id[id])
        
end



function dead_battle_reset_info.set(id, key, value)
    local record = dead_battle_reset_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function dead_battle_reset_info.get_index_data()
    return __index_id
end