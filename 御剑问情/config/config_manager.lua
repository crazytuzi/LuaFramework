
ConfigManager = ConfigManager or BaseClass()

function ConfigManager:__init()
	if ConfigManager.Instance ~= nil then
		error("[ConfigManager] attempt to create singleton twice!")
		return
	end
	ConfigManager.Instance = self

	self.cfg_list = {}
end

function ConfigManager:__delete()
	for k, v in pairs(self.cfg_list) do
		_G.package.loaded[k] = nil
	end
	self.cfg_list = {}

	ConfigManager.Instance = nil
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

function ConfigManager:ClearCfgList()
	self.cfg_list = {}
end

-- 设置分表原表
function SetConfigSplitMetable(cfg_name, cfg)
	local mt = {}
	mt.__index = function (tbl, key)
		local old_metatable = getmetatable(tbl)
		setmetatable(tbl, nil)

		local sub_t = require("config/auto_new/" .. cfg_name .. "/" .. key .. "_auto")
		SetConfigMetatables(sub_t, cfg[key .. "_default_table"])
		tbl[key] = sub_t

		setmetatable(tbl, old_metatable)
		return sub_t
	end
	setmetatable(cfg, mt)
end

function ConfigManager:GetConfig(lua_name)
	local cfg = self.cfg_list[lua_name]
	if nil == cfg then
		cfg = require(lua_name)
		if nil ~= cfg then
			self.cfg_list[lua_name] = cfg
			CheckConfigMetable(cfg)
		end
	end

	return cfg
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

-- 配置分表读取常驻内存表格(只require一次,key就是配置的名字)
local split_persistent_cfg_list = {
	["config/auto_new/roleskill_auto"] = "roleskill_auto",
	["config/auto_new/randactivityconfig_1_auto"] = "randactivityconfig_1_auto",
	["config/auto_new/randactivityconfig_2_auto"] = "randactivityconfig_2_auto",
}

function CheckLuaConfig(path, lua_cfg)
	local split_lua_name = split_persistent_cfg_list[path]
	if split_lua_name then
		SetConfigSplitMetable(split_lua_name, lua_cfg)
	else
		CheckConfigMetable(lua_cfg)
	end
end

function CheckConfigMetable(lua_cfg)
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
			SetConfigMetatables(lua_cfg, default_table)
		end

	elseif 2 == depth then
		for k, v in real_pairs(lua_cfg) do
			local default_table = lua_cfg[k .. "_default_table"]
			if nil ~= default_table then
				lua_cfg[k .. "_default_table"] = nil
				SetConfigMetatables(v, default_table)
			end
		end
	end

	setmetatable(lua_cfg, lua_cfg_old_metable)
end

function SetConfigMetatables(list_cfg, default_table)
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
