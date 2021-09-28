

---@classdef record_richman_event_info
local record_richman_event_info = {}
  
record_richman_event_info.id = 0 --事件编号  
record_richman_event_info.prob = 0 --事件概率  
record_richman_event_info.type = 0 --事件奖励类型  
record_richman_event_info.value = 0 --事件奖励类型值  
record_richman_event_info.size = 0 --事件奖励数量  
record_richman_event_info.dialogue = 0 --对话id


richman_event_info = {
   _data = {
    [1] = {1,10,3,14,50,9000,},
    [2] = {2,10,3,18,100,9001,},
    [3] = {3,10,3,60,200,9002,},
    [4] = {4,10,23,0,500,9003,},
    [5] = {5,10,3,13,20,9004,},
    [6] = {6,10,3,81,10,9005,},
    [7] = {7,5,3,157,1,9006,},
    [8] = {8,1,3,186,1,9007,},
    [9] = {9,1000,3,18,2,9008,},
    [10] = {10,1333,3,60,2,9009,},
    [11] = {11,978,23,0,10,9010,},
    [12] = {12,1000,3,18,2,9011,},
    [13] = {13,1000,3,18,2,9014,},
    [14] = {14,1333,3,60,2,9012,},
    [15] = {15,1334,3,60,2,9015,},
    [16] = {16,978,23,0,10,9013,},
    [17] = {17,978,23,0,10,9016,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [12] = 12,
    [13] = 13,
    [14] = 14,
    [15] = 15,
    [16] = 16,
    [17] = 17,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  prob = 2,
  type = 3,
  value = 4,
  size = 5,
  dialogue = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_richman_event_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function richman_event_info.getLength()
    return #richman_event_info._data
end



function richman_event_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_richman_event_info
function richman_event_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = richman_event_info._data[index]}, m)
    
end

---
--@return @class record_richman_event_info
function richman_event_info.get(id)
    
    return richman_event_info.indexOf(__index_id[id])
        
end



function richman_event_info.set(id, key, value)
    local record = richman_event_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function richman_event_info.get_index_data()
    return __index_id
end