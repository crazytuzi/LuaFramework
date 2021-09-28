

---@classdef record_crosspvp_fight_info
local record_crosspvp_fight_info = {}
  
record_crosspvp_fight_info.id = 0 --id  
record_crosspvp_fight_info.name = "" --名称  
record_crosspvp_fight_info.quality = 0 --品质  
record_crosspvp_fight_info.icon = 0 --icon  
record_crosspvp_fight_info.score = 0 --攻占积分  
record_crosspvp_fight_info.per_score = 0 --每3秒获得积分  
record_crosspvp_fight_info.max_time = 0 --最长占领时间


crosspvp_fight_info = {
   _data = {
    [1] = {1,"绿帅旗",2,1,50,9,60,},
    [2] = {2,"蓝帅旗",3,2,60,11,60,},
    [3] = {3,"紫帅旗",4,3,70,13,60,},
    [4] = {4,"橙帅旗",5,4,80,15,60,},
    [5] = {5,"红帅旗",6,5,90,17,60,},
    [6] = {6,"金帅旗",7,6,100,19,60,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,

}

local __key_map = {
  id = 1,
  name = 2,
  quality = 3,
  icon = 4,
  score = 5,
  per_score = 6,
  max_time = 7,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_crosspvp_fight_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function crosspvp_fight_info.getLength()
    return #crosspvp_fight_info._data
end



function crosspvp_fight_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_crosspvp_fight_info
function crosspvp_fight_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = crosspvp_fight_info._data[index]}, m)
    
end

---
--@return @class record_crosspvp_fight_info
function crosspvp_fight_info.get(id)
    
    return crosspvp_fight_info.indexOf(__index_id[id])
        
end



function crosspvp_fight_info.set(id, key, value)
    local record = crosspvp_fight_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function crosspvp_fight_info.get_index_data()
    return __index_id
end