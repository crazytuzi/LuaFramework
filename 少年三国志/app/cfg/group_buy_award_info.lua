

---@classdef record_group_buy_award_info
local record_group_buy_award_info = {}
  
record_group_buy_award_info.id = 0 --编号  
record_group_buy_award_info.task_type = 0 --任务类型  
record_group_buy_award_info.condition = 0 --达成条件  
record_group_buy_award_info.type_1 = 0 --奖励类型1  
record_group_buy_award_info.value_1 = 0 --奖励值1  
record_group_buy_award_info.size_1 = 0 --奖励数量1  
record_group_buy_award_info.type_2 = 0 --奖励类型2  
record_group_buy_award_info.value_2 = 0 --奖励值2  
record_group_buy_award_info.size_2 = 0 --奖励数量2  
record_group_buy_award_info.type_3 = "" --奖励类型3  
record_group_buy_award_info.value_3 = "" --奖励值3  
record_group_buy_award_info.size_3 = "" --奖励数量3


group_buy_award_info = {
   _data = {
    [1] = {1,1,500,27,0,50,0,0,0,0,0,0,},
    [2] = {2,1,1000,3,116,1,0,0,0,0,0,0,},
    [3] = {3,1,1500,3,116,1,0,0,0,0,0,0,},
    [4] = {4,1,2500,27,0,100,0,0,0,0,0,0,},
    [5] = {5,1,4000,3,116,1,0,0,0,0,0,0,},
    [6] = {6,1,6000,3,116,2,0,0,0,0,0,0,},
    [7] = {7,1,10000,3,116,2,0,0,0,0,0,0,},
    [8] = {8,1,15000,3,116,3,0,0,0,0,0,0,},
    [9] = {9,1,20000,3,75,1,0,0,0,0,0,0,},
    [10] = {10,3,0,0,0,0,0,0,0,0,0,0,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
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
  task_type = 2,
  condition = 3,
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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_group_buy_award_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function group_buy_award_info.getLength()
    return #group_buy_award_info._data
end



function group_buy_award_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_group_buy_award_info
function group_buy_award_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = group_buy_award_info._data[index]}, m)
    
end

---
--@return @class record_group_buy_award_info
function group_buy_award_info.get(id)
    
    return group_buy_award_info.indexOf(__index_id[id])
        
end



function group_buy_award_info.set(id, key, value)
    local record = group_buy_award_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function group_buy_award_info.get_index_data()
    return __index_id
end