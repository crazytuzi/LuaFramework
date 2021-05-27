------------------------------------------------------------
-- 组队数据
------------------------------------------------------------

TeamData = TeamData or BaseClass()

TeamData.MaxMemberCount = 20

--队伍的物品的分配方法
TeamItemAssignMethod = 
{
	TeamItemStyleTeam = 1,    	-- 队伍拾取
	TeamIteamStyleRotate = 2,  	-- 轮流拾取
	TeamIteamStyleFree = 3,  	-- 自由拾取
	TeamItemStyleCaptin = 4, 	-- 队长分配
};


-- 数据改变监听
TeamData.TEAM_INFO_CHANGE = "team_info_change"
TeamData.APPLY_LIST_CHANGE = "apply_list_change"
TeamData.INVITE_LIST_CHANGE = "invite_list_change"


function TeamData:__init()
	if TeamData.Instance then
		ErrorLog("[TeamData]:Attempt to create singleton twice!")
	end

	TeamData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.member_list = {}
	self.team_info = self.InitTeamInfo()
	self.pick_up_mode = 0
	self.item_pickup_lv = 0
	self.team_invite_list = {}
	self.team_apply_list = {}
	self.near_team_list = {}

	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.TeamApply)
end

function TeamData:__delete()
	TeamData.Instance = nil
end

function TeamData.InitTeamInfo()
	return {
		mode = 0,
		member_list = {},
		leader_id = 0,
		item_lv_limit = 0,
		team_id = 0,
		fb_id = 0,
		team_state = 0,
	}
end

function TeamData:SetTeamInfo(protocol)
	self.team_info.mode = protocol.mode
	self.team_info.leader_id = protocol.leader_id
	self.team_info.member_list = protocol.teammate_list
	if #self.team_info.member_list > 0 then
		self.team_invite_list = {}
	else
		self.team_apply_list = {}
	end
	self.team_info.item_lv_limit = protocol.item_lv_limit
	self.team_info.team_id = protocol.team_id
	self.team_info.fb_id = protocol.fb_id
	self.team_info.team_state = protocol.team_state
	self:SortTeamMember()
end

function TeamData:AddTeammate(protocol)
	local add_key = nil
	for k,v in pairs(self.team_info.member_list) do
		if v.role_id == protocol.member_info.role_id then
			add_key = k
		end
	end
	if add_key then
		self.team_info.member_list[add_key] = protocol.member_info
	else
		table.insert(self.team_info.member_list, protocol.member_info)
	end
	self:SortTeamMember()
end

function TeamData:RemoveTeammate(protocol)
	if protocol.role_id == RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID) then
		self.team_info = self.InitTeamInfo()
		self.team_apply_list = {}
		self:DispatchEvent(TeamData.TEAM_INFO_CHANGE)
		return
	end
	local remove_k = 0
	for k,v in pairs(self.team_info.member_list) do
		if v.role_id == protocol.role_id then
			remove_k = k
		end
	end
	if remove_k > 0 then
		table.remove(self.team_info.member_list, remove_k)
	end

	self:DispatchEvent(TeamData.TEAM_INFO_CHANGE)
end

function TeamData:GetTeamInfo()
	return self.team_info
end

function TeamData:GetMemberList()
	return self.team_info.member_list
end

function TeamData:SetLeaderId(protocol)
	self.team_info.leader_id = protocol.leader_id
	self:SortTeamMember()
end

function TeamData:GetLeaderId()
	return self.team_info.leader_id
end

function TeamData:IsLeader(role_id)
	role_id = role_id or RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID)
	return self.team_info.leader_id == role_id
end

function TeamData:HasTeam()
	return #self.team_info.member_list > 0
end

function TeamData:SetPickUpMode(mode)
	self.pick_up_mode = mode
end

function TeamData:GetPickUpMode()
	return self.pick_up_mode
end

function TeamData:SetPickUpItemLv(item_pickup_lv)
	self.item_pickup_lv = item_pickup_lv
end

function TeamData:GetPickUpItemLv()
	return self.item_pickup_lv
end

function TeamData:SetTeammateOutLine(role_id)
	for k,v in pairs(self.team_info.member_list) do
		if v.role_id == role_id then
			v.is_online = 0
		end
	end
	self:SortTeamMember()
end

-- 排序队伍
function TeamData:SortTeamMember()
	for k,v in pairs(self.team_info.member_list) do
		v.is_alive = v.is_alive or 1
		v.is_online = v.is_online or 1
	end
	table.sort(self.team_info.member_list, self:TeammemberSortTool())

	self:DispatchEvent(TeamData.TEAM_INFO_CHANGE)
end

function TeamData:TeammemberSortTool()
	return function (a, b)
		local order_a = 10000
		local order_b = 10000
		if self:IsLeader(a.role_id) then
			order_a = order_a + 1000
		elseif self:IsLeader(b.role_id) then
			order_b = order_b + 1000
		end
		local main_role = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID)
		if a.role_id == main_role then
			order_a = order_a + 100
		elseif b.role_id == main_role then
			order_b = order_b + 100
		end
		-- if a.is_online == 1 or a.is_alive == 1 then
		-- 	order_a = order_a + 10
		-- elseif a.is_online == 1 or a.is_alive == 1 then
		-- 	order_b = order_b + 10
		-- end
		return order_a > order_b
	end
end

function TeamData:AddTeamInvite(protocol)
	for k,v in pairs(self.team_invite_list) do
		if v.role_id == protocol.invite_info.role_id then
			return
		end
	end
	table.insert(self.team_invite_list, protocol.invite_info)
	self:DispatchEvent(TeamData.INVITE_LIST_CHANGE)
	RemindManager.Instance:DoRemind(RemindName.TeamApply)
end

function TeamData:DeleteOneInvite(role_name)
	if "all" == role_name then
		self.team_invite_list = {}
		self:DispatchEvent(TeamData.INVITE_LIST_CHANGE)
		RemindManager.Instance:DoRemind(RemindName.TeamApply)
		return
	end
	local del_key = nil
	for k,v in pairs(self.team_invite_list) do
		if v.name == role_name then
			del_key = k
		end
	end
	if del_key then
		table.remove(self.team_invite_list, del_key)
	end
	self:DispatchEvent(TeamData.INVITE_LIST_CHANGE)
	RemindManager.Instance:DoRemind(RemindName.TeamApply)
end

function TeamData:GetTeamInivteList()
	return self.team_invite_list
end

function TeamData:AddTeamApply(protocol)
	for k,v in pairs(self.team_apply_list) do
		if v.role_id == protocol.apply_info.role_id then
			return
		end
	end
	table.insert(self.team_apply_list, protocol.apply_info)
	self:DispatchEvent(TeamData.APPLY_LIST_CHANGE)
	RemindManager.Instance:DoRemind(RemindName.TeamApply)
end

function TeamData:DeleteOneApply(role_id)
	if role_id == "all" then
		self.team_apply_list = {}
		self:DispatchEvent(TeamData.APPLY_LIST_CHANGE)
		RemindManager.Instance:DoRemind(RemindName.TeamApply)
		return
	end
	local del_key = nil
	for k,v in pairs(self.team_apply_list) do
		if v.role_id == role_id then
			del_key = k
		end
	end
	if del_key then
		table.remove(self.team_apply_list, del_key)
	end
	self:DispatchEvent(TeamData.APPLY_LIST_CHANGE)
	RemindManager.Instance:DoRemind(RemindName.TeamApply)
end

function TeamData:GetTeamApplyList()
	return self.team_apply_list
end

function TeamData:SetTeammateDie(protocol)
	for k,v in pairs(self.team_info.member_list) do
		if v.role_id == protocol.role_id then
			v.is_alive = protocol.die_or_relive
		end
	end
end

function TeamData:SetTeammatePosInfo(protocol)
	for k,v in pairs(self.team_info.member_list) do
		if v.role_id == protocol.role_id then
			local vo = {}
			vo.role_id = protocol.role_id
			vo.scene_id = protocol.scene_id
			vo.x = protocol.x
			vo.y = protocol.y
			vo.is_out_exp_range = protocol.is_out_exp_range
			v.pos_info = vo
		end
	end

	self:DispatchEvent(TeamData.TEAM_INFO_CHANGE)
	RemindManager.Instance:DoRemind(RemindName.TeamApply)
end

function TeamData:GetTeammatePosInfo(role_id)
	for k,v in pairs(self.team_info.member_list) do
		if v.role_id == protocol.role_id then
			return v.pos_info
		end
	end
	return nil
end

function TeamData:SetNearTeamList(protocol)
	self.near_team_list = protocol.team_list
	self:DispatchEvent(TeamData.TEAM_INFO_CHANGE)
end

function TeamData:GetNearTeamList()
	return self.near_team_list
end

function TeamData.GetOrganizeType()
	if SettingData.Instance:GetOneSysSetting(SETTING_TYPE.REFUSE_JOIN_TEAM) then
		return 2
	elseif SettingData.Instance:GetOneSysSetting(SETTING_TYPE.AUTO_JOIN_TEAM) then
		return 0
	else
		return 1
	end
end

function TeamData.SetOrganizeType(type)
	if type == 0 then
		SettingCtrl.Instance:ChangeSetting({[SETTING_TYPE.AUTO_JOIN_TEAM] = true, [SETTING_TYPE.REFUSE_JOIN_TEAM] = false})
	elseif type == 1 then
		SettingCtrl.Instance:ChangeSetting({[SETTING_TYPE.AUTO_JOIN_TEAM] = false, [SETTING_TYPE.REFUSE_JOIN_TEAM] = false})
	elseif type == 2 then
		SettingCtrl.Instance:ChangeSetting({[SETTING_TYPE.AUTO_JOIN_TEAM] = false, [SETTING_TYPE.REFUSE_JOIN_TEAM] = true})
	end
end

----------选择数据----------

-- 设置选择数据
function TeamData:SetSelectData(data)
	self.select_data = data
end

-- 重置选择数据
function TeamData:ResetSelectData()
	self.select_data = {}
end

-- 获取选择数据
function TeamData:GetSelectData()
	return self.select_data
end

----------end----------

-- 获取提醒显示索引 0不显示红点, 1显示红点
function TeamData:GetRemindIndex()
	local list = TeamData.Instance:GetTeamApplyList()
	local invite_list = TeamData.Instance:GetTeamInivteList()
	local index = nil ~= list[1] and 1 or 0
	local invite_index = nil ~= invite_list[1] and 1 or 0
	if index == 0 and invite_index == 0 then
		return 0
	else
		return 1
	end
end