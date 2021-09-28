

---@classdef record_rookie_reward_info
local record_rookie_reward_info = {}
  
record_rookie_reward_info.id = 0 --id  
record_rookie_reward_info.level = 0 --等级  
record_rookie_reward_info.day = 0 --注册时间类型  
record_rookie_reward_info.type_1 = 0 --奖励类型1  
record_rookie_reward_info.value_1 = 0 --类型值1  
record_rookie_reward_info.size_1 = 0 --数量1  
record_rookie_reward_info.type_2 = 0 --奖励类型2  
record_rookie_reward_info.value_2 = 0 --类型值2  
record_rookie_reward_info.size_2 = 0 --数量2  
record_rookie_reward_info.type_3 = 0 --奖励类型3  
record_rookie_reward_info.value_3 = 0 --类型值3  
record_rookie_reward_info.size_3 = 0 --数量3


rookie_reward_info = {
   _data = {
    [1] = {1,10,1,1,0,10000,3,9,10,0,0,0,},
    [2] = {2,15,1,1,0,20000,3,22,2,0,0,0,},
    [3] = {3,22,1,1,0,30000,16,0,3000,2,0,50,},
    [4] = {4,28,1,1,0,40000,13,0,100,0,0,0,},
    [5] = {5,35,1,1,0,50000,15,0,1000,2,0,100,},
    [6] = {6,5,1,1,0,10000,3,6,50,0,0,0,},
    [7] = {10,5,2,1,0,10000,3,6,75,0,0,0,},
    [8] = {11,10,2,1,0,10000,3,9,15,0,0,0,},
    [9] = {12,15,2,1,0,20000,3,22,3,2,0,50,},
    [10] = {13,22,2,1,0,30000,16,0,5000,0,0,0,},
    [11] = {14,28,2,1,0,40000,13,0,150,2,0,100,},
    [12] = {15,35,2,1,0,50000,15,0,2000,0,0,0,},
    [13] = {16,40,2,1,0,80000,3,20,1,2,0,200,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 7,
    [11] = 8,
    [12] = 9,
    [13] = 10,
    [14] = 11,
    [15] = 12,
    [16] = 13,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,

}

local __key_map = {
  id = 1,
  level = 2,
  day = 3,
  type_1 = 4,
  value_1 = 5,
  size_1 = 6,
  type_2 = 7,
  value_2 = 8,
  size_2 = 9,
  type_3 = 10,
  value_3 = 11,
  size_3 = 12,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_rookie_reward_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function rookie_reward_info.getLength()
    return #rookie_reward_info._data
end



function rookie_reward_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_rookie_reward_info
function rookie_reward_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = rookie_reward_info._data[index]}, m)
    
end

---
--@return @class record_rookie_reward_info
function rookie_reward_info.get(id)
    
    return rookie_reward_info.indexOf(__index_id[id])
        
end



function rookie_reward_info.set(id, key, value)
    local record = rookie_reward_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function rookie_reward_info.get_index_data()
    return __index_id
end