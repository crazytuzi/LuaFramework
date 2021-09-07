RoyTombData = RoyTombData or BaseClass()

function RoyTombData:__init()
	if RoyTombData.Instance then
		print_error("[RoyTombData] Attempt to create singleton twice!")
		return
	end
	RoyTombData.Instance = self

	self.roytomb_cfg = nil
	self.roytomb_fb_config = nil

	self.roytomb_role_info = {
		team_info_list = {},
		today_kill_role_score = 0,
	}
end

function RoyTombData:__delete()
	RoyTombData.Instance = nil
end

function RoyTombData:SetHuanglingFBRoleInfo(protocol)
	self.roytomb_role_info.team_info_list = protocol.team_info_list
	self.roytomb_role_info.today_kill_role_score = protocol.today_kill_role_score
end

function RoyTombData:GetHuanglingFBRoleInfo()
	return self.roytomb_role_info
end

function RoyTombData:GetRoyTombInfoCfg()
	if not self.roytomb_cfg then 
		self.roytomb_cfg = ConfigManager.Instance:GetAutoConfig("huanglifb_auto")
	end
	return self.roytomb_cfg
end

function RoyTombData:GetRoyTombFbInfoCfg()
	local roytomb_info = self:GetRoyTombInfoCfg()
	if self.roytomb_fb_config == nil then
		self.roytomb_fb_config = roytomb_info.fb_config
		table.sort(self.roytomb_fb_config, SortTools.KeyLowerSorter("seq"))
	end
	return self.roytomb_fb_config
end

function RoyTombData:GetEnterInfoByLevel(role_level)
	local roytomb_info = self:GetRoyTombFbInfoCfg()
	local return_info = nil
	local return_level = 0
	if roytomb_info and role_level then
		for k,v in pairs(roytomb_info) do
			if v and return_level <= v.enter_need_level then
				return_info = v
				return_level = v.enter_need_level
				if role_level >= return_level and role_level <= v.enter_max_level then
					break
				end
			end
		end
	end
	return return_info
end