

---@classdef record_crosspvp_ground_info
local record_crosspvp_ground_info = {}
  
record_crosspvp_ground_info.id = 0 --id  
record_crosspvp_ground_info.name = "" --名称  
record_crosspvp_ground_info.arena_rank = 0 --竞技场排名限制


crosspvp_ground_info = {
   _data = {
    [1] = {1,"初级赛区",200,},
    [2] = {2,"中级赛区",150,},
    [3] = {3,"高级赛区",100,},
    [4] = {4,"至尊赛区",50,},
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
  name = 2,
  arena_rank = 3,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_crosspvp_ground_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function crosspvp_ground_info.getLength()
    return #crosspvp_ground_info._data
end



function crosspvp_ground_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_crosspvp_ground_info
function crosspvp_ground_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = crosspvp_ground_info._data[index]}, m)
    
end

---
--@return @class record_crosspvp_ground_info
function crosspvp_ground_info.get(id)
    
    return crosspvp_ground_info.indexOf(__index_id[id])
        
end



function crosspvp_ground_info.set(id, key, value)
    local record = crosspvp_ground_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function crosspvp_ground_info.get_index_data()
    return __index_id
end