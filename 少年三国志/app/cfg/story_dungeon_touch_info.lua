

---@classdef record_story_dungeon_touch_info
local record_story_dungeon_touch_info = {}
  
record_story_dungeon_touch_info.touch_type = 0 --触发条件  
record_story_dungeon_touch_info.barrier_id = 0 --关卡ID  
record_story_dungeon_touch_info.story_id = 0 --剧情ID


story_dungeon_touch_info = {
   _data = {
    [1] = {2,1,1,},
    [2] = {1,1,3,},
    [3] = {2,5,1,},
    [4] = {1,5,3,},
    [5] = {2,9,1,},
    [6] = {1,9,3,},
    [7] = {2,13,1,},
    [8] = {1,13,3,},
    [9] = {2,17,1,},
    [10] = {1,17,3,},
    [11] = {2,21,1,},
    [12] = {1,21,3,},
    [13] = {2,25,1,},
    [14] = {1,25,3,},
    [15] = {2,29,1,},
    [16] = {1,29,3,},
    [17] = {2,33,1,},
    [18] = {1,33,3,},
    [19] = {2,37,1,},
    [20] = {1,37,3,},
    [21] = {2,41,1,},
    [22] = {1,41,3,},
    }
}



local __index_touch_type_barrier_id = {
    ["1_1"] = 2,
    ["1_13"] = 8,
    ["1_17"] = 10,
    ["1_21"] = 12,
    ["1_25"] = 14,
    ["1_29"] = 16,
    ["1_33"] = 18,
    ["1_37"] = 20,
    ["1_41"] = 22,
    ["1_5"] = 4,
    ["1_9"] = 6,
    ["2_1"] = 1,
    ["2_13"] = 7,
    ["2_17"] = 9,
    ["2_21"] = 11,
    ["2_25"] = 13,
    ["2_29"] = 15,
    ["2_33"] = 17,
    ["2_37"] = 19,
    ["2_41"] = 21,
    ["2_5"] = 3,
    ["2_9"] = 5,

}

local __key_map = {
  touch_type = 1,
  barrier_id = 2,
  story_id = 3,

}



local m = { 
    __index = function(t, k) 
        assert(__key_map[k], "cannot find " .. k .. " in record_story_dungeon_touch_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function story_dungeon_touch_info.getLength()
    return #story_dungeon_touch_info._data
end



function story_dungeon_touch_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_story_dungeon_touch_info
function story_dungeon_touch_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = story_dungeon_touch_info._data[index]}, m)
    
end

---
--@return @class record_story_dungeon_touch_info
function story_dungeon_touch_info.get(touch_type,barrier_id)
    
    local k = touch_type .. '_' .. barrier_id
    return story_dungeon_touch_info.indexOf(__index_touch_type_barrier_id[k])
        
end



function story_dungeon_touch_info.set(touch_type,barrier_id, key, value)
    local record = story_dungeon_touch_info.get(touch_type,barrier_id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end