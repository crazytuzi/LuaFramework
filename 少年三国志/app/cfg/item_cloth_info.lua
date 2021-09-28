

---@classdef record_item_cloth_info
local record_item_cloth_info = {}
  
record_item_cloth_info.id = 0 --换装id  
record_item_cloth_info.res_id = 0 --资源id  
record_item_cloth_info.time = 0 --持续时间


item_cloth_info = {
   _data = {
    [1] = {1,60001,600,},
    [2] = {2,60002,180,},
    [3] = {3,10100,604800,},
    [4] = {4,10062,604800,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,

}

local __key_map = {
  id = 1,
  res_id = 2,
  time = 3,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_item_cloth_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function item_cloth_info.getLength()
    return #item_cloth_info._data
end



function item_cloth_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_item_cloth_info
function item_cloth_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = item_cloth_info._data[index]}, m)
    
end

---
--@return @class record_item_cloth_info
function item_cloth_info.get(id)
    
    return item_cloth_info.indexOf(__index_id[id])
        
end



function item_cloth_info.set(id, key, value)
    local record = item_cloth_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function item_cloth_info.get_index_data()
    return __index_id
end