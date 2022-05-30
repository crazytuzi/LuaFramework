-- this file is generated by program!
-- don't change it manaully.
-- source file: guild_marketplace_data.xls

Config = Config or {}
Config.GuildMarketplaceData = Config.GuildMarketplaceData or {}
Config.GuildMarketplaceData.data_item_info_key_depth = 1
Config.GuildMarketplaceData.data_item_info_length = 56
Config.GuildMarketplaceData.data_item_info_lan = "zh"
Config.GuildMarketplaceData.data_item_info_cache = {}
Config.GuildMarketplaceData.data_item_info = function(key)
	if Config.GuildMarketplaceData.data_item_info_cache[key] == nil then
		local base = Config.GuildMarketplaceData.data_item_info_table[key]
		if not base then return end
		Config.GuildMarketplaceData.data_item_info_cache[key] = {
			capacity = base[1], --预留注释
			day_buy = base[2], --预留注释
			end_time = base[3], --预留注释
			id = base[4], --预留注释
			is_board = base[5], --预留注释
			is_pile = base[6], --预留注释
			is_sell = base[7], --预留注释
			max_pile = base[8], --预留注释
			name = base[9], --预留注释
			price = base[10], --预留注释
			radio = base[11], --预留注释
			sell = base[12], --预留注释
			type = base[13], --预留注释
		}
	end
	return Config.GuildMarketplaceData.data_item_info_cache[key] 
end

Config.GuildMarketplaceData.data_item_info_table = {
	[10001] = {15, 0, 30, 10001, 1, 1, 1, 49950, "神奇糖果", {{36,5}}, 50, {{36,1}}, 2},
	[10403] = {15, 10, 30, 10403, 1, 1, 0, 999, "高级精灵球", {{36,20}}, 1, {}, 2},
	[10453] = {15, 1, 30, 10453, 1, 0, 0, 1, "紫宝石", {{36,500}}, 1, {}, 3},
	[14001] = {15, 2, 30, 14001, 1, 1, 0, 999, "狩猎球", {{36,150}}, 1, {}, 2},
	[24902] = {15, 0, 30, 24902, 1, 1, 1, 999, "呱呱泡蛙碎片", {{36,12}}, 1, {{36,6}}, 0},
	[24905] = {15, 0, 30, 24905, 1, 1, 1, 999, "黑眼鳄碎片", {{36,10}}, 1, {{36,5}}, 0},
	[24906] = {15, 0, 30, 24906, 1, 1, 1, 999, "帝牙卢卡碎片", {{36,10}}, 1, {{36,5}}, 0},
	[24907] = {15, 0, 30, 24907, 1, 1, 1, 999, "水跃鱼碎片", {{36,10}}, 1, {{36,5}}, 0},
	[24908] = {15, 0, 30, 24908, 1, 1, 1, 999, "小锯鳄碎片", {{36,10}}, 1, {{36,5}}, 0},
	[24909] = {15, 0, 30, 24909, 1, 1, 0, 49950, "盖欧卡碎片", {{36,750}}, 50, {}, 0},
	[25900] = {15, 0, 30, 25900, 1, 1, 1, 999, "小火龙碎片", {{36,12}}, 1, {{36,6}}, 0},
	[25901] = {15, 0, 30, 25901, 1, 1, 1, 999, "火球鼠碎片", {{36,12}}, 1, {{36,6}}, 0},
	[25902] = {15, 0, 30, 25902, 1, 1, 1, 999, "暖暖猪碎片", {{36,10}}, 1, {{36,5}}, 0},
	[25903] = {15, 0, 30, 25903, 1, 1, 1, 999, "固拉多碎片", {{36,12}}, 1, {{36,6}}, 0},
	[25904] = {15, 0, 30, 25904, 1, 1, 1, 999, "火稚鸡碎片", {{36,12}}, 1, {{36,6}}, 0},
	[25905] = {15, 0, 30, 25905, 1, 1, 1, 999, "鸭嘴宝宝碎片", {{36,10}}, 1, {{36,5}}, 0},
	[25907] = {15, 0, 30, 25907, 1, 1, 0, 49950, "炎帝碎片", {{36,750}}, 50, {}, 0},
	[26900] = {15, 0, 30, 26900, 1, 1, 1, 999, "妙蛙种子碎片", {{36,12}}, 1, {{36,6}}, 0},
	[26902] = {15, 0, 30, 26902, 1, 1, 1, 999, "菊草叶碎片", {{36,12}}, 1, {{36,6}}, 0},
	[26903] = {15, 0, 30, 26903, 1, 1, 1, 999, "藤藤蛇碎片", {{36,12}}, 1, {{36,6}}, 0},
	[26904] = {15, 0, 30, 26904, 1, 1, 1, 999, "木木枭碎片", {{36,10}}, 1, {{36,5}}, 0},
	[26905] = {15, 0, 30, 26905, 1, 1, 1, 999, "木守宫碎片", {{36,12}}, 1, {{36,6}}, 0},
	[26906] = {15, 0, 30, 26906, 1, 1, 0, 49950, "蒂安希碎片", {{36,750}}, 50, {}, 0},
	[26907] = {15, 0, 30, 26907, 1, 1, 0, 999, "裂空座碎片", {{36,12}}, 1, {}, 0},
	[27903] = {15, 0, 30, 27903, 1, 1, 0, 49950, "电击怪碎片", {{36,800}}, 50, {}, 0},
	[28904] = {15, 0, 30, 28904, 1, 1, 0, 49950, "鬼斯碎片", {{36,800}}, 50, {}, 0},
	[29105] = {15, 0, 30, 29105, 1, 1, 1, 999, "5星水系碎片", {{36,12}}, 1, {{36,6}}, 0},
	[29205] = {15, 0, 30, 29205, 1, 1, 1, 999, "5星火系碎片", {{36,12}}, 1, {{36,6}}, 0},
	[29305] = {15, 0, 30, 29305, 1, 1, 1, 999, "5星草系碎片", {{36,12}}, 1, {{36,6}}, 0},
	[29905] = {15, 0, 30, 29905, 1, 1, 0, 999, "5星随机碎片", {{36,10}}, 1, {}, 0},
	[37001] = {15, 0, 30, 37001, 1, 1, 1, 999, "探宝券", {{36,3}}, 1, {{36,1}}, 2},
	[39047] = {15, 0, 30, 39047, 1, 1, 0, 999, "随机天赋石礼包", {{36,244}}, 1, {}, 2},
	[40105] = {15, 0, 30, 40105, 1, 1, 1, 999, "幸运铃铛", {{36,9}}, 1, {{36,1}}, 1},
	[40106] = {15, 0, 30, 40106, 1, 1, 1, 999, "心灵铃铛", {{36,15}}, 1, {{36,3}}, 1},
	[40107] = {15, 0, 30, 40107, 1, 1, 1, 999, "勇气铃铛", {{36,25}}, 1, {{36,5}}, 1},
	[40108] = {15, 0, 30, 40108, 1, 1, 1, 999, "突击铃铛", {{36,43}}, 1, {{36,8}}, 1},
	[40109] = {15, 0, 30, 40109, 1, 1, 1, 999, "神秘铃铛", {{36,73}}, 1, {{36,14}}, 1},
	[40110] = {15, 0, 30, 40110, 1, 1, 0, 999, "古代铃铛", {{36,125}}, 1, {}, 1},
	[40205] = {15, 0, 30, 40205, 1, 1, 1, 999, "幸运领巾", {{36,9}}, 1, {{36,1}}, 1},
	[40206] = {15, 0, 30, 40206, 1, 1, 1, 999, "心灵领巾", {{36,15}}, 1, {{36,3}}, 1},
	[40207] = {15, 0, 30, 40207, 1, 1, 1, 999, "勇气领巾", {{36,25}}, 1, {{36,5}}, 1},
	[40208] = {15, 0, 30, 40208, 1, 1, 1, 999, "突击领巾", {{36,43}}, 1, {{36,8}}, 1},
	[40209] = {15, 0, 30, 40209, 1, 1, 1, 999, "神秘领巾", {{36,73}}, 1, {{36,14}}, 1},
	[40210] = {15, 0, 30, 40210, 1, 1, 0, 999, "古代领巾", {{36,125}}, 1, {}, 1},
	[40305] = {15, 0, 30, 40305, 1, 1, 1, 999, "幸运胸针", {{36,9}}, 1, {{36,1}}, 1},
	[40306] = {15, 0, 30, 40306, 1, 1, 1, 999, "心灵胸针", {{36,15}}, 1, {{36,3}}, 1},
	[40307] = {15, 0, 30, 40307, 1, 1, 1, 999, "勇气胸针", {{36,25}}, 1, {{36,5}}, 1},
	[40308] = {15, 0, 30, 40308, 1, 1, 1, 999, "突击胸针", {{36,43}}, 1, {{36,8}}, 1},
	[40309] = {15, 0, 30, 40309, 1, 1, 1, 999, "神秘胸针", {{36,73}}, 1, {{36,14}}, 1},
	[40310] = {15, 0, 30, 40310, 1, 1, 0, 999, "古代胸针", {{36,125}}, 1, {}, 1},
	[40405] = {15, 0, 30, 40405, 1, 1, 1, 999, "幸运手绳", {{36,9}}, 1, {{36,1}}, 1},
	[40406] = {15, 0, 30, 40406, 1, 1, 1, 999, "心灵手绳", {{36,15}}, 1, {{36,3}}, 1},
	[40407] = {15, 0, 30, 40407, 1, 1, 1, 999, "勇气手绳", {{36,25}}, 1, {{36,5}}, 1},
	[40408] = {15, 0, 30, 40408, 1, 1, 1, 999, "突击手绳", {{36,43}}, 1, {{36,8}}, 1},
	[40409] = {15, 0, 30, 40409, 1, 1, 1, 999, "神秘手绳", {{36,73}}, 1, {{36,14}}, 1},
	[40410] = {15, 0, 30, 40410, 1, 1, 0, 999, "古代手绳", {{36,125}}, 1, {}, 1},
}
