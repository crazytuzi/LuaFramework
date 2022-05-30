-- this file is generated by program!
-- don't change it manaully.
-- source file: hallows_data.xls

Config = Config or {}
Config.HallowsData = Config.HallowsData or {}
Config.HallowsData.data_trace_cost_key_depth = 1
Config.HallowsData.data_trace_cost_length = 120
Config.HallowsData.data_trace_cost_lan = "en"
Config.HallowsData.data_trace_cost_cache = {}
Config.HallowsData.data_trace_cost = function(key)
	if Config.HallowsData.data_trace_cost_cache[key] == nil then
		local base = Config.HallowsData.data_trace_cost_table[key]
		if not base then return end
		Config.HallowsData.data_trace_cost_cache[key] = {
			num = base[1], --预留注释
		}
	end
	return Config.HallowsData.data_trace_cost_cache[key] 
end

Config.HallowsData.data_trace_cost_table = {
	["1_1"] = {0},
	["1_10"] = {35},
	["1_11"] = {40},
	["1_12"] = {45},
	["1_13"] = {50},
	["1_14"] = {55},
	["1_15"] = {60},
	["1_16"] = {65},
	["1_17"] = {70},
	["1_18"] = {75},
	["1_19"] = {80},
	["1_2"] = {0},
	["1_20"] = {85},
	["1_21"] = {90},
	["1_22"] = {95},
	["1_23"] = {100},
	["1_24"] = {105},
	["1_3"] = {3},
	["1_4"] = {5},
	["1_5"] = {10},
	["1_6"] = {15},
	["1_7"] = {20},
	["1_8"] = {25},
	["1_9"] = {30},
	["2_1"] = {0},
	["2_10"] = {35},
	["2_11"] = {40},
	["2_12"] = {45},
	["2_13"] = {50},
	["2_14"] = {55},
	["2_15"] = {60},
	["2_16"] = {65},
	["2_17"] = {70},
	["2_18"] = {75},
	["2_19"] = {80},
	["2_2"] = {0},
	["2_20"] = {85},
	["2_21"] = {90},
	["2_22"] = {95},
	["2_23"] = {100},
	["2_24"] = {105},
	["2_3"] = {3},
	["2_4"] = {5},
	["2_5"] = {10},
	["2_6"] = {15},
	["2_7"] = {20},
	["2_8"] = {25},
	["2_9"] = {30},
	["3_1"] = {0},
	["3_10"] = {35},
	["3_11"] = {40},
	["3_12"] = {45},
	["3_13"] = {50},
	["3_14"] = {55},
	["3_15"] = {60},
	["3_16"] = {65},
	["3_17"] = {70},
	["3_18"] = {75},
	["3_19"] = {80},
	["3_2"] = {0},
	["3_20"] = {85},
	["3_21"] = {90},
	["3_22"] = {95},
	["3_23"] = {100},
	["3_24"] = {105},
	["3_3"] = {3},
	["3_4"] = {5},
	["3_5"] = {10},
	["3_6"] = {15},
	["3_7"] = {20},
	["3_8"] = {25},
	["3_9"] = {30},
	["4_1"] = {0},
	["4_10"] = {35},
	["4_11"] = {40},
	["4_12"] = {45},
	["4_13"] = {50},
	["4_14"] = {55},
	["4_15"] = {60},
	["4_16"] = {65},
	["4_17"] = {70},
	["4_18"] = {75},
	["4_19"] = {80},
	["4_2"] = {0},
	["4_20"] = {85},
	["4_21"] = {90},
	["4_22"] = {95},
	["4_23"] = {100},
	["4_24"] = {105},
	["4_3"] = {3},
	["4_4"] = {5},
	["4_5"] = {10},
	["4_6"] = {15},
	["4_7"] = {20},
	["4_8"] = {25},
	["4_9"] = {30},
	["5_1"] = {0},
	["5_10"] = {35},
	["5_11"] = {40},
	["5_12"] = {45},
	["5_13"] = {50},
	["5_14"] = {55},
	["5_15"] = {60},
	["5_16"] = {65},
	["5_17"] = {70},
	["5_18"] = {75},
	["5_19"] = {80},
	["5_2"] = {0},
	["5_20"] = {85},
	["5_21"] = {90},
	["5_22"] = {95},
	["5_23"] = {100},
	["5_24"] = {105},
	["5_3"] = {3},
	["5_4"] = {5},
	["5_5"] = {10},
	["5_6"] = {15},
	["5_7"] = {20},
	["5_8"] = {25},
	["5_9"] = {30},
}
