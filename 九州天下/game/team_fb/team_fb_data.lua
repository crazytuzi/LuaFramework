TeamFbData = TeamFbData or BaseClass()

local TEAMCOUNTTYPR = {
[DAY_COUNT.DAYCOUNT_ID_YAOSHOUJITAN_JOIN_TIMES] = 3 ,
[DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES] = 2, 
[DAY_COUNT.DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES] = 1 }

function TeamFbData:__init()
	if TeamFbData.Instance ~= nil then
		print_error("[ForgeData] attempt to create singleton twice!")
		return
	end
	TeamFbData.Instance = self
	self.get_team_fb_info = false

	self.fuben_cell_info = {}
	self.reward_item_list = {}
	self.reward_item_first = {}
	self.join_times_list = {}
	self.open_list = {}
	self.desc_list = {}
	
	self.player_id = 0
	self.show_flag = false
	self.team_member_t = {}

	self.team_fb_info = {}

	self:InitTeamCfg()
end

function TeamFbData:__delete()
	self.get_team_fb_info = nil
	TeamFbData.Instance = nil
	self.player_id = nil
end

-- 初始化奖励
function TeamFbData:InitTeamCfg()
	local cfg = ConfigManager.Instance:GetAutoConfig("fbequip_auto").other	
	local cfg2 = ConfigManager.Instance:GetAutoConfig("teamtowerdefend_auto").other

	self.reward_item_list[1] = cfg[1].show_item_id
	self.reward_item_list[2] = cfg2[1].show_item_id

	self.reward_item_first[1] = cfg[1].fb_first_reward

	self.join_times_list[1] = cfg[1].join_times
	self.join_times_list[2] = cfg2[1].free_join_times

	self.open_list[1] = cfg[1].open_level
	self.open_list[2] = cfg2[1].open_level

end

function TeamFbData:SetEquipInfo(protocol)
	self.has_first_passed = protocol.has_first_passed
end

function TeamFbData:GetIsFirstPass(choose)
	if self.has_first_passed and self.has_first_passed == 0 and choose == 1 then
		return true
	else
		return false
	end
end

function TeamFbData:GetDesc()
	if  self.desc_list and not(next(self.desc_list)) then 	
		local cfg = ConfigManager.Instance:GetAutoConfig("fbequip_auto").other
		self.desc_list[1] = cfg[1].fb_des
		local cfg = ConfigManager.Instance:GetAutoConfig("teamtowerdefend_auto").other
		self.desc_list[2] = cfg[1].fb_des
	end
	
	return self.desc_list
end

function TeamFbData:GetOpenList()
	return self.open_list
end


-- 设置对应副本类型的剩余进入次数
function TeamFbData:SetTeamFBInfo(type_value,protocol_value)
	--print_error("进入次数---编号：",type_value, "-----" ,protocol_value)

	if type_value ~= DAY_COUNT.DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES or type_value ~= DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES then
		self.team_fb_info[type_value] = protocol_value
		self:UpdateTeamFBInfo()
	else
		self.remain_help_times = protocol_value
	end
	self.get_team_fb_info = true
end

function TeamFbData:GetTeamFbCanEnterCount(type_value)
	if TEAMCOUNTTYPR[type_value] then
		local join_times = self.join_times_list[TEAMCOUNTTYPR[type_value]] or 0
		local enter_count = self.team_fb_info[type_value] or 0
		return join_times - enter_count
	end
	return 0
end

function TeamFbData:UpdateTeamFBInfo()
	for k,v in pairs(self.team_fb_info) do
		local cell_info = {}
		cell_info.remain_times = self.join_times_list[TEAMCOUNTTYPR[k]] - v
		self.fuben_cell_info[TEAMCOUNTTYPR[k]] = cell_info
	end
end

-- 设置最大副本数量
function TeamFbData:GetTeamFBNumber()
	return 2
end

-- 获取副本格子信息
function TeamFbData:GetFubenCellInfo()
	return self.fuben_cell_info
end

-- 获取副本剩余次数协议是否到达
function TeamFbData:IsGetTeamFbInfo()
	return self.get_team_fb_info
end

-- 获取对应副本的奖励物品信息
function TeamFbData:GetReward(choose)
	local cur_is_first = self:GetIsFirstPass(choose)
	local first_reward = {}
	if cur_is_first and self.reward_item_list[choose] then
		for k,v in pairs(self.reward_item_list[choose]) do
			table.insert(first_reward, v)
		end
		table.insert(first_reward, self.reward_item_first[1][0])
		return first_reward
	end

	if self.reward_item_list[choose] then
		return self.reward_item_list[choose]
	else
		return {}
	end
end

function TeamFbData:GetHelpReward()
	return self.remain_help_times
end

function TeamFbData:IsOpenTeamFb()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local open_level_list = TeamFbData.Instance:GetOpenList()
	for k,v in pairs(open_level_list) do
		if vo.level >= v then 
			return true
		end
	end
	return false
end
function TeamFbData:SetDefaultChoose(req_team_type)
	self.show_flag = true
	if req_team_type == ScoietyData.InviteOpenType.EquipTeamFbNew then
		self.default_choose = TEAMCOUNTTYPR[DAY_COUNT.DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES]
	elseif req_team_type == ScoietyData.InviteOpenType.TeamTowerDefendInvite then
		self.default_choose = TEAMCOUNTTYPR[DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES]
	end
end

function TeamFbData:GetDefaultChoose()
	local flag = self.show_flag
	if flag then
		self.show_flag = false
		return self.default_choose or TEAMCOUNTTYPR[DAY_COUNT.DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES], true
	else
		return self.default_choose or TEAMCOUNTTYPR[DAY_COUNT.DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES], false
	end

end

function TeamFbData:GetMaxHelpValue()
	local cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto").other
	return cfg[1].team_fb_assist_times
end

function TeamFbData:CheckRedPoint()
	if not self.get_team_fb_info then
		return false
	end

	local open_level_list = TeamFbData.Instance:GetOpenList()
	local vo = GameVoManager.Instance:GetMainRoleVo()

	for k,v in pairs(self.fuben_cell_info) do
		if v.remain_times > 0 and k ~= TEAMCOUNTTYPR[DAY_COUNT.DAYCOUNT_ID_YAOSHOUJITAN_JOIN_TIMES] and vo.level >= open_level_list[k] then
			return true
		end
	end
	return false
end

function TeamFbData:IsFirstEnter(protocol)
	self.team_tower_defend_fb_is_first = protocol.team_tower_defend_fb_is_first    -- 是否第一次组队塔防
	self.team_yaoshoujitan_fb_is_first = protocol.team_yaoshoujitan_fb_is_first    -- 是否第一次组队妖兽祭坛
	self.team_equip_fb_is_first = protocol.team_equip_fb_is_first

	-- 如果是第一次的话，则对应的副本进入次数增加1
	if self.team_tower_defend_fb_is_first == 1 then
		self.join_times_list[2] = self.join_times_list[2] + 1
	end
	if self.team_yaoshoujitan_fb_is_first == 1 then
		self.join_times_list[3] = self.join_times_list[3] + 1
	end
	-- if self.team_equip_fb_is_first == 1 then
	-- 	self.join_times_list[1] = self.join_times_list[1] + 1
	-- end

	self:UpdateTeamFBInfo()
end

--精英须臾幻境部分--




--组队塔防部分--

function TeamFbData:TeamTowerInfo(protocol)
	self.team_info = protocol
end

function TeamFbData:GetTeamTowerInfo()
	return self.team_info
end

function TeamFbData:SetTeamTowerDefendSkill(protocol)
	if self.team_info then
		for k,v in pairs(self.team_info.skill_list) do
			if protocol.skill_index == v.skill_id then
				v.last_perform_time = protocol.perform_time
				break
			end
		end
	end
end

function TeamFbData:TeamTowerDefendAttrType(protocol)
	self.team_member_t[protocol.uid] = {uid = protocol.uid, attr_type = protocol.attr_type}
end

function TeamFbData:ClearTeamTowerDefendAttrType()
	self.team_member_t = {}
end

function TeamFbData:GetTeamTowerDefendInfo()
	return self.team_member_t or {}
end

function TeamFbData:IsAttrTypeExist(attr_type)
	local player_info = self.team_member_t[self.player_id]
	for k, v in pairs(self.team_member_t) do
		if attr_type == v.attr_type and player_info and player_info.attr_type ~= attr_type then
			return true
		end
	end
	return false
end

function TeamFbData:SendID(id)
	self.player_id = id or 0
end

function TeamFbData:GetID()
	return self.player_id
end

function TeamFbData:SendPos(pos)
	self.player_pos = pos or 0
end

function TeamFbData:GetPos()
	return self.player_pos
end

function TeamFbData:GetSkillCfg()
	local cfg = ConfigManager.Instance:GetAutoConfig("teamtowerdefend_auto").skill_cfg
	return cfg
end

function TeamFbData:GetGuaJiPos()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("teamtowerdefend_auto").other[1]
	return other_cfg.guaji_pos_x, other_cfg.guaji_pos_y
end

function TeamFbData:SetTeamTowerDefendSkillCD(id)
	local cfg = self:GetSkillCfg()
	for k,v in pairs(cfg) do
		if v.skill_id == id then
			return v.cd_s
		end
	end
	return 1
end

