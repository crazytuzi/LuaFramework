

---@classdef record_crosspvp_value_info
local record_crosspvp_value_info = {}
  
record_crosspvp_value_info.id = 0 --id  
record_crosspvp_value_info.value = 0 --类型值


crosspvp_value_info = {
   _data = {
    [1] = {1,100,},
    [2] = {2,200,},
    [3] = {3,60,},
    [4] = {4,10,},
    [5] = {5,10,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_crosspvp_value_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function crosspvp_value_info.getLength()
    return #crosspvp_value_info._data
end



function crosspvp_value_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_crosspvp_value_info
function crosspvp_value_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = crosspvp_value_info._data[index]}, m)
    
end

---
--@return @class record_crosspvp_value_info
function crosspvp_value_info.get(id)
    
    return crosspvp_value_info.indexOf(__index_id[id])
        
end



function crosspvp_value_info.set(id, key, value)
    local record = crosspvp_value_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function crosspvp_value_info.get_index_data()
    return __index_id
end