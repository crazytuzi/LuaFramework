

---@classdef record_Harmony6_info
local record_Harmony6_info = {}
  
record_Harmony6_info.dungeon_stageId = 0 --原武将ID  
record_Harmony6_info.resId = 0 --和谐武将ID


Harmony6_info = {
   _data = {
    [1] = {84,11045,},
    [2] = {225,11045,},
    [3] = {500,11045,},
    }
}



local __index_dungeon_stageId = {
    [225] = 2,
    [500] = 3,
    [84] = 1,

}

local __key_map = {
  dungeon_stageId = 1,
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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_Harmony6_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function Harmony6_info.getLength()
    return #Harmony6_info._data
end



function Harmony6_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_Harmony6_info
function Harmony6_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = Harmony6_info._data[index]}, m)
    
end

---
--@return @class record_Harmony6_info
function Harmony6_info.get(dungeon_stageId)
    
    return Harmony6_info.indexOf(__index_dungeon_stageId[dungeon_stageId])
        
end



function Harmony6_info.set(dungeon_stageId, key, value)
    local record = Harmony6_info.get(dungeon_stageId)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function Harmony6_info.get_index_data()
    return __index_dungeon_stageId
end