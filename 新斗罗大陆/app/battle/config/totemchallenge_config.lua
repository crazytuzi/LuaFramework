--[[
kind:
1:指定队伍死亡后全体获取怒气  value = {value = 怒气值, is_teammate = true是己方否则是敌方}
2.指定队伍释放大招后，释放大招的人回复x%的生命值  value:回复的百分比
3.指定队伍死亡后，对敌方全体造成伤害 value = {value = 伤害血量的百分比, ignore_absorb = true/false 是否无视护盾, 默认false}
4.指定队伍死亡后，对击杀者造成伤害 value = {value = 伤害血量的百分比, ignore_absorb = true/false 是否无视护盾, 默认false}
5.指定队伍中某个魂师死亡后同时对击杀者造成100%无视护盾无视防御的伤害
6.指定队伍获得，全体增加属性，value = {{"属性", 值}, {"属性", 值}}这样的数组
7.指定队伍获得:反伤 value = {physical = 物理反伤 ,magic = 法术反伤}
8.指定队伍获得:吸血 value = {physical = 物理吸血 ,magic = 法术吸血}
9.指定魂师增加属性，格式如同6
10.指定魂师免死，只有当队友死干净后才能死【有特效】
11.指定魂师有队友时无敌【有特效】
12.指定魂师有队友时反伤, value:反伤的系数【有特效】
13.指定队伍每x秒获得一个buff, value = {interval=时间间隔, buff_id=buff的id}
14.指定队伍每x秒会集火血量最少的敌人,value = {interval=时间间隔, duration=持续时间}【有特效】
15.指定队伍有人死亡则触发奉献伤害/回血,value = {interval=时间间隔, duration=持续时间, value=血量百分比系数, type = 1/伤害,2/回血}【有特效】
16.指定队伍反射一切控制效果, value =  {“status1”, “status2”}要反射的status列表
17.指定队伍开场对指定玩家释放一个技能,value=skillId
18.指定队伍获得每击杀一个敌人魂师，降低敌方治疗量, value = 降低的治疗量
19.指定队伍放逐一个最强的敌人x秒, value放逐的时间【有特效】
20.指定队伍开场增加base*数量的点暴击率（只计算开场，过程减员不会降低），队伍每死亡一个魂师，增长value点, value = {base = 基础值, value = 每死亡一个魂师增长的值}
21.指定队伍魔法伤害加深magic%，物理伤害加深physical%, value = {magic = 魔法伤害放大, physical = 物理伤害放大}
22.指定队伍击杀人之后会给己方全体上Buff value = "buff_id"
23.指定队伍每隔x秒会给随机半场的敌人上一个buff,value = {interval = 时间间隔, buff_id = "buff_id"}【有特效】
24.全场每隔x秒斩杀血量低于execute的魂师,value = {execute = 斩杀的血线, interval = 时间间隔}【有特效】
25.全场每隔x秒增加value点的伤势,value = {value = 伤势的百分比（满血%）, interval = 时间间隔}
26.全体被上指定status的buff之后，会再上一个指定id的buff, value = {status = {status1, status2, ...}, buff_id = "要上的buff_id"}；
27.指定队伍治疗转伤害, value = 治疗转伤害的系数
28.指定队伍受到的治疗翻倍, value = 翻倍的系数 (这个是直接乘以value)
29.指定队伍的AOE与单体伤害翻倍, value = {single = 单体系数, aoe = aoe系数}
--]]
--[[
string:tips的内容
string_duration:tips持续时间
string_begin_time:第一次出现的时间，默认0
string_interval:多次tips出现的间隔, 如果不写则只会出现第一次
--]]
--[[
effect_buff_id = "XXXXXXXXXXXXXXXXXXXXXXXXX",
scene_effect = {id = "XXXXXXXXXXXXXXXXXXXXXXXXX", pos = {x = 300, y = 400}, is_lay_on_the_ground = true},
--]]

local totemchallenge_config = {
	-- force_id = 29001,   --测试词缀的debug设置，填写了几就代表了所有词缀都变成对应ID的效果
	-- force_pos = 3,		--填的是词缀生效的位置关系，1是治疗，4是T，（只生效与有需要位置关系的词缀）

	-- 1:指定队伍死亡后地方全体获取怒气  value = {value = 怒气值, is_teammate = true是己方否则是敌方}---------------------------------------------------------------------------------
	[01001] = {
		kind = 1, value = {value = 500, is_teammate = true}, is_hero = false, is_enemy = true, 
		string = "敌人魂师死亡后，敌方全体获取500点能量", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[01002] = {
		kind = 1, value = {value = 300, is_teammate = true}, is_hero = true, is_enemy = true, 
		string = "双方魂师死亡后，其队友全体获取500点能量", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[01003] = {
		kind = 1, value = {value = 300, is_teammate = true}, is_hero = false, is_enemy = true, 
		string = "敌人魂师死亡后，敌方全体获取300点能量", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 2.指定队伍释放大招后，释放大招的人回复x%的生命值  value:回复的百分比----------------------------------------------------------------------------------------------------------
	[02001] = {
		kind = 2, value = 0.35, is_hero = false, is_enemy = true,
		string = "敌方魂师释放大招后，回复自身30%的生命值", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[02002] = {
		kind = 2, value = 0.35, is_hero = true, is_enemy = true,
		string = "所有魂师释放大招后，回复自身30%的生命值", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 3.指定队伍死亡后，对敌方全体造成伤害 value = {value = 伤害血量的百分比, ignore_absorb = true/false 是否无视护盾, 默认false}---------------------------------------------------
	[03001] = {
		kind = 3, value = {value = 0.20, ignore_absorb = false}, is_hero = false, is_enemy = true,
		string = "敌方魂师死亡后，对我方所有魂师造成最大生命值20%的伤害", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[03002] = {
		kind = 3, value = {value = 0.30, ignore_absorb = true}, is_hero = false, is_enemy = true,
		string = "敌方魂师死亡后，对我方所有魂师造成最大生命值30%的无视伤害护盾伤害", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 4.指定队伍死亡后，对击杀者造成伤害 value = {value = 伤害血量的百分比, ignore_absorb = true/false 是否无视护盾, 默认false}-----------------------------------------------------
	[04001] = {
		kind = 4, value = {value = 0.60, ignore_absorb = false}, is_hero = false, is_enemy = true,
		string = "敌方魂师死亡后，对击杀者造成最大生命值60%的伤害", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[04002] = {
		kind = 4, value = {value = 0.60, ignore_absorb = true}, is_hero = false, is_enemy = true,
		string = "敌方魂师死亡后，对击杀者造成最大生命值60%的无视伤害护盾伤害", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 5.指定队伍中某个魂师死亡后同时对击杀者造成100%无视护盾无视防御的伤害----------------------------------------------------------------------------------------------------------
	[05001] = {kind = 5, is_hero = false, is_enemy = true,
		string = "敌方#HERO_NAME#魂师死亡后，直接对击杀者进行斩杀", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 6.指定队伍获得，全体增加属性，value = {{"属性", 值}, {"属性", 值}}这样的数组--------------------------------------------------------------------------------------------------
	[06001] = {kind = 6, value = {{"attack_percent", 0.15}}, is_hero = false, is_enemy = true,
		string = "敌方魂师攻击力提升15%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[06002] = {kind = 6, value = {{"attack_percent", 0.35}}, is_hero = false, is_enemy = true,
		string = "敌方魂师攻击力提升35%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[06003] = {kind = 6, value = {{"armor_magic_percent", 0.5}}, is_hero = false, is_enemy = true,
		string = "敌方魂师法术防御提升50%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[06004] = {kind = 6, value = {{"armor_magic_percent", 0.8}}, is_hero = false, is_enemy = true,
		string = "敌方魂师法术防御提升80%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[06005] = {kind = 6, value = {{"armor_physical_percent", 0.5}}, is_hero = false, is_enemy = true,
		string = "敌方魂师物理防御提升50%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[06006] = {kind = 6, value = {{"armor_physical_percent", 0.8}}, is_hero = false, is_enemy = true,
		string = "敌方魂师物理防御提升80%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[06007] = {kind = 6, value = {{"critical_chance", 0.25}}, is_hero = false, is_enemy = true,
		string = "敌方魂师暴击率提升25%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[06008] = {kind = 6, value = {{"attackspeed_chance", 0.35}}, is_hero = false, is_enemy = true,
		string = "敌方魂师攻速提升35%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 7.指定队伍获得:反伤 value = {physical = 物理反伤 ,magic = 法术反伤}-----------------------------------------------------------------------------------------------------------
	[07001] = {kind = 7, value = {physical = 0.25}, is_hero = false, is_enemy = true,
		string = "敌方魂师反弹25%的物理伤害", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[07002] = {kind = 7, value = {magic = 0.25}, is_hero = false, is_enemy = true,
		string = "敌方魂师反弹25%的法术伤害", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[07003] = {kind = 7, value = {physical = 0.4}, is_hero = false, is_enemy = true,
		string = "敌方魂师反弹40%的物理伤害", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[07004] = {kind = 7, value = {magic = 0.4}, is_hero = false, is_enemy = true,
		string = "敌方魂师反弹40%的法术伤害", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 8.指定队伍获得:吸血 value = {physical = 物理吸血 ,magic = 法术吸血}-----------------------------------------------------------------------------------------------------------
	[08001] = {kind = 8, value = {physical = 0.35}, is_hero = false, is_enemy = true,
		string = "敌方魂师获得35%伤害的物理吸血效果", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[08002] = {kind = 8, value = {magic = 0.35}, is_hero = false, is_enemy = true,
		string = "敌方魂师获得35%伤害的法术吸血效果", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[08003] = {kind = 8, value = {physical = 0.35}, is_hero = true, is_enemy = true,
		string = "双方魂师获得35%伤害的物理吸血效果", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[08004] = {kind = 8, value = {magic = 0.35}, is_hero = true, is_enemy = true,
		string = "双方魂师获得35%伤害的法术吸血效果", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 9.指定魂师增加属性，全体增加属性，value = {{"属性", 值}, {"属性", 值}}这样的数组----------------------------------------------------------------------------------------------
	[09001] = {kind = 9, value = {{"attack_percent", 0.4}}, is_hero = false, is_enemy = true,
		string = "敌方#HERO_NAME#魂师，攻击力提升40%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[09002] = {kind = 9, value = {{"armor_magic_percent", 1.2}}, is_hero = false, is_enemy = true,
		string = "敌方#HERO_NAME#魂师，法术防御提升120%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[09003] = {kind = 9, value = {{"armor_physical_percent", 1.2}}, is_hero = false, is_enemy = true,
		string = "敌方#HERO_NAME#魂师，物理防御提升120%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[09004] = {kind = 9, value = {{"critical_chance", 0.35}}, is_hero = false, is_enemy = true,
		string = "敌方#HERO_NAME#魂师，暴击率提升35%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[09005] = {kind = 9, value = {{"attackspeed_chance", 0.45}}, is_hero = false, is_enemy = true,
		string = "敌方#HERO_NAME#魂师，攻速提升45%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},


	-- 10.指定魂师免死，只有当队友死干净后才能死-------------------------------------------------------------------------------------------------------------------------------------
	[10001] = {kind = 10, is_hero = false, is_enemy = true,
		string = "敌方的#HERO_NAME#魂师获得神赐，若队友在场时该魂师不会死亡", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 11.指定魂师有队友时无敌-------------------------------------------------------------------------------------------------------------------------------------------------------
	[11001] = {kind = 11, is_hero = false, is_enemy = true,
		string = "敌方的#HERO_NAME#魂师获得神赐，若队友在场时该魂师获得无敌", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 12.指定魂师有队友时反伤, value:反伤的系数-------------------------------------------------------------------------------------------------------------------------------------
	[12001] = {kind = 12, value = 0.6, is_hero = false, is_enemy = true,
		string = "敌方的#HERO_NAME#魂师获得神赐，若队友在场时该魂师获得60%的反伤", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[12002] = {kind = 12, value = 0.35, is_hero = false, is_enemy = true,
		string = "敌方的#HERO_NAME#魂师获得神赐，若队友在场时该魂师获得35%的反伤", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 13.指定队伍每x秒获得一个buff, value = {first_time = 初始0S, interval=时间间隔, buff_id=buff的id, , , random_target = true/false(单体/群体)}-----------------------------------
	[13001] = {kind = 13, value = {first_time = 5, interval=10, buff_id= "shengzhutiaozhan_hudun1", random_target = true}, is_hero = false, is_enemy = true,
		string = "每10秒有一名敌人获得35%血量的护盾，且护盾抵消的伤害有一半会治疗该敌人，持续8秒", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[13002] = {kind = 13, value = {first_time = 5, interval=10, buff_id= "shengzhutiaozhan_stun_5s", random_target = true}, is_hero = true, is_enemy = false,
		string = "我方每10秒会随机一个人被眩晕5秒", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[13003] = {kind = 13, value = {first_time = 5, interval=10, buff_id= "shengzhutiaozhan_hudun3", random_target = true}, is_hero = false, is_enemy = true,
		string = "每10秒有一名敌人获得35%血量的护盾，且护盾会持续治疗该英雄，持续20秒", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[13004] = {kind = 13, value = {first_time = 5, interval=10, buff_id= "shengzhutiaozhan_bingdong_6S", random_target = true}, is_hero = true, is_enemy = false,
		string = "我方每10秒会随机一个人被冰冻6秒", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 14.指定队伍每x秒会集火血量最少的敌人,value = {first_time = 初始0S, interval=时间间隔, duration=持续时间}----------------------------------------------------------------------
	[14001] = {kind = 14,value = {first_time = 15, interval = 15, duration = 8}, is_hero = false, is_enemy = true,
		string = "敌人每间隔15秒，会集火血量最少的敌人，持续8秒", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[14002] = {kind = 14,value = {first_time = 10, interval = 10, duration = 10}, is_hero = false, is_enemy = true,
		string = "敌人每间隔10秒，会集火血量最少的敌人，持续10秒", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 	15.指定队伍有人死亡则触发奉献伤害/回血,value = {first_time = 初始0S, interval=时间间隔, duration=持续时间, value=血量百分比系数, type = 1/伤害,2/回血}-----------------------
	[15001] = {kind = 15, value = {first_time = 15, interval = 15, duration = 6, value = 1, type = 2}, is_hero = false, is_enemy = true,
		string = {
			{string = "敌人每间隔15秒，会进入献祭时间，此时敌方魂师死亡后，给全队回满血，持续6秒", string_duration = 10, string_begin_time = 0},
			{string = "进入6秒献祭时间，此时敌人死亡其他敌人将回满血", string_duration = 6, string_begin_time = 15, string_interval = 21},
		},
	},

	-- 	16.指定队伍反射一切控制效果, value =  {“status1”, “status2”}要反射的status列表-----------------------------------------------------------------------------------------------
	[16001] = {kind = 16, value =  {"stun", "fear", "time_stop", "freeze", "petrify", "winding_of_cane", "stun_charge"}, is_hero = false, is_enemy = true,
		string = "敌人会反射一切控制效果（不包含击飞击退）", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
 
	-- 	17.指定队伍开场对指定玩家释放一个技能,value=skillId--------------------------------------------------------------------------------------------------------------------------
	[17001] = {kind = 17, value = 53226, is_hero = false, is_enemy = true,
		string = "敌人开场冰冻所有我们魂师，持续6秒", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 	18.指定队伍获得每击杀一个敌人魂师，降低敌方治疗量, value = 降低的治疗量------------------------------------------------------------------------------------------------------
	[18001] = {kind = 18, value = 0.2, is_hero = true, is_enemy = false,
		string = "我方每击杀一个人，我方治疗量降低20%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[18002] = {kind = 18, value = 0.35, is_hero = true, is_enemy = false,
		string = "我方每击杀一个人，我方治疗量降低35%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 	19.指定队伍放逐一个最强的敌人x秒, value放逐的时间----------------------------------------------------------------------------------------------------------------------------
	[19001] = {kind = 19, value = 10, is_hero = false, is_enemy = true,
		string = "入场时，放逐了你的一个最强的魂师，持续10秒", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[19002] = {kind = 19, value = 15, is_hero = false, is_enemy = true,
		string = "入场时，放逐了你的一个最强的魂师，持续15秒", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 	20.指定队伍开场增加base*数量的点暴击率（只计算开场，过程减员不会降低），队伍每死亡一个魂师，增长value点, value = {base = 基础值, value = 每死亡一个魂师增长的值}-------------
	[20001] = {kind = 20, value = {base = -0.125, value = 0.5}, is_hero = false, is_enemy = true,
		string = "敌方魂师数量越少，暴击率越高", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 	21.指定队伍魔法伤害加深magic%，物理伤害加深physical%, value = {magic = 魔法伤害放大, physical = 物理伤害放大}----------------------------------------------------------------
	[21001] = {kind = 21, value = {magic = 0.2, physical = 0}, is_hero = false, is_enemy = true,
		string = "敌方魂师魔法伤害提升20%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[21002] = {kind = 21, value = {magic = 0, physical = 0.2}, is_hero = false, is_enemy = true,
		string = "敌方魂师物理伤害提升20%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[21003] = {kind = 21, value = {magic = 0.35, physical = 0}, is_hero = false, is_enemy = true,
		string = "敌方魂师魔法伤害提升35%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[21004] = {kind = 21, value = {magic = 0, physical = 0.35}, is_hero = false, is_enemy = true,
		string = "敌方魂师物理伤害提升35%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[21005] = {kind = 21, value = {magic = -0.3, physical = 0}, is_hero = false, is_enemy = true,
		string = "我方魂师魔法伤害降低30%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[21006] = {kind = 21, value = {magic = 0, physical = -0.3}, is_hero = true, is_enemy = false,
		string = "我方魂师物理伤害降低30%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[21007] = {kind = 21, value = {magic = -0.3, physical = -0.3}, is_hero = true, is_enemy = false,
		string = "我方魂师所有伤害降低30%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},


	-- 	22.指定队伍击杀人之后会给己方全体上Buff value = "buff_id"--------------------------------------------------------------------------------------------------------------------
	[22001] = {kind = 22, value = "shengzhutiaozhan_hudun2", is_hero = false, is_enemy = true,
		string = "敌方魂师击杀人之后，全队获得护盾，持续20秒", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},


	-- 	23.指定队伍每隔x秒会给随机半场的敌人上一个buff,value = {first_time = 初始0S, interval = 时间间隔, buff_id = "buff_id"}-------------------------------------------------------
	[23001] = {kind = 23, value = {first_time = 15, interval = 15, buff_id= "shengzhutiaozhan_bingdong_6S"}, is_hero = false, is_enemy = true,
		string = "每15秒，半场会冻住我方魂师6秒", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 	24.全场每隔x秒斩杀血量低于execute的魂师,value = {first_time = 初始0S, execute = 斩杀的血线, interval = 时间间隔}-------------------------------------------------------------
	[24001] = {kind = 24, value = {first_time = 10, execute = 0.25, interval = 10}, is_hero = true, is_enemy = false,
		string = "每10秒，对场上血量低于25%的我方魂师进行斩杀", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[24002] = {kind = 24, value = {first_time = 20, execute = 0.3, interval = 20}, is_hero = true, is_enemy = false,
		string = "每20秒，对场上血量低于30%的我方魂师进行斩杀", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[24003] = {kind = 24, value = {first_time = 20, execute = 0.35, interval = 20}, is_hero = true, is_enemy = true,
		string = "每20秒，对场上血量低于35%的双方魂师进行斩杀", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 	25.全场每隔x秒增加value点的伤势,value = {first_time = 初始0S, value = 伤势的百分比（满血%）, interval = 时间间隔}------------------------------------------------------------
	[25001] = {kind = 25, value = {first_time = 10, value = 0.07, interval = 10}, is_hero = true, is_enemy = true,
		string = "每10秒，对场上我方魂师增加7%最大生命值的伤势", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[25002] = {kind = 25, value = {first_time = 15, value = 0.15, interval = 15}, is_hero = true, is_enemy = true,
		string = "每15秒，对场上我方魂师增加15%最大生命值的伤势", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 	26.全体被上指定status的buff之后，会再上一个指定id的buff, value = {status = {status1, status2, ...}, buff_id = "要上的buff_id"}；---------------------------------------------
	[26001] = {kind = 26, value =  {status = {"stun", "fear", "time_stop", "freeze", "petrify", "winding_of_cane", "stun_charge"}, buff_id= "shengzhutiaozhan_stun_5s"}, is_hero = true, is_enemy = true,
		string = "场上所有被控制的目标，都会额外被眩晕5秒", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 27.指定队伍治疗转伤害, value = 治疗转伤害的系数(这个是直接乘以value)
	[27001] = {kind = 27, value = 0.4, is_hero = true, is_enemy = false,
		string = "我方治疗会变成伤害，伤害等于40%的治疗量", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[27002] = {kind = 27, value = 0.6, is_hero = true, is_enemy = false,
		string = "我方治疗会变成伤害，伤害等于60%的治疗量", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[27003] = {kind = 27, value = 0.8, is_hero = true, is_enemy = false,
		string = "我方治疗会变成伤害，伤害等于80%的治疗量", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 28.指定队伍受到的治疗翻倍, value = 翻倍的系数 (这个是直接乘以value)
	[28001] = {kind = 28, value = 1.3, is_hero = false, is_enemy = true,
		string = "敌方的治疗量提升1.3倍", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[28002] = {kind = 28, value = 2, is_hero = false, is_enemy = true,
		string = "敌方的治疗量提升2倍", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

	-- 29.指定队伍的AOE与单体伤害翻倍, value = {single = 单体系数, aoe = aoe系数}(这个是直接乘以value)
	[29001] = {kind = 29, value = {single = 0.7, aoe = 1}, is_hero = true, is_enemy = false,
		string = "我方单体伤害降低30%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[29002] = {kind = 29, value = {single = 1, aoe = 0.7}, is_hero = true, is_enemy = false,
		string = "我方群体伤害降低30%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[29003] = {kind = 29, value = {single = 1, aoe = 1.3}, is_hero = false, is_enemy = true,
		string = "敌方群体伤害提升30%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},
	[29004] = {kind = 29, value = {single = 1.3, aoe = 1}, is_hero = false, is_enemy = true,
		string = "敌方单体伤害提升30%", string_duration = 10, string_begin_time = 0, string_interval = 100,
	},

}
return totemchallenge_config