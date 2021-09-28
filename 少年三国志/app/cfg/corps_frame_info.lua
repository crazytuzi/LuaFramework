

---@classdef record_corps_frame_info
local record_corps_frame_info = {}
  
record_corps_frame_info.id = 0 --id  
record_corps_frame_info.name = "" --名称  
record_corps_frame_info.frame_id = 0 --边框  
record_corps_frame_info.type = 0 --开启类型  
record_corps_frame_info.value = 0 --开启类型值  
record_corps_frame_info.tips = "" --未开启描述


corps_frame_info = {
   _data = {
    [1] = {1,"普通边框",1,1,0,"0",},
    [2] = {2,"新手军团",2,2,2,"军团等级到达2级可以使用",},
    [3] = {3,"精英军团",3,2,5,"军团等级到达5级可以使用",},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,

}

local __key_map = {
  id = 1,
  name = 2,
  frame_id = 3,
  type = 4,
  value = 5,
  tips = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_corps_frame_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function corps_frame_info.getLength()
    return #corps_frame_info._data
end



function corps_frame_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_corps_frame_info
function corps_frame_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = corps_frame_info._data[index]}, m)
    
end

---
--@return @class record_corps_frame_info
function corps_frame_info.get(id)
    
    return corps_frame_info.indexOf(__index_id[id])
        
end



function corps_frame_info.set(id, key, value)
    local record = corps_frame_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function corps_frame_info.get_index_data()
    return __index_id
end