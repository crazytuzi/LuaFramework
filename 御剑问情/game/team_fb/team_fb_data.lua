TeamFbData = TeamFbData or BaseClass()
-- 组队副本Data
function TeamFbData:__init()
	if TeamFbData.Instance ~= nil then
		print_error("[ForgeData] attempt to create singleton twice!")
		return
	end
	TeamFbData.Instance = self
	self.get_team_fb_info = false

	self.fuben_cell_info = {}
	self.reward_item_list = {}
	self.join_times_list = {}
	self.open_list = {}

	self.player_id = 0
	self.show_flag = false
	self.team_member_t = {}

	self.team_fb_info = {}

	self:InitEnterTimes()
	self:InitOpenLevel()
	self:InitReward()
end

function TeamFbData:__delete()
	self.get_team_fb_info = nil
	TeamFbData.Instance = nil
	self.player_id = nil
end

--数据层构造按照 1.获取数据方法 2.处理数据方法 3.判断数据方法
local TeamCountType = {[DAY_COUNT.DAYCOUNT_ID_YAOSHOUJITAN_JOIN_TIMES] = 3 ,[DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES] = 2, [DAY_COUNT.DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES] = 1}

--通用部分--

-- 初始化奖励
function TeamFbData:InitReward()
	local cfg = ConfigManager.Instance:GetAutoConfig("fbequip_auto").other
	self.reward_item_list[1] = cfg[1].show_item_id
	cfg = ConfigManager.Instance:GetAutoConfig("teamtowerdefend_auto").other
	self.reward_item_list[2] = cfg[1].show_item_id
	cfg = ConfigManager.Instance:GetAutoConfig("yaoshoujitanteamfbconfig_auto").other
	self.reward_item_list[3] = cfg[1].show_item_id
end

function TeamFbData:InitEnterTimes()
	local cfg = ConfigManager.Instance:GetAutoConfig("fbequip_auto").other
	self.join_times_list[1] = cfg[1].join_times
	local cfg = ConfigManager.Instance:GetAutoConfig("teamtowerdefend_auto").other
	self.join_times_list[2] = cfg[1].free_join_times
	local cfg = ConfigManager.Instance:GetAutoConfig("yaoshoujitanteamfbconfig_auto").mode_list
	self.join_times_list[3] = cfg[1].free_join_times
end

function TeamFbData:InitOpenLevel()
	local cfg = ConfigManager.Instance:GetAutoConfig("fbequip_auto").other
	self.open_list[1] = cfg[1].open_level
	local cfg = ConfigManager.Instance:GetAutoConfig("teamtowerdefend_auto").other
	self.open_list[2] = cfg[1].open_level
	local cfg = ConfigManager.Instance:GetAutoConfig("yaoshoujitanteamfbconfig_auto").other
	self.open_list[3] = cfg[1].open_level
end

function TeamFbData:GetDesc()
	local desc_list = {}
	local cfg = ConfigManager.Instance:GetAutoConfig("fbequip_auto").other
	desc_list[1] = cfg[1].fb_des
	local cfg = ConfigManager.Instance:GetAutoConfig("teamtowerdefend_auto").other
	desc_list[2] = cfg[1].fb_des
	local cfg = ConfigManager.Instance:GetAutoConfig("yaoshoujitanteamfbconfig_auto").other
	desc_list[3] = cfg[1].fb_des
	return desc_list
end

function TeamFbData:GetOpenList()
	return self.open_list
end


-- 设置对应副本类型的剩余进入次数
function TeamFbData:SetTeamFBInfo(type_value,protocol_value)
	if type_value ~= DAY_COUNT.DAYCOUNT_ID_TEAM_FB_ASSIST_TIMES then
		self.team_fb_info[type_value] = protocol_value
		self:UpdateTeamFBInfo()
	else
		self.remain_help_times = protocol_value
	end
	self.get_team_fb_info = true
end

function TeamFbData:GetTeamFbCanEnterCount(type_value)
	if TeamCountType[type_value] then
		local join_times = self.join_times_list[TeamCountType[type_value]] or 0
		local enter_count = self.team_fb_info[type_value] or 0
		return join_times - enter_count
	end
	return 0
end

function TeamFbData:UpdateTeamFBInfo()
	for k,v in pairs(self.team_fb_info) do
		local cell_info = {}
		cell_info.remain_times = self.join_times_list[TeamCountType[k]] - v
		self.fuben_cell_info[TeamCountType[k]] = cell_info
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
	if self.reward_item_list[choose] then
		return self.reward_item_list[choose]
	else
		return {}
	end
end

function TeamFbData:GetHelpReward()
	return self.remain_help_times
end


function TeamFbData:SetDefaultChoose(req_team_type)
	self.show_flag = true
	if req_team_type == ScoietyData.InviteOpenType.EquipTeamFbNew then
		self.default_choose = TeamCountType[DAY_COUNT.DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES]
	elseif req_team_type == ScoietyData.InviteOpenType.TeamTowerDefendInvite then
		self.default_choose = TeamCountType[DAY_COUNT.DAYCOUNT_ID_TEAM_TOWERDEFEND_JOIN_TIMES]
	end
end

function TeamFbData:GetDefaultChoose()
	local flag = self.show_flag
	if flag then
		self.show_flag = false
		return self.default_choose or TeamCountType[DAY_COUNT.DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES], true
	else
		return self.default_choose or TeamCountType[DAY_COUNT.DAYCOUNT_ID_EQUIP_TEAM_FB_JOIN_TIMES], false
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
		if v.remain_times > 0 and k ~= TeamCountType[DAY_COUNT.DAYCOUNT_ID_YAOSHOUJITAN_JOIN_TIMES] and vo.level >= open_level_list[k] then
			return true
		end
	end
	return false
end

function TeamFbData:IsFirstEnter(protocol)
	self.team_tower_defend_fb_is_first = protocol.team_tower_defend_fb_is_first    -- 是否第一次组队塔防
    self.team_yaoshoujitan_fb_is_first = protocol.team_yaoshoujitan_fb_is_first    -- 是否第一次组队妖兽祭坛
    self.team_equip_fb_is_first = protocol.team_equip_fb_is_first
    self:InitEnterTimes()
    -- 如果是第一次的话，则对应的副本进入次数增加1
    if self.team_tower_defend_fb_is_first == 1 then
    	self.join_times_list[2] = self.join_times_list[2] + 1
    end
    if self.team_yaoshoujitan_fb_is_first == 1 then
    	self.join_times_list[3] = self.join_times_list[3] + 1
    end
    if self.team_equip_fb_is_first == 1 then
    	self.join_times_list[1] = self.join_times_list[1] + 1
    end

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

--妖兽祭坛部分--




--结束-->>>>>>> .r157626
