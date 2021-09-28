--经验
FuBenNewExpView = FuBenNewExpView or BaseClass(BaseRender)

function FuBenNewExpView:__init(instance)
	self:ListenEvent("OnClickTeamEnter",
		BindTool.Bind(self.OnClickTeamEnter, self))
	self:ListenEvent("OnClickSoloEnter",
		BindTool.Bind(self.OnClickSoloEnter, self))
	self:ListenEvent("OnClickAddTime",
		BindTool.Bind(self.OnClickAddTime, self))
	self:ListenEvent("OnClickZuDui",
		BindTool.Bind(self.OnClickZuDui, self))
	self:ListenEvent("OnClickExit",
		BindTool.Bind(self.OnClickExit, self))
	-- self:ListenEvent("OnClickTurntable",
	-- 	BindTool.Bind(self.OnClickTurntable, self))
	self:ListenEvent("OnClickAddTicket",
		BindTool.Bind(self.OnClickAddTicket, self))
	ScoietyData.Instance:GetTeamInfo()
	self.show_card = self:FindVariable("ShowCard")
	self.show_time = self:FindVariable("ShowTime")
	self.countdown = self:FindVariable("Countdown")
	self.set_gray = self:FindVariable("SetGray")
	self.show_team = self:FindVariable("HasTeam")
	self.is_cap = self:FindVariable("IsCap")
	self.no_room = self:FindVariable("NoRoom")
	self.countdown_state = self:FindVariable("CountdownState")
	self.show_room_list = self:FindVariable("ShowRoomList")
	self.has_rest_count = self:FindVariable("HasRestCount")
	self.turntable_info = TurntableInfoCell.New(self:FindObj("Turntable"))

	self.reward_item = ItemCell.New()
	self.reward_item:SetInstanceParent(self:FindObj("ItemCell"))

	--引导用按钮
	self.exp_solo_btn = self:FindObj("SoloBtn")

	self.get_ui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FuBen, self.get_ui_callback)

	self:InitTeamRoom()
	self:InitRoomScroller()

	self.quest_time = TimeCtrl.Instance:GetServerTime() + 10
	self:StartQuest()
end

function FuBenNewExpView:DeleteQuest()
	if self.quest then
		GlobalTimerQuest:CancelQuest(self.quest)
		self.quest = nil
	end
end

function FuBenNewExpView:StartQuest()
	self:DeleteQuest()
	if not self.quest then
		self.quest = GlobalTimerQuest:AddRunQuest(
			function()
				local time = self.quest_time - TimeCtrl.Instance:GetServerTime()
				if time <=0 and self:CheckIsNeedShowRoomList() then
					self.quest_time = TimeCtrl.Instance:GetServerTime() + 5
					FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
				end
			end
		,0)
	end
end

function FuBenNewExpView:__delete()
	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.FuBen, self.get_ui_callback)
	end
	if self.turntable_info ~= nil then
		self.turntable_info:DeleteMe()
	end
	self.teammates = {}
	for k, v in pairs(self.team_cell_list) do
		v:DeleteMe()
	end
	self.team_cell_list = {}
	self.countdown_state = nil
end

function FuBenNewExpView:FlushInfo()
	local get_cfg = FuBenData.Instance:GetExpPotionCfg()
	local team_state = ScoietyData.Instance:GetTeamState()
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local is_leader = ScoietyData.Instance:IsLeaderById(role_id)
	local other_cfg = FuBenData.Instance:GetExpFBOtherCfg()

	local ItemNum = FuBenData.Instance:GetBagRewardNum()
	local RewardNum = other_cfg.item_stuff.num
	local had_item_text = ""
	-- if ItemNum < RewardNum then
	-- 	had_item_text = ToColorStr(ItemNum, TEXT_COLOR.BLUE_4)
	-- else
	-- 	had_item_text = ToColorStr(ItemNum, TEXT_COLOR.BLUE_4)
	-- end
	local num_string = ItemNum
	if ItemNum < RewardNum then
		num_string = ToColorStr(ItemNum,"#fe3030")
	end
	self.show_card:SetValue(num_string .. " / " .. RewardNum)

	local pay_times = FuBenData.Instance:GetExpPayTimes()
	local enter_times = FuBenData.Instance:GetExpEnterTimes()

	local cfg = (pay_times + other_cfg.day_times - enter_times)
	if cfg < 1 then
		self.has_rest_count:SetValue(false)
	else
		self.has_rest_count:SetValue(true)
	end
	local cff = pay_times + other_cfg.day_times

	local num_string_1 = cfg
	if cfg < cff and cfg > 0 then
		num_string_1 = ToColorStr(cfg)
    elseif cfg <= 0 then
    	num_string_1 = ToColorStr(cfg, "#fe3030")
	end
	self.show_time:SetValue(num_string_1 .. " / " .. cff)
	self.set_gray:SetValue(ItemNum == 0 or pay_times + other_cfg.day_times - enter_times == 0)

	if get_cfg then
		local data = {}
		data.item_id = get_cfg.drop_item_1
		self.reward_item:SetData(data)
	end

	local is_self_cap = ScoietyData.Instance:MainRoleIsCap()
	self.is_cap:SetValue(is_self_cap)

	if team_state and self:CheckIsExpType() then
		self.show_team:SetValue(true)
	else
		self.show_team:SetValue(false)
	end

	if self:CheckIsNeedShowRoomList() then
		self:StartQuest()
		self.show_room_list:SetValue(true)
		self:FlushRoomList()
	else
		self.show_room_list:SetValue(false)
		self:FlushTeamRoom()
	end
	self:OpenGlobalTimer()

	local has_buy_times = FuBenData.Instance:GetExpPayTimes()
	local next_pay_money = FuBenData.Instance:GetExpNextPayMoney(has_buy_times)
	if next_pay_money == 0 then
		next_pay_money = 90
	end
end

function FuBenNewExpView:IsShowEffect()
	self.turntable_info:SetShowEffect(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)
end

-- 是否需要显示房间列表
function FuBenNewExpView:CheckIsNeedShowRoomList()
	local flag = true
	if ScoietyData.Instance:GetTeamState() then
		if self:CheckIsExpType() then
			flag = false
		end
	end
	return flag
end

-- 队伍是否是经验副本类型
function FuBenNewExpView:CheckIsExpType()
	local team_info = ScoietyData.Instance:GetTeamInfo() or {}
	local team_type = team_info.team_type or 0
	if team_type == FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB then
		return true
	end
	return false
end

function FuBenNewExpView:OpenGlobalTimer()
	if self.active_countdown then
		GlobalTimerQuest:CancelQuest(self.active_countdown)
		self.active_countdown = nil
	end
	if self.active_countdown == nil then
		self.active_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetExpCountdown, self), 0.2)
	end
end

function FuBenNewExpView:CloseCallBack()
	if self.active_countdown then
		GlobalTimerQuest:CancelQuest(self.active_countdown)
		self.active_countdown = nil
	end
	self:DeleteQuest()
end

function FuBenNewExpView:OnClickInvite()
	TipsCtrl.Instance:ShowInviteView(ScoietyData.InviteOpenType.ExpFuBen)
end

function FuBenNewExpView:OnClickTeamEnter()
	local item_id = FuBenData.Instance:GetExpFBOtherCfg().item_stuff.item_id
	local item_num = FuBenData.Instance:GetBagRewardNum()
	local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		end
	if item_num == 0 then
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
		return
	end
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.START_ROOM)
end

function FuBenNewExpView:OnClickSoloEnter()
	local item_id = FuBenData.Instance:GetExpFBOtherCfg().item_stuff.item_id
	local item_num = FuBenData.Instance:GetBagRewardNum()
	local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		end
	if item_num == 0 then
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
		return
	end
	FuBenCtrl.Instance:SendEnterFBReq(1, 0, 0, param_3)
end

function FuBenNewExpView:OnClickAddTime()
	local vip_level = PlayerData.Instance.role_vo.vip_level
	local totla_buy_times = FuBenData.Instance:GetExpPayTimeByVipLevel(vip_level)
	local has_buy_times =FuBenData.Instance:GetExpPayTimes()
	local next_pay_money = FuBenData.Instance:GetExpNextPayMoney(has_buy_times)
	local max_pay_time = FuBenData.Instance:GetExpMaxPayTime()
	local max_vip_level = FuBenData.Instance:GetExpMaxVipLevel()
	local ok_fun = function ()
		FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_DAILY_FB, 0, param_2, param_3, param_4)
	end
	if max_pay_time > has_buy_times then
		if has_buy_times == totla_buy_times then
			TipsCtrl.Instance:ShowLockVipView(VIPPOWER.EXP_FB_BUY_TIMES)
			return
		end
		local cfg = string.format(Language.ExpFuBen.TipsText1, next_pay_money)
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
	elseif
		vip_level == max_vip_level or has_buy_times == max_pay_time then
		SysMsgCtrl.Instance:ErrorRemind(Language.ExpFuBen.TipsText2)
	end
end

function FuBenNewExpView:OnClickAddTicket()
	local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end
	TipsCtrl.Instance:ShowCommonBuyView(func, 27287, nil, 1)
end

function FuBenNewExpView:SetExpCountdown()
	local add_time = FuBenData.Instance:GetExpFBOtherCfg().interval_time
	local last_time = FuBenData.Instance:GetExpLastTimes()
	local now_time = TimeCtrl.Instance:GetServerTime()
	local min, sec = nil
	local enter_time = ""
	if last_time + add_time > now_time then
		local temp_time = last_time + add_time - now_time - 1
		temp_time = os.date('*t', temp_time)
		enter_time = string.format(Language.ExpFuBen.Countdown, temp_time.min, temp_time.sec)
		self.countdown_state:SetValue(true)
	else
		self.countdown_state:SetValue(false)
	end
	self.countdown:SetValue(enter_time)
end

function FuBenNewExpView:GetUiCallBack(ui_name, ui_param)
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function FuBenNewExpView:OnClickZuDui()
	self:DeleteQuest()
	local item_id = FuBenData.Instance:GetExpFBOtherCfg().item_stuff.item_id
	local item_num = FuBenData.Instance:GetBagRewardNum()
	local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		end
	if item_num == 0 then
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
		return
	end

	if ScoietyData.Instance:GetTeamState() then
		if ScoietyData.Instance:MainRoleIsCap() then
			FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CHANGE_MODE, FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.NoCap)
		end
	else
		FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.CREATE_ROOM, FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
	end
end

function FuBenNewExpView:OnClickExit()
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.EXIT_ROOM)
	FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.REQ_ROOM_LIST, FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
	self:StartQuest()
end

function FuBenNewExpView:OnClickTurntable()
	ViewManager.Instance:Open(ViewName.Welfare, TabIndex.welfare_goldturn)
end
--------------------------------------- 房间信息 ----------------------------------------------

function FuBenNewExpView:InitTeamRoom()
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
		self.teammates[i].is_player = variable_table:FindVariable("IsPlayer")

		name_table = self.teammates[i].obj:GetComponent(typeof(UINameTable))
		self.teammates[i].portrait = U3DObject(name_table:Find("portrait"))
		self.teammates[i].portrait_raw = U3DObject(name_table:Find("portrait_raw"))

		self.teammates[i].event_table = self.teammates[i].obj:GetComponent(typeof(UIEventTable))
		self.teammates[i].event_table:ListenEvent("OnClickInvite", BindTool.Bind(self.OnClickInvite, self, i))
	end
end

function FuBenNewExpView:FlushTeamRoom()
	for i = 1, 2 do
		self.teammates[i].show_member_info:SetValue(false)
	end
	local info = ScoietyData.Instance:GetTeamInfo()
	if info then
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		local i = 1
		for k,v in pairs(info.team_member_list) do
			local teammate_info = v
			if teammate_info and self.teammates[i] then
				-- 如果是队员
				if not ScoietyData.Instance:IsLeaderById(teammate_info.role_id) then
					self.teammates[i].show_member_info:SetValue(true)
					self.teammates[i].name:SetValue(teammate_info.name)
					self.teammates[i].fp:SetValue(teammate_info.capability)
					-- self.teammates[i].has_prepare:SetValue(teammate_info.user_state == CROSS_TEAM_FB_STATE_TYPE.CROSS_TEAM_FB_STATE_TYPE_READY)

					self.teammates[i].is_online:SetValue(teammate_info.is_online == 1)
					-- 设置头像
					CommonDataManager.SetAvatar(teammate_info.role_id, self.teammates[i].portrait_raw, self.teammates[i].portrait, self.teammates[i].head, teammate_info.sex, teammate_info.prof, false)

					self.teammates[i].event_table:ClearEvent("OnClickKickOut")
					self.teammates[i].event_table:ListenEvent("OnClickKickOut", BindTool.Bind(self.OnClickKickOut, self,
					teammate_info.name, teammate_info.role_id))

					self.teammates[i].event_table:ClearEvent("OnClickHead")
					self.teammates[i].event_table:ListenEvent("OnClickHead", BindTool.Bind(self.OnClickHead, self,
					teammate_info.name, teammate_info.role_id))

					self.teammates[i].event_table:ClearEvent("OnClickQuit")
					self.teammates[i].event_table:ListenEvent("OnClickQuit", BindTool.Bind(self.OnClickQuit, self,
					teammate_info.name, teammate_info.role_id))

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
			self.cap_info.name:SetValue(cap_info.name)
			self.cap_info.fp:SetValue(cap_info.capability)
			-- 设置头像
			CommonDataManager.SetAvatar(cap_info.role_id, self.cap_info.portrait_raw, self.cap_info.portrait, self.cap_info.head, cap_info.sex, cap_info.prof, true)
			self.cap_info.is_online:SetValue(cap_info.is_online == 1)

			self.cap_info.event_table:ClearEvent("OnClickHead")
			self.cap_info.event_table:ListenEvent("OnClickHead", BindTool.Bind(self.OnClickHead, self,
			cap_info.name, cap_info.role_id))
		end
	end
end

function FuBenNewExpView:OnClickKickOut(name, role_id)
	if ScoietyData.Instance:MainRoleIsCap() then
		local des = string.format(Language.Society.KickOutTeam, name)
		local ok_callback = function() FuBenCtrl.Instance:SendTeamFbRoomOperateReq(TeamFuBenOperateType.KICK_OUT, role_id) end
		TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
	end
end

function FuBenNewExpView:OnClickHead(name, role_id)
	if role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		return
	end
	ScoietyCtrl.Instance:ShowOperateList(ScoietyData.DetailType.Default, name)
end

function FuBenNewExpView:OnClickQuit(name, role_id)
	if role_id ~= GameVoManager.Instance:GetMainRoleVo().role_id then
		return
	end
	ScoietyCtrl.Instance:ExitTeamReq()
end

----------------------------------------InitRoomScroller---------------------------------------------------

--初始化滚动条
function FuBenNewExpView:InitRoomScroller()
	self.team_scroller = self:FindObj("TeamScroller")
	self.team_cell_list = {}
	self.room_list_info = FuBenData.Instance:GetTeamFbRoomList()
	local scroller_delegate = self.team_scroller.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoomNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.GetRoomCellView, self)
end

--滚动条数量
function FuBenNewExpView:GetRoomNumberOfCells()
	return self.room_list_info.count or 0
end

--滚动条刷新
function FuBenNewExpView:GetRoomCellView(cellObj, data_index)
	local cell = self.team_cell_list[cellObj]
	if cell == nil then
		self.team_cell_list[cellObj] = KuaFuFuBenRoomScrollCell.New(cellObj)
		cell = self.team_cell_list[cellObj]
	end
	cell:SetIndex(data_index)
	cell:SetTeamType(FuBenTeamType.TEAM_TYPE_TEAM_DAILY_FB)
	local data = self.room_list_info.room_list[data_index + 1]
	if data then
		cell:SetData(data)
	end
end

function FuBenNewExpView:FlushRoomList()
	self.room_list_info = FuBenData.Instance:GetTeamFbRoomList()
	self.no_room:SetValue(self.room_list_info.count <= 0)
	if self.team_scroller.scroller.isActiveAndEnabled then
		self.team_scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end