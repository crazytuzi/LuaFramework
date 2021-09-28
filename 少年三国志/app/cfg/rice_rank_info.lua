

---@classdef record_rice_rank_info
local record_rice_rank_info = {}
  
record_rice_rank_info.rank = 0 --排行  
record_rice_rank_info.initial_num = 0 --初始粮草  
record_rice_rank_info.growth = 0 --粮草增长步长


rice_rank_info = {
   _data = {
    [1] = {1001,3000,0,},
    [2] = {501,3499,100,},
    [3] = {301,3888,200,},
    [4] = {201,4197,300,},
    [5] = {101,4596,400,},
    [6] = {51,4894,600,},
    [7] = {31,5090,1000,},
    [8] = {21,5235,1500,},
    [9] = {11,5430,2000,},
    [10] = {6,5570,3000,},
    [11] = {5,5600,0,},
    [12] = {4,5700,0,},
    [13] = {3,5800,0,},
    [14] = {2,5900,0,},
    [15] = {1,6000,0,},
    }
}



local __index_rank = {
    [1] = 15,
    [1001] = 1,
    [101] = 5,
    [11] = 9,
    [2] = 14,
    [201] = 4,
    [21] = 8,
    [3] = 13,
    [301] = 3,
    [31] = 7,
    [4] = 12,
    [5] = 11,
    [501] = 2,
    [51] = 6,
    [6] = 10,

}

local __key_map = {
  rank = 1,
  initial_num = 2,
  growth = 3,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_rice_rank_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function rice_rank_info.getLength()
    return #rice_rank_info._data
end



function rice_rank_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_rice_rank_info
function rice_rank_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = rice_rank_info._data[index]}, m)
    
end

---
--@return @class record_rice_rank_info
function rice_rank_info.get(rank)
    
    return rice_rank_info.indexOf(__index_rank[rank])
        
end



function rice_rank_info.set(rank, key, value)
    local record = rice_rank_info.get(rank)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function rice_rank_info.get_index_data()
    return __index_rank
end