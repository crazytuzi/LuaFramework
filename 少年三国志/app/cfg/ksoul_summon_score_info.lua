

---@classdef record_ksoul_summon_score_info
local record_ksoul_summon_score_info = {}
  
record_ksoul_summon_score_info.id = 0 --id  
record_ksoul_summon_score_info.summon_score = 0 --奇遇点  
record_ksoul_summon_score_info.probability = 0 --概率


ksoul_summon_score_info = {
   _data = {
    [1] = {1,25,300,},
    [2] = {2,50,550,},
    [3] = {3,100,150,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,

}

local __key_map = {
  id = 1,
  summon_score = 2,
  probability = 3,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_ksoul_summon_score_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function ksoul_summon_score_info.getLength()
    return #ksoul_summon_score_info._data
end



function ksoul_summon_score_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_ksoul_summon_score_info
function ksoul_summon_score_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = ksoul_summon_score_info._data[index]}, m)
    
end

---
--@return @class record_ksoul_summon_score_info
function ksoul_summon_score_info.get(id)
    
    return ksoul_summon_score_info.indexOf(__index_id[id])
        
end



function ksoul_summon_score_info.set(id, key, value)
    local record = ksoul_summon_score_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function ksoul_summon_score_info.get_index_data()
    return __index_id
end