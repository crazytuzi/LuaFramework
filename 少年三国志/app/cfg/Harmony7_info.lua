

---@classdef record_Harmony7_info
local record_Harmony7_info = {}
  
record_Harmony7_info.dress_infoId = 0 --原武将ID  
record_Harmony7_info.resId = 0 --和谐武将ID


Harmony7_info = {
   _data = {
    [1] = {101,10021,},
    [2] = {102,10021,},
    [3] = {201,10021,},
    [4] = {202,10021,},
    [5] = {301,10021,},
    [6] = {302,10021,},
    [7] = {401,10021,},
    [8] = {402,10021,},
    [9] = {501,10021,},
    [10] = {502,10021,},
    }
}



local __index_dress_infoId = {
    [101] = 1,
    [102] = 2,
    [201] = 3,
    [202] = 4,
    [301] = 5,
    [302] = 6,
    [401] = 7,
    [402] = 8,
    [501] = 9,
    [502] = 10,

}

local __key_map = {
  dress_infoId = 1,
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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_Harmony7_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function Harmony7_info.getLength()
    return #Harmony7_info._data
end



function Harmony7_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_Harmony7_info
function Harmony7_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = Harmony7_info._data[index]}, m)
    
end

---
--@return @class record_Harmony7_info
function Harmony7_info.get(dress_infoId)
    
    return Harmony7_info.indexOf(__index_dress_infoId[dress_infoId])
        
end



function Harmony7_info.set(dress_infoId, key, value)
    local record = Harmony7_info.get(dress_infoId)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function Harmony7_info.get_index_data()
    return __index_dress_infoId
end