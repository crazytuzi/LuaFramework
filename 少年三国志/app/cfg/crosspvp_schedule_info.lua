

---@classdef record_crosspvp_schedule_info
local record_crosspvp_schedule_info = {}
  
record_crosspvp_schedule_info.id = 0 --id  
record_crosspvp_schedule_info.name = "" --名称  
record_crosspvp_schedule_info.short_name = "" --简写名称  
record_crosspvp_schedule_info.num = 0 --总晋级人数  
record_crosspvp_schedule_info.room = 0 --房间数  
record_crosspvp_schedule_info.bet = 0 --是否有投注  
record_crosspvp_schedule_info.rank_num = 0 --房间晋级人数


crosspvp_schedule_info = {
   _data = {
    [1] = {1,"海选赛","海选",1024,64,0,16,},
    [2] = {2,"复赛","复赛",256,16,0,16,},
    [3] = {3,"64强晋级赛","64强",64,4,0,16,},
    [4] = {4,"16强晋级赛","16强",16,1,1,16,},
    [5] = {5,"4强晋级赛","4强",4,1,1,4,},
    [6] = {6,"决赛","决赛",4,1,1,4,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,

}

local __key_map = {
  id = 1,
  name = 2,
  short_name = 3,
  num = 4,
  room = 5,
  bet = 6,
  rank_num = 7,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_crosspvp_schedule_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function crosspvp_schedule_info.getLength()
    return #crosspvp_schedule_info._data
end



function crosspvp_schedule_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_crosspvp_schedule_info
function crosspvp_schedule_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = crosspvp_schedule_info._data[index]}, m)
    
end

---
--@return @class record_crosspvp_schedule_info
function crosspvp_schedule_info.get(id)
    
    return crosspvp_schedule_info.indexOf(__index_id[id])
        
end



function crosspvp_schedule_info.set(id, key, value)
    local record = crosspvp_schedule_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function crosspvp_schedule_info.get_index_data()
    return __index_id
end