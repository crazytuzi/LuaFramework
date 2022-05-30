-- this file is generated by program!
-- don't change it manaully.
-- source file: sprite_data.xls

Config = Config or {}
Config.SpriteData = Config.SpriteData or {}
Config.SpriteData.data_elfin_data_key_depth = 1
Config.SpriteData.data_elfin_data_length = 85
Config.SpriteData.data_elfin_data_lan = "zh"
Config.SpriteData.data_elfin_data_cache = {}
Config.SpriteData.data_elfin_data = function(key)
	if Config.SpriteData.data_elfin_data_cache[key] == nil then
		local base = Config.SpriteData.data_elfin_data_table[key]
		if not base then return end
		Config.SpriteData.data_elfin_data_cache[key] = {
			effect_id = base[1], --预留注释
			icon = base[2], --预留注释
			id = base[3], --预留注释
			res_id = base[4], --预留注释
			offset_y = base[5], --预留注释
			power = base[6], --预留注释
			scale_val = base[7], --预留注释
			skill = base[8], --预留注释
			sprite_type = base[9], --预留注释
			step = base[10], --预留注释
		}
	end
	return Config.SpriteData.data_elfin_data_cache[key] 
end

Config.SpriteData.data_elfin_data_table = {
	[111001] = {"E70001", 111001, 111001, 111001, "-10", 50, 1, 21011, 1, 1},
	[111002] = {"E70002", 111002, 111002, 111002, "20", 50, 1, 21021, 2, 1},
	[111003] = {"E70003", 111003, 111003, 111003, "20", 75, 1, 21031, 3, 1},
	[111004] = {"E70004", 111004, 111004, 111004, "20", 75, 1, 21041, 4, 1},
	[111005] = {"E70005", 111005, 111005, 111005, "0", 50, 1, 21051, 5, 1},
	[111101] = {"E70001", 111001, 111101, 111001, "-10", 100, 1, 21012, 1, 2},
	[111102] = {"E70002", 111002, 111102, 111002, "20", 100, 1, 21022, 2, 2},
	[111103] = {"E70003", 111003, 111103, 111003, "20", 150, 1, 21032, 3, 2},
	[111104] = {"E70004", 111004, 111104, 111004, "20", 150, 1, 21042, 4, 2},
	[111105] = {"E70005", 111005, 111105, 111005, "0", 100, 1, 21052, 5, 2},
	[111201] = {"E70001", 111001, 111201, 111001, "-10", 200, 1, 21013, 1, 3},
	[111202] = {"E70002", 111002, 111202, 111002, "20", 200, 1, 21023, 2, 3},
	[111203] = {"E70003", 111003, 111203, 111003, "20", 300, 1, 21033, 3, 3},
	[111204] = {"E70004", 111004, 111204, 111004, "20", 300, 1, 21043, 4, 3},
	[111205] = {"E70005", 111005, 111205, 111005, "0", 200, 1, 21053, 5, 3},
	[111301] = {"E70001", 111001, 111301, 111001, "-10", 350, 1, 21014, 1, 4},
	[111302] = {"E70002", 111002, 111302, 111002, "20", 350, 1, 21024, 2, 4},
	[111303] = {"E70003", 111003, 111303, 111003, "20", 525, 1, 21034, 3, 4},
	[111304] = {"E70004", 111004, 111304, 111004, "20", 525, 1, 21044, 4, 4},
	[111305] = {"E70005", 111005, 111305, 111005, "0", 350, 1, 21054, 5, 4},
	[111401] = {"E70001", 111001, 111401, 111001, "-10", 550, 1, 21015, 1, 5},
	[111402] = {"E70002", 111002, 111402, 111002, "20", 550, 1, 21025, 2, 5},
	[111403] = {"E70003", 111003, 111403, 111003, "20", 825, 1, 21035, 3, 5},
	[111404] = {"E70004", 111004, 111404, 111004, "20", 825, 1, 21045, 4, 5},
	[111405] = {"E70005", 111005, 111405, 111005, "0", 550, 1, 21055, 5, 5},
	[112001] = {"E70006", 112001, 112001, 112001, "20", 150, 1, 22011, 6, 1},
	[112002] = {"E70007", 112002, 112002, 112002, "-10", 150, 1, 22021, 7, 1},
	[112003] = {"E70008", 112003, 112003, 112003, "-10", 150, 1, 22031, 8, 1},
	[112004] = {"E70009", 112004, 112004, 112004, "0", 150, 1, 22041, 9, 1},
	[112101] = {"E70006", 112001, 112101, 112001, "20", 300, 1, 22012, 6, 2},
	[112102] = {"E70007", 112002, 112102, 112002, "-10", 300, 1, 22022, 7, 2},
	[112103] = {"E70008", 112003, 112103, 112003, "-10", 300, 1, 22032, 8, 2},
	[112104] = {"E70009", 112004, 112104, 112004, "0", 300, 1, 22042, 9, 2},
	[112201] = {"E70006", 112001, 112201, 112001, "20", 600, 1, 22013, 6, 3},
	[112202] = {"E70007", 112002, 112202, 112002, "-10", 600, 1, 22023, 7, 3},
	[112203] = {"E70008", 112003, 112203, 112003, "-10", 600, 1, 22033, 8, 3},
	[112204] = {"E70009", 112004, 112204, 112004, "0", 600, 1, 22043, 9, 3},
	[112301] = {"E70006", 112001, 112301, 112001, "20", 1050, 1, 22014, 6, 4},
	[112302] = {"E70007", 112002, 112302, 112002, "-10", 1050, 1, 22024, 7, 4},
	[112303] = {"E70008", 112003, 112303, 112003, "-10", 1050, 1, 22034, 8, 4},
	[112304] = {"E70009", 112004, 112304, 112004, "0", 1050, 1, 22044, 9, 4},
	[112401] = {"E70006", 112001, 112401, 112001, "20", 1650, 1, 22015, 6, 5},
	[112402] = {"E70007", 112002, 112402, 112002, "-10", 1650, 1, 22025, 7, 5},
	[112403] = {"E70008", 112003, 112403, 112003, "-10", 1650, 1, 22035, 8, 5},
	[112404] = {"E70009", 112004, 112404, 112004, "0", 1650, 1, 22045, 9, 5},
	[113001] = {"E70010", 113001, 113001, 113001, "-15", 475, 1, 23011, 10, 1},
	[113002] = {"E70011", 113002, 113002, 113002, "-20", 500, 1, 23021, 11, 1},
	[113003] = {"E70012", 113003, 113003, 113003, "-15", 475, 1, 23031, 12, 1},
	[113004] = {"E70013", 113004, 113004, 113004, "-15", 500, 1, 23041, 13, 1},
	[113005] = {"E70014", 113005, 113005, 113005, "-15", 500, 1, 23051, 14, 1},
	[113006] = {"E70016", 113006, 113006, 113006, "-15", 500, 1, 23061, 15, 1},
	[113007] = {"E70017", 113007, 113007, 113007, "-15", 500, 1, 23071, 16, 1},
	[113008] = {"E70018", 113008, 113008, 113008, "-15", 500, 1, 23081, 17, 1},
	[113101] = {"E70010", 113001, 113101, 113001, "-15", 950, 1, 23012, 10, 2},
	[113102] = {"E70011", 113002, 113102, 113002, "-20", 1000, 1, 23022, 11, 2},
	[113103] = {"E70012", 113003, 113103, 113003, "-15", 950, 1, 23032, 12, 2},
	[113104] = {"E70013", 113004, 113104, 113004, "-15", 1000, 1, 23042, 13, 2},
	[113105] = {"E70014", 113005, 113105, 113005, "-15", 1000, 1, 23052, 14, 2},
	[113106] = {"E70016", 113006, 113106, 113006, "-15", 1000, 1, 23062, 15, 2},
	[113107] = {"E70017", 113007, 113107, 113007, "-15", 1000, 1, 23072, 16, 2},
	[113108] = {"E70018", 113008, 113108, 113008, "-15", 1000, 1, 23082, 17, 2},
	[113201] = {"E70010", 113001, 113201, 113001, "-15", 1900, 1, 23013, 10, 3},
	[113202] = {"E70011", 113002, 113202, 113002, "-20", 2000, 1, 23023, 11, 3},
	[113203] = {"E70012", 113003, 113203, 113003, "-15", 1900, 1, 23033, 12, 3},
	[113204] = {"E70013", 113004, 113204, 113004, "-15", 2000, 1, 23043, 13, 3},
	[113205] = {"E70014", 113005, 113205, 113005, "-15", 2000, 1, 23053, 14, 3},
	[113206] = {"E70016", 113006, 113206, 113006, "-15", 2000, 1, 23063, 15, 3},
	[113207] = {"E70017", 113007, 113207, 113007, "-15", 2000, 1, 23073, 16, 3},
	[113208] = {"E70018", 113008, 113208, 113008, "-15", 2000, 1, 23083, 17, 3},
	[113301] = {"E70010", 113001, 113301, 113001, "-15", 3325, 1, 23014, 10, 4},
	[113302] = {"E70011", 113002, 113302, 113002, "-20", 3500, 1, 23024, 11, 4},
	[113303] = {"E70012", 113003, 113303, 113003, "-15", 3325, 1, 23034, 12, 4},
	[113304] = {"E70013", 113004, 113304, 113004, "-15", 3500, 1, 23044, 13, 4},
	[113305] = {"E70014", 113005, 113305, 113005, "-15", 3500, 1, 23054, 14, 4},
	[113306] = {"E70016", 113006, 113306, 113006, "-15", 3500, 1, 23064, 15, 4},
	[113307] = {"E70017", 113007, 113307, 113007, "-15", 3500, 1, 23074, 16, 4},
	[113308] = {"E70018", 113008, 113308, 113008, "-15", 3500, 1, 23084, 17, 4},
	[113401] = {"E70010", 113001, 113401, 113001, "-15", 5225, 1, 23015, 10, 5},
	[113402] = {"E70011", 113002, 113402, 113002, "-20", 5500, 1, 23025, 11, 5},
	[113403] = {"E70012", 113003, 113403, 113003, "-15", 5225, 1, 23035, 12, 5},
	[113404] = {"E70013", 113004, 113404, 113004, "-15", 5500, 1, 23045, 13, 5},
	[113405] = {"E70014", 113005, 113405, 113005, "-15", 5500, 1, 23055, 14, 5},
	[113406] = {"E70016", 113006, 113406, 113006, "-15", 5500, 1, 23065, 15, 5},
	[113407] = {"E70017", 113007, 113407, 113007, "-15", 5500, 1, 23075, 16, 5},
	[113408] = {"E70018", 113008, 113408, 113008, "-15", 5500, 1, 23085, 17, 5},
}
