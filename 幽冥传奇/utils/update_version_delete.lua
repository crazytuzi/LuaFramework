-- 按等级版本删除(等级按版本开放)
UpdateVersionDelete = UpdateVersionDelete or {}

-- 过滤删除表里面等级
function UpdateVersionDelete.FilterDelete(value)
	local filter_cfg = Config.version_level_auto.delete_cfg_list or {}
	if nil == filter_cfg then return end

	for _,v in pairs(filter_cfg) do
		if nil ~= v.cfg_name and nil ~= value and value == v.cfg_name and 
			nil ~= v.param_name and nil ~= v.param_min_value then 

			local cfg_name = Split(v.cfg_name, "%.")
			local cfg = Config
			for k2,v2 in pairs(cfg_name) do
				if k2 ~= 1 then
					cfg = cfg[v2]
				end
			end
			for k3 = #cfg, 1, -1 do
				if cfg[k3][v.param_name] > v.param_min_value then
					table.remove(cfg, k3)
				end
			end
		end
	end
end

-- 过滤删除表里面等级
function UpdateVersionDelete.FilterDeleteEx(value, cfg)
	local filter_cfg = Config.version_level_auto.delete_cfg_list or {}
	if nil == filter_cfg then return end

	for _,v in pairs(filter_cfg) do
		if nil ~= v.cfg_name and nil ~= value and value == v.cfg_name and 
			nil ~= v.param_name and nil ~= v.param_min_value then 

			local cfg_name = Split(v.cfg_name, "%.")
			local cfg_child = cfg
			for k2,v2 in pairs(cfg_name) do
				if k2 > 2 then
					cfg_child = cfg_child[v2]
				end
			end
			for k3 = #cfg_child, 1, -1 do
				if cfg_child[k3][v.param_name] > v.param_min_value then
					table.remove(cfg_child, k3)
				end
			end
		end
	end
end