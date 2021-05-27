--传世装备显示配置
return {
	--基础属性,有配置的才显示在基础属性中
	--第1层按玩家职业索引
	base_attr_types = {
		[1] = {5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33},
		[2] = {5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33},
		[3] = {5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33},
	},

	--第1层索引为装备位置
	--第2层按玩家职业索引
	--第3层为物品id索引
	--skill_desc:技能描述
	--effect_id:特效id
	chuanshi_equip_cfg = {
----------------------------------------	
		[0] = {-- 武器
			[1] = {--战士
--------------------			
[2924] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV1】}\n      有{color;ff0000;10%}几率将{color;ff0000;15%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·圣
[2932] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV2】}\n      有{color;ff0000;20%}几率将{color;ff0000;25%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·魔
[2940] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV3】}\n      有{color;ff0000;30%}几率将{color;ff0000;35%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·神
[2948] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV4】}\n      有{color;ff0000;40%}几率将{color;ff0000;45%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·仙
[2956] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV5】}\n      有{color;ff0000;50%}几率将{color;ff0000;55%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·佛
[2964] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV6】}\n      有{color;ff0000;60%}几率将{color;ff0000;65%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·至尊

--------------------
			},			
			[2] = {--法师
--------------------			
[2924] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV1】}\n      有{color;ff0000;10%}几率将{color;ff0000;15%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·圣
[2932] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV2】}\n      有{color;ff0000;20%}几率将{color;ff0000;25%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·魔
[2940] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV3】}\n      有{color;ff0000;30%}几率将{color;ff0000;35%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·神
[2948] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV4】}\n      有{color;ff0000;40%}几率将{color;ff0000;45%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·仙
[2956] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV5】}\n      有{color;ff0000;50%}几率将{color;ff0000;55%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·佛
[2964] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV6】}\n      有{color;ff0000;60%}几率将{color;ff0000;65%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·至尊

--------------------			
			},			
			[3] = {--道士
--------------------			
[2924] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV1】}\n      有{color;ff0000;10%}几率将{color;ff0000;15%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·圣
[2932] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV2】}\n      有{color;ff0000;20%}几率将{color;ff0000;25%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·魔
[2940] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV3】}\n      有{color;ff0000;30%}几率将{color;ff0000;35%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·神
[2948] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV4】}\n      有{color;ff0000;40%}几率将{color;ff0000;45%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·仙
[2956] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV5】}\n      有{color;ff0000;50%}几率将{color;ff0000;55%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·佛
[2964] = {effect_id = 110, skill_desc = "      {color;ff0000;【嗜血技能 LV6】}\n      有{color;ff0000;60%}几率将{color;ff0000;65%}的伤害\n      转换成自己的血量，间隔触发时间{color;00c0ff;10}秒"},--传世之刃·至尊

--------------------			
			},
		},
-----------------------------------------


		[1] = {-- 衣服
			[1] = {--战士
--------------------			
[2925] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV1】}\n      有{color;ff0000;10%}几率降低对方{color;ff0000;5%}的攻击\n      持续时间{color;00c0ff;3}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·圣
[2933] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV2】}\n      有{color;ff0000;20%}几率降低对方{color;ff0000;10%}的攻击\n      持续时间{color;00c0ff;5}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·魔
[2941] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV3】}\n      有{color;ff0000;30%}几率降低对方{color;ff0000;15%}的攻击\n      持续时间{color;00c0ff;7}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·神
[2949] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV4】}\n      有{color;ff0000;40%}几率降低对方{color;ff0000;20%}的攻击\n      持续时间{color;00c0ff;9}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·仙
[2957] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV5】}\n      有{color;ff0000;50%}几率降低对方{color;ff0000;25%}的攻击\n      持续时间{color;00c0ff;11}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·佛
[2965] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV6】}\n      有{color;ff0000;60%}几率降低对方{color;ff0000;30%}的攻击\n      持续时间{color;00c0ff;13}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·至尊

--------------------
			},			
			[2] = {--法师
--------------------			
[2925] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV1】}\n      有{color;ff0000;10%}几率降低对方{color;ff0000;5%}的攻击\n      持续时间{color;00c0ff;3}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·圣
[2933] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV2】}\n      有{color;ff0000;20%}几率降低对方{color;ff0000;10%}的攻击\n      持续时间{color;00c0ff;5}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·魔
[2941] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV3】}\n      有{color;ff0000;30%}几率降低对方{color;ff0000;15%}的攻击\n      持续时间{color;00c0ff;7}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·神
[2949] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV4】}\n      有{color;ff0000;40%}几率降低对方{color;ff0000;20%}的攻击\n      持续时间{color;00c0ff;9}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·仙
[2957] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV5】}\n      有{color;ff0000;50%}几率降低对方{color;ff0000;25%}的攻击\n      持续时间{color;00c0ff;11}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·佛
[2965] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV6】}\n      有{color;ff0000;60%}几率降低对方{color;ff0000;30%}的攻击\n      持续时间{color;00c0ff;13}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·至尊

--------------------			
			},			
			[3] = {--道士
--------------------			
[2925] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV1】}\n      有{color;ff0000;10%}几率降低对方{color;ff0000;5%}的攻击\n      持续时间{color;00c0ff;3}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·圣
[2933] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV2】}\n      有{color;ff0000;20%}几率降低对方{color;ff0000;10%}的攻击\n      持续时间{color;00c0ff;5}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·魔
[2941] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV3】}\n      有{color;ff0000;30%}几率降低对方{color;ff0000;15%}的攻击\n      持续时间{color;00c0ff;7}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·神
[2949] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV4】}\n      有{color;ff0000;40%}几率降低对方{color;ff0000;20%}的攻击\n      持续时间{color;00c0ff;9}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·仙
[2957] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV5】}\n      有{color;ff0000;50%}几率降低对方{color;ff0000;25%}的攻击\n      持续时间{color;00c0ff;11}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·佛
[2965] = {effect_id = 111, skill_desc = "      {color;ff0000;【诅咒技能 LV6】}\n      有{color;ff0000;60%}几率降低对方{color;ff0000;30%}的攻击\n      持续时间{color;00c0ff;13}秒，间隔触发时间{color;00c0ff;10}秒"},--传世神甲·至尊

--------------------			
			},
		},
-----------------------------------------


		[2] = {-- 头盔
			[1] = {--战士
--------------------			
[2926] = {effect_id = 112, skill_desc = "      无"},--传世头盔·圣
[2934] = {effect_id = 112, skill_desc = "      无"},--传世头盔·魔
[2942] = {effect_id = 112, skill_desc = "      无"},--传世头盔·神
[2950] = {effect_id = 112, skill_desc = "      无"},--传世头盔·仙
[2958] = {effect_id = 112, skill_desc = "      无"},--传世头盔·佛
[2966] = {effect_id = 112, skill_desc = "      无"},--传世头盔·至尊

--------------------
			},			
			[2] = {--法师
--------------------			
[2926] = {effect_id = 112, skill_desc = "      无"},--传世头盔·圣
[2934] = {effect_id = 112, skill_desc = "      无"},--传世头盔·魔
[2942] = {effect_id = 112, skill_desc = "      无"},--传世头盔·神
[2950] = {effect_id = 112, skill_desc = "      无"},--传世头盔·仙
[2958] = {effect_id = 112, skill_desc = "      无"},--传世头盔·佛
[2966] = {effect_id = 112, skill_desc = "      无"},--传世头盔·至尊

--------------------			
			},			
			[3] = {--道士
--------------------			
[2926] = {effect_id = 112, skill_desc = "      无"},--传世头盔·圣
[2934] = {effect_id = 112, skill_desc = "      无"},--传世头盔·魔
[2942] = {effect_id = 112, skill_desc = "      无"},--传世头盔·神
[2950] = {effect_id = 112, skill_desc = "      无"},--传世头盔·仙
[2958] = {effect_id = 112, skill_desc = "      无"},--传世头盔·佛
[2966] = {effect_id = 112, skill_desc = "      无"},--传世头盔·至尊
--------------------			
			},
		},
--------------------------------------------

		[3] = {-- 项链
			[1] = {--战士
--------------------			
[2927] = {effect_id = 113, skill_desc = "      无"},--传世项链·圣
[2935] = {effect_id = 113, skill_desc = "      无"},--传世项链·魔
[2943] = {effect_id = 113, skill_desc = "      无"},--传世项链·神
[2951] = {effect_id = 113, skill_desc = "      无"},--传世项链·仙
[2959] = {effect_id = 113, skill_desc = "      无"},--传世项链·佛
[2967] = {effect_id = 113, skill_desc = "      无"},--传世项链·至尊

--------------------
			},			
			[2] = {--法师
--------------------			
[2927] = {effect_id = 113, skill_desc = "      无"},--传世项链·圣
[2935] = {effect_id = 113, skill_desc = "      无"},--传世项链·魔
[2943] = {effect_id = 113, skill_desc = "      无"},--传世项链·神
[2951] = {effect_id = 113, skill_desc = "      无"},--传世项链·仙
[2959] = {effect_id = 113, skill_desc = "      无"},--传世项链·佛
[2967] = {effect_id = 113, skill_desc = "      无"},--传世项链·至尊

--------------------			
			},			
			[3] = {--道士
--------------------			
[2927] = {effect_id = 113, skill_desc = "      无"},--传世项链·圣
[2935] = {effect_id = 113, skill_desc = "      无"},--传世项链·魔
[2943] = {effect_id = 113, skill_desc = "      无"},--传世项链·神
[2951] = {effect_id = 113, skill_desc = "      无"},--传世项链·仙
[2959] = {effect_id = 113, skill_desc = "      无"},--传世项链·佛
[2967] = {effect_id = 113, skill_desc = "      无"},--传世项链·至尊

--------------------			
			},
		},
-----------------------------------------


		[4] = {-- 左边的手镯
			[1] = {--战士
--------------------			
[2928] = {effect_id = 114, skill_desc = "      无"},--传世手镯·圣
[2936] = {effect_id = 114, skill_desc = "      无"},--传世手镯·魔
[2944] = {effect_id = 114, skill_desc = "      无"},--传世手镯·神
[2952] = {effect_id = 114, skill_desc = "      无"},--传世手镯·仙
[2960] = {effect_id = 114, skill_desc = "      无"},--传世手镯·佛
[2968] = {effect_id = 114, skill_desc = "      无"},--传世手镯·至尊

--------------------
			},			
			[2] = {--法师
--------------------			
[2928] = {effect_id = 114, skill_desc = "      无"},--传世手镯·圣
[2936] = {effect_id = 114, skill_desc = "      无"},--传世手镯·魔
[2944] = {effect_id = 114, skill_desc = "      无"},--传世手镯·神
[2952] = {effect_id = 114, skill_desc = "      无"},--传世手镯·仙
[2960] = {effect_id = 114, skill_desc = "      无"},--传世手镯·佛
[2968] = {effect_id = 114, skill_desc = "      无"},--传世手镯·至尊

--------------------			
			},			
			[3] = {--道士
--------------------			
[2928] = {effect_id = 114, skill_desc = "      无"},--传世手镯·圣
[2936] = {effect_id = 114, skill_desc = "      无"},--传世手镯·魔
[2944] = {effect_id = 114, skill_desc = "      无"},--传世手镯·神
[2952] = {effect_id = 114, skill_desc = "      无"},--传世手镯·仙
[2960] = {effect_id = 114, skill_desc = "      无"},--传世手镯·佛
[2968] = {effect_id = 114, skill_desc = "      无"},--传世手镯·至尊

--------------------			
			},
		},
-----------------------------------------


		[5] = {-- 右边的手镯
			[1] = {--战士
--------------------			
[2928] = {effect_id = 114, skill_desc = "      无"},--传世手镯·圣
[2936] = {effect_id = 114, skill_desc = "      无"},--传世手镯·魔
[2944] = {effect_id = 114, skill_desc = "      无"},--传世手镯·神
[2952] = {effect_id = 114, skill_desc = "      无"},--传世手镯·仙
[2960] = {effect_id = 114, skill_desc = "      无"},--传世手镯·佛
[2968] = {effect_id = 114, skill_desc = "      无"},--传世手镯·至尊

--------------------
			},			
			[2] = {--法师
--------------------			
[2928] = {effect_id = 114, skill_desc = "      无"},--传世手镯·圣
[2936] = {effect_id = 114, skill_desc = "      无"},--传世手镯·魔
[2944] = {effect_id = 114, skill_desc = "      无"},--传世手镯·神
[2952] = {effect_id = 114, skill_desc = "      无"},--传世手镯·仙
[2960] = {effect_id = 114, skill_desc = "      无"},--传世手镯·佛
[2968] = {effect_id = 114, skill_desc = "      无"},--传世手镯·至尊

--------------------			
			},			
			[3] = {--道士
--------------------			
[2928] = {effect_id = 114, skill_desc = "      无"},--传世手镯·圣
[2936] = {effect_id = 114, skill_desc = "      无"},--传世手镯·魔
[2944] = {effect_id = 114, skill_desc = "      无"},--传世手镯·神
[2952] = {effect_id = 114, skill_desc = "      无"},--传世手镯·仙
[2960] = {effect_id = 114, skill_desc = "      无"},--传世手镯·佛
[2968] = {effect_id = 114, skill_desc = "      无"},--传世手镯·至尊

--------------------			
			},
		},
-----------------------------------------	


		[6] = {-- 左边的戒指
			[1] = {--战士
--------------------			
[2929] = {effect_id = 115, skill_desc = "      无"},--传世戒指·圣
[2937] = {effect_id = 115, skill_desc = "      无"},--传世戒指·魔
[2945] = {effect_id = 115, skill_desc = "      无"},--传世戒指·神
[2953] = {effect_id = 115, skill_desc = "      无"},--传世戒指·仙
[2961] = {effect_id = 115, skill_desc = "      无"},--传世戒指·佛
[2969] = {effect_id = 115, skill_desc = "      无"},--传世戒指·至尊

--------------------
			},			
			[2] = {--法师
--------------------			
[2929] = {effect_id = 115, skill_desc = "      无"},--传世戒指·圣
[2937] = {effect_id = 115, skill_desc = "      无"},--传世戒指·魔
[2945] = {effect_id = 115, skill_desc = "      无"},--传世戒指·神
[2953] = {effect_id = 115, skill_desc = "      无"},--传世戒指·仙
[2961] = {effect_id = 115, skill_desc = "      无"},--传世戒指·佛
[2969] = {effect_id = 115, skill_desc = "      无"},--传世戒指·至尊

--------------------			
			},			
			[3] = {--道士
--------------------			
[2929] = {effect_id = 115, skill_desc = "      无"},--传世戒指·圣
[2937] = {effect_id = 115, skill_desc = "      无"},--传世戒指·魔
[2945] = {effect_id = 115, skill_desc = "      无"},--传世戒指·神
[2953] = {effect_id = 115, skill_desc = "      无"},--传世戒指·仙
[2961] = {effect_id = 115, skill_desc = "      无"},--传世戒指·佛
[2969] = {effect_id = 115, skill_desc = "      无"},--传世戒指·至尊

--------------------			
			},
		},
-----------------------------------------


		[7] = {-- 右边的戒指
			[1] = {--战士
--------------------			
[2929] = {effect_id = 115, skill_desc = "      无"},--传世戒指·圣
[2937] = {effect_id = 115, skill_desc = "      无"},--传世戒指·魔
[2945] = {effect_id = 115, skill_desc = "      无"},--传世戒指·神
[2953] = {effect_id = 115, skill_desc = "      无"},--传世戒指·仙
[2961] = {effect_id = 115, skill_desc = "      无"},--传世戒指·佛
[2969] = {effect_id = 115, skill_desc = "      无"},--传世戒指·至尊

--------------------
			},			
			[2] = {--法师
--------------------			
[2929] = {effect_id = 115, skill_desc = "      无"},--传世戒指·圣
[2937] = {effect_id = 115, skill_desc = "      无"},--传世戒指·魔
[2945] = {effect_id = 115, skill_desc = "      无"},--传世戒指·神
[2953] = {effect_id = 115, skill_desc = "      无"},--传世戒指·仙
[2961] = {effect_id = 115, skill_desc = "      无"},--传世戒指·佛
[2969] = {effect_id = 115, skill_desc = "      无"},--传世戒指·至尊

--------------------			
			},			
			[3] = {--道士
--------------------			
[2929] = {effect_id = 115, skill_desc = "      无"},--传世戒指·圣
[2937] = {effect_id = 115, skill_desc = "      无"},--传世戒指·魔
[2945] = {effect_id = 115, skill_desc = "      无"},--传世戒指·神
[2953] = {effect_id = 115, skill_desc = "      无"},--传世戒指·仙
[2961] = {effect_id = 115, skill_desc = "      无"},--传世戒指·佛
[2969] = {effect_id = 115, skill_desc = "      无"},--传世戒指·至尊
--------------------			
			},
		},
-----------------------------------------


		[8] = {-- 腰带
			[1] = {--战士
--------------------			
[2930] = {effect_id = 116, skill_desc = "      无"},--传世腰带·圣
[2938] = {effect_id = 116, skill_desc = "      无"},--传世腰带·魔
[2946] = {effect_id = 116, skill_desc = "      无"},--传世腰带·神
[2954] = {effect_id = 116, skill_desc = "      无"},--传世腰带·仙
[2962] = {effect_id = 116, skill_desc = "      无"},--传世腰带·佛
[2970] = {effect_id = 116, skill_desc = "      无"},--传世腰带·至尊

--------------------
			},			
			[2] = {--法师
--------------------			
[2930] = {effect_id = 116, skill_desc = "      无"},--传世腰带·圣
[2938] = {effect_id = 116, skill_desc = "      无"},--传世腰带·魔
[2946] = {effect_id = 116, skill_desc = "      无"},--传世腰带·神
[2954] = {effect_id = 116, skill_desc = "      无"},--传世腰带·仙
[2962] = {effect_id = 116, skill_desc = "      无"},--传世腰带·佛
[2970] = {effect_id = 116, skill_desc = "      无"},--传世腰带·至尊

--------------------			
			},			
			[3] = {--道士
--------------------			
[2930] = {effect_id = 116, skill_desc = "      无"},--传世腰带·圣
[2938] = {effect_id = 116, skill_desc = "      无"},--传世腰带·魔
[2946] = {effect_id = 116, skill_desc = "      无"},--传世腰带·神
[2954] = {effect_id = 116, skill_desc = "      无"},--传世腰带·仙
[2962] = {effect_id = 116, skill_desc = "      无"},--传世腰带·佛
[2970] = {effect_id = 116, skill_desc = "      无"},--传世腰带·至尊

--------------------			
			},
		},
-----------------------------------------



		[9] = {-- 鞋子
			[1] = {--战士
--------------------			
[2931] = {effect_id = 117, skill_desc = "      无"},--传世靴子·圣
[2939] = {effect_id = 117, skill_desc = "      无"},--传世靴子·魔
[2947] = {effect_id = 117, skill_desc = "      无"},--传世靴子·神
[2955] = {effect_id = 117, skill_desc = "      无"},--传世靴子·仙
[2963] = {effect_id = 117, skill_desc = "      无"},--传世靴子·佛
[2971] = {effect_id = 117, skill_desc = "      无"},--传世靴子·至尊

--------------------
			},			
			[2] = {--法师
--------------------			
[2931] = {effect_id = 117, skill_desc = "      无"},--传世靴子·圣
[2939] = {effect_id = 117, skill_desc = "      无"},--传世靴子·魔
[2947] = {effect_id = 117, skill_desc = "      无"},--传世靴子·神
[2955] = {effect_id = 117, skill_desc = "      无"},--传世靴子·仙
[2963] = {effect_id = 117, skill_desc = "      无"},--传世靴子·佛
[2971] = {effect_id = 117, skill_desc = "      无"},--传世靴子·至尊
--------------------			
			},			
			[3] = {--道士
--------------------			
[2931] = {effect_id = 117, skill_desc = "      无"},--传世靴子·圣
[2939] = {effect_id = 117, skill_desc = "      无"},--传世靴子·魔
[2947] = {effect_id = 117, skill_desc = "      无"},--传世靴子·神
[2955] = {effect_id = 117, skill_desc = "      无"},--传世靴子·仙
[2963] = {effect_id = 117, skill_desc = "      无"},--传世靴子·佛
[2971] = {effect_id = 117, skill_desc = "      无"},--传世靴子·至尊

--------------------			
			},
		},
-----------------------------------------





	}
}