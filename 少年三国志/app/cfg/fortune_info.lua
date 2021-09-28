

---@classdef record_fortune_info
local record_fortune_info = {}
  
record_fortune_info.id = 0 --ID  
record_fortune_info.strike_value_1 = 0 --暴击倍数1  
record_fortune_info.strike_1 = 0 --概率1  
record_fortune_info.description_1 = "" --描述1  
record_fortune_info.strike_value_2 = 0 --暴击倍数2  
record_fortune_info.strike_2 = 0 --概率2  
record_fortune_info.description_2 = "" --描述2  
record_fortune_info.strike_value_3 = 0 --暴击倍数3  
record_fortune_info.strike_3 = 0 --概率3  
record_fortune_info.description_3 = "" --描述3


fortune_info = {
   _data = {
    [1] = {1,10,80,"【招财进宝】",20,15,"【财运亨通，银两翻2倍！】",30,5,"【人品爆发，银两翻3倍！】",},
    }
}



local __index_id = {
    [1] = 1,

}

local __key_map = {
  id = 1,
  strike_value_1 = 2,
  strike_1 = 3,
  description_1 = 4,
  strike_value_2 = 5,
  strike_2 = 6,
  description_2 = 7,
  strike_value_3 = 8,
  strike_3 = 9,
  description_3 = 10,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_fortune_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function fortune_info.getLength()
    return #fortune_info._data
end



function fortune_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_fortune_info
function fortune_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = fortune_info._data[index]}, m)
    
end

---
--@return @class record_fortune_info
function fortune_info.get(id)
    
    return fortune_info.indexOf(__index_id[id])
        
end



function fortune_info.set(id, key, value)
    local record = fortune_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function fortune_info.get_index_data()
    return __index_id
end