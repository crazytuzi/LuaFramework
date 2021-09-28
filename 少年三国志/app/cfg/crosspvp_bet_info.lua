

---@classdef record_crosspvp_bet_info
local record_crosspvp_bet_info = {}
  
record_crosspvp_bet_info.id = 0 --id  
record_crosspvp_bet_info.name = "" --名称  
record_crosspvp_bet_info.buff_type = 0 --属性加成类型  
record_crosspvp_bet_info.buff1 = 0 --鼓舞buff1  
record_crosspvp_bet_info.buff2 = 0 --鼓舞buff2  
record_crosspvp_bet_info.price = 0 --花费元宝


crosspvp_bet_info = {
   _data = {
    [1] = {1,"鲜花",0,4503,4504,30,},
    [2] = {2,"鸡蛋",1,4505,4506,30,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,

}

local __key_map = {
  id = 1,
  name = 2,
  buff_type = 3,
  buff1 = 4,
  buff2 = 5,
  price = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_crosspvp_bet_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function crosspvp_bet_info.getLength()
    return #crosspvp_bet_info._data
end



function crosspvp_bet_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_crosspvp_bet_info
function crosspvp_bet_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = crosspvp_bet_info._data[index]}, m)
    
end

---
--@return @class record_crosspvp_bet_info
function crosspvp_bet_info.get(id)
    
    return crosspvp_bet_info.indexOf(__index_id[id])
        
end



function crosspvp_bet_info.set(id, key, value)
    local record = crosspvp_bet_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function crosspvp_bet_info.get_index_data()
    return __index_id
end