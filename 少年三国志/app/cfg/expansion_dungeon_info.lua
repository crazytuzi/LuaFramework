

---@classdef record_expansion_dungeon_info
local record_expansion_dungeon_info = {}
  
record_expansion_dungeon_info.id = 0 --编号


expansion_dungeon_info = {
   _data = {
    [1] = {2,},
    }
}



local __index_id = {
    [2] = 1,

}

local __key_map = {
  id = 1,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_expansion_dungeon_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function expansion_dungeon_info.getLength()
    return #expansion_dungeon_info._data
end



function expansion_dungeon_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_expansion_dungeon_info
function expansion_dungeon_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = expansion_dungeon_info._data[index]}, m)
    
end

---
--@return @class record_expansion_dungeon_info
function expansion_dungeon_info.get(id)
    
    return expansion_dungeon_info.indexOf(__index_id[id])
        
end



function expansion_dungeon_info.set(id, key, value)
    local record = expansion_dungeon_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function expansion_dungeon_info.get_index_data()
    return __index_id
end