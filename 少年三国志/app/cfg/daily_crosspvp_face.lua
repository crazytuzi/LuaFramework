

---@classdef record_daily_crosspvp_face
local record_daily_crosspvp_face = {}
  
record_daily_crosspvp_face.id = 0 --编号  
record_daily_crosspvp_face.win_lose = 0 --是否优势  
record_daily_crosspvp_face.face_id = 0 --表情id


daily_crosspvp_face = {
   _data = {
    [1] = {1,1,1,},
    [2] = {2,1,2,},
    [3] = {3,1,3,},
    [4] = {4,1,4,},
    [5] = {5,1,5,},
    [6] = {6,1,6,},
    [7] = {7,1,8,},
    [8] = {8,1,9,},
    [9] = {9,1,10,},
    [10] = {10,1,11,},
    [11] = {11,1,12,},
    [12] = {12,1,17,},
    [13] = {13,1,20,},
    [14] = {14,1,29,},
    [15] = {15,1,31,},
    [16] = {16,1,32,},
    [17] = {17,1,35,},
    [18] = {18,1,44,},
    [19] = {19,1,46,},
    [20] = {20,1,49,},
    [21] = {21,1,52,},
    [22] = {22,1,53,},
    [23] = {23,0,7,},
    [24] = {24,0,13,},
    [25] = {25,0,14,},
    [26] = {26,0,15,},
    [27] = {27,0,16,},
    [28] = {28,0,18,},
    [29] = {29,0,19,},
    [30] = {30,0,21,},
    [31] = {31,0,22,},
    [32] = {32,0,23,},
    [33] = {33,0,24,},
    [34] = {34,0,25,},
    [35] = {35,0,26,},
    [36] = {36,0,27,},
    [37] = {37,0,28,},
    [38] = {38,0,33,},
    [39] = {39,0,34,},
    [40] = {40,0,38,},
    [41] = {41,0,40,},
    [42] = {42,0,43,},
    [43] = {43,0,47,},
    [44] = {44,0,50,},
    [45] = {45,0,51,},
    [46] = {46,0,54,},
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
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  win_lose = 2,
  face_id = 3,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_daily_crosspvp_face")
        
        
        return t._raw[__key_map[k]]
    end
}


function daily_crosspvp_face.getLength()
    return #daily_crosspvp_face._data
end



function daily_crosspvp_face.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_daily_crosspvp_face
function daily_crosspvp_face.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = daily_crosspvp_face._data[index]}, m)
    
end

---
--@return @class record_daily_crosspvp_face
function daily_crosspvp_face.get(id)
    
    return daily_crosspvp_face.indexOf(__index_id[id])
        
end



function daily_crosspvp_face.set(id, key, value)
    local record = daily_crosspvp_face.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function daily_crosspvp_face.get_index_data()
    return __index_id
end