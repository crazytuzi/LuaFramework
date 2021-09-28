

---@classdef record_rebel_boss_info
local record_rebel_boss_info = {}
  
record_rebel_boss_info.id = 0 --id  
record_rebel_boss_info.name = "" --boss名称  
record_rebel_boss_info.res_id = 0 --boss形象  
record_rebel_boss_info.knight_id_1 = 0 --1号武将id  
record_rebel_boss_info.knight_id_2 = 0 --2号武将id  
record_rebel_boss_info.knight_id_3 = 0 --3号武将id  
record_rebel_boss_info.knight_id_4 = 0 --4号武将id  
record_rebel_boss_info.knight_id_5 = 0 --5号武将id  
record_rebel_boss_info.knight_id_6 = 0 --6号武将id  
record_rebel_boss_info.attack_reward = 0 --每次攻击奖励战功  
record_rebel_boss_info.first_reward_type = 0 --首次攻击奖励类型  
record_rebel_boss_info.first_reward_value = 0 --首次攻击奖励类型值  
record_rebel_boss_info.first_reward_size = 0 --首次攻击奖励数量类型  
record_rebel_boss_info.kill_reward_type = 0 --击杀奖励类型  
record_rebel_boss_info.kill_reward_value = 0 --击杀奖励类型值  
record_rebel_boss_info.kill_reward_size = 0 --击杀奖励数量类型


rebel_boss_info = {
   _data = {
    [1] = {1,"暴走董卓",14016,3520,3521,3522,3523,3524,3525,200,2,0,1,3,60,2,},
    [2] = {2,"暴走董卓",14016,3520,3521,3522,3523,3524,3525,200,2,0,1,3,18,3,},
    [3] = {3,"暴走董卓",14016,3520,3521,3522,3523,3524,3525,200,2,0,1,3,14,4,},
    [4] = {4,"暴走董卓",14016,3520,3521,3522,3523,3524,3525,200,2,0,1,3,13,5,},
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
  res_id = 3,
  knight_id_1 = 4,
  knight_id_2 = 5,
  knight_id_3 = 6,
  knight_id_4 = 7,
  knight_id_5 = 8,
  knight_id_6 = 9,
  attack_reward = 10,
  first_reward_type = 11,
  first_reward_value = 12,
  first_reward_size = 13,
  kill_reward_type = 14,
  kill_reward_value = 15,
  kill_reward_size = 16,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_rebel_boss_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function rebel_boss_info.getLength()
    return #rebel_boss_info._data
end



function rebel_boss_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_rebel_boss_info
function rebel_boss_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = rebel_boss_info._data[index]}, m)
    
end

---
--@return @class record_rebel_boss_info
function rebel_boss_info.get(id)
    
    return rebel_boss_info.indexOf(__index_id[id])
        
end



function rebel_boss_info.set(id, key, value)
    local record = rebel_boss_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function rebel_boss_info.get_index_data()
    return __index_id
end