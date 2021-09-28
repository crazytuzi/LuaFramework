

---@classdef record_dead_battle_boss_info
local record_dead_battle_boss_info = {}
  
record_dead_battle_boss_info.id = 0 --编号  
record_dead_battle_boss_info.level_number = 0 --关数  
record_dead_battle_boss_info.front_floor = 0 --前置三国无双关卡  
record_dead_battle_boss_info.monster_name = "" --怪物名称  
record_dead_battle_boss_info.monster_image = 0 --怪物形象  
record_dead_battle_boss_info.monster_icon = 0 --怪物头像  
record_dead_battle_boss_info.monster_group_id = 0 --引用怪物组id  
record_dead_battle_boss_info.first_type = 0 --首胜奖励类型  
record_dead_battle_boss_info.first_value = 0 --首胜奖励类型值  
record_dead_battle_boss_info.first_size = 0 --首胜奖励数量  
record_dead_battle_boss_info.type_1 = 0 --掉落道具类型1  
record_dead_battle_boss_info.value_1 = 0 --掉落道具类型值1  
record_dead_battle_boss_info.min_size_1 = 0 --掉落道具数量最小1  
record_dead_battle_boss_info.max_size_1 = 0 --掉落道具数量最大1  
record_dead_battle_boss_info.type_2 = 0 --掉落道具类型2  
record_dead_battle_boss_info.value_2 = 0 --掉落道具类型值2  
record_dead_battle_boss_info.min_size_2 = 0 --掉落道具数量最小2  
record_dead_battle_boss_info.max_size_2 = 0 --掉落道具数量最大2  
record_dead_battle_boss_info.type_3 = 0 --掉落道具类型3  
record_dead_battle_boss_info.value_3 = 0 --掉落道具类型值3  
record_dead_battle_boss_info.min_size_3 = 0 --掉落道具数量最小3  
record_dead_battle_boss_info.max_size_3 = 0 --掉落道具数量最大3


dead_battle_boss_info = {
   _data = {
    [1] = {1,1,3,"汉献帝",14039,14039,3500,16,0,6000,1,0,120000,120000,0,0,0,0,0,0,0,0,},
    [2] = {2,2,6,"乐进",11014,11014,3501,16,0,6000,3,13,6,6,0,0,0,0,0,0,0,0,},
    [3] = {3,3,9,"徐盛",13017,13017,3502,16,0,6000,3,18,24,24,0,0,0,0,0,0,0,0,},
    [4] = {4,4,12,"魏延",12007,12007,3503,16,0,9000,1,0,180000,180000,0,0,0,0,0,0,0,0,},
    [5] = {5,5,15,"夏侯渊",11005,11005,3504,16,0,9000,3,13,9,9,0,0,0,0,0,0,0,0,},
    [6] = {6,6,18,"孙尚香",13012,13012,3505,16,0,9000,3,18,36,36,0,0,0,0,0,0,0,0,},
    [7] = {7,7,21,"黄月英",12015,12015,3506,16,0,12000,3,13,12,12,0,0,0,0,0,0,0,0,},
    [8] = {8,8,24,"卢植",14015,14015,3507,16,0,12000,3,18,48,48,0,0,0,0,0,0,0,0,},
    [9] = {9,9,27,"孙策",13004,13004,3508,16,0,12000,3,81,3,3,0,0,0,0,0,0,0,0,},
    [10] = {10,10,30,"郭嘉",11001,11001,3509,16,0,15000,1,0,300000,300000,0,0,0,0,0,0,0,0,},
    [11] = {11,11,33,"董卓",14016,14016,3510,16,0,15000,3,45,60,60,0,0,0,0,0,0,0,0,},
    [12] = {12,12,36,"关羽",12003,12003,3511,16,0,15000,3,81,3,3,0,0,0,0,0,0,0,0,},
    [13] = {13,13,39,"曹操",11002,11002,3512,16,0,18000,3,13,18,18,0,0,0,0,0,0,0,0,},
    [14] = {14,14,42,"诸葛亮",12009,12009,3513,16,0,18000,3,18,72,72,0,0,0,0,0,0,0,0,},
    [15] = {15,15,45,"周瑜",13007,13007,3514,16,0,18000,1,0,360000,360000,0,0,0,0,0,0,0,0,},
    [16] = {16,16,48,"吕布",14005,14005,3515,16,0,24000,3,45,96,96,0,0,0,0,0,0,0,0,},
    [17] = {17,17,51,"张辽",110063,110063,3516,16,0,24000,3,81,3,3,0,0,0,0,0,0,0,0,},
    [18] = {18,18,54,"赵云",120013,120013,3517,16,0,24000,3,13,24,24,0,0,0,0,0,0,0,0,},
    [19] = {19,19,57,"吕蒙",130083,130083,3518,16,0,30000,3,18,120,120,0,0,0,0,0,0,0,0,},
    [20] = {20,20,60,"张角",140193,140193,3519,16,0,30000,1,0,600000,600000,0,0,0,0,0,0,0,0,},
    [21] = {21,21,63,"荀彧",110072,110072,3520,16,0,30000,3,45,120,120,0,0,0,0,0,0,0,0,},
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
  level_number = 2,
  front_floor = 3,
  monster_name = 4,
  monster_image = 5,
  monster_icon = 6,
  monster_group_id = 7,
  first_type = 8,
  first_value = 9,
  first_size = 10,
  type_1 = 11,
  value_1 = 12,
  min_size_1 = 13,
  max_size_1 = 14,
  type_2 = 15,
  value_2 = 16,
  min_size_2 = 17,
  max_size_2 = 18,
  type_3 = 19,
  value_3 = 20,
  min_size_3 = 21,
  max_size_3 = 22,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_dead_battle_boss_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function dead_battle_boss_info.getLength()
    return #dead_battle_boss_info._data
end



function dead_battle_boss_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_dead_battle_boss_info
function dead_battle_boss_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = dead_battle_boss_info._data[index]}, m)
    
end

---
--@return @class record_dead_battle_boss_info
function dead_battle_boss_info.get(id)
    
    return dead_battle_boss_info.indexOf(__index_id[id])
        
end



function dead_battle_boss_info.set(id, key, value)
    local record = dead_battle_boss_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function dead_battle_boss_info.get_index_data()
    return __index_id
end