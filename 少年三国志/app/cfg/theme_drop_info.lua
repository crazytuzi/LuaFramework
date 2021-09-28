

---@classdef record_theme_drop_info
local record_theme_drop_info = {}
  
record_theme_drop_info.id = 0 --武将ID  
record_theme_drop_info.group_id = 0 --阵营  
record_theme_drop_info.theme = 0 --主题将  
record_theme_drop_info.level = 0 --开放等级  
record_theme_drop_info.ball_size = 0 --将星大小


theme_drop_info = {
   _data = {
    [1] = {10012,1,0,40,950,},
    [2] = {10023,1,0,40,950,},
    [3] = {10034,1,0,40,950,},
    [4] = {10045,1,1,40,1100,},
    [5] = {10001,1,2,60,1300,},
    [6] = {10067,1,0,40,950,},
    [7] = {10089,1,0,40,950,},
    [8] = {10111,1,1,40,1100,},
    [9] = {10122,1,0,40,950,},
    [10] = {10144,1,0,40,950,},
    [11] = {10056,1,2,60,1300,},
    [12] = {20012,2,0,40,950,},
    [13] = {20023,2,1,40,1100,},
    [14] = {20034,2,0,40,950,},
    [15] = {20045,2,0,40,950,},
    [16] = {20056,2,0,40,950,},
    [17] = {20067,2,0,40,950,},
    [18] = {20001,2,2,60,1300,},
    [19] = {20089,2,1,40,1100,},
    [20] = {20111,2,0,40,950,},
    [21] = {20155,2,0,40,950,},
    [22] = {20078,2,2,60,1300,},
    [23] = {30012,3,0,40,950,},
    [24] = {30023,3,0,40,950,},
    [25] = {30034,3,1,40,1100,},
    [26] = {30056,3,0,40,950,},
    [27] = {30067,3,1,40,1100,},
    [28] = {30001,3,2,60,1300,},
    [29] = {30078,3,0,40,950,},
    [30] = {30089,3,0,40,950,},
    [31] = {30133,3,0,40,950,},
    [32] = {30144,3,0,40,950,},
    [33] = {30045,3,2,60,1300,},
    [34] = {40012,4,0,40,950,},
    [35] = {40023,4,0,40,950,},
    [36] = {40056,4,0,40,950,},
    [37] = {40045,4,2,60,1300,},
    [38] = {40133,4,1,40,1100,},
    [39] = {40144,4,0,40,950,},
    [40] = {40155,4,0,40,950,},
    [41] = {40166,4,0,40,950,},
    [42] = {40177,4,0,40,950,},
    [43] = {40188,4,1,40,1100,},
    [44] = {40001,4,2,60,1300,},
    }
}



local __index_id = {
    [10001] = 5,
    [10012] = 1,
    [10023] = 2,
    [10034] = 3,
    [10045] = 4,
    [10056] = 11,
    [10067] = 6,
    [10089] = 7,
    [10111] = 8,
    [10122] = 9,
    [10144] = 10,
    [20001] = 18,
    [20012] = 12,
    [20023] = 13,
    [20034] = 14,
    [20045] = 15,
    [20056] = 16,
    [20067] = 17,
    [20078] = 22,
    [20089] = 19,
    [20111] = 20,
    [20155] = 21,
    [30001] = 28,
    [30012] = 23,
    [30023] = 24,
    [30034] = 25,
    [30045] = 33,
    [30056] = 26,
    [30067] = 27,
    [30078] = 29,
    [30089] = 30,
    [30133] = 31,
    [30144] = 32,
    [40001] = 44,
    [40012] = 34,
    [40023] = 35,
    [40045] = 37,
    [40056] = 36,
    [40133] = 38,
    [40144] = 39,
    [40155] = 40,
    [40166] = 41,
    [40177] = 42,
    [40188] = 43,

}

local __key_map = {
  id = 1,
  group_id = 2,
  theme = 3,
  level = 4,
  ball_size = 5,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_theme_drop_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function theme_drop_info.getLength()
    return #theme_drop_info._data
end



function theme_drop_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_theme_drop_info
function theme_drop_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = theme_drop_info._data[index]}, m)
    
end

---
--@return @class record_theme_drop_info
function theme_drop_info.get(id)
    
    return theme_drop_info.indexOf(__index_id[id])
        
end



function theme_drop_info.set(id, key, value)
    local record = theme_drop_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function theme_drop_info.get_index_data()
    return __index_id
end