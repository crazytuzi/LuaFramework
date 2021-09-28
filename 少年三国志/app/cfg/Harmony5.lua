

---@classdef record_Harmony5
local record_Harmony5 = {}
  
record_Harmony5.story_dungeonId = 0 --原武将ID  
record_Harmony5.resId = 0 --和谐武将ID


Harmony5 = {
   _data = {
    [1] = {1,11045,},
    [2] = {33,11045,},
    }
}



local __index_story_dungeonId = {
    [1] = 1,
    [33] = 2,

}

local __key_map = {
  story_dungeonId = 1,
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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_Harmony5")
        
        
        return t._raw[__key_map[k]]
    end
}


function Harmony5.getLength()
    return #Harmony5._data
end



function Harmony5.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_Harmony5
function Harmony5.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = Harmony5._data[index]}, m)
    
end

---
--@return @class record_Harmony5
function Harmony5.get(story_dungeonId)
    
    return Harmony5.indexOf(__index_story_dungeonId[story_dungeonId])
        
end



function Harmony5.set(story_dungeonId, key, value)
    local record = Harmony5.get(story_dungeonId)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function Harmony5.get_index_data()
    return __index_story_dungeonId
end