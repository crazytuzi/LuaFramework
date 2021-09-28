

---@classdef record_dead_battle_boss_number_info
local record_dead_battle_boss_number_info = {}
  
record_dead_battle_boss_number_info.id = 0 --编号  
record_dead_battle_boss_number_info.num = 0 --次数  
record_dead_battle_boss_number_info.cost = 0 --花费元宝  
record_dead_battle_boss_number_info.vip_level = 0 --VIP限制


dead_battle_boss_number_info = {
   _data = {
    [1] = {1,1,30,0,},
    [2] = {2,2,40,0,},
    [3] = {3,3,50,0,},
    [4] = {4,4,60,1,},
    [5] = {5,5,70,1,},
    [6] = {6,6,80,2,},
    [7] = {7,7,100,2,},
    [8] = {8,8,100,3,},
    [9] = {9,9,100,3,},
    [10] = {10,10,150,4,},
    [11] = {11,11,150,4,},
    [12] = {12,12,150,5,},
    [13] = {13,13,180,5,},
    [14] = {14,14,180,6,},
    [15] = {15,15,180,6,},
    [16] = {16,16,280,7,},
    [17] = {17,17,280,7,},
    [18] = {18,18,280,8,},
    [19] = {19,19,350,8,},
    [20] = {20,20,350,8,},
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
  num = 2,
  cost = 3,
  vip_level = 4,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_dead_battle_boss_number_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function dead_battle_boss_number_info.getLength()
    return #dead_battle_boss_number_info._data
end



function dead_battle_boss_number_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_dead_battle_boss_number_info
function dead_battle_boss_number_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = dead_battle_boss_number_info._data[index]}, m)
    
end

---
--@return @class record_dead_battle_boss_number_info
function dead_battle_boss_number_info.get(id)
    
    return dead_battle_boss_number_info.indexOf(__index_id[id])
        
end



function dead_battle_boss_number_info.set(id, key, value)
    local record = dead_battle_boss_number_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function dead_battle_boss_number_info.get_index_data()
    return __index_id
end