----------------------------------------------------
-- 此文件由数据工具生成
-- 物品数据--item_data.xml
--------------------------------------

Config = Config or {} 
Config.ItemData5 = Config.ItemData5 or {}

-- -------------------unit_start-------------------
Config.ItemData5.data_unit_length = 0
Config.ItemData5.data_unit_cache = {}
Config.ItemData5.data_unit = function(key)
	if Config.ItemData5.data_unit_cache[key] == nil then
		local base = Config.ItemData5.data_unit_table[key]
		if not base then return end
		base = loadstring(string.format('return %s',base))()
		if not base then return end
		Config.ItemData5.data_unit_cache[key] = {
			id = base[1],
			name = base[2],
			icon = base[3],
			type = base[4],
			sub_type = base[5],
			quality = base[6],
			overlap = base[7],
			gain_type = base[8],
			use_type = base[9],
			value = base[10],
			desc = base[11],
			lev = base[12],
			career = base[13],
			eqm_set = base[14],
			ext = base[15],
			is_effect = base[16],
			tips_btn = base[17],
			source = base[18],
			type_desc = base[19],
			can_share = base[20],
		}
	end
	return Config.ItemData5.data_unit_cache[key] 
end
Config.ItemData5.data_unit_table = {

}
-- -------------------unit_end---------------------
