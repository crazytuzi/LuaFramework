

---@classdef record_richman_prize_info
local record_richman_prize_info = {}
  
record_richman_prize_info.id = 0 --ID  
record_richman_prize_info.turn = 0 --规定圈数  
record_richman_prize_info.type = 0 --奖励类型  
record_richman_prize_info.value = 0 --奖励类型值  
record_richman_prize_info.size = 0 --奖励数量


richman_prize_info = {
   _data = {
    [1] = {1,1,3,13,2,},
    [2] = {2,3,3,14,20,},
    [3] = {3,5,3,18,10,},
    [4] = {4,7,3,60,20,},
    [5] = {5,10,3,87,2,},
    [6] = {6,15,3,3,2,},
    [7] = {7,20,3,81,2,},
    [8] = {8,25,3,13,5,},
    [9] = {9,35,3,14,60,},
    [10] = {10,50,3,18,40,},
    [11] = {11,65,3,60,60,},
    [12] = {12,80,3,87,5,},
    [13] = {13,100,3,3,5,},
    [14] = {14,120,3,81,5,},
    [15] = {15,140,3,13,15,},
    [16] = {16,160,3,14,100,},
    [17] = {17,180,3,3,10,},
    [18] = {18,200,3,81,10,},
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
    [2] = 2,
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
  turn = 2,
  type = 3,
  value = 4,
  size = 5,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_richman_prize_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function richman_prize_info.getLength()
    return #richman_prize_info._data
end



function richman_prize_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_richman_prize_info
function richman_prize_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = richman_prize_info._data[index]}, m)
    
end

---
--@return @class record_richman_prize_info
function richman_prize_info.get(id)
    
    return richman_prize_info.indexOf(__index_id[id])
        
end



function richman_prize_info.set(id, key, value)
    local record = richman_prize_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function richman_prize_info.get_index_data()
    return __index_id
end