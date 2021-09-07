
ConfigManager = ConfigManager or BaseClass()

function ConfigManager:__init()
	if ConfigManager.Instance ~= nil then
		error("[ConfigManager] attempt to create singleton twice!")
		return
	end
	ConfigManager.Instance = self

	self.cfg_list = {}
	self.split_cfg_list = {}

	-- 常驻内存表格
	self.persistent_cfg_list = {
		["config/auto_new/tasklist_auto"] = require("config/auto_new/tasklist_auto"),
		["config/auto_new/monster_auto"] = require("config/auto_new/monster_auto"),
		["config/auto_new/mount_auto"] = require("config/auto_new/mount_auto"),
		["config/auto_new/wing_auto"] = require("config/auto_new/wing_auto"),

		["config/auto_new/item/gift_auto"] = require("config/auto_new/item/gift_auto"),
		["config/auto_new/item/equipment_auto"] = require("config/auto_new/item/equipment_auto"),
		["config/auto_new/item/other_auto"] = require("config/auto_new/item/other_auto"),
		["config/auto_new/item/expense_auto"] = require("config/auto_new/item/expense_auto"),
		["config/auto_new/item/virtual_auto"] = require("config/auto_new/item/virtual_auto")
	}

	for k, v in pairs(self.persistent_cfg_list) do
		self:CheckMetable(k, v)
	end

	-- 配置分表读取常驻内存表格(只require一次,key就是配置的名字)
	self.split_persistent_cfg_list = {
		["roleskill_auto"] = require("config/auto_new/roleskill_auto"),
	}

	for k, v in pairs(self.split_persistent_cfg_list) do
		self:SetSplitMetable(k, v)
	end

	self.timer_quest = GlobalTimerQuest:AddRunQuest(function() self:TimerCallback() end, 1)
end

function ConfigManager:__delete()
	for k,v in pairs(self.persistent_cfg_list) do
		_G.package.loaded[k] = nil
	end
	self.persistent_cfg_list = {}

	for k,v in pairs(self.split_persistent_cfg_list) do
		_G.package.loaded[k] = nil
	end
	self.split_persistent_cfg_list = {}

	for k, v in pairs(self.cfg_list) do
		_G.package.loaded[k] = nil
	end
	self.cfg_list = {}

	for k, v in pairs(self.split_cfg_list) do
		_G.package.loaded[k] = nil
	end
	self.split_cfg_list = {}

	ConfigManager.Instance = nil
	GlobalTimerQuest:CancelQuest(self.timer_quest)
end

local real_pairs = pairs
function pairs(t)
	local metable = getmetatable(t)
	if nil ~= metable and nil ~= metable.__pairs then
		return metable.__pairs(t)
	end
	return real_pairs(t)
end

local real_next = next
function next(t)
	local metable = getmetatable(t)
	if nil ~= metable and nil ~= metable.__next then
		return metable.__next(t)
	end
	return real_next(t)
end

function ConfigManager:CheckMetable(lua_name, lua_cfg)
	if nil == lua_cfg then
		return
	end

	local lua_cfg_old_metable = getmetatable(lua_cfg)
	setmetatable(lua_cfg, nil)

	local depth = nil ~= lua_cfg["default_table"] and 1 or 2

	if 1 == depth then
		local default_table = lua_cfg["default_table"]
		if nil ~= default_table then
			lua_cfg["default_table"] = nil
			self:SetMetatables(lua_cfg, default_table)
		end

	elseif 2 == depth then
		for k, v in real_pairs(lua_cfg) do
			local default_table = lua_cfg[k .. "_default_table"]
			if nil ~= default_table then
				lua_cfg[k .. "_default_table"] = nil
				self:SetMetatables(v, default_table)
			end
		end
	end

	setmetatable(lua_cfg, lua_cfg_old_metable)
end

-- 设置分表原表
function ConfigManager:SetSplitMetable(cfg_name, cfg)
	local mt = {}

	mt.__index = function (tbl, key)
		local old_metatable = getmetatable(tbl)
		setmetatable(tbl, nil)

		local sub_t = require("config/auto_new/" .. cfg_name .. "/" .. key .. "_auto")
		self:SetMetatables(sub_t, cfg[key .. "_default_table"])
		tbl[key] = sub_t

		setmetatable(tbl, old_metatable)
		return sub_t
	end
	setmetatable(cfg, mt)
end

function ConfigManager:SetMetatables(list_cfg, default_table)
	if nil == list_cfg or nil == default_table then
		return
	end

	local func = function (tbl, key)
		local nk, nv = real_next(default_table, key)
		if nk then
			nv = tbl[nk]
		end

		return nk, nv
	end

	local mt = {}
	mt.__index = function(tbl, key)
		-- 如果是获取的数据是由公式算的话执行公式的逻辑
		if "function" == type(default_table[key]) then
			local t_key = default_table[key .. "_params"]
			-- 不知道什么原因导致关闭的时候会有个function存在导致直接调用了报错
			if nil == t_key then
				return default_table[key]
			end

			local len = #t_key
			-- 目前最大只供4个参数作为运算，以后有需要的再加吧。
			if 1 == len then
				return default_table[key](tbl[t_key[1]])
			elseif 2 == len then
				return default_table[key](tbl[t_key[1]], tbl[t_key[2]])
			elseif 3 == len then
				return default_table[key](tbl[t_key[1]], tbl[t_key[2]], tbl[t_key[3]])
			elseif 4 == len then
				return default_table[key](tbl[t_key[1]], tbl[t_key[2]], tbl[t_key[3]], tbl[t_key[4]])
			end
		else
			return default_table[key]
		end
	end

	mt.__pairs = function(tbl, key)
		return func, tbl, key
	end

	mt.__next = function(tbl)
		return next(default_table)
	end

	mt.__newindex = function (t, k, v)
		print_error("please do not try to modify config, Ok?", k, v)
	end

	for k,v in pairs(list_cfg) do
		setmetatable(v, mt)
	end
end

function ConfigManager:TimerCallback()
	local now_time = Status.NowTime
	for k, v in pairs(self.cfg_list) do
		if v.time + 600 < now_time then
			_G.package.loaded[k] = nil
			self.cfg_list[k] = nil
		end
	end
	for k, v in pairs(self.split_cfg_list) do
		if v.time + 600 < now_time then
			_G.package.loaded[k] = nil
			self.split_cfg_list[k] = nil
		end
	end
end

function ConfigManager:ClearCfgList()
	self.cfg_list = {}
end

function ConfigManager:ClearSplitCfgList()
	self.split_cfg_list = {}
end

function ConfigManager:GetConfig(lua_name)
	-- 优先从常驻内存里读取
	local cfg_info = self.persistent_cfg_list[lua_name]
	if nil ~= cfg_info then
		return cfg_info
	end

	-- 动态读取
	local cfg_info = self.cfg_list[lua_name]
	if nil == cfg_info then
		local cfg = require(lua_name)
		if nil ~= cfg then
			cfg_info = {["cfg"] = cfg, ["time"] = Status.NowTime}
			self.cfg_list[lua_name] = cfg_info

			self:CheckMetable(lua_name, cfg)
		end
	else
		cfg_info.time = Status.NowTime
	end

	return cfg_info and cfg_info.cfg
end

--获取数据配置
function ConfigManager:GetAutoConfig(lua_name)
	return self:GetConfig("config/auto_new/" .. lua_name)
end

-- 获取物品数据配置
function ConfigManager:GetAutoItemConfig(lua_name)
	return self:GetConfig("config/auto_new/item/" .. lua_name)
end

-- 获取场景配置
function ConfigManager:GetSceneConfig(scene_id)
	return self:GetConfig("config/scenes/scene_" .. scene_id)
end
