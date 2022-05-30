----------------------------------------------------
-- 此文件由数据工具生成
-- 精英赛配置数据--arena_peak_champion_data.xml
--------------------------------------

Config = Config or {} 
Config.ArenaPeakChampionData = Config.ArenaPeakChampionData or {}

LocalizedConfigRequire("config.auto_config.arena_peak_champion_data@data_const")
LocalizedConfigRequire("config.auto_config.arena_peak_champion_data@data_explain")
LocalizedConfigRequire("config.auto_config.arena_peak_champion_data@data_explain_guess")
LocalizedConfigRequire("config.auto_config.arena_peak_champion_data@data_rank_reward")

-- -------------------const_start-------------------
Config.ArenaPeakChampionData.data_const_fun = function(key)
	local data=Config.ArenaPeakChampionData.data_const[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaPeakChampionData.data_const['..key..'])not found') return
	end
	return data
end
-- -------------------const_end---------------------


-- -------------------rank_reward_start-------------------
-- -------------------rank_reward_end---------------------


-- -------------------explain_start-------------------
Config.ArenaPeakChampionData.data_explain_fun = function(key)
	local data=Config.ArenaPeakChampionData.data_explain[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaPeakChampionData.data_explain['..key..'])not found') return
	end
	return data
end
-- -------------------explain_end---------------------


-- -------------------explain_guess_start-------------------
Config.ArenaPeakChampionData.data_explain_guess_fun = function(key)
	local data=Config.ArenaPeakChampionData.data_explain_guess[key]
	if DATA_DEBUG and data == nil then
		print('(Config.ArenaPeakChampionData.data_explain_guess['..key..'])not found') return
	end
	return data
end
-- -------------------explain_guess_end---------------------
