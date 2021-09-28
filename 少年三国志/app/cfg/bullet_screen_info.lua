

---@classdef record_bullet_screen_info
local record_bullet_screen_info = {}
  
record_bullet_screen_info.id = 0 --id  
record_bullet_screen_info.system_id = "" --弹幕库所属系统  
record_bullet_screen_info.cold_time = 0 --冷却cd  
record_bullet_screen_info.cost_1 = "" --普通花费  
record_bullet_screen_info.cost_2 = 0 --高亮花费


bullet_screen_info = {
   _data = {
    [1] = {1,1,20,20,50,},
    }
}



local __index_id = {
    [1] = 1,

}

local __key_map = {
  id = 1,
  system_id = 2,
  cold_time = 3,
  cost_1 = 4,
  cost_2 = 5,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_bullet_screen_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function bullet_screen_info.getLength()
    return #bullet_screen_info._data
end



function bullet_screen_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_bullet_screen_info
function bullet_screen_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = bullet_screen_info._data[index]}, m)
    
end

---
--@return @class record_bullet_screen_info
function bullet_screen_info.get(id)
    
    return bullet_screen_info.indexOf(__index_id[id])
        
end



function bullet_screen_info.set(id, key, value)
    local record = bullet_screen_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function bullet_screen_info.get_index_data()
    return __index_id
end