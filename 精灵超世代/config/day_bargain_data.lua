----------------------------------------------------
-- 此文件由数据工具生成
-- 章节副本配置数据--day_bargain_data.xml
--------------------------------------

Config = Config or {} 
Config.DayBargainData = Config.DayBargainData or {}

-- -------------------info_start-------------------
Config.DayBargainData.data_info_length = 4
Config.DayBargainData.data_info = {
	[10] = {id=10, time=1, open_day=7, name="超值三星", award={{80019,1},{20023,30},{2,1280},{1,500000}}, return_award={{2,150}}, return_day=7, charge_id=26, charge_num=128, effect_list={{80019,1,0},{2,1,0},{10401,1,0},{10220,1,0}}},
	[20] = {id=20, time=15, open_day=7, name="豪华三星", award={{10220,1},{10212,1},{2,1980},{1,500000}}, return_award={{2,200}}, return_day=7, charge_id=27, charge_num=198, effect_list={{80011,1,0},{2,1,0},{10401,1,0},{10220,1,0}}},
	[30] = {id=30, time=7, open_day=7, name="超强橙装", award={{81109,1},{20023,50},{2,3280},{1,1000000}}, return_award={{2,250}}, return_day=7, charge_id=28, charge_num=328, effect_list={{30202,1,0},{10212,1,0},{2,1,0},{81109,1,0}}},
	[40] = {id=40, time=15, open_day=7, name="极品红装", award={{81110,1},{10212,2},{2,6480},{1,1000000}}, return_award={{2,300}}, return_day=7, charge_id=29, charge_num=648, effect_list={{30202,1,0},{10212,1,0},{2,1,0},{81110,1,0}}}
}
-- -------------------info_end---------------------


-- -------------------const_start-------------------
Config.DayBargainData.data_const_length = 2
Config.DayBargainData.data_const = {
	["vip_gift_id"] = {label='vip_gift_id', val=10},
	["vip_lev"] = {label='vip_lev', val=6}
}
-- -------------------const_end---------------------
