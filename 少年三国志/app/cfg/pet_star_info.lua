

---@classdef record_pet_star_info
local record_pet_star_info = {}
  
record_pet_star_info.quality = 0 --品质  
record_pet_star_info.star_level = 0 --星数  
record_pet_star_info.level_ban = 0 --等级限制  
record_pet_star_info.cost_fragment = 0 --消耗碎片数量  
record_pet_star_info.cost_type = 0 --消耗道具类型  
record_pet_star_info.cost_value = 0 --消耗道具值  
record_pet_star_info.cost_size = 0 --消耗道具数量  
record_pet_star_info.cost_money = 0 --消耗银两


pet_star_info = {
   _data = {
    [1] = {1,0,0,999,3,204,99999,999999999,},
    [2] = {1,1,20,999,3,204,99999,999999999,},
    [3] = {1,2,40,999,3,204,99999,999999999,},
    [4] = {1,3,60,999,3,204,99999,999999999,},
    [5] = {1,4,80,999,3,204,99999,999999999,},
    [6] = {1,5,100,0,3,204,0,0,},
    [7] = {2,0,0,999,3,204,99999,999999999,},
    [8] = {2,1,20,999,3,204,99999,999999999,},
    [9] = {2,2,40,999,3,204,99999,999999999,},
    [10] = {2,3,60,999,3,204,99999,999999999,},
    [11] = {2,4,80,999,3,204,99999,999999999,},
    [12] = {2,5,100,0,3,204,0,0,},
    [13] = {3,0,0,10,3,204,200,400000,},
    [14] = {3,1,20,15,3,204,350,700000,},
    [15] = {3,2,40,25,3,204,550,1100000,},
    [16] = {3,3,60,35,3,204,800,1600000,},
    [17] = {3,4,80,50,3,204,1200,2400000,},
    [18] = {3,5,100,0,3,204,0,0,},
    [19] = {4,0,0,20,3,204,600,1200000,},
    [20] = {4,1,20,30,3,204,1000,2000000,},
    [21] = {4,2,40,50,3,204,1500,3000000,},
    [22] = {4,3,60,70,3,204,2500,5000000,},
    [23] = {4,4,80,100,3,204,3200,6400000,},
    [24] = {4,5,100,0,3,204,0,0,},
    [25] = {5,0,0,30,3,204,1200,2400000,},
    [26] = {5,1,20,45,3,204,2000,4000000,},
    [27] = {5,2,40,75,3,204,3500,7000000,},
    [28] = {5,3,60,105,3,204,4500,9000000,},
    [29] = {5,4,80,150,3,204,6500,13000000,},
    [30] = {5,5,100,0,3,204,0,0,},
    [31] = {6,0,0,40,3,204,2000,4000000,},
    [32] = {6,1,20,60,3,204,3500,7000000,},
    [33] = {6,2,40,100,3,204,5500,11000000,},
    [34] = {6,3,60,140,3,204,7500,15000000,},
    [35] = {6,4,80,200,3,204,12000,24000000,},
    [36] = {6,5,100,0,3,204,0,0,},
    [37] = {7,0,0,50,3,204,3000,5000000,},
    [38] = {7,1,20,70,3,204,4000,10000000,},
    [39] = {7,2,40,120,3,204,6000,15000000,},
    [40] = {7,3,60,180,3,204,9000,20000000,},
    [41] = {7,4,80,240,3,204,15000,30000000,},
    [42] = {7,5,100,0,3,204,0,0,},
    }
}



local __index_star_level_quality = {
    ["0_1"] = 1,
    ["0_2"] = 7,
    ["0_3"] = 13,
    ["0_4"] = 19,
    ["0_5"] = 25,
    ["0_6"] = 31,
    ["0_7"] = 37,
    ["1_1"] = 2,
    ["1_2"] = 8,
    ["1_3"] = 14,
    ["1_4"] = 20,
    ["1_5"] = 26,
    ["1_6"] = 32,
    ["1_7"] = 38,
    ["2_1"] = 3,
    ["2_2"] = 9,
    ["2_3"] = 15,
    ["2_4"] = 21,
    ["2_5"] = 27,
    ["2_6"] = 33,
    ["2_7"] = 39,
    ["3_1"] = 4,
    ["3_2"] = 10,
    ["3_3"] = 16,
    ["3_4"] = 22,
    ["3_5"] = 28,
    ["3_6"] = 34,
    ["3_7"] = 40,
    ["4_1"] = 5,
    ["4_2"] = 11,
    ["4_3"] = 17,
    ["4_4"] = 23,
    ["4_5"] = 29,
    ["4_6"] = 35,
    ["4_7"] = 41,
    ["5_1"] = 6,
    ["5_2"] = 12,
    ["5_3"] = 18,
    ["5_4"] = 24,
    ["5_5"] = 30,
    ["5_6"] = 36,
    ["5_7"] = 42,

}

local __key_map = {
  quality = 1,
  star_level = 2,
  level_ban = 3,
  cost_fragment = 4,
  cost_type = 5,
  cost_value = 6,
  cost_size = 7,
  cost_money = 8,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_pet_star_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function pet_star_info.getLength()
    return #pet_star_info._data
end



function pet_star_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_pet_star_info
function pet_star_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = pet_star_info._data[index]}, m)
    
end

---
--@return @class record_pet_star_info
function pet_star_info.get(star_level,quality)
    
    local k = star_level .. '_' .. quality
    return pet_star_info.indexOf(__index_star_level_quality[k])
        
end



function pet_star_info.set(star_level,quality, key, value)
    local record = pet_star_info.get(star_level,quality)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function pet_star_info.get_index_data()
    return __index_star_level_quality
end