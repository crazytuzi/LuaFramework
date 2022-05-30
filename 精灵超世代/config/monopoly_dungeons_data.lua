----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--monopoly_dungeons_data.xml
--------------------------------------

Config = Config or {} 
Config.MonopolyDungeonsData = Config.MonopolyDungeonsData or {}

-- -------------------const_start-------------------
Config.MonopolyDungeonsData.data_const_length = 5
Config.MonopolyDungeonsData.data_const = {
	["monopoly_combat_id"] = {val={80245}, desc="挑战券id"},
	["monopoly_follow_combat_id"] = {val={4}, desc="可追击的Boss_id"},
	["monopoly_buff_max"] = {val={{'attack',1000000},{'hp_max',10000000}}, desc="最大数值"},
	["day_worship_max"] = {val={20}, desc="每日点赞上限"},
	["worship_reward"] = {val={{1,10000}}, desc="点赞奖励"}
}
Config.MonopolyDungeonsData.data_const_fun = function(key)
	local data=Config.MonopolyDungeonsData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.MonopolyDungeonsData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------boss_info_start-------------------
Config.MonopolyDungeonsData.data_boss_info_length = 4
Config.MonopolyDungeonsData.data_boss_info = {
	[1] = {
		[1] = {id=1, boss_id=1, base_id=910101, develop=400, drop_id={{80244,5},{10,100}}, reward={{80244,100},{36,10},{10,1000}}, head_id=10305, boss_name="万圣节射手"},
		[2] = {id=1, boss_id=2, base_id=910102, develop=800, drop_id={{80244,5},{10,100}}, reward={{80244,150},{36,20},{10,1500}}, head_id=10301, boss_name="神秘女学徒"},
		[3] = {id=1, boss_id=3, base_id=910103, develop=1200, drop_id={{80244,5},{10,100}}, reward={{80244,200},{36,30},{10,2000}}, head_id=10507, boss_name="灵学魔法使"},
		[4] = {id=1, boss_id=4, base_id=910104, develop=1600, drop_id={{80244,5},{10,100}}, reward={{80244,300},{36,50},{10,3000}}, head_id=2011, boss_name="万圣节伯爵"},
	},
	[2] = {
		[1] = {id=2, boss_id=1, base_id=910201, develop=400, drop_id={{80244,5},{10,100}}, reward={{80244,100},{36,10},{10,1000}}, head_id=20201, boss_name="万圣节巫师"},
		[2] = {id=2, boss_id=2, base_id=910202, develop=800, drop_id={{80244,5},{10,100}}, reward={{80244,150},{36,20},{10,1500}}, head_id=20405, boss_name="万圣节鸟人"},
		[3] = {id=2, boss_id=3, base_id=910203, develop=1200, drop_id={{80244,5},{10,100}}, reward={{80244,200},{36,30},{10,2000}}, head_id=20304, boss_name="万圣节火怪"},
		[4] = {id=2, boss_id=4, base_id=910204, develop=1600, drop_id={{80244,5},{10,100}}, reward={{80244,300},{36,50},{10,3000}}, head_id=50505, boss_name="墓地看守者"},
	},
	[3] = {
		[1] = {id=3, boss_id=1, base_id=910301, develop=400, drop_id={{80244,5},{10,100}}, reward={{80244,100},{36,10},{10,1000}}, head_id=30301, boss_name="万圣节树妖"},
		[2] = {id=3, boss_id=2, base_id=910302, develop=800, drop_id={{80244,5},{10,100}}, reward={{80244,150},{36,20},{10,1500}}, head_id=30302, boss_name="万圣节老者"},
		[3] = {id=3, boss_id=3, base_id=910303, develop=1200, drop_id={{80244,5},{10,100}}, reward={{80244,200},{36,30},{10,2000}}, head_id=30304, boss_name="强壮牛头人"},
		[4] = {id=3, boss_id=4, base_id=910304, develop=1600, drop_id={{80244,5},{10,100}}, reward={{80244,300},{36,50},{10,3000}}, head_id=50506, boss_name="糖果小偷"},
	},
	[4] = {
		[1] = {id=4, boss_id=1, base_id=910401, develop=400, drop_id={{80244,5},{10,100}}, reward={{80244,100},{36,10},{10,1000}}, head_id=50401, boss_name="万圣节女巫"},
		[2] = {id=4, boss_id=2, base_id=910402, develop=800, drop_id={{80244,5},{10,100}}, reward={{80244,150},{36,20},{10,1500}}, head_id=50402, boss_name="万圣节炮手"},
		[3] = {id=4, boss_id=3, base_id=910403, develop=1200, drop_id={{80244,5},{10,100}}, reward={{80244,200},{36,30},{10,2000}}, head_id=50404, boss_name="斗篷神秘人"},
		[4] = {id=4, boss_id=4, base_id=910404, develop=1600, drop_id={{80244,5},{10,100}}, reward={{80244,300},{36,50},{10,3000}}, head_id=50504, boss_name="万圣节猛男"},
	},
}
-- -------------------boss_info_end---------------------


-- -------------------main_hero_start-------------------
Config.MonopolyDungeonsData.data_main_hero_length = 4
Config.MonopolyDungeonsData.data_main_hero = {
	[1] = {id=1, main_partner={50509,30509,10502}, main_buff={670011}, buff_val=50},
	[2] = {id=2, main_partner={50504,10510,20510}, main_buff={670011}, buff_val=50},
	[3] = {id=3, main_partner={40506,30508,20509}, main_buff={670011}, buff_val=50},
	[4] = {id=4, main_partner={40503,30510,20508}, main_buff={670011}, buff_val=50}
}
Config.MonopolyDungeonsData.data_main_hero_fun = function(key)
	local data=Config.MonopolyDungeonsData.data_main_hero[key]
	if DATA_DEBUG and data == nil then
		print('(Config.MonopolyDungeonsData.data_main_hero['..key..'])not found') return
	end
	return data
end
-- -------------------main_hero_end---------------------


-- -------------------award_start-------------------
Config.MonopolyDungeonsData.data_award_length = 4
Config.MonopolyDungeonsData.data_award = {
{min=1, max=1, items={{14001,5},{10403,30},{39047,8}}},
{min=2, max=2, items={{14001,4},{10403,24},{39047,6}}},
{min=3, max=3, items={{14001,3},{10403,18},{39047,4}}},
{min=4, max=5, items={{14001,2},{10403,12},{39047,2}}}
}
-- -------------------award_end---------------------
