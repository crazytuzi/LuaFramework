

---@classdef record_dead_battle_buff_info
local record_dead_battle_buff_info = {}
  
record_dead_battle_buff_info.id = 0 --id  
record_dead_battle_buff_info.type = 0 --类型  
record_dead_battle_buff_info.star = 0 --消耗星数  
record_dead_battle_buff_info.skill_id = 0 --关联被动技能id


dead_battle_buff_info = {
   _data = {
    [1] = {1,1,3,2002,},
    [2] = {2,1,3,2003,},
    [3] = {3,1,3,2004,},
    [4] = {4,1,3,2005,},
    [5] = {5,1,3,2006,},
    [6] = {6,1,3,2007,},
    [7] = {7,1,3,2008,},
    [8] = {1,2,6,2102,},
    [9] = {2,2,6,2103,},
    [10] = {3,2,6,2104,},
    [11] = {4,2,6,2105,},
    [12] = {5,2,6,2106,},
    [13] = {6,2,6,2107,},
    [14] = {7,2,6,2108,},
    [15] = {1,3,9,2202,},
    [16] = {2,3,9,2203,},
    [17] = {3,3,9,2204,},
    [18] = {4,3,9,2205,},
    [19] = {5,3,9,2206,},
    [20] = {6,3,9,2207,},
    [21] = {7,3,9,2208,},
    }
}



local __index_id_type = {
    ["1_1"] = 1,
    ["1_2"] = 8,
    ["1_3"] = 15,
    ["2_1"] = 2,
    ["2_2"] = 9,
    ["2_3"] = 16,
    ["3_1"] = 3,
    ["3_2"] = 10,
    ["3_3"] = 17,
    ["4_1"] = 4,
    ["4_2"] = 11,
    ["4_3"] = 18,
    ["5_1"] = 5,
    ["5_2"] = 12,
    ["5_3"] = 19,
    ["6_1"] = 6,
    ["6_2"] = 13,
    ["6_3"] = 20,
    ["7_1"] = 7,
    ["7_2"] = 14,
    ["7_3"] = 21,

}

local __key_map = {
  id = 1,
  type = 2,
  star = 3,
  skill_id = 4,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_dead_battle_buff_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function dead_battle_buff_info.getLength()
    return #dead_battle_buff_info._data
end



function dead_battle_buff_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_dead_battle_buff_info
function dead_battle_buff_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = dead_battle_buff_info._data[index]}, m)
    
end

---
--@return @class record_dead_battle_buff_info
function dead_battle_buff_info.get(id,type)
    
    local k = id .. '_' .. type
    return dead_battle_buff_info.indexOf(__index_id_type[k])
        
end



function dead_battle_buff_info.set(id,type, key, value)
    local record = dead_battle_buff_info.get(id,type)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function dead_battle_buff_info.get_index_data()
    return __index_id_type
end