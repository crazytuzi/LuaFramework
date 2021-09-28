

---@classdef record_story_fight_info
local record_story_fight_info = {}
  
record_story_fight_info.id = 0 --剧情战斗ID  
record_story_fight_info.dungeon_id = 0 --副本ID  
record_story_fight_info.npc1_id = 0 --1号位剧情武将ID  
record_story_fight_info.npc2_id = 0 --2号位剧情武将ID  
record_story_fight_info.npc3_id = 0 --3号位剧情武将ID  
record_story_fight_info.npc4_id = 0 --4号位剧情武将ID  
record_story_fight_info.npc5_id = 0 --5号位剧情武将ID  
record_story_fight_info.npc6_id = 0 --6号位剧情武将ID


story_fight_info = {
   _data = {
    [1] = {1,1,0,10019,99,10020,10020,0,},
    }
}



local __index_id = {
    [1] = 1,

}

local __key_map = {
  id = 1,
  dungeon_id = 2,
  npc1_id = 3,
  npc2_id = 4,
  npc3_id = 5,
  npc4_id = 6,
  npc5_id = 7,
  npc6_id = 8,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_story_fight_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function story_fight_info.getLength()
    return #story_fight_info._data
end



function story_fight_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_story_fight_info
function story_fight_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = story_fight_info._data[index]}, m)
    
end

---
--@return @class record_story_fight_info
function story_fight_info.get(id)
    
    return story_fight_info.indexOf(__index_id[id])
        
end



function story_fight_info.set(id, key, value)
    local record = story_fight_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function story_fight_info.get_index_data()
    return __index_id
end