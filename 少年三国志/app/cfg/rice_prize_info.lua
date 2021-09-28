

---@classdef record_rice_prize_info
local record_rice_prize_info = {}
  
record_rice_prize_info.id = 0 --id  
record_rice_prize_info.lower_rank = 0 --排名下限  
record_rice_prize_info.upper_rank = 0 --排名上限  
record_rice_prize_info.type_1 = 0 --道具类型1  
record_rice_prize_info.value_1 = 0 --道具类型值1  
record_rice_prize_info.size_1 = 0 --道具数量1  
record_rice_prize_info.type_2 = 0 --道具类型2  
record_rice_prize_info.value_2 = 0 --道具类型值2  
record_rice_prize_info.size_2 = 0 --道具数量2  
record_rice_prize_info.type_3 = 0 --道具类型3  
record_rice_prize_info.value_3 = 0 --道具类型值3  
record_rice_prize_info.size_3 = 0 --道具数量3


rice_prize_info = {
   _data = {
    [1] = {1,1,1,9,0,12000,3,18,1200,0,0,0,},
    [2] = {2,2,2,9,0,11000,3,18,1100,0,0,0,},
    [3] = {3,3,3,9,0,10000,3,18,1000,0,0,0,},
    [4] = {4,5,4,9,0,9000,3,18,900,0,0,0,},
    [5] = {5,10,6,9,0,8000,3,18,800,0,0,0,},
    [6] = {6,20,11,9,0,7000,3,18,700,0,0,0,},
    [7] = {7,50,21,9,0,6000,3,18,600,0,0,0,},
    [8] = {8,100,51,9,0,5000,3,18,500,0,0,0,},
    [9] = {9,200,101,9,0,4000,3,18,400,0,0,0,},
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
  lower_rank = 2,
  upper_rank = 3,
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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_rice_prize_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function rice_prize_info.getLength()
    return #rice_prize_info._data
end



function rice_prize_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_rice_prize_info
function rice_prize_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = rice_prize_info._data[index]}, m)
    
end

---
--@return @class record_rice_prize_info
function rice_prize_info.get(id)
    
    return rice_prize_info.indexOf(__index_id[id])
        
end



function rice_prize_info.set(id, key, value)
    local record = rice_prize_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function rice_prize_info.get_index_data()
    return __index_id
end