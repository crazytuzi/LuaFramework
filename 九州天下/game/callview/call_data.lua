--1 为国家 2为家族 3组队

CallData = CallData or BaseClass()

Call = {
	Country = 1,
	Family = 2,
	Team = 3,
	ReviveTotem = 4,
	BloodTotem = 5,
}

function CallData:__init()
	if CallData.Instance then
		print_warning("[CallData] Attemp to create a singleton twice !")
	end
	CallData.Instance = self
	self.camp_call = {						-- 召集者信息
		{call_type = 0, uid = 0, post = '', name = "", scene_id = 0,	x = 0,	y = 0, is_kf = false},				--国家
		{uid = 0, post = '', name = "", scene_id = 0,	x = 0,	y = 0, is_kf = false},				--家族（公会）
		{uid = 0, post = '', name = "", scene_id = 0,	x = 0,	y = 0, is_kf = false},				--组队
	}
end

function CallData:__delete()
	CallData.Instance = nil
	self.country_cfg = nil
	self.family_cfg = nil
	self.team_cfg = nil
	self.totem_cfg = nil
end

function CallData:GetCampCallCfg()
	if not self.country_cfg then
		self.country_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").other[1]
	end
	return self.country_cfg
end

function CallData:GetFamilyCallCfg()
	if not self.family_cfg then
		self.family_cfg = ConfigManager.Instance:GetAutoConfig("guildconfig_auto").other_config[1]
	end
	return self.family_cfg
end

function CallData:GetTeamCallCfg()
	if not self.team_cfg then
		self.team_cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1]
	end
	return self.team_cfg
end

function CallData:GetTotemCfg()
	if not self.totem_cfg then
		self.totem_cfg = ConfigManager.Instance:GetAutoConfig("campconfg_auto").totem_pillar[1]
	end
	return self.totem_cfg
end

function CallData:SetCampCall(protocol, index)
	if self.camp_call[index] == nil then
		self.camp_call[index] = {}
	end

	self.camp_call[index].call_type = protocol.call_type
	self.camp_call[index].uid = protocol.uid
	self.camp_call[index].post = protocol.post
	self.camp_call[index].name = protocol.name
	self.camp_call[index].nation = protocol.nation
	self.camp_call[index].scene_id = protocol.scene_id
	self.camp_call[index].x = protocol.x
	self.camp_call[index].y = protocol.y
	self.camp_call[index].is_kf = protocol.activity_type ~= nil
	self.camp_call[index].activity_type = protocol.activity_type
	self.camp_call[index].call_info = protocol.call_info
end

function CallData:GetCampCall()
	return self.camp_call
end

-- 根据index返回
function CallData:GetIndexCost(index)
	if index == Call.Country then
		return self:GetCampCallCfg().call_need_gold
	elseif index == Call.Family then
		return self:GetFamilyCallCfg().call_in_need_gold
	elseif index == Call.Team then
		return self:GetTeamCallCfg().team_callin_need_gold
	elseif index == Call.ReviveTotem then
		return self:GetTotemCfg().relive_pillar_create_gold
	elseif index == Call.BloodTotem then
		return self:GetTotemCfg().recover_pillar_create_gold
	end
	return 0
end