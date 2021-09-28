

---@classdef record_rebel_boss_reward_size_info
local record_rebel_boss_reward_size_info = {}
  
record_rebel_boss_reward_size_info.id = 0 --id  
record_rebel_boss_reward_size_info.type = "" --数量类型  
record_rebel_boss_reward_size_info.level_min = "" --BOSS等级下限  
record_rebel_boss_reward_size_info.level_max = "" --BOSS等级上限  
record_rebel_boss_reward_size_info.size = "" --数量


rebel_boss_reward_size_info = {
   _data = {
    [1] = {1,1,1,20,100,},
    [2] = {2,1,21,40,150,},
    [3] = {3,1,41,60,200,},
    [4] = {4,1,61,80,300,},
    [5] = {5,1,81,999,500,},
    [6] = {6,2,1,20,20,},
    [7] = {7,2,21,40,40,},
    [8] = {8,2,41,60,80,},
    [9] = {9,2,61,80,100,},
    [10] = {10,2,81,999,180,},
    [11] = {11,3,1,20,12,},
    [12] = {12,3,21,40,24,},
    [13] = {13,3,41,60,48,},
    [14] = {14,3,61,80,60,},
    [15] = {15,3,81,999,108,},
    [16] = {16,4,1,20,6,},
    [17] = {17,4,21,40,12,},
    [18] = {18,4,41,60,24,},
    [19] = {19,4,61,80,30,},
    [20] = {20,4,81,999,54,},
    [21] = {21,5,1,20,3,},
    [22] = {22,5,21,40,6,},
    [23] = {23,5,41,60,12,},
    [24] = {24,5,61,80,15,},
    [25] = {25,5,81,999,27,},
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
    [18] = 18,
    [19] = 19,
    [2] = 2,
    [20] = 20,
    [21] = 21,
    [22] = 22,
    [23] = 23,
    [24] = 24,
    [25] = 25,
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
  type = 2,
  level_min = 3,
  level_max = 4,
  size = 5,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_rebel_boss_reward_size_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function rebel_boss_reward_size_info.getLength()
    return #rebel_boss_reward_size_info._data
end



function rebel_boss_reward_size_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_rebel_boss_reward_size_info
function rebel_boss_reward_size_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = rebel_boss_reward_size_info._data[index]}, m)
    
end

---
--@return @class record_rebel_boss_reward_size_info
function rebel_boss_reward_size_info.get(id)
    
    return rebel_boss_reward_size_info.indexOf(__index_id[id])
        
end



function rebel_boss_reward_size_info.set(id, key, value)
    local record = rebel_boss_reward_size_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function rebel_boss_reward_size_info.get_index_data()
    return __index_id
end