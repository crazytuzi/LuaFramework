

---@classdef record_corps_dungeon_rank_info
local record_corps_dungeon_rank_info = {}
  
record_corps_dungeon_rank_info.id = 0 --id  
record_corps_dungeon_rank_info.rank_min = 0 --排名  
record_corps_dungeon_rank_info.rank_max = 0 --排名  
record_corps_dungeon_rank_info.award_type = 0 --奖励类型  
record_corps_dungeon_rank_info.award_value = 0 --物品ID  
record_corps_dungeon_rank_info.award_size = 0 --奖励数量


corps_dungeon_rank_info = {
   _data = {
    [1] = {1,1,1,20,0,1000,},
    [2] = {2,2,5,20,0,800,},
    [3] = {3,6,10,20,0,700,},
    [4] = {4,11,20,20,0,600,},
    [5] = {5,21,30,20,0,500,},
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
  award_type = 4,
  award_value = 5,
  award_size = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_corps_dungeon_rank_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function corps_dungeon_rank_info.getLength()
    return #corps_dungeon_rank_info._data
end



function corps_dungeon_rank_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_corps_dungeon_rank_info
function corps_dungeon_rank_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = corps_dungeon_rank_info._data[index]}, m)
    
end

---
--@return @class record_corps_dungeon_rank_info
function corps_dungeon_rank_info.get(id)
    
    return corps_dungeon_rank_info.indexOf(__index_id[id])
        
end



function corps_dungeon_rank_info.set(id, key, value)
    local record = corps_dungeon_rank_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function corps_dungeon_rank_info.get_index_data()
    return __index_id
end