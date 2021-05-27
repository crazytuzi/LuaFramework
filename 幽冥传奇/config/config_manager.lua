
ConfigManager = ConfigManager or BaseClass()

function ConfigManager:__init()
	if ConfigManager.Instance ~= nil then
		error("[ConfigManager] attempt to create singleton twice!")
		return
	end
	ConfigManager.Instance = self

	self.cfg_list = {}
	self.scene_cfg_list = {}

	self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:TimerCallback() end, 1)
end

function ConfigManager:__delete()
	ConfigManager.Instance = nil
	GlobalTimerQuest:CancelQuest(self.timer_quest)
end

function ConfigManager:TimerCallback()
	local now_time = Status.NowTime
	for k, v in pairs(self.cfg_list) do
		if v.time + 120 < now_time then
			_G.package.loaded[k] = nil
			self.cfg_list[k] = nil
		end
	end

	for k, v in pairs(self.scene_cfg_list) do
		if v.time + 120 < now_time then
			Config.scenes[v.scene_id] = nil
			_G.package.loaded[k] = nil
			self.scene_cfg_list[k] = nil
		end
	end
end

-- 获取plist配置
function ConfigManager.GetPlistConfig(plist)
	return nil
end

function ConfigManager:GetConfig(lua_name)
	local cfg_info = self.cfg_list[lua_name]
	if nil == cfg_info then
		local cfg = cc.FileUtils:getInstance():isFileExist(lua_name .. ".lua") and require(lua_name) or nil
		if nil ~= cfg then
			cfg_info = {["cfg"] = cfg, ["time"] = Status.NowTime}
			self.cfg_list[lua_name] = cfg_info
		end
	else
		cfg_info.time = Status.NowTime
	end

	return cfg_info and cfg_info.cfg
end

--获取客户端配置
function ConfigManager:GetClientConfig(lua_name)
	return self:GetConfig("scripts/config/client/" .. lua_name)
end

--获取数据配置
function ConfigManager:GetAutoConfig(lua_name)
	return self:GetConfig("scripts/config/auto_new/" .. lua_name)
end

-- 获取物品数据配置
function ConfigManager:GetAutoItemConfig(lua_name)
	return self:GetConfig("scripts/config/auto_new/item/" .. lua_name)
end

-- 获取物品数据配置
function ConfigManager:GetItemConfig(item_id)
	return self:GetConfig("scripts/config/client/item_cfg/" .. item_id)
end

-- 获取UI配置
function ConfigManager:GetUiConfig(lua_name)
	return self:GetConfig("scripts/gameui/config/" .. lua_name)
end

-- 获取场景配置
function ConfigManager:GetServerSceneConfig(scene_id)
	return self:GetConfig("scripts/config/server/envir/scene/scene" .. scene_id)
end

-- 获取场景配置
function ConfigManager:GetSceneConfig(scene_id)
	if nil == Config_scenelist[scene_id] then
		return nil
	end

	local lua_name = "scripts/config/scenes/scene_" .. scene_id
	local cfg_info = self.scene_cfg_list[lua_name]
	if nil == cfg_info then
		require(lua_name)
		if nil ~= Config.scenes[scene_id] then
			cfg_info = {["cfg"] = Config.scenes[scene_id], ["time"] = Status.NowTime, ["scene_id"] = scene_id}
			self.scene_cfg_list[lua_name] = cfg_info
			Config.scenes[scene_id] = nil
		end
	else
		cfg_info.time = Status.NowTime
	end

	return cfg_info and cfg_info.cfg
end

-- 获取服务端配置
function ConfigManager:GetServerConfig(lua_name)
	return self:GetConfig("scripts/config/server/config/" .. lua_name)
end
