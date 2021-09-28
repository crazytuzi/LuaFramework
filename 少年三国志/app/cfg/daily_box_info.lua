

---@classdef record_daily_box_info
local record_daily_box_info = {}
  
record_daily_box_info.id = 0 --编号  
record_daily_box_info.require_points = 0 --需求积分  
record_daily_box_info.level_min = 0 --等级下限（闭区间）  
record_daily_box_info.level_max = 0 --等级上限（闭区间）  
record_daily_box_info.award1_type = 0 --奖励1类型  
record_daily_box_info.award1_value = 0 --奖励1类型值  
record_daily_box_info.award1_size = 0 --奖励1数量  
record_daily_box_info.award2_type = 0 --奖励2类型  
record_daily_box_info.award2_value = 0 --奖励2类型值  
record_daily_box_info.award2_size = 0 --奖励2数量  
record_daily_box_info.award3_type = 0 --奖励3类型  
record_daily_box_info.award3_value = 0 --奖励3类型值  
record_daily_box_info.award3_size = 0 --奖励3数量  
record_daily_box_info.award4_type = 0 --奖励4类型  
record_daily_box_info.award4_value = 0 --奖励4类型值  
record_daily_box_info.award4_size = 0 --奖励4数量


daily_box_info = {
   _data = {
    [1] = {101,30,1,20,1,0,20000,2,0,20,0,0,0,0,0,0,},
    [2] = {102,60,1,20,1,0,40000,2,0,30,0,0,0,0,0,0,},
    [3] = {103,90,1,20,3,37,1,2,0,50,0,0,0,0,0,0,},
    [4] = {104,120,1,20,3,37,1,2,0,100,0,0,0,0,0,0,},
    [5] = {201,30,21,34,1,0,25000,2,0,20,0,0,0,0,0,0,},
    [6] = {202,60,21,34,1,0,50000,2,0,30,3,15,1,0,0,0,},
    [7] = {203,90,21,34,3,37,1,2,0,50,3,15,2,0,0,0,},
    [8] = {204,120,21,34,3,37,3,2,0,100,3,15,3,0,0,0,},
    [9] = {301,30,35,50,1,0,90000,2,0,60,0,0,0,0,0,0,},
    [10] = {302,60,35,50,1,0,180000,2,0,90,3,15,3,0,0,0,},
    [11] = {303,90,35,50,3,37,3,2,0,150,3,15,6,3,5,3,},
    [12] = {304,120,35,50,3,37,3,2,0,300,3,15,9,3,5,3,},
    [13] = {401,30,51,60,1,0,40000,2,0,20,3,5,1,0,0,0,},
    [14] = {402,60,51,60,1,0,70000,2,0,30,3,15,1,3,5,1,},
    [15] = {403,90,51,60,3,37,1,2,0,50,3,15,2,3,5,2,},
    [16] = {404,120,51,60,3,37,1,2,0,100,3,15,3,3,5,2,},
    [17] = {501,30,61,70,1,0,50000,2,0,20,3,5,1,0,0,0,},
    [18] = {502,60,61,70,1,0,80000,2,0,30,3,15,1,3,5,1,},
    [19] = {503,90,61,70,3,37,1,2,0,50,3,15,2,3,5,2,},
    [20] = {504,120,61,70,3,37,1,2,0,100,3,15,3,3,5,2,},
    [21] = {601,30,71,80,1,0,60000,2,0,20,3,5,1,0,0,0,},
    [22] = {602,60,71,80,1,0,90000,2,0,30,3,15,1,3,5,1,},
    [23] = {603,90,71,80,3,37,1,2,0,50,3,15,2,3,5,2,},
    [24] = {604,120,71,80,3,37,1,2,0,100,3,15,3,3,5,2,},
    [25] = {701,30,81,100,1,0,60000,2,0,20,3,5,1,0,0,0,},
    [26] = {702,60,81,100,1,0,90000,2,0,30,3,15,1,3,5,1,},
    [27] = {703,90,81,100,3,37,1,2,0,50,3,15,2,3,5,2,},
    [28] = {704,120,81,100,3,37,1,2,0,100,3,15,3,3,5,2,},
    [29] = {801,30,101,120,1,0,60000,2,0,20,3,5,1,0,0,0,},
    [30] = {802,60,101,120,1,0,90000,2,0,30,3,15,1,3,5,1,},
    [31] = {803,90,101,120,3,37,1,2,0,50,3,15,2,3,5,2,},
    [32] = {804,120,101,120,3,37,1,2,0,100,3,15,3,3,5,2,},
    [33] = {901,30,121,140,1,0,90000,2,0,20,3,5,1,0,0,0,},
    [34] = {902,60,121,140,1,0,135000,2,0,30,3,15,1,3,5,1,},
    [35] = {903,90,121,140,3,37,2,2,0,50,3,15,2,3,5,2,},
    [36] = {904,120,121,140,3,37,2,2,0,100,3,15,3,3,5,2,},
    [37] = {1001,30,141,999,1,0,135000,2,0,20,3,5,1,0,0,0,},
    [38] = {1002,60,141,999,1,0,205000,2,0,30,3,15,1,3,5,1,},
    [39] = {1003,90,141,999,3,37,2,2,0,50,3,15,2,3,5,2,},
    [40] = {1004,120,141,999,3,37,2,2,0,100,3,15,3,3,5,2,},
    }
}



local __index_id = {
    [1001] = 37,
    [1002] = 38,
    [1003] = 39,
    [1004] = 40,
    [101] = 1,
    [102] = 2,
    [103] = 3,
    [104] = 4,
    [201] = 5,
    [202] = 6,
    [203] = 7,
    [204] = 8,
    [301] = 9,
    [302] = 10,
    [303] = 11,
    [304] = 12,
    [401] = 13,
    [402] = 14,
    [403] = 15,
    [404] = 16,
    [501] = 17,
    [502] = 18,
    [503] = 19,
    [504] = 20,
    [601] = 21,
    [602] = 22,
    [603] = 23,
    [604] = 24,
    [701] = 25,
    [702] = 26,
    [703] = 27,
    [704] = 28,
    [801] = 29,
    [802] = 30,
    [803] = 31,
    [804] = 32,
    [901] = 33,
    [902] = 34,
    [903] = 35,
    [904] = 36,

}

local __key_map = {
  id = 1,
  require_points = 2,
  level_min = 3,
  level_max = 4,
  award1_type = 5,
  award1_value = 6,
  award1_size = 7,
  award2_type = 8,
  award2_value = 9,
  award2_size = 10,
  award3_type = 11,
  award3_value = 12,
  award3_size = 13,
  award4_type = 14,
  award4_value = 15,
  award4_size = 16,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_daily_box_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function daily_box_info.getLength()
    return #daily_box_info._data
end



function daily_box_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_daily_box_info
function daily_box_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = daily_box_info._data[index]}, m)
    
end

---
--@return @class record_daily_box_info
function daily_box_info.get(id)
    
    return daily_box_info.indexOf(__index_id[id])
        
end



function daily_box_info.set(id, key, value)
    local record = daily_box_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function daily_box_info.get_index_data()
    return __index_id
end