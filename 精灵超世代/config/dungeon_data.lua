----------------------------------------------------
-- 此文件由数据工具生成
-- 副本配置数据--dungeon_data.xml
--------------------------------------

Config = Config or {} 
Config.DungeonData = Config.DungeonData or {}

LocalizedConfigRequire("config.auto_config.dungeon_data@data_drama_boss_show_reward")
LocalizedConfigRequire("config.auto_config.dungeon_data@data_drama_const")
LocalizedConfigRequire("config.auto_config.dungeon_data@data_drama_dungeon_info")
LocalizedConfigRequire("config.auto_config.dungeon_data@data_drama_info")
LocalizedConfigRequire("config.auto_config.dungeon_data@data_drama_quick_cost")
LocalizedConfigRequire("config.auto_config.dungeon_data@data_drama_quick_desc")
LocalizedConfigRequire("config.auto_config.dungeon_data@data_drama_reward")
LocalizedConfigRequire("config.auto_config.dungeon_data@data_drama_show_reward")
LocalizedConfigRequire("config.auto_config.dungeon_data@data_drama_talk")
LocalizedConfigRequire("config.auto_config.dungeon_data@data_drama_world_info")


-- -------------------drama_info_start-------------------
-- -------------------drama_info_end---------------------


-- -------------------drama_dungeon_info_start-------------------
-- -------------------drama_dungeon_info_end---------------------


-- -------------------drama_const_start-------------------
Config.DungeonData.data_drama_const_fun = function(key)
	local data=Config.DungeonData.data_drama_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DungeonData.data_drama_const['..key..'])not found') return
	end
	return data
end
-- -------------------drama_const_end---------------------


-- -------------------drama_world_info_start-------------------
-- -------------------drama_world_info_end---------------------


-- -------------------drama_quick_desc_start-------------------
Config.DungeonData.data_drama_quick_desc_length = 6
Config.DungeonData.data_drama_quick_desc = {
	[1] = {key=1, desc="<div fontcolor=#68452a>1、快速作战可直接收益<div fontcolor=#249015>120</div>分钟当前关卡挂机奖励</div>"},
	[2] = {key=2, desc="<div fontcolor=#68452a>2、每天首次快速作战免费,消耗优先使用快速作战券</div>"},
	[3] = {key=3, desc="<div fontcolor=#68452a>3、VIP可以额外提升5%快速作战收益</div>"},
	[4] = {key=4, desc="<div fontcolor=#68452a>4、每天<div fontcolor=#249015>5</div>点重置收益次数</div>"},
	[5] = {key=5, desc="<div fontcolor=#68452a>5、获得伤害+<div fontcolor=#249015>10%</div>的加成,适用于PVE战斗,持续10分钟</div>"},
	[6] = {key=6, desc="<div fontcolor=#68452a>6、低于世界等级<div fontcolor=#249015>5</div>级及以上可获得额外次数的加成</div>"}
}
Config.DungeonData.data_drama_quick_desc_fun = function(key)
	local data=Config.DungeonData.data_drama_quick_desc[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DungeonData.data_drama_quick_desc['..key..'])not found') return
	end
	return data
end
-- -------------------drama_quick_desc_end---------------------


-- -------------------drama_quick_cost_start-------------------
Config.DungeonData.data_drama_quick_cost_fun = function(key)
	local data=Config.DungeonData.data_drama_quick_cost[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DungeonData.data_drama_quick_cost['..key..'])not found') return
	end
	return data
end
-- -------------------drama_quick_cost_end---------------------


-- -------------------drama_talk_start-------------------
-- -------------------drama_talk_end---------------------


-- -------------------drama_reward_start-------------------
Config.DungeonData.data_drama_reward_fun = function(key)
	local data=Config.DungeonData.data_drama_reward[key]
	if DATA_DEBUG and data == nil then
		print('(Config.DungeonData.data_drama_reward['..key..'])not found') return
	end
	return data
end
-- -------------------drama_reward_end---------------------


-- -------------------drama_show_reward_start-------------------
-- -------------------drama_show_reward_end---------------------


-- -------------------drama_boss_show_reward_start-------------------
-- -------------------drama_boss_show_reward_end---------------------
