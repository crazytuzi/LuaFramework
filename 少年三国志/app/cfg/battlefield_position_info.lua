

---@classdef record_battlefield_position_info
local record_battlefield_position_info = {}
  
record_battlefield_position_info.id = 0 --格子ID  
record_battlefield_position_info.award_key = 0 --是否为宝藏的前置关卡  
record_battlefield_position_info.prepose_id1 = "" --前置关卡ID1  
record_battlefield_position_info.prepose_id2 = "" --前置关卡ID2  
record_battlefield_position_info.prepose_id3 = "" --前置关卡ID3  
record_battlefield_position_info.prepose_id4 = "" --前置关卡ID4


battlefield_position_info = {
   _data = {
    [1] = {1,0,0,0,0,0,},
    [2] = {2,0,0,0,0,0,},
    [3] = {3,0,0,0,0,0,},
    [4] = {4,0,1,5,7,7,},
    [5] = {5,0,2,4,6,8,},
    [6] = {6,0,3,5,9,9,},
    [7] = {7,0,4,8,10,10,},
    [8] = {8,0,5,7,9,11,},
    [9] = {9,0,6,8,12,12,},
    [10] = {10,1,7,11,7,11,},
    [11] = {11,1,8,10,12,12,},
    [12] = {12,1,9,11,9,11,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [12] = 12,
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
  award_key = 2,
  prepose_id1 = 3,
  prepose_id2 = 4,
  prepose_id3 = 5,
  prepose_id4 = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_battlefield_position_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function battlefield_position_info.getLength()
    return #battlefield_position_info._data
end



function battlefield_position_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_battlefield_position_info
function battlefield_position_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = battlefield_position_info._data[index]}, m)
    
end

---
--@return @class record_battlefield_position_info
function battlefield_position_info.get(id)
    
    return battlefield_position_info.indexOf(__index_id[id])
        
end



function battlefield_position_info.set(id, key, value)
    local record = battlefield_position_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function battlefield_position_info.get_index_data()
    return __index_id
end