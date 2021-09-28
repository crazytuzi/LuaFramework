

---@classdef record_contest_value_info
local record_contest_value_info = {}
  
record_contest_value_info.id = 0 --id  
record_contest_value_info.value = 0 --类型值


contest_value_info = {
   _data = {
    [1] = {1,10,},
    [2] = {2,8,},
    [3] = {3,15,},
    [4] = {4,9,},
    [5] = {5,30,},
    [6] = {6,30,},
    [7] = {7,140,},
    [8] = {8,140,},
    [9] = {9,120,},
    [10] = {10,120,},
    [11] = {11,100,},
    [12] = {12,100,},
    [13] = {13,35,},
    [14] = {14,5,},
    [15] = {15,70,},
    [16] = {16,70,},
    [17] = {17,60,},
    [18] = {18,60,},
    [19] = {19,50,},
    [20] = {20,50,},
    [21] = {21,10,},
    [22] = {22,14,},
    [23] = {23,100,},
    [24] = {24,15,},
    [25] = {25,50,},
    [26] = {26,20,},
    [27] = {27,100,},
    [28] = {28,50,},
    [29] = {29,300,},
    [30] = {30,150,},
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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_contest_value_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function contest_value_info.getLength()
    return #contest_value_info._data
end



function contest_value_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_contest_value_info
function contest_value_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = contest_value_info._data[index]}, m)
    
end

---
--@return @class record_contest_value_info
function contest_value_info.get(id)
    
    return contest_value_info.indexOf(__index_id[id])
        
end



function contest_value_info.set(id, key, value)
    local record = contest_value_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function contest_value_info.get_index_data()
    return __index_id
end