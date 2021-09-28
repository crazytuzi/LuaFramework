

---@classdef record_battlefield_award_info
local record_battlefield_award_info = {}
  
record_battlefield_award_info.id = 0 --ID  
record_battlefield_award_info.award_type = 0 --关卡宝箱ID  
record_battlefield_award_info.level = 0 --玩家等级  
record_battlefield_award_info.drop_id1 = 0 --第1次开箱子  
record_battlefield_award_info.drop_id2 = 0 --第2次开箱子  
record_battlefield_award_info.drop_id3 = 0 --第3次开箱子  
record_battlefield_award_info.drop_id4 = 0 --第4次开箱子  
record_battlefield_award_info.drop_id5 = 0 --第5次开箱子


battlefield_award_info = {
   _data = {
    [1] = {101,1,0,901,905,905,905,905,},
    [2] = {201,2,0,902,906,906,906,906,},
    [3] = {301,3,0,903,907,907,907,907,},
    [4] = {401,4,0,904,908,908,908,908,},
    }
}



local __index_id = {
    [101] = 1,
    [201] = 2,
    [301] = 3,
    [401] = 4,

}

local __key_map = {
  id = 1,
  award_type = 2,
  level = 3,
  drop_id1 = 4,
  drop_id2 = 5,
  drop_id3 = 6,
  drop_id4 = 7,
  drop_id5 = 8,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_battlefield_award_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function battlefield_award_info.getLength()
    return #battlefield_award_info._data
end



function battlefield_award_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_battlefield_award_info
function battlefield_award_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = battlefield_award_info._data[index]}, m)
    
end

---
--@return @class record_battlefield_award_info
function battlefield_award_info.get(id)
    
    return battlefield_award_info.indexOf(__index_id[id])
        
end



function battlefield_award_info.set(id, key, value)
    local record = battlefield_award_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function battlefield_award_info.get_index_data()
    return __index_id
end