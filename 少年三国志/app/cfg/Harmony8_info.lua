

---@classdef record_Harmony8_info
local record_Harmony8_info = {}
  
record_Harmony8_info.hard_dungeon_stageId = 0 --原武将ID  
record_Harmony8_info.resId = 0 --和谐武将ID


Harmony8_info = {
   _data = {
    [1] = {39,11045,},
    [2] = {93,11045,},
    }
}



local __index_hard_dungeon_stageId = {
    [39] = 1,
    [93] = 2,

}

local __key_map = {
  hard_dungeon_stageId = 1,
  resId = 2,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_Harmony8_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function Harmony8_info.getLength()
    return #Harmony8_info._data
end



function Harmony8_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_Harmony8_info
function Harmony8_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = Harmony8_info._data[index]}, m)
    
end

---
--@return @class record_Harmony8_info
function Harmony8_info.get(hard_dungeon_stageId)
    
    return Harmony8_info.indexOf(__index_hard_dungeon_stageId[hard_dungeon_stageId])
        
end



function Harmony8_info.set(hard_dungeon_stageId, key, value)
    local record = Harmony8_info.get(hard_dungeon_stageId)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function Harmony8_info.get_index_data()
    return __index_hard_dungeon_stageId
end