

---@classdef record_recharge_card_info
local record_recharge_card_info = {}
  
record_recharge_card_info.id = 0 --牌组id  
record_recharge_card_info.cost = 0 --消耗积分数量  
record_recharge_card_info.cost_num = 0 --重置消耗元宝  
record_recharge_card_info.time = 0 --每日翻牌次数  
record_recharge_card_info.type_1 = 0 --奖励类型1  
record_recharge_card_info.value_1 = 0 --奖励值1  
record_recharge_card_info.size_1 = 0 --奖励数量1  
record_recharge_card_info.weight_1 = 0 --奖励权值1  
record_recharge_card_info.position_1 = 0 --奖励位置1  
record_recharge_card_info.if_effect_1 = 0 --奖励特效1  
record_recharge_card_info.type_2 = 0 --奖励类型2  
record_recharge_card_info.value_2 = 0 --奖励值2  
record_recharge_card_info.size_2 = 0 --奖励数量2  
record_recharge_card_info.weight_2 = 0 --奖励权值2  
record_recharge_card_info.position_2 = 0 --奖励位置2  
record_recharge_card_info.if_effect_2 = 0 --奖励特效2  
record_recharge_card_info.type_3 = 0 --奖励类型3  
record_recharge_card_info.value_3 = 0 --奖励值3  
record_recharge_card_info.size_3 = 0 --奖励数量3  
record_recharge_card_info.weight_3 = 0 --奖励权值3  
record_recharge_card_info.position_3 = 0 --奖励位置3  
record_recharge_card_info.if_effect_3 = 0 --奖励特效3  
record_recharge_card_info.type_4 = 0 --奖励类型4  
record_recharge_card_info.value_4 = 0 --奖励值4  
record_recharge_card_info.size_4 = 0 --奖励数量4  
record_recharge_card_info.weight_4 = 0 --奖励权值4  
record_recharge_card_info.position_4 = 0 --奖励位置4  
record_recharge_card_info.if_effect_4 = 0 --奖励特效4  
record_recharge_card_info.type_5 = 0 --奖励类型5  
record_recharge_card_info.value_5 = 0 --奖励值5  
record_recharge_card_info.size_5 = 0 --奖励数量5  
record_recharge_card_info.weight_5 = 0 --奖励权值5  
record_recharge_card_info.position_5 = 0 --奖励位置5  
record_recharge_card_info.if_effect_5 = 0 --奖励特效5  
record_recharge_card_info.type_6 = 0 --奖励类型6  
record_recharge_card_info.value_6 = 0 --奖励值6  
record_recharge_card_info.size_6 = 0 --奖励数量6  
record_recharge_card_info.weight_6 = 0 --奖励权值6  
record_recharge_card_info.position_6 = 0 --奖励位置6  
record_recharge_card_info.if_effect_6 = 0 --奖励特效6  
record_recharge_card_info.type_7 = 0 --奖励类型7  
record_recharge_card_info.value_7 = 0 --奖励值7  
record_recharge_card_info.size_7 = 0 --奖励数量7  
record_recharge_card_info.weight_7 = 0 --奖励权值7  
record_recharge_card_info.position_7 = 0 --奖励位置7  
record_recharge_card_info.if_effect_7 = 0 --奖励特效7  
record_recharge_card_info.type_8 = 0 --奖励类型8  
record_recharge_card_info.value_8 = 0 --奖励值8  
record_recharge_card_info.size_8 = 0 --奖励数量8  
record_recharge_card_info.weight_8 = 0 --奖励权值8  
record_recharge_card_info.position_8 = 0 --奖励位置8  
record_recharge_card_info.if_effect_8 = 0 --奖励特效8


recharge_card_info = {
   _data = {
    [1] = {1,10,5,10,2,0,30,25,1,0,2,0,50,15,2,0,2,0,80,12,3,0,2,0,100,12,4,0,2,0,120,12,5,0,2,0,150,12,6,1,2,0,200,10,7,1,2,0,500,2,8,1,},
    [2] = {2,100,5,10,2,0,300,25,1,0,2,0,500,15,2,0,2,0,800,12,3,0,2,0,1000,12,4,0,2,0,1200,12,5,0,2,0,1500,12,6,1,2,0,2000,10,7,1,2,0,5000,2,8,1,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,

}

local __key_map = {
  id = 1,
  cost = 2,
  cost_num = 3,
  time = 4,
  type_1 = 5,
  value_1 = 6,
  size_1 = 7,
  weight_1 = 8,
  position_1 = 9,
  if_effect_1 = 10,
  type_2 = 11,
  value_2 = 12,
  size_2 = 13,
  weight_2 = 14,
  position_2 = 15,
  if_effect_2 = 16,
  type_3 = 17,
  value_3 = 18,
  size_3 = 19,
  weight_3 = 20,
  position_3 = 21,
  if_effect_3 = 22,
  type_4 = 23,
  value_4 = 24,
  size_4 = 25,
  weight_4 = 26,
  position_4 = 27,
  if_effect_4 = 28,
  type_5 = 29,
  value_5 = 30,
  size_5 = 31,
  weight_5 = 32,
  position_5 = 33,
  if_effect_5 = 34,
  type_6 = 35,
  value_6 = 36,
  size_6 = 37,
  weight_6 = 38,
  position_6 = 39,
  if_effect_6 = 40,
  type_7 = 41,
  value_7 = 42,
  size_7 = 43,
  weight_7 = 44,
  position_7 = 45,
  if_effect_7 = 46,
  type_8 = 47,
  value_8 = 48,
  size_8 = 49,
  weight_8 = 50,
  position_8 = 51,
  if_effect_8 = 52,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_recharge_card_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function recharge_card_info.getLength()
    return #recharge_card_info._data
end



function recharge_card_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_recharge_card_info
function recharge_card_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = recharge_card_info._data[index]}, m)
    
end

---
--@return @class record_recharge_card_info
function recharge_card_info.get(id)
    
    return recharge_card_info.indexOf(__index_id[id])
        
end



function recharge_card_info.set(id, key, value)
    local record = recharge_card_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function recharge_card_info.get_index_data()
    return __index_id
end