

---@classdef record_rice_time_info
local record_rice_time_info = {}
  
record_rice_time_info.day = 0 --开放日  
record_rice_time_info.start_time = 0 --开始时间  
record_rice_time_info.end_time = 0 --结束时间  
record_rice_time_info.prize_end = 0 --领奖结束


rice_time_info = {
   _data = {
    [1] = {2,43200,72000,86399,},
    [2] = {4,43200,72000,86399,},
    }
}



local __index_day = {
    [2] = 1,
    [4] = 2,

}

local __key_map = {
  day = 1,
  start_time = 2,
  end_time = 3,
  prize_end = 4,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_rice_time_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function rice_time_info.getLength()
    return #rice_time_info._data
end



function rice_time_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_rice_time_info
function rice_time_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = rice_time_info._data[index]}, m)
    
end

---
--@return @class record_rice_time_info
function rice_time_info.get(day)
    
    return rice_time_info.indexOf(__index_day[day])
        
end



function rice_time_info.set(day, key, value)
    local record = rice_time_info.get(day)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function rice_time_info.get_index_data()
    return __index_day
end