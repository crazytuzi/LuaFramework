

---@classdef record_city_technology_info
local record_city_technology_info = {}
  
record_city_technology_info.id = 0 --编号  
record_city_technology_info.level = 0 --等级  
record_city_technology_info.require_patroltime = 0 --开启要求巡逻时长  
record_city_technology_info.odds = 0 --翻倍几率  
record_city_technology_info.learn_cost_type = 0 --学习消耗类型  
record_city_technology_info.learn_cost_value = 0 --学习消耗ID  
record_city_technology_info.learn_cost_size = 0 --学习消耗值  
record_city_technology_info.name = "" --技能名称  
record_city_technology_info.icon = 0 --技能ICON  
record_city_technology_info.description = "" --技能描述


city_technology_info = {
   _data = {
    [1] = {1,1,200,200,2,0,50,"桃源村",1,"巡逻桃源村获得特产物品时有20%的几率翻倍，提升后翻倍几率提升至40%",},
    [2] = {1,2,300,400,2,0,100,"桃源村",1,"巡逻桃源村获得特产物品时有40%的几率翻倍，提升后翻倍几率提升至60%",},
    [3] = {1,3,600,600,2,0,200,"桃源村",1,"巡逻桃源村获得特产物品时有60%的几率翻倍，提升后翻倍几率提升至80%",},
    [4] = {1,4,1700,800,2,0,350,"桃源村",1,"巡逻桃源村获得特产物品时有80%的几率翻倍，提升后翻倍几率提升至100%",},
    [5] = {1,5,3300,1000,2,0,500,"桃源村",1,"巡逻桃源村获得特产物品时有100%的几率翻倍",},
    [6] = {2,1,300,200,2,0,50,"宛城",2,"巡逻宛城获得特产物品时有20%的几率翻倍，提升后翻倍几率提升至40%",},
    [7] = {2,2,700,400,2,0,100,"宛城",2,"巡逻宛城获得特产物品时有40%的几率翻倍，提升后翻倍几率提升至60%",},
    [8] = {2,3,2200,600,2,0,200,"宛城",2,"巡逻宛城获得特产物品时有60%的几率翻倍，提升后翻倍几率提升至80%",},
    [9] = {2,4,5200,800,2,0,350,"宛城",2,"巡逻宛城获得特产物品时有80%的几率翻倍，提升后翻倍几率提升至100%",},
    [10] = {2,5,7200,1000,2,0,500,"宛城",2,"巡逻宛城获得特产物品时有100%的几率翻倍",},
    [11] = {3,1,600,200,2,0,50,"洛阳",3,"巡逻洛阳获得特产物品时有20%的几率翻倍，提升后翻倍几率提升至40%",},
    [12] = {3,2,1400,400,2,0,100,"洛阳",3,"巡逻洛阳获得特产物品时有40%的几率翻倍，提升后翻倍几率提升至60%",},
    [13] = {3,3,4100,600,2,0,200,"洛阳",3,"巡逻洛阳获得特产物品时有60%的几率翻倍，提升后翻倍几率提升至80%",},
    [14] = {3,4,6900,800,2,0,350,"洛阳",3,"巡逻洛阳获得特产物品时有80%的几率翻倍，提升后翻倍几率提升至100%",},
    [15] = {3,5,9800,1000,2,0,500,"洛阳",3,"巡逻洛阳获得特产物品时有100%的几率翻倍",},
    [16] = {4,1,900,200,2,0,50,"荆州",4,"巡逻荆州获得特产物品时有20%的几率翻倍，提升后翻倍几率提升至40%",},
    [17] = {4,2,2500,400,2,0,100,"荆州",4,"巡逻荆州获得特产物品时有40%的几率翻倍，提升后翻倍几率提升至60%",},
    [18] = {4,3,6500,600,2,0,200,"荆州",4,"巡逻荆州获得特产物品时有60%的几率翻倍，提升后翻倍几率提升至80%",},
    [19] = {4,4,9500,800,2,0,350,"荆州",4,"巡逻荆州获得特产物品时有80%的几率翻倍，提升后翻倍几率提升至100%",},
    [20] = {4,5,12800,1000,2,0,500,"荆州",4,"巡逻荆州获得特产物品时有100%的几率翻倍",},
    [21] = {5,1,1600,200,2,0,50,"五丈原",5,"巡逻五丈原获得特产物品时有20%的几率翻倍，提升后翻倍几率提升至40%",},
    [22] = {5,2,3900,400,2,0,100,"五丈原",5,"巡逻五丈原获得特产物品时有40%的几率翻倍，提升后翻倍几率提升至60%",},
    [23] = {5,3,8200,600,2,0,200,"五丈原",5,"巡逻五丈原获得特产物品时有60%的几率翻倍，提升后翻倍几率提升至80%",},
    [24] = {5,4,12100,800,2,0,350,"五丈原",5,"巡逻五丈原获得特产物品时有80%的几率翻倍，提升后翻倍几率提升至100%",},
    [25] = {5,5,16200,1000,2,0,500,"五丈原",5,"巡逻五丈原获得特产物品时有100%的几率翻倍",},
    [26] = {6,1,2900,200,2,0,50,"赤壁",6,"巡逻赤壁获得特产物品时有20%的几率翻倍，提升后翻倍几率提升至40%",},
    [27] = {6,2,5800,400,2,0,100,"赤壁",6,"巡逻赤壁获得特产物品时有40%的几率翻倍，提升后翻倍几率提升至60%",},
    [28] = {6,3,10200,600,2,0,200,"赤壁",6,"巡逻赤壁获得特产物品时有60%的几率翻倍，提升后翻倍几率提升至80%",},
    [29] = {6,4,14900,800,2,0,350,"赤壁",6,"巡逻赤壁获得特产物品时有80%的几率翻倍，提升后翻倍几率提升至100%",},
    [30] = {6,5,19800,1000,2,0,500,"赤壁",6,"巡逻赤壁获得特产物品时有100%的几率翻倍",},
    }
}



local __index_id_level = {
    ["1_1"] = 1,
    ["1_2"] = 2,
    ["1_3"] = 3,
    ["1_4"] = 4,
    ["1_5"] = 5,
    ["2_1"] = 6,
    ["2_2"] = 7,
    ["2_3"] = 8,
    ["2_4"] = 9,
    ["2_5"] = 10,
    ["3_1"] = 11,
    ["3_2"] = 12,
    ["3_3"] = 13,
    ["3_4"] = 14,
    ["3_5"] = 15,
    ["4_1"] = 16,
    ["4_2"] = 17,
    ["4_3"] = 18,
    ["4_4"] = 19,
    ["4_5"] = 20,
    ["5_1"] = 21,
    ["5_2"] = 22,
    ["5_3"] = 23,
    ["5_4"] = 24,
    ["5_5"] = 25,
    ["6_1"] = 26,
    ["6_2"] = 27,
    ["6_3"] = 28,
    ["6_4"] = 29,
    ["6_5"] = 30,

}

local __key_map = {
  id = 1,
  level = 2,
  require_patroltime = 3,
  odds = 4,
  learn_cost_type = 5,
  learn_cost_value = 6,
  learn_cost_size = 7,
  name = 8,
  icon = 9,
  description = 10,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_city_technology_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function city_technology_info.getLength()
    return #city_technology_info._data
end



function city_technology_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_city_technology_info
function city_technology_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = city_technology_info._data[index]}, m)
    
end

---
--@return @class record_city_technology_info
function city_technology_info.get(id,level)
    
    local k = id .. '_' .. level
    return city_technology_info.indexOf(__index_id_level[k])
        
end



function city_technology_info.set(id,level, key, value)
    local record = city_technology_info.get(id,level)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function city_technology_info.get_index_data()
    return __index_id_level
end