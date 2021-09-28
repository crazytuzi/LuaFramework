----------------- auto generate db file ------------------------
i3k_db_spawn_area = 
{
	___loadedKeys = {},

};
local spawn_area_mt = { __index  = function(table, key)
	if key <= 0 then
		return nil;
	end

	local fileKey = math.floor(key / 100);
	if table.___loadedKeys[fileKey] ~= nil then
		return nil;
	end
	table.___loadedKeys[fileKey] = true;

	local filename = 'script/gamedb/dungeon/spawn_area_' .. fileKey;
	local _call = function()
		return require(filename).get_db_table();
	end

	local _err = function()
		i3k_warn('unable load db file[' .. filename .. ']');
		--i3k_warn(debug.traceback());
	end

	local ret, _db = xpcall(_call, _err);
	if not ret then
		return nil;
	end
	for k, v in pairs(_db) do
		table[k] = v;
	end
	i3k_game_unload_script(filename);
	return table[key]
end };
setmetatable(i3k_db_spawn_area, spawn_area_mt);


----------------- auto generate db file ------------------------
i3k_db_spawn_point = 
{
	___loadedKeys = {},

};
local spawn_point_mt = { __index  = function(table, key)
	if key <= 0 then
		return nil;
	end

	local fileKey = math.floor(key / 200);
	if table.___loadedKeys[fileKey] ~= nil then
		return nil;
	end
	table.___loadedKeys[fileKey] = true;

	local filename = 'script/gamedb/dungeon/spawn_point_' .. fileKey;
	local _call = function()
		return require(filename).get_db_table();
	end

	local _err = function()
		i3k_warn('unable load db file[' .. filename .. ']');
		--i3k_warn(debug.traceback());
	end

	local ret, _db = xpcall(_call, _err);
	if not ret then
		return nil;
	end
	for k, v in pairs(_db) do
		table[k] = v;
	end
	i3k_game_unload_script(filename);
	return table[key]
end };
setmetatable(i3k_db_spawn_point, spawn_point_mt);


----------------- auto generate db file ------------------------
i3k_db_npc_area = 
{
	___loadedKeys = {},

};
local npc_area_mt = { __index  = function(table, key)
	if key <= 0 then
		return nil;
	end

	local fileKey = math.floor(key / 500);
	if table.___loadedKeys[fileKey] ~= nil then
		return nil;
	end
	table.___loadedKeys[fileKey] = true;

	local filename = 'script/gamedb/dungeon/npc_area_' .. fileKey;
	local _call = function()
		return require(filename).get_db_table();
	end

	local _err = function()
		i3k_warn('unable load db file[' .. filename .. ']');
		--i3k_warn(debug.traceback());
	end

	local ret, _db = xpcall(_call, _err);
	if not ret then
		return nil;
	end
	for k, v in pairs(_db) do
		table[k] = v;
	end
	i3k_game_unload_script(filename);
	return table[key]
end };
setmetatable(i3k_db_npc_area, npc_area_mt);


----------------- auto generate db file ------------------------
i3k_db_resourcepoint_area = 
{
	___loadedKeys = {},

};
local resourcepoint_area_mt = { __index  = function(table, key)
	if key <= 0 then
		return nil;
	end

	local fileKey = math.floor(key / 1000);
	if table.___loadedKeys[fileKey] ~= nil then
		return nil;
	end
	table.___loadedKeys[fileKey] = true;

	local filename = 'script/gamedb/dungeon/res_area_' .. fileKey;
	local _call = function()
		return require(filename).get_db_table();
	end

	local _err = function()
		i3k_warn('unable load db file[' .. filename .. ']');
		--i3k_warn(debug.traceback());
	end

	local ret, _db = xpcall(_call, _err);
	if not ret then
		return nil;
	end
	for k, v in pairs(_db) do
		table[k] = v;
	end
	i3k_game_unload_script(filename);
	return table[key]
end };
setmetatable(i3k_db_resourcepoint_area, resourcepoint_area_mt);


i3k_db_transfer_point =
{
	[102] = { id = 102, pos = { x = 8.27235, y = 2.795168, z = -92.34575 }, transmapID = 2, transpos = { x = -64.94, y = 0.0, z = -125.69 }, modelID = 82, Radius = 500, Tips = '前往 红螺平原', functionType = 0, startMap = 1 },
	[201] = { id = 201, pos = { x = -63.70263, y = 0.1031103, z = -138.783 }, transmapID = 1, transpos = { x = 2.56, y = 3.11, z = -80.46 }, modelID = 82, Radius = 500, Tips = '前往 泫勃派', functionType = 0, startMap = 2 },
	[203] = { id = 203, pos = { x = 84.93774, y = 13.06564, z = -34.67548 }, transmapID = 3, transpos = { x = 26.54, y = 3.12, z = -105.14 }, modelID = 82, Radius = 500, Tips = '前往 三邪圣地', functionType = 0, startMap = 2 },
	[302] = { id = 302, pos = { x = 26.89008, y = 3.018252, z = -110.5365 }, transmapID = 2, transpos = { x = 78.04, y = 12.99, z = -27.0 }, modelID = 82, Radius = 500, Tips = '前往 红螺平原', functionType = 0, startMap = 3 },
	[305] = { id = 305, pos = { x = 46.34126, y = 9.320881, z = 92.24926 }, transmapID = 5, transpos = { x = 12.8, y = 8.37, z = -86.45 }, modelID = 82, Radius = 500, Tips = '前往 神武门', functionType = 0, startMap = 3 },
	[3019] = { id = 3019, pos = { x = -98.33566, y = 15.4682, z = 13.768 }, transmapID = 19, transpos = { x = 12.58, y = 0.99, z = -89.81 }, modelID = 82, Radius = 500, Tips = '前往 三邪关', functionType = 0, startMap = 3 },
	[406] = { id = 406, pos = { x = 95.6075, y = 6.174693, z = -87.45129 }, transmapID = 6, transpos = { x = -96.98, y = 16.95, z = 103.66 }, modelID = 82, Radius = 500, Tips = '前往 南林湖', functionType = 0, startMap = 4 },
	[503] = { id = 503, pos = { x = 30.43689, y = 6.843246, z = -90.06454 }, transmapID = 3, transpos = { x = 42.84, y = 9.32, z = 82.88 }, modelID = 82, Radius = 500, Tips = '前往 三邪圣地', functionType = 0, startMap = 5 },
	[506] = { id = 506, pos = { x = -143.9645, y = 3.117821, z = -2.554033 }, transmapID = 6, transpos = { x = 144.01, y = 0.18, z = -132.07 }, modelID = 82, Radius = 500, Tips = '前往 南林湖', functionType = 0, startMap = 5 },
	[605] = { id = 605, pos = { x = 148.4716, y = 0.1638422, z = -136.3901 }, transmapID = 5, transpos = { x = -137.1, y = 3.11, z = 0.2 }, modelID = 82, Radius = 500, Tips = '前往 神武门', functionType = 0, startMap = 6 },
	[607] = { id = 607, pos = { x = -35.65184, y = 17.2787, z = 147.7598 }, transmapID = 7, transpos = { x = -0.98, y = 11.52, z = -98.2 }, modelID = 82, Radius = 500, Tips = '前往 北海冻原', functionType = 0, startMap = 6 },
	[604] = { id = 604, pos = { x = -113.6091, y = 17.26384, z = 92.70367 }, transmapID = 4, transpos = { x = 94.81, y = 6.06, z = -95.38 }, modelID = 82, Radius = 500, Tips = '前往 柳正关', functionType = 0, startMap = 6 },
	[706] = { id = 706, pos = { x = -2.145778, y = 11.85855, z = -105.5237 }, transmapID = 6, transpos = { x = -35.9, y = 17.21, z = 141.36 }, modelID = 82, Radius = 500, Tips = '前往 南林湖', functionType = 0, startMap = 7 },
	[708] = { id = 708, pos = { x = -75.17605, y = 7.76839, z = 18.65335 }, transmapID = 8, transpos = { x = 172.49, y = 7.48, z = 27.31 }, modelID = 82, Radius = 500, Tips = '前往 西邪焦土', functionType = 0, startMap = 7 },
	[807] = { id = 807, pos = { x = 184.9552, y = 7.436337, z = 11.43887 }, transmapID = 7, transpos = { x = -74.06, y = 8.87, z = 10.39 }, modelID = 82, Radius = 500, Tips = '前往 北海冻原', functionType = 0, startMap = 8 },
	[809] = { id = 809, pos = { x = -78.2297, y = 25.72619, z = -30.30231 }, transmapID = 9, transpos = { x = 50.26, y = 10.69, z = -17.04 }, modelID = 82, Radius = 500, Tips = '前往 百道峡岭', functionType = 0, startMap = 8 },
	[908] = { id = 908, pos = { x = 59.77057, y = 10.8025, z = -28.29927 }, transmapID = 8, transpos = { x = -60.08, y = 24.43, z = -23.77 }, modelID = 82, Radius = 500, Tips = '前往 西邪焦土', functionType = 0, startMap = 9 },
	[910] = { id = 910, pos = { x = -104.7023, y = 7.89169, z = -129.9722 }, transmapID = 10, transpos = { x = -3.56, y = -1.38, z = -188.34 }, modelID = 82, Radius = 500, Tips = '前往 花亭平原', functionType = 0, startMap = 9 },
	[911] = { id = 911, pos = { x = -116.1631, y = 7.52653, z = -132.234 }, transmapID = 11, transpos = { x = 155.46, y = -0.38, z = -94.04 }, modelID = 82, Radius = 500, Tips = '前往 虎峡谷', functionType = 0, startMap = 9 },
	[1009] = { id = 1009, pos = { x = -13.31138, y = -1.505865, z = -189.8493 }, transmapID = 9, transpos = { x = -105.2, y = 7.5, z = -107.4 }, modelID = 82, Radius = 500, Tips = '前往 百道峡岭', functionType = 0, startMap = 10 },
	[1011] = { id = 1011, pos = { x = -9.707241, y = -1.47343, z = -195.3894 }, transmapID = 11, transpos = { x = 155.46, y = -0.38, z = -94.04 }, modelID = 82, Radius = 500, Tips = '前往 虎峡谷', functionType = 0, startMap = 10 },
	[1013] = { id = 1013, pos = { x = 139.1843, y = 20.08202, z = 17.02981 }, transmapID = 13, transpos = { x = 8.66, y = 5.31, z = -136.1 }, modelID = 82, Radius = 500, Tips = '前往 松月关', functionType = 0, startMap = 10 },
	[1110] = { id = 1110, pos = { x = 144.3671, y = -6.354523, z = -120.0017 }, transmapID = 10, transpos = { x = -3.56, y = -1.38, z = -188.34 }, modelID = 82, Radius = 500, Tips = '前往 花亭平原', functionType = 0, startMap = 8 },
	[1109] = { id = 1109, pos = { x = 172.6208, y = -6.339142, z = -88.6016 }, transmapID = 9, transpos = { x = -105.2, y = 7.5, z = -107.4 }, modelID = 82, Radius = 500, Tips = '前往 百道峡岭', functionType = 0, startMap = 8 },
	[1310] = { id = 1310, pos = { x = 12.54686, y = 5.319472, z = -142.4573 }, transmapID = 10, transpos = { x = 137.47, y = 20.08, z = 25.41 }, modelID = 82, Radius = 500, Tips = '前往 花亭平原', functionType = 0, startMap = 13 },
	[1903] = { id = 1903, pos = { x = 0.0091322, y = 1.728603, z = -100.7308 }, transmapID = 3, transpos = { x = -85.1, y = 15.42, z = 21.99 }, modelID = 82, Radius = 500, Tips = '前往 三邪圣地', functionType = 0, startMap = 19 },
	[108888] = { id = 108888, pos = { x = -36.7274, y = 1.749787, z = -133.4383 }, transmapID = 8888, transpos = { x = -122.522339, y = 5.325612, z = -102.238914 }, modelID = 82, Radius = 500, Tips = '前往 花月境', functionType = 0, startMap = 1 },
	[118888] = { id = 118888, pos = { x = -130.7011, y = 5.287651, z = -102.6005 }, transmapID = 1, transpos = { x = -51.22, y = 1.52, z = -127.37 }, modelID = 82, Radius = 500, Tips = '前往 泫勃派', functionType = 0, startMap = 8888 },
	[108889] = { id = 108889, pos = { x = 28.9519, y = 3.357313, z = -39.10938 }, transmapID = 8889, transpos = { x = 28.85023, y = 16.43134, z = -181.3631 }, modelID = 82, Radius = 500, Tips = '前往 荣耀殿堂', functionType = 0, startMap = 1 },
	[118889] = { id = 118889, pos = { x = 29.0959, y = 16.43134, z = -190.8553 }, transmapID = 1, transpos = { x = 18.87, y = 3.3, z = -17.95 }, modelID = 82, Radius = 500, Tips = '前往 泫勃派', functionType = 0, startMap = 8889 },
	[2005001] = { id = 2005001, pos = { x = 4.113144, y = 10.218605, z = -11.1117439 }, transmapID = 1, transpos = { x = 19.001, y = 3.5, z = -39.18 }, modelID = 82, Radius = 500, Tips = '前往 泫勃派', functionType = 0, startMap = 20050 },
	[11] = { id = 11, pos = { x = 65.66765, y = 3.32215, z = 96.56541 }, transmapID = 2001, transpos = { x = -0.0052461, y = 5.97117, z = -39.16273 }, modelID = 296, Radius = 500, Tips = '前往 虎穴地宫', functionType = 0, startMap = 6 },
	[12] = { id = 12, pos = { x = 99.22264, y = 2.858551, z = -32.16505 }, transmapID = 2002, transpos = { x = -27.11367, y = 6.340994, z = -99.01826 }, modelID = 296, Radius = 500, Tips = '前往 长白地宫', functionType = 0, startMap = 7 },
	[13] = { id = 13, pos = { x = -87.92718, y = 24.89176, z = 63.43529 }, transmapID = 2003, transpos = { x = 1.606956, y = 8.699302, z = 1.194997 }, modelID = 296, Radius = 500, Tips = '前往 圣殿地宫', functionType = 0, startMap = 8 },
	[14] = { id = 14, pos = { x = -92.69994, y = 10.3226, z = -14.26134 }, transmapID = 2004, transpos = { x = 9.93322, y = 4.895325, z = -66.52784 }, modelID = 296, Radius = 500, Tips = '前往 神宫地宫', functionType = 0, startMap = 9 },
	[15] = { id = 15, pos = { x = -44.40974, y = 13.16542, z = -53.00056 }, transmapID = 2005, transpos = { x = 49.87663, y = 18.9391, z = -56.61406 }, modelID = 296, Radius = 500, Tips = '前往 古寺地宫', functionType = 0, startMap = 4 },
	[16] = { id = 16, pos = { x = -42.79079, y = 0.0820236, z = -172.5686 }, transmapID = 2006, transpos = { x = 36.35, y = 6.23, z = -41.08 }, modelID = 296, Radius = 500, Tips = '前往 重楼地宫', functionType = 0, startMap = 10 },
	[17] = { id = 17, pos = { x = -159.2458, y = 18.10461, z = 138.7885 }, transmapID = 2007, transpos = { x = 13.57181, y = 25.29872, z = 19.57732 }, modelID = 296, Radius = 500, Tips = '前往 血魔地宫', functionType = 0, startMap = 13 },
	[18] = { id = 18, pos = { x = -49.43476, y = -2.678198, z = -38.21822 }, transmapID = 2008, transpos = { x = -1.16, y = 51.5, z = 63.69 }, modelID = 296, Radius = 500, Tips = '前往 毒瘴地宫', functionType = 0, startMap = 13 },
	[31] = { id = 31, pos = { x = -12.43899, y = 5.97117, z = -39.74595 }, transmapID = 6, transpos = { x = 73.08, y = 3.23, z = 92.5 }, modelID = 296, Radius = 500, Tips = '离开地宫', functionType = 0, startMap = 2001 },
	[32] = { id = 32, pos = { x = 40.648, y = 13.83538, z = -5.069254 }, transmapID = 7, transpos = { x = 99.42, y = 3.02, z = -38.6 }, modelID = 296, Radius = 500, Tips = '离开地宫', functionType = 0, startMap = 2002 },
	[33] = { id = 33, pos = { x = 39.78127, y = 2.580618, z = -9.463617 }, transmapID = 8, transpos = { x = -81.32, y = 25.01, z = 62.9 }, modelID = 296, Radius = 500, Tips = '离开地宫', functionType = 0, startMap = 2003 },
	[34] = { id = 34, pos = { x = 44.49413, y = 6.965301, z = -12.66597 }, transmapID = 9, transpos = { x = -91.87, y = 8.43, z = -20.61 }, modelID = 296, Radius = 500, Tips = '离开地宫', functionType = 0, startMap = 2004 },
	[35] = { id = 35, pos = { x = 60.46856, y = 18.99218, z = 70.82204 }, transmapID = 4, transpos = { x = -44.78278, y = 13.16542, z = -57.00114 }, modelID = 296, Radius = 500, Tips = '离开地宫', functionType = 0, startMap = 2005 },
	[36] = { id = 36, pos = { x = -40.16424, y = 0.4378013, z = 6.82655 }, transmapID = 10, transpos = { x = -29.95, y = 0.0, z = -170.8 }, modelID = 296, Radius = 500, Tips = '离开地宫', functionType = 0, startMap = 2006 },
	[37] = { id = 37, pos = { x = -44.55796, y = 28.0, z = 24.57491 }, transmapID = 13, transpos = { x = -162.582016, y = 18.1046066, z = 127.798454 }, modelID = 296, Radius = 500, Tips = '离开地宫', functionType = 0, startMap = 2007 },
	[38] = { id = 38, pos = { x = 7.224991, y = 27.90901, z = -121.1358 }, transmapID = 11, transpos = { x = -29.07, y = -2.86, z = -33.42 }, modelID = 296, Radius = 500, Tips = '离开地宫', functionType = 0, startMap = 2007 },
	[81] = { id = 81, pos = { x = 60.88396, y = 1.474938, z = -30.21956 }, transmapID = 1, transpos = { x = -92.42, y = 3.98, z = 93.48 }, modelID = 296, Radius = 500, Tips = '离开秘境', functionType = 0, startMap = 3001 },
	[82] = { id = 82, pos = { x = 88.72956, y = 7.394502, z = -66.12994 }, transmapID = 1, transpos = { x = -92.42, y = 3.98, z = 93.48 }, modelID = 296, Radius = 500, Tips = '离开秘境', functionType = 0, startMap = 3002 },
	[83] = { id = 83, pos = { x = 32.0, y = 0.2, z = -106.882843 }, transmapID = 0, transpos = { x = 0.0, y = 0.0, z = 0.0 }, modelID = 296, Radius = 500, Tips = '江湖告急', functionType = 1, startMap = 0 },
	[84] = { id = 84, pos = { x = 82.4269, y = 3.03619385, z = -87.45705 }, transmapID = 0, transpos = { x = 0.0, y = 0.0, z = 0.0 }, modelID = 296, Radius = 500, Tips = '江湖告急', functionType = 1, startMap = 0 },
	[85] = { id = 85, pos = { x = 75.6288452, y = 9.236191, z = 43.57357 }, transmapID = 0, transpos = { x = 0.0, y = 0.0, z = 0.0 }, modelID = 296, Radius = 500, Tips = '江湖告急', functionType = 1, startMap = 0 },
	[86] = { id = 86, pos = { x = -81.97374, y = 8.172829, z = 125.461731 }, transmapID = 0, transpos = { x = 0.0, y = 0.0, z = 0.0 }, modelID = 296, Radius = 500, Tips = '江湖告急', functionType = 1, startMap = 0 },
	[87] = { id = 87, pos = { x = 83.96181, y = 8.022817, z = 7.031288 }, transmapID = 0, transpos = { x = 0.0, y = 0.0, z = 0.0 }, modelID = 296, Radius = 500, Tips = '江湖告急', functionType = 1, startMap = 0 },
	[88] = { id = 88, pos = { x = 104.240456, y = 2.97079086, z = 7.267224 }, transmapID = 0, transpos = { x = 0.0, y = 0.0, z = 0.0 }, modelID = 296, Radius = 500, Tips = '江湖告急', functionType = 1, startMap = 0 },
	[89] = { id = 89, pos = { x = 50.3846, y = 18.99218, z = -62.10744 }, transmapID = 1, transpos = { x = -92.42, y = 3.98, z = 93.48 }, modelID = 296, Radius = 500, Tips = '离开秘境', functionType = 0, startMap = 3003 },
	[90] = { id = 90, pos = { x = -34.98086, y = 28.0, z = 34.22437 }, transmapID = 1, transpos = { x = -92.42, y = 3.98, z = 93.48 }, modelID = 296, Radius = 500, Tips = '离开秘境', functionType = 0, startMap = 3004 },
	[91] = { id = 91, pos = { x = 6.370031, y = 27.90901, z = -120.9916 }, transmapID = 1, transpos = { x = -92.42, y = 3.98, z = 93.48 }, modelID = 296, Radius = 500, Tips = '离开秘境', functionType = 0, startMap = 3004 },
	[75000] = { id = 75000, pos = { x = -129.086, y = 15.10461, z = -153.1372 }, transmapID = 75001, transpos = { x = -70.64997, y = -0.278688, z = -118.551208 }, modelID = 296, Radius = 500, Tips = '进入龙穴', functionType = 0, startMap = 3004 },
	[75001] = { id = 75001, pos = { x = -88.0419846, y = -0.1622314, z = -137.937958 }, transmapID = 75008, transpos = { x = -70.64997, y = -0.278688, z = -118.551208 }, modelID = 296, Radius = 500, Tips = '进入龙穴深渊', functionType = 0, startMap = 3004 },
	[75008] = { id = 75008, pos = { x = -88.0419846, y = -0.1622314, z = -137.937958 }, transmapID = 75001, transpos = { x = -70.64997, y = -0.278688, z = -118.551208 }, modelID = 296, Radius = 500, Tips = '离开龙穴深渊', functionType = 0, startMap = 3004 },
	[1090] = { id = 1090, pos = { x = 41.32706, y = 0.127993, z = -174.0997 }, transmapID = 90, transpos = { x = -0.5531769, y = 3.2995, z = -98.45422 }, modelID = 82, Radius = 500, Tips = '前往 风雷岛', functionType = 0, startMap = 10 },
	[9010] = { id = 9010, pos = { x = 9.044926, y = 3.591104, z = -105.3782 }, transmapID = 10, transpos = { x = 36.0625, y = 0.0589485, z = -170.8504 }, modelID = 82, Radius = 500, Tips = '前往 花亭平原', functionType = 0, startMap = 90 },
	[1012] = { id = 1012, pos = { x = -4.815403, y = -1.454596, z = -195.6127 }, transmapID = 12, transpos = { x = -102.3091, y = -2.390975, z = -117.3097 }, modelID = 82, Radius = 500, Tips = '前往 百武关', functionType = 0, startMap = 10 },
	[1210] = { id = 1210, pos = { x = -105.5897, y = -2.237063, z = -127.2063 }, transmapID = 10, transpos = { x = 4.212605, y = -1.317976, z = -182.9618 }, modelID = 82, Radius = 500, Tips = '前往 花亭平原', functionType = 0, startMap = 12 },
};

i3k_db_mapbuff =
{
	[4] = { id = 4, pos = { x = 72.55, y = 2.95, z = 7.46 }, mapBuffID = 4};
	[5] = { id = 5, pos = { x = 70.3, y = 3.33, z = 55.27 }, mapBuffID = 5};
	[8] = { id = 8, pos = { x = -16.43, y = 4.5, z = 4.95 }, mapBuffID = 8};
	[9] = { id = 9, pos = { x = -54.81, y = 4.5, z = 17.5 }, mapBuffID = 9};
	[10] = { id = 10, pos = { x = -16.23, y = 1.0, z = 46.26 }, mapBuffID = 10};
	[11] = { id = 11, pos = { x = 31.64, y = 1.5, z = 63.37 }, mapBuffID = 11};
	[13] = { id = 13, pos = { x = -2.727106, y = 21.55037, z = 6.241072 }, mapBuffID = 23};
	[14] = { id = 14, pos = { x = -3.744964, y = 21.55037, z = -9.23744 }, mapBuffID = 47};
	[15] = { id = 15, pos = { x = -22.12696, y = 0.8400139, z = -5.821621 }, mapBuffID = 48};
	[16] = { id = 16, pos = { x = -22.38756, y = 0.8337874, z = 25.84431 }, mapBuffID = 48};
	[17] = { id = 17, pos = { x = 21.70765, y = 1.296722, z = 26.39342 }, mapBuffID = 48};
	[18] = { id = 18, pos = { x = 21.18777, y = 1.321195, z = -5.437376 }, mapBuffID = 48};
	[19] = { id = 19, pos = { x = 11.94447, y = 1.212327, z = 9.048424 }, mapBuffID = 48};
	[20] = { id = 20, pos = { x = -11.40238, y = 0.9578354, z = 9.088259 }, mapBuffID = 48};
	[21] = { id = 21, pos = { x = -36.79955, y = 0.8213196, z = 22.60258 }, mapBuffID = 48};
	[22] = { id = 22, pos = { x = -37.46329, y = 0.8213196, z = -2.600375 }, mapBuffID = 48};
	[23] = { id = 23, pos = { x = 39.17238, y = 0.8213196, z = 22.35339 }, mapBuffID = 48};
	[24] = { id = 24, pos = { x = 39.15397, y = 0.8213196, z = -5.417538 }, mapBuffID = 48};
	[25] = { id = 25, pos = { x = -22.12696, y = 0.8400139, z = -5.821621 }, mapBuffID = 48};
	[26] = { id = 26, pos = { x = -22.38756, y = 0.8337874, z = 25.84431 }, mapBuffID = 48};
	[27] = { id = 27, pos = { x = 21.70765, y = 1.296722, z = 26.39342 }, mapBuffID = 48};
	[28] = { id = 28, pos = { x = 21.18777, y = 1.321195, z = -5.437376 }, mapBuffID = 48};
	[29] = { id = 29, pos = { x = 11.94447, y = 1.212327, z = 9.048424 }, mapBuffID = 48};
	[30] = { id = 30, pos = { x = -11.40238, y = 0.9578354, z = 9.088259 }, mapBuffID = 48};
	[31] = { id = 31, pos = { x = -36.79955, y = 0.8213196, z = 22.60258 }, mapBuffID = 48};
	[32] = { id = 32, pos = { x = -37.46329, y = 0.8213196, z = -2.600375 }, mapBuffID = 48};
	[33] = { id = 33, pos = { x = 39.17238, y = 0.8213196, z = 22.35339 }, mapBuffID = 48};
	[34] = { id = 34, pos = { x = 39.15397, y = 0.8213196, z = -5.417538 }, mapBuffID = 48};
	[35] = { id = 35, pos = { x = -22.12696, y = 0.8400139, z = -5.821621 }, mapBuffID = 48};
	[36] = { id = 36, pos = { x = -22.38756, y = 0.8337874, z = 25.84431 }, mapBuffID = 48};
	[37] = { id = 37, pos = { x = 21.70765, y = 1.296722, z = 26.39342 }, mapBuffID = 48};
	[38] = { id = 38, pos = { x = 21.18777, y = 1.321195, z = -5.437376 }, mapBuffID = 48};
	[39] = { id = 39, pos = { x = 11.94447, y = 1.212327, z = 9.048424 }, mapBuffID = 48};
	[40] = { id = 40, pos = { x = -11.40238, y = 0.9578354, z = 9.088259 }, mapBuffID = 48};
	[41] = { id = 41, pos = { x = -36.79955, y = 0.8213196, z = 22.60258 }, mapBuffID = 48};
	[42] = { id = 42, pos = { x = -37.46329, y = 0.8213196, z = -2.600375 }, mapBuffID = 48};
	[43] = { id = 43, pos = { x = 39.17238, y = 0.8213196, z = 22.35339 }, mapBuffID = 48};
	[44] = { id = 44, pos = { x = 39.15397, y = 0.8213196, z = -5.417538 }, mapBuffID = 48};
	[45] = { id = 45, pos = { x = -22.12696, y = 0.8400139, z = -5.821621 }, mapBuffID = 48};
	[46] = { id = 46, pos = { x = -22.38756, y = 0.8337874, z = 25.84431 }, mapBuffID = 48};
	[47] = { id = 47, pos = { x = 21.70765, y = 1.296722, z = 26.39342 }, mapBuffID = 48};
	[48] = { id = 48, pos = { x = 21.18777, y = 1.321195, z = -5.437376 }, mapBuffID = 48};
	[49] = { id = 49, pos = { x = 11.94447, y = 1.212327, z = 9.048424 }, mapBuffID = 48};
	[50] = { id = 50, pos = { x = -11.40238, y = 0.9578354, z = 9.088259 }, mapBuffID = 48};
	[51] = { id = 51, pos = { x = -36.79955, y = 0.8213196, z = 22.60258 }, mapBuffID = 48};
	[52] = { id = 52, pos = { x = -37.46329, y = 0.8213196, z = -2.600375 }, mapBuffID = 48};
	[53] = { id = 53, pos = { x = 39.17238, y = 0.8213196, z = 22.35339 }, mapBuffID = 48};
	[54] = { id = 54, pos = { x = 39.15397, y = 0.8213196, z = -5.417538 }, mapBuffID = 48};
	[55] = { id = 55, pos = { x = -22.12696, y = 0.8400139, z = -5.821621 }, mapBuffID = 48};
	[56] = { id = 56, pos = { x = -22.38756, y = 0.8337874, z = 25.84431 }, mapBuffID = 48};
	[57] = { id = 57, pos = { x = 21.70765, y = 1.296722, z = 26.39342 }, mapBuffID = 48};
	[58] = { id = 58, pos = { x = 21.18777, y = 1.321195, z = -5.437376 }, mapBuffID = 48};
	[59] = { id = 59, pos = { x = 11.94447, y = 1.212327, z = 9.048424 }, mapBuffID = 48};
	[60] = { id = 60, pos = { x = -11.40238, y = 0.9578354, z = 9.088259 }, mapBuffID = 48};
	[61] = { id = 61, pos = { x = -36.79955, y = 0.8213196, z = 22.60258 }, mapBuffID = 48};
	[62] = { id = 62, pos = { x = -37.46329, y = 0.8213196, z = -2.600375 }, mapBuffID = 48};
	[63] = { id = 63, pos = { x = 39.17238, y = 0.8213196, z = 22.35339 }, mapBuffID = 48};
	[64] = { id = 64, pos = { x = 39.15397, y = 0.8213196, z = -5.417538 }, mapBuffID = 48};
	[65] = { id = 65, pos = { x = -22.12696, y = 0.8400139, z = -5.821621 }, mapBuffID = 48};
	[66] = { id = 66, pos = { x = -22.38756, y = 0.8337874, z = 25.84431 }, mapBuffID = 48};
	[67] = { id = 67, pos = { x = 21.70765, y = 1.296722, z = 26.39342 }, mapBuffID = 48};
	[68] = { id = 68, pos = { x = 21.18777, y = 1.321195, z = -5.437376 }, mapBuffID = 48};
	[69] = { id = 69, pos = { x = 11.94447, y = 1.212327, z = 9.048424 }, mapBuffID = 48};
	[70] = { id = 70, pos = { x = -11.40238, y = 0.9578354, z = 9.088259 }, mapBuffID = 48};
	[71] = { id = 71, pos = { x = -36.79955, y = 0.8213196, z = 22.60258 }, mapBuffID = 48};
	[72] = { id = 72, pos = { x = -37.46329, y = 0.8213196, z = -2.600375 }, mapBuffID = 48};
	[73] = { id = 73, pos = { x = 39.17238, y = 0.8213196, z = 22.35339 }, mapBuffID = 48};
	[74] = { id = 74, pos = { x = 39.15397, y = 0.8213196, z = -5.417538 }, mapBuffID = 48};
	[115] = { id = 115, pos = { x = -22.12696, y = 0.8400139, z = -5.821621 }, mapBuffID = 48};
	[116] = { id = 116, pos = { x = -22.38756, y = 0.8337874, z = 25.84431 }, mapBuffID = 48};
	[117] = { id = 117, pos = { x = 21.70765, y = 1.296722, z = 26.39342 }, mapBuffID = 48};
	[118] = { id = 118, pos = { x = 21.18777, y = 1.321195, z = -5.437376 }, mapBuffID = 48};
	[119] = { id = 119, pos = { x = 11.94447, y = 1.212327, z = 9.048424 }, mapBuffID = 48};
	[120] = { id = 120, pos = { x = -11.40238, y = 0.9578354, z = 9.088259 }, mapBuffID = 48};
	[121] = { id = 121, pos = { x = -36.79955, y = 0.8213196, z = 22.60258 }, mapBuffID = 48};
	[122] = { id = 122, pos = { x = -37.46329, y = 0.8213196, z = -2.600375 }, mapBuffID = 48};
	[123] = { id = 123, pos = { x = 39.17238, y = 0.8213196, z = 22.35339 }, mapBuffID = 48};
	[124] = { id = 124, pos = { x = 39.15397, y = 0.8213196, z = -5.417538 }, mapBuffID = 48};
	[125] = { id = 125, pos = { x = -22.12696, y = 0.8400139, z = -5.821621 }, mapBuffID = 48};
	[126] = { id = 126, pos = { x = -22.38756, y = 0.8337874, z = 25.84431 }, mapBuffID = 48};
	[127] = { id = 127, pos = { x = 21.70765, y = 1.296722, z = 26.39342 }, mapBuffID = 48};
	[128] = { id = 128, pos = { x = 21.18777, y = 1.321195, z = -5.437376 }, mapBuffID = 48};
	[129] = { id = 129, pos = { x = 11.94447, y = 1.212327, z = 9.048424 }, mapBuffID = 48};
	[130] = { id = 130, pos = { x = -11.40238, y = 0.9578354, z = 9.088259 }, mapBuffID = 48};
	[131] = { id = 131, pos = { x = -36.79955, y = 0.8213196, z = 22.60258 }, mapBuffID = 48};
	[132] = { id = 132, pos = { x = -37.46329, y = 0.8213196, z = -2.600375 }, mapBuffID = 48};
	[133] = { id = 133, pos = { x = 39.17238, y = 0.8213196, z = 22.35339 }, mapBuffID = 48};
	[134] = { id = 134, pos = { x = 39.15397, y = 0.8213196, z = -5.417538 }, mapBuffID = 48};
	[135] = { id = 135, pos = { x = -22.12696, y = 0.8400139, z = -5.821621 }, mapBuffID = 48};
	[136] = { id = 136, pos = { x = -22.38756, y = 0.8337874, z = 25.84431 }, mapBuffID = 48};
	[137] = { id = 137, pos = { x = 21.70765, y = 1.296722, z = 26.39342 }, mapBuffID = 48};
	[138] = { id = 138, pos = { x = 21.18777, y = 1.321195, z = -5.437376 }, mapBuffID = 48};
	[139] = { id = 139, pos = { x = 11.94447, y = 1.212327, z = 9.048424 }, mapBuffID = 48};
	[140] = { id = 140, pos = { x = -11.40238, y = 0.9578354, z = 9.088259 }, mapBuffID = 48};
	[141] = { id = 141, pos = { x = -36.79955, y = 0.8213196, z = 22.60258 }, mapBuffID = 48};
	[142] = { id = 142, pos = { x = -37.46329, y = 0.8213196, z = -2.600375 }, mapBuffID = 48};
	[143] = { id = 143, pos = { x = 39.17238, y = 0.8213196, z = 22.35339 }, mapBuffID = 48};
	[144] = { id = 144, pos = { x = 39.15397, y = 0.8213196, z = -5.417538 }, mapBuffID = 48};
	[145] = { id = 145, pos = { x = -22.12696, y = 0.8400139, z = -5.821621 }, mapBuffID = 48};
	[146] = { id = 146, pos = { x = -22.38756, y = 0.8337874, z = 25.84431 }, mapBuffID = 48};
	[147] = { id = 147, pos = { x = 21.70765, y = 1.296722, z = 26.39342 }, mapBuffID = 48};
	[148] = { id = 148, pos = { x = 21.18777, y = 1.321195, z = -5.437376 }, mapBuffID = 48};
	[149] = { id = 149, pos = { x = 11.94447, y = 1.212327, z = 9.048424 }, mapBuffID = 48};
	[150] = { id = 150, pos = { x = -11.40238, y = 0.9578354, z = 9.088259 }, mapBuffID = 48};
	[151] = { id = 151, pos = { x = -36.79955, y = 0.8213196, z = 22.60258 }, mapBuffID = 48};
	[152] = { id = 152, pos = { x = -37.46329, y = 0.8213196, z = -2.600375 }, mapBuffID = 48};
	[153] = { id = 153, pos = { x = 39.17238, y = 0.8213196, z = 22.35339 }, mapBuffID = 48};
	[154] = { id = 154, pos = { x = 39.15397, y = 0.8213196, z = -5.417538 }, mapBuffID = 48};
	[155] = { id = 155, pos = { x = -22.12696, y = 0.8400139, z = -5.821621 }, mapBuffID = 48};
	[156] = { id = 156, pos = { x = -22.38756, y = 0.8337874, z = 25.84431 }, mapBuffID = 48};
	[157] = { id = 157, pos = { x = 21.70765, y = 1.296722, z = 26.39342 }, mapBuffID = 48};
	[158] = { id = 158, pos = { x = 21.18777, y = 1.321195, z = -5.437376 }, mapBuffID = 48};
	[159] = { id = 159, pos = { x = 11.94447, y = 1.212327, z = 9.048424 }, mapBuffID = 48};
	[160] = { id = 160, pos = { x = -11.40238, y = 0.9578354, z = 9.088259 }, mapBuffID = 48};
	[161] = { id = 161, pos = { x = -36.79955, y = 0.8213196, z = 22.60258 }, mapBuffID = 48};
	[162] = { id = 162, pos = { x = -37.46329, y = 0.8213196, z = -2.600375 }, mapBuffID = 48};
	[163] = { id = 163, pos = { x = 39.17238, y = 0.8213196, z = 22.35339 }, mapBuffID = 48};
	[164] = { id = 164, pos = { x = 39.15397, y = 0.8213196, z = -5.417538 }, mapBuffID = 48};
	[165] = { id = 165, pos = { x = -22.12696, y = 0.8400139, z = -5.821621 }, mapBuffID = 48};
	[166] = { id = 166, pos = { x = -22.38756, y = 0.8337874, z = 25.84431 }, mapBuffID = 48};
	[167] = { id = 167, pos = { x = 21.70765, y = 1.296722, z = 26.39342 }, mapBuffID = 48};
	[168] = { id = 168, pos = { x = 21.18777, y = 1.321195, z = -5.437376 }, mapBuffID = 48};
	[169] = { id = 169, pos = { x = 11.94447, y = 1.212327, z = 9.048424 }, mapBuffID = 48};
	[170] = { id = 170, pos = { x = -11.40238, y = 0.9578354, z = 9.088259 }, mapBuffID = 48};
	[171] = { id = 171, pos = { x = -36.79955, y = 0.8213196, z = 22.60258 }, mapBuffID = 48};
	[172] = { id = 172, pos = { x = -37.46329, y = 0.8213196, z = -2.600375 }, mapBuffID = 48};
	[173] = { id = 173, pos = { x = 39.17238, y = 0.8213196, z = 22.35339 }, mapBuffID = 48};
	[174] = { id = 174, pos = { x = 39.15397, y = 0.8213196, z = -5.417538 }, mapBuffID = 48};
	[175] = { id = 175, pos = { x = -66.20856, y = 13.47561, z = -63.60886 }, mapBuffID = 100};
	[176] = { id = 176, pos = { x = 115.9824, y = 13.31757, z = 65.56296 }, mapBuffID = 100};
	[177] = { id = 177, pos = { x = 143.9894, y = 14.42185, z = -144.3376 }, mapBuffID = 101};
	[178] = { id = 178, pos = { x = -32.82132, y = 21.15307, z = -13.16942 }, mapBuffID = 101};
	[179] = { id = 179, pos = { x = -66.81389, y = 13.4672, z = -106.5335 }, mapBuffID = 102};
	[180] = { id = 180, pos = { x = 75.36423, y = 19.3573, z = -76.58092 }, mapBuffID = 102};
	[181] = { id = 181, pos = { x = -121.0498, y = 19.23724, z = 108.4866 }, mapBuffID = 103};
	[182] = { id = 182, pos = { x = 22.88263, y = 13.81381, z = 1.610918 }, mapBuffID = 103};
	[183] = { id = 183, pos = { x = 160.3673, y = 26.98256, z = -77.28314 }, mapBuffID = 104};
	[184] = { id = 184, pos = { x = -186.2852, y = 14.42185, z = 147.2587 }, mapBuffID = 104};
	[185] = { id = 185, pos = { x = 22.32753, y = 13.47561, z = 76.3352 }, mapBuffID = 105};
	[186] = { id = 186, pos = { x = -22.22808, y = 13.81382, z = 44.53889 }, mapBuffID = 105};
	[187] = { id = 187, pos = { x = -150.2033, y = 13.05474, z = -68.71571 }, mapBuffID = 106};
	[188] = { id = 188, pos = { x = -110.365, y = 13.81381, z = 44.46709 }, mapBuffID = 106};
	[189] = { id = 189, pos = { x = 104.9534, y = 13.45692, z = 135.9122 }, mapBuffID = 107};
	[190] = { id = 190, pos = { x = -64.56409, y = 13.81381, z = -1.548813 }, mapBuffID = 107};
	[191] = { id = 191, pos = { x = -145.306, y = 13.45992, z = -136.8707 }, mapBuffID = 108};
	[192] = { id = 192, pos = { x = 88.40082, y = 14.52368, z = -148.0023 }, mapBuffID = 108};
	[193] = { id = 193, pos = { x = -10.56516, y = 13.47402, z = 135.122 }, mapBuffID = 109};
	[194] = { id = 194, pos = { x = -205.3257, y = 26.98256, z = 78.41124 }, mapBuffID = 109};
	[195] = { id = 195, pos = { x = -66.20856, y = 13.47561, z = -63.60886 }, mapBuffID = 110};
	[196] = { id = 196, pos = { x = 115.9824, y = 13.31757, z = 65.56296 }, mapBuffID = 110};
	[197] = { id = 197, pos = { x = 143.9894, y = 14.42185, z = -144.3376 }, mapBuffID = 111};
	[198] = { id = 198, pos = { x = -32.82132, y = 21.15307, z = -13.16942 }, mapBuffID = 111};
	[199] = { id = 199, pos = { x = -66.81389, y = 13.4672, z = -106.5335 }, mapBuffID = 112};
	[200] = { id = 200, pos = { x = 75.36423, y = 19.3573, z = -76.58092 }, mapBuffID = 112};
	[201] = { id = 201, pos = { x = -121.0498, y = 19.23724, z = 108.4866 }, mapBuffID = 113};
	[202] = { id = 202, pos = { x = 22.88263, y = 13.81381, z = 1.610918 }, mapBuffID = 113};
	[203] = { id = 203, pos = { x = 160.3673, y = 26.98256, z = -77.28314 }, mapBuffID = 114};
	[204] = { id = 204, pos = { x = -186.2852, y = 14.42185, z = 147.2587 }, mapBuffID = 114};
	[205] = { id = 205, pos = { x = 22.32753, y = 13.47561, z = 76.3352 }, mapBuffID = 115};
	[206] = { id = 206, pos = { x = -22.22808, y = 13.81382, z = 44.53889 }, mapBuffID = 115};
	[207] = { id = 207, pos = { x = -150.2033, y = 13.05474, z = -68.71571 }, mapBuffID = 116};
	[208] = { id = 208, pos = { x = -110.365, y = 13.81381, z = 44.46709 }, mapBuffID = 116};
	[209] = { id = 209, pos = { x = 104.9534, y = 13.45692, z = 135.9122 }, mapBuffID = 117};
	[210] = { id = 210, pos = { x = -64.56409, y = 13.81381, z = -1.548813 }, mapBuffID = 117};
	[211] = { id = 211, pos = { x = -145.306, y = 13.45992, z = -136.8707 }, mapBuffID = 118};
	[212] = { id = 212, pos = { x = 88.40082, y = 14.52368, z = -148.0023 }, mapBuffID = 118};
	[213] = { id = 213, pos = { x = -10.56516, y = 13.47402, z = 135.122 }, mapBuffID = 119};
	[214] = { id = 214, pos = { x = -205.3257, y = 26.98256, z = 78.41124 }, mapBuffID = 119};
	[215] = { id = 215, pos = { x = -66.20856, y = 13.47561, z = -63.60886 }, mapBuffID = 120};
	[216] = { id = 216, pos = { x = 115.9824, y = 13.31757, z = 65.56296 }, mapBuffID = 120};
	[217] = { id = 217, pos = { x = 143.9894, y = 14.42185, z = -144.3376 }, mapBuffID = 121};
	[218] = { id = 218, pos = { x = -32.82132, y = 21.15307, z = -13.16942 }, mapBuffID = 121};
	[219] = { id = 219, pos = { x = -66.81389, y = 13.4672, z = -106.5335 }, mapBuffID = 122};
	[220] = { id = 220, pos = { x = 75.36423, y = 19.3573, z = -76.58092 }, mapBuffID = 122};
	[221] = { id = 221, pos = { x = -121.0498, y = 19.23724, z = 108.4866 }, mapBuffID = 123};
	[222] = { id = 222, pos = { x = 22.88263, y = 13.81381, z = 1.610918 }, mapBuffID = 123};
	[223] = { id = 223, pos = { x = 160.3673, y = 26.98256, z = -77.28314 }, mapBuffID = 124};
	[224] = { id = 224, pos = { x = -186.2852, y = 14.42185, z = 147.2587 }, mapBuffID = 124};
	[225] = { id = 225, pos = { x = 22.32753, y = 13.47561, z = 76.3352 }, mapBuffID = 125};
	[226] = { id = 226, pos = { x = -22.22808, y = 13.81382, z = 44.53889 }, mapBuffID = 125};
	[227] = { id = 227, pos = { x = -150.2033, y = 13.05474, z = -68.71571 }, mapBuffID = 126};
	[228] = { id = 228, pos = { x = -110.365, y = 13.81381, z = 44.46709 }, mapBuffID = 126};
	[229] = { id = 229, pos = { x = 104.9534, y = 13.45692, z = 135.9122 }, mapBuffID = 127};
	[230] = { id = 230, pos = { x = -64.56409, y = 13.81381, z = -1.548813 }, mapBuffID = 127};
	[231] = { id = 231, pos = { x = -145.306, y = 13.45992, z = -136.8707 }, mapBuffID = 128};
	[232] = { id = 232, pos = { x = 88.40082, y = 14.52368, z = -148.0023 }, mapBuffID = 128};
	[233] = { id = 233, pos = { x = -10.56516, y = 13.47402, z = 135.122 }, mapBuffID = 129};
	[234] = { id = 234, pos = { x = -205.3257, y = 26.98256, z = 78.41124 }, mapBuffID = 129};
	[235] = { id = 235, pos = { x = -64.64001, y = 13.81381, z = 44.30959 }, mapBuffID = 130};
	[236] = { id = 236, pos = { x = -156.4561, y = 13.31757, z = -66.22603 }, mapBuffID = 130};
	[237] = { id = 237, pos = { x = 22.58296, y = 13.81382, z = -42.70164 }, mapBuffID = 131};
	[238] = { id = 238, pos = { x = 113.7086, y = 13.8462, z = 99.59049 }, mapBuffID = 131};
	[239] = { id = 239, pos = { x = -65.05049, y = 13.47087, z = -98.7019 }, mapBuffID = 132};
	[240] = { id = 240, pos = { x = 56.75399, y = 13.70961, z = 89.89635 }, mapBuffID = 132};
	[241] = { id = 241, pos = { x = -24.1982, y = 21.15306, z = 15.32684 }, mapBuffID = 133};
	[242] = { id = 242, pos = { x = 111.1179, y = 13.45638, z = 130.4676 }, mapBuffID = 133};
	[243] = { id = 243, pos = { x = -101.5277, y = 13.70965, z = -87.3162 }, mapBuffID = 134};
	[244] = { id = 244, pos = { x = 74.00098, y = 13.71925, z = 140.8944 }, mapBuffID = 134};
	[245] = { id = 245, pos = { x = 22.525, y = 13.81381, z = 44.48203 }, mapBuffID = 135};
	[246] = { id = 246, pos = { x = 21.81806, y = 13.47561, z = 85.68399 }, mapBuffID = 135};
	[247] = { id = 247, pos = { x = -118.7673, y = 13.35299, z = -98.92832 }, mapBuffID = 136};
	[248] = { id = 248, pos = { x = -6.373769, y = 13.47219, z = 126.2002 }, mapBuffID = 136};
	[249] = { id = 249, pos = { x = 109.5965, y = 13.31757, z = 66.70659 }, mapBuffID = 137};
	[250] = { id = 250, pos = { x = -18.7908, y = 21.15307, z = -17.86802 }, mapBuffID = 137};
	[251] = { id = 251, pos = { x = -150.0877, y = 13.63027, z = -126.9132 }, mapBuffID = 138};
	[252] = { id = 252, pos = { x = -66.08083, y = 13.81381, z = 42.65734 }, mapBuffID = 138};
	[253] = { id = 253, pos = { x = -37.09257, y = 13.47243, z = -127.1791 }, mapBuffID = 139};
	[254] = { id = 254, pos = { x = -66.45559, y = 13.47561, z = -73.98338 }, mapBuffID = 139};
	[255] = { id = 255, pos = { x = -66.208565, y = 13.475609, z = -63.608856 }, mapBuffID = 100};
	[256] = { id = 256, pos = { x = 115.982353, y = 13.31757, z = 65.562958 }, mapBuffID = 100};
	[257] = { id = 257, pos = { x = 143.98941, y = 14.421852, z = -144.337646 }, mapBuffID = 101};
	[258] = { id = 258, pos = { x = -32.82132, y = 21.153072, z = -13.169419 }, mapBuffID = 101};
	[259] = { id = 259, pos = { x = -66.813889, y = 13.467198, z = -106.533539 }, mapBuffID = 102};
	[260] = { id = 260, pos = { x = 75.364227, y = 19.357302, z = -76.580917 }, mapBuffID = 102};
	[261] = { id = 261, pos = { x = -121.049843, y = 19.237244, z = 108.486603 }, mapBuffID = 103};
	[262] = { id = 262, pos = { x = 22.882631, y = 13.813814, z = 1.610918 }, mapBuffID = 103};
	[263] = { id = 263, pos = { x = 160.367264, y = 26.982563, z = -77.283142 }, mapBuffID = 104};
	[264] = { id = 264, pos = { x = -186.285233, y = 14.421849, z = 147.258698 }, mapBuffID = 104};
	[265] = { id = 265, pos = { x = 22.327534, y = 13.475607, z = 76.335197 }, mapBuffID = 105};
	[266] = { id = 266, pos = { x = -22.228075, y = 13.813816, z = 44.538895 }, mapBuffID = 105};
	[267] = { id = 267, pos = { x = -150.203278, y = 13.054738, z = -68.715714 }, mapBuffID = 106};
	[268] = { id = 268, pos = { x = -110.364983, y = 13.813814, z = 44.467087 }, mapBuffID = 106};
	[269] = { id = 269, pos = { x = 104.953369, y = 13.456919, z = 135.912201 }, mapBuffID = 107};
	[270] = { id = 270, pos = { x = -64.564095, y = 13.813814, z = -1.548813 }, mapBuffID = 107};
	[271] = { id = 271, pos = { x = -145.306015, y = 13.459922, z = -136.870743 }, mapBuffID = 108};
	[272] = { id = 272, pos = { x = 88.400818, y = 14.52368, z = -148.002319 }, mapBuffID = 108};
	[273] = { id = 273, pos = { x = -10.565165, y = 13.474022, z = 135.122009 }, mapBuffID = 109};
	[274] = { id = 274, pos = { x = -205.325668, y = 26.982565, z = 78.41124 }, mapBuffID = 109};
	[275] = { id = 275, pos = { x = -66.208565, y = 13.475609, z = -63.608856 }, mapBuffID = 110};
	[276] = { id = 276, pos = { x = 115.982353, y = 13.31757, z = 65.562958 }, mapBuffID = 110};
	[277] = { id = 277, pos = { x = 143.98941, y = 14.421852, z = -144.337646 }, mapBuffID = 111};
	[278] = { id = 278, pos = { x = -32.82132, y = 21.153072, z = -13.169419 }, mapBuffID = 111};
	[279] = { id = 279, pos = { x = -66.813889, y = 13.467198, z = -106.533539 }, mapBuffID = 112};
	[280] = { id = 280, pos = { x = 75.364227, y = 19.357302, z = -76.580917 }, mapBuffID = 112};
	[281] = { id = 281, pos = { x = -121.049843, y = 19.237244, z = 108.486603 }, mapBuffID = 113};
	[282] = { id = 282, pos = { x = 22.882631, y = 13.813814, z = 1.610918 }, mapBuffID = 113};
	[283] = { id = 283, pos = { x = 160.367264, y = 26.982563, z = -77.283142 }, mapBuffID = 114};
	[284] = { id = 284, pos = { x = -186.285233, y = 14.421849, z = 147.258698 }, mapBuffID = 114};
	[285] = { id = 285, pos = { x = 22.327534, y = 13.475607, z = 76.335197 }, mapBuffID = 115};
	[286] = { id = 286, pos = { x = -22.228075, y = 13.813816, z = 44.538895 }, mapBuffID = 115};
	[287] = { id = 287, pos = { x = -150.203278, y = 13.054738, z = -68.715714 }, mapBuffID = 116};
	[288] = { id = 288, pos = { x = -110.364983, y = 13.813814, z = 44.467087 }, mapBuffID = 116};
	[289] = { id = 289, pos = { x = 104.953369, y = 13.456919, z = 135.912201 }, mapBuffID = 117};
	[290] = { id = 290, pos = { x = -64.564095, y = 13.813814, z = -1.548813 }, mapBuffID = 117};
	[291] = { id = 291, pos = { x = -145.306015, y = 13.459922, z = -136.870743 }, mapBuffID = 118};
	[292] = { id = 292, pos = { x = 88.400818, y = 14.52368, z = -148.002319 }, mapBuffID = 118};
	[293] = { id = 293, pos = { x = -10.565165, y = 13.474022, z = 135.122009 }, mapBuffID = 119};
	[294] = { id = 294, pos = { x = -205.325668, y = 26.982565, z = 78.41124 }, mapBuffID = 119};
	[295] = { id = 295, pos = { x = -66.208565, y = 13.475609, z = -63.608856 }, mapBuffID = 120};
	[296] = { id = 296, pos = { x = 115.982353, y = 13.31757, z = 65.562958 }, mapBuffID = 120};
	[297] = { id = 297, pos = { x = 143.98941, y = 14.421852, z = -144.337646 }, mapBuffID = 121};
	[298] = { id = 298, pos = { x = -32.82132, y = 21.153072, z = -13.169419 }, mapBuffID = 121};
	[299] = { id = 299, pos = { x = -66.813889, y = 13.467198, z = -106.533539 }, mapBuffID = 122};
	[300] = { id = 300, pos = { x = 75.364227, y = 19.357302, z = -76.580917 }, mapBuffID = 122};
	[301] = { id = 301, pos = { x = -121.049843, y = 19.237244, z = 108.486603 }, mapBuffID = 123};
	[302] = { id = 302, pos = { x = 22.882631, y = 13.813814, z = 1.610918 }, mapBuffID = 123};
	[303] = { id = 303, pos = { x = 160.367264, y = 26.982563, z = -77.283142 }, mapBuffID = 124};
	[304] = { id = 304, pos = { x = -186.285233, y = 14.421849, z = 147.258698 }, mapBuffID = 124};
	[305] = { id = 305, pos = { x = 22.327534, y = 13.475607, z = 76.335197 }, mapBuffID = 125};
	[306] = { id = 306, pos = { x = -22.228075, y = 13.813816, z = 44.538895 }, mapBuffID = 125};
	[307] = { id = 307, pos = { x = -150.203278, y = 13.054738, z = -68.715714 }, mapBuffID = 126};
	[308] = { id = 308, pos = { x = -110.364983, y = 13.813814, z = 44.467087 }, mapBuffID = 126};
	[309] = { id = 309, pos = { x = 104.953369, y = 13.456919, z = 135.912201 }, mapBuffID = 127};
	[310] = { id = 310, pos = { x = -64.564095, y = 13.813814, z = -1.548813 }, mapBuffID = 127};
	[311] = { id = 311, pos = { x = -145.306015, y = 13.459922, z = -136.870743 }, mapBuffID = 128};
	[312] = { id = 312, pos = { x = 88.400818, y = 14.52368, z = -148.002319 }, mapBuffID = 128};
	[313] = { id = 313, pos = { x = -10.565165, y = 13.474022, z = 135.122009 }, mapBuffID = 129};
	[314] = { id = 314, pos = { x = -205.325668, y = 26.982565, z = 78.41124 }, mapBuffID = 129};
	[315] = { id = 315, pos = { x = -64.640015, y = 13.813812, z = 44.309593 }, mapBuffID = 130};
	[316] = { id = 316, pos = { x = -156.4561, y = 13.31757, z = -66.226028 }, mapBuffID = 130};
	[317] = { id = 317, pos = { x = 22.582958, y = 13.813816, z = -42.701645 }, mapBuffID = 131};
	[318] = { id = 318, pos = { x = 113.708641, y = 13.846196, z = 99.590492 }, mapBuffID = 131};
	[319] = { id = 319, pos = { x = -65.050491, y = 13.470873, z = -98.701904 }, mapBuffID = 132};
	[320] = { id = 320, pos = { x = 56.75399, y = 13.709607, z = 89.896347 }, mapBuffID = 132};
	[321] = { id = 321, pos = { x = -24.1982, y = 21.153065, z = 15.326841 }, mapBuffID = 133};
	[322] = { id = 322, pos = { x = 111.117851, y = 13.456377, z = 130.467606 }, mapBuffID = 133};
	[323] = { id = 323, pos = { x = -101.527695, y = 13.709646, z = -87.3162 }, mapBuffID = 134};
	[324] = { id = 324, pos = { x = 74.000984, y = 13.719252, z = 140.894394 }, mapBuffID = 134};
	[325] = { id = 325, pos = { x = 22.525003, y = 13.813814, z = 44.482029 }, mapBuffID = 135};
	[326] = { id = 326, pos = { x = 21.818058, y = 13.475608, z = 85.68399 }, mapBuffID = 135};
	[327] = { id = 327, pos = { x = -118.767319, y = 13.352987, z = -98.928322 }, mapBuffID = 136};
	[328] = { id = 328, pos = { x = -6.373769, y = 13.472193, z = 126.200165 }, mapBuffID = 136};
	[329] = { id = 329, pos = { x = 109.596519, y = 13.317572, z = 66.706589 }, mapBuffID = 137};
	[330] = { id = 330, pos = { x = -18.790804, y = 21.153072, z = -17.868015 }, mapBuffID = 137};
	[331] = { id = 331, pos = { x = -150.087677, y = 13.630267, z = -126.91317 }, mapBuffID = 138};
	[332] = { id = 332, pos = { x = -66.080826, y = 13.813814, z = 42.657345 }, mapBuffID = 138};
	[333] = { id = 333, pos = { x = -37.092571, y = 13.472435, z = -127.179077 }, mapBuffID = 139};
	[334] = { id = 334, pos = { x = -66.455589, y = 13.475607, z = -73.983383 }, mapBuffID = 139};
	[335] = { id = 335, pos = { x = -66.208565, y = 13.475609, z = -63.608856 }, mapBuffID = 100};
	[336] = { id = 336, pos = { x = 115.982353, y = 13.31757, z = 65.562958 }, mapBuffID = 100};
	[337] = { id = 337, pos = { x = 143.98941, y = 14.421852, z = -144.337646 }, mapBuffID = 101};
	[338] = { id = 338, pos = { x = -32.82132, y = 21.153072, z = -13.169419 }, mapBuffID = 101};
	[339] = { id = 339, pos = { x = -66.813889, y = 13.467198, z = -106.533539 }, mapBuffID = 102};
	[340] = { id = 340, pos = { x = 75.364227, y = 19.357302, z = -76.580917 }, mapBuffID = 102};
	[341] = { id = 341, pos = { x = -121.049843, y = 19.237244, z = 108.486603 }, mapBuffID = 103};
	[342] = { id = 342, pos = { x = 22.882631, y = 13.813814, z = 1.610918 }, mapBuffID = 103};
	[343] = { id = 343, pos = { x = 160.367264, y = 26.982563, z = -77.283142 }, mapBuffID = 104};
	[344] = { id = 344, pos = { x = -186.285233, y = 14.421849, z = 147.258698 }, mapBuffID = 104};
	[345] = { id = 345, pos = { x = 22.327534, y = 13.475607, z = 76.335197 }, mapBuffID = 105};
	[346] = { id = 346, pos = { x = -22.228075, y = 13.813816, z = 44.538895 }, mapBuffID = 105};
	[347] = { id = 347, pos = { x = -150.203278, y = 13.054738, z = -68.715714 }, mapBuffID = 106};
	[348] = { id = 348, pos = { x = -110.364983, y = 13.813814, z = 44.467087 }, mapBuffID = 106};
	[349] = { id = 349, pos = { x = 104.953369, y = 13.456919, z = 135.912201 }, mapBuffID = 107};
	[350] = { id = 350, pos = { x = -64.564095, y = 13.813814, z = -1.548813 }, mapBuffID = 107};
	[351] = { id = 351, pos = { x = -145.306015, y = 13.459922, z = -136.870743 }, mapBuffID = 108};
	[352] = { id = 352, pos = { x = 88.400818, y = 14.52368, z = -148.002319 }, mapBuffID = 108};
	[353] = { id = 353, pos = { x = -10.565165, y = 13.474022, z = 135.122009 }, mapBuffID = 109};
	[354] = { id = 354, pos = { x = -205.325668, y = 26.982565, z = 78.41124 }, mapBuffID = 109};
	[355] = { id = 355, pos = { x = -66.208565, y = 13.475609, z = -63.608856 }, mapBuffID = 110};
	[356] = { id = 356, pos = { x = 115.982353, y = 13.31757, z = 65.562958 }, mapBuffID = 110};
	[357] = { id = 357, pos = { x = 143.98941, y = 14.421852, z = -144.337646 }, mapBuffID = 111};
	[358] = { id = 358, pos = { x = -32.82132, y = 21.153072, z = -13.169419 }, mapBuffID = 111};
	[359] = { id = 359, pos = { x = -66.813889, y = 13.467198, z = -106.533539 }, mapBuffID = 112};
	[360] = { id = 360, pos = { x = 75.364227, y = 19.357302, z = -76.580917 }, mapBuffID = 112};
	[361] = { id = 361, pos = { x = -121.049843, y = 19.237244, z = 108.486603 }, mapBuffID = 113};
	[362] = { id = 362, pos = { x = 22.882631, y = 13.813814, z = 1.610918 }, mapBuffID = 113};
	[363] = { id = 363, pos = { x = 160.367264, y = 26.982563, z = -77.283142 }, mapBuffID = 114};
	[364] = { id = 364, pos = { x = -186.285233, y = 14.421849, z = 147.258698 }, mapBuffID = 114};
	[365] = { id = 365, pos = { x = 22.327534, y = 13.475607, z = 76.335197 }, mapBuffID = 115};
	[366] = { id = 366, pos = { x = -22.228075, y = 13.813816, z = 44.538895 }, mapBuffID = 115};
	[367] = { id = 367, pos = { x = -150.203278, y = 13.054738, z = -68.715714 }, mapBuffID = 116};
	[368] = { id = 368, pos = { x = -110.364983, y = 13.813814, z = 44.467087 }, mapBuffID = 116};
	[369] = { id = 369, pos = { x = 104.953369, y = 13.456919, z = 135.912201 }, mapBuffID = 117};
	[370] = { id = 370, pos = { x = -64.564095, y = 13.813814, z = -1.548813 }, mapBuffID = 117};
	[371] = { id = 371, pos = { x = -145.306015, y = 13.459922, z = -136.870743 }, mapBuffID = 118};
	[372] = { id = 372, pos = { x = 88.400818, y = 14.52368, z = -148.002319 }, mapBuffID = 118};
	[373] = { id = 373, pos = { x = -10.565165, y = 13.474022, z = 135.122009 }, mapBuffID = 119};
	[374] = { id = 374, pos = { x = -205.325668, y = 26.982565, z = 78.41124 }, mapBuffID = 119};
	[375] = { id = 375, pos = { x = -66.208565, y = 13.475609, z = -63.608856 }, mapBuffID = 120};
	[376] = { id = 376, pos = { x = 115.982353, y = 13.31757, z = 65.562958 }, mapBuffID = 120};
	[377] = { id = 377, pos = { x = 143.98941, y = 14.421852, z = -144.337646 }, mapBuffID = 121};
	[378] = { id = 378, pos = { x = -32.82132, y = 21.153072, z = -13.169419 }, mapBuffID = 121};
	[379] = { id = 379, pos = { x = -66.813889, y = 13.467198, z = -106.533539 }, mapBuffID = 122};
	[380] = { id = 380, pos = { x = 75.364227, y = 19.357302, z = -76.580917 }, mapBuffID = 122};
	[381] = { id = 381, pos = { x = -121.049843, y = 19.237244, z = 108.486603 }, mapBuffID = 123};
	[382] = { id = 382, pos = { x = 22.882631, y = 13.813814, z = 1.610918 }, mapBuffID = 123};
	[383] = { id = 383, pos = { x = 160.367264, y = 26.982563, z = -77.283142 }, mapBuffID = 124};
	[384] = { id = 384, pos = { x = -186.285233, y = 14.421849, z = 147.258698 }, mapBuffID = 124};
	[385] = { id = 385, pos = { x = 22.327534, y = 13.475607, z = 76.335197 }, mapBuffID = 125};
	[386] = { id = 386, pos = { x = -22.228075, y = 13.813816, z = 44.538895 }, mapBuffID = 125};
	[387] = { id = 387, pos = { x = -150.203278, y = 13.054738, z = -68.715714 }, mapBuffID = 126};
	[388] = { id = 388, pos = { x = -110.364983, y = 13.813814, z = 44.467087 }, mapBuffID = 126};
	[389] = { id = 389, pos = { x = 104.953369, y = 13.456919, z = 135.912201 }, mapBuffID = 127};
	[390] = { id = 390, pos = { x = -64.564095, y = 13.813814, z = -1.548813 }, mapBuffID = 127};
	[391] = { id = 391, pos = { x = -145.306015, y = 13.459922, z = -136.870743 }, mapBuffID = 128};
	[392] = { id = 392, pos = { x = 88.400818, y = 14.52368, z = -148.002319 }, mapBuffID = 128};
	[393] = { id = 393, pos = { x = -10.565165, y = 13.474022, z = 135.122009 }, mapBuffID = 129};
	[394] = { id = 394, pos = { x = -205.325668, y = 26.982565, z = 78.41124 }, mapBuffID = 129};
	[395] = { id = 395, pos = { x = -64.640015, y = 13.813812, z = 44.309593 }, mapBuffID = 130};
	[396] = { id = 396, pos = { x = -156.4561, y = 13.31757, z = -66.226028 }, mapBuffID = 130};
	[397] = { id = 397, pos = { x = 22.582958, y = 13.813816, z = -42.701645 }, mapBuffID = 131};
	[398] = { id = 398, pos = { x = 113.708641, y = 13.846196, z = 99.590492 }, mapBuffID = 131};
	[399] = { id = 399, pos = { x = -65.050491, y = 13.470873, z = -98.701904 }, mapBuffID = 132};
	[400] = { id = 400, pos = { x = 56.75399, y = 13.709607, z = 89.896347 }, mapBuffID = 132};
	[401] = { id = 401, pos = { x = -24.1982, y = 21.153065, z = 15.326841 }, mapBuffID = 133};
	[402] = { id = 402, pos = { x = 111.117851, y = 13.456377, z = 130.467606 }, mapBuffID = 133};
	[403] = { id = 403, pos = { x = -101.527695, y = 13.709646, z = -87.3162 }, mapBuffID = 134};
	[404] = { id = 404, pos = { x = 74.000984, y = 13.719252, z = 140.894394 }, mapBuffID = 134};
	[405] = { id = 405, pos = { x = 22.525003, y = 13.813814, z = 44.482029 }, mapBuffID = 135};
	[406] = { id = 406, pos = { x = 21.818058, y = 13.475608, z = 85.68399 }, mapBuffID = 135};
	[407] = { id = 407, pos = { x = -118.767319, y = 13.352987, z = -98.928322 }, mapBuffID = 136};
	[408] = { id = 408, pos = { x = -6.373769, y = 13.472193, z = 126.200165 }, mapBuffID = 136};
	[409] = { id = 409, pos = { x = 109.596519, y = 13.317572, z = 66.706589 }, mapBuffID = 137};
	[410] = { id = 410, pos = { x = -18.790804, y = 21.153072, z = -17.868015 }, mapBuffID = 137};
	[411] = { id = 411, pos = { x = -150.087677, y = 13.630267, z = -126.91317 }, mapBuffID = 138};
	[412] = { id = 412, pos = { x = -66.080826, y = 13.813814, z = 42.657345 }, mapBuffID = 138};
	[413] = { id = 413, pos = { x = -37.092571, y = 13.472435, z = -127.179077 }, mapBuffID = 139};
	[414] = { id = 414, pos = { x = -66.455589, y = 13.475607, z = -73.983383 }, mapBuffID = 139};
	[415] = { id = 415, pos = { x = -10.0013, y = 5.107989, z = 0.004385 }, mapBuffID = 250};
	[416] = { id = 416, pos = { x = 10.0034, y = 5.049264, z = 0.0044061 }, mapBuffID = 251};
	[417] = { id = 417, pos = { x = 27.12722, y = 25.0, z = -17.29042 }, mapBuffID = 252};
	[418] = { id = 418, pos = { x = 19.72403, y = 7.64325, z = -34.31454 }, mapBuffID = 50};
	[419] = { id = 419, pos = { x = 8.649845, y = 7.496335, z = 63.36946 }, mapBuffID = 50};
	[420] = { id = 420, pos = { x = 50.41275, y = 7.64325, z = -4.472481 }, mapBuffID = 50};
	[421] = { id = 421, pos = { x = 49.40031, y = 12.64325, z = 91.13136 }, mapBuffID = 50};
	[422] = { id = 422, pos = { x = -51.23145, y = 8.462352, z = 57.59841 }, mapBuffID = 50};
	[423] = { id = 423, pos = { x = -77.02707, y = 8.043243, z = 92.59538 }, mapBuffID = 50};
	[424] = { id = 424, pos = { x = -59.78711, y = 5.538916, z = 30.80283 }, mapBuffID = 50};
	[425] = { id = 425, pos = { x = -115.6576, y = 6.64325, z = 31.94241 }, mapBuffID = 50};
	[426] = { id = 426, pos = { x = -1.24438858, y = 11.6878977, z = -76.49497 }, mapBuffID = 50};
	[427] = { id = 427, pos = { x = 15.7868366, y = 13.6891918, z = -56.66416 }, mapBuffID = 50};
	[428] = { id = 428, pos = { x = -42.65634, y = 13.358551, z = 4.043537 }, mapBuffID = 50};
	[429] = { id = 429, pos = { x = 20.9607029, y = 13.6359148, z = 21.0488 }, mapBuffID = 50};
	[430] = { id = 430, pos = { x = 27.8710918, y = 13.358551, z = 57.5603638 }, mapBuffID = 50};
	[431] = { id = 431, pos = { x = 59.4929848, y = 20.5848885, z = 30.1423683 }, mapBuffID = 50};
	[432] = { id = 432, pos = { x = 81.47287, y = 2.858551, z = -43.9945641 }, mapBuffID = 50};
	[433] = { id = 433, pos = { x = 15.60939, y = 13.2865, z = -22.9822369 }, mapBuffID = 50};
	[434] = { id = 434, pos = { x = -112.784233, y = 7.50008, z = -74.7184753 }, mapBuffID = 50};
	[435] = { id = 435, pos = { x = -3.27045059, y = 7.50008, z = -95.5772552 }, mapBuffID = 50};
	[436] = { id = 436, pos = { x = 54.63459, y = 7.50008, z = -91.32051 }, mapBuffID = 50};
	[437] = { id = 437, pos = { x = 21.2298737, y = 11.00008, z = 31.4609413 }, mapBuffID = 50};
	[438] = { id = 438, pos = { x = -50.6645775, y = 13.00008, z = 29.2017384 }, mapBuffID = 50};
	[439] = { id = 439, pos = { x = 55.90562, y = 10.70364, z = 9.770248 }, mapBuffID = 50};
	[440] = { id = 440, pos = { x = -175.14473, y = -6.49992, z = -99.03528 }, mapBuffID = 50};
	[441] = { id = 441, pos = { x = -97.95862, y = 7.50008, z = -106.234589 }, mapBuffID = 50};
	[442] = { id = 442, pos = { x = 25.59811, y = 1.187279, z = -96.88906 }, mapBuffID = 50};
	[443] = { id = 443, pos = { x = 19.92259, y = 1.187279, z = -61.37537 }, mapBuffID = 50};
	[444] = { id = 444, pos = { x = -49.21468, y = 8.187279, z = 33.24128 }, mapBuffID = 50};
	[445] = { id = 445, pos = { x = -25.33539, y = 4.187279, z = -37.01561 }, mapBuffID = 50};
	[446] = { id = 446, pos = { x = 75.15894, y = 9.098885, z = 110.2808 }, mapBuffID = 50};
	[447] = { id = 447, pos = { x = 47.99472, y = 3.187279, z = 5.934547 }, mapBuffID = 50};
	[448] = { id = 448, pos = { x = 50.09809, y = 9.187286, z = 48.40837 }, mapBuffID = 50};
	[449] = { id = 449, pos = { x = 0.0632476, y = 9.187286, z = 86.56918 }, mapBuffID = 50};
	[450] = { id = 450, pos = { x = 69.31034, y = 6.165421, z = -107.825 }, mapBuffID = 50};
	[451] = { id = 451, pos = { x = 27.79821, y = 11.16542, z = -81.8323 }, mapBuffID = 50};
	[452] = { id = 452, pos = { x = -11.13256, y = 13.16542, z = -51.81628 }, mapBuffID = 50};
	[453] = { id = 453, pos = { x = -41.41456, y = 22.16542, z = 19.91031 }, mapBuffID = 50};
	[454] = { id = 454, pos = { x = -4.350616, y = 32.36542, z = 90.04454 }, mapBuffID = 50};
	[455] = { id = 455, pos = { x = 58.96797, y = 32.36542, z = 90.66731 }, mapBuffID = 50};
	[456] = { id = 456, pos = { x = 120.4716, y = 30.16542, z = 116.0754 }, mapBuffID = 50};
	[457] = { id = 457, pos = { x = 116.2601, y = 22.17132, z = -53.45601 }, mapBuffID = 50};
	[458] = { id = 458, pos = { x = 33.93846, y = 5.0, z = -28.61248 }, mapBuffID = 50};
	[459] = { id = 459, pos = { x = -35.4272, y = 5.0, z = -63.28077 }, mapBuffID = 50};
	[460] = { id = 460, pos = { x = -94.70584, y = 7.0, z = 33.28357 }, mapBuffID = 50};
	[461] = { id = 461, pos = { x = 54.36966, y = 13.05469, z = 37.72503 }, mapBuffID = 50};
	[462] = { id = 462, pos = { x = -64.71688, y = 0.2000002, z = -87.86631 }, mapBuffID = 50};
	[463] = { id = 463, pos = { x = -95.51828, y = 0.2000002, z = -111.2252 }, mapBuffID = 50};
	[464] = { id = 464, pos = { x = -4.592705, y = 0.2000002, z = -123.9988 }, mapBuffID = 50};
	[465] = { id = 465, pos = { x = 4.301727, y = 5.0, z = -68.20008 }, mapBuffID = 50};
	[466] = { id = 466, pos = { x = -133.336, y = 2.082024, z = -30.62843 }, mapBuffID = 50};
	[467] = { id = 467, pos = { x = -50.77419, y = 5.082024, z = -35.29362 }, mapBuffID = 50};
	[468] = { id = 468, pos = { x = 22.67023, y = 7.082024, z = -70.73944 }, mapBuffID = 50};
	[469] = { id = 469, pos = { x = 110.9572, y = 10.12772, z = -45.22568 }, mapBuffID = 50};
	[470] = { id = 470, pos = { x = 30.42099, y = 5.082024, z = -102.5807 }, mapBuffID = 50};
	[471] = { id = 471, pos = { x = -11.4106, y = 0.0820236, z = -172.0323 }, mapBuffID = 50};
	[472] = { id = 472, pos = { x = -14.66136, y = 0.0820236, z = -137.9506 }, mapBuffID = 50};
	[473] = { id = 473, pos = { x = -1.363762, y = 5.17448, z = -72.07549 }, mapBuffID = 50};
	[474] = { id = 474, pos = { x = 169.7914, y = -6.339142, z = -95.16876 }, mapBuffID = 50};
	[475] = { id = 475, pos = { x = 119.7209, y = -6.339142, z = -91.25458 }, mapBuffID = 50};
	[476] = { id = 476, pos = { x = 123.0687, y = -6.495178, z = -57.2241 }, mapBuffID = 50};
	[477] = { id = 477, pos = { x = 92.44868, y = 0.6990842, z = 21.40891 }, mapBuffID = 50};
	[478] = { id = 478, pos = { x = 154.7431, y = 0.6608635, z = 30.87447 }, mapBuffID = 50};
	[479] = { id = 479, pos = { x = 83.01051, y = 0.6608581, z = 56.11747 }, mapBuffID = 50};
	[480] = { id = 480, pos = { x = -44.68248, y = 14.26086, z = 86.59121 }, mapBuffID = 50};
	[481] = { id = 481, pos = { x = -38.19948, y = -2.802291, z = -32.17667 }, mapBuffID = 50};
};
