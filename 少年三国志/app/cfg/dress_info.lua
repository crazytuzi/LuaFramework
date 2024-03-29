

---@classdef record_dress_info
local record_dress_info = {}
  
record_dress_info.id = 0 --id  
record_dress_info.name = "" --名称  
record_dress_info.man_res_id = 0 --男性资源id  
record_dress_info.woman_res_id = 0 --女性资源id  
record_dress_info.play_group_id = 0 --播放组  
record_dress_info.release_knight_id = 0 --关联武将  
record_dress_info.quality = 0 --品质  
record_dress_info.potentiality = 0 --潜力  
record_dress_info.basic_type_1 = 0 --基本属性类型1  
record_dress_info.basic_value_1 = 0 --基本属性类型值1  
record_dress_info.basic_type_2 = 0 --基本属性类型2  
record_dress_info.basic_value_2 = 0 --基本属性类型值2  
record_dress_info.strength_type_1 = 0 --强化属性类型1  
record_dress_info.strength_value_1 = 0 --强化属性类型值1  
record_dress_info.strength_type_2 = 0 --强化属性类型2  
record_dress_info.strength_value_2 = 0 --强化属性类型值2  
record_dress_info.strength_type_3 = 0 --强化属性类型3  
record_dress_info.strength_value_3 = 0 --强化属性类型值3  
record_dress_info.strength_type_4 = 0 --强化属性类型4  
record_dress_info.strength_value_4 = 0 --强化属性类型值4  
record_dress_info.cost_money = 0 --强化消耗银币元  
record_dress_info.cost_item = 0 --强化消耗道具元  
record_dress_info.common_skill_id = 0 --自带普攻id  
record_dress_info.skill_res_id_1 = "" --普攻图标资源id  
record_dress_info.common_clear_level = 0 --普攻解锁等级  
record_dress_info.active_skill_id_1 = 0 --自带主动id1  
record_dress_info.skill_res_id_2 = "" --自带主动图标id  
record_dress_info.active_clear_level_1 = 0 --主动1解锁等级  
record_dress_info.active_skill_id_2 = 0 --自带主动id2  
record_dress_info.skill_res_id_3 = 0 --自带主动2图标id  
record_dress_info.active_clear_level_2 = 0 --主动2解锁等级  
record_dress_info.unite_skill_id = 0 --自带合击id  
record_dress_info.skill_res_id_4 = 0 --自带合击图标id  
record_dress_info.unite_clear_level = 0 --合击解锁等级  
record_dress_info.active_skill_id_3 = 0 --自带主动id3  
record_dress_info.skill_res_id_5 = 0 --自带主动3图标id  
record_dress_info.active_clear_level_3 = 0 --主动3解锁等级  
record_dress_info.super_unite_skill_id = 0 --超合击技能id  
record_dress_info.sp_unite_des = "" --超合击图标技能描述  
record_dress_info.super_unite_clear_level = 0 --超合击解锁等级  
record_dress_info.compose_id = 0 --关联组合id  
record_dress_info.passive_skill_1 = 0 --时装天赋1  
record_dress_info.strength_level_1 = 0 --天赋1强化等级  
record_dress_info.passive_skill_2 = 0 --时装天赋2  
record_dress_info.strength_level_2 = 0 --天赋2强化等级  
record_dress_info.passive_skill_3 = 0 --时装天赋3  
record_dress_info.strength_level_3 = 0 --天赋3强化等级  
record_dress_info.passive_skill_4 = 0 --时装天赋4  
record_dress_info.strength_level_4 = 0 --天赋4强化等级  
record_dress_info.passive_skill_5 = 0 --时装天赋5  
record_dress_info.strength_level_5 = 0 --天赋5强化等级  
record_dress_info.passive_skill_6 = 0 --时装天赋6  
record_dress_info.strength_level_6 = 0 --天赋6强化等级  
record_dress_info.passive_skill_7 = 0 --时装天赋7  
record_dress_info.strength_level_7 = 0 --天赋7强化等级  
record_dress_info.directions = "" --描述


dress_info = {
   _data = {
    [1] = {101,"孟获时装",10014,10044,10,20199,4,18,17,50,18,50,6,11,5,140,3,7,4,7,300,20,201881,1011,0,201882,1012,0,201882,0,160,201884,1014,160,201882,0,240,0,"0",240,1,6011,40,6012,80,6013,120,6014,160,6015,200,6016,240,6017,300,"主角时装，穿上后可以拥有孟获的技能，同时拥有孟获时装，祝融时装，可以激活额外属性。",},
    [2] = {102,"祝融时装",10015,10045,20,20188,4,18,17,20,18,20,6,11,5,140,3,7,4,7,300,20,201991,1021,0,201992,1022,0,201992,0,160,201994,1014,160,201992,0,240,0,"0",240,1,6021,40,6022,80,6023,120,6024,160,6025,200,6026,240,6027,300,"主角时装，穿上后可以拥有祝融的技能，同时拥有孟获时装，祝融时装，可以激活额外属性。",},
    [3] = {201,"太史慈时装",10017,10047,10,30012,5,20,6,1000,13,200,6,14,5,180,3,9,4,9,540,30,300341,2011,0,300342,2012,0,300342,0,160,300344,2014,160,300342,0,240,0,"0",240,2,6031,40,6032,80,6033,120,6034,160,6035,200,6036,240,6037,300,"主角时装，穿上后可以拥有太史慈的技能，同时拥有太史慈时装，孙策时装，可以激活额外属性。",},
    [4] = {202,"孙策时装",10016,10046,20,30034,5,20,6,500,13,100,6,14,5,180,3,9,4,9,540,30,300121,2021,0,300122,2022,0,300122,0,160,300124,2014,160,300122,0,240,0,"0",240,2,6041,40,6042,80,6043,120,6044,160,6045,200,6046,240,6047,300,"主角时装，穿上后可以拥有孙策的技能，同时拥有太史慈时装，孙策时装，可以激活额外属性。",},
    [5] = {301,"张辽时装",10020,10050,10,10122,5,20,6,1000,16,200,6,14,5,180,3,9,4,9,540,30,100451,3011,0,100452,3012,0,100452,0,160,100454,3013,160,100452,0,240,0,"0",240,3,6051,40,6052,80,6053,120,6054,160,6055,200,6056,240,6057,300,"主角时装，穿上后可以拥有张辽的技能，同时拥有张辽时装，张郃时装，可以激活额外属性。",},
    [6] = {302,"张郃时装",10024,10051,20,10045,5,20,6,500,16,100,6,14,5,180,3,9,4,9,540,30,101221,3021,0,101222,3022,0,101222,0,160,101224,3013,160,101222,0,240,0,"0",240,3,6061,40,6062,80,6063,120,6064,160,6065,200,6066,240,6067,300,"主角时装，穿上后可以拥有张郃的技能，同时拥有张辽时装，张郃时装，可以激活额外属性。",},
    [7] = {401,"赵云时装",10026,10053,10,20045,5,20,6,1000,15,200,6,14,5,180,3,9,4,9,540,30,200231,4011,0,200232,4012,0,200232,0,160,200234,4013,160,200232,0,240,0,"0",240,4,6071,40,6072,80,6073,120,6074,160,6075,200,6076,240,6077,300,"主角时装，穿上后可以拥有赵云的技能，同时拥有赵云时装，黄忠时装，可以激活额外属性。",},
    [8] = {402,"黄忠时装",10025,10052,20,20023,5,20,6,500,15,100,6,14,5,180,3,9,4,9,540,30,200451,4021,0,200452,4022,0,200452,0,160,200454,4013,160,200452,0,240,0,"0",240,4,6081,40,6082,80,6083,120,6084,160,6085,200,6086,240,6087,300,"主角时装，穿上后可以拥有黄忠的技能，同时拥有赵云时装，黄忠时装，可以激活额外属性。",},
    [9] = {501,"张角时装",10019,10049,10,40056,5,20,6,1000,14,200,6,14,5,180,3,9,4,9,540,30,401881,5011,0,401882,5012,0,401882,0,160,401884,5013,160,401882,0,240,0,"0",240,5,6091,40,6092,80,6093,120,6094,160,6095,200,6096,240,6097,300,"主角时装，穿上后可以拥有张角的技能，同时拥有张角时装，于吉时装，可以激活额外属性。",},
    [10] = {502,"于吉时装",10018,10048,20,40188,5,20,6,500,14,100,6,14,5,180,3,9,4,9,540,30,400561,5021,0,400562,5022,0,400562,0,160,400564,5013,160,400562,0,240,0,"0",240,5,6101,40,6102,80,6103,120,6104,160,6105,200,6106,240,6107,300,"主角时装，穿上后可以拥有于吉的技能，同时拥有张角时装，于吉时装，可以激活额外属性。",},
    [11] = {601,"蔡文姬时装",10027,10054,10,20144,5,20,6,1000,21,500,6,14,5,180,3,9,4,9,540,30,400341,6011,0,400342,6012,0,400342,0,160,400344,6013,160,400342,0,240,0,"0",240,6,6111,40,6112,80,6113,120,6114,160,6115,200,6116,240,6117,300,"主角时装，穿上后可以拥有蔡文姬的技能，同时拥有蔡文姬时装，黄月英时装，可以激活额外属性。",},
    [12] = {602,"黄月英时装",10028,10055,20,40034,5,20,6,500,21,250,6,14,5,180,3,9,4,9,540,30,201441,6021,0,201442,6022,0,201442,0,160,201444,6013,160,201442,0,240,0,"0",240,6,6121,40,6122,80,6123,120,6124,160,6125,200,6126,240,6127,300,"主角时装，穿上后可以拥有黄月英的技能，同时拥有黄月英时装，蔡文姬时装，可以激活额外属性。",},
    [13] = {701,"荀彧时装",10034,10056,10,10012,6,23,5,100000,20,1,6,17,5,200,3,10,4,10,880,50,100561,7011,0,100562,7012,0,100562,0,160,100564,7013,160,100563,0,240,100569,"对所有敌人造成#num1#%#damage_type#伤害#test#，20%概率造成眩晕，敌人受到的伤害增加20%，持续2回合【与曹仁共同出战可触发】",240,7,6131,40,6132,80,6133,120,6134,160,6135,200,6136,240,6137,300,"主角时装，穿上后可以拥有荀彧时装的技能.",},
    [14] = {702,"诸葛亮时装",10035,10057,10,20111,6,23,5,100000,20,1,6,17,5,200,3,10,4,10,880,50,200781,7021,0,200782,7022,0,200782,0,160,200784,7023,160,200783,0,240,200789,"对前排敌人造成#num1#%#damage_type#伤害#test#，减少2点怒气，35%概率造成眩晕【与姜维共同出战可触发】",240,7,6141,40,6142,80,6143,120,6144,160,6145,200,6146,240,6147,300,"主角时装，穿上后可以拥有诸葛亮时装的技能.",},
    [15] = {703,"孙坚时装",10036,10058,10,30089,6,23,6,30000,20,1,6,17,5,200,3,10,4,10,880,50,300011,7031,0,300012,7032,0,300012,0,160,300014,7033,160,300013,0,240,300019,"对一列敌人造成#num1#%#damage_type#伤害#test#，清除对方所有增益状态，我方全体武将伤害加成与伤害减免提高15%，持续2回合【与甘宁共同出战可触发】",240,8,6151,40,6152,80,6153,120,6154,160,6155,200,6156,240,6157,300,"主角时装，穿上后可以拥有孙坚时装的技能.",},
    [16] = {704,"吕布时装",10037,10059,10,40023,6,23,6,30000,20,1,6,17,5,200,3,10,4,10,880,50,400011,7041,0,400012,7042,0,400012,0,160,400014,7043,160,400013,0,240,400019,"对所有敌人造成#num1#%#damage_type#伤害#test#，20%概率造成眩晕，本次攻击必命中，必暴击。【与貂蝉共同出战可触发】",240,8,6161,40,6162,80,6163,120,6164,160,6165,200,6166,240,6167,300,"主角时装，穿上后可以拥有吕布时装的技能.",},
	[17] = {705,"曹操时装",10104,10066,10,10067,6,23,6,30000,20,1,6,17,5,200,3,10,4,10,880,50,100011,7051,0,100012,7052,0,100012,0,160,100014,7053,160,100013,0,240,100019,"对所有敌人造成#num1#%#damage_type#伤害#test#，20%概率造成眩晕，本次攻击必命中，必暴击。【与郭嘉共同出战可触发】",240,9,6201,40,6202,80,6203,120,6204,160,6205,200,6206,240,6207,300,"主角时装，穿上后可以拥有曹操时装的技能.",},
	[18] = {706,"关羽时装",10102,10064,10,20012,6,23,6,30000,20,1,6,17,5,200,3,10,4,10,880,50,200011,7061,0,200012,7062,0,200012,0,160,200014,7063,160,200013,0,240,200019,"对所有敌人造成#num1#%#damage_type#伤害#test#，20%概率造成眩晕，本次攻击必命中，必暴击。【与张飞共同出战可触发】",240,9,6301,40,6302,80,6303,120,6304,160,6305,200,6306,240,6307,300,"主角时装，穿上后可以拥有关羽时装的技能.",},
	[19] = {707,"周瑜时装",10103,10065,10,30144,6,23,5,100000,20,1,6,17,5,200,3,10,4,10,880,50,300451,7071,0,300452,7072,0,300452,0,160,300454,7073,160,300453,0,240,300459,"对所有敌人造成#num1#%#damage_type#伤害#test#，20%概率造成眩晕，本次攻击必命中，必暴击。【与小乔共同出战可触发】",240,10,6401,40,6402,80,6403,120,6404,160,6405,200,6406,240,6407,300,"主角时装，穿上后可以拥有周瑜时装的技能.",},
	[20] = {708,"左慈时装",10101,10063,10,40177,6,23,5,100000,20,1,6,17,5,200,3,10,4,10,880,50,400451,7081,0,400452,7082,0,400452,0,160,400454,7083,160,400453,0,240,400459,"对所有敌人造成#num1#%#damage_type#伤害#test#，20%概率造成眩晕，本次攻击必命中，必暴击。【与华佗共同出战可触发】",240,10,6501,40,6502,80,6503,120,6504,160,6505,200,6506,240,6507,300,"主角时装，穿上后可以拥有左慈时装的技能.",},
    }
}



local __index_id = {
    [101] = 1,
    [102] = 2,
    [201] = 3,
    [202] = 4,
    [301] = 5,
    [302] = 6,
    [401] = 7,
    [402] = 8,
    [501] = 9,
    [502] = 10,
    [601] = 11,
    [602] = 12,
    [701] = 13,
    [702] = 14,
    [703] = 15,
    [704] = 16,
    [705] = 17,
	[706] = 18,
	[707] = 19,
	[708] = 20,

}

local __key_map = {
  id = 1,
  name = 2,
  man_res_id = 3,
  woman_res_id = 4,
  play_group_id = 5,
  release_knight_id = 6,
  quality = 7,
  potentiality = 8,
  basic_type_1 = 9,
  basic_value_1 = 10,
  basic_type_2 = 11,
  basic_value_2 = 12,
  strength_type_1 = 13,
  strength_value_1 = 14,
  strength_type_2 = 15,
  strength_value_2 = 16,
  strength_type_3 = 17,
  strength_value_3 = 18,
  strength_type_4 = 19,
  strength_value_4 = 20,
  cost_money = 21,
  cost_item = 22,
  common_skill_id = 23,
  skill_res_id_1 = 24,
  common_clear_level = 25,
  active_skill_id_1 = 26,
  skill_res_id_2 = 27,
  active_clear_level_1 = 28,
  active_skill_id_2 = 29,
  skill_res_id_3 = 30,
  active_clear_level_2 = 31,
  unite_skill_id = 32,
  skill_res_id_4 = 33,
  unite_clear_level = 34,
  active_skill_id_3 = 35,
  skill_res_id_5 = 36,
  active_clear_level_3 = 37,
  super_unite_skill_id = 38,
  sp_unite_des = 39,
  super_unite_clear_level = 40,
  compose_id = 41,
  passive_skill_1 = 42,
  strength_level_1 = 43,
  passive_skill_2 = 44,
  strength_level_2 = 45,
  passive_skill_3 = 46,
  strength_level_3 = 47,
  passive_skill_4 = 48,
  strength_level_4 = 49,
  passive_skill_5 = 50,
  strength_level_5 = 51,
  passive_skill_6 = 52,
  strength_level_6 = 53,
  passive_skill_7 = 54,
  strength_level_7 = 55,
  directions = 56,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_dress_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function dress_info.getLength()
    return #dress_info._data
end



function dress_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_dress_info
function dress_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = dress_info._data[index]}, m)
    
end

---
--@return @class record_dress_info
function dress_info.get(id)
    
    return dress_info.indexOf(__index_id[id])
        
end



function dress_info.set(id, key, value)
    local record = dress_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function dress_info.get_index_data()
    return __index_id
end