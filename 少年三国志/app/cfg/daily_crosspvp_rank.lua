

---@classdef record_daily_crosspvp_rank
local record_daily_crosspvp_rank = {}
  
record_daily_crosspvp_rank.id = 0 --奖励id  
record_daily_crosspvp_rank.upper_rank = 0 --排名上限  
record_daily_crosspvp_rank.lower_rank = 0 --排名下限  
record_daily_crosspvp_rank.type_1 = 0 --奖励类型1  
record_daily_crosspvp_rank.value_1 = 0 --奖励值1  
record_daily_crosspvp_rank.size_1 = 0 --奖励数量1  
record_daily_crosspvp_rank.type_2 = 0 --奖励类型2  
record_daily_crosspvp_rank.value_2 = 0 --奖励值2  
record_daily_crosspvp_rank.size_2 = 0 --奖励数量2


daily_crosspvp_rank = {
   _data = {
    [1] = {1,1,1,31,0,5000,1,0,5000000,},
    [2] = {2,2,2,31,0,4700,1,0,4700000,},
    [3] = {3,3,3,31,0,4400,1,0,4400000,},
    [4] = {4,4,5,31,0,4100,1,0,4100000,},
    [5] = {5,6,10,31,0,3800,1,0,3800000,},
    [6] = {6,11,20,31,0,3500,1,0,3500000,},
    [7] = {7,21,35,31,0,3200,1,0,3200000,},
    [8] = {8,36,55,31,0,2900,1,0,2900000,},
    [9] = {9,56,80,31,0,2600,1,0,2600000,},
    [10] = {10,81,110,31,0,2300,1,0,2300000,},
    [11] = {11,111,145,31,0,2000,1,0,2000000,},
    [12] = {12,146,185,31,0,1700,1,0,1700000,},
    [13] = {13,186,235,31,0,1400,1,0,1400000,},
    [14] = {14,236,300,31,0,1100,1,0,1100000,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [12] = 12,
    [13] = 13,
    [14] = 14,
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
  upper_rank = 2,
  lower_rank = 3,
  type_1 = 4,
  value_1 = 5,
  size_1 = 6,
  type_2 = 7,
  value_2 = 8,
  size_2 = 9,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_daily_crosspvp_rank")
        
        
        return t._raw[__key_map[k]]
    end
}


function daily_crosspvp_rank.getLength()
    return #daily_crosspvp_rank._data
end



function daily_crosspvp_rank.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_daily_crosspvp_rank
function daily_crosspvp_rank.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = daily_crosspvp_rank._data[index]}, m)
    
end

---
--@return @class record_daily_crosspvp_rank
function daily_crosspvp_rank.get(id)
    
    return daily_crosspvp_rank.indexOf(__index_id[id])
        
end



function daily_crosspvp_rank.set(id, key, value)
    local record = daily_crosspvp_rank.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function daily_crosspvp_rank.get_index_data()
    return __index_id
end