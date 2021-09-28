

---@classdef record_bullet_screen_config
local record_bullet_screen_config = {}
  
record_bullet_screen_config.id = 0 --id  
record_bullet_screen_config.comment = "" --预设弹幕


bullet_screen_config = {
   _data = {
    [1] = {1,"老子天下第一",},
    [2] = {2,"踢我下来那个给我等着",},
    [3] = {3,"30秒后又是一条好汉",},
    [4] = {4,"这场赢定了",},
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
  comment = 2,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_bullet_screen_config")
        
        
        return t._raw[__key_map[k]]
    end
}


function bullet_screen_config.getLength()
    return #bullet_screen_config._data
end



function bullet_screen_config.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_bullet_screen_config
function bullet_screen_config.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = bullet_screen_config._data[index]}, m)
    
end

---
--@return @class record_bullet_screen_config
function bullet_screen_config.get(id)
    
    return bullet_screen_config.indexOf(__index_id[id])
        
end



function bullet_screen_config.set(id, key, value)
    local record = bullet_screen_config.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function bullet_screen_config.get_index_data()
    return __index_id
end