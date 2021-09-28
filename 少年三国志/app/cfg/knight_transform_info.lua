

---@classdef record_knight_transform_info
local record_knight_transform_info = {}
  
record_knight_transform_info.group_id = 0 --变化组  
record_knight_transform_info.advanced_code = 0 --武将进阶码  
record_knight_transform_info.cost = 0 --价格系数  
record_knight_transform_info.constant = 0 --价格常量  
record_knight_transform_info.cost_2 = "" --消耗精华  
record_knight_transform_info.group = 0 --所属阵营


knight_transform_info = {
   _data = {
    [1] = {1,10012,0,200,0,1,},
    [2] = {1,10023,0,200,0,1,},
    [3] = {1,10034,0,200,0,1,},
    [4] = {1,10045,800,200,0,1,},
    [5] = {1,10067,0,200,0,1,},
    [6] = {1,10089,0,200,0,1,},
    [7] = {1,10111,800,200,0,1,},
    [8] = {1,10122,0,200,0,1,},
    [9] = {1,10144,0,200,0,1,},
    [10] = {1,20012,0,200,0,2,},
    [11] = {1,20023,800,200,0,2,},
    [12] = {1,20034,0,200,0,2,},
    [13] = {1,20045,0,200,0,2,},
    [14] = {1,20056,0,200,0,2,},
    [15] = {1,20067,0,200,0,2,},
    [16] = {1,20089,800,200,0,2,},
    [17] = {1,20111,0,200,0,2,},
    [18] = {1,20155,0,200,0,2,},
    [19] = {1,30012,0,200,0,3,},
    [20] = {1,30023,0,200,0,3,},
    [21] = {1,30034,800,200,0,3,},
    [22] = {1,30056,0,200,0,3,},
    [23] = {1,30067,800,200,0,3,},
    [24] = {1,30078,0,200,0,3,},
    [25] = {1,30089,0,200,0,3,},
    [26] = {1,30133,0,200,0,3,},
    [27] = {1,30144,0,200,0,3,},
    [28] = {1,40012,0,200,0,4,},
    [29] = {1,40023,0,200,0,4,},
    [30] = {1,40056,0,200,0,4,},
    [31] = {1,40133,800,200,0,4,},
    [32] = {1,40144,0,200,0,4,},
    [33] = {1,40155,0,200,0,4,},
    [34] = {1,40166,0,200,0,4,},
    [35] = {1,40177,0,200,0,4,},
    [36] = {1,40188,800,200,0,4,},
    [37] = {2,10001,0,500,5,1,},
    [38] = {2,10056,0,500,5,1,},
    [39] = {2,20001,0,500,5,2,},
    [40] = {2,20078,0,500,5,2,},
    [41] = {2,30001,0,500,5,3,},
    [42] = {2,30045,0,500,5,3,},
    [43] = {2,40001,0,500,5,4,},
    [44] = {2,40045,0,500,5,4,},
    }
}



local __index_advanced_code = {
    [10001] = 37,
    [10012] = 1,
    [10023] = 2,
    [10034] = 3,
    [10045] = 4,
    [10056] = 38,
    [10067] = 5,
    [10089] = 6,
    [10111] = 7,
    [10122] = 8,
    [10144] = 9,
    [20001] = 39,
    [20012] = 10,
    [20023] = 11,
    [20034] = 12,
    [20045] = 13,
    [20056] = 14,
    [20067] = 15,
    [20078] = 40,
    [20089] = 16,
    [20111] = 17,
    [20155] = 18,
    [30001] = 41,
    [30012] = 19,
    [30023] = 20,
    [30034] = 21,
    [30045] = 42,
    [30056] = 22,
    [30067] = 23,
    [30078] = 24,
    [30089] = 25,
    [30133] = 26,
    [30144] = 27,
    [40001] = 43,
    [40012] = 28,
    [40023] = 29,
    [40045] = 44,
    [40056] = 30,
    [40133] = 31,
    [40144] = 32,
    [40155] = 33,
    [40166] = 34,
    [40177] = 35,
    [40188] = 36,

}

local __key_map = {
  group_id = 1,
  advanced_code = 2,
  cost = 3,
  constant = 4,
  cost_2 = 5,
  group = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_knight_transform_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function knight_transform_info.getLength()
    return #knight_transform_info._data
end



function knight_transform_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_knight_transform_info
function knight_transform_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = knight_transform_info._data[index]}, m)
    
end

---
--@return @class record_knight_transform_info
function knight_transform_info.get(advanced_code)
    
    return knight_transform_info.indexOf(__index_advanced_code[advanced_code])
        
end



function knight_transform_info.set(advanced_code, key, value)
    local record = knight_transform_info.get(advanced_code)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function knight_transform_info.get_index_data()
    return __index_advanced_code
end