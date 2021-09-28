

---@classdef record_Harmony4
local record_Harmony4 = {}
  
record_Harmony4.story_barrierId = 0 --原武将ID  
record_Harmony4.resId = 0 --和谐武将ID


Harmony4 = {
   _data = {
    [1] = {4,11045,},
    [2] = {46,11045,},
    [3] = {131,11041,},
    [4] = {132,11045,},
    }
}



local __index_story_barrierId = {
    [131] = 3,
    [132] = 4,
    [4] = 1,
    [46] = 2,

}

local __key_map = {
  story_barrierId = 1,
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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_Harmony4")
        
        
        return t._raw[__key_map[k]]
    end
}


function Harmony4.getLength()
    return #Harmony4._data
end



function Harmony4.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_Harmony4
function Harmony4.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = Harmony4._data[index]}, m)
    
end

---
--@return @class record_Harmony4
function Harmony4.get(story_barrierId)
    
    return Harmony4.indexOf(__index_story_barrierId[story_barrierId])
        
end



function Harmony4.set(story_barrierId, key, value)
    local record = Harmony4.get(story_barrierId)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function Harmony4.get_index_data()
    return __index_story_barrierId
end