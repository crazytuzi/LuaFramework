----------------------------------------------------
-- 此文件由数据工具生成
-- 跨服大厅配置数据--cross_hall_data.xml
--------------------------------------

Config = Config or {} 
Config.CrossHallData = Config.CrossHallData or {}

-- -------------------const_start-------------------
Config.CrossHallData.data_const_length = 5
Config.CrossHallData.data_const = {
	["initial_hall_num"] = {key="initial_hall_num", val=4, desc="初始大厅数量"},
	["hall_map"] = {key="hall_map", val=10003, desc="副本大厅地图ID"},
	["join_lev"] = {key="join_lev", val=50, desc="副本大厅进入等级"},
	["hall_max_num"] = {key="hall_max_num", val=30, desc="大厅人数上限"},
	["join_point"] = {key="join_point", val={{1260,720},{1380,690},{1560,720},{1770,720},{1710,930},{1530,930},{1380,900}}, desc="进入地图位置"}
}
-- -------------------const_end---------------------
