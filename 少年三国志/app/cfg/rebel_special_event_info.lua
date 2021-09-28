

---@classdef record_rebel_special_event_info
local record_rebel_special_event_info = {}
  
record_rebel_special_event_info.id = 0 --ID  
record_rebel_special_event_info.type = 0 --事件类型  
record_rebel_special_event_info.value = 0 --事件类型值  
record_rebel_special_event_info.open = 0 --每日开始时间  
record_rebel_special_event_info.end_time = 0 --每日结束时间  
record_rebel_special_event_info.directions = "" --事件描述


rebel_special_event_info = {
   _data = {
    [1] = {1,1,1,43200,50400,"每日12:00-14:00 全力一击消耗征讨令减半",},
    [2] = {2,2,0,0,0,"0",},
    [3] = {3,3,200,64800,72000,"每日18:00-20:00 攻打叛军获得功勋翻倍",},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,

}

local __key_map = {
  id = 1,
  type = 2,
  value = 3,
  open = 4,
  end_time = 5,
  directions = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_rebel_special_event_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function rebel_special_event_info.getLength()
    return #rebel_special_event_info._data
end



function rebel_special_event_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_rebel_special_event_info
function rebel_special_event_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = rebel_special_event_info._data[index]}, m)
    
end

---
--@return @class record_rebel_special_event_info
function rebel_special_event_info.get(id)
    
    return rebel_special_event_info.indexOf(__index_id[id])
        
end



function rebel_special_event_info.set(id, key, value)
    local record = rebel_special_event_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function rebel_special_event_info.get_index_data()
    return __index_id
end