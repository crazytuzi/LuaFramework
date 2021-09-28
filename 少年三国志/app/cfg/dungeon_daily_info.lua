

---@classdef record_dungeon_daily_info
local record_dungeon_daily_info = {}
  
record_dungeon_daily_info.id = 0 --id  
record_dungeon_daily_info.dungeon_type = 0 --所属类型  
record_dungeon_daily_info.name = "" --副本名称  
record_dungeon_daily_info.monster_image = 0 --怪物形象  
record_dungeon_daily_info.monster_name = "" --怪物名称  
record_dungeon_daily_info.pic_icon = 0 --怪物头像  
record_dungeon_daily_info.talk = "" --气泡里的话  
record_dungeon_daily_info.expend = 0 --每次消耗体力数  
record_dungeon_daily_info.level_1 = 0 --难度1开启等级  
record_dungeon_daily_info.monster_team_id_1 = 0 --难度1怪物组ID  
record_dungeon_daily_info.monster_fight_1 = 0 --难度1战斗力  
record_dungeon_daily_info.level_2 = 0 --难度2开启等级  
record_dungeon_daily_info.monster_team_id_2 = 0 --难度2怪物组id  
record_dungeon_daily_info.monster_fight_2 = 0 --难度2战斗力  
record_dungeon_daily_info.level_3 = 0 --难度3开启等级  
record_dungeon_daily_info.monster_team_id_3 = 0 --难度3怪物id  
record_dungeon_daily_info.monster_fight_3 = 0 --难度3战斗力  
record_dungeon_daily_info.level_4 = 0 --难度4开启等级  
record_dungeon_daily_info.monster_team_id_4 = 0 --难度4怪物id  
record_dungeon_daily_info.monster_fight_4 = 0 --难度4战斗力  
record_dungeon_daily_info.level_5 = 0 --难度5开启等级  
record_dungeon_daily_info.monster_team_id_5 = 0 --难度5怪物id  
record_dungeon_daily_info.monster_fight_5 = 0 --难度5战斗力  
record_dungeon_daily_info.level_6 = 0 --难度6开启等级  
record_dungeon_daily_info.monster_team_id_6 = 0 --难度6怪物id  
record_dungeon_daily_info.monster_fight_6 = 0 --难度6战斗力  
record_dungeon_daily_info.type = 0 --掉落道具类型  
record_dungeon_daily_info.value = 0 --掉落道具类型值  
record_dungeon_daily_info.min_size_1 = 0 --难度1掉落道具数量最小  
record_dungeon_daily_info.max_size_1 = 0 --难度1掉落道具数量最大  
record_dungeon_daily_info.min_size_2 = 0 --难度2掉落道具数量最小  
record_dungeon_daily_info.max_size_2 = 0 --难度2掉落道具数量最大  
record_dungeon_daily_info.min_size_3 = 0 --难度3掉落道具数量最小  
record_dungeon_daily_info.max_size_3 = 0 --难度3掉落道具数量最大  
record_dungeon_daily_info.min_size_4 = 0 --难度4掉落道具数量最小  
record_dungeon_daily_info.max_size_4 = 0 --难度4掉落道具数量最大  
record_dungeon_daily_info.min_size_5 = 0 --难度5掉落道具数量最小  
record_dungeon_daily_info.max_size_5 = 0 --难度5掉落道具数量最大  
record_dungeon_daily_info.min_size_6 = 0 --难度6掉落道具数量最小  
record_dungeon_daily_info.max_size_6 = 0 --难度6掉落道具数量最大


dungeon_daily_info = {
   _data = {
    [1] = {101,1,"突破石",13002,"鲁肃",4,"击败我可以获得大量突破石~",30,50,71001,447556,70,71002,2000073,85,71003,6526996,105,71004,35919956,125,71005,80000000,150,71006,122220000,3,6,400,400,800,800,1200,1200,1600,1600,2000,2000,2400,2400,},
    [2] = {102,1,"金龙宝宝",12009,"诸葛亮",10,"挑战的难度越大，获得的奖励越多~",10,25,75001,48747,50,75002,508250,75,75003,2935189,100,75004,27538277,125,75005,80000000,150,75006,122220000,4,2003,8,8,16,16,24,24,32,32,40,40,48,48,},
    [3] = {103,1,"银两",14019,"张角",1,"击败我可以获得大量银两~",20,35,73001,191596,60,73002,1060020,80,73003,4506318,105,73004,35919956,125,73005,80000000,150,73006,122220000,1,0,1260000,1260000,2500000,2500000,3760000,3760000,5000000,5000000,6240000,6240000,7500000,7500000,},
    [4] = {201,2,"极品精炼石",11002,"曹操",9,"想要获得极品精炼石，就来挑战我吧！",20,35,74001,191596,60,74002,1060020,80,74003,4506318,105,74004,35919956,125,74005,80000000,150,74006,122220000,3,13,60,60,120,120,180,180,240,240,300,300,360,360,},
    [5] = {202,2,"黄金经验宝物",14005,"吕布",3,"提升等级可以解锁更多难度，难度越大胜利奖励越丰富哦~",10,25,72001,48747,50,72002,508250,75,72003,2935189,100,72004,27538277,125,72005,80000000,150,72006,122220000,7,2,8,8,16,16,24,24,32,32,40,40,48,48,},
    [6] = {203,2,"宝物精炼石",11014,"乐进",7,"击败我可以获得大量宝物精炼石~",30,50,76001,447556,70,76002,2000057,85,76003,6526974,105,76004,35919956,125,76005,80000000,150,76006,122220000,3,18,400,400,800,800,1200,1200,1600,1600,2000,2000,2400,2400,},
    }
}



local __index_id = {
    [101] = 1,
    [102] = 2,
    [103] = 3,
    [201] = 4,
    [202] = 5,
    [203] = 6,

}

local __key_map = {
  id = 1,
  dungeon_type = 2,
  name = 3,
  monster_image = 4,
  monster_name = 5,
  pic_icon = 6,
  talk = 7,
  expend = 8,
  level_1 = 9,
  monster_team_id_1 = 10,
  monster_fight_1 = 11,
  level_2 = 12,
  monster_team_id_2 = 13,
  monster_fight_2 = 14,
  level_3 = 15,
  monster_team_id_3 = 16,
  monster_fight_3 = 17,
  level_4 = 18,
  monster_team_id_4 = 19,
  monster_fight_4 = 20,
  level_5 = 21,
  monster_team_id_5 = 22,
  monster_fight_5 = 23,
  level_6 = 24,
  monster_team_id_6 = 25,
  monster_fight_6 = 26,
  type = 27,
  value = 28,
  min_size_1 = 29,
  max_size_1 = 30,
  min_size_2 = 31,
  max_size_2 = 32,
  min_size_3 = 33,
  max_size_3 = 34,
  min_size_4 = 35,
  max_size_4 = 36,
  min_size_5 = 37,
  max_size_5 = 38,
  min_size_6 = 39,
  max_size_6 = 40,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_dungeon_daily_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function dungeon_daily_info.getLength()
    return #dungeon_daily_info._data
end



function dungeon_daily_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_dungeon_daily_info
function dungeon_daily_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = dungeon_daily_info._data[index]}, m)
    
end

---
--@return @class record_dungeon_daily_info
function dungeon_daily_info.get(id)
    
    return dungeon_daily_info.indexOf(__index_id[id])
        
end



function dungeon_daily_info.set(id, key, value)
    local record = dungeon_daily_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function dungeon_daily_info.get_index_data()
    return __index_id
end