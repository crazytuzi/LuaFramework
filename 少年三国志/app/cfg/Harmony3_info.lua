

---@classdef record_Harmony3_info
local record_Harmony3_info = {}
  
record_Harmony3_info.fragmentId = 0 --原武将碎片ID  
record_Harmony3_info.resId = 0 --和谐武将碎片ID


Harmony3_info = {
   _data = {
    [1] = {10018,11045,},
    [2] = {10104,12039,},
    [3] = {10037,12022,},
    [4] = {10038,14044,},
    [5] = {10043,14028,},
    [6] = {10109,12039,},
    [7] = {10110,14028,},
    [8] = {10058,12039,},
    [9] = {10059,11042,},
    [10] = {10060,11045,},
    [11] = {10061,12039,},
    [12] = {10070,14028,},
    [13] = {10073,11045,},
    [14] = {10074,12039,},
    }
}



local __index_fragmentId = {
    [10018] = 1,
    [10037] = 3,
    [10038] = 4,
    [10043] = 5,
    [10058] = 8,
    [10059] = 9,
    [10060] = 10,
    [10061] = 11,
    [10070] = 12,
    [10073] = 13,
    [10074] = 14,
    [10104] = 2,
    [10109] = 6,
    [10110] = 7,

}

local __key_map = {
  fragmentId = 1,
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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_Harmony3_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function Harmony3_info.getLength()
    return #Harmony3_info._data
end



function Harmony3_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_Harmony3_info
function Harmony3_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = Harmony3_info._data[index]}, m)
    
end

---
--@return @class record_Harmony3_info
function Harmony3_info.get(fragmentId)
    
    return Harmony3_info.indexOf(__index_fragmentId[fragmentId])
        
end



function Harmony3_info.set(fragmentId, key, value)
    local record = Harmony3_info.get(fragmentId)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function Harmony3_info.get_index_data()
    return __index_fragmentId
end