

---@classdef record_shop_time_reward_info
local record_shop_time_reward_info = {}
  
record_shop_time_reward_info.id = 0 --id  
record_shop_time_reward_info.num = 0 --购买道具人次  
record_shop_time_reward_info.type = 0 --奖励类型  
record_shop_time_reward_info.value = 0 --奖励类型值  
record_shop_time_reward_info.size = 0 --奖励数量


shop_time_reward_info = {
   _data = {
    [1] = {1,800,1,0,250000,},
    [2] = {2,1800,3,14,100,},
    [3] = {3,3000,3,18,200,},
    [4] = {4,4200,3,13,50,},
    [5] = {5,5600,3,60,500,},
    [6] = {6,7000,3,3,20,},
    [7] = {7,8500,3,45,300,},
    [8] = {8,10000,3,81,20,},
    [9] = {9,14000,1,0,1000000,},
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
    [9] = 9,

}

local __key_map = {
  id = 1,
  num = 2,
  type = 3,
  value = 4,
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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_shop_time_reward_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function shop_time_reward_info.getLength()
    return #shop_time_reward_info._data
end



function shop_time_reward_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_shop_time_reward_info
function shop_time_reward_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = shop_time_reward_info._data[index]}, m)
    
end

---
--@return @class record_shop_time_reward_info
function shop_time_reward_info.get(id)
    
    return shop_time_reward_info.indexOf(__index_id[id])
        
end



function shop_time_reward_info.set(id, key, value)
    local record = shop_time_reward_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function shop_time_reward_info.get_index_data()
    return __index_id
end