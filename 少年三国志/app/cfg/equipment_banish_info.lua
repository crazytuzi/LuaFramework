

---@classdef record_equipment_banish_info
local record_equipment_banish_info = {}
  
record_equipment_banish_info.id = 0 --id  
record_equipment_banish_info.equipment_id = 0 --装备ID  
record_equipment_banish_info.score = 0 --返还闯关积分  
record_equipment_banish_info.extra_type = 0 --额外type  
record_equipment_banish_info.extra_value = 0 --额外value  
record_equipment_banish_info.extra_size = 0 --额外size


equipment_banish_info = {
   _data = {
    [1] = {1,1001,80,0,0,0,},
    [2] = {2,1002,80,0,0,0,},
    [3] = {3,1003,80,0,0,0,},
    [4] = {4,1004,80,0,0,0,},
    [5] = {5,2001,1000,0,0,0,},
    [6] = {6,2002,1000,0,0,0,},
    [7] = {7,2003,1000,0,0,0,},
    [8] = {8,2004,1000,0,0,0,},
    [9] = {9,2011,1000,0,0,0,},
    [10] = {10,2012,1000,0,0,0,},
    [11] = {11,2013,1000,0,0,0,},
    [12] = {12,2014,1000,0,0,0,},
    [13] = {13,3001,5000,0,0,0,},
    [14] = {14,3002,5000,0,0,0,},
    [15] = {15,3003,5000,0,0,0,},
    [16] = {16,3004,5000,0,0,0,},
    [17] = {17,3011,5000,0,0,0,},
    [18] = {18,3012,5000,0,0,0,},
    [19] = {19,3013,5000,0,0,0,},
    [20] = {20,3014,5000,0,0,0,},
    [21] = {21,3021,5000,0,0,0,},
    [22] = {22,3022,5000,0,0,0,},
    [23] = {23,3023,5000,0,0,0,},
    [24] = {24,3024,5000,0,0,0,},
    [25] = {25,4001,20000,0,0,0,},
    [26] = {26,4002,20000,0,0,0,},
    [27] = {27,4003,20000,0,0,0,},
    [28] = {28,4004,20000,0,0,0,},
    [29] = {29,4011,20000,0,0,0,},
    [30] = {30,4012,20000,0,0,0,},
    [31] = {31,4013,20000,0,0,0,},
    [32] = {32,4014,20000,0,0,0,},
    [33] = {33,4021,20000,0,0,0,},
    [34] = {34,4022,20000,0,0,0,},
    [35] = {35,4023,20000,0,0,0,},
    [36] = {36,4024,20000,0,0,0,},
    [37] = {37,5001,30000,3,81,40,},
    [38] = {38,5002,30000,3,81,40,},
    [39] = {39,5003,30000,3,81,40,},
    [40] = {40,5004,30000,3,81,40,},
    [41] = {41,6001,50000,0,0,0,},
    [42] = {42,6002,50000,0,0,0,},
    [43] = {43,6003,50000,0,0,0,},
    [44] = {44,6004,50000,0,0,0,},
    [45] = {45,7001,50000,0,0,0,},
    [46] = {46,7002,50000,0,0,0,},
    [47] = {47,7003,50000,0,0,0,},
    [48] = {48,7004,50000,0,0,0,},
    [49] = {49,7011,50000,0,0,0,},
    [50] = {50,7012,50000,0,0,0,},
    [51] = {51,7013,50000,0,0,0,},
    [52] = {52,7014,50000,0,0,0,},
    [53] = {53,7021,50000,0,0,0,},
    [54] = {54,7022,50000,0,0,0,},
    [55] = {55,7023,50000,0,0,0,},
    [56] = {56,7024,50000,0,0,0,},
    [57] = {57,7031,50000,0,0,0,},
    [58] = {58,7032,50000,0,0,0,},
    [59] = {59,7033,50000,0,0,0,},
    [60] = {60,7034,50000,0,0,0,},
    [61] = {61,7041,50000,0,0,0,},
    [62] = {62,7042,50000,0,0,0,},
    [63] = {63,7043,50000,0,0,0,},
    [64] = {64,7044,50000,0,0,0,},
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
    [37] = 37,
    [38] = 38,
    [39] = 39,
    [4] = 4,
    [40] = 40,
    [41] = 41,
    [42] = 42,
    [43] = 43,
    [44] = 44,
    [45] = 45,
    [46] = 46,
    [47] = 47,
    [48] = 48,
    [49] = 49,
    [5] = 5,
    [50] = 50,
    [51] = 51,
    [52] = 52,
    [53] = 53,
    [54] = 54,
    [55] = 55,
    [56] = 56,
    [57] = 57,
    [58] = 58,
    [59] = 59,
    [6] = 6,
    [60] = 60,
    [61] = 61,
    [62] = 62,
    [63] = 63,
    [64] = 64,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  equipment_id = 2,
  score = 3,
  extra_type = 4,
  extra_value = 5,
  extra_size = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_equipment_banish_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function equipment_banish_info.getLength()
    return #equipment_banish_info._data
end



function equipment_banish_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_equipment_banish_info
function equipment_banish_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = equipment_banish_info._data[index]}, m)
    
end

---
--@return @class record_equipment_banish_info
function equipment_banish_info.get(id)
    
    return equipment_banish_info.indexOf(__index_id[id])
        
end



function equipment_banish_info.set(id, key, value)
    local record = equipment_banish_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function equipment_banish_info.get_index_data()
    return __index_id
end