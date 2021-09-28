

---@classdef record_fortune_box_info
local record_fortune_box_info = {}
  
record_fortune_box_info.id = 0 --ID  
record_fortune_box_info.time = 0 --需要次数  
record_fortune_box_info.type_1 = 0 --奖励类型1  
record_fortune_box_info.value_1 = 0 --奖励类型值1  
record_fortune_box_info.size_1 = 0 --奖励数量1  
record_fortune_box_info.type_2 = 0 --奖励类型2  
record_fortune_box_info.value_2 = 0 --奖励类型值2  
record_fortune_box_info.size_2 = 0 --奖励数量2


fortune_box_info = {
   _data = {
    [1] = {1,10,2,0,80,3,5,1,},
    [2] = {2,20,2,0,150,3,5,3,},
    [3] = {3,30,2,0,200,3,5,5,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,

}

local __key_map = {
  id = 1,
  time = 2,
  type_1 = 3,
  value_1 = 4,
  size_1 = 5,
  type_2 = 6,
  value_2 = 7,
  size_2 = 8,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_fortune_box_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function fortune_box_info.getLength()
    return #fortune_box_info._data
end



function fortune_box_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_fortune_box_info
function fortune_box_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = fortune_box_info._data[index]}, m)
    
end

---
--@return @class record_fortune_box_info
function fortune_box_info.get(id)
    
    return fortune_box_info.indexOf(__index_id[id])
        
end



function fortune_box_info.set(id, key, value)
    local record = fortune_box_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function fortune_box_info.get_index_data()
    return __index_id
end