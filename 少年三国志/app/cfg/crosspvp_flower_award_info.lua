

---@classdef record_crosspvp_flower_award_info
local record_crosspvp_flower_award_info = {}
  
record_crosspvp_flower_award_info.id = 0 --编号  
record_crosspvp_flower_award_info.type = 0 --物品类型  
record_crosspvp_flower_award_info.min_size = 0 --购买数量下限  
record_crosspvp_flower_award_info.max_size = 0 --购买数量上限  
record_crosspvp_flower_award_info.award_type_1 = 0 --奖励类型1  
record_crosspvp_flower_award_info.award_value_1 = 0 --奖励类型值1  
record_crosspvp_flower_award_info.award_size_1 = 0 --奖励数量1  
record_crosspvp_flower_award_info.award_type_2 = 0 --奖励类型2  
record_crosspvp_flower_award_info.award_value_2 = 0 --奖励类型值2  
record_crosspvp_flower_award_info.award_size_2 = 0 --奖励数量2  
record_crosspvp_flower_award_info.award_type_3 = 0 --奖励类型3  
record_crosspvp_flower_award_info.award_value_3 = 0 --奖励类型值3  
record_crosspvp_flower_award_info.award_size_3 = 0 --奖励数量3  
record_crosspvp_flower_award_info.award_type_4 = 0 --奖励类型4  
record_crosspvp_flower_award_info.award_value_4 = 0 --奖励类型值4  
record_crosspvp_flower_award_info.award_size_4 = 0 --奖励数量4


crosspvp_flower_award_info = {
   _data = {
    [1] = {1,1,1,10,2,0,80,25,0,750,3,13,10,0,0,0,},
    [2] = {2,1,11,30,2,0,200,3,289,5,25,0,2250,3,13,20,},
    [3] = {3,1,31,50,2,0,400,3,289,10,25,0,3750,3,13,40,},
    [4] = {4,1,51,100,2,0,600,3,289,15,25,0,6000,3,13,60,},
    [5] = {5,1,101,200,2,0,1200,3,289,20,25,0,11250,3,13,120,},
    [6] = {6,1,201,10000000,2,0,1500,3,289,30,25,0,15000,3,13,150,},
    [7] = {7,2,1,10,2,0,80,25,0,750,3,18,40,0,0,0,},
    [8] = {8,2,11,30,2,0,200,3,289,5,25,0,2250,3,18,80,},
    [9] = {9,2,31,50,2,0,400,3,289,10,25,0,3750,3,18,160,},
    [10] = {10,2,51,100,2,0,600,3,289,15,25,0,6000,3,18,240,},
    [11] = {11,2,101,200,2,0,1200,3,289,20,25,0,11250,3,18,480,},
    [12] = {12,2,201,10000000,2,0,1500,3,289,30,25,0,15000,3,18,600,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [12] = 12,
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
  type = 2,
  min_size = 3,
  max_size = 4,
  award_type_1 = 5,
  award_value_1 = 6,
  award_size_1 = 7,
  award_type_2 = 8,
  award_value_2 = 9,
  award_size_2 = 10,
  award_type_3 = 11,
  award_value_3 = 12,
  award_size_3 = 13,
  award_type_4 = 14,
  award_value_4 = 15,
  award_size_4 = 16,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_crosspvp_flower_award_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function crosspvp_flower_award_info.getLength()
    return #crosspvp_flower_award_info._data
end



function crosspvp_flower_award_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_crosspvp_flower_award_info
function crosspvp_flower_award_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = crosspvp_flower_award_info._data[index]}, m)
    
end

---
--@return @class record_crosspvp_flower_award_info
function crosspvp_flower_award_info.get(id)
    
    return crosspvp_flower_award_info.indexOf(__index_id[id])
        
end



function crosspvp_flower_award_info.set(id, key, value)
    local record = crosspvp_flower_award_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function crosspvp_flower_award_info.get_index_data()
    return __index_id
end