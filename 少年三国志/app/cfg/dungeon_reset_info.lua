

---@classdef record_dungeon_reset_info
local record_dungeon_reset_info = {}
  
record_dungeon_reset_info.id = 0 --id  
record_dungeon_reset_info.num = 0 --重置次数  
record_dungeon_reset_info.cost = 0 --花费金币


dungeon_reset_info = {
   _data = {
    [1] = {1,1,20,},
    [2] = {2,2,30,},
    [3] = {3,3,50,},
    [4] = {4,4,100,},
    [5] = {5,5,150,},
    [6] = {6,6,200,},
    [7] = {7,7,250,},
    [8] = {8,8,300,},
    [9] = {9,9,350,},
    [10] = {10,10,400,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_dungeon_reset_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function dungeon_reset_info.getLength()
    return #dungeon_reset_info._data
end



function dungeon_reset_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_dungeon_reset_info
function dungeon_reset_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = dungeon_reset_info._data[index]}, m)
    
end

---
--@return @class record_dungeon_reset_info
function dungeon_reset_info.get(id)
    
    return dungeon_reset_info.indexOf(__index_id[id])
        
end



function dungeon_reset_info.set(id, key, value)
    local record = dungeon_reset_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function dungeon_reset_info.get_index_data()
    return __index_id
end