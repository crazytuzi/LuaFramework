

---@classdef record_equipment_suit_info
local record_equipment_suit_info = {}
  
record_equipment_suit_info.id = 0 --编号  
record_equipment_suit_info.name = "" --轻甲套装名称  
record_equipment_suit_info.equipment_id_1 = 0 --装备ID1  
record_equipment_suit_info.equipment_id_2 = 0 --装备ID2  
record_equipment_suit_info.equipment_id_3 = 0 --装备ID3  
record_equipment_suit_info.equipment_id_4 = 0 --装备ID4  
record_equipment_suit_info.two_suit_type_1 = 0 --2件套装属性类型1  
record_equipment_suit_info.two_suit_value_1 = 0 --2件套装属性类型值1  
record_equipment_suit_info.two_suit_type_2 = 0 --2件套装属性类型2  
record_equipment_suit_info.two_suit_value_2 = 0 --2件套装属性类型值2  
record_equipment_suit_info.three_suit_type_1 = 0 --3件套装属性类型1  
record_equipment_suit_info.three_suit_value_1 = 0 --3件套装属性类型值1  
record_equipment_suit_info.three_suit_type_2 = 0 --3件套装属性类型2  
record_equipment_suit_info.three_suit_value_2 = 0 --3件套装属性类型值2  
record_equipment_suit_info.four_suit_type_1 = 0 --4件套装属性类型1  
record_equipment_suit_info.four_suit_value_1 = 0 --4件套装属性类型值1  
record_equipment_suit_info.four_suit_type_2 = 0 --4件套装属性类型2  
record_equipment_suit_info.four_suit_value_2 = 0 --4件套装属性类型值2


equipment_suit_info = {
   _data = {
    [1] = {1000,"白龙套装",1001,1002,1003,1004,5,800,0,0,6,66,0,0,17,20,18,20,},
    [2] = {2000,"流星套装",2001,2002,2003,2004,5,1400,0,0,6,115,0,0,17,40,18,40,},
    [3] = {2010,"飞雪套装",2011,2012,2013,2014,6,173,0,0,13,40,0,0,15,40,17,40,},
    [4] = {3000,"龙翼套装",3001,3002,3003,3004,5,2000,0,0,6,165,0,0,17,60,18,60,},
    [5] = {3010,"惊雷套装",3011,3012,3013,3014,5,3000,0,0,14,60,0,0,16,60,18,60,},
    [6] = {3020,"落月套装",3021,3022,3023,3024,6,247,0,0,13,60,0,0,15,60,17,60,},
    [7] = {4000,"辉煌套装",4001,4002,4003,4004,5,2600,0,0,6,214,0,0,17,80,18,80,},
    [8] = {4010,"破军套装",4011,4012,4013,4014,5,3900,0,0,14,80,0,0,16,80,18,80,},
    [9] = {4020,"贪狼套装",4021,4022,4023,4024,6,321,0,0,13,80,0,0,15,80,17,80,},
    [10] = {5000,"血狱套装",5001,5002,5003,5004,5,3200,0,0,6,264,0,0,17,100,18,100,},
    [11] = {6000,"天罡套装",6001,6002,6003,6004,5,3600,0,0,6,297,0,0,17,120,18,120,},
    [12] = {7000,"无双套装",7001,7002,7003,7004,5,4000,0,0,6,330,0,0,17,140,18,140,},
    [13] = {7010,"青龙套装",7011,7012,7013,7014,5,4000,0,0,6,330,0,0,17,140,18,140,},
    [14] = {7020,"朱雀套装",7021,7022,7023,7024,5,4000,0,0,6,330,0,0,17,140,18,140,},
    [15] = {7030,"白虎套装",7031,7032,7033,7034,5,4000,0,0,6,330,0,0,17,140,18,140,},
    [16] = {7040,"玄武套装",7041,7042,7043,7044,5,4000,0,0,6,330,0,0,17,140,18,140,},
    }
}



local __index_id = {
    [1000] = 1,
    [2000] = 2,
    [2010] = 3,
    [3000] = 4,
    [3010] = 5,
    [3020] = 6,
    [4000] = 7,
    [4010] = 8,
    [4020] = 9,
    [5000] = 10,
    [6000] = 11,
    [7000] = 12,
    [7010] = 13,
    [7020] = 14,
    [7030] = 15,
    [7040] = 16,

}

local __key_map = {
  id = 1,
  name = 2,
  equipment_id_1 = 3,
  equipment_id_2 = 4,
  equipment_id_3 = 5,
  equipment_id_4 = 6,
  two_suit_type_1 = 7,
  two_suit_value_1 = 8,
  two_suit_type_2 = 9,
  two_suit_value_2 = 10,
  three_suit_type_1 = 11,
  three_suit_value_1 = 12,
  three_suit_type_2 = 13,
  three_suit_value_2 = 14,
  four_suit_type_1 = 15,
  four_suit_value_1 = 16,
  four_suit_type_2 = 17,
  four_suit_value_2 = 18,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_equipment_suit_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function equipment_suit_info.getLength()
    return #equipment_suit_info._data
end



function equipment_suit_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_equipment_suit_info
function equipment_suit_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = equipment_suit_info._data[index]}, m)
    
end

---
--@return @class record_equipment_suit_info
function equipment_suit_info.get(id)
    
    return equipment_suit_info.indexOf(__index_id[id])
        
end



function equipment_suit_info.set(id, key, value)
    local record = equipment_suit_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function equipment_suit_info.get_index_data()
    return __index_id
end