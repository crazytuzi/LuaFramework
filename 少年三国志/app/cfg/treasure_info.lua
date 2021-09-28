

---@classdef record_treasure_info
local record_treasure_info = {}
  
record_treasure_info.id = 0 --编号  
record_treasure_info.name = "" --宝物名称  
record_treasure_info.type = 0 --宝物类型  
record_treasure_info.potentiality = 0 --宝物潜力  
record_treasure_info.open_level = 0 --夺宝开启等级  
record_treasure_info.star = 0 --宝物星级  
record_treasure_info.quality = 0 --宝物品质  
record_treasure_info.wear_level = 0 --可穿戴等级  
record_treasure_info.is_strength = 0 --是否可强化和精练  
record_treasure_info.is_basic = 0 --是否长期显示  
record_treasure_info.strength_type_1 = 0 --强化属性类型1  
record_treasure_info.strength_value_1 = 0 --初始强化属性值1  
record_treasure_info.strength_growth_1 = 0 --属性成长率1  
record_treasure_info.strength_type_2 = 0 --强化属性类型2  
record_treasure_info.strength_value_2 = 0 --初始强化属性值2  
record_treasure_info.strength_growth_2 = 0 --属性成长率2  
record_treasure_info.exp = 0 --初始消耗经验  
record_treasure_info.exp_growth = 0 --经验消耗成长  
record_treasure_info.supply_exp = 0 --作为材料提供经验值  
record_treasure_info.advance_type_1 = 0 --精练能力类型1  
record_treasure_info.advance_value_1 = 0 --精练能力类型值1  
record_treasure_info.advance_growth_1 = 0 --精练能力成长率1  
record_treasure_info.advance_type_2 = 0 --精练能力类型2  
record_treasure_info.advance_value_2 = 0 --精练能力类型值2  
record_treasure_info.advance_growth_2 = 0 --精练能力成长率2  
record_treasure_info.res_id = 0 --宝物ICON  
record_treasure_info.directions = "" --宝物描述  
record_treasure_info.gm = 0 --GM后台是否可发  
record_treasure_info.is_sold = 0 --是否可出售  
record_treasure_info.price_type = 0 --出售价格类型  
record_treasure_info.price = 0 --出售价格类型值  
record_treasure_info.compose_id = 0 --组合id  
record_treasure_info.fragment_id = 0 --展示碎片id  
record_treasure_info.equipment_skill_1 = 0 --神兵技能id1  
record_treasure_info.equipment_skill_2 = 0 --神兵技能id2  
record_treasure_info.equipment_skill_3 = 0 --神兵技能id3  
record_treasure_info.equipment_skill_4 = 0 --神兵技能id4  
record_treasure_info.equipment_skill_5 = 0 --神兵技能id5  
record_treasure_info.equipment_skill_6 = 0 --神兵技能id6  
record_treasure_info.equipment_skill_7 = 0 --神兵技能id7  
record_treasure_info.equipment_skill_8 = 0 --神兵技能id8  
record_treasure_info.equipment_skill_9 = 0 --神兵技能id9  
record_treasure_info.equipment_skill_10 = 0 --神兵技能id10  
record_treasure_info.forge_id = 0 --铸造后的宝物id  
record_treasure_info.forge_price = 0 --铸造花费类型


treasure_info = {
   _data = {
    [1] = {101,"司马法",1,13,1,3,3,1,1,1,6,20,20,15,2,2,100,20,1200,12,10,10,13,10,10,22001,"齐国司马穰苴整理成文，是现存中国最古老的兵法书。",1,1,1,1000,101,1011,0,0,0,0,0,0,0,0,0,0,0,0,},
    [2] = {102,"火鼠印",2,13,1,3,3,1,1,1,5,200,200,14,2,2,100,20,1200,11,10,10,16,10,10,22002,"火鼠为传说灵兽，可以在火中生存，以它形象铸印，寓意不惧火伤。",1,1,1,1000,102,1021,0,0,0,0,0,0,0,0,0,0,0,0,},
    [3] = {103,"三略",1,13,1,3,3,1,1,1,6,20,20,13,2,2,100,20,1200,12,10,10,15,10,10,22021,"此书不同于其他兵书。它是一部糅合了诸子各家的思想，专论战略的兵书。",1,1,1,1000,103,1031,0,0,0,0,0,0,0,0,0,0,0,0,},
    [4] = {104,"嬴鱼印",2,13,1,3,3,1,1,1,5,200,200,16,2,2,100,20,1200,11,10,10,14,10,10,22022,"嬴鱼为传说灵兽，鱼身而鸟翼，以它形象铸印，寓意不惧水袭。",1,1,1,1000,104,1041,0,0,0,0,0,0,0,0,0,0,0,0,},
    [5] = {201,"孙子兵法",1,18,1,4,4,1,1,0,6,40,40,15,4,4,100,40,10000,12,20,20,13,20,20,22003,"春秋时期孙武所著，博大精深，被誉为“兵学圣典”。",1,1,1,1000,201,2011,0,0,0,0,0,0,0,0,0,0,0,0,},
    [6] = {202,"天马印",2,18,1,4,4,1,1,0,5,400,400,14,4,4,100,40,10000,11,20,20,16,20,20,22004,"天马为传说灵兽，无翼却可腾云飞翔，以它形象铸印，寓意行军神速。",1,1,1,1000,202,2021,0,0,0,0,0,0,0,0,0,0,0,0,},
    [7] = {203,"吴子兵书",1,18,1,4,4,1,1,0,6,40,40,13,4,4,100,40,10000,12,20,20,15,20,20,22023,"战国名将吴起著，主要论述战争观问题，认为只有内修文外治武，才能使国家强盛。",1,1,1,1000,203,2031,0,0,0,0,0,0,0,0,0,0,0,0,},
    [8] = {204,"腾蛇印",2,18,1,4,4,1,1,0,5,400,400,16,4,4,100,40,10000,11,20,20,14,20,20,22024,"传说一种能飞的蛇，能腾云驾雾，以它形象铸印，寓意做事必能成功！",1,1,1,1000,204,2041,0,0,0,0,0,0,0,0,0,0,0,0,},
    [9] = {301,"太平要术",1,20,1,5,5,1,1,0,6,60,60,15,6,6,100,60,20000,12,30,30,13,30,30,22005,"于吉曾于汉顺帝时入山采药，忽视有书浮于水。取而观之，名太平要术。",1,1,1,1000,301,3011,0,0,0,0,0,0,0,0,0,0,401,1,},
    [10] = {302,"朱雀印",2,20,1,5,5,1,1,0,5,600,600,14,6,6,100,60,20000,11,30,30,16,30,30,22006,"古代神兽之一，为火焰化身，能浴火重生，以它形象铸印，寓意坚忍不拔",1,1,1,1000,302,3021,0,0,0,0,0,0,0,0,0,0,402,1,},
    [11] = {303,"太公兵法",1,20,1,5,5,1,1,0,6,60,60,13,6,6,100,60,20000,12,30,30,15,30,30,22025,"姜子牙所著兵法名篇，其内容博大精深，对有关战争和各方面问题都有涉及。",1,1,1,1000,303,3031,0,0,0,0,0,0,0,0,0,0,403,1,},
    [12] = {304,"玄武印",2,20,1,5,5,1,1,0,5,600,600,16,6,6,100,60,20000,11,30,30,14,30,30,22026,"古代神兽之一，龙头龟身蛇尾，寿命绵长，以它形象铸印，寓意长寿绵延。",1,1,1,1000,304,3041,0,0,0,0,0,0,0,0,0,0,404,1,},
    [13] = {401,"孟德新书",1,23,1,6,6,1,1,0,6,400,80,15,8,8,100,80,50000,12,40,40,13,40,40,22007,"曹操半生戎马，在前人的基础上总结并创新，成就了这本孟德新书。",1,1,1,1000,401,4011,501,502,503,504,505,506,507,508,0,0,0,0,},
    [14] = {402,"猛虎印",2,23,1,6,6,1,1,0,5,4000,800,14,8,8,100,80,50000,11,40,40,16,40,40,22027,"猛虎下山，如待时而起之人才，以之为印，寓意才能得以施展。",1,1,1,1000,402,4021,601,602,603,604,605,606,607,608,0,0,0,0,},
    [15] = {403,"鬼谷子",1,23,1,6,6,1,1,0,6,400,80,13,8,8,100,80,50000,12,40,40,15,40,40,22028,"鬼谷子为纵横家之鼻祖，通天彻地，人不能及。著有《鬼谷子》兵书十四篇传世。",1,1,1,1000,403,4031,501,502,503,504,505,506,507,508,0,0,0,0,},
    [16] = {404,"麒麟印",2,23,1,6,6,1,1,0,5,4000,800,16,8,8,100,80,50000,11,40,40,14,40,40,22029,"麒麟为上古神兽，体态优美，主祥瑞，以之为印，寓意貌美才高",1,1,1,1000,404,4041,601,602,603,604,605,606,607,608,0,0,0,0,},
    [17] = {501,"遁甲天书",1,25,1,7,7,1,1,0,6,100,100,15,10,10,100,100,100000,12,50,50,13,50,50,22009,"左慈常年在峨眉山修行，忽然有雷震碎石壁，露出‘天书三卷’，即为此书。",1,1,1,1000,501,5011,0,0,0,0,0,0,0,0,0,0,0,0,},
    [18] = {502,"卧龙印",2,25,1,7,7,1,1,0,5,1000,1000,14,10,10,100,100,100000,11,50,50,16,50,50,22008,"龙为神兽，能行云雨利万物，卧龙为诸葛亮别号，卧龙凤雏，得一而可安天下。",1,1,1,1000,502,5021,0,0,0,0,0,0,0,0,0,0,0,0,},
    [19] = {503,"阴符经",1,25,1,7,7,1,1,0,6,100,100,13,10,10,100,100,100000,12,50,50,15,50,50,22030,"此书据传为黄帝所著，言简意赅，历来为学者所重视，因此注本浩繁。",1,1,1,1000,503,5031,0,0,0,0,0,0,0,0,0,0,0,0,},
    [20] = {504,"凤雏印",2,25,1,7,7,1,1,0,5,1000,1000,16,10,10,100,100,100000,11,50,50,14,50,50,22010,"凤为神兽，百鸟之首，主吉瑞，凤雏是庞统别号，卧龙凤雏，得一而可安天下。",1,1,1,1000,504,5041,0,0,0,0,0,0,0,0,0,0,0,0,},
    [21] = {1,"白银经验宝物",3,13,0,3,3,1,2,0,6,10,0,0,0,0,0,0,2500,0,0,0,0,0,0,22011,"由宫廷流传出来的神秘宝物，通体由白银铸造，可用于宝物强化，提供2500点宝物经验",1,1,1,1000,1,11,0,0,0,0,0,0,0,0,0,0,0,0,},
    [22] = {2,"黄金经验宝物",3,20,0,5,4,1,2,0,5,10,0,0,0,0,0,0,99999999,0,0,0,0,0,0,22012,"由天师张道陵祭炼的宝物，通体由黄金铸造，可用于宝物强化，提供99999999点宝物经验",1,1,1,1000,2,21,0,0,0,0,0,0,0,0,0,0,0,0,},
    [23] = {3,"青铜经验宝物",3,12,0,2,2,1,2,0,5,10,0,0,0,0,0,0,500,0,0,0,0,0,0,22031,"在宝物重生功能中，小额的强化经验会以青铜经验宝物的形式返还，提供500点宝物经验",1,1,1,1000,0,31,0,0,0,0,0,0,0,0,0,0,0,0,},
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
    [3] = 23,
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
  name = 2,
  type = 3,
  potentiality = 4,
  open_level = 5,
  star = 6,
  quality = 7,
  wear_level = 8,
  is_strength = 9,
  is_basic = 10,
  strength_type_1 = 11,
  strength_value_1 = 12,
  strength_growth_1 = 13,
  strength_type_2 = 14,
  strength_value_2 = 15,
  strength_growth_2 = 16,
  exp = 17,
  exp_growth = 18,
  supply_exp = 19,
  advance_type_1 = 20,
  advance_value_1 = 21,
  advance_growth_1 = 22,
  advance_type_2 = 23,
  advance_value_2 = 24,
  advance_growth_2 = 25,
  res_id = 26,
  directions = 27,
  gm = 28,
  is_sold = 29,
  price_type = 30,
  price = 31,
  compose_id = 32,
  fragment_id = 33,
  equipment_skill_1 = 34,
  equipment_skill_2 = 35,
  equipment_skill_3 = 36,
  equipment_skill_4 = 37,
  equipment_skill_5 = 38,
  equipment_skill_6 = 39,
  equipment_skill_7 = 40,
  equipment_skill_8 = 41,
  equipment_skill_9 = 42,
  equipment_skill_10 = 43,
  forge_id = 44,
  forge_price = 45,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_treasure_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function treasure_info.getLength()
    return #treasure_info._data
end



function treasure_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_treasure_info
function treasure_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = treasure_info._data[index]}, m)
    
end

---
--@return @class record_treasure_info
function treasure_info.get(id)
    
    return treasure_info.indexOf(__index_id[id])
        
end



function treasure_info.set(id, key, value)
    local record = treasure_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function treasure_info.get_index_data()
    return __index_id
end