

---@classdef record_rebel_rank_reward_info
local record_rebel_rank_reward_info = {}
  
record_rebel_rank_reward_info.id = 0 --ID  
record_rebel_rank_reward_info.rank_type = 0 --排行类型  
record_rebel_rank_reward_info.min_rank = 0 --排行最小值  
record_rebel_rank_reward_info.max_rank = 0 --排行最大值  
record_rebel_rank_reward_info.reward_type = 0 --奖励类型  
record_rebel_rank_reward_info.reward_value = 0 --奖励类型值  
record_rebel_rank_reward_info.reward_size = 0 --奖励数量


rebel_rank_reward_info = {
   _data = {
    [1] = {1,1,1,1,15,0,6000,},
    [2] = {2,1,2,2,15,0,5500,},
    [3] = {3,1,3,3,15,0,5000,},
    [4] = {4,1,4,5,15,0,4000,},
    [5] = {5,1,6,10,15,0,3000,},
    [6] = {6,1,11,30,15,0,2500,},
    [7] = {7,1,31,50,15,0,2000,},
    [8] = {8,1,51,100,15,0,1500,},
    [9] = {9,1,101,200,15,0,1000,},
    [10] = {10,2,1,1,15,0,4000,},
    [11] = {11,2,2,2,15,0,3700,},
    [12] = {12,2,3,3,15,0,3200,},
    [13] = {13,2,4,5,15,0,2700,},
    [14] = {14,2,6,10,15,0,2000,},
    [15] = {15,2,11,30,15,0,1700,},
    [16] = {16,2,31,50,15,0,1400,},
    [17] = {17,2,51,100,15,0,1000,},
    [18] = {18,2,101,200,15,0,700,},
    [19] = {100,3,0,0,15,0,50,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [100] = 19,
    [11] = 11,
    [12] = 12,
    [13] = 13,
    [14] = 14,
    [15] = 15,
    [16] = 16,
    [17] = 17,
    [18] = 18,
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
  reward_type = 5,
  reward_value = 6,
  reward_size = 7,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_rebel_rank_reward_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function rebel_rank_reward_info.getLength()
    return #rebel_rank_reward_info._data
end



function rebel_rank_reward_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_rebel_rank_reward_info
function rebel_rank_reward_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = rebel_rank_reward_info._data[index]}, m)
    
end

---
--@return @class record_rebel_rank_reward_info
function rebel_rank_reward_info.get(id)
    
    return rebel_rank_reward_info.indexOf(__index_id[id])
        
end



function rebel_rank_reward_info.set(id, key, value)
    local record = rebel_rank_reward_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function rebel_rank_reward_info.get_index_data()
    return __index_id
end