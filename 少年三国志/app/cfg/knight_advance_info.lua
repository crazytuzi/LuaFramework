

---@classdef record_knight_advance_info
local record_knight_advance_info = {}
  
record_knight_advance_info.id = 0 --编号  
record_knight_advance_info.knight_type = 0 --武将类型  
record_knight_advance_info.advanced_level = 0 --阶数  
record_knight_advance_info.level_ban = 0 --等级限制  
record_knight_advance_info.cost1_type = 0 --消耗1类型  
record_knight_advance_info.cost1_value = 0 --消耗1类型值  
record_knight_advance_info.cost1_num = 0 --消耗1数量  
record_knight_advance_info.cost2_type = 0 --消耗2类型  
record_knight_advance_info.cost2_value = 0 --消耗2类型值  
record_knight_advance_info.cost2_num = 0 --消耗2数量  
record_knight_advance_info.cost3_type = 0 --消耗3类型  
record_knight_advance_info.cost3_value = 0 --消耗3类型值  
record_knight_advance_info.cost3_num = 0 --消耗3数量  
record_knight_advance_info.cost4_type = 0 --消耗4类型  
record_knight_advance_info.cost4_value = 0 --消耗4类型值  
record_knight_advance_info.cost4_num = 0 --消耗4数量  
record_knight_advance_info.cost_money = 0 --消耗银两  
record_knight_advance_info.recycle_money = 0 --回收银两


knight_advance_info = {
   _data = {
    [1] = {1,2,0,0,2,6,30,0,0,0,0,0,0,0,0,0,10000,0,},
    [2] = {2,2,1,15,2,6,150,0,0,0,0,0,0,0,0,0,20000,0,},
    [3] = {3,2,2,25,2,6,300,0,0,0,0,0,0,0,0,0,30000,0,},
    [4] = {4,2,3,35,2,6,500,1,0,1,0,0,0,0,0,0,40000,0,},
    [5] = {5,2,4,45,2,6,800,1,0,1,0,0,0,0,0,0,50000,0,},
    [6] = {6,2,5,55,2,6,1200,1,0,2,0,0,0,0,0,0,60000,0,},
    [7] = {7,2,6,65,2,6,1800,1,0,2,0,0,0,0,0,0,70000,0,},
    [8] = {8,2,7,75,2,6,2500,1,0,4,0,0,0,0,0,0,80000,0,},
    [9] = {9,2,8,90,2,6,3500,1,0,4,0,0,0,0,0,0,90000,0,},
    [10] = {10,2,9,100,2,6,8000,1,0,6,0,0,0,0,0,0,500000,0,},
    [11] = {11,2,10,110,2,6,18000,1,0,8,0,0,0,0,0,0,2000000,0,},
    [12] = {12,1,0,0,2,6,50,0,0,0,0,0,0,0,0,0,10000,0,},
    [13] = {13,1,1,15,2,6,180,0,0,0,0,0,0,0,0,0,20000,0,},
    [14] = {14,1,2,25,2,6,350,0,0,0,0,0,0,0,0,0,30000,0,},
    [15] = {15,1,3,35,2,6,600,0,0,0,0,0,0,0,0,0,40000,0,},
    [16] = {16,1,4,45,2,6,1000,0,0,0,0,0,0,0,0,0,50000,0,},
    [17] = {17,1,5,55,2,6,1500,0,0,0,0,0,0,0,0,0,60000,0,},
    [18] = {18,1,6,65,2,6,2500,0,0,0,0,0,0,0,0,0,70000,0,},
    [19] = {19,1,7,75,2,6,3500,0,0,0,0,0,0,0,0,0,80000,0,},
    [20] = {20,1,8,90,2,6,5000,0,0,0,0,0,0,0,0,0,90000,0,},
    [21] = {21,1,9,100,2,6,12000,0,0,0,0,0,0,0,0,0,500000,0,},
    [22] = {22,1,10,110,2,6,25000,0,0,0,0,0,0,0,0,0,2000000,0,},
    [23] = {23,2,11,120,2,6,35000,1,0,10,0,0,0,0,0,0,5000000,0,},
    [24] = {24,1,11,120,2,6,50000,0,0,0,0,0,0,0,0,0,5000000,0,},
    [25] = {25,2,12,130,2,6,50000,1,0,10,0,0,0,0,0,0,5000000,0,},
    [26] = {26,1,12,130,2,6,60000,0,0,0,0,0,0,0,0,0,5000000,0,},
    [27] = {27,2,13,140,2,6,75000,1,0,10,0,0,0,0,0,0,5000000,0,},
    [28] = {28,1,13,140,2,6,85000,0,0,0,0,0,0,0,0,0,5000000,0,},
    [29] = {29,2,14,150,2,6,100000,1,0,15,0,0,0,0,0,0,5000000,0,},
    [30] = {30,1,14,150,2,6,115000,0,0,0,0,0,0,0,0,0,5000000,0,},
    [31] = {31,2,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
    [32] = {32,1,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
    }
}



local __index_knight_type_advanced_level = {
    ["1_0"] = 12,
    ["1_1"] = 13,
    ["1_10"] = 22,
    ["1_11"] = 24,
    ["1_12"] = 26,
    ["1_13"] = 28,
    ["1_14"] = 30,
    ["1_15"] = 32,
    ["1_2"] = 14,
    ["1_3"] = 15,
    ["1_4"] = 16,
    ["1_5"] = 17,
    ["1_6"] = 18,
    ["1_7"] = 19,
    ["1_8"] = 20,
    ["1_9"] = 21,
    ["2_0"] = 1,
    ["2_1"] = 2,
    ["2_10"] = 11,
    ["2_11"] = 23,
    ["2_12"] = 25,
    ["2_13"] = 27,
    ["2_14"] = 29,
    ["2_15"] = 31,
    ["2_2"] = 3,
    ["2_3"] = 4,
    ["2_4"] = 5,
    ["2_5"] = 6,
    ["2_6"] = 7,
    ["2_7"] = 8,
    ["2_8"] = 9,
    ["2_9"] = 10,

}

local __key_map = {
  id = 1,
  knight_type = 2,
  advanced_level = 3,
  level_ban = 4,
  cost1_type = 5,
  cost1_value = 6,
  cost1_num = 7,
  cost2_type = 8,
  cost2_value = 9,
  cost2_num = 10,
  cost3_type = 11,
  cost3_value = 12,
  cost3_num = 13,
  cost4_type = 14,
  cost4_value = 15,
  cost4_num = 16,
  cost_money = 17,
  recycle_money = 18,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_knight_advance_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function knight_advance_info.getLength()
    return #knight_advance_info._data
end



function knight_advance_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_knight_advance_info
function knight_advance_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = knight_advance_info._data[index]}, m)
    
end

---
--@return @class record_knight_advance_info
function knight_advance_info.get(knight_type,advanced_level)
    
    local k = knight_type .. '_' .. advanced_level
    return knight_advance_info.indexOf(__index_knight_type_advanced_level[k])
        
end



function knight_advance_info.set(knight_type,advanced_level, key, value)
    local record = knight_advance_info.get(knight_type,advanced_level)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function knight_advance_info.get_index_data()
    return __index_knight_type_advanced_level
end