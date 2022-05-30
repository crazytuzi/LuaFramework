----------------------------------------------------
-- 此文件由数据工具生成
-- 等级好礼配置数据--lev_gift_data.xml
--------------------------------------

Config = Config or {} 
Config.LevGiftData = Config.LevGiftData or {}

-- -------------------level_welfare_start-------------------
Config.LevGiftData.data_level_welfare_length = 6
Config.LevGiftData.data_level_welfare = {
	[1] = {id=1, lev=15, name="15级礼包", reward={{3,100},{10001,100},{1,50000},{22,50000}}, num=5000},
	[2] = {id=2, lev=25, name="25级礼包", reward={{10403,1},{10001,200},{1,100000},{22,100000}}, num=3000},
	[3] = {id=3, lev=35, name="35级礼包", reward={{10403,2},{72002,3},{1,200000},{22,150000}}, num=1500},
	[4] = {id=4, lev=45, name="45级礼包", reward={{10403,3},{40408,1},{1,300000},{22,200000}}, num=500},
	[5] = {id=5, lev=50, name="50级礼包", reward={{10403,5},{72003,1},{1,400000},{22,250000}}, num=100},
	[6] = {id=6, lev=55, name="55级礼包", reward={{10403,10},{40111,1},{1,500000},{22,300000}}, num=10}
}
Config.LevGiftData.data_level_welfare_fun = function(key)
	local data=Config.LevGiftData.data_level_welfare[key]
	if DATA_DEBUG and data == nil then
		print('(Config.LevGiftData.data_level_welfare['..key..'])not found') return
	end
	return data
end
-- -------------------level_welfare_end---------------------
