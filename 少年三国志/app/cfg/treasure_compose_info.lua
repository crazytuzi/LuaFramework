

---@classdef record_treasure_compose_info
local record_treasure_compose_info = {}
  
record_treasure_compose_info.id = 0 --id  
record_treasure_compose_info.treasure_id = 0 --宝物ID  
record_treasure_compose_info.fragment_id_1 = 0 --需求碎片id1  
record_treasure_compose_info.fragment_id_2 = 0 --需求碎片id2  
record_treasure_compose_info.fragment_id_3 = 0 --需求碎片id3  
record_treasure_compose_info.fragment_id_4 = 0 --需求碎片id4  
record_treasure_compose_info.fragment_id_5 = 0 --需求碎片id5  
record_treasure_compose_info.fragment_id_6 = 0 --需求碎片id6  
record_treasure_compose_info.fragment_id_7 = 0 --需求碎片id7  
record_treasure_compose_info.fragment_id_8 = 0 --需求碎片id8


treasure_compose_info = {
   _data = {
    [1] = {101,101,1011,1012,1013,0,0,0,0,0,},
    [2] = {102,102,1021,1022,1023,0,0,0,0,0,},
    [3] = {103,103,1031,1032,1033,0,0,0,0,0,},
    [4] = {104,104,1041,1042,1043,0,0,0,0,0,},
    [5] = {201,201,2011,2012,2013,2014,0,0,0,0,},
    [6] = {202,202,2021,2022,2023,2024,0,0,0,0,},
    [7] = {203,203,2031,2032,2033,2034,0,0,0,0,},
    [8] = {204,204,2041,2042,2043,2044,0,0,0,0,},
    [9] = {301,301,3011,3012,3013,3014,3015,0,0,0,},
    [10] = {302,302,3021,3022,3023,3024,3025,0,0,0,},
    [11] = {303,303,3031,3032,3033,3034,3035,0,0,0,},
    [12] = {304,304,3041,3042,3043,3044,3045,0,0,0,},
    [13] = {401,401,4011,4012,4013,4014,4015,4016,0,0,},
    [14] = {402,402,4021,4022,4023,4024,4025,4026,0,0,},
    [15] = {403,403,4031,4032,4033,4034,4035,4036,0,0,},
    [16] = {404,404,4041,4042,4043,4044,4045,4046,0,0,},
    [17] = {501,501,5011,5012,5013,5014,5015,5016,0,0,},
    [18] = {502,502,5021,5022,5023,5024,5025,5026,0,0,},
    [19] = {503,503,5031,5032,5033,5034,5035,5036,0,0,},
    [20] = {504,504,5041,5042,5043,5044,5045,5046,0,0,},
    [21] = {1,1,11,12,13,0,0,0,0,0,},
    [22] = {2,2,21,22,23,24,0,0,0,0,},
    }
}



local __index_id = {
    [1] = 21,
    [101] = 1,
    [102] = 2,
    [103] = 3,
    [104] = 4,
    [2] = 22,
    [201] = 5,
    [202] = 6,
    [203] = 7,
    [204] = 8,
    [301] = 9,
    [302] = 10,
    [303] = 11,
    [304] = 12,
    [401] = 13,
    [402] = 14,
    [403] = 15,
    [404] = 16,
    [501] = 17,
    [502] = 18,
    [503] = 19,
    [504] = 20,

}

local __key_map = {
  id = 1,
  treasure_id = 2,
  fragment_id_1 = 3,
  fragment_id_2 = 4,
  fragment_id_3 = 5,
  fragment_id_4 = 6,
  fragment_id_5 = 7,
  fragment_id_6 = 8,
  fragment_id_7 = 9,
  fragment_id_8 = 10,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_treasure_compose_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function treasure_compose_info.getLength()
    return #treasure_compose_info._data
end



function treasure_compose_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_treasure_compose_info
function treasure_compose_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = treasure_compose_info._data[index]}, m)
    
end

---
--@return @class record_treasure_compose_info
function treasure_compose_info.get(id)
    
    return treasure_compose_info.indexOf(__index_id[id])
        
end



function treasure_compose_info.set(id, key, value)
    local record = treasure_compose_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function treasure_compose_info.get_index_data()
    return __index_id
end