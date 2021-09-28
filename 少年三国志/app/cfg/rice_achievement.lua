

---@classdef record_rice_achievement
local record_rice_achievement = {}
  
record_rice_achievement.id = 0 --成就id  
record_rice_achievement.premise_id = 0 --前置成就id  
record_rice_achievement.num = 0 --需求粮草数量  
record_rice_achievement.type_1 = 0 --奖励类型1  
record_rice_achievement.value_1 = 0 --奖励类型值1  
record_rice_achievement.size_1 = 0 --奖励数量1  
record_rice_achievement.type_2 = 0 --奖励类型2  
record_rice_achievement.value_2 = 0 --奖励类型值2  
record_rice_achievement.size_2 = 0 --奖励数量2  
record_rice_achievement.type_3 = 0 --奖励类型3  
record_rice_achievement.value_3 = 0 --奖励类型值3  
record_rice_achievement.size_3 = 0 --奖励数量3


rice_achievement = {
   _data = {
    [1] = {1,0,7500,1,0,300000,3,18,60,0,0,0,},
    [2] = {2,1,9000,3,6,100,3,18,60,0,0,0,},
    [3] = {3,2,11000,3,60,80,3,18,60,0,0,0,},
    [4] = {4,3,13500,1,0,450000,3,18,90,0,0,0,},
    [5] = {5,4,16500,3,6,200,3,18,90,0,0,0,},
    [6] = {6,5,20000,3,60,100,3,18,90,0,0,0,},
    [7] = {7,6,24000,1,0,600000,3,18,120,0,0,0,},
    [8] = {8,7,28500,3,6,300,3,18,120,0,0,0,},
    [9] = {9,8,33500,3,60,120,3,18,120,0,0,0,},
    [10] = {10,9,39000,1,0,750000,3,18,150,0,0,0,},
    [11] = {11,10,45000,3,6,400,3,18,150,0,0,0,},
    [12] = {12,11,52000,3,60,140,3,18,150,0,0,0,},
    [13] = {13,12,60000,1,0,900000,3,18,180,0,0,0,},
    [14] = {14,13,71000,3,6,500,3,18,180,0,0,0,},
    [15] = {15,14,84000,3,60,160,3,18,180,0,0,0,},
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
  premise_id = 2,
  num = 3,
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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_rice_achievement")
        
        
        return t._raw[__key_map[k]]
    end
}


function rice_achievement.getLength()
    return #rice_achievement._data
end



function rice_achievement.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_rice_achievement
function rice_achievement.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = rice_achievement._data[index]}, m)
    
end

---
--@return @class record_rice_achievement
function rice_achievement.get(id)
    
    return rice_achievement.indexOf(__index_id[id])
        
end



function rice_achievement.set(id, key, value)
    local record = rice_achievement.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function rice_achievement.get_index_data()
    return __index_id
end