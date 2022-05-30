----------------------------------------------------
-- 此文件由数据工具生成
-- 皮肤--partner_skin_data.xml
--------------------------------------

Config = Config or {} 
Config.PartnerSkinData = Config.PartnerSkinData or {}

-- -------------------const_start-------------------
Config.PartnerSkinData.data_const_length = 1
Config.PartnerSkinData.data_const = {
	["skin_open"] = {val={'lev',35}, desc="玩家35级开启皮肤系统"}
}
Config.PartnerSkinData.data_const_fun = function(key)
	local data=Config.PartnerSkinData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerSkinData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------skin_info_start-------------------
Config.PartnerSkinData.data_skin_info_length = 19
Config.PartnerSkinData.data_skin_info = {
	[101] = {skin_id=101, skin_name="水色悠梦", skin_attr={{'atk_per',20},{'hp_max_per',20},{'crit_rate',20}}, bid=30508, res_id="H50000", head_id=2001, head_card_id=2001, bustid=2001, draw_res="shuiseyoumeng", draw_offset={{0,-70}}, scale=75, draw_offset_2={{75,60}}, scale_2=82, show_effect="E25006", fight_effect="E25106", action_bid=991032, action_start_time={2019,10,4,0,0,0}, action_end_time={2019,10,6,23,59,59}, voice="d_voice_30508", voice_time=1, item_id_list={23001,23002}, hero_info_bg_res="hero_info_bg_shuiseyoumeng", hero_camp_res="null", chip_num=200, diamond_num={{3,5000}}, is_shop=1},
	[102] = {skin_id=102, skin_name="如梦令", skin_attr={{'atk_per',20},{'hp_max_per',20},{'cure',30}}, bid=40507, res_id="H50001", head_id=2002, head_card_id=2002, bustid=2002, draw_res="rumengling", draw_offset={{0,-50}}, scale=65, draw_offset_2={{-35,55}}, scale_2=84, show_effect="E25004", fight_effect="E25104", action_bid=991032, action_start_time={2019,10,7,0,0,0}, action_end_time={2019,10,9,23,59,59}, voice="d_voice_40507", voice_time=3, item_id_list={23004,23005}, hero_info_bg_res="hero_info_bg_rumengling", hero_camp_res="hero_camp_rumengling", chip_num=200, diamond_num={{3,5000}}, is_shop=1},
	[103] = {skin_id=103, skin_name="赤羽火舞", skin_attr={{'atk_per',10},{'hp_max_per',10}}, bid=20508, res_id="H50002", head_id=2003, head_card_id=2003, bustid=2003, draw_res="chiyuhuowu", draw_offset={{-160,-50}}, scale=65, draw_offset_2={{-240,100}}, scale_2=86, show_effect="E25002", fight_effect="E25102", action_bid=0, action_start_time={}, action_end_time={}, voice="d_voice_20508", voice_time=4, item_id_list={23007,23008}, hero_info_bg_res="hero_info_bg_2", hero_camp_res="", chip_num=100, diamond_num={{3,2500}}, is_shop=1},
	[104] = {skin_id=104, skin_name="御龙金甲", skin_attr={{'atk_per',10},{'hp_max_per',10}}, bid=10505, res_id="H50003", head_id=2004, head_card_id=2004, bustid=2004, draw_res="yulongjinjia", draw_offset={{20,0}}, scale=55, draw_offset_2={{120,20}}, scale_2=76, show_effect="E25001", fight_effect="E25101", action_bid=0, action_start_time={}, action_end_time={}, voice="d_voice_10505", voice_time=4, item_id_list={23010,23011}, hero_info_bg_res="hero_info_bg_1", hero_camp_res="", chip_num=100, diamond_num={{3,2500}}, is_shop=1},
	[105] = {skin_id=105, skin_name="赤魅海盗", skin_attr={{'atk_per',20},{'hp_max_per',20},{'speed',3}}, bid=50507, res_id="H50004", head_id=2005, head_card_id=2005, bustid=2005, draw_res="chimeihaidao", draw_offset={{-40,0}}, scale=65, draw_offset_2={{-90,200}}, scale_2=90, show_effect="E25005", fight_effect="E25105", action_bid=0, action_start_time={}, action_end_time={}, voice="d_voice_50507", voice_time=3, item_id_list={23013,23014}, hero_info_bg_res="hero_info_bg_5", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=1},
	[106] = {skin_id=106, skin_name="甜心女仆", skin_attr={{'atk_per',20},{'hp_max_per',20},{'speed',3}}, bid=10501, res_id="H50005", head_id=2006, head_card_id=2006, bustid=2006, draw_res="tianxinnvpu", draw_offset={{0,-30}}, scale=75, draw_offset_2={{150,30}}, scale_2=89, show_effect="E25001", fight_effect="E25101", action_bid=991032, action_start_time={2019,10,1,0,0,0}, action_end_time={2019,10,3,23,59,59}, voice="d_voice_10501", voice_time=5, item_id_list={23016,23017}, hero_info_bg_res="hero_info_bg_1", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=1},
	[107] = {skin_id=107, skin_name="暗影暴君", skin_attr={{'crit_ratio',30},{'hp_max_per',20},{'crit_rate',20}}, bid=50504, res_id="H50006", head_id=2007, head_card_id=2007, bustid=2007, draw_res="anyingbaojun", draw_offset={{-10,-15}}, scale=50, draw_offset_2={{-30,105}}, scale_2=65, show_effect="E25005", fight_effect="E25105", action_bid=0, action_start_time={}, action_end_time={}, voice="d_voice_50504", voice_time=4, item_id_list={23019,23020}, hero_info_bg_res="hero_info_bg_5", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=1},
	[108] = {skin_id=108, skin_name="竹韵清风", skin_attr={{'atk_per',20},{'hp_max_per',20},{'cure',30}}, bid=30507, res_id="H50007", head_id=2008, head_card_id=2008, bustid=2008, draw_res="zhuyunqingfeng", draw_offset={{-20,60}}, scale=70, draw_offset_2={{-50,135}}, scale_2=85, show_effect="E25003", fight_effect="E25103", action_bid=0, action_start_time={}, action_end_time={}, voice="d_voice_30507", voice_time=3, item_id_list={23022,23023}, hero_info_bg_res="hero_info_bg_3", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=1},
	[109] = {skin_id=109, skin_name="暴走青春", skin_attr={{'atk_per',20},{'hp_max_per',20},{'crit_rate',20}}, bid=50508, res_id="H50008", head_id=2009, head_card_id=2009, bustid=2009, draw_res="baozouqingchun", draw_offset={{40,20}}, scale=75, draw_offset_2={{50,80}}, scale_2=85, show_effect="E25005", fight_effect="E25105", action_bid=0, action_start_time={}, action_end_time={}, voice="d_voice_50508", voice_time=3, item_id_list={23025,23026}, hero_info_bg_res="hero_info_bg_5", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=1},
	[110] = {skin_id=110, skin_name="绽放的誓约", skin_attr={{'atk_per',20},{'hp_max_per',20},{'crit_rate',20}}, bid=40503, res_id="H50009", head_id=2010, head_card_id=2010, bustid=2010, draw_res="zhanfangdeshiyue", draw_offset={{100,30}}, scale=55, draw_offset_2={{180,60}}, scale_2=80, show_effect="E25004", fight_effect="E25104", action_bid=991032, action_start_time={2019,10,24,0,0,0}, action_end_time={2019,10,30,23,59,59}, voice="d_voice_40503", voice_time=3, item_id_list={23028,23029}, hero_info_bg_res="hero_info_bg_4", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=1},
	[111] = {skin_id=111, skin_name="魅夜男爵", skin_attr={{'hp_max_per',20},{'def_per',20},{'speed',3}}, bid=20507, res_id="H50010", head_id=2011, head_card_id=2011, bustid=2011, draw_res="meiyenanjue", draw_offset={{60,10}}, scale=80, draw_offset_2={{60,10}}, scale_2=80, show_effect="E25002", fight_effect="E25102", action_bid=0, action_start_time={}, action_end_time={}, voice="d_voice_20507", voice_time=2, item_id_list={23031,23032}, hero_info_bg_res="hero_info_bg_2", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=1},
	[112] = {skin_id=112, skin_name="冰雪圆舞曲", skin_attr={{'hp_max_per',20},{'def_per',20},{'speed',3}}, bid=40506, res_id="H50011", head_id=2012, head_card_id=2012, bustid=2012, draw_res="bingxueyuanwuqu", draw_offset={{80,45}}, scale=70, draw_offset_2={{80,55}}, scale_2=70, show_effect="E25004", fight_effect="E25104", action_bid=0, action_start_time={}, action_end_time={}, voice="d_voice_40506", voice_time=2, item_id_list={23034,23035}, hero_info_bg_res="hero_info_bg_4", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=1},
	[113] = {skin_id=113, skin_name="圣诞天使", skin_attr={{'atk_per',20},{'hp_max_per',20},{'speed',3}}, bid=40508, res_id="H50012", head_id=2013, head_card_id=2013, bustid=2013, draw_res="shengdantianshi", draw_offset={{-40,20}}, scale=75, draw_offset_2={{-40,20}}, scale_2=75, show_effect="E25004", fight_effect="E25104", action_bid=991032, action_start_time={2019,12,25,0,0,0}, action_end_time={2020,1,1,23,59,59}, voice="d_voice_40508", voice_time=3, item_id_list={23037,23038}, hero_info_bg_res="hero_info_bg_4", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=0},
	[114] = {skin_id=114, skin_name="锦绣霓裳", skin_attr={{'atk_per',20},{'hp_max_per',20},{'crit_rate',20}}, bid=30508, res_id="H50013", head_id=2014, head_card_id=2014, bustid=2014, draw_res="jinxiunishang", draw_offset={{-40,20}}, scale=75, draw_offset_2={{-40,20}}, scale_2=75, show_effect="E25007", fight_effect="E25107", action_bid=993045, action_start_time={2020,1,23,0,0,0}, action_end_time={2020,1,29,23,59,59}, voice="d_voice_30508", voice_time=1, item_id_list={23040,23041}, hero_info_bg_res="hero_info_bg_jinxiunishang", hero_camp_res="null", chip_num=200, diamond_num={{3,5000}}, is_shop=0},
	[115] = {skin_id=115, skin_name="一战封神", skin_attr={{'atk_per',20},{'hp_max_per',20},{'cure',30}}, bid=30507, res_id="H50014", head_id=2015, head_card_id=2015, bustid=2015, draw_res="yizhanfengshen", draw_offset={{-40,20}}, scale=75, draw_offset_2={{-40,20}}, scale_2=75, show_effect="E25003", fight_effect="E25103", action_bid=991032, action_start_time={2020,1,16,0,0,0}, action_end_time={2020,1,22,23,59,59}, voice="d_voice_30507", voice_time=3, item_id_list={23043,23044}, hero_info_bg_res="hero_info_bg_3", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=1},
	[116] = {skin_id=116, skin_name="黯灭金属", skin_attr={{'crit_ratio',30},{'hp_max_per',20},{'crit_rate',20}}, bid=50509, res_id="H50015", head_id=2016, head_card_id=2016, bustid=2016, draw_res="anmiejinshu", draw_offset={{-25,20}}, scale=65, draw_offset_2={{-25,20}}, scale_2=65, show_effect="E25005", fight_effect="E25105", action_bid=0, action_start_time={}, action_end_time={}, voice="d_voice_50509", voice_time=4, item_id_list={23046,23047}, hero_info_bg_res="hero_info_bg_5", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=0},
	[117] = {skin_id=117, skin_name="玫瑰之恋", skin_attr={{'crit_ratio',30},{'hp_max_per',20},{'crit_rate',20}}, bid=50508, res_id="H50016", head_id=2017, head_card_id=2017, bustid=2017, draw_res="meiguizhilian", draw_offset={{20,20}}, scale=85, draw_offset_2={{20,20}}, scale_2=85, show_effect="E25005", fight_effect="E25105", action_bid=993045, action_start_time={2020,3,12,0,0,0}, action_end_time={2020,3,17,23,59,59}, voice="d_voice_50508", voice_time=4, item_id_list={23049,23050}, hero_info_bg_res="hero_info_bg_5", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=0},
	[118] = {skin_id=118, skin_name="岚月刃歌", skin_attr={{'atk_per',20},{'hp_max_per',20},{'crit_ratio',30}}, bid=30509, res_id="H50017", head_id=2018, head_card_id=2018, bustid=2018, draw_res="lanyuerenge", draw_offset={{-20,20}}, scale=75, draw_offset_2={{-20,20}}, scale_2=75, show_effect="E25003", fight_effect="E25103", action_bid=0, action_start_time={}, action_end_time={}, voice="d_voice_30509", voice_time=3, item_id_list={23052,23053}, hero_info_bg_res="hero_info_bg_3", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=0},
	[119] = {skin_id=119, skin_name="元气拉拉队", skin_attr={{'atk_per',20},{'hp_max_per',20},{'speed',3}}, bid=40508, res_id="H50018", head_id=2019, head_card_id=2019, bustid=2019, draw_res="yuanqilaladui", draw_offset={{0,20}}, scale=85, draw_offset_2={{0,20}}, scale_2=85, show_effect="E25004", fight_effect="E25104", action_bid=0, action_start_time={}, action_end_time={}, voice="d_voice_40508", voice_time=3, item_id_list={23055,23056}, hero_info_bg_res="hero_info_bg_4", hero_camp_res="", chip_num=200, diamond_num={{3,5000}}, is_shop=0}
}
Config.PartnerSkinData.data_skin_info_fun = function(key)
	local data=Config.PartnerSkinData.data_skin_info[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerSkinData.data_skin_info['..key..'])not found') return
	end
	return data
end
-- -------------------skin_info_end---------------------


-- -------------------hero_info_start-------------------
Config.PartnerSkinData.data_hero_info_length = 0
Config.PartnerSkinData.data_hero_info_cache = {}
Config.PartnerSkinData.data_hero_info = function(key)
	if Config.PartnerSkinData.data_hero_info_cache[key] == nil then
		local base = Config.PartnerSkinData.data_hero_info_table[key]
		if not base then return end
		base = loadstring(string.format('return %s',base))()
		if not base then return end
		Config.PartnerSkinData.data_hero_info_cache[key] = {
			skin_id = base[1],
			content = base[2],
		}
	end
	return Config.PartnerSkinData.data_hero_info_cache[key] 
end
Config.PartnerSkinData.data_hero_info_table = {

}
-- -------------------hero_info_end---------------------


-- -------------------partner_bid_info_start-------------------
Config.PartnerSkinData.data_partner_bid_info_length = 15
Config.PartnerSkinData.data_partner_bid_info = {
	[30508] = {
		[101] = {skin_id=101},
		[114] = {skin_id=114},
	},
	[40507] = {
		[102] = {skin_id=102},
	},
	[20508] = {
		[103] = {skin_id=103},
	},
	[10505] = {
		[104] = {skin_id=104},
	},
	[50507] = {
		[105] = {skin_id=105},
	},
	[10501] = {
		[106] = {skin_id=106},
	},
	[50504] = {
		[107] = {skin_id=107},
	},
	[30507] = {
		[108] = {skin_id=108},
		[115] = {skin_id=115},
	},
	[50508] = {
		[109] = {skin_id=109},
		[117] = {skin_id=117},
	},
	[40503] = {
		[110] = {skin_id=110},
	},
	[20507] = {
		[111] = {skin_id=111},
	},
	[40506] = {
		[112] = {skin_id=112},
	},
	[40508] = {
		[113] = {skin_id=113},
		[119] = {skin_id=119},
	},
	[50509] = {
		[116] = {skin_id=116},
	},
	[30509] = {
		[118] = {skin_id=118},
	},
}
-- -------------------partner_bid_info_end---------------------


-- -------------------skilltoeffect_start-------------------
Config.PartnerSkinData.data_skilltoeffect_length = 58
Config.PartnerSkinData.data_skilltoeffect = {
	["114_5030001"] = 10000,
	["114_5031001"] = 10011,
	["114_5031002"] = 10011,
	["114_5031003"] = 10011,
	["114_5033001"] = 10031,
	["114_5033002"] = 10031,
	["114_5033003"] = 10031,
	["114_5039001"] = 10000,
	["115_5040001"] = 10110,
	["115_5041001"] = 10111,
	["115_5041002"] = 10111,
	["115_5041003"] = 10111,
	["115_5043001"] = 10121,
	["115_5043002"] = 10121,
	["115_5043003"] = 10121,
	["115_5049001"] = 95009001,
	["116_5210001"] = 10201,
	["116_5211001"] = 10211,
	["116_5211002"] = 10211,
	["116_5211003"] = 10211,
	["116_5213011"] = 10231,
	["116_5213012"] = 10231,
	["116_5213013"] = 10231,
	["116_5213099"] = 10239,
	["116_5215001"] = 10251,
	["116_5215002"] = 10251,
	["116_5215003"] = 10251,
	["116_5219001"] = 10291,
	["117_5160001"] = 10301,
	["117_5161001"] = 10311,
	["117_5161002"] = 10311,
	["117_5161003"] = 10311,
	["117_5163001"] = 10331,
	["117_5163002"] = 10331,
	["117_5163003"] = 10331,
	["117_5169001"] = 10391,
	["118_5150001"] = 10401,
	["118_5151011"] = 10411,
	["118_5151012"] = 10411,
	["118_5151013"] = 10411,
	["118_5153101"] = 10431,
	["118_5153102"] = 10431,
	["118_5153103"] = 10431,
	["118_5153201"] = 10432,
	["118_5153202"] = 10432,
	["118_5153203"] = 10432,
	["118_5153301"] = 10433,
	["118_5153302"] = 10433,
	["118_5153303"] = 10433,
	["118_5159001"] = 10491,
	["119_5140001"] = 10501,
	["119_5141011"] = 10511,
	["119_5141012"] = 10511,
	["119_5141013"] = 10511,
	["119_5143001"] = 10531,
	["119_5143002"] = 10531,
	["119_5143003"] = 10531,
	["119_5149001"] = 10591
}
Config.PartnerSkinData.data_skilltoeffect_fun = function(key)
	local data=Config.PartnerSkinData.data_skilltoeffect[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerSkinData.data_skilltoeffect['..key..'])not found') return
	end
	return data
end
-- -------------------skilltoeffect_end---------------------


-- -------------------bufftospine_start-------------------
Config.PartnerSkinData.data_bufftospine_length = 9
Config.PartnerSkinData.data_bufftospine = {
	["116_16501"] = {spine_res="H35106", effect_bid=0},
	["116_16502"] = {spine_res="H35106", effect_bid=0},
	["116_16503"] = {spine_res="H35106", effect_bid=0},
	["118_16201"] = {spine_res="", effect_bid=50026},
	["118_16202"] = {spine_res="", effect_bid=50026},
	["118_16203"] = {spine_res="", effect_bid=50026},
	["119_19101"] = {spine_res="", effect_bid=50031},
	["119_19102"] = {spine_res="", effect_bid=50031},
	["119_19103"] = {spine_res="", effect_bid=50031}
}
Config.PartnerSkinData.data_bufftospine_fun = function(key)
	local data=Config.PartnerSkinData.data_bufftospine[key]
	if DATA_DEBUG and data == nil then
		print('(Config.PartnerSkinData.data_bufftospine['..key..'])not found') return
	end
	return data
end
-- -------------------bufftospine_end---------------------
