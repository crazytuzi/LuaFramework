OtherData = OtherData or BaseClass()

function OtherData:__init()
	if OtherData.Instance then
		print_error("[OtherData] Attempt to create singleton twice!")
		return
	end
	OtherData.Instance = self

	self.forbid_change_avatar_state = false

	local cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto")
	self.other_client_cfg = ListToMap(cfg.client_config, "plat_name")
	self.other_cfg = cfg.other[1]
end

function OtherData:__delete()
	OtherData.Instance = nil
end

function OtherData:SetForbidChangeAvatarState(state)
	self.forbid_change_avatar_state = state
end

--是否可以更换头像（根据渠道配置）
function OtherData:CanChangePortrait()
	return not self.forbid_change_avatar_state
	-- local spid = tostring(GLOBAL_CONFIG.package_info.config.agent_id or 0)
	-- local plat_cfg = self.other_client_cfg[spid]
	-- if plat_cfg then
	-- 	return plat_cfg.change_portrait == 1
	-- end

	-- return self.other_client_cfg["default"] and self.other_client_cfg["default"].change_portrait == 1 or false
end