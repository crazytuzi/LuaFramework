

---@classdef record_rebel_boss_rank_info
local record_rebel_boss_rank_info = {}
  
record_rebel_boss_rank_info.id = 0 --id  
record_rebel_boss_rank_info.type = 0 --排行类型  
record_rebel_boss_rank_info.rank_min = 0 --排名（下限）  
record_rebel_boss_rank_info.rank_max = 0 --排名（上限）  
record_rebel_boss_rank_info.award_type1 = 0 --奖励类型1  
record_rebel_boss_rank_info.award_value1 = 0 --奖励ID1  
record_rebel_boss_rank_info.award_size1 = 0 --奖励数量1  
record_rebel_boss_rank_info.award_type2 = 0 --奖励类型2  
record_rebel_boss_rank_info.award_value2 = 0 --奖励ID2  
record_rebel_boss_rank_info.award_size2 = 0 --奖励数量2  
record_rebel_boss_rank_info.award_type3 = 0 --奖励类型3  
record_rebel_boss_rank_info.award_value3 = 0 --奖励ID3  
record_rebel_boss_rank_info.award_size3 = 0 --奖励数量3


rebel_boss_rank_info = {
   _data = {
    [1] = {101,1,1,1,15,0,8000,3,13,200,0,0,0,},
    [2] = {102,1,2,2,15,0,7000,3,13,160,0,0,0,},
    [3] = {103,1,3,3,15,0,6000,3,13,120,0,0,0,},
    [4] = {104,1,4,4,15,0,5500,3,13,100,0,0,0,},
    [5] = {105,1,5,5,15,0,5000,3,13,95,0,0,0,},
    [6] = {106,1,6,6,15,0,4700,3,13,90,0,0,0,},
    [7] = {107,1,7,7,15,0,4400,3,13,85,0,0,0,},
    [8] = {108,1,8,8,15,0,4100,3,13,80,0,0,0,},
    [9] = {109,1,9,9,15,0,3800,3,13,75,0,0,0,},
    [10] = {110,1,10,10,15,0,3600,3,13,70,0,0,0,},
    [11] = {111,1,11,11,15,0,3400,3,13,65,0,0,0,},
    [12] = {112,1,12,12,15,0,3200,3,13,60,0,0,0,},
    [13] = {113,1,13,13,15,0,3000,3,13,55,0,0,0,},
    [14] = {114,1,14,14,15,0,2800,3,13,50,0,0,0,},
    [15] = {115,1,15,15,15,0,2600,3,13,45,0,0,0,},
    [16] = {116,1,16,16,15,0,2400,3,13,40,0,0,0,},
    [17] = {117,1,17,17,15,0,2300,3,13,35,0,0,0,},
    [18] = {118,1,18,18,15,0,2200,3,13,30,0,0,0,},
    [19] = {119,1,19,19,15,0,2100,3,13,25,0,0,0,},
    [20] = {120,1,20,20,15,0,2000,3,13,20,0,0,0,},
    [21] = {201,2,1,1,15,0,6000,3,14,200,0,0,0,},
    [22] = {202,2,2,2,15,0,5500,3,14,160,0,0,0,},
    [23] = {203,2,3,3,15,0,5000,3,14,120,0,0,0,},
    [24] = {204,2,4,4,15,0,4500,3,14,100,0,0,0,},
    [25] = {205,2,5,5,15,0,4000,3,14,95,0,0,0,},
    [26] = {206,2,6,6,15,0,3800,3,14,90,0,0,0,},
    [27] = {207,2,7,7,15,0,3600,3,14,85,0,0,0,},
    [28] = {208,2,8,8,15,0,3400,3,14,80,0,0,0,},
    [29] = {209,2,9,9,15,0,3200,3,14,75,0,0,0,},
    [30] = {210,2,10,10,15,0,3000,3,14,70,0,0,0,},
    [31] = {211,2,11,11,15,0,2800,3,14,65,0,0,0,},
    [32] = {212,2,12,12,15,0,2600,3,14,60,0,0,0,},
    [33] = {213,2,13,13,15,0,2400,3,14,55,0,0,0,},
    [34] = {214,2,14,14,15,0,2200,3,14,50,0,0,0,},
    [35] = {215,2,15,15,15,0,2000,3,14,45,0,0,0,},
    [36] = {216,2,16,16,15,0,1900,3,14,40,0,0,0,},
    [37] = {217,2,17,17,15,0,1800,3,14,35,0,0,0,},
    [38] = {218,2,18,18,15,0,1700,3,14,30,0,0,0,},
    [39] = {219,2,19,19,15,0,1600,3,14,25,0,0,0,},
    [40] = {220,2,20,20,15,0,1500,3,14,20,0,0,0,},
    }
}



local __index_id = {
    [101] = 1,
    [102] = 2,
    [103] = 3,
    [104] = 4,
    [105] = 5,
    [106] = 6,
    [107] = 7,
    [108] = 8,
    [109] = 9,
    [110] = 10,
    [111] = 11,
    [112] = 12,
    [113] = 13,
    [114] = 14,
    [115] = 15,
    [116] = 16,
    [117] = 17,
    [118] = 18,
    [119] = 19,
    [120] = 20,
    [201] = 21,
    [202] = 22,
    [203] = 23,
    [204] = 24,
    [205] = 25,
    [206] = 26,
    [207] = 27,
    [208] = 28,
    [209] = 29,
    [210] = 30,
    [211] = 31,
    [212] = 32,
    [213] = 33,
    [214] = 34,
    [215] = 35,
    [216] = 36,
    [217] = 37,
    [218] = 38,
    [219] = 39,
    [220] = 40,

}

local __key_map = {
  id = 1,
  type = 2,
  rank_min = 3,
  rank_max = 4,
  award_type1 = 5,
  award_value1 = 6,
  award_size1 = 7,
  award_type2 = 8,
  award_value2 = 9,
  award_size2 = 10,
  award_type3 = 11,
  award_value3 = 12,
  award_size3 = 13,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_rebel_boss_rank_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function rebel_boss_rank_info.getLength()
    return #rebel_boss_rank_info._data
end



function rebel_boss_rank_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_rebel_boss_rank_info
function rebel_boss_rank_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = rebel_boss_rank_info._data[index]}, m)
    
end

---
--@return @class record_rebel_boss_rank_info
function rebel_boss_rank_info.get(id)
    
    return rebel_boss_rank_info.indexOf(__index_id[id])
        
end



function rebel_boss_rank_info.set(id, key, value)
    local record = rebel_boss_rank_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function rebel_boss_rank_info.get_index_data()
    return __index_id
end