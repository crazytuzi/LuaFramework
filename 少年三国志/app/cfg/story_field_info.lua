

---@classdef record_story_field_info
local record_story_field_info = {}
  
record_story_field_info.id = 0 --编号  
record_story_field_info.name = "" --名称  
record_story_field_info.icon = 0 --图标信息  
record_story_field_info.position = 0 --客户端位置


story_field_info = {
   _data = {
    [1] = {1,"魏",0,1,},
    [2] = {2,"蜀",0,2,},
    [3] = {3,"吴",0,3,},
    [4] = {4,"群雄",0,4,},
    [5] = {5,"大事件",0,5,},
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
  name = 2,
  icon = 3,
  position = 4,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_story_field_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function story_field_info.getLength()
    return #story_field_info._data
end



function story_field_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_story_field_info
function story_field_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = story_field_info._data[index]}, m)
    
end

---
--@return @class record_story_field_info
function story_field_info.get(id)
    
    return story_field_info.indexOf(__index_id[id])
        
end



function story_field_info.set(id, key, value)
    local record = story_field_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function story_field_info.get_index_data()
    return __index_id
end