

---@classdef record_task_icon_info
local record_task_icon_info = {}
  
record_task_icon_info.id = 0 --活动类型  
record_task_icon_info.icon = 0 --icon路径


task_icon_info = {
   _data = {
    [1] = {1,1020,},
    [2] = {2,1040,},
    [3] = {3,1030,},
    [4] = {4,1010,},
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
  icon = 2,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_task_icon_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function task_icon_info.getLength()
    return #task_icon_info._data
end



function task_icon_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_task_icon_info
function task_icon_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = task_icon_info._data[index]}, m)
    
end

---
--@return @class record_task_icon_info
function task_icon_info.get(id)
    
    return task_icon_info.indexOf(__index_id[id])
        
end



function task_icon_info.set(id, key, value)
    local record = task_icon_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function task_icon_info.get_index_data()
    return __index_id
end