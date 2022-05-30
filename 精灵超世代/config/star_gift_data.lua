----------------------------------------------------
-- 此文件由数据工具生成
-- 星级养成礼配置数据--star_gift_data.xml
--------------------------------------

Config = Config or {} 
Config.StarGiftData = Config.StarGiftData or {}

-- -------------------limit_gift_start-------------------
Config.StarGiftData.data_limit_gift_length = 0
Config.StarGiftData.data_limit_gift_cache = {}
Config.StarGiftData.data_limit_gift = function(key)
	if Config.StarGiftData.data_limit_gift_cache[key] == nil then
		local base = Config.StarGiftData.data_limit_gift_table[key]
		if not base then return end
		base = loadstring(string.format('return %s',base))()
		if not base then return end
		Config.StarGiftData.data_limit_gift_cache[key] = {
			id = base[1],
			name = base[2],
			gift_type = base[3],
			codition = base[4],
			reward = base[5],
			package_id = base[6],
			time = base[7],
			ico = base[8],
			res_1 = base[9],
			res_2 = base[10],
			desc = base[11],
		}
	end
	return Config.StarGiftData.data_limit_gift_cache[key] 
end
Config.StarGiftData.data_limit_gift_table = {

}
-- -------------------limit_gift_end---------------------
