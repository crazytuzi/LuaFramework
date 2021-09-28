

---@classdef record_dungeon_vip_info
local record_dungeon_vip_info = {}
  
record_dungeon_vip_info.id = 0 --副本id  
record_dungeon_vip_info.type = 0 --副本类型  
record_dungeon_vip_info.name = "" --副本名称  
record_dungeon_vip_info.monster_team = 0 --怪物组  
record_dungeon_vip_info.cost = 0 --进入花费体力  
record_dungeon_vip_info.output_type = 0 --副本产出类型  
record_dungeon_vip_info.output_value = 0 --副本产出类型值  
record_dungeon_vip_info.output_bewrite = "" --产出奖励描述  
record_dungeon_vip_info.output_bewrite_event = "" --产出奖励描述-活动  
record_dungeon_vip_info.boss = 0 --BOSS全身像  
record_dungeon_vip_info.talk = "" --副本气泡描述  
record_dungeon_vip_info.map = 0 --战斗内的地图  
record_dungeon_vip_info.icon_pic = 0 --icon图片  
record_dungeon_vip_info.extra_ratio_1 = 0 --额外奖励系数值1  
record_dungeon_vip_info.extra_type_1 = 0 --额外奖励类型1  
record_dungeon_vip_info.extra_value_1 = 0 --额外奖励类型值1  
record_dungeon_vip_info.extra_size_1 = 0 --额外奖励数量1  
record_dungeon_vip_info.extra_ratio_2 = 0 --额外奖励系数值2  
record_dungeon_vip_info.extra_type_2 = 0 --额外奖励类型2  
record_dungeon_vip_info.extra_value_2 = 0 --额外奖励类型值2  
record_dungeon_vip_info.extra_size_2 = 0 --额外奖励数量2  
record_dungeon_vip_info.extra_ratio_3 = 0 --额外奖励系数值3  
record_dungeon_vip_info.extra_type_3 = 0 --额外奖励类型3  
record_dungeon_vip_info.extra_value_3 = 0 --额外奖励类型值3  
record_dungeon_vip_info.extra_size_3 = 0 --额外奖励数量3  
record_dungeon_vip_info.extra_ratio_4 = 0 --额外奖励系数值4  
record_dungeon_vip_info.extra_type_4 = 0 --额外奖励类型4  
record_dungeon_vip_info.extra_value_4 = 0 --额外奖励类型值4  
record_dungeon_vip_info.extra_size_4 = 0 --额外奖励数量4  
record_dungeon_vip_info.extra_ratio_5 = 0 --额外奖励系数值5  
record_dungeon_vip_info.extra_type_5 = 0 --额外奖励类型5  
record_dungeon_vip_info.extra_value_5 = 0 --额外奖励类型值5  
record_dungeon_vip_info.extra_size_5 = 0 --额外奖励数量5  
record_dungeon_vip_info.extra_ratio_6 = 0 --额外奖励系数值6  
record_dungeon_vip_info.extra_type_6 = 0 --额外奖励类型6  
record_dungeon_vip_info.extra_value_6 = 0 --额外奖励类型值6  
record_dungeon_vip_info.extra_size_6 = 0 --额外奖励数量6  
record_dungeon_vip_info.extra_ratio_7 = 0 --额外奖励系数值7  
record_dungeon_vip_info.extra_type_7 = 0 --额外奖励类型7  
record_dungeon_vip_info.extra_value_7 = 0 --额外奖励类型值7  
record_dungeon_vip_info.extra_size_7 = 0 --额外奖励数量7  
record_dungeon_vip_info.extra_ratio_8 = 0 --额外奖励系数值8  
record_dungeon_vip_info.extra_type_8 = 0 --额外奖励类型8  
record_dungeon_vip_info.extra_value_8 = 0 --额外奖励类型值8  
record_dungeon_vip_info.extra_size_8 = 0 --额外奖励数量8


dungeon_vip_info = {
   _data = {
    [1] = {1,1,"银两副本",9001,20,1,0,"5万-30万","10万-60万",140193,"攻击我能获得银两，对我的伤害越高，获得的奖励越多哦！",31013,1,1000,1,0,10000,60000,1,0,16000,150000,1,0,22000,300000,1,0,28000,450000,1,0,34000,600000,1,0,40000,900000,1,0,46000,1500000,1,0,52000,},
    [2] = {2,2,"银龙宝宝",9002,20,4,2002,"2个-10个","4个-20个",14016,"攻击我能获得银龙宝宝，能在我手下下坚持越久，奖励越高哦！",31001,2,1,4,2002,2,2,4,2002,3,3,4,2002,4,4,4,2002,5,6,4,2002,7,8,4,2002,8,10,4,2002,9,12,4,2002,10,},
    [3] = {3,2,"经验银印",9003,50,7,1,"2个-10个","4个-20个",14005,"攻击我能获得经验银印，能在我手下下坚持越久，奖励越高哦！",31002,3,1,7,1,2,2,7,1,3,3,7,1,4,4,7,1,5,6,7,1,7,8,7,1,8,10,7,1,9,12,7,1,10,},
    [4] = {4,1,"突破石",9004,20,3,6,"40个-200个","80个-400个",130023,"攻击我能获得突破石，对我的伤害越高，获得的奖励越多哦！",31013,4,20000,3,6,4,50000,3,6,8,150000,3,6,12,300000,3,6,16,450000,3,6,22,600000,3,6,28,900000,3,6,34,1500000,3,6,40,},
    [5] = {5,1,"培养丹",9005,30,3,9,"20个-100个","40个-200个",130083,"攻击我能获得培养丹，对我的伤害越高，获得的奖励越多哦！",31001,5,20000,3,9,2,50000,3,9,4,150000,3,9,6,300000,3,9,8,450000,3,9,10,600000,3,9,12,900000,3,9,16,1500000,3,9,20,},
    [6] = {6,1,"装备精炼",9006,20,3,10,"20个-100个","40个-200个",11016,"攻击我能获得初级精炼石，对我的伤害越高，获得的奖励越多哦！",31002,6,20000,3,10,2,50000,3,10,4,150000,3,10,6,300000,3,10,8,450000,3,10,10,600000,3,10,12,900000,3,10,16,1500000,3,10,20,},
    [7] = {7,1,"宝物精炼",9007,50,3,18,"20个-100个","40个-200个",11014,"攻击我能获得宝物精炼石，对我的伤害越高，获得的奖励越多哦！",31013,7,20000,3,18,2,50000,3,18,4,150000,3,18,6,300000,3,18,8,450000,3,18,10,600000,3,18,12,900000,3,18,16,1500000,3,18,20,},
    [8] = {8,2,"天命石",9008,75,3,14,"10个-50个","20个-100个",11009,"攻击我能获得天命石，能在我手下下坚持越久，奖励越高哦！",31001,8,1,3,14,10,2,3,14,15,3,3,14,20,4,3,14,25,6,3,14,35,8,3,14,40,10,3,14,45,12,3,14,50,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,

}

local __key_map = {
  id = 1,
  type = 2,
  name = 3,
  monster_team = 4,
  cost = 5,
  output_type = 6,
  output_value = 7,
  output_bewrite = 8,
  output_bewrite_event = 9,
  boss = 10,
  talk = 11,
  map = 12,
  icon_pic = 13,
  extra_ratio_1 = 14,
  extra_type_1 = 15,
  extra_value_1 = 16,
  extra_size_1 = 17,
  extra_ratio_2 = 18,
  extra_type_2 = 19,
  extra_value_2 = 20,
  extra_size_2 = 21,
  extra_ratio_3 = 22,
  extra_type_3 = 23,
  extra_value_3 = 24,
  extra_size_3 = 25,
  extra_ratio_4 = 26,
  extra_type_4 = 27,
  extra_value_4 = 28,
  extra_size_4 = 29,
  extra_ratio_5 = 30,
  extra_type_5 = 31,
  extra_value_5 = 32,
  extra_size_5 = 33,
  extra_ratio_6 = 34,
  extra_type_6 = 35,
  extra_value_6 = 36,
  extra_size_6 = 37,
  extra_ratio_7 = 38,
  extra_type_7 = 39,
  extra_value_7 = 40,
  extra_size_7 = 41,
  extra_ratio_8 = 42,
  extra_type_8 = 43,
  extra_value_8 = 44,
  extra_size_8 = 45,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_dungeon_vip_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function dungeon_vip_info.getLength()
    return #dungeon_vip_info._data
end



function dungeon_vip_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_dungeon_vip_info
function dungeon_vip_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = dungeon_vip_info._data[index]}, m)
    
end

---
--@return @class record_dungeon_vip_info
function dungeon_vip_info.get(id)
    
    return dungeon_vip_info.indexOf(__index_id[id])
        
end



function dungeon_vip_info.set(id, key, value)
    local record = dungeon_vip_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function dungeon_vip_info.get_index_data()
    return __index_id
end