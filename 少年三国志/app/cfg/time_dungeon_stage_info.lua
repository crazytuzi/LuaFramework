

---@classdef record_time_dungeon_stage_info
local record_time_dungeon_stage_info = {}
  
record_time_dungeon_stage_info.id = 0 --id  
record_time_dungeon_stage_info.type = 0 --副本类型  
record_time_dungeon_stage_info.difficult = 0 --副本难度  
record_time_dungeon_stage_info.level_min = 0 --副本最低等级  
record_time_dungeon_stage_info.level_max = 0 --副本最高等级  
record_time_dungeon_stage_info.dungeon_1 = 0 --关卡1  
record_time_dungeon_stage_info.dungeon_2 = 0 --关卡2  
record_time_dungeon_stage_info.dungeon_3 = 0 --关卡3  
record_time_dungeon_stage_info.dungeon_4 = 0 --关卡4  
record_time_dungeon_stage_info.dungeon_5 = 0 --关卡5  
record_time_dungeon_stage_info.dungeon_6 = 0 --关卡6  
record_time_dungeon_stage_info.dungeon_7 = 0 --关卡7  
record_time_dungeon_stage_info.dungeon_8 = 0 --关卡8


time_dungeon_stage_info = {
   _data = {
    [1] = {1,1,1,45,54,1,2,3,4,5,6,7,8,},
    [2] = {2,1,2,55,64,9,10,11,12,13,14,15,16,},
    [3] = {3,1,3,65,74,17,18,19,20,21,22,23,24,},
    [4] = {4,1,4,75,89,25,26,27,28,29,30,31,32,},
    [5] = {5,1,5,90,99,33,34,35,36,37,38,39,40,},
    [6] = {6,1,6,100,999,41,42,43,44,45,46,47,48,},
    [7] = {7,2,1,45,54,49,50,51,52,53,54,55,56,},
    [8] = {8,2,2,55,64,57,58,59,60,61,62,63,64,},
    [9] = {9,2,3,65,74,65,66,67,68,69,70,71,72,},
    [10] = {10,2,4,75,89,73,74,75,76,77,78,79,80,},
    [11] = {11,2,5,90,99,81,82,83,84,85,86,87,88,},
    [12] = {12,2,6,100,999,89,90,91,92,93,94,95,96,},
    [13] = {13,3,1,45,54,97,98,99,100,101,102,103,104,},
    [14] = {14,3,2,55,64,105,106,107,108,109,110,111,112,},
    [15] = {15,3,3,65,74,113,114,115,116,117,118,119,120,},
    [16] = {16,3,4,75,89,121,122,123,124,125,126,127,128,},
    [17] = {17,3,5,90,99,129,130,131,132,133,134,135,136,},
    [18] = {18,3,6,100,999,137,138,139,140,141,142,143,144,},
    [19] = {19,4,1,45,54,145,146,147,148,149,150,151,152,},
    [20] = {20,4,2,55,64,153,154,155,156,157,158,159,160,},
    [21] = {21,4,3,65,74,161,162,163,164,165,166,167,168,},
    [22] = {22,4,4,75,89,169,170,171,172,173,174,175,176,},
    [23] = {23,4,5,90,99,177,178,179,180,181,182,183,184,},
    [24] = {24,4,6,100,999,185,186,187,188,189,190,191,192,},
    [25] = {25,5,1,45,54,193,194,195,196,197,198,199,200,},
    [26] = {26,5,2,55,64,201,202,203,204,205,206,207,208,},
    [27] = {27,5,3,65,74,209,210,211,212,213,214,215,216,},
    [28] = {28,5,4,75,89,217,218,219,220,221,222,223,224,},
    [29] = {29,5,5,90,99,225,226,227,228,229,230,231,232,},
    [30] = {30,5,6,100,999,233,234,235,236,237,238,239,240,},
    [31] = {31,6,1,45,54,241,242,243,244,245,246,247,248,},
    [32] = {32,6,2,55,64,249,250,251,252,253,254,255,256,},
    [33] = {33,6,3,65,74,257,258,259,260,261,262,263,264,},
    [34] = {34,6,4,75,89,265,266,267,268,269,270,271,272,},
    [35] = {35,6,5,90,99,273,274,275,276,277,278,279,280,},
    [36] = {36,6,6,100,999,281,282,283,284,285,286,287,288,},
    [37] = {37,7,1,45,54,289,290,291,292,293,294,295,296,},
    [38] = {38,7,2,55,64,297,298,299,300,301,302,303,304,},
    [39] = {39,7,3,65,74,305,306,307,308,309,310,311,312,},
    [40] = {40,7,4,75,89,313,314,315,316,317,318,319,320,},
    [41] = {41,7,5,90,99,321,322,323,324,325,326,327,328,},
    [42] = {42,7,6,100,999,329,330,331,332,333,334,335,336,},
    [43] = {43,8,1,45,54,337,338,339,340,341,342,343,344,},
    [44] = {44,8,2,55,64,345,346,347,348,349,350,351,352,},
    [45] = {45,8,3,65,74,353,354,355,356,357,358,359,360,},
    [46] = {46,8,4,75,89,361,362,363,364,365,366,367,368,},
    [47] = {47,8,5,90,99,369,370,371,372,373,374,375,376,},
    [48] = {48,8,6,100,999,377,378,379,380,381,382,383,384,},
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
    [18] = 18,
    [19] = 19,
    [2] = 2,
    [20] = 20,
    [21] = 21,
    [22] = 22,
    [23] = 23,
    [24] = 24,
    [25] = 25,
    [26] = 26,
    [27] = 27,
    [28] = 28,
    [29] = 29,
    [3] = 3,
    [30] = 30,
    [31] = 31,
    [32] = 32,
    [33] = 33,
    [34] = 34,
    [35] = 35,
    [36] = 36,
    [37] = 37,
    [38] = 38,
    [39] = 39,
    [4] = 4,
    [40] = 40,
    [41] = 41,
    [42] = 42,
    [43] = 43,
    [44] = 44,
    [45] = 45,
    [46] = 46,
    [47] = 47,
    [48] = 48,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  type = 2,
  difficult = 3,
  level_min = 4,
  level_max = 5,
  dungeon_1 = 6,
  dungeon_2 = 7,
  dungeon_3 = 8,
  dungeon_4 = 9,
  dungeon_5 = 10,
  dungeon_6 = 11,
  dungeon_7 = 12,
  dungeon_8 = 13,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_time_dungeon_stage_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function time_dungeon_stage_info.getLength()
    return #time_dungeon_stage_info._data
end



function time_dungeon_stage_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_time_dungeon_stage_info
function time_dungeon_stage_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = time_dungeon_stage_info._data[index]}, m)
    
end

---
--@return @class record_time_dungeon_stage_info
function time_dungeon_stage_info.get(id)
    
    return time_dungeon_stage_info.indexOf(__index_id[id])
        
end



function time_dungeon_stage_info.set(id, key, value)
    local record = time_dungeon_stage_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function time_dungeon_stage_info.get_index_data()
    return __index_id
end