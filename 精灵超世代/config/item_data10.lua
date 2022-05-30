----------------------------------------------------
-- 此文件由数据工具生成
-- 物品数据--item_data.xml
--------------------------------------

Config = Config or {} 
Config.ItemData10 = Config.ItemData10 or {}

-- -------------------unit_start-------------------
Config.ItemData10.data_unit_length = 1
Config.ItemData10.data_unit_cache = {}
Config.ItemData10.data_unit = function(key)
	if Config.ItemData10.data_unit_cache[key] == nil then
		local base = Config.ItemData10.data_unit_table[key]
		if not base then return end
		base = loadstring(string.format('return %s',base))()
		if not base then return end
		Config.ItemData10.data_unit_cache[key] = {
			id = base[1],
			name = base[2],
			icon = base[3],
			type = base[4],
			sub_type = base[5],
			quality = base[6],
			overlap = base[7],
			gain_type = base[8],
			use_type = base[9],
			expire_type = base[10],
			value = base[11],
			effect = base[12],
			client_effect = base[13],
			source = base[14],
			desc = base[15],
			lev = base[16],
			career = base[17],
			sex = base[18],
			ext = base[19],
			is_effect = base[20],
			eqm_jie = base[21],
			fast_use = base[22],
			tips_btn = base[23],
			type_desc = base[24],
			use_desc = base[25],
			can_share = base[26],
			use_count = base[27],
		}
	end
	return Config.ItemData10.data_unit_cache[key] 
end
Config.ItemData10.data_unit_table = {
	[300001] = [[{300001, "木锤", 300001, 0, 0, 2, 99, 0, 0, 0, {}, {}, {}, {}, "坚硬的木锤，能破坏某些障碍物。", 0, 0, 2, {}, 0, 0, 0, {}, "位面征战道具", "位面征战玩法中消耗", 0, 0}]]
}
-- -------------------unit_end---------------------
