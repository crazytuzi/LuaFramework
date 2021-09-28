

---@classdef record_contest_arena_reward_info
local record_contest_arena_reward_info = {}
  
record_contest_arena_reward_info.id = 0 --id  
record_contest_arena_reward_info.rank_min = 0 --排名（下限）  
record_contest_arena_reward_info.rank_max = 0 --排名（上限）  
record_contest_arena_reward_info.win_reward = 0 --勋章数量（战斗胜利）  
record_contest_arena_reward_info.lose_reward = 0 --勋章数量（战斗失败）


contest_arena_reward_info = {
   _data = {
    [1] = {1,1,10,1000,500,},
    [2] = {2,11,50,900,450,},
    [3] = {3,51,300,800,400,},
    [4] = {4,301,1000,700,350,},
    [5] = {5,1001,9999,600,300,},
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
  rank_min = 2,
  rank_max = 3,
  win_reward = 4,
  lose_reward = 5,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_contest_arena_reward_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function contest_arena_reward_info.getLength()
    return #contest_arena_reward_info._data
end



function contest_arena_reward_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_contest_arena_reward_info
function contest_arena_reward_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = contest_arena_reward_info._data[index]}, m)
    
end

---
--@return @class record_contest_arena_reward_info
function contest_arena_reward_info.get(id)
    
    return contest_arena_reward_info.indexOf(__index_id[id])
        
end



function contest_arena_reward_info.set(id, key, value)
    local record = contest_arena_reward_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function contest_arena_reward_info.get_index_data()
    return __index_id
end