MapData = MapData or BaseClass()

MapData.WORLDCFG = {
	[1] = 101,							-- 桃源村
	[2] = 107,							-- 女娲禁地
	[3] = 103,							-- 华胥古国
	[4] = 104,							-- 雪剑崖
	[5] = 105,							-- 云之巅
	[6] = 108,							-- 魔教驻地
	[7] = 106,							-- 苍之南
	[8] = 102,							-- 月牙涧
	--[9] = 109,							-- 碧日平原
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