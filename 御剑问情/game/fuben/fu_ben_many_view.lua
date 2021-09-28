ManyFuBenView = ManyFuBenView or BaseClass(BaseRender)

function ManyFuBenView:__init(instance)
	if instance == nil then
		return
	end

	self.item_cell = {}
	for i = 1, 5 do
		self.item_cell[i] = {}
		self.item_cell[i].obj = self:FindObj("ItemCell" .. i)
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
	end
	self.has_team = self:FindVariable("HasTeam")
	self.is_cap = self:FindVariable("IsCap")
	self.reward_count = self:FindVariable("RewardCount")
	self.no_room = self:FindVariable("NoRoom")
	self.show_room_list = self:FindVariable("ShowRoomList")
	self.select_fb = 0
	self.last_select_fb = -1

	self:ListenEvent("OnClickStart",
		BindTool.Bind(self.OnClickStart, self))
	self:ListenEvent("OnClickExit",
		BindTool.Bind(self.OnClickExit, self))
	self:ListenEvent("OnClickHelp",
		BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickZuDui",
		BindTool.Bind(self.OnClickZuDui, self))
	self:ListenEvent("OnClickPlus",
		BindTool.Bind(self.OnClickPlus, self))

	self:InitTeamRoom()
	self:InitInfoScroller()
	self:InitRoomScroller()
end

function ManyFuBenView:__delete()
	for k,v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
			v.cell = nil
		end
	end
	self.item_cell = {}

	for k, v in pairs(self.info_cell_list) do
		v:DeleteMe()
	end
	for k, v in pairs(self.team_cell_list) do
		v:DeleteMe()
	end
	self.info_cell_list = {}
	self.team_cell_list = {}
	self.teammates = {}
	self:RemoveDelayTime()
end

function ManyFuBenView:OpenCallBack()
	self.select_fb = self:FindFB()
	self:Flush()
	if self:CheckIsNeedShowRoomList() then
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB, 0, self.select_fb)
	end
end

function ManyFuBenView:JumpToIndex(index)
	if self.scroller.scroller.isActiveAndEnabled then
		local jump_index = index
		local scrollerOffset = 0
		local cellOffset = 0
		local useSpacing = false
		local scrollerTweenType = self.scroller.scroller.snapTweenType
		local scrollerTweenTime = 0
		local scroll_complete = nil
		self.scroller.scroller:JumpToDataIndexForce(
			jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
	else
		self:RemoveDelayTime()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:JumpToIndex(index) end, 0.1)
	end
end

function ManyFuBenView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function ManyFuBenView:OnClickStart()
	if ScoietyData.Instance:MainRoleIsCap() then
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.START_ROOM)
	end
end

function ManyFuBenView:OnClickExit()
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.EXIT_ROOM)
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB, 0, self.select_fb)
end

function ManyFuBenView:OnClickKickOut(name, role_id)
	if ScoietyData.Instance:MainRoleIsCap() then
		local des = string.format(Language.Society.KickOutTeam, name)
		local ok_callback = function() FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.KICK_OUT, role_id) end
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
	end
end

function ManyFuBenView:OnClickHead(name, role_id)
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		return
	end
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, name)
end

function ManyFuBenView:OnClickInvite()
	local config = FuBenData.Instance:GetShowConfigByLayer(self.select_fb)
	local name = ""
	if config then
		name = config.name
	end
	local team_index = ScoietyData.Instance:GetTeamIndex()
	if team_index then
		FuBenData.Instance:SetSelectFuBenLayer(self.select_fb)
		TipsCtrl.Instance:ShowInviteView(ScoietyData.InviteOpenType.ManyFuBen)
	end
end

function ManyFuBenView:OnClickFuBen(layer)
	self.select_fb = layer
	if self:CheckIsNeedShowRoomList() then
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB, 0, self.select_fb)
	end
	self:Flush()
end

function ManyFuBenView:Flush()
	local is_self_cap = ScoietyData.Instance:MainRoleIsCap()
	self.is_cap:SetValue(is_self_cap)
	if ScoietyData.Instance:GetTeamState() and self:CheckIsTeamEquipType() then
		self.has_team:SetValue(true)
	else
		self.has_team:SetValue(false)
	end
	if self:CheckIsNeedShowRoomList() then
		self.show_room_list:SetValue(true)
		self:FlushRoomList()
	else
		self.show_room_list:SetValue(false)
		self:FlushTeamRoom()
		if self.scroller.scroller.isActiveAndEnabled then
			for k,v in pairs(self.info_cell_list) do
				v:Flush()
			end
		end
	end
	self:FlushReward()
	local team_equip_fb_day_count = FuBenData.Instance:GetManyFBCount() or 0
	local total_count = FuBenData.Instance:GetManyFbTotalCount() or 0
	local rest_count = math.max(total_count - team_equip_fb_day_count, 0)
	if rest_count > 0 then
		self.reward_count:SetValue(rest_count .. "/" .. total_count)
	else
		self.reward_count:SetValue(ToColorStr(rest_count, TEXT_COLOR.RED) .. "/" .. total_count)
	end
end

function ManyFuBenView:FlushReward()
	if self.last_select_fb ~= self.select_fb then
		self.last_select_fb = self.select_fb
		local config = FuBenData.Instance:GetShowConfigByLayer(self.select_fb)
		if config then
			local reward_config = config.probability_falling
			for i = 1, 5 do
				local item = reward_config[i]
				self.item_cell[i].cell:SetParentActive(nil ~= item)
				if item then
					self.item_cell[i].cell:SetData(item)
					self.item_cell[i].cell:SetInteractable(true)
				end
			end
		end
	end
end

function ManyFuBenView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(130)
end

function ManyFuBenView:OnClickZuDui()
	if ScoietyData.Instance:GetTeamState() then
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CHANGE_MODE, FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB, 0, self.select_fb)
	else
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CREATE_ROOM, FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB, 0, 0, self.select_fb, 0)
	end
end

function ManyFuBenView:OnClickPlus()
	local price = FuBenData.Instance:GetManyFbPrice() or 0
	local des = string.format(Language.FuBen.BuyManyFB, price)
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level or 0
	local buy_count = FuBenData.Instance:GetManyFbBuyCount() or 0
	local can_buy_count = FuBenData.Instance:GetManyFbBuyCountByVip(vip_level) or 0
	local max_can_buy_count = FuBenData.Instance:GetManyFbBuyCountByVip(15) or 0
	if can_buy_count <= buy_count then
		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.TEAM_EQUIP_COUNT)
		return
	end
	if buy_count >= max_can_buy_count then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.MaxManyFB)
		return
	end
	local ok_callback = function()
		FuBenCtrl.Instance:SendTeamEquipFbBuyDropCountReq()
	end

	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
end

-- 找到合适等级的副本
function ManyFuBenView:FindFB()
	local main_role_level = GameVoManager.Instance:GetMainRoleVo().level
	local layer = 0
	for i = FuBenData.Instance:GetCrossFBCount(), 1, -1 do
		local cfg = FuBenData.Instance:GetConfigByLayer(i) or {}
		if cfg and next(cfg) then
			if cfg.level_limit <= main_role_level then
				layer = cfg.layer
				break
			end
		end
	end
	if ScoietyData.Instance:GetTeamState() then
		local team_info = ScoietyData.Instance:GetTeamInfo()
		local team_layer = team_info.teamfb_layer or 0
		local team_type = team_info.team_type or 0
		if team_type == FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB then
			layer = math.min(layer, team_layer)
		end
	end
	return layer
end

-- 是否需要显示房间列表
function ManyFuBenView:CheckIsNeedShowRoomList()
	local flag = true
	if ScoietyData.Instance:GetTeamState() then
		if self:CheckIsTeamEquipType() then
			flag = false
		end
	end
	return flag
end

-- 队伍是否是组队副本类型
function ManyFuBenView:CheckIsTeamEquipType()
	local team_info = ScoietyData.Instance:GetTeamInfo() or {}
	local team_type = team_info.team_type or 0
	if team_type == FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB then
		return true
	end
	return false
end

--------------------------------------- 房间信息 ----------------------------------------------

function ManyFuBenView:InitTeamRoom()
	self.cap_info = {}
	self.cap_info.obj = self:FindObj("CaptainrInfo")
	local variable_table = self.cap_info.obj:GetComponent(typeof(UIVariableTable))
	self.cap_info.head = variable_table:FindVariable("Head")
	self.cap_info.name = variable_table:FindVariable("Name")
	self.cap_info.fp = variable_table:FindVariable("FightPower")
	self.cap_info.is_online = variable_table:FindVariable("IsOnline")

	local name_table = self.cap_info.obj:GetComponent(typeof(UINameTable))
	self.cap_info.portrait = U3DObject(name_table:Find("portrait"))
	self.cap_info.portrait_raw = U3DObject(name_table:Find("portrait_raw"))
	self.cap_info.event_table = self.cap_info.obj:GetComponent(typeof(UIEventTable))

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

		name_table = self.teammates[i].obj:GetComponent(typeof(UINameTable))
		self.teammates[i].portrait = U3DObject(name_table:Find("portrait"))
		self.teammates[i].portrait_raw = U3DObject(name_table:Find("portrait_raw"))

		self.teammates[i].event_table = self.teammates[i].obj:GetComponent(typeof(UIEventTable))
		self.teammates[i].event_table:ListenEvent("OnClickInvite", BindTool.Bind(self.OnClickInvite, self, i))
	end
end

function ManyFuBenView:FlushTeamRoom()
	for i = 1, 2 do
		self.teammates[i].show_member_info:SetValue(false)
	end
	local info = ScoietyData.Instance:GetTeamInfo()
	if info then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local main_role_id = vo.role_id
		local i = 1
		for k,v in pairs(info.team_member_list) do
			local teammate_info = v
			if teammate_info and self.teammates[i] then
				-- 如果是队员
				if not ScoietyData.Instance:IsLeaderById(teammate_info.role_id) then
					self.teammates[i].show_member_info:SetValue(true)
					self.teammates[i].name:SetValue(teammate_info.name)
					self.teammates[i].fp:SetValue(teammate_info.capability)
					self.teammates[i].is_online:SetValue(teammate_info.is_online == 1)
					-- 设置头像
					CommonDataManager.SetAvatar(vo.role_id, self.teammates[i].portrait_raw, self.teammates[i].portrait, self.teammates[i].head, vo.sex, vo.prof, true)

					self.teammates[i].event_table:ClearEvent("OnClickKickOut")
					self.teammates[i].event_table:ListenEvent("OnClickKickOut", BindTool.Bind(self.OnClickKickOut, self,
					teammate_info.name, teammate_info.role_id))

					self.teammates[i].event_table:ClearEvent("OnClickHead")
					self.teammates[i].event_table:ListenEvent("OnClickHead", BindTool.Bind(self.OnClickHead, self,
					teammate_info.name, teammate_info.role_id))

					if ScoietyData.Instance:MainRoleIsCap() then
						self.teammates[i].show_kick_out:SetValue(true)
					else
						self.teammates[i].show_kick_out:SetValue(false)
					end
					i = i + 1
				end
			end
		end
		local leader_index = ScoietyData.Instance:GetTeamLeaderIndex() or 0
		leader_index = leader_index + 1
		local cap_info = info.team_member_list[leader_index]
		if cap_info then
			self.cap_info.name:SetValue(cap_info.name)
			self.cap_info.fp:SetValue(cap_info.capability)
			-- 设置头像
			CommonDataManager.SetAvatar(cap_info.role_id, self.cap_info.portrait_raw, self.cap_info.portrait, self.cap_info.head, cap_info.sex, cap_info.prof, true)
		end
	end
end

----------------------------------------InitInfoScroller---------------------------------------------------

--初始化滚动条
function ManyFuBenView:InitInfoScroller()
	self.scroller = self:FindObj("Scroller")
	self.toggle_group = self.scroller:GetComponent("ToggleGroup")
	self.info_cell_list = {}
	local scroller_delegate = self.scroller.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.GetCellView, self)
	self.scroller_is_load = false
end

--滚动条数量
function ManyFuBenView:GetNumberOfCells()
	return FuBenData.Instance:GetCrossFBCount()
end

--滚动条刷新
function ManyFuBenView:GetCellView(cellObj, data_index)
	local cell = self.info_cell_list[cellObj]
	if cell == nil then
		self.info_cell_list[cellObj] = KuaFuFuBenScrollCell.New(cellObj)
		cell = self.info_cell_list[cellObj]
		cell:ListenAllEvent(self)
		cell:SetToggleGroup(self.toggle_group)
	end
	local config = FuBenData.Instance:GetShowConfigByLayer(data_index)
	if config then
		cell:SetIndex(data_index)
		cell:SetData(config)
	end
	if not self.scroller_is_load and FuBenData.Instance:GetCrossFBCount() > 3 and self.scroller.scroller.isActiveAndEnabled then
		self.scroller_is_load = true
		GlobalTimerQuest:AddDelayTimer(function() self:JumpToIndex(self.select_fb) end, 0)
	end
end

--------------------------------------- 动态生成副本信息 ----------------------------------------------
KuaFuFuBenScrollCell = KuaFuFuBenScrollCell or BaseClass(BaseCell)

function KuaFuFuBenScrollCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)

	self.name = self:FindVariable("Name")
	self.bg = self:FindVariable("Bg")
	self.level = self:FindVariable("Level")
	self.count = self:FindVariable("Count")
	self.show_level = self:FindVariable("ShowLevel")
	self.show_hl = self:FindVariable("ShowHighLight")
end

function KuaFuFuBenScrollCell:__delete()

end

function KuaFuFuBenScrollCell:OnFlush()
	self.name:SetValue(self.data.name)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if level < self.data.level then
		self.show_level:SetValue(true)
		local lv = PlayerData.GetLevelString(self.data.level)
  		self.level:SetValue(lv)
	else
		self.show_level:SetValue(false)
	end
	local bundle, asset = ResPath.CrossFBIcon(self.data.image_id)
	self.bg:SetAsset(bundle, asset)
	if self.handle.select_fb == self.index then
		self.root_node.toggle.isOn = true
	else
		if self.root_node.toggle.isOn then
			self.show_hl:SetValue(true)
			GlobalTimerQuest:AddDelayTimer(function() self.show_hl:SetValue(false) end, 0)
		end
		self.root_node.toggle.isOn = false
	end
end

function KuaFuFuBenScrollCell:ListenAllEvent(handle)
	self.handle = handle
	self:ListenEvent("OnClick", function() handle:OnClickFuBen(self.index) end)
end

function KuaFuFuBenScrollCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

----------------------------------------InitRoomScroller---------------------------------------------------

--初始化滚动条
function ManyFuBenView:InitRoomScroller()
	self.team_scroller = self:FindObj("TeamScroller")
	self.team_cell_list = {}
	self.room_list_info = FuBenData.Instance:GetTeamFbRoomList()
	local scroller_delegate = self.team_scroller.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoomNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.GetRoomCellView, self)
end

--滚动条数量
function ManyFuBenView:GetRoomNumberOfCells()
	return self.room_list_info.count or 0
end

--滚动条刷新
function ManyFuBenView:GetRoomCellView(cellObj, data_index)
	local cell = self.team_cell_list[cellObj]
	if cell == nil then
		self.team_cell_list[cellObj] = KuaFuFuBenRoomScrollCell.New(cellObj)
		cell = self.team_cell_list[cellObj]
	end
	cell:SetIndex(data_index)
	cell:SetTeamType(FuBenTeamType.TEAM_TYPE_TEAM_EQUIP_FB)
	local data = self.room_list_info.room_list[data_index + 1]
	if data then
		cell:SetData(data)
	end
end

function ManyFuBenView:FlushRoomList()
	self.room_list_info = FuBenData.Instance:GetTeamFbRoomList()
	self.no_room:SetValue(self.room_list_info.count <= 0)
	if self.team_scroller.scroller.isActiveAndEnabled then
		self.team_scroller.scroller:ReloadData(0)
	end
end

--------------------------------------- 动态生成副本队伍信息 ----------------------------------------------
KuaFuFuBenRoomScrollCell = KuaFuFuBenRoomScrollCell or BaseClass(BaseCell)

function KuaFuFuBenRoomScrollCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.Flush, self)

	self.name = self:FindVariable("Name")
	self.head = self:FindVariable("Head")
	self.count = self:FindVariable("Count")
	self.fight_power = self:FindVariable("FightPower")

	self.portrait = self:FindObj("portrait")
	self.portrait_raw = self:FindObj("portrait_raw")

	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))

	self.team_type = 0
end

function KuaFuFuBenRoomScrollCell:__delete()

end

function KuaFuFuBenRoomScrollCell:SetTeamType(team_type)
	self.team_type = team_type or 0
end

function KuaFuFuBenRoomScrollCell:OnFlush()
	if self.data then
		self.name:SetValue(self.data.leader_name)
		if self.data.menber_num >= 3 then
			self.count:SetValue(ToColorStr(self.data.menber_num .. "/3", TEXT_COLOR.RED))
		else
			self.count:SetValue(self.data.menber_num .. "/3")
		end
		self.fight_power:SetValue(self.data.leader_capability)
		-- CommonDataManager.SetAvatar(self.data.leader_uid, self.portrait_raw, self.portrait, self.head, self.data.sex, self.data.prof, self.data.avatar_key_big)
		if AvatarManager.Instance:isDefaultImg(self.data.leader_uid) == 0 then
			self.portrait_raw.gameObject:SetActive(false)
			self.portrait.gameObject:SetActive(true)
			local bundle, asset = AvatarManager.GetDefAvatar(PlayerData.Instance:GetRoleBaseProf(self.data.leader_prof), false, self.data.leader_sex)
			self.head:SetAsset(bundle, asset)
		else
			local callback = function (path)
				local avatar_path_small = path or AvatarManager.GetFilePath(self.data.leader_uid, false)
				self.portrait_raw.raw_image:LoadSprite(avatar_path_small, function()
					self.portrait_raw.gameObject:SetActive(true)
					self.portrait.gameObject:SetActive(false)
				end)
			end
			AvatarManager.Instance:GetAvatar(self.data.leader_uid, false, callback)
		end
--		AvatarManager.Instance:SetAvatarKey(self.data.leader_uid, self.data.avatar_key_big, self.data.avatar_key_small)
	end
end

function KuaFuFuBenRoomScrollCell:OnClick()
	if ScoietyData.Instance:GetTeamState() then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.HasTeam)
	else
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.JOIN_ROOM, self.team_type, self.data.team_index, self.data.layer)
	end
end