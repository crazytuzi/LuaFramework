

---@classdef record_rebel_boss_corps_info
local record_rebel_boss_corps_info = {}
  
record_rebel_boss_corps_info.id = 0 --id  
record_rebel_boss_corps_info.rank = 0 --军团排名  
record_rebel_boss_corps_info.name = "" --名称  
record_rebel_boss_corps_info.award_type1 = 0 --奖励类型1  
record_rebel_boss_corps_info.award_value1 = 0 --奖励ID1  
record_rebel_boss_corps_info.award_size1 = 0 --奖励数量1


rebel_boss_corps_info = {
   _data = {
    [1] = {1,1,"军团总荣誉第1名",3,151,1,},
    [2] = {2,2,"军团总荣誉第2名",3,152,1,},
    [3] = {3,3,"军团总荣誉第3名",3,153,1,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,

}

local __key_map = {
  id = 1,
  rank = 2,
  name = 3,
  award_type1 = 4,
  award_value1 = 5,
  award_size1 = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_rebel_boss_corps_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function rebel_boss_corps_info.getLength()
    return #rebel_boss_corps_info._data
end



function rebel_boss_corps_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_rebel_boss_corps_info
function rebel_boss_corps_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = rebel_boss_corps_info._data[index]}, m)
    
end

---
--@return @class record_rebel_boss_corps_info
function rebel_boss_corps_info.get(id)
    
    return rebel_boss_corps_info.indexOf(__index_id[id])
        
end



function rebel_boss_corps_info.set(id, key, value)
    local record = rebel_boss_corps_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function rebel_boss_corps_info.get_index_data()
    return __index_id
end