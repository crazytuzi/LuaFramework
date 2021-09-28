

---@classdef record_days7_competition_info
local record_days7_competition_info = {}
  
record_days7_competition_info.id = 0 --id  
record_days7_competition_info.directions = "" --描述  
record_days7_competition_info.top_rank = "" --最高领奖名次  
record_days7_competition_info.bottom_rank = "" --最低领奖名次  
record_days7_competition_info.type_1 = 0 --奖励类型1  
record_days7_competition_info.value_1 = 0 --奖励类型值1  
record_days7_competition_info.size_1 = 0 --奖励数量1  
record_days7_competition_info.type_2 = 0 --奖励类型2  
record_days7_competition_info.value_2 = 0 --奖励类型值2  
record_days7_competition_info.size_2 = 0 --奖励数量2  
record_days7_competition_info.type_3 = 0 --奖励类型3  
record_days7_competition_info.value_3 = 0 --奖励类型值3  
record_days7_competition_info.size_3 = 0 --奖励数量3  
record_days7_competition_info.type_4 = 0 --奖励类型4  
record_days7_competition_info.value_4 = 0 --奖励类型值4  
record_days7_competition_info.size_4 = 0 --奖励数量4


days7_competition_info = {
   _data = {
    [1] = {1,"开服竞赛战力第1名奖励",1,1,3,14,1000,3,18,1000,3,13,300,1,0,5000000,},
    [2] = {2,"开服竞赛战力第2名奖励",2,2,3,14,800,3,18,800,3,13,250,1,0,4000000,},
    [3] = {3,"开服竞赛战力第3名奖励",3,3,3,14,600,3,18,600,3,13,200,1,0,3000000,},
    [4] = {4,"开服竞赛战力第4-5名奖励",4,5,3,14,500,3,18,500,3,13,180,1,0,2500000,},
    [5] = {5,"开服竞赛战力第6-10名奖励",6,10,3,14,400,3,18,400,3,13,160,1,0,2000000,},
    [6] = {6,"开服竞赛战力第11-15名奖励",11,15,3,14,350,3,18,350,3,13,150,1,0,1800000,},
    [7] = {7,"开服竞赛战力第16-20名奖励",16,20,3,14,300,3,18,300,3,13,140,1,0,1600000,},
    [8] = {8,"开服竞赛战力第21-30名奖励",21,30,3,14,250,3,18,250,3,13,130,1,0,1400000,},
    [9] = {9,"开服竞赛战力第31-40名奖励",31,40,3,14,200,3,18,200,3,13,120,1,0,1200000,},
    [10] = {10,"开服竞赛战力第41-50名奖励",41,50,3,14,150,3,18,150,3,13,100,1,0,1000000,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
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
  directions = 2,
  top_rank = 3,
  bottom_rank = 4,
  type_1 = 5,
  value_1 = 6,
  size_1 = 7,
  type_2 = 8,
  value_2 = 9,
  size_2 = 10,
  type_3 = 11,
  value_3 = 12,
  size_3 = 13,
  type_4 = 14,
  value_4 = 15,
  size_4 = 16,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_days7_competition_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function days7_competition_info.getLength()
    return #days7_competition_info._data
end



function days7_competition_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_days7_competition_info
function days7_competition_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = days7_competition_info._data[index]}, m)
    
end

---
--@return @class record_days7_competition_info
function days7_competition_info.get(id)
    
    return days7_competition_info.indexOf(__index_id[id])
        
end



function days7_competition_info.set(id, key, value)
    local record = days7_competition_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function days7_competition_info.get_index_data()
    return __index_id
end