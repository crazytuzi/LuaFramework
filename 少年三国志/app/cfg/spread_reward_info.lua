

---@classdef record_spread_reward_info
local record_spread_reward_info = {}
  
record_spread_reward_info.id = 0 --id  
record_spread_reward_info.type = "" --从属对象  
record_spread_reward_info.level = 0 --等级限制  
record_spread_reward_info.power = 0 --战力限制  
record_spread_reward_info.time = 0 --领取次数  
record_spread_reward_info.item_type1 = 0 --奖励类型1  
record_spread_reward_info.item_value1 = 0 --奖励类型值1  
record_spread_reward_info.item_size1 = 0 --奖励数量1  
record_spread_reward_info.item_type2 = 0 --奖励类型2  
record_spread_reward_info.item_value2 = 0 --奖励类型值2  
record_spread_reward_info.item_size2 = 0 --奖励数量2  
record_spread_reward_info.item_type3 = 0 --奖励类型3  
record_spread_reward_info.item_value3 = 0 --奖励类型值3  
record_spread_reward_info.item_size3 = 0 --奖励数量3  
record_spread_reward_info.item_type4 = 0 --奖励类型4  
record_spread_reward_info.item_value4 = 0 --奖励类型值4  
record_spread_reward_info.item_size4 = 0 --奖励数量4


spread_reward_info = {
   _data = {
    [1] = {101,"1",0,500000,50,1,0,100000,3,14,20,26,0,1000,0,0,0,},
    [2] = {102,"1",0,1000000,35,3,12,25,3,60,60,26,0,1500,0,0,0,},
    [3] = {103,"1",0,2000000,20,3,18,70,3,60,120,26,0,2500,0,0,0,},
    [4] = {104,"1",0,3000000,10,3,45,300,26,0,5000,0,0,0,0,0,0,},
    [5] = {105,"1",0,5000000,5,3,18,200,3,13,100,26,0,10000,0,0,0,},
    [6] = {106,"1",0,8000000,2,3,60,1888,3,45,388,26,0,25000,0,0,0,},
    [7] = {107,"1",0,10000000,1,2,0,2888,3,13,188,3,18,1688,26,0,50000,},
    [8] = {201,"2",30,0,1,1,0,888888,26,0,6666,0,0,0,0,0,0,},
    }
}



local __index_id = {
    [101] = 1,
    [102] = 2,
    [103] = 3,
    [104] = 4,
    [105] = 5,
    [106] = 6,
    [107] = 7,
    [201] = 8,

}

local __key_map = {
  id = 1,
  type = 2,
  level = 3,
  power = 4,
  time = 5,
  item_type1 = 6,
  item_value1 = 7,
  item_size1 = 8,
  item_type2 = 9,
  item_value2 = 10,
  item_size2 = 11,
  item_type3 = 12,
  item_value3 = 13,
  item_size3 = 14,
  item_type4 = 15,
  item_value4 = 16,
  item_size4 = 17,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_spread_reward_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function spread_reward_info.getLength()
    return #spread_reward_info._data
end



function spread_reward_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_spread_reward_info
function spread_reward_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = spread_reward_info._data[index]}, m)
    
end

---
--@return @class record_spread_reward_info
function spread_reward_info.get(id)
    
    return spread_reward_info.indexOf(__index_id[id])
        
end



function spread_reward_info.set(id, key, value)
    local record = spread_reward_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function spread_reward_info.get_index_data()
    return __index_id
end