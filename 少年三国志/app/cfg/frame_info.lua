

---@classdef record_frame_info
local record_frame_info = {}
  
record_frame_info.id = 0 --头像框ID  
record_frame_info.type = 0 --类型  
record_frame_info.vip_level = 0 --解锁等级  
record_frame_info.name = "" --头像框名称  
record_frame_info.res_id = 0 --资源ID  
record_frame_info.directions = "" --描述


frame_info = {
   _data = {
    [1] = {1001,1,1,"VIP1头像框",1001,"VIP等级达到1级时可以使用。",},
    [2] = {1002,1,5,"VIP5头像框",1002,"VIP等级达到5级时可以使用。",},
    [3] = {1003,1,8,"VIP8头像框",1003,"VIP等级达到8级时可以使用。",},
    [4] = {1004,1,10,"VIP10头像框",1004,"VIP等级达到10级时可以使用。",},
    [5] = {1005,1,12,"VIP12头像框",1005,"VIP等级达到12级时可以使用。",},
    }
}



local __index_id = {
    [1001] = 1,
    [1002] = 2,
    [1003] = 3,
    [1004] = 4,
    [1005] = 5,

}

local __key_map = {
  id = 1,
  type = 2,
  vip_level = 3,
  name = 4,
  res_id = 5,
  directions = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_frame_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function frame_info.getLength()
    return #frame_info._data
end



function frame_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_frame_info
function frame_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = frame_info._data[index]}, m)
    
end

---
--@return @class record_frame_info
function frame_info.get(id)
    
    return frame_info.indexOf(__index_id[id])
        
end



function frame_info.set(id, key, value)
    local record = frame_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function frame_info.get_index_data()
    return __index_id
end