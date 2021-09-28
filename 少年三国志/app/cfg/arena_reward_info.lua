

---@classdef record_arena_reward_info
local record_arena_reward_info = {}
  
record_arena_reward_info.id = 0 --id  
record_arena_reward_info.rank_type = 0 --排名类型  
record_arena_reward_info.min_rank = 0 --最小排名  
record_arena_reward_info.max_rank = 0 --最大排名  
record_arena_reward_info.day_type1 = 0 --每日奖励类型1  
record_arena_reward_info.day_value1 = 0 --每日奖励类型值1  
record_arena_reward_info.day_size1 = 0 --每日奖励数量1  
record_arena_reward_info.day_type2 = 0 --每日奖励类型2  
record_arena_reward_info.day_value2 = 0 --每日奖励类型值2  
record_arena_reward_info.day_size2 = 0 --每日奖励数量2  
record_arena_reward_info.day_type3 = 0 --每日奖励类型3  
record_arena_reward_info.day_value3 = 0 --每日奖励类型值3  
record_arena_reward_info.day_size3 = 0 --每日奖励数量3


arena_reward_info = {
   _data = {
    [1] = {1,1,1,1,9,0,30000,1,0,1000000,3,9,1,},
    [2] = {2,1,2,5,9,0,20000,1,0,500000,3,9,1,},
    [3] = {3,1,6,20,9,0,8000,1,0,300000,3,9,1,},
    [4] = {4,1,21,50,9,0,6000,1,0,200000,3,9,1,},
    [5] = {5,1,51,100,9,0,4000,1,0,100000,3,9,1,},
    [6] = {6,1,101,300,9,0,2000,1,0,50000,3,9,1,},
    [7] = {7,1,301,1000,9,0,2000,1,0,30000,3,9,1,},
    [8] = {8,2,1,100,2,0,5,0,0,0,0,0,0,},
    [9] = {9,2,101,500,2,0,3,0,0,0,0,0,0,},
    [10] = {10,2,501,1000,2,0,2,0,0,0,0,0,0,},
    [11] = {11,2,1001,4000,2,0,1,0,0,0,0,0,0,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
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
  rank_type = 2,
  min_rank = 3,
  max_rank = 4,
  day_type1 = 5,
  day_value1 = 6,
  day_size1 = 7,
  day_type2 = 8,
  day_value2 = 9,
  day_size2 = 10,
  day_type3 = 11,
  day_value3 = 12,
  day_size3 = 13,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_arena_reward_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function arena_reward_info.getLength()
    return #arena_reward_info._data
end



function arena_reward_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_arena_reward_info
function arena_reward_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = arena_reward_info._data[index]}, m)
    
end

---
--@return @class record_arena_reward_info
function arena_reward_info.get(id)
    
    return arena_reward_info.indexOf(__index_id[id])
        
end



function arena_reward_info.set(id, key, value)
    local record = arena_reward_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function arena_reward_info.get_index_data()
    return __index_id
end