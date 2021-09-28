

---@classdef record_dungeon_allstar_info
local record_dungeon_allstar_info = {}
  
record_dungeon_allstar_info.id = 0 --ID  
record_dungeon_allstar_info.allstar_num = 0 --副本总星数  
record_dungeon_allstar_info.item_id = 0 --奖励掉落库ID  
record_dungeon_allstar_info.item_num = "" --数量


dungeon_allstar_info = {
   _data = {
    [1] = {1,3,1,1,},
    [2] = {2,9,1,1,},
    [3] = {3,13,1,1,},
    [4] = {4,21,1,1,},
    [5] = {5,27,1,1,},
    [6] = {6,39,1,1,},
    [7] = {7,47,1,1,},
    [8] = {8,63,1,1,},
    [9] = {9,73,1,1,},
    [10] = {10,93,1,1,},
    [11] = {11,103,1,1,},
    [12] = {12,123,1,1,},
    [13] = {13,133,1,1,},
    [14] = {14,153,1,1,},
    [15] = {15,163,1,1,},
    [16] = {16,183,1,1,},
    [17] = {17,193,1,1,},
    [18] = {18,213,1,1,},
    [19] = {19,223,1,1,},
    [20] = {20,243,1,1,},
    [21] = {21,253,1,1,},
    [22] = {22,273,1,1,},
    [23] = {23,283,1,1,},
    [24] = {24,303,1,1,},
    [25] = {25,313,1,1,},
    [26] = {26,333,1,1,},
    [27] = {27,343,1,1,},
    [28] = {28,363,1,1,},
    [29] = {29,373,1,1,},
    [30] = {30,393,1,1,},
    [31] = {31,403,1,1,},
    [32] = {32,423,1,1,},
    [33] = {33,433,1,1,},
    [34] = {34,453,1,1,},
    [35] = {35,463,1,1,},
    [36] = {36,483,1,1,},
    [37] = {37,493,1,1,},
    [38] = {38,513,1,1,},
    [39] = {39,523,1,1,},
    [40] = {40,543,1,1,},
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
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  allstar_num = 2,
  item_id = 3,
  item_num = 4,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_dungeon_allstar_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function dungeon_allstar_info.getLength()
    return #dungeon_allstar_info._data
end



function dungeon_allstar_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_dungeon_allstar_info
function dungeon_allstar_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = dungeon_allstar_info._data[index]}, m)
    
end

---
--@return @class record_dungeon_allstar_info
function dungeon_allstar_info.get(id)
    
    return dungeon_allstar_info.indexOf(__index_id[id])
        
end



function dungeon_allstar_info.set(id, key, value)
    local record = dungeon_allstar_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function dungeon_allstar_info.get_index_data()
    return __index_id
end