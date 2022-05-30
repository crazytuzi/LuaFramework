----------------------------------------------------
-- 此文件由数据工具生成
-- 团购--holiday_groupon_data.xml
--------------------------------------

Config = Config or {} 
Config.HolidayGrouponData = Config.HolidayGrouponData or {}

-- -------------------const_start-------------------
Config.HolidayGrouponData.data_const_length = 0
Config.HolidayGrouponData.data_const = {

}
Config.HolidayGrouponData.data_const_fun = function(key)
	local data=Config.HolidayGrouponData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.HolidayGrouponData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------holiday_reward_start-------------------
Config.HolidayGrouponData.data_holiday_reward_length = 5
Config.HolidayGrouponData.data_holiday_reward = {
	[11001] = {
		[1] = {id=1, reward={{26907,50}}, gold=6000, discount={{0,800},{20,750},{50,700},{80,650},{100,600}}, limit=1, all_limit=0},
		[2] = {id=2, reward={{24904,50}}, gold=6000, discount={{0,800},{20,750},{50,700},{80,650},{100,600}}, limit=1, all_limit=0},
		[3] = {id=3, reward={{10453,1}}, gold=5000, discount={{0,800},{20,750},{50,700},{80,650},{100,600}}, limit=1, all_limit=0},
		[4] = {id=4, reward={{10403,10}}, gold=2500, discount={{0,800},{200,750},{500,700},{800,650},{1000,500}}, limit=1, all_limit=0},
		[5] = {id=5, reward={{29905,2}}, gold=200, discount={{0,800},{200,750},{500,700},{800,650},{1000,500}}, limit=25, all_limit=0},
	},
	[16010] = {
		[1] = {id=1, reward={{25907,50}}, gold=10000, discount={{0,900},{20,850},{50,800},{80,750},{100,700}}, limit=1, all_limit=0},
		[2] = {id=2, reward={{24903,50}}, gold=10000, discount={{0,900},{20,850},{50,800},{80,750},{100,700}}, limit=1, all_limit=0},
		[3] = {id=3, reward={{10454,1}}, gold=25000, discount={{0,800},{10,750},{20,700},{30,650},{50,600}}, limit=1, all_limit=0},
		[4] = {id=4, reward={{10403,10}}, gold=2500, discount={{0,800},{50,750},{100,700},{150,600},{200,500}}, limit=1, all_limit=0},
		[5] = {id=5, reward={{29905,2}}, gold=200, discount={{0,800},{250,700},{500,650},{750,600},{1000,500}}, limit=10, all_limit=0},
	},
	[23001] = {
		[1] = {id=1, reward={{28903,50}}, gold=16000, discount={{0,800},{20,750},{50,700},{80,600},{100,500}}, limit=0, all_limit=1},
		[2] = {id=2, reward={{26907,50}}, gold=10000, discount={{0,800},{20,750},{50,700},{80,600},{100,500}}, limit=0, all_limit=1},
		[3] = {id=3, reward={{10450,2000}}, gold=2000, discount={{0,800},{50,750},{100,700},{150,600},{200,500}}, limit=2, all_limit=0},
		[4] = {id=4, reward={{10403,10}}, gold=2500, discount={{0,800},{50,750},{100,700},{150,600},{200,500}}, limit=1, all_limit=0},
		[5] = {id=5, reward={{29905,2}}, gold=200, discount={{0,800},{250,700},{500,650},{750,600},{1000,500}}, limit=10, all_limit=0},
	},
	[31012] = {
		[1] = {id=1, reward={{27901,50}}, gold=16000, discount={{0,800},{20,750},{50,700},{80,600},{100,500}}, limit=0, all_limit=1},
		[2] = {id=2, reward={{28903,50}}, gold=16000, discount={{0,800},{20,750},{50,700},{80,600},{100,500}}, limit=0, all_limit=1},
		[3] = {id=3, reward={{26907,50}}, gold=12000, discount={{0,800},{20,750},{50,700},{80,600},{100,500}}, limit=0, all_limit=1},
		[4] = {id=4, reward={{10403,10}}, gold=2500, discount={{0,800},{50,750},{100,700},{150,600},{200,500}}, limit=1, all_limit=0},
		[5] = {id=5, reward={{10450,2000}}, gold=2000, discount={{0,800},{50,750},{100,700},{150,600},{200,500}}, limit=5, all_limit=0},
	},
	[46013] = {
		[1] = {id=1, reward={{27902,50}}, gold=16000, discount={{0,800},{20,750},{50,700},{80,600},{100,500}}, limit=0, all_limit=1},
		[2] = {id=2, reward={{24910,50}}, gold=12000, discount={{0,800},{20,750},{50,700},{80,600},{100,500}}, limit=0, all_limit=1},
		[3] = {id=3, reward={{10450,2000}}, gold=2000, discount={{0,800},{50,750},{100,700},{150,600},{200,500}}, limit=5, all_limit=0},
		[4] = {id=4, reward={{10403,10}}, gold=2500, discount={{0,800},{50,750},{100,700},{150,600},{200,500}}, limit=1, all_limit=0},
		[5] = {id=5, reward={{29905,2}}, gold=200, discount={{0,800},{250,700},{500,650},{750,600},{1000,500}}, limit=10, all_limit=0},
	},
}
-- -------------------holiday_reward_end---------------------
