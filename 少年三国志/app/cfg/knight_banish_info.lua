

---@classdef record_knight_banish_info
local record_knight_banish_info = {}
  
record_knight_banish_info.id = 0 --编号  
record_knight_banish_info.type = 0 --参数类型  
record_knight_banish_info.type_value = 0 --类型值  
record_knight_banish_info.essence = 0 --精魄参数  
record_knight_banish_info.extra_type = 0 --额外type  
record_knight_banish_info.extra_value = 0 --额外value  
record_knight_banish_info.extra_size = 0 --额外size


knight_banish_info = {
   _data = {
    [1] = {1,1,0,1,0,0,1,},
    [2] = {2,1,1,1,0,0,1,},
    [3] = {3,1,2,1,0,0,1,},
    [4] = {4,1,3,1,0,0,1,},
    [5] = {5,1,4,2,0,0,2,},
    [6] = {6,1,5,3,0,0,3,},
    [7] = {7,1,6,5,0,0,5,},
    [8] = {8,1,7,7,0,0,7,},
    [9] = {9,1,8,11,0,0,11,},
    [10] = {10,1,9,15,0,0,15,},
    [11] = {11,1,10,21,0,0,21,},
    [12] = {12,2,1,10,0,0,0,},
    [13] = {13,2,2,40,0,0,0,},
    [14] = {14,2,3,400,0,0,0,},
    [15] = {15,2,4,1000,0,0,0,},
    [16] = {16,2,5,2000,3,3,30,},
    [17] = {17,1,11,29,0,0,29,},
    [18] = {18,1,12,39,0,0,39,},
    [19] = {19,1,13,49,0,0,49,},
    [20] = {20,1,14,59,0,0,59,},
    [21] = {21,1,15,74,0,0,74,},
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
  type_value = 3,
  essence = 4,
  extra_type = 5,
  extra_value = 6,
  extra_size = 7,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_knight_banish_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function knight_banish_info.getLength()
    return #knight_banish_info._data
end



function knight_banish_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_knight_banish_info
function knight_banish_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = knight_banish_info._data[index]}, m)
    
end

---
--@return @class record_knight_banish_info
function knight_banish_info.get(id)
    
    return knight_banish_info.indexOf(__index_id[id])
        
end



function knight_banish_info.set(id, key, value)
    local record = knight_banish_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function knight_banish_info.get_index_data()
    return __index_id
end