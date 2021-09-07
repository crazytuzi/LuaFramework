local TEAMFBTYPE = {
	[1] = FuBenTeamType.TEAM_TYPE_EQUIP_TEAM_FB,
	[2] = FuBenTeamType.TEAM_TYPE_TEAM_TOWERDEFEND,				--组队塔防
	--[3] = FuBenTeamType.TEAM_TYPE_YAOSHOUJITANG,
}

--------- 功能划分 ---------
-- 点击事件
-- 房间列表
-- 房间相关
-- 副本格子
-- 奖励显示

TeamFBContent = TeamFBContent or BaseClass(BaseRender)

function TeamFBContent:__init()

end

function TeamFBContent:LoadCallBack()
	self:ListenEvent("OnClickTeamEnter",
		BindTool.Bind(self.OnClickTeamEnter, self))
	self:ListenEvent("OnClickZuDui",
		BindTool.Bind(self.OnClickZuDui, self))
	self:ListenEvent("OnClickExit",
		BindTool.Bind(self.OnClickExit, self))
	self:ListenEvent("OnClickHelp",
		BindTool.Bind(self.OnClickHelp, self))


	self.is_cap = self:FindVariable("IsCap")
	self.show_team = self:FindVariable("HasTeam")
	self.show_room_list = self:FindVariable("ShowRoomList")
	self.no_room = self:FindVariable("NoRoom")
	self.has_rest_count = self:FindVariable("HasRestCount")
	self.help_reward = self:FindVariable("HelpReward")
	self.is_first_pass =self:FindVariable("IsFirstPass")
	self:InitRoomScroller()

	self:InitTeamRoom()

	self.item_cell_list = self:FindObj("ItemCellList")
	self.item_cell_list_first = self:FindObj("ItemCellList2")

	self.fuben_scroller = self:FindObj("LeftScroller")
	local scroller_delegate = self.fuben_scroller.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetFubenNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.FlushFuBenCellView, self)

	self.fuben_cell_list = {}
	self.default_choose = TeamFbData.Instance:GetDefaultChoose()
	self.cur_choose = self.default_choose
	self.fuben_list_info = TeamFbData.Instance:GetFubenCellInfo()
	self.reward_cell_list = {}
	self.reward_cell_list2 = {}


	TeamFbCtrl.Instance:SetInfoCallBack(BindTool.Bind(self.RemainTimeChanges,self))
	self:RemainTimeChanges()
	-- self:ChangeIndex(self.default_choose)
end

function TeamFBContent:__delete()
	if self.fuben_cell_list and next(self.fuben_cell_list) then 
		for k,v in pairs(self.fuben_cell_list) do
			v:DeleteMe()
		end
		self.fuben_cell_list = {}
	end

	if self.fuben_cell_list and next(self.fuben_cell_list) then 
		for k,v in pairs(self.team_cell_list) do
			v:DeleteMe()
		end
		self.team_cell_list = {}
	end

	if self.reward_cell_list and next(self.reward_cell_list) then 
		for k,v in pairs(self.reward_cell_list) do
			v:DeleteMe()
		end
		self.reward_cell_list = {}
	end

	if self.reward_cell_list2 and next(self.reward_cell_list2) then 
		for k,v in pairs(self.reward_cell_list2) do
			v:DeleteMe()
		end
		self.reward_cell_list2 = {}
	end
end

function TeamFBContent:OnFlush()
	local team_info = FuBenData.Instance:GetTeamFbRoomList()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	self:FlushTeamlist()

	if self:CheckIsNeedShowRoomList() then
		self.show_room_list:SetValue(true)
		self:FlushRoomList()
	else
		self.show_room_list:SetValue(false)
		self:FlushTeamRoom()
	end

	self.has_rest_count:SetValue(self.fuben_list_info[self.cur_choose].remain_times > 0)

	local help_reward_value = TeamFbData.Instance:GetHelpReward()
	local max_help_value = TeamFbData.Instance:GetMaxHelpValue()
	local help_string = ""--string.format(Language.FuBen.TeamFbHelp,help_reward_value,max_help_value)
	self.help_reward:SetValue(help_string)
	if self.fuben_scroller.scroller.isActiveAndEnabled then
		self.fuben_scroller.scroller:ReloadData(0)
	end
end

function TeamFBContent:FlushItemReward()
	local is_fisrt = TeamFbData.Instance:GetIsFirstPass(self.cur_choose)
	self.is_first_pass:SetValue(is_fisrt)
	if is_fisrt then
		self:FlushReward()
	else
		self:FlushReward2()
	end	
end

function TeamFBContent:FlushTeamlist()
	local team_state = ScoietyData.Instance:GetTeamState()
	local is_self_cap = ScoietyData.Instance:MainRoleIsCap()

	self.is_cap:SetValue(is_self_cap)

	if team_state and self:CheckIsTrueType() then
		self.show_team:SetValue(true)
	else
		self.show_team:SetValue(false)
	end
end

function TeamFBContent:OpenCallBack()
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, TEAMFBTYPE[self.cur_choose])
	TeamFbCtrl.Instance:SedReqEquipInfo()
	-- self:Flush()
end

function TeamFBContent:CheckIsNeedShowRoomList()
	local flag = true
	if ScoietyData.Instance:GetTeamState() then
		if self:CheckIsTrueType() then
			flag = false
		end
	end
	return flag
end

function TeamFBContent:CheckIsTrueType()
	local team_info = ScoietyData.Instance:GetTeamInfo() or {}
	local team_type = team_info.team_type or 0
	if team_type == TEAMFBTYPE[self.cur_choose] then
		return true
	end
	return false
end

function TeamFBContent:ChangeIndex(index)
	self.cur_choose = index or self.cur_choose
	if index then
		for k,v in pairs(self.fuben_cell_list) do
			v.toggle.isOn = v.index == index
		end
	end
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, TEAMFBTYPE[self.cur_choose])
	TeamFbCtrl.Instance:SedReqEquipInfo()

	self:OnFlush()
	--self:FlushTeamlist()
end

function TeamFBContent:RemainTimeChanges()
	self.fuben_list_info = TeamFbData.Instance:GetFubenCellInfo()
	for k,v in pairs(self.fuben_cell_list) do
		v:ChangeRemainTimes(self.fuben_list_info[v.index].remain_times)
	end
end

-- 副本格子
function TeamFBContent:GetFubenNumberOfCells()
	return TeamFbData.Instance:GetTeamFBNumber()
end

function TeamFBContent:FlushFuBenCellView(cellObj, cell_index, data_index)
	data_index = data_index + 1
	local cell = self.fuben_cell_list[cellObj]
	if cell == nil then
		self.fuben_cell_list[cellObj] = TeamFBItem.New(cellObj)
		cell = self.fuben_cell_list[cellObj]
		cell.toggle.group = self.fuben_scroller.toggle_group
	end
	cell:SetIndex(data_index)
	local data = self.fuben_list_info[data_index]

	if data then
		cell:SetData(data)
	end
	cell:SetClickCallBack(BindTool.Bind(self.ChangeIndex,self))
	if self.default_choose and data_index == self.default_choose then
		cell.toggle.isOn = true
		self.default_choose = nil
	end
end


----------------------------------------奖励物品相关-----------------------
function TeamFBContent:FlushReward()
	for k,v in pairs(self.reward_cell_list) do
		v:SetItemActive(false)
	end
	local reward_data = TeamFbData.Instance:GetReward(self.cur_choose)
	for i=1,#reward_data do
		if not self.reward_cell_list[i] then
			local cell = ItemCell.New()
			cell:SetInstanceParent(self.item_cell_list)
			cell:SetData(reward_data[i])
			if i == 4 then cell:SetActivityEffect() end
			self.reward_cell_list[i] = cell
		else
			self.reward_cell_list[i]:SetData(reward_data[i])
		end
		if reward_data[i] then
			self.reward_cell_list[i]:SetItemActive(true)
		end
	end
end

function TeamFBContent:FlushReward2()
	for k,v in pairs(self.reward_cell_list2) do
		v:SetItemActive(false)
	end
	local reward_data = TeamFbData.Instance:GetReward(self.cur_choose)
	for i=1,#reward_data + 1 do
		if not self.reward_cell_list2[i] then
			local cell = ItemCell.New()
			cell:SetInstanceParent(self.item_cell_list_first)
			cell:SetData(reward_data[i - 1])
			self.reward_cell_list2[i] = cell
		else
			self.reward_cell_list2[i]:SetData(reward_data[i - 1])
		end
		if reward_data[i - 1] then
			self.reward_cell_list2[i]:SetItemActive(true)
		end
	end
end

----------------------------点击事件相关--------------------
-- 组队进入按钮
function TeamFBContent:OnClickTeamEnter()
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.START_ROOM)
	ViewManager.Instance:Close(ViewName.FuBen)
end

-- 组队（创建房间）
function TeamFBContent:OnClickZuDui()
	if ScoietyData.Instance:GetTeamState() then
		if ScoietyData.Instance:MainRoleIsCap() then
			FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CHANGE_MODE, TEAMFBTYPE[self.cur_choose])
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.NoCap)
		end
	else
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CREATE_ROOM, TEAMFBTYPE[self.cur_choose])
	end
end

-- 退出房间
function TeamFBContent:OnClickExit()
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.EXIT_ROOM)
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, TEAMFBTYPE[self.cur_choose])
end

-- 点击邀请
function TeamFBContent:OnClickInvite()
	if self.cur_choose == 1 then
		TipsCtrl.Instance:ShowInviteView(ScoietyData.InviteOpenType.EquipTeamFbNew)
	elseif self.cur_choose == 2 then
		TipsCtrl.Instance:ShowInviteView(ScoietyData.InviteOpenType.TeamTowerDefendInvite)
	elseif self.cur_choose == 3 then
		TipsCtrl.Instance:ShowInviteView(ScoietyData.InviteOpenType.TeamYaoshouInvite)
	end
end

-- 踢出
function TeamFBContent:OnClickKickOut(name, role_id)
	if ScoietyData.Instance:MainRoleIsCap() then
		local des = string.format(Language.Society.KickOutTeam, name)
		local ok_callback = function() FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.KICK_OUT, role_id) end
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
	end
end

-- 点击头像
function TeamFBContent:OnClickHead(name, role_id, click_obj)
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		return
	end
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, name)
end

function TeamFBContent:OnSkillClick(name, id, pos)
	local is_self_cap = ScoietyData.Instance:MainRoleIsCap()
	if is_self_cap	then
		-- if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		-- 	return
		-- end
		-- ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, name)
		TeamFbData.Instance:SendID(id)
		TeamFbData.Instance:SendPos(pos)
		ViewManager.Instance:Open(ViewName.TowerSelectView)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.CantSelectSkill)
	end
end

function TeamFBContent:OnClickHelp()
	local tips_list = {[1] = 245,[3] = 246, [2] = 247}
	TipsCtrl.Instance:ShowHelpTipView(tips_list[self.cur_choose])
end

----------------------------------------房间列表---------------------------------------------------

--初始化滚动条
function TeamFBContent:InitRoomScroller()
	self.team_scroller = self:FindObj("TeamScroller")
	self.team_cell_list = {}
	self.room_list_info = FuBenData.Instance:GetTeamFbRoomList()

	local scroller_delegate = self.team_scroller.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoomNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.GetRoomCellView, self)
end

--滚动条数量
function TeamFBContent:GetRoomNumberOfCells()
	return self.room_list_info.count or 0
end

--滚动条刷新
function TeamFBContent:GetRoomCellView(cellObj, data_index)
	local cell = self.team_cell_list[cellObj]
	if cell == nil then
		self.team_cell_list[cellObj] = KuaFuFuBenRoomScrollCell.New(cellObj)
		cell = self.team_cell_list[cellObj]
	end
	cell:SetIndex(data_index)
	cell:SetTeamType(TEAMFBTYPE[self.cur_choose])
	local data = self.room_list_info.room_list[data_index + 1]
	if data then
		cell:SetData(data)
	end
end

function TeamFBContent:FlushRoomList()
	self.room_list_info = FuBenData.Instance:GetTeamFbRoomList()
	self.no_room:SetValue(self.room_list_info.count <= 0)
	if self.team_scroller.scroller.isActiveAndEnabled then
		self.team_scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

--------------------------------------- 房间信息 ----------------------------------------------
function TeamFBContent:InitTeamRoom()
	self.cap_info = {}
	self.cap_info.obj = self:FindObj("CaptainrInfo")
	local variable_table = self.cap_info.obj:GetComponent(typeof(UIVariableTable))
	self.cap_info.head = variable_table:FindVariable("Head")
	self.cap_info.name = variable_table:FindVariable("Name")
	self.cap_info.fp = variable_table:FindVariable("FightPower")
	self.cap_info.is_online = variable_table:FindVariable("IsOnline")
	self.cap_info.room_number = variable_table:FindVariable("room_number")
	self.cap_info.skill = variable_table:FindVariable("Skill_number")
	self.cap_info.skill:SetValue(4)

	local name_table = self.cap_info.obj:GetComponent(typeof(UINameTable))
	self.cap_info.portrait = U3DObject(name_table:Find("portrait"))
	self.cap_info.portrait_raw = U3DObject(name_table:Find("portrait_raw"))
	self.cap_info.event_table = self.cap_info.obj:GetComponent(typeof(UIEventTable))
	self.cap_info.click_obj = U3DObject(name_table:Find("ClickObj"))

	self.teammates = {}
	for i = 1, 2 do
		self.teammates[i] = {}
		self.teammates[i].obj = self:FindObj("MemberInfo" .. i)

		variable_table = self.teammates[i].obj:GetComponent(typeof(UIVariableTable))
		self.teammates[i].head = variable_table:FindVariable("Head")
		self.teammates[i].name = variable_table:FindVariable("Name")
		self.teammates[i].fp = variable_table:FindVariable("FightPower")
		self.teammates[i].show_member_info = variable_table:FindVariable("ShowMemberInfo")
		self.teammates[i].show_kick_out = variable_table:FindVariable("ShowKickOut")
		self.teammates[i].has_prepare = variable_table:FindVariable("HasPrepare")
		self.teammates[i].is_online = variable_table:FindVariable("IsOnline")
		self.teammates[i].is_player = variable_table:FindVariable("IsPlayer")
		self.teammates[i].room_number = variable_table:FindVariable("room_number")
		self.teammates[i].skill = variable_table:FindVariable("Skill_number")
		self.teammates[i].skill:SetValue(4)
		name_table = self.teammates[i].obj:GetComponent(typeof(UINameTable))
		self.teammates[i].portrait = U3DObject(name_table:Find("portrait"))
		self.teammates[i].portrait_raw = U3DObject(name_table:Find("portrait_raw"))

		self.teammates[i].event_table = self.teammates[i].obj:GetComponent(typeof(UIEventTable))
		self.teammates[i].event_table:ListenEvent("OnClickInvite", BindTool.Bind(self.OnClickInvite, self, i))
	end
end

function TeamFBContent:FlushTeamRoom()
	self.cap_info.room_number:SetValue(self.cur_choose)
	for i = 1, 2 do
		self.teammates[i].show_member_info:SetValue(false)
		self.teammates[i].room_number:SetValue(self.cur_choose)
	end
	local info = ScoietyData.Instance:GetTeamInfo()
	if info then
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		local i = 1
		local player_info = TeamFbData.Instance:GetTeamTowerDefendInfo()
		for k,v in pairs(info.team_member_list) do
			local teammate_info = v
			if teammate_info and self.teammates[i] then
				-- 如果是队员
				if not ScoietyData.Instance:IsLeaderById(teammate_info.role_id) then
					if nil ~= player_info then
						if nil ~= player_info[teammate_info.role_id] then
							self.teammates[i].skill:SetValue(player_info[teammate_info.role_id].attr_type)
						end
					end
					self.teammates[i].show_member_info:SetValue(true)
					self.teammates[i].name:SetValue(teammate_info.name)
					self.teammates[i].fp:SetValue(teammate_info.capability)

					self.teammates[i].is_online:SetValue(teammate_info.is_online == 1)
					-- 设置头像
					CommonDataManager.SetAvatar(teammate_info.role_id, self.teammates[i].portrait_raw, self.teammates[i].portrait, self.teammates[i].head, teammate_info.sex, teammate_info.prof, false)

					self.teammates[i].event_table:ClearEvent("OnClickKickOut")
					self.teammates[i].event_table:ListenEvent("OnClickKickOut", BindTool.Bind(self.OnClickKickOut, self,
					teammate_info.name, teammate_info.role_id))

					self.teammates[i].event_table:ClearEvent("OnClickHead")
					self.teammates[i].event_table:ListenEvent("OnClickHead", BindTool.Bind(self.OnClickHead, self,
					teammate_info.name, teammate_info.role_id))
					self.teammates[i].event_table:ClearEvent("SkillClick")
					self.teammates[i].event_table:ListenEvent("SkillClick", BindTool.Bind(self.OnSkillClick, self,
					teammate_info.name, teammate_info.role_id,self.teammates[i].obj.transform.position))

					if ScoietyData.Instance:MainRoleIsCap() then
						self.teammates[i].show_kick_out:SetValue(true)
					else
						self.teammates[i].show_kick_out:SetValue(false)
					end

					if teammate_info.role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
						self.teammates[i].is_player:SetValue(true)
					else
						self.teammates[i].is_player:SetValue(false)
					end
					i = i + 1
				end
			end
		end
		local leader_index = ScoietyData.Instance:GetTeamLeaderIndex() or 0
		leader_index = leader_index + 1
		local cap_info = info.team_member_list[leader_index]
		if cap_info then
			if nil ~= player_info then
				if nil ~= player_info[cap_info.role_id] then
					self.cap_info.skill:SetValue(player_info[cap_info.role_id].attr_type)
				end
			end
			self.cap_info.name:SetValue(cap_info.name)
			self.cap_info.fp:SetValue(cap_info.capability)
			-- 设置头像
			local prof = PlayerData.Instance:GetRoleBaseProf(cap_info.prof)
			local image = self.cap_info.portrait
			local raw_image = self.cap_info.portrait_raw
			local image_res = self.cap_info.head
			CommonDataManager.SetAvatar(cap_info.role_id, raw_image, image, image_res, cap_info.sex, prof, true)
			self.cap_info.is_online:SetValue(cap_info.is_online == 1)

			self.cap_info.event_table:ClearEvent("OnClickHead")
			self.cap_info.event_table:ListenEvent("OnClickHead", BindTool.Bind(self.OnClickHead, self,
			cap_info.name, cap_info.role_id, self.cap_info.click_obj))
			self.cap_info.event_table:ClearEvent("SkillClick")
			self.cap_info.event_table:ListenEvent("SkillClick", BindTool.Bind(self.OnSkillClick, self,
			cap_info.name, cap_info.role_id, self.cap_info.obj.transform.position))
		end
		TeamFbData.Instance:SendPos(self.cap_info.obj.transform.position)
		TeamFbCtrl.Instance:OnFlushTeamFBContent()
	end
end

----------------副本格子------------
TeamFBItem = TeamFBItem or BaseClass(BaseCell)

function TeamFBItem:__init()
	self.toggle = self.root_node.toggle
	self.image = self:FindVariable("image")
	self.remain_times = self:FindVariable("remain_times")
	self.fb_name = self:FindVariable("fb_name")
	self.is_open = self:FindVariable("is_open")
	self:ListenEvent("onclick",BindTool.Bind(self.OnClick,self))
	self.limit_level = self:FindVariable("limit_level")
	self.story_desc = self:FindVariable("story")
	self.is_open_value = true
end

function TeamFBItem:__delete()

end

function TeamFBItem:OnFlush()
	self.image:SetAsset(ResPath.GetRawImage("team_fb_0" .. self.index, false))
	self.fb_name:SetValue(Language.FuBen.TeamFbName[self.index])
	if self.data then
		self:ChangeRemainTimes(self.data.remain_times)
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local open_level = TeamFbData.Instance:GetOpenList()[self.index]
	if open_level then
		if vo.level >= open_level then
			self.is_open_value = true
			self.is_open:SetValue(true)
			self.toggle.interactable = true
		else
			self.is_open_value = false
			self.toggle.interactable = false
			self.is_open:SetValue(false)
			local limit_level = PlayerData.GetLevelString(open_level,false)
			self.limit_level:SetValue(string.format(Language.FuBen.TeamFbOpen, limit_level))
		end
	end
	local story_desc = TeamFbData.Instance:GetDesc()[self.index]
	self.story_desc:SetValue(story_desc)
end

function TeamFBItem:ChangeRemainTimes(remain_times)
	if remain_times < 0 then
		remain_times = 0
	end
	self.remain_times_value = remain_times
	local remain_string = string.format(Language.FuBen.TeamFbRemainTimes, self.remain_times_value)
	self.remain_times:SetValue(remain_string)
end

function TeamFBItem:SetClickCallBack(click_callback)
	self.click_callback = click_callback
end

function TeamFBItem:OnClick()
	if self.click_callback and self.is_open_value then
		self.click_callback(self.index)
	end
end