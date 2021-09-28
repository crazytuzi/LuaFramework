

---@classdef record_app_return_value_info
local record_app_return_value_info = {}
  
record_app_return_value_info.id = 0 --ID  
record_app_return_value_info.player_level = 0 --老玩家等级  
record_app_return_value_info.player_time = 0 --老玩家判定时间  
record_app_return_value_info.start_time = 0 --活动开始时间  
record_app_return_value_info.end_time = 0 --活动结束时间  
record_app_return_value_info.vip_exp = 0 --最低返还VIP经验


app_return_value_info = {
   _data = {
    [1] = {1,60,1446307200,1449244800,1449439200,1000,},
    }
}



local __index_id = {
    [1] = 1,

}

local __key_map = {
  id = 1,
  player_level = 2,
  player_time = 3,
  start_time = 4,
  end_time = 5,
  vip_exp = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_app_return_value_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function app_return_value_info.getLength()
    return #app_return_value_info._data
end



function app_return_value_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_app_return_value_info
function app_return_value_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = app_return_value_info._data[index]}, m)
    
end

---
--@return @class record_app_return_value_info
function app_return_value_info.get(id)
    
    return app_return_value_info.indexOf(__index_id[id])
        
end



function app_return_value_info.set(id, key, value)
    local record = app_return_value_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function app_return_value_info.get_index_data()
    return __index_id
end