

---@classdef record_contest_rank_award_info
local record_contest_rank_award_info = {}
  
record_contest_rank_award_info.id = 0 --id  
record_contest_rank_award_info.type = 0 --比赛类型  
record_contest_rank_award_info.rank_min = 0 --排名（下限）  
record_contest_rank_award_info.rank_max = 0 --排名（上限）  
record_contest_rank_award_info.title_type = 0 --称号奖励类型  
record_contest_rank_award_info.title_value = 0 --称号奖励ID  
record_contest_rank_award_info.title_size = 0 --称号数量  
record_contest_rank_award_info.title_id = 0 --称号ID  
record_contest_rank_award_info.award_type1 = 0 --奖励类型1  
record_contest_rank_award_info.award_value1 = 0 --物品ID1  
record_contest_rank_award_info.award_size1 = 0 --奖励数量1  
record_contest_rank_award_info.award_type2 = 0 --奖励类型2  
record_contest_rank_award_info.award_value2 = 0 --物品ID2  
record_contest_rank_award_info.award_size2 = 0 --奖励数量2


contest_rank_award_info = {
   _data = {
    [1] = {1,1,1,1,3,90,1,201,3,104,1,0,0,0,},
    [2] = {2,1,2,2,3,91,1,202,3,105,1,0,0,0,},
    [3] = {3,1,3,3,3,92,1,203,3,106,1,0,0,0,},
    [4] = {4,1,4,10,3,93,1,204,3,107,1,0,0,0,},
    [5] = {5,1,11,25,3,94,1,205,3,108,1,0,0,0,},
    [6] = {6,1,26,50,3,95,1,206,3,109,1,0,0,0,},
    [7] = {7,1,51,100,3,96,1,207,3,110,1,0,0,0,},
    [8] = {8,2,1,1,3,97,1,301,3,129,1,0,0,0,},
    [9] = {9,2,2,2,3,98,1,302,3,130,1,0,0,0,},
    [10] = {10,2,3,3,3,99,1,303,3,131,1,0,0,0,},
    [11] = {11,2,4,10,3,100,1,304,3,132,1,0,0,0,},
    [12] = {12,2,11,25,3,101,1,305,3,133,1,0,0,0,},
    [13] = {13,2,26,50,3,102,1,306,3,134,1,0,0,0,},
    [14] = {14,2,51,100,3,128,1,307,3,135,1,0,0,0,},
    [15] = {15,2,101,300,0,0,0,0,3,136,1,0,0,0,},
    [16] = {16,2,301,1000,0,0,0,0,3,137,1,0,0,0,},
    [17] = {17,2,1001,3000,0,0,0,0,3,138,1,0,0,0,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [12] = 12,
    [13] = 13,
    [14] = 14,
    [15] = 15,
    [16] = 16,
    [17] = 17,
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
  type = 2,
  rank_min = 3,
  rank_max = 4,
  title_type = 5,
  title_value = 6,
  title_size = 7,
  title_id = 8,
  award_type1 = 9,
  award_value1 = 10,
  award_size1 = 11,
  award_type2 = 12,
  award_value2 = 13,
  award_size2 = 14,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_contest_rank_award_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function contest_rank_award_info.getLength()
    return #contest_rank_award_info._data
end



function contest_rank_award_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_contest_rank_award_info
function contest_rank_award_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = contest_rank_award_info._data[index]}, m)
    
end

---
--@return @class record_contest_rank_award_info
function contest_rank_award_info.get(id)
    
    return contest_rank_award_info.indexOf(__index_id[id])
        
end



function contest_rank_award_info.set(id, key, value)
    local record = contest_rank_award_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function contest_rank_award_info.get_index_data()
    return __index_id
end