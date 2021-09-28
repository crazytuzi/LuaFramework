

---@classdef record_ksoul_group_target_info
local record_ksoul_group_target_info = {}
  
record_ksoul_group_target_info.id = 0 --id  
record_ksoul_group_target_info.target_value = 0 --所需荣誉值  
record_ksoul_group_target_info.pre_id = 0 --前置成就id  
record_ksoul_group_target_info.attribute_type1 = 0 --属性类型  
record_ksoul_group_target_info.attribute_value1 = 0 --属性类型值


ksoul_group_target_info = {
   _data = {
    [1] = {1,25,0,17,10,},
    [2] = {2,50,1,18,10,},
    [3] = {3,75,2,17,10,},
    [4] = {4,100,3,18,10,},
    [5] = {5,125,4,17,10,},
    [6] = {6,150,5,18,10,},
    [7] = {7,175,6,17,10,},
    [8] = {8,200,7,18,10,},
    [9] = {9,225,8,17,10,},
    [10] = {10,250,9,18,10,},
    [11] = {11,275,10,17,10,},
    [12] = {12,300,11,18,10,},
    [13] = {13,325,12,17,10,},
    [14] = {14,350,13,18,10,},
    [15] = {15,375,14,17,10,},
    [16] = {16,400,15,18,10,},
    [17] = {17,425,16,17,10,},
    [18] = {18,450,17,18,10,},
    [19] = {19,475,18,17,10,},
    [20] = {20,500,19,18,10,},
    [21] = {21,525,20,17,10,},
    [22] = {22,550,21,18,10,},
    [23] = {23,575,22,17,10,},
    [24] = {24,600,23,18,10,},
    [25] = {25,625,24,17,10,},
    [26] = {26,650,25,18,10,},
    [27] = {27,675,26,17,10,},
    [28] = {28,700,27,18,10,},
    [29] = {29,725,28,17,10,},
    [30] = {30,750,29,18,10,},
    [31] = {31,775,30,17,10,},
    [32] = {32,800,31,18,10,},
    [33] = {33,825,32,17,10,},
    [34] = {34,850,33,18,10,},
    [35] = {35,875,34,17,10,},
    [36] = {36,900,35,18,10,},
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
    [20] = 20,
    [21] = 21,
    [22] = 22,
    [23] = 23,
    [24] = 24,
    [25] = 25,
    [26] = 26,
    [27] = 27,
    [28] = 28,
    [29] = 29,
    [3] = 3,
    [30] = 30,
    [31] = 31,
    [32] = 32,
    [33] = 33,
    [34] = 34,
    [35] = 35,
    [36] = 36,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  target_value = 2,
  pre_id = 3,
  attribute_type1 = 4,
  attribute_value1 = 5,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_ksoul_group_target_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function ksoul_group_target_info.getLength()
    return #ksoul_group_target_info._data
end



function ksoul_group_target_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_ksoul_group_target_info
function ksoul_group_target_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = ksoul_group_target_info._data[index]}, m)
    
end

---
--@return @class record_ksoul_group_target_info
function ksoul_group_target_info.get(id)
    
    return ksoul_group_target_info.indexOf(__index_id[id])
        
end



function ksoul_group_target_info.set(id, key, value)
    local record = ksoul_group_target_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function ksoul_group_target_info.get_index_data()
    return __index_id
end