

---@classdef record_wheel_info
local record_wheel_info = {}
  
record_wheel_info.id = 0 --轮盘id  
record_wheel_info.cost_type = 0 --消耗价格类型  
record_wheel_info.cost = 0 --消耗数量  
record_wheel_info.score = 0 --获得积分  
record_wheel_info.type_1 = 0 --奖励类型1  
record_wheel_info.value_1 = 0 --奖励值1  
record_wheel_info.if_effect_1 = 0 --奖励特效1  
record_wheel_info.size_1 = 0 --奖励数量1  
record_wheel_info.probability_1 = 0 --奖励概率1  
record_wheel_info.position_1 = 0 --奖励位置1  
record_wheel_info.type_2 = 0 --奖励类型2  
record_wheel_info.value_2 = 0 --奖励值2  
record_wheel_info.if_effect_2 = 0 --奖励特效2  
record_wheel_info.size_2 = 0 --奖励数量2  
record_wheel_info.probability_2 = 0 --奖励概率2  
record_wheel_info.position_2 = 0 --奖励位置2  
record_wheel_info.type_3 = 0 --奖励类型3  
record_wheel_info.value_3 = 0 --奖励值3  
record_wheel_info.if_effect_3 = 0 --奖励特效3  
record_wheel_info.size_3 = 0 --奖励数量3  
record_wheel_info.probability_3 = 0 --奖励概率3  
record_wheel_info.position_3 = 0 --奖励位置3  
record_wheel_info.type_4 = 0 --奖励类型4  
record_wheel_info.value_4 = 0 --奖励值4  
record_wheel_info.if_effect_4 = 0 --奖励特效4  
record_wheel_info.size_4 = 0 --奖励数量4  
record_wheel_info.probability_4 = 0 --奖励概率4  
record_wheel_info.position_4 = 0 --奖励位置4  
record_wheel_info.type_5 = 0 --奖励类型5  
record_wheel_info.value_5 = 0 --奖励值5  
record_wheel_info.if_effect_5 = 0 --奖励特效5  
record_wheel_info.size_5 = 0 --奖励数量5  
record_wheel_info.probability_5 = 0 --奖励概率5  
record_wheel_info.position_5 = 0 --奖励位置5  
record_wheel_info.type_6 = 0 --奖励类型6  
record_wheel_info.value_6 = 0 --奖励值6  
record_wheel_info.if_effect_6 = 0 --奖励特效6  
record_wheel_info.size_6 = 0 --奖励数量6  
record_wheel_info.probability_6 = 0 --奖励概率6  
record_wheel_info.position_6 = 0 --奖励位置6  
record_wheel_info.type_7 = 0 --奖励类型7  
record_wheel_info.value_7 = 0 --奖励值7  
record_wheel_info.if_effect_7 = 0 --奖励特效7  
record_wheel_info.size_7 = 0 --奖励数量7  
record_wheel_info.probability_7 = 0 --奖励概率7  
record_wheel_info.position_7 = 0 --奖励位置7  
record_wheel_info.money_size = 0 --投放额度


wheel_info = {
   _data = {
    [1] = {1,20,1,10,3,45,0,1,193,2,1,0,0,15000,200,3,3,45,0,2,200,4,1,0,0,20000,200,6,1,0,0,25000,200,7,1,0,1,1000000,1,8,3,67,1,1,1,1,1,},
    [2] = {2,22,1,100,3,45,0,10,193,2,1,0,0,150000,200,3,3,45,0,20,200,4,1,0,0,200000,200,6,1,0,0,250000,200,7,1,0,1,10000000,2,8,3,86,1,1,1,1,10,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,

}

local __key_map = {
  id = 1,
  cost_type = 2,
  cost = 3,
  score = 4,
  type_1 = 5,
  value_1 = 6,
  if_effect_1 = 7,
  size_1 = 8,
  probability_1 = 9,
  position_1 = 10,
  type_2 = 11,
  value_2 = 12,
  if_effect_2 = 13,
  size_2 = 14,
  probability_2 = 15,
  position_2 = 16,
  type_3 = 17,
  value_3 = 18,
  if_effect_3 = 19,
  size_3 = 20,
  probability_3 = 21,
  position_3 = 22,
  type_4 = 23,
  value_4 = 24,
  if_effect_4 = 25,
  size_4 = 26,
  probability_4 = 27,
  position_4 = 28,
  type_5 = 29,
  value_5 = 30,
  if_effect_5 = 31,
  size_5 = 32,
  probability_5 = 33,
  position_5 = 34,
  type_6 = 35,
  value_6 = 36,
  if_effect_6 = 37,
  size_6 = 38,
  probability_6 = 39,
  position_6 = 40,
  type_7 = 41,
  value_7 = 42,
  if_effect_7 = 43,
  size_7 = 44,
  probability_7 = 45,
  position_7 = 46,
  money_size = 47,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_wheel_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function wheel_info.getLength()
    return #wheel_info._data
end



function wheel_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_wheel_info
function wheel_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = wheel_info._data[index]}, m)
    
end

---
--@return @class record_wheel_info
function wheel_info.get(id)
    
    return wheel_info.indexOf(__index_id[id])
        
end



function wheel_info.set(id, key, value)
    local record = wheel_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function wheel_info.get_index_data()
    return __index_id
end