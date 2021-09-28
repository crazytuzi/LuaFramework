

---@classdef record_corps_fight_buff_info
local record_corps_fight_buff_info = {}
  
record_corps_fight_buff_info.id = 0 --id  
record_corps_fight_buff_info.icon = 0 --icon  
record_corps_fight_buff_info.skill_id = 0 --技能id  
record_corps_fight_buff_info.probability = 0 --鼓舞成功概率  
record_corps_fight_buff_info.max = 0 --鼓舞上限次数  
record_corps_fight_buff_info.gold = 0 --鼓舞元宝系数  
record_corps_fight_buff_info.number = 0 --单人可鼓舞次数


corps_fight_buff_info = {
   _data = {
    [1] = {1,1,4001,500,50,10,10,},
    [2] = {2,2,4002,500,50,10,10,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,

}

local __key_map = {
  id = 1,
  icon = 2,
  skill_id = 3,
  probability = 4,
  max = 5,
  gold = 6,
  number = 7,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_corps_fight_buff_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function corps_fight_buff_info.getLength()
    return #corps_fight_buff_info._data
end



function corps_fight_buff_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_corps_fight_buff_info
function corps_fight_buff_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = corps_fight_buff_info._data[index]}, m)
    
end

---
--@return @class record_corps_fight_buff_info
function corps_fight_buff_info.get(id)
    
    return corps_fight_buff_info.indexOf(__index_id[id])
        
end



function corps_fight_buff_info.set(id, key, value)
    local record = corps_fight_buff_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function corps_fight_buff_info.get_index_data()
    return __index_id
end