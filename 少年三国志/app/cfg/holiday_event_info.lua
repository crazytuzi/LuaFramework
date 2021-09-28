

---@classdef record_holiday_event_info
local record_holiday_event_info = {}
  
record_holiday_event_info.id = 0 --货物id  
record_holiday_event_info.level = 0 --兑换等级  
record_holiday_event_info.type = 0 --货物类型  
record_holiday_event_info.value = 0 --货物类型值  
record_holiday_event_info.size = 0 --货物数量  
record_holiday_event_info.num = 0 --单日限购次数  
record_holiday_event_info.cost_item = 0 --兑换物类型值  
record_holiday_event_info.cost_num = 0 --兑换消耗


holiday_event_info = {
   _data = {
    [1] = {1,1,1,0,5000,50,46,1,},
    [2] = {2,1,2,0,50,5,46,10,},
    [3] = {3,1,3,20,1,1,46,400,},
    [4] = {4,10,3,9,25,10,46,15,},
    [5] = {5,15,3,22,1,5,46,25,},
    [6] = {6,30,3,13,5,10,46,20,},
    [7] = {7,30,3,21,1,5,46,25,},
    [8] = {8,35,3,14,5,10,46,15,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,

}

local __key_map = {
  id = 1,
  level = 2,
  type = 3,
  value = 4,
  size = 5,
  num = 6,
  cost_item = 7,
  cost_num = 8,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_holiday_event_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function holiday_event_info.getLength()
    return #holiday_event_info._data
end



function holiday_event_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_holiday_event_info
function holiday_event_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = holiday_event_info._data[index]}, m)
    
end

---
--@return @class record_holiday_event_info
function holiday_event_info.get(id)
    
    return holiday_event_info.indexOf(__index_id[id])
        
end



function holiday_event_info.set(id, key, value)
    local record = holiday_event_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function holiday_event_info.get_index_data()
    return __index_id
end