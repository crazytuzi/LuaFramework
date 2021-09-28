

---@classdef record_activity_money_info
local record_activity_money_info = {}
  
record_activity_money_info.id = 0 --id  
record_activity_money_info.level = "" --等级  
record_activity_money_info.times_total = "" --总领取次数  
record_activity_money_info.times = 0 --显示次数  
record_activity_money_info.max_money = "" --最高奖励  
record_activity_money_info.min_money = 0 --最低奖励  
record_activity_money_info.single_reward = 0 --单次奖励  
record_activity_money_info.type = 0 --奖励类型  
record_activity_money_info.value = 0 --奖励类型值  
record_activity_money_info.size = 0 --奖励数量  
record_activity_money_info.total_reward = 0 --累计银两  
record_activity_money_info.type_show = 0 --显示奖励类型  
record_activity_money_info.value_show = 0 --显示奖励类型值  
record_activity_money_info.size_show = 0 --显示奖励数量  
record_activity_money_info.count_down = 0 --天数倒计时


activity_money_info = {
   _data = {
    [1] = {1,0,1,1,10000,5000,7500,3,4,1,7500,3,4,0,1,},
    [2] = {2,0,2,2,12500,7500,10000,3,4,1,17500,3,4,0,1,},
    [3] = {3,0,3,3,15000,10000,12500,3,4,1,30000,3,4,0,1,},
    [4] = {4,0,4,1,10000,5000,7500,3,4,1,37500,3,4,0,0,},
    [5] = {5,0,5,2,12500,7500,10000,3,4,1,47500,3,4,0,0,},
    [6] = {6,0,6,3,15000,10000,12500,3,4,1,60000,3,4,0,0,},
    [7] = {7,0,7,0,60000,60000,60000,3,4,0,0,3,4,0,0,},
    [8] = {8,40,1,1,35000,25000,30000,3,4,1,30000,3,4,0,1,},
    [9] = {9,40,2,2,45000,35000,40000,3,4,1,70000,3,4,0,1,},
    [10] = {10,40,3,3,55000,45000,50000,3,4,2,120000,3,4,0,1,},
    [11] = {11,40,4,1,35000,25000,30000,3,4,1,150000,3,4,0,0,},
    [12] = {12,40,5,2,45000,35000,40000,3,4,1,190000,3,4,0,0,},
    [13] = {13,40,6,3,55000,45000,50000,3,4,2,240000,3,4,0,0,},
    [14] = {14,40,7,0,240000,240000,240000,3,4,0,0,3,4,0,0,},
    [15] = {15,60,1,1,70000,50000,60000,3,4,1,60000,3,4,0,1,},
    [16] = {16,60,2,2,90000,70000,80000,3,4,2,140000,3,4,0,1,},
    [17] = {17,60,3,3,110000,90000,100000,3,4,2,240000,3,4,0,1,},
    [18] = {18,60,4,1,70000,50000,60000,3,4,1,300000,3,4,0,0,},
    [19] = {19,60,5,2,90000,70000,80000,3,4,2,380000,3,4,0,0,},
    [20] = {20,60,6,3,110000,90000,100000,3,4,2,480000,3,4,0,0,},
    [21] = {21,60,7,0,480000,480000,480000,3,4,0,0,3,4,0,0,},
    [22] = {22,80,1,1,90000,60000,75000,3,4,2,75000,3,4,0,1,},
    [23] = {23,80,2,2,115000,85000,100000,3,4,2,175000,3,4,0,1,},
    [24] = {24,80,3,3,140000,110000,125000,3,4,2,300000,3,4,0,1,},
    [25] = {25,80,4,1,90000,60000,75000,3,4,2,375000,3,4,0,0,},
    [26] = {26,80,5,2,115000,85000,100000,3,4,2,475000,3,4,0,0,},
    [27] = {27,80,6,3,140000,110000,125000,3,4,2,600000,3,4,0,0,},
    [28] = {28,80,7,0,600000,600000,600000,3,4,0,0,3,4,0,0,},
    [29] = {29,100,1,1,135000,90000,120000,3,4,2,120000,3,4,0,1,},
    [30] = {30,100,2,2,172500,127500,150000,3,4,2,270000,3,4,0,1,},
    [31] = {31,100,3,3,210000,165000,180000,3,4,2,450000,3,4,0,1,},
    [32] = {32,100,4,1,135000,90000,120000,3,4,2,570000,3,4,0,0,},
    [33] = {33,100,5,2,172500,127500,150000,3,4,2,720000,3,4,0,0,},
    [34] = {34,100,6,3,210000,165000,180000,3,4,2,900000,3,4,0,0,},
    [35] = {35,100,7,0,900000,900000,900000,3,4,0,0,3,4,0,0,},
    [36] = {36,120,1,1,202500,135000,170000,3,4,3,170000,3,4,0,1,},
    [37] = {37,120,2,2,258750,191250,225000,3,4,3,395000,3,4,0,1,},
    [38] = {38,120,3,3,315000,247500,280000,3,4,3,675000,3,4,0,1,},
    [39] = {39,120,4,1,202500,135000,170000,3,4,3,845000,3,4,0,0,},
    [40] = {40,120,5,2,258750,191250,225000,3,4,3,1070000,3,4,0,0,},
    [41] = {41,120,6,3,315000,247500,280000,3,4,3,1350000,3,4,0,0,},
    [42] = {42,120,7,0,1350000,1350000,1350000,3,4,0,0,3,4,0,0,},
    }
}



local __index_level_times_total = {
    ["0_1"] = 1,
    ["0_2"] = 2,
    ["0_3"] = 3,
    ["0_4"] = 4,
    ["0_5"] = 5,
    ["0_6"] = 6,
    ["0_7"] = 7,
    ["100_1"] = 29,
    ["100_2"] = 30,
    ["100_3"] = 31,
    ["100_4"] = 32,
    ["100_5"] = 33,
    ["100_6"] = 34,
    ["100_7"] = 35,
    ["120_1"] = 36,
    ["120_2"] = 37,
    ["120_3"] = 38,
    ["120_4"] = 39,
    ["120_5"] = 40,
    ["120_6"] = 41,
    ["120_7"] = 42,
    ["40_1"] = 8,
    ["40_2"] = 9,
    ["40_3"] = 10,
    ["40_4"] = 11,
    ["40_5"] = 12,
    ["40_6"] = 13,
    ["40_7"] = 14,
    ["60_1"] = 15,
    ["60_2"] = 16,
    ["60_3"] = 17,
    ["60_4"] = 18,
    ["60_5"] = 19,
    ["60_6"] = 20,
    ["60_7"] = 21,
    ["80_1"] = 22,
    ["80_2"] = 23,
    ["80_3"] = 24,
    ["80_4"] = 25,
    ["80_5"] = 26,
    ["80_6"] = 27,
    ["80_7"] = 28,

}

local __key_map = {
  id = 1,
  level = 2,
  times_total = 3,
  times = 4,
  max_money = 5,
  min_money = 6,
  single_reward = 7,
  type = 8,
  value = 9,
  size = 10,
  total_reward = 11,
  type_show = 12,
  value_show = 13,
  size_show = 14,
  count_down = 15,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_activity_money_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function activity_money_info.getLength()
    return #activity_money_info._data
end



function activity_money_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_activity_money_info
function activity_money_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = activity_money_info._data[index]}, m)
    
end

---
--@return @class record_activity_money_info
function activity_money_info.get(level,times_total)
    
    local k = level .. '_' .. times_total
    return activity_money_info.indexOf(__index_level_times_total[k])
        
end



function activity_money_info.set(level,times_total, key, value)
    local record = activity_money_info.get(level,times_total)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function activity_money_info.get_index_data()
    return __index_level_times_total
end