

---@classdef record_eight_trigrams_info
local record_eight_trigrams_info = {}
  
record_eight_trigrams_info.type = 0 --类别  
record_eight_trigrams_info.level = 0 --等级  
record_eight_trigrams_info.sup_id = 0 --彩蛋id  
record_eight_trigrams_info.sup_per = 0 --彩蛋概率  
record_eight_trigrams_info.award_type1 = 0 --奖励类型1  
record_eight_trigrams_info.value1 = 0 --奖励值1  
record_eight_trigrams_info.num1 = 0 --奖励数量1  
record_eight_trigrams_info.percent1 = 0 --奖励1概率  
record_eight_trigrams_info.award_type2 = 0 --奖励类型2  
record_eight_trigrams_info.value2 = 0 --奖励值2  
record_eight_trigrams_info.num2 = 0 --奖励数量2  
record_eight_trigrams_info.percent2 = 0 --奖励2概率  
record_eight_trigrams_info.award_type3 = 0 --奖励类型3  
record_eight_trigrams_info.value3 = 0 --奖励值3  
record_eight_trigrams_info.num3 = 0 --奖励数量3  
record_eight_trigrams_info.percent3 = 0 --奖励3概率  
record_eight_trigrams_info.award_type4 = 0 --奖励类型4  
record_eight_trigrams_info.value4 = 0 --奖励值4  
record_eight_trigrams_info.num4 = 0 --奖励数量4  
record_eight_trigrams_info.percent4 = 0 --奖励4概率  
record_eight_trigrams_info.award_type5 = 0 --奖励类型5  
record_eight_trigrams_info.value5 = 0 --奖励值5  
record_eight_trigrams_info.num5 = 0 --奖励数量5  
record_eight_trigrams_info.percent5 = 0 --奖励5概率  
record_eight_trigrams_info.award_type6 = 0 --奖励类型6  
record_eight_trigrams_info.value6 = 0 --奖励值6  
record_eight_trigrams_info.num6 = 0 --奖励数量6  
record_eight_trigrams_info.percent6 = 0 --奖励6概率


eight_trigrams_info = {
   _data = {
    [1] = {1,1,8,92,3,204,5,250,3,201,3,250,3,198,3,250,1,0,30000,250,0,0,0,0,0,0,0,0,},
    [2] = {2,1,0,0,3,204,5,250,3,201,3,250,3,198,3,250,1,0,30000,250,0,0,0,0,0,0,0,0,},
    [3] = {3,1,0,0,3,204,5,250,3,201,3,250,3,198,3,250,1,0,30000,250,0,0,0,0,0,0,0,0,},
    [4] = {4,1,0,0,3,204,5,250,3,201,3,250,3,198,3,250,1,0,30000,250,0,0,0,0,0,0,0,0,},
    [5] = {5,1,0,0,3,204,5,250,3,201,3,250,3,198,3,250,1,0,30000,250,0,0,0,0,0,0,0,0,},
    [6] = {6,2,0,0,3,204,10,250,3,202,5,250,3,199,1,250,1,0,80000,250,0,0,0,0,0,0,0,0,},
    [7] = {7,2,0,0,3,204,10,250,3,202,5,250,3,199,1,250,1,0,80000,250,0,0,0,0,0,0,0,0,},
    [8] = {8,3,0,0,3,204,50,250,3,203,10,250,3,200,3,250,1,0,300000,250,0,0,0,0,0,0,0,0,},
    }
}



local __index_type = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,

}

local __key_map = {
  type = 1,
  level = 2,
  sup_id = 3,
  sup_per = 4,
  award_type1 = 5,
  value1 = 6,
  num1 = 7,
  percent1 = 8,
  award_type2 = 9,
  value2 = 10,
  num2 = 11,
  percent2 = 12,
  award_type3 = 13,
  value3 = 14,
  num3 = 15,
  percent3 = 16,
  award_type4 = 17,
  value4 = 18,
  num4 = 19,
  percent4 = 20,
  award_type5 = 21,
  value5 = 22,
  num5 = 23,
  percent5 = 24,
  award_type6 = 25,
  value6 = 26,
  num6 = 27,
  percent6 = 28,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_eight_trigrams_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function eight_trigrams_info.getLength()
    return #eight_trigrams_info._data
end



function eight_trigrams_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_eight_trigrams_info
function eight_trigrams_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = eight_trigrams_info._data[index]}, m)
    
end

---
--@return @class record_eight_trigrams_info
function eight_trigrams_info.get(type)
    
    return eight_trigrams_info.indexOf(__index_type[type])
        
end



function eight_trigrams_info.set(type, key, value)
    local record = eight_trigrams_info.get(type)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function eight_trigrams_info.get_index_data()
    return __index_type
end