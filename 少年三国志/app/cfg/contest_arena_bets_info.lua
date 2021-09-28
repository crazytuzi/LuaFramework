

---@classdef record_contest_arena_bets_info
local record_contest_arena_bets_info = {}
  
record_contest_arena_bets_info.id = 0 --id  
record_contest_arena_bets_info.name = "" --名称  
record_contest_arena_bets_info.number = 0 --猜中人数  
record_contest_arena_bets_info.bonus = 0 --奖金池比例（千分比）  
record_contest_arena_bets_info.max_award = 0 --奖金池收益上限（勋章）  
record_contest_arena_bets_info.base_award = 0 --每注基础收益（勋章）


contest_arena_bets_info = {
   _data = {
    [1] = {1,"特等奖",10,600,1500,500,},
    [2] = {2,"一等奖",9,300,800,400,},
    [3] = {3,"二等奖",8,100,450,350,},
    [4] = {4,"三等奖",7,0,0,300,},
    [5] = {5,"三等奖",6,0,0,300,},
    [6] = {6,"四等奖",5,0,0,250,},
    [7] = {7,"四等奖",4,0,0,250,},
    [8] = {8,"五等奖",3,0,0,200,},
    [9] = {9,"五等奖",2,0,0,200,},
    [10] = {10,"鼓励奖",1,0,0,120,},
    [11] = {11,"鼓励奖",0,0,0,120,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  name = 2,
  number = 3,
  bonus = 4,
  max_award = 5,
  base_award = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_contest_arena_bets_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function contest_arena_bets_info.getLength()
    return #contest_arena_bets_info._data
end



function contest_arena_bets_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_contest_arena_bets_info
function contest_arena_bets_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = contest_arena_bets_info._data[index]}, m)
    
end

---
--@return @class record_contest_arena_bets_info
function contest_arena_bets_info.get(id)
    
    return contest_arena_bets_info.indexOf(__index_id[id])
        
end



function contest_arena_bets_info.set(id, key, value)
    local record = contest_arena_bets_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function contest_arena_bets_info.get_index_data()
    return __index_id
end