

---@classdef record_knight_training_info
local record_knight_training_info = {}
  
record_knight_training_info.id = 0 --编号  
record_knight_training_info.stage = 0 --阶段  
record_knight_training_info.stage_start_level = 0 --阶段起始等级  
record_knight_training_info.stage_end_level = 0 --阶段结束等级  
record_knight_training_info.stage_correspond_level = 0 --阶段加成对应等级  
record_knight_training_info.stage_uplimit_percentage = 0 --阶段加成上限百分比


knight_training_info = {
   _data = {
    [1] = {1,1,1,20,20,50,},
    [2] = {2,2,21,35,35,50,},
    [3] = {3,3,36,50,50,50,},
    [4] = {4,4,51,65,65,50,},
    [5] = {5,5,66,80,80,50,},
    [6] = {6,6,81,85,100,50,},
    [7] = {7,7,86,90,100,60,},
    [8] = {8,8,91,95,100,70,},
    [9] = {9,9,96,100,100,80,},
    [10] = {10,10,101,105,105,90,},
    [11] = {11,11,106,110,110,100,},
    [12] = {12,12,111,115,115,100,},
    [13] = {13,13,116,120,120,100,},
    [14] = {14,14,121,125,125,100,},
    [15] = {15,15,126,130,130,100,},
    [16] = {16,16,131,135,135,100,},
    [17] = {17,17,136,140,140,100,},
    [18] = {18,18,141,145,145,100,},
    [19] = {19,19,146,150,150,100,},
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
    [16] = 16,
    [17] = 17,
    [18] = 18,
    [19] = 19,
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
  stage = 2,
  stage_start_level = 3,
  stage_end_level = 4,
  stage_correspond_level = 5,
  stage_uplimit_percentage = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_knight_training_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function knight_training_info.getLength()
    return #knight_training_info._data
end



function knight_training_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_knight_training_info
function knight_training_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = knight_training_info._data[index]}, m)
    
end

---
--@return @class record_knight_training_info
function knight_training_info.get(id)
    
    return knight_training_info.indexOf(__index_id[id])
        
end



function knight_training_info.set(id, key, value)
    local record = knight_training_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function knight_training_info.get_index_data()
    return __index_id
end