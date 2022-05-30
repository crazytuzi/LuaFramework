----------------------------------------------------
-- 此文件由数据工具生成
-- 单位配置数据--unit_other_part_data.xml
--------------------------------------

Config = Config or {} 
Config.UnitData = Config.UnitData or {}

-- -------------------unit_start-------------------
Config.UnitData.data_unit = function(key)
	return Config.UnitData1.data_unit1(key) or Config.UnitData2.data_unit1(key) or Config.UnitData3.data_unit1(key)
	or Config.UnitData1.data_unit2(key) or Config.UnitData2.data_unit2(key) or Config.UnitData3.data_unit2(key)
end

-- -------------------button_start-------------------
Config.UnitData.data_button_length = 4
Config.UnitData.data_button = {
	[1001] = {id=1001, name="每日礼包", type=2, priority=1, is_auto=0, ext={}, condition={}, show_cond={}},
	[1002] = {id=1002, name="联盟红包", type=2, priority=2, is_auto=0, ext={}, condition={}, show_cond={}},
	[1003] = {id=1003, name="等级礼包", type=2, priority=1, is_auto=0, ext={}, condition={}, show_cond={}},
	[1010] = {id=1010, name="神之试炼", type=2, priority=1, is_auto=0, ext={}, condition={}, show_cond={}}
}
Config.UnitData.data_button_fun = function(key)
	local data=Config.UnitData.data_button[key]
	if DATA_DEBUG and data == nil then
		print('(Config.UnitData.data_button['..key..'])not found') return
	end
	return data
end
-- -------------------button_end---------------------


