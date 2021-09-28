

---@classdef record_rebel_boss_attack_reward_info
local record_rebel_boss_attack_reward_info = {}
  
record_rebel_boss_attack_reward_info.id = 0 --ID  
record_rebel_boss_attack_reward_info.name = "" --名字  
record_rebel_boss_attack_reward_info.quality = 0 --名字品质  
record_rebel_boss_attack_reward_info.attack_reward = 0 --每次攻击奖励战功  
record_rebel_boss_attack_reward_info.probability = 0 --概率


rebel_boss_attack_reward_info = {
   _data = {
    [1] = {1,"0",0,300,5000,},
    [2] = {2,"(大暴击)",4,150,3000,},
    [3] = {3,"(幸运暴击)",5,200,2000,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,

}

local __key_map = {
  id = 1,
  name = 2,
  quality = 3,
  attack_reward = 4,
  probability = 5,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_rebel_boss_attack_reward_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function rebel_boss_attack_reward_info.getLength()
    return #rebel_boss_attack_reward_info._data
end



function rebel_boss_attack_reward_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_rebel_boss_attack_reward_info
function rebel_boss_attack_reward_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = rebel_boss_attack_reward_info._data[index]}, m)
    
end

---
--@return @class record_rebel_boss_attack_reward_info
function rebel_boss_attack_reward_info.get(id)
    
    return rebel_boss_attack_reward_info.indexOf(__index_id[id])
        
end



function rebel_boss_attack_reward_info.set(id, key, value)
    local record = rebel_boss_attack_reward_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function rebel_boss_attack_reward_info.get_index_data()
    return __index_id
end