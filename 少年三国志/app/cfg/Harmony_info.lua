

---@classdef record_Harmony_info
local record_Harmony_info = {}
  
record_Harmony_info.id = 0 --武将ID  
record_Harmony_info.knightId1 = 0 --原武将ID  
record_Harmony_info.knightId2 = 0 --和谐版武将ID


Harmony_info = {
   _data = {
    [1] = {1,4,3,},
    [2] = {2,78,3,},
    [3] = {3,122,3,},
    [4] = {4,166,3,},
    [5] = {5,10188,10485,},
    [6] = {6,10430,20441,},
    [7] = {7,10463,10441,},
    [8] = {8,20133,20232,},
    [9] = {9,20144,50009,},
    [10] = {10,20199,40298,},
    [11] = {11,20243,20441,},
    [12] = {12,20254,40298,},
    [13] = {13,30111,20441,},
    [14] = {14,30122,30540,},
    [15] = {15,30133,10485,},
    [16] = {16,30144,20441,},
    [17] = {17,30397,40298,},
    [18] = {18,40023,10485,},
    [19] = {19,40034,20441,},
    [20] = {20,40452,30540,},
    [21] = {21,80009,20441,},
    [22] = {22,80010,40298,},
    [23] = {23,80028,20232,},
    [24] = {24,80029,50009,},
    [25] = {25,80032,20441,},
    [26] = {26,80033,30540,},
    [27] = {27,80036,20441,},
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
  knightId1 = 2,
  knightId2 = 3,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_Harmony_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function Harmony_info.getLength()
    return #Harmony_info._data
end



function Harmony_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_Harmony_info
function Harmony_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = Harmony_info._data[index]}, m)
    
end

---
--@return @class record_Harmony_info
function Harmony_info.get(id)
    
    return Harmony_info.indexOf(__index_id[id])
        
end



function Harmony_info.set(id, key, value)
    local record = Harmony_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function Harmony_info.get_index_data()
    return __index_id
end