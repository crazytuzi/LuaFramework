MapData = MapData or BaseClass()

-- 世界地图
MapData.WORLDMAPCFG = {
	[1] = 2303,							-- 函谷关
	[2] = 2304,							-- 中立皇城
	[3] = 2305,							-- 长平战场
	[4] = 2306,							-- 漠北天山
	[5] = 2307,							-- 东周皇陵
	[6] = 2308,							-- 熔岩-2308
	[7] = 2007,							-- 马陵关外
	[8] = 2002,							-- 齐国王城
	[9] = 2102,							-- 楚国王城
	[10] = 2202,						-- 魏国王城
}
-- 国家地图
MapData.COUNTRYMAPCFG = {
	[1] = {					-- 齐国地图
		[1] = 2000,					-- 无极山
		[2] = 2001,					-- 凤凰城
		[3] = 2002,					-- 齐国王城
		[4] = 2003,					-- 河西郊外
		[5] = 2004,					-- 崤之平原
		[6] = 2005,					-- 长平关
		[7] = 2006,					-- 桂陵古道
	},
	[2] = {					-- 楚国地图
		[1] = 2100,					-- 无极山
		[2] = 2101,					-- 凤凰城
		[3] = 2102,					-- 楚国王城
		[4] = 2103,					-- 河西郊外
		[5] = 2104,					-- 崤之平原
		[6] = 2105,					-- 长平关
		[7] = 2106,					-- 桂陵古道
	},
	[3] = {					-- 魏国地图
		[1] = 2200,					-- 无极山
		[2] = 2201,					-- 凤凰城
		[3] = 2202,					-- 魏国王城
		[4] = 2203,					-- 河西郊外
		[5] = 2204,					-- 崤之平原
		[6] = 2205,					-- 长平关
		[7] = 2206,					-- 桂陵古道
	},
}
-- 本国地图
MapData.MapNameList = {
	[2000] = 1,
    [2001] = 2,
    [2002] = 3,
    [2003] = 4,
    [2004] = 5,
    [2005] = 6,
    [2006] = 7,
    [2100] = 1,
    [2101] = 2,
    [2102] = 30,
    [2103] = 4,
    [2104] = 5,
    [2105] = 6,
    [2106] = 7,
    [2200] = 1,
    [2201] = 2,
    [2202] = 300,
    [2203] = 4,
    [2204] = 5,
    [2205] = 6,
    [2206] = 7,
    --世界地图
    [2303] = 8,							-- 函谷关
	[2304] = 9,							-- 中立皇城
	[2305] = 10,							-- 长平战场
	[2306] = 11,							-- 漠北天山
	[2307] = 12,							-- 东周皇陵
	[2308] = 13,							-- 熔岩-2308
	[2007] = 14,							-- 马陵关外
	[2002] = 3,							-- 齐国王城
	[2102] = 30,							-- 楚国王城
	[2202] = 300,						-- 魏国王城
}


MapData.SCENEID = {
	gongchengzhan = 1002,							-- 攻城战
}

function MapData:__init()
	if MapData.Instance then
		print_error("[MapData] Attempt to create singleton twice!")
		return
	end
	MapData.Instance = self

	self.map_config = {}

	self.info_table = {}
	self.icon_table = {}
end

function MapData:__delete()
	MapData.Instance = nil
end

function MapData:GetMapConfig(map_id)
	if not self.map_config[map_id] then
		self.map_config[map_id] = ConfigManager.Instance:GetSceneConfig(map_id)
		if not self.map_config[map_id] then
			print_error("Can't find scene_" .. map_id .. "config")
			return
		end
	end
	return self.map_config[map_id]
end

function MapData:GetInfoByType(info_type)
	if not info_type then
		return self.info_table
	else
		local temp_table = {}
		local count = 0
		for _, v in pairs(self.info_table) do
			if (v.obj_type == info_type) then
				count = count + 1
				temp_table[count] = v
			end
		end
		return temp_table, count
	end
end

function MapData:GetInfoByIndex(index)
	if not index then
		return self.info_table
	else
		return self.info_table[index]
	end
end

function MapData:SetInfo(list)
	self:ClearInfo()
	self.info_table = list
	local count = 0
	for _, v in pairs(self.info_table) do
		count = count + 1
	end
end

function MapData:ClearInfo()
	if self.info_table then
		for _, v in pairs(self.info_table) do
			GameObject.Destroy(v.obj)
		end
		self.info_table = {}
	end
end

function MapData:SetIcon(list)
	self:ClearIcon()
	self.icon_table = list
end

function MapData:ClearIcon()
	if self.icon_table then
		for _, v in pairs(self.icon_table) do
			GameObject.Destroy(v.obj)
		end
		self.icon_table = {}
	end
end

function MapData:GetNpcIcon()
	local temp_table = {}
	local count = 0
	for _, v in pairs(self.icon_table) do
		if v.npc_id then
			count = count + 1
			temp_table[count] = v
		end
	end
	return temp_table, count
end

function MapData:GetMonster(monster_id)
	local monster_info = ConfigManager.Instance:GetAutoConfig("guaji_pos_auto").map_info
	for k,v in pairs(monster_info) do
		if monster_id == v.monster_id then
			return v
		end
	end
	return nil
end

-- 小飞鞋道具ID
function MapData:GetFlyShoeId()
	return 27583
end

-- (当前地图怪物按钮排序)
function MapData:GetSceneMonsterSort(list)
	if list then
		local new_list = {}
		local last_monster_id = 0
		for _,v in pairs(list) do
			if last_monster_id ~= v.id then
				last_monster_id = v.id
				local boss_cfg = BossData.Instance:GetMonsterInfo(v.id)
				if boss_cfg then
					local info = {}
					info.id = v.id or 0
					info.x = v.x or 0
					info.y = v.y or 0
					info.name = boss_cfg.name or ""
					info.level = boss_cfg.level or 0
					table.insert(new_list, info)
				end
			end
		end
		if new_list and next(new_list) then
			SortTools.SortAsc(new_list, "level")
		end
		return new_list
	end
	return nil
end
