

---@classdef record_treasure_advance_info
local record_treasure_advance_info = {}
  
record_treasure_advance_info.id = 0 --编号  
record_treasure_advance_info.advance_level = 0 --精练阶数  
record_treasure_advance_info.cost_type_1 = 0 --消耗1类型  
record_treasure_advance_info.cost_value_1 = 0 --消耗1类型值  
record_treasure_advance_info.cost_num_1 = 0 --消耗1数量  
record_treasure_advance_info.cost_type_2 = 0 --消耗2类型  
record_treasure_advance_info.cost_value_2 = 0 --消耗2类型值  
record_treasure_advance_info.cost_num_2 = 0 --消耗2数量  
record_treasure_advance_info.cost_type_3 = 0 --消耗3类型  
record_treasure_advance_info.cost_value_3 = 0 --消耗3类型值  
record_treasure_advance_info.cost_num_3 = 0 --消耗3数量  
record_treasure_advance_info.recycle_price = 0 --精炼消耗银两（重生用）  
record_treasure_advance_info.recycle_jinglianshi = 0 --消耗宝物精炼石（重生用）  
record_treasure_advance_info.recycle_treasure = 0 --消耗同名宝物（重生用）


treasure_advance_info = {
   _data = {
    [1] = {1,1,1,0,30000,2,18,30,3,0,0,30000,30,0,},
    [2] = {2,2,1,0,60000,2,18,50,3,0,1,90000,80,1,},
    [3] = {3,3,1,0,120000,2,18,100,3,0,1,210000,180,2,},
    [4] = {4,4,1,0,200000,2,18,300,3,0,2,410000,480,4,},
    [5] = {5,5,1,0,300000,2,18,500,3,0,2,710000,980,6,},
    [6] = {6,6,1,0,400000,2,18,1000,3,0,2,1110000,1980,8,},
    [7] = {7,7,1,0,500000,2,18,1500,3,0,3,1610000,3480,11,},
    [8] = {8,8,1,0,650000,2,18,2000,3,0,5,2260000,5480,16,},
    [9] = {9,9,1,0,800000,2,18,3000,3,0,8,3060000,8480,24,},
    [10] = {10,10,1,0,1000000,2,18,4000,3,0,10,4060000,12480,34,},
    [11] = {11,11,1,0,1200000,2,18,5000,3,0,10,5260000,17480,44,},
    [12] = {12,12,1,0,1400000,2,18,6000,3,0,10,6660000,23480,54,},
    [13] = {13,13,1,0,1600000,2,18,7000,3,0,10,8260000,30480,64,},
    [14] = {14,14,1,0,1800000,2,18,8000,3,0,10,10060000,38480,74,},
    [15] = {15,15,1,0,2000000,2,18,9000,3,0,10,12060000,47480,84,},
    [16] = {16,16,1,0,2200000,2,18,10000,3,0,10,14260000,57480,94,},
    [17] = {17,17,1,0,2400000,2,18,11000,3,0,10,16660000,68480,104,},
    [18] = {18,18,1,0,2600000,2,18,12000,3,0,10,19260000,80480,114,},
    [19] = {19,19,1,0,2800000,2,18,13000,3,0,10,22060000,93480,124,},
    [20] = {20,20,1,0,3000000,2,18,14000,3,0,10,25060000,107480,134,},
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
  advance_level = 2,
  cost_type_1 = 3,
  cost_value_1 = 4,
  cost_num_1 = 5,
  cost_type_2 = 6,
  cost_value_2 = 7,
  cost_num_2 = 8,
  cost_type_3 = 9,
  cost_value_3 = 10,
  cost_num_3 = 11,
  recycle_price = 12,
  recycle_jinglianshi = 13,
  recycle_treasure = 14,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_treasure_advance_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function treasure_advance_info.getLength()
    return #treasure_advance_info._data
end



function treasure_advance_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_treasure_advance_info
function treasure_advance_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = treasure_advance_info._data[index]}, m)
    
end

---
--@return @class record_treasure_advance_info
function treasure_advance_info.get(id)
    
    return treasure_advance_info.indexOf(__index_id[id])
        
end



function treasure_advance_info.set(id, key, value)
    local record = treasure_advance_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function treasure_advance_info.get_index_data()
    return __index_id
end