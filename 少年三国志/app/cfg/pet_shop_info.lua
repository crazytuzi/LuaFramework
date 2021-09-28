

---@classdef record_pet_shop_info
local record_pet_shop_info = {}
  
record_pet_shop_info.id = 0 --id  
record_pet_shop_info.type = 0 --格子类型  
record_pet_shop_info.item_type = 0 --物品类型  
record_pet_shop_info.item_id = 0 --物品ID  
record_pet_shop_info.item_num = 0 --物品数量  
record_pet_shop_info.price_type = 0 --购买货币类型  
record_pet_shop_info.price = 0 --购买价格  
record_pet_shop_info.probability = 0 --概率  
record_pet_shop_info.recommend = 0 --推荐


pet_shop_info = {
   _data = {
    [1] = {1001,1,6,50000,5,2,500,470,0,},
    [2] = {1002,1,6,50001,5,2,500,470,0,},
    [3] = {1003,1,6,50002,5,2,750,310,1,},
    [4] = {1004,1,6,50003,5,2,750,310,1,},
    [5] = {1005,1,6,50004,5,2,1000,310,1,},
    [6] = {1006,1,6,50000,5,15,500,1410,0,},
    [7] = {1007,1,6,50001,5,15,500,1410,0,},
    [8] = {1008,1,6,50002,5,15,750,935,1,},
    [9] = {1009,1,6,50003,5,15,750,935,1,},
    [10] = {1010,1,6,50004,5,15,1000,940,1,},
    [11] = {1011,2,3,198,25,2,250,1400,0,},
    [12] = {1012,2,3,199,15,2,750,775,0,},
    [13] = {1013,2,3,200,10,2,1000,325,1,},
    [14] = {1014,2,3,198,25,15,250,4200,0,},
    [15] = {1015,2,3,199,15,15,750,2325,0,},
    [16] = {1016,2,3,200,10,15,1000,975,1,},
    [17] = {1017,3,3,198,25,2,250,1400,0,},
    [18] = {1018,3,3,199,15,2,750,775,0,},
    [19] = {1019,3,3,200,10,2,1000,325,1,},
    [20] = {1020,3,3,198,25,15,250,4200,0,},
    [21] = {1021,3,3,199,15,15,750,2325,0,},
    [22] = {1022,3,3,200,10,15,1000,975,1,},
    [23] = {1023,4,3,201,50,2,250,1400,0,},
    [24] = {1024,4,3,202,25,2,250,775,0,},
    [25] = {1025,4,3,203,25,2,500,325,1,},
    [26] = {1026,4,3,201,50,15,250,4200,0,},
    [27] = {1027,4,3,202,25,15,250,2325,0,},
    [28] = {1028,4,3,203,25,15,500,975,1,},
    [29] = {1029,5,3,201,50,2,250,1400,0,},
    [30] = {1030,5,3,202,25,2,250,775,0,},
    [31] = {1031,5,3,203,25,2,500,325,1,},
    [32] = {1032,5,3,201,50,15,250,4200,0,},
    [33] = {1033,5,3,202,25,15,250,2325,0,},
    [34] = {1034,5,3,203,25,15,500,975,1,},
    [35] = {1035,6,3,204,150,2,300,1400,0,},
    [36] = {1036,6,3,204,200,2,400,775,0,},
    [37] = {1037,6,3,204,250,2,500,325,1,},
    [38] = {1038,6,3,204,150,15,300,4200,0,},
    [39] = {1039,6,3,204,200,15,400,2325,0,},
    [40] = {1040,6,3,204,250,15,500,975,1,},
    [41] = {1041,1,6,50006,5,2,1000,310,1,},
    [42] = {1042,1,6,50008,5,2,1000,310,1,},
    [43] = {1043,1,6,50006,5,15,1000,940,1,},
    [44] = {1044,1,6,50008,5,15,1000,940,1,},
    }
}



local __index_id = {
    [1001] = 1,
    [1002] = 2,
    [1003] = 3,
    [1004] = 4,
    [1005] = 5,
    [1006] = 6,
    [1007] = 7,
    [1008] = 8,
    [1009] = 9,
    [1010] = 10,
    [1011] = 11,
    [1012] = 12,
    [1013] = 13,
    [1014] = 14,
    [1015] = 15,
    [1016] = 16,
    [1017] = 17,
    [1018] = 18,
    [1019] = 19,
    [1020] = 20,
    [1021] = 21,
    [1022] = 22,
    [1023] = 23,
    [1024] = 24,
    [1025] = 25,
    [1026] = 26,
    [1027] = 27,
    [1028] = 28,
    [1029] = 29,
    [1030] = 30,
    [1031] = 31,
    [1032] = 32,
    [1033] = 33,
    [1034] = 34,
    [1035] = 35,
    [1036] = 36,
    [1037] = 37,
    [1038] = 38,
    [1039] = 39,
    [1040] = 40,
    [1041] = 41,
    [1042] = 42,
    [1043] = 43,
    [1044] = 44,

}

local __key_map = {
  id = 1,
  type = 2,
  item_type = 3,
  item_id = 4,
  item_num = 5,
  price_type = 6,
  price = 7,
  probability = 8,
  recommend = 9,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_pet_shop_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function pet_shop_info.getLength()
    return #pet_shop_info._data
end



function pet_shop_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_pet_shop_info
function pet_shop_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = pet_shop_info._data[index]}, m)
    
end

---
--@return @class record_pet_shop_info
function pet_shop_info.get(id)
    
    return pet_shop_info.indexOf(__index_id[id])
        
end



function pet_shop_info.set(id, key, value)
    local record = pet_shop_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function pet_shop_info.get_index_data()
    return __index_id
end