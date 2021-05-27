
MapData = MapData or BaseClass()

function MapData:__init()
	if MapData.Instance ~= nil then
		ErrorLog("[MapData] attempt to create singleton twice!")
		return
	end
	MapData.Instance = self

	self.door_scene_count = 0
	self.door_scene_list = {}

	self.npc_scene_count = 0
	self.npc_scene_list = {}
	self.npc_req_list = {}
end

function MapData:__delete()
	MapData.Instance = nil
end

function MapData:SetDoorInfo(door_scene_count, door_scene_list)
	-- self.door_scene_count = door_scene_count
	-- self.door_scene_list = door_scene_list
end

function MapData:GetDoorList(scene_id)
	if nil == self.door_scene_list[scene_id] then
		self.door_scene_list[scene_id] = {}
		self.door_scene_list[scene_id].door_list = ConfigManager.Instance:GetServerSceneConfig(scene_id)[1].teleport
	end
	return self.door_scene_list[scene_id].door_list or {}
end

function MapData:GetDoorCfg(scene_id, to_scene_id)
	if scene_id == to_scene_id then
		return nil
	end

	local close_scene_id_list = {}
	local door_list = {}

	-- 广度优先搜索
	function breadth_first_search(scene_id)
		local _door_list = self:GetDoorList(scene_id)

		for k, v in pairs(_door_list) do
			if v.toSceneid == to_scene_id then
				table.insert(door_list, v)
				return true
			end
		end

		close_scene_id_list[scene_id] = true

		for k, v in pairs(_door_list) do
			if not close_scene_id_list[v.toSceneid] and breadth_first_search(v.toSceneid) then
				table.insert(door_list, 1, v)
				return true
			end
		end

		return false
	end

	breadth_first_search(scene_id)

	return door_list[1]
end

function MapData:SetNpcList(scene_id, npc_list)
	-- self.npc_scene_list[scene_id] = npc_list
end

function MapData:GetNpcList(scene_id)
	-- if nil ~= self.npc_scene_list[scene_id] then
	-- 	return self.npc_scene_list[scene_id] or {}
	-- end

	-- if nil == self.npc_req_list[scene_id] then
	-- 	self.npc_req_list[scene_id] = true
	-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSNpcConfigReq)
	-- 	protocol.scene_id = scene_id
	-- 	protocol:EncodeAndSend()
	-- end
	-- return {}
	if nil == self.npc_scene_list[scene_id] then
		self.npc_scene_list[scene_id] = {}
		self.npc_scene_list[scene_id] = ConfigManager.Instance:GetServerSceneConfig(scene_id)[1].npc
	end
	return self.npc_scene_list[scene_id] or {}
end

function MapData.GetMapBossList(scene_id)
	local map_labels = NewlyBossCtrl.Instance:GetMapLabels()
	local list = map_labels[scene_id] and map_labels[scene_id].labels or {}

	return list
end

function MapData.GetMapBossPos(scene_id, boss_id)
	local map_labels = NewlyBossCtrl.Instance:GetMapLabels()
	local labels = map_labels[scene_id] and map_labels[scene_id].labels or {}
	local x, y = -1, -1
	for k, v in pairs(labels) do
		if v.BossId == boss_id then
			x, y = v.x or -1, v.y or -1
			break
		end
	end

	return x, y
end

function MapData:GetMapXmlConfig(scene_id)
	self.map_xml_cfg_list = self.map_xml_cfg_list or {}
	if nil ~= self.map_xml_cfg_list[scene_id] then
		return self.map_xml_cfg_list[scene_id]
	end

	local cfg_str = UtilEx:readText("config/map/" .. scene_id .. ".xml")
	self.map_xml_cfg_list[scene_id] = {
		id = scene_id,
		res_id = scene_id,
		res_x = tonumber(MapData.GetXmlValue(cfg_str, "res_x")),
		res_y = tonumber(MapData.GetXmlValue(cfg_str, "res_y")),
		pixel_width = tonumber(MapData.GetXmlValue(cfg_str, "pixel_width")),
		pixel_height = tonumber(MapData.GetXmlValue(cfg_str, "pixel_height")),
		logic_width = tonumber(MapData.GetXmlValue(cfg_str, "logic_width")),
		logic_height = tonumber(MapData.GetXmlValue(cfg_str, "logic_height")),
	}
	
	return self.map_xml_cfg_list[scene_id]
end

function MapData.GetXmlValue(xml_str, name)
	local s, e = string.find(xml_str, "<" .. name .. ">(.-)</" .. name .. ">")
	if nil ~= s and nil ~= e then
		local len = string.len(name)
		return string.sub(xml_str, s + len + 2, e - len - 3)
	end
	return ""
end
