

---@classdef record_Harmony9_info
local record_Harmony9_info = {}
  
record_Harmony9_info.dead_battle_infoId = 0 --原武将ID  
record_Harmony9_info.resId = 0 --和谐武将ID


Harmony9_info = {
   _data = {
    [1] = {8,14028,},
    [2] = {11,14028,},
    [3] = {18,12039,},
    [4] = {22,11042,},
    [5] = {25,12039,},
    [6] = {43,12039,},
    [7] = {55,11045,},
    }
}



local __index_dead_battle_infoId = {
    [11] = 2,
    [18] = 3,
    [22] = 4,
    [25] = 5,
    [43] = 6,
    [55] = 7,
    [8] = 1,

}

local __key_map = {
  dead_battle_infoId = 1,
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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_Harmony9_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function Harmony9_info.getLength()
    return #Harmony9_info._data
end



function Harmony9_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_Harmony9_info
function Harmony9_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = Harmony9_info._data[index]}, m)
    
end

---
--@return @class record_Harmony9_info
function Harmony9_info.get(dead_battle_infoId)
    
    return Harmony9_info.indexOf(__index_dead_battle_infoId[dead_battle_infoId])
        
end



function Harmony9_info.set(dead_battle_infoId, key, value)
    local record = Harmony9_info.get(dead_battle_infoId)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function Harmony9_info.get_index_data()
    return __index_dead_battle_infoId
end