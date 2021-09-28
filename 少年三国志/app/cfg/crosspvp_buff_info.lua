

---@classdef record_crosspvp_buff_info
local record_crosspvp_buff_info = {}
  
record_crosspvp_buff_info.id = 0 --id  
record_crosspvp_buff_info.icon = 0 --icon  
record_crosspvp_buff_info.buff_id = 0 --技能id  
record_crosspvp_buff_info.buff_num = 0 --鼓舞上限次数  
record_crosspvp_buff_info.price = 0 --鼓舞花费元宝


crosspvp_buff_info = {
   _data = {
    [1] = {1,1,4501,10,30,},
    [2] = {2,2,4502,10,30,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,

}

local __key_map = {
  id = 1,
  icon = 2,
  buff_id = 3,
  buff_num = 4,
  price = 5,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_crosspvp_buff_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function crosspvp_buff_info.getLength()
    return #crosspvp_buff_info._data
end



function crosspvp_buff_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_crosspvp_buff_info
function crosspvp_buff_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = crosspvp_buff_info._data[index]}, m)
    
end

---
--@return @class record_crosspvp_buff_info
function crosspvp_buff_info.get(id)
    
    return crosspvp_buff_info.indexOf(__index_id[id])
        
end



function crosspvp_buff_info.set(id, key, value)
    local record = crosspvp_buff_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function crosspvp_buff_info.get_index_data()
    return __index_id
end