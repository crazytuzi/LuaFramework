

---@classdef record_corps_value_info
local record_corps_value_info = {}
  
record_corps_value_info.id = 0 --id  
record_corps_value_info.value = 0 --类型值


corps_value_info = {
   _data = {
    [1] = {1,500,},
    [2] = {2,5,},
    [3] = {3,6,},
    [4] = {4,2,},
    [5] = {5,20,},
    [6] = {6,40,},
    [7] = {7,86400,},
    [8] = {8,50,},
    [9] = {9,30,},
    [10] = {10,10,},
    [11] = {11,432000,},
    [12] = {12,604800,},
    [13] = {13,200,},
    [14] = {14,3,},
    [15] = {15,604800,},
    [16] = {16,4,},
    [17] = {17,15,},
    [18] = {18,200,},
    [19] = {19,200,},
    [20] = {20,20,},
    [21] = {21,60,},
    [22] = {22,20,},
    [23] = {23,200,},
    [24] = {24,30,},
    [25] = {25,10,},
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
  value = 2,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_corps_value_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function corps_value_info.getLength()
    return #corps_value_info._data
end



function corps_value_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_corps_value_info
function corps_value_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = corps_value_info._data[index]}, m)
    
end

---
--@return @class record_corps_value_info
function corps_value_info.get(id)
    
    return corps_value_info.indexOf(__index_id[id])
        
end



function corps_value_info.set(id, key, value)
    local record = corps_value_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function corps_value_info.get_index_data()
    return __index_id
end