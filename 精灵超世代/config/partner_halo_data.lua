----------------------------------------------------
-- 此文件由数据工具生成
-- 配置数据--partner_halo_data.xml
--------------------------------------

Config = Config or {} 
Config.PartnerHaloData = Config.PartnerHaloData or {}

-- -------------------halo_const_start-------------------
Config.PartnerHaloData.data_halo_const_length = 3
Config.PartnerHaloData.data_halo_const = {
	["halo_random"] = {key="halo_random", val=3, desc="1-3阶光环随机生成"},
	["halo_lev_limit"] = {key="halo_lev_limit", val=28, desc="光环标签页开启等级"},
	["product_lev_limit"] = {key="product_lev_limit", val=28, desc="合成标签页开启等级"}
}
-- -------------------halo_const_end---------------------


-- -------------------halo_list_start-------------------
Config.PartnerHaloData.data_halo_list_length = 25
Config.PartnerHaloData.data_halo_list = {
	[15200] = {bid=15200, stage=1, need_count=1, attr_tuple={{'atk',{100,200}},{'hp_max',{1300,2600}}}, attr_rand={{1,800},{2,200}}, eff_1="E55001", eff_2="E55002", name="1阶生命光环", career=1, attr_look={{'atk',200},{'hp_max',2600}}},
	[15201] = {bid=15201, stage=1, need_count=1, attr_tuple={{'atk',{130,260}},{'hp_max',{1025,2050}}}, attr_rand={{1,800},{2,200}}, eff_1="E55301", eff_2="E55302", name="1阶强击光环", career=2, attr_look={{'atk',260},{'hp_max',2050}}},
	[15202] = {bid=15202, stage=1, need_count=1, attr_tuple={{'atk',{130,260}},{'hp_max',{1025,2050}}}, attr_rand={{1,800},{2,200}}, eff_1="E55201", eff_2="E55202", name="1阶辉煌光环", career=3, attr_look={{'atk',260},{'hp_max',2050}}},
	[15203] = {bid=15203, stage=1, need_count=1, attr_tuple={{'atk',{95,190}},{'hp_max',{1032,2065}}}, attr_rand={{1,800},{2,200}}, eff_1="E55101", eff_2="E55102", name="1阶守御光环", career=4, attr_look={{'atk',190},{'hp_max',2065}}},
	[15204] = {bid=15204, stage=1, need_count=1, attr_tuple={{'atk',{110,220}},{'hp_max',{1122,2245}}}, attr_rand={{1,800},{2,200}}, eff_1="E55401", eff_2="E55402", name="1阶专注光环", career=5, attr_look={{'atk',220},{'hp_max',2245}}},
	[15300] = {bid=15300, stage=2, need_count=1, attr_tuple={{'atk',{200,400}},{'hp_max',{2600,5200}}}, attr_rand={{1,800},{2,200}}, eff_1="E55001", eff_2="E55002", name="2阶生命光环", career=1, attr_look={{'atk',400},{'hp_max',5200}}},
	[15301] = {bid=15301, stage=2, need_count=1, attr_tuple={{'atk',{260,520}},{'hp_max',{2005,4010}}}, attr_rand={{1,800},{2,200}}, eff_1="E55301", eff_2="E55302", name="2阶强击光环", career=2, attr_look={{'atk',520},{'hp_max',4010}}},
	[15302] = {bid=15302, stage=2, need_count=1, attr_tuple={{'atk',{260,520}},{'hp_max',{2005,4010}}}, attr_rand={{1,800},{2,200}}, eff_1="E55201", eff_2="E55202", name="2阶辉煌光环", career=3, attr_look={{'atk',520},{'hp_max',4010}}},
	[15303] = {bid=15303, stage=2, need_count=1, attr_tuple={{'atk',{190,380}},{'hp_max',{2065,4130}}}, attr_rand={{1,800},{2,200}}, eff_1="E55101", eff_2="E55102", name="2阶守御光环", career=4, attr_look={{'atk',380},{'hp_max',4130}}},
	[15304] = {bid=15304, stage=2, need_count=1, attr_tuple={{'atk',{220,440}},{'hp_max',{2245,4490}}}, attr_rand={{1,800},{2,200}}, eff_1="E55401", eff_2="E55402", name="2阶专注光环", career=5, attr_look={{'atk',440},{'hp_max',4490}}},
	[15400] = {bid=15400, stage=3, need_count=2, attr_tuple={{'atk',{400,800}},{'hp_max',{5200,10400}}}, attr_rand={{1,800},{2,200}}, eff_1="E55003", eff_2="E55004", name="3阶生命光环", career=1, attr_look={{'atk',800},{'hp_max',10400}}},
	[15401] = {bid=15401, stage=3, need_count=2, attr_tuple={{'atk',{520,1040}},{'hp_max',{4010,8020}}}, attr_rand={{1,800},{2,200}}, eff_1="E55303", eff_2="E55304", name="3阶强击光环", career=2, attr_look={{'atk',1040},{'hp_max',8020}}},
	[15402] = {bid=15402, stage=3, need_count=2, attr_tuple={{'atk',{520,1040}},{'hp_max',{4010,8020}}}, attr_rand={{1,800},{2,200}}, eff_1="E55203", eff_2="E55204", name="3阶辉煌光环", career=3, attr_look={{'atk',1040},{'hp_max',8020}}},
	[15403] = {bid=15403, stage=3, need_count=2, attr_tuple={{'atk',{380,760}},{'hp_max',{4130,8260}}}, attr_rand={{1,800},{2,200}}, eff_1="E55103", eff_2="E55104", name="3阶守御光环", career=4, attr_look={{'atk',760},{'hp_max',8260}}},
	[15404] = {bid=15404, stage=3, need_count=2, attr_tuple={{'atk',{440,880}},{'hp_max',{4490,8980}}}, attr_rand={{1,800},{2,200}}, eff_1="E55403", eff_2="E55404", name="3阶专注光环", career=5, attr_look={{'atk',880},{'hp_max',8980}}},
	[15500] = {bid=15500, stage=4, need_count=2, attr_tuple={{'atk',{720,1440}},{'hp_max',{10800,21600}}}, attr_rand={{1,800},{2,200}}, eff_1="E55003", eff_2="E55004", name="4阶生命光环", career=1, attr_look={{'atk',1440},{'hp_max',21600}}},
	[15501] = {bid=15501, stage=4, need_count=2, attr_tuple={{'atk',{936,1872}},{'hp_max',{7380,14760}}}, attr_rand={{1,800},{2,200}}, eff_1="E55303", eff_2="E55304", name="4阶强击光环", career=2, attr_look={{'atk',1872},{'hp_max',14760}}},
	[15502] = {bid=15502, stage=4, need_count=2, attr_tuple={{'atk',{936,1872}},{'hp_max',{7380,14760}}}, attr_rand={{1,800},{2,200}}, eff_1="E55203", eff_2="E55204", name="4阶辉煌光环", career=3, attr_look={{'atk',1872},{'hp_max',14760}}},
	[15503] = {bid=15503, stage=4, need_count=2, attr_tuple={{'atk',{684,1368}},{'hp_max',{7434,14868}}}, attr_rand={{1,800},{2,200}}, eff_1="E55103", eff_2="E55104", name="4阶守御光环", career=4, attr_look={{'atk',1368},{'hp_max',14868}}},
	[15504] = {bid=15504, stage=4, need_count=2, attr_tuple={{'atk',{792,1584}},{'hp_max',{8082,16165}}}, attr_rand={{1,800},{2,200}}, eff_1="E55403", eff_2="E55404", name="4阶专注光环", career=5, attr_look={{'atk',1584},{'hp_max',16165}}},
	[15600] = {bid=15600, stage=5, need_count=3, attr_tuple={{'atk',{1260,2520}},{'hp_max',{16380,32760}}}, attr_rand={{1,800},{2,200}}, eff_1="E55005", eff_2="E55006", name="5阶生命光环", career=1, attr_look={{'atk',2520},{'hp_max',32760}}},
	[15601] = {bid=15601, stage=5, need_count=3, attr_tuple={{'atk',{1638,3276}},{'hp_max',{12915,25830}}}, attr_rand={{1,800},{2,200}}, eff_1="E55305", eff_2="E55306", name="5阶强击光环", career=2, attr_look={{'atk',3276},{'hp_max',25830}}},
	[15602] = {bid=15602, stage=5, need_count=3, attr_tuple={{'atk',{1638,3276}},{'hp_max',{12915,25830}}}, attr_rand={{1,800},{2,200}}, eff_1="E55205", eff_2="E55206", name="5阶辉煌光环", career=3, attr_look={{'atk',3276},{'hp_max',25830}}},
	[15603] = {bid=15603, stage=5, need_count=3, attr_tuple={{'atk',{1197,2394}},{'hp_max',{13010,26020}}}, attr_rand={{1,800},{2,200}}, eff_1="E55105", eff_2="E55106", name="5阶守御光环", career=4, attr_look={{'atk',2394},{'hp_max',26020}}},
	[15604] = {bid=15604, stage=5, need_count=3, attr_tuple={{'atk',{1386,2772}},{'hp_max',{14142,28285}}}, attr_rand={{1,800},{2,200}}, eff_1="E55405", eff_2="E55406", name="5阶专注光环", career=5, attr_look={{'atk',2772},{'hp_max',28285}}},
}
-- -------------------halo_list_end---------------------


-- -------------------make_list_start-------------------
Config.PartnerHaloData.data_make_list_length = 6
Config.PartnerHaloData.data_make_list = {
	[0] = {
		[1] = {stage=1, type=0, rand_list={{15200,200},{15201,200},{15202,200},{15203,200},{15204,200}}, succeed_base_pro=1000, expend={{15002,10},{15010,4}}, count=0},
		[2] = {stage=2, type=0, rand_list={{15300,200},{15301,200},{15302,200},{15303,200},{15304,200}}, succeed_base_pro=500, expend={{15002,15},{15011,5}}, count=1},
		[3] = {stage=3, type=0, rand_list={{15400,200},{15401,200},{15402,200},{15403,200},{15404,200}}, succeed_base_pro=400, expend={{15002,20},{15012,6}}, count=1},
	},
	[1] = {
		[4] = {stage=4, type=1, rand_list={{15500,1000}}, succeed_base_pro=200, expend={{15002,30},{15013,8}}, count=1},
		[5] = {stage=5, type=1, rand_list={{15600,1000}}, succeed_base_pro=200, expend={{15002,40},{15014,10}}, count=1},
	},
	[2] = {
		[4] = {stage=4, type=2, rand_list={{15501,1000}}, succeed_base_pro=200, expend={{15002,30},{15013,8}}, count=1},
		[5] = {stage=5, type=2, rand_list={{15601,1000}}, succeed_base_pro=200, expend={{15002,40},{15014,10}}, count=1},
	},
	[3] = {
		[4] = {stage=4, type=3, rand_list={{15502,1000}}, succeed_base_pro=200, expend={{15002,30},{15013,8}}, count=1},
		[5] = {stage=5, type=3, rand_list={{15602,1000}}, succeed_base_pro=200, expend={{15002,40},{15014,10}}, count=1},
	},
	[4] = {
		[4] = {stage=4, type=4, rand_list={{15503,1000}}, succeed_base_pro=200, expend={{15002,30},{15013,8}}, count=1},
		[5] = {stage=5, type=4, rand_list={{15603,1000}}, succeed_base_pro=200, expend={{15002,40},{15014,10}}, count=1},
	},
	[5] = {
		[4] = {stage=4, type=5, rand_list={{15504,1000}}, succeed_base_pro=200, expend={{15002,30},{15013,8}}, count=1},
		[5] = {stage=5, type=5, rand_list={{15604,1000}}, succeed_base_pro=200, expend={{15002,40},{15014,10}}, count=1},
	},
}
-- -------------------make_list_end---------------------


-- -------------------clean_list_start-------------------
Config.PartnerHaloData.data_clean_list_length = 25
Config.PartnerHaloData.data_clean_list = {
	[15200] = {bid=15200, expend={{15002,2},{15010,1}}, add_val={20,40}},
	[15201] = {bid=15201, expend={{15002,2},{15010,1}}, add_val={20,40}},
	[15202] = {bid=15202, expend={{15002,2},{15010,1}}, add_val={20,40}},
	[15203] = {bid=15203, expend={{15002,2},{15010,1}}, add_val={20,40}},
	[15204] = {bid=15204, expend={{15002,2},{15010,1}}, add_val={20,40}},
	[15300] = {bid=15300, expend={{15002,3},{15011,1}}, add_val={20,40}},
	[15301] = {bid=15301, expend={{15002,3},{15011,1}}, add_val={20,40}},
	[15302] = {bid=15302, expend={{15002,3},{15011,1}}, add_val={20,40}},
	[15303] = {bid=15303, expend={{15002,3},{15011,1}}, add_val={20,40}},
	[15304] = {bid=15304, expend={{15002,3},{15011,1}}, add_val={20,40}},
	[15400] = {bid=15400, expend={{15002,4},{15012,2}}, add_val={20,40}},
	[15401] = {bid=15401, expend={{15002,4},{15012,2}}, add_val={20,40}},
	[15402] = {bid=15402, expend={{15002,4},{15012,2}}, add_val={20,40}},
	[15403] = {bid=15403, expend={{15002,4},{15012,2}}, add_val={20,40}},
	[15404] = {bid=15404, expend={{15002,4},{15012,2}}, add_val={20,40}},
	[15500] = {bid=15500, expend={{15002,6},{15013,2}}, add_val={20,40}},
	[15501] = {bid=15501, expend={{15002,6},{15013,2}}, add_val={20,40}},
	[15502] = {bid=15502, expend={{15002,6},{15013,2}}, add_val={20,40}},
	[15503] = {bid=15503, expend={{15002,6},{15013,2}}, add_val={20,40}},
	[15504] = {bid=15504, expend={{15002,6},{15013,2}}, add_val={20,40}},
	[15600] = {bid=15600, expend={{15002,10},{15014,3}}, add_val={20,40}},
	[15601] = {bid=15601, expend={{15002,10},{15014,3}}, add_val={20,40}},
	[15602] = {bid=15602, expend={{15002,10},{15014,3}}, add_val={20,40}},
	[15603] = {bid=15603, expend={{15002,10},{15014,3}}, add_val={20,40}},
	[15604] = {bid=15604, expend={{15002,10},{15014,3}}, add_val={20,40}}
}
-- -------------------clean_list_end---------------------


-- -------------------luck_list_start-------------------
Config.PartnerHaloData.data_luck_list_length = 5
Config.PartnerHaloData.data_luck_list = {
	[15030] = {id=15030, succeed_pro=50},
	[15031] = {id=15031, succeed_pro=80},
	[15032] = {id=15032, succeed_pro=100},
	[15033] = {id=15033, succeed_pro=150},
	[15034] = {id=15034, succeed_pro=200}
}
-- -------------------luck_list_end---------------------


-- -------------------attr_list_start-------------------
Config.PartnerHaloData.data_attr_list_length = 5
Config.PartnerHaloData.data_attr_list = {
	[1] = {
		[1] = {id=1, stage=1, type=1, attr_tuple={{'hp_max_per',50,450},{'speed',2,100},{'hit_magic',50,250},{'dodge_magic',50,200}}},
		[2] = {id=2, stage=1, type=2, attr_tuple={{'atk_per',50,450},{'speed',2,100},{'hit_magic',50,250},{'dodge_magic',50,200}}},
		[3] = {id=3, stage=1, type=3, attr_tuple={{'atk_per',50,450},{'speed',2,100},{'hit_magic',50,250},{'dodge_magic',50,200}}},
		[4] = {id=4, stage=1, type=4, attr_tuple={{'hp_max_per',50,200},{'speed',2,100},{'hit_magic',50,100},{'dodge_magic',50,100},{'def_per',30,150}}},
		[5] = {id=5, stage=1, type=5, attr_tuple={{'hp_max_per',50,450},{'speed',2,100},{'hit_magic',250,100},{'dodge_magic',50,200}}},
	},
	[2] = {
		[1] = {id=11, stage=2, type=1, attr_tuple={{'hp_max_per',50,450},{'hp_max_per',100,250},{'speed',2,100},{'hit_magic',50,100},{'dodge_magic',50,100}}},
		[2] = {id=12, stage=2, type=2, attr_tuple={{'atk_per',50,450},{'atk_per',100,250},{'speed',2,100},{'hit_magic',50,100},{'dodge_magic',50,100}}},
		[3] = {id=13, stage=2, type=3, attr_tuple={{'atk_per',50,450},{'atk_per',100,250},{'speed',2,100},{'hit_magic',50,100},{'dodge_magic',50,100}}},
		[4] = {id=14, stage=2, type=4, attr_tuple={{'hp_max_per',50,200},{'hp_max_per',100,150},{'speed',2,100},{'hit_magic',50,100},{'dodge_magic',50,100},{'def_per',30,200},{'def_per',60,150}}},
		[5] = {id=15, stage=2, type=5, attr_tuple={{'hp_max_per',50,450},{'hp_max_per',100,250},{'speed',2,100},{'hit_magic',50,100},{'dodge_magic',50,100}}},
	},
	[3] = {
		[1] = {id=21, stage=3, type=1, attr_tuple={{'hp_max_per',100,300},{'hp_max_per',150,200},{'speed',5,100},{'hit_magic',50,75},{'dodge_magic',50,75},{'hit_magic',100,25},{'dodge_magic',100,25},{'crit_rate',50,100},{'crit_ratio',50,100}}},
		[2] = {id=22, stage=3, type=2, attr_tuple={{'atk_per',100,300},{'atk_per',150,200},{'speed',5,100},{'hit_magic',50,75},{'dodge_magic',50,75},{'hit_magic',100,25},{'dodge_magic',100,25},{'crit_rate',50,100},{'crit_ratio',50,100}}},
		[3] = {id=23, stage=3, type=3, attr_tuple={{'atk_per',100,300},{'atk_per',150,200},{'speed',5,100},{'hit_magic',50,75},{'dodge_magic',50,75},{'hit_magic',100,25},{'dodge_magic',100,25},{'crit_rate',50,100},{'crit_ratio',50,100}}},
		[4] = {id=24, stage=3, type=4, attr_tuple={{'hp_max_per',150,100},{'hp_max_per',100,150},{'speed',5,100},{'hit_magic',50,75},{'dodge_magic',50,75},{'hit_magic',100,25},{'dodge_magic',100,25},{'def_per',90,100},{'def_per',60,150},{'crit_rate',50,100},{'crit_ratio',50,100}}},
		[5] = {id=25, stage=3, type=5, attr_tuple={{'hp_max_per',100,300},{'hp_max_per',150,200},{'speed',5,100},{'hit_magic',50,75},{'dodge_magic',50,75},{'hit_magic',100,25},{'dodge_magic',100,25},{'crit_rate',50,100},{'crit_ratio',50,100}}},
	},
	[4] = {
		[1] = {id=31, stage=4, type=1, attr_tuple={{'hp_max_per',200,200},{'hp_max_per',150,300},{'speed',5,75},{'speed',10,25},{'hit_magic',50,75},{'dodge_magic',50,75},{'hit_magic',100,25},{'dodge_magic',100,25},{'crit_rate',50,75},{'crit_ratio',50,75},{'crit_rate',100,25},{'crit_ratio',100,25}}},
		[2] = {id=32, stage=4, type=2, attr_tuple={{'atk_per',200,200},{'atk_per',150,300},{'speed',5,75},{'speed',10,25},{'hit_magic',50,75},{'dodge_magic',50,75},{'hit_magic',100,25},{'dodge_magic',100,25},{'crit_rate',50,75},{'crit_ratio',50,75},{'crit_rate',100,25},{'crit_ratio',100,25}}},
		[3] = {id=33, stage=4, type=3, attr_tuple={{'atk_per',200,200},{'atk_per',150,300},{'speed',5,75},{'speed',10,25},{'hit_magic',50,75},{'dodge_magic',50,75},{'hit_magic',100,25},{'dodge_magic',100,25},{'crit_rate',50,75},{'crit_ratio',50,75},{'crit_rate',100,25},{'crit_ratio',100,25}}},
		[4] = {id=34, stage=4, type=4, attr_tuple={{'hp_max_per',150,150},{'hp_max_per',200,100},{'speed',5,75},{'speed',10,25},{'hit_magic',50,75},{'dodge_magic',50,75},{'hit_magic',100,25},{'dodge_magic',100,25},{'def_per',90,150},{'def_per',120,100},{'crit_rate',50,75},{'crit_ratio',50,75},{'crit_rate',100,25},{'crit_ratio',100,25}}},
		[5] = {id=35, stage=4, type=5, attr_tuple={{'hp_max_per',200,200},{'hp_max_per',150,300},{'speed',5,75},{'speed',10,25},{'hit_magic',50,75},{'dodge_magic',50,75},{'hit_magic',100,25},{'dodge_magic',100,25},{'crit_rate',50,75},{'crit_ratio',50,75},{'crit_rate',100,25},{'crit_ratio',100,25}}},
	},
	[5] = {
		[1] = {id=41, stage=5, type=1, attr_tuple={{'hp_max_per',200,300},{'hp_max_per',250,200},{'speed',15,25},{'speed',10,75},{'hit_magic',150,25},{'dodge_magic',150,25},{'hit_magic',100,75},{'dodge_magic',100,75},{'crit_rate',150,25},{'crit_ratio',150,25},{'crit_rate',100,75},{'crit_ratio',100,75}}},
		[2] = {id=42, stage=5, type=2, attr_tuple={{'atk_per',200,300},{'atk_per',250,200},{'speed',15,25},{'speed',10,75},{'hit_magic',150,25},{'dodge_magic',150,25},{'hit_magic',100,75},{'dodge_magic',100,75},{'crit_rate',150,25},{'crit_ratio',150,25},{'crit_rate',100,75},{'crit_ratio',100,75}}},
		[3] = {id=43, stage=5, type=3, attr_tuple={{'atk_per',200,300},{'atk_per',250,200},{'speed',15,25},{'speed',10,75},{'hit_magic',150,25},{'dodge_magic',150,25},{'hit_magic',100,75},{'dodge_magic',100,75},{'crit_rate',150,25},{'crit_ratio',150,25},{'crit_rate',100,75},{'crit_ratio',100,75}}},
		[4] = {id=44, stage=5, type=4, attr_tuple={{'hp_max_per',250,100},{'hp_max_per',200,150},{'speed',15,25},{'speed',10,75},{'hit_magic',150,25},{'dodge_magic',150,25},{'hit_magic',100,75},{'dodge_magic',100,75},{'def_per',150,100},{'def_per',120,150},{'crit_rate',150,25},{'crit_ratio',150,25},{'crit_rate',100,75},{'crit_ratio',100,75}}},
		[5] = {id=45, stage=5, type=5, attr_tuple={{'hp_max_per',200,300},{'hp_max_per',250,200},{'speed',15,25},{'speed',10,75},{'hit_magic',150,25},{'dodge_magic',150,25},{'hit_magic',100,75},{'dodge_magic',100,75},{'crit_rate',150,25},{'crit_ratio',150,25},{'crit_rate',100,75},{'crit_ratio',100,75}}},
	},
}
-- -------------------attr_list_end---------------------


-- -------------------goods_make_start-------------------
Config.PartnerHaloData.data_goods_make_length = 10
Config.PartnerHaloData.data_goods_make = {
	[15031] = {id=15031, expend_id=15030, expend_num=4, expend={{1,5000}}, succeed_pro=1000},
	[15032] = {id=15032, expend_id=15031, expend_num=4, expend={{1,10000}}, succeed_pro=1000},
	[15033] = {id=15033, expend_id=15032, expend_num=4, expend={{1,15000}}, succeed_pro=1000},
	[15034] = {id=15034, expend_id=15033, expend_num=4, expend={{1,20000}}, succeed_pro=1000},
	[15011] = {id=15011, expend_id=15010, expend_num=2, expend={{1,10000}}, succeed_pro=1000},
	[15012] = {id=15012, expend_id=15011, expend_num=2, expend={{1,15000}}, succeed_pro=1000},
	[15013] = {id=15013, expend_id=15012, expend_num=2, expend={{1,20000}}, succeed_pro=1000},
	[15014] = {id=15014, expend_id=15013, expend_num=2, expend={{1,25000}}, succeed_pro=1000},
	[15041] = {id=15041, expend_id=15040, expend_num=2, expend={{1,10000}}, succeed_pro=1000},
	[15042] = {id=15042, expend_id=15041, expend_num=2, expend={{1,15000}}, succeed_pro=1000},
}
-- -------------------goods_make_end---------------------
