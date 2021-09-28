

---@classdef record_holiday_time_info
local record_holiday_time_info = {}
  
record_holiday_time_info.id = 0 --id  
record_holiday_time_info.name = 0 --名字  
record_holiday_time_info.start_time = 0 --开始时间  
record_holiday_time_info.end_time = 0 --结束时间  
record_holiday_time_info.present_end = 0 --领奖结束  
record_holiday_time_info.drop_name = "" --drop_info文件名  
record_holiday_time_info.dungeon_name = "" --dungeon_info文件名  
record_holiday_time_info.comment = "" --活动描述


holiday_time_info = {
   _data = {
    [1] = {1,0,1449763200,1450022400,1450022400,"drop_info_holiday.xml","dungeon_info_holiday.lua","1",},
    }
}



local __index_id = {
    [1] = 1,

}

local __key_map = {
  id = 1,
  name = 2,
  start_time = 3,
  end_time = 4,
  present_end = 5,
  drop_name = 6,
  dungeon_name = 7,
  comment = 8,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_holiday_time_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function holiday_time_info.getLength()
    return #holiday_time_info._data
end



function holiday_time_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_holiday_time_info
function holiday_time_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = holiday_time_info._data[index]}, m)
    
end

---
--@return @class record_holiday_time_info
function holiday_time_info.get(id)
    
    return holiday_time_info.indexOf(__index_id[id])
        
end



function holiday_time_info.set(id, key, value)
    local record = holiday_time_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function holiday_time_info.get_index_data()
    return __index_id
end