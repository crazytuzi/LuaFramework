

---@classdef record_function_stage_info
local record_function_stage_info = {}
  
record_function_stage_info.id = 0 --id  
record_function_stage_info.chapter_id = 0 --章节id  
record_function_stage_info.stage_id = 0 --关卡id  
record_function_stage_info.guideStartId = 0 --新手引导步数


function_stage_info = {
   _data = {
    [1] = {1,2,10,601,},
    [2] = {2,4,31,1101,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,

}

local __key_map = {
  id = 1,
  chapter_id = 2,
  stage_id = 3,
  guideStartId = 4,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_function_stage_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function function_stage_info.getLength()
    return #function_stage_info._data
end



function function_stage_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_function_stage_info
function function_stage_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = function_stage_info._data[index]}, m)
    
end

---
--@return @class record_function_stage_info
function function_stage_info.get(id)
    
    return function_stage_info.indexOf(__index_id[id])
        
end



function function_stage_info.set(id, key, value)
    local record = function_stage_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function function_stage_info.get_index_data()
    return __index_id
end