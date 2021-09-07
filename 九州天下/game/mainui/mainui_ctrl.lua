require("game/mainui/mainui_data")
require("game/mainui/mainui_view")
require("game/mainui/main_collectgarbage_text")
require("game/mainui/mainui_view_attackmode")				--攻击模式界面
require("game/mainui/mainui_line_view")						--分线界面
require("game/mainui/mainui_activity_hall_view")						--活动卷轴
require("game/mainui/mainui_activity_hall_data")						--活动卷轴
require("game/mainui/main_chat_icon")
require("game/mainui/mainui_day_activity_name")	

-- 登录
MainUICtrl = MainUICtrl or BaseClass(BaseController)

function MainUICtrl:__init()
	if MainUICtrl.Instance ~= nil then
		print_error("[MainUICtrl] attempt to create singleton twice!")
		return
	end
	MainUICtrl.Instance = self

	self.view = MainUIView.New(ViewName.Main)
	self.attack_mode_view = ActtackModeView.New(ViewName.AttackMode)
	self.line_view = MainUILineView.New(ViewName.LineView)
	self.data = MainUIData.New()
	self.activity_hall = MainuiActivityHallView.New(ViewName.ActivityHall)
	self.activity_data = MainuiActivityHallData.New()
	self.activity_name = DayActivityName.New(ViewName.ActivityName)

	self.mode = 0
	self:RegisterAllProtocols()
	self:RegisterAllEvents()
	self.chat_id = 0
end

function MainUICtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.attack_mode_view then
		self.attack_mode_view:DeleteMe()
		self.attack_mode_view = nil
	end

	if self.line_view then
		self.line_view:DeleteMe()
		self.line_view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.activity_hall then
		self.activity_hall:DeleteMe()
		self.activity_hall = nil
	end

	if self.activity_data then
		self.activity_data:DeleteMe()
		self.activity_data = nil
	end

	if self.activity_name then
		self.activity_name:DeleteMe()
		self.activity_name = nil
	end

	if self.collectgarbage_view then
		self.collectgarbage_view:DeleteMe()
		self.collectgarbage_view = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	MainUICtrl.Instance = nil
end

function MainUICtrl:CreateMainCollectgarbageText()
	if self.collectgarbage_view == nil then
		self.collectgarbage_view = MainCollectgarbageText.New()
		self.collectgarbage_view:Open()
	else
		self.collectgarbage_view:Close()
		self.collectgarbage_view:DeleteMe()
		self.collectgarbage_view = nil
	end
end

function MainUICtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSetAttackMode, "OnSetAttackMode")
	self:RegisterProtocol(SCContinueKillInfo, "OnContinueKillInfo")
	self:RegisterProtocol(CSSetAttackMode)
	self:RegisterProtocol(SCActivityStatusShow, "OnActivityShowInfo")
end

function MainUICtrl:GetView()
	return self.view
end

function MainUICtrl:GetData()
	return self.data
end

function MainUICtrl:GetTaskView()
	return self.view.task_view
end

function MainUICtrl:GetMenuToggleState()
	return self.view:GetMenuToggleState()
end

function MainUICtrl:GetFightToggleState()
	return self.view:GetFightToggleState()
end

function MainUICtrl:SetShowShield(is_show)
	self.view:SetShowShield(is_show)
end

function MainUICtrl:RegisterAllEvents()

end

function MainUICtrl:OnSetAttackMode(protocol)
	if protocol.result ~= GameEnum.SET_ATTACK_MODE_SUCC then
		local str = Language.Mainui.AttackMode[protocol.result]
		TipsCtrl.Instance:ShowSystemMsg(str)
		return
	end

	self.mode = protocol.attack_mode
	local obj_id = protocol.obj_id
	-- 自己的攻击模式改变
	if Scene ~= nil and Scene.Instance ~= nil and obj_id == Scene.Instance:GetMainRole():GetObjId() then
		self.view:UpdateAttackMode(self.mode)
		GlobalEventSystem:Fire(SettingEventType.SHIELD_OTHERS, self.mode)
	end

	--TODO 其他人攻击模式改变,改变vo即可
	for k,v in pairs(Scene.Instance.obj_list) do
		if v.obj_type == SceneObjType.Role or v.obj_type == SceneObjType.MainRole and v:GetObjId() == obj_id then
			v:SetAttackMode(self.mode)
			if not Scene.Instance.is_pingbi_other_role and Scene.Instance.is_pingbi_friend_role then
				GlobalEventSystem:Fire(SettingEventType.SYSTEM_SETTING_CHANGE, SETTING_TYPE.SHIELD_SAME_CAMP, true)
			end
		end
	end
end

function MainUICtrl:OnTaskRefreshActiveCellViews()
	if self.view then
		self.view:OnTaskRefreshActiveCellViews()
	end
end

function MainUICtrl:GetAttckMode()
	return self.mode
end

function MainUICtrl:SendSetAttackMode(mode, is_fanji)
	print('设置攻击模式', mode)

	local scene_id = Scene.Instance:GetSceneId()
	if mode ~= 0 then
		if scene_id == 8050 or scene_id == 520 then
			TipsCtrl.Instance:ShowSystemMsg("当前场景不能PvP")
			return
		end
		if scene_id == 2303 and mode ~= GameEnum.ATTACK_MODE_ALLIANCE then
			mode = GameEnum.ATTACK_MODE_CAMP
		end
	end
	if Scene.Instance:GetSceneId() >= 9010 and Scene.Instance:GetSceneId() <= 9021 and mode ~= GameEnum.ATTACK_MODE_CAMP then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.SceneLimit)
		return
	end
	if (scene_id == 2002 or scene_id == 2102 or scene_id == 2202) and mode ~= GameEnum.ATTACK_MODE_ALLIANCE and mode ~= GameEnum.ATTACK_MODE_CAMP then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.SceneLimit)
		return
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetAttackMode)
	protocol.mode = mode
	protocol.is_fanji = is_fanji or 0
	protocol:EncodeAndSend()
end

function MainUICtrl:GetSkillButtonPosition()
	return self.view:GetSkillButtonPosition()
end

function MainUICtrl:ChangeRedPoint(index, state)
	self.view:ChangeRedPoint(index, state)
end

function MainUICtrl:ShowHuSongButton(state)
	if self.view and self.view.chat_view then
		self.view.chat_view:ShowHuSong(state)
	end
end

function MainUICtrl:SetButtonVisible(index, is_show)
	self.view:SetButtonVisible(index, is_show)
end

function MainUICtrl:SetBeAttackedIcon(role_vo)
	self.view:Flush("be_atk", {role_vo})
end

-- 自动采集
function MainUICtrl:AutoGather(target, end_type, task_id)
	if self.view and self.view.task_view then
		self.view.task_view:MoveToTarget(target, end_type, task_id)
	end
end

function MainUICtrl:SpiritHuntCountDown()
	local diff_time = SpiritData.Instance:GetHuntSpiritFreeTime() - TimeCtrl.Instance:GetServerTime()
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				SpiritCtrl.Instance:SendHuntSpiritGetFreeInfo()
				return
			end
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 5, diff_time_func)
	end
end

function MainUICtrl:GetCityCombatButtons()
	return self.view:GetCityCombatButtons()
end

function MainUICtrl:SetNewServerBtnState()
	if self.view then
		self.view:SetNewServerBtnState()
	end
end

function MainUICtrl:SetViewState(enable)
	if self.view then
		self.view:SetViewState(enable)
	end
end

function MainUICtrl:ChangeFightStateEnable(enable)
	if self.view then
		self.view:ChangeFightStateEnable(enable)
	end
end

function MainUICtrl:OnTaskShrinkToggleChange()
	if self.view and self.view:IsOpen() then
		self.view:OnTaskShrinkToggleChange()
	end
end

--管理主界面聊天小图标显示或隐藏操作(model_name = 归属的界面(根据该界面功能开启进行显示或隐藏), flush_name = 刷新参数, state = 隐藏或显示)
function MainUICtrl:ChangeMainUiChatIconList(model_name, flush_name, state)
	self.data:ChangeMainUiChatIconList(model_name, flush_name, state)
	if not state then
		self.view:Flush(flush_name, {false})
	else
		self:CheckMainUiChatIconVisible(model_name, flush_name)
	end
end

function MainUICtrl:CheckMainUiChatIconVisible(model_name, flush_name)
	local mainui_icon_list = self.data:GetMainUiIconList()
	if model_name then
		local can_see = OpenFunData.Instance:CheckIsHide(model_name)
		if can_see then
			self.view:Flush(flush_name, {true})
		end
		return
	end
	for k, v in pairs(mainui_icon_list) do
		for k1 in pairs(v) do
			local can_see = OpenFunData.Instance:CheckIsHide(k)
			if can_see then
				self.view:Flush(k1, {true})
			end
		end
	end
end

function MainUICtrl:FlushView(...)
	if self.view then
		self.view:Flush(...)
	end
end

function MainUICtrl:IsLoaded()
	return self.view:IsLoaded()
end

function MainUICtrl:SetIsAutoTaskState(state)
	self.view.task_view:SetAutoTaskState(state)
end

function MainUICtrl:SetTaskAutoState(state)
	self.view.task_view:SetTaskAutoState(state)
end

function MainUICtrl:SetBtnDailyCharge(state)
	self.view:SetBtnDailyCharge(state)
end

function MainUICtrl:OnClickGo()
	self.view.task_view:ClickGo()
end


function MainUICtrl:ShowGuildChatRes()
	self.view:ShowGuildChatRes(ChatData.Instance:GetRedChat())
end

function MainUICtrl:ShowGuildChatDaTi()
	self.view:ShowGuildChatDaTi(ChatData.Instance:GetGuildChatDaTi())
end

function MainUICtrl:UpdateAttackMode(mode)
	self.view:UpdateAttackMode(mode)
end

function MainUICtrl:FlushActivityRed()
	self.activity_hall:FlushRankActivityRed()
end

function MainUICtrl:CloseActivityHallView()
	if self.activity_hall:IsOpen() then
		self.activity_hall:Close()
	end
end

function MainUICtrl:GetGBWorshipCountDown()
	if self.view then
		local count_down = self.view:GetGBWorshipCountDown()
		return count_down
	end
	return nil
end

function MainUICtrl:SetGBWorshipCountDown(time)
	if self.view then
		self.view:SetGBWorshipCountDown(time)
	end
end

function MainUICtrl:ShowGBWorshipCdmask(value)
	if self.view then
		self.view:ShowGBWorshipCdmask(value)
	end
end

function MainUICtrl:ShowGBWorshipBtn(value)
	if self.view then
		self.view:ShowGBWorshipBtn(value)
	end
end

function MainUICtrl:OnOpenTrigger(trigger_type, value)
	if self.view then
		self.view:OnOpenTrigger(trigger_type, value)
	end
end

function MainUICtrl:IsPauseAutoTask()
	if self.view then
		return self.view:IsPauseAutoTask()
	end
	return true
end

function MainUICtrl:OnContinueKillInfo(protocol)
	TipsCtrl.Instance:OpenDoubleHitView(protocol)
end

function MainUICtrl:SetBiPinTimeCountDown(reset_time_s)
	self.view:SetBiPinTimeCountDown(reset_time_s)
end

function MainUICtrl:ChangeBiPinBtn(can_show)
	self.view:ChangeBiPinBtn(can_show)
end

function MainUICtrl:ChangeHappyBtn(can_show)
	self.view:ChangeHappyBtn(can_show)
end

function MainUICtrl:ClickSwitch()
	self.view:ClickSwitch()
end

function MainUICtrl:ShowWorshipEntrance(state)
	self.view:ShowWorshipEntrance(state)
end

function MainUICtrl:DoTransfer(num)
	self.view:DoTransfer(num)
end

function MainUICtrl:SetTransferBtnVIsible(num)
	if self.view and self.view:IsOpen() then
		self.view:SetTransferBtnVIsible(num)
	end
end


function MainUICtrl:OnResetPosCallBack()
	self.view:OnResetPosCallBack()
end

function MainUICtrl:FlushChargeIcon()
	self.view:FlushChargeIcon()
end

function MainUICtrl:OpenRecharge()
	self.view:OpenRecharge()
end

function MainUICtrl:ChangeHuanZhuangShopBtn(state)
	self.view:ChangeHuanZhuangShopBtn(state)
end

function MainUICtrl:GetRootNode()
	return self.view:GetRootNode()
end

function MainUICtrl:GetRootNodeLayer()
	return self.view:GetRootNode().layer
end

function MainUICtrl:SetShrinkButtonRepoint()
	self.view:SetShrinkButtonRepoint()
end

function MainUICtrl:GetHuanZhuangShopActivity()
	return self.view:GetHuanZhuangShopActivity()
end

function MainUICtrl:CheckShowMount()
	self.view:CheckShowMount()
end

function MainUICtrl:OnActivityShowInfo(protocol)
	self.data:SetOpenActivityTime(protocol)
	self.view:Flush("activity_time")
end

function MainUICtrl:OnShowAdventureShopIcon(value)
	self.view:ShowAdventureShop(value)
end

function MainUICtrl:OnChangeRewardItemByLevel()
	local info = GameVoManager.Instance:GetMainRoleVo()
	if self.view:IsOpen() then
		self.view:ChangeRewardItemByLevel(info.level)
	end
end