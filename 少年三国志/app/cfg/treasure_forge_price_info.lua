

---@classdef record_treasure_forge_price_info
local record_treasure_forge_price_info = {}
  
record_treasure_forge_price_info.id = 0 --id  
record_treasure_forge_price_info.type = 0 --类型  
record_treasure_forge_price_info.advance_level = 0 --精炼阶数  
record_treasure_forge_price_info.price = 0 --花费元宝


treasure_forge_price_info = {
   _data = {
    [1] = {1,1,0,550,},
    [2] = {2,1,1,550,},
    [3] = {3,1,2,1100,},
    [4] = {4,1,3,1650,},
    [5] = {5,1,4,2750,},
    [6] = {6,1,5,3850,},
    [7] = {7,1,6,4950,},
    [8] = {8,1,7,6600,},
    [9] = {9,1,8,9350,},
    [10] = {10,1,9,13750,},
    [11] = {11,1,10,19250,},
    [12] = {12,1,11,24750,},
    [13] = {13,1,12,30250,},
    [14] = {14,1,13,35750,},
    [15] = {15,1,14,41250,},
    [16] = {16,1,15,46750,},
    [17] = {17,1,16,52250,},
    [18] = {18,1,17,57750,},
    [19] = {19,1,18,63250,},
    [20] = {20,1,19,68750,},
    [21] = {21,1,20,74250,},
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
  type = 2,
  advance_level = 3,
  price = 4,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_treasure_forge_price_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function treasure_forge_price_info.getLength()
    return #treasure_forge_price_info._data
end



function treasure_forge_price_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_treasure_forge_price_info
function treasure_forge_price_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = treasure_forge_price_info._data[index]}, m)
    
end

---
--@return @class record_treasure_forge_price_info
function treasure_forge_price_info.get(id)
    
    return treasure_forge_price_info.indexOf(__index_id[id])
        
end



function treasure_forge_price_info.set(id, key, value)
    local record = treasure_forge_price_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function treasure_forge_price_info.get_index_data()
    return __index_id
end