QiXiMarriageData = QiXiMarriageData or BaseClass()
function QiXiMarriageData:__init()
	if QiXiMarriageData.Instance then
		print_error("[QiXiMarriageData] Attempt to create singleton twice!")
		return
	end
	QiXiMarriageData.Instance = self
end

function QiXiMarriageData:__delete()
	-- RemindManager.Instance:UnRegister(RemindName.MarryRing)
	QiXiMarriageData.Instance = nil
end

function QiXiMarriageData:SetQiXiMarriageInfo(protocol)
	self.cp_info = protocol.cp_info
	self.begin_time = protocol.begin_time
	self.end_time = protocol.end_time
	for i=1,2 do
		AvatarManager.Instance:SetAvatarKey(self.cp_info[i].uid, self.cp_info[i].avatar_key_big, self.cp_info[i].avatar_key_small)
	end
	-- self.next_hunyan_begin_time = protocol.next_hunyan_begin_time
end

function QiXiMarriageData:GetCpInfo()
	return self.cp_info
end

function QiXiMarriageData:GetBeginTime()
	return self.begin_time
end

function QiXiMarriageData:GetEndTime()
	return self.end_time
end

function QiXiMarriageData:GetHunLiOtherCfg()
	local activity_cfg = ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto")
	if activity_cfg then
		self.hunli_other_cfg = activity_cfg.hunli_other
	end
	return self.hunli_other_cfg
end

function QiXiMarriageData:GetLuxuryPrice()
	local cfg = self:GetHunLiOtherCfg()
	if cfg and cfg[3] then
		return cfg[3].marry_gold or 0
	end
end

-- function QiXiMarriageData:GetNextHunyanBeginTime()
-- 	return self.next_hunyan_begin_time
-- end
