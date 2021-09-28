

---@classdef record_knight_pack_info
local record_knight_pack_info = {}
  
record_knight_pack_info.id = 0 --卡包1ID  
record_knight_pack_info.knight_show = 0 --卡包展示  
record_knight_pack_info.knight1_id = 0 --武将1ID  
record_knight_pack_info.knight2_id = 0 --武将2ID  
record_knight_pack_info.knight3_id = 0 --武将3ID  
record_knight_pack_info.knight4_id = 0 --武将4ID  
record_knight_pack_info.knight5_id = 0 --武将5ID  
record_knight_pack_info.knight6_id = 0 --武将6ID  
record_knight_pack_info.knight7_id = 0 --武将7ID  
record_knight_pack_info.knight8_id = 0 --武将8ID  
record_knight_pack_info.knight9_id = 0 --武将9ID  
record_knight_pack_info.knight10_id = 0 --武将10ID  
record_knight_pack_info.knight11_id = 0 --武将11ID  
record_knight_pack_info.knight12_id = 0 --武将12ID  
record_knight_pack_info.knight13_id = 0 --武将13ID  
record_knight_pack_info.knight14_id = 0 --武将14ID  
record_knight_pack_info.knight15_id = 0 --武将15ID  
record_knight_pack_info.knight16_id = 0 --武将16ID  
record_knight_pack_info.knight17_id = 0 --武将17ID  
record_knight_pack_info.knight18_id = 0 --武将18ID  
record_knight_pack_info.knight19_id = 0 --武将19ID  
record_knight_pack_info.knight20_id = 0 --武将20ID


knight_pack_info = {
   _data = {
    [1] = {1,0,10078,10100,10133,10155,10166,10177,10188,10199,10210,20100,20122,20133,20144,20166,20177,20188,0,0,0,0,},
    [2] = {2,0,30111,30122,30155,30166,30177,30188,30199,40034,40067,40078,40089,40100,40111,40122,20199,30100,0,0,0,0,},
    [3] = {3,0,10012,10023,10034,10067,10089,10122,10144,20012,20034,20045,20056,20067,20111,20155,0,0,0,0,0,0,},
    [4] = {4,0,30012,30023,30056,30078,30089,30133,30144,40012,40023,40056,40144,40155,40166,40177,0,0,0,0,0,0,},
    [5] = {5,0,10001,20001,10056,20078,30001,30045,40001,40045,0,0,0,0,0,0,0,0,0,0,0,0,},
    [6] = {6,0,10265,10276,10287,10375,10386,10463,10485,10496,10507,20287,20342,20353,20397,20408,20452,20485,0,0,0,0,},
    [7] = {7,0,30254,30265,30287,30364,30430,30463,40298,40331,40342,40353,40375,40452,0,0,0,0,0,0,0,0,},
    [8] = {8,0,10221,10232,10243,10254,10298,10309,10320,10331,10342,10353,10364,10397,10408,10419,10430,10441,10452,10474,10518,0,},
    [9] = {9,0,20210,20221,20232,20243,20254,20265,20276,20298,20309,20320,20331,20364,20375,20386,20419,20430,20441,20463,20474,0,},
    [10] = {10,0,30210,30221,30232,30243,30276,30298,30309,30320,30331,30342,30353,30375,30386,30397,30408,30419,30441,30452,30474,0,},
    [11] = {11,0,40199,40210,40221,40232,40243,40254,40265,40276,40287,40309,40320,40364,40386,40397,40408,40419,40430,40441,0,0,},
    [12] = {12,0,10529,10540,10551,10562,10573,10584,10595,10606,10617,10628,20496,20507,20518,20529,20540,30485,30496,30507,30518,30529,},
    [13] = {13,0,30540,40463,40474,40485,40496,10639,10650,10661,10672,20551,0,0,0,0,0,0,0,0,0,0,},
    [14] = {14,0,10078,10166,10100,10133,10155,20100,20166,20122,20133,20144,30122,30155,30166,30177,30188,40034,40067,40078,40089,40100,},
    [15] = {15,0,10111,20089,30067,40133,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
    [16] = {16,0,10221,10232,10243,10254,10298,20210,20221,20232,20243,20254,30210,30221,30232,30243,30276,40199,40210,40221,40232,40243,},
    [17] = {1000,0,20144,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,},
    [18] = {500,1,10078,10166,10100,10133,10155,20100,20166,20122,20133,20144,30122,30155,30166,30177,30188,40034,40067,40078,40089,40100,},
    [19] = {501,2,10111,20089,30067,40133,10012,10023,10034,20012,20034,20045,30067,30078,30089,30133,40012,40023,40056,0,0,0,},
    [20] = {1001,0,10078,10100,10133,10155,10166,10177,10188,10199,10210,0,0,0,0,0,0,0,0,0,0,0,},
    [21] = {1002,4,10012,10023,10034,10067,10089,10111,10122,10144,0,0,0,0,0,0,0,0,0,0,0,0,},
    [22] = {2001,0,20100,20122,20133,20144,20166,20177,20188,20199,0,0,0,0,0,0,0,0,0,0,0,0,},
    [23] = {2002,5,20012,20034,20045,20056,20067,20089,20111,20155,0,0,0,0,0,0,0,0,0,0,0,0,},
    [24] = {3001,0,30111,30122,30155,30166,30177,30188,30199,30100,0,0,0,0,0,0,0,0,0,0,0,0,},
    [25] = {3002,6,30012,30023,30056,30067,30078,30089,30133,30144,0,0,0,0,0,0,0,0,0,0,0,0,},
    [26] = {4001,0,40034,40067,40078,40089,40100,40111,40122,0,0,0,0,0,0,0,0,0,0,0,0,0,},
    [27] = {4002,7,40012,40023,40056,40133,40144,40155,40166,40177,0,0,0,0,0,0,0,0,0,0,0,0,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [1000] = 17,
    [1001] = 20,
    [1002] = 21,
    [11] = 11,
    [12] = 12,
    [13] = 13,
    [14] = 14,
    [15] = 15,
    [16] = 16,
    [2] = 2,
    [2001] = 22,
    [2002] = 23,
    [3] = 3,
    [3001] = 24,
    [3002] = 25,
    [4] = 4,
    [4001] = 26,
    [4002] = 27,
    [5] = 5,
    [500] = 18,
    [501] = 19,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  knight_show = 2,
  knight1_id = 3,
  knight2_id = 4,
  knight3_id = 5,
  knight4_id = 6,
  knight5_id = 7,
  knight6_id = 8,
  knight7_id = 9,
  knight8_id = 10,
  knight9_id = 11,
  knight10_id = 12,
  knight11_id = 13,
  knight12_id = 14,
  knight13_id = 15,
  knight14_id = 16,
  knight15_id = 17,
  knight16_id = 18,
  knight17_id = 19,
  knight18_id = 20,
  knight19_id = 21,
  knight20_id = 22,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_knight_pack_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function knight_pack_info.getLength()
    return #knight_pack_info._data
end



function knight_pack_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_knight_pack_info
function knight_pack_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = knight_pack_info._data[index]}, m)
    
end

---
--@return @class record_knight_pack_info
function knight_pack_info.get(id)
    
    return knight_pack_info.indexOf(__index_id[id])
        
end



function knight_pack_info.set(id, key, value)
    local record = knight_pack_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function knight_pack_info.get_index_data()
    return __index_id
end