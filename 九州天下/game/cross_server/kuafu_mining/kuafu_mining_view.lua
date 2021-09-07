KuaFuMiningView = KuaFuMiningView or BaseClass(BaseView)

function KuaFuMiningView:__init()
	self.ui_config = {"uis/views/kuafumining","KuaFuMiningInfoView"}

	self.is_show = false
	self.is_guide = false
	self.gift_close_time = 5
	self.is_safe_area_adapter = true
end

function KuaFuMiningView:ReleaseCallBack()
	-- if self.task_view then
	-- 	self.task_view:DeleteMe()
	-- 	self.task_view = nil
	-- end

	if self.score_view then
		self.score_view:DeleteMe()
		self.score_view = nil
	end

	if self.gift_panel then
		self.gift_panel:DeleteMe()
		self.gift_panel = nil
	end

	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	if self.mining_box_view then
		self.mining_box_view:DeleteMe()
		self.mining_box_view = nil
	end

	if self.mining_gather_view then
		self.mining_gather_view:DeleteMe()
		self.mining_gather_view = nil
	end

	-- if nil ~= self.main_role_pos_change_callback then
	-- 	GlobalEventSystem:UnBind(self.main_role_pos_change_callback)
	-- 	self.main_role_pos_change_callback = nil
	-- end

	if nil ~= self.move_by_click then
		GlobalEventSystem:UnBind(self.move_by_click)
		self.move_by_click = nil
	end

	if nil ~= self.enter_hit then
		GlobalEventSystem:UnBind(self.enter_hit)
		self.enter_hit = nil
	end

	if nil ~= self.exit_hit then
		GlobalEventSystem:UnBind(self.exit_hit)
		self.exit_hit = nil
	end
	
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if nil ~= self.role_move_end then
		GlobalEventSystem:UnBind(self.role_move_end)
		self.role_move_end = nil
	end

	if nil ~= self.delay_mining_auto then
		GlobalTimerQuest:CancelQuest(self.delay_mining_auto)
		self.delay_mining_auto = nil
	end
	
	self.is_show = false
	self.is_guide = false
	self.cur_combo = nil
	self.auto_mining = nil
	self.lbl_act_time = nil
	self.show_rank_view = nil
	self.cancel_auto_mining = nil
	self.show_text = nil
	self.show_score = nil
	self.show_panel = nil
	self.show_gather_view = nil
	self.show_get_view = nil
	self.show_guide_mining = nil

	UnityEngine.PlayerPrefs.DeleteKey("aoto_buy_auto_mining")
end

function KuaFuMiningView:LoadCallBack()
	-- self.task_view = KuaFuMiningTaskView.New(self:FindObj("TaskView"))
	self.rank_view = KuaFuMiningRankView.New(self:FindObj("RankView"))
	self.score_view = KuaFuMiningScoreView.New(self:FindObj("ScoreView"))
	self.gift_panel = KuaFuMiningGiftPanel.New(self:FindObj("GiftPanel"))
	self.mining_box_view = MiningTipsRewardView.New(self:FindObj("MiningBoxView"))
	self.mining_gather_view = KuaFuMiningGatherView.New(self:FindObj("MiningGatherView"))

	-- --排行面板
	-- self.rank_view = KuaFuMiningRankView.New()
	-- local rank_view_panel = self:FindObj("RankView")
	-- rank_view_panel.uiprefab_loader:Wait(function(obj)
	-- 	obj = U3DObject(obj)
	-- 	self.rank_view:SetInstance(obj)
	-- end)

	self:ListenEvent("AutoMining", BindTool.Bind(self.OnClickAuto, self))
	self:ListenEvent("CancelAutoMining", BindTool.Bind(self.OnClickCancelAuto, self))
	self:ListenEvent("GuideButton", BindTool.Bind(self.OnClickGuide, self))
	--self:ListenEvent("CloseRankList",BindTool.Bind(self.SetRankViewVisable, self, false))
	--self:ListenEvent("OpenRankView",BindTool.Bind(self.SetRankViewVisable, self, true))
	self:ListenEvent("CloseGiftPanel",BindTool.Bind(self.OnClickGiftViewVisable, self))

	-- if self.main_role_pos_change_callback == nil then
	-- 	self.main_role_pos_change_callback = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind(self.OnRolePosChange, self))
	-- end
	
	if self.move_by_click == nil then
		self.move_by_click = GlobalEventSystem:Bind(OtherEventType.MOVE_BY_CLICK, BindTool.Bind(self.OnMoveByClick, self))
	end

	if self.enter_hit == nil then
		self.enter_hit = GlobalEventSystem:Bind(ObjectEventType.ENTER_FIGHT, BindTool.Bind(self.EnterFightState, self))
	end

	if self.exit_hit == nil then
		self.exit_hit = GlobalEventSystem:Bind(ObjectEventType.EXIT_FIGHT, BindTool.Bind(self.ExitFightState, self))
	end

	if self.role_move_end == nil then
		self.role_move_end = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_MOVE_END, BindTool.Bind(self.OnMainRoleMoveEnd, self))
	end

	self.show_rank_view = self:FindVariable("ShowRankView")
	self.auto_mining = self:FindVariable("ShowAutoMining")									-- 自动挂机
	self.cancel_auto_mining = self:FindVariable("ShowCancelAutoMining")						-- 取消自动挂机
	self.lbl_act_time = self:FindVariable("LabelActTime")									-- 活动倒计时
	self.cur_combo = self:FindVariable("CurCombo")											-- 连击次数
	self.show_text = self:FindVariable("ShowText")											-- 显示“托管中。。。”
	self.show_score = self:FindVariable("ShowScore")	                                    -- 显示连击次数
	self.show_panel = self:FindVariable("ShowPanel")
	self.show_gather_view = self:FindVariable("ShowGatherView")
	self.show_get_view = self:FindVariable("ShowGetView")
	self.show_guide_mining = self:FindVariable("ShowGuideMining")

	self.show_rank_view:SetValue(false)
	self.show_gather_view:SetValue(false)
	self.show_get_view:SetValue(false)
	self.show_guide_mining:SetValue(true)
	--self:OnClickGiftViewVisable()

	if self.show_or_hide_other_button == nil then
		self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
			BindTool.Bind(self.SwitchButtonState, self))
	end
end

function KuaFuMiningView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function KuaFuMiningView:ShowIndexCallBack(index)
	local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_MINING)
	if activity_info then
		local diff_time = activity_info.next_time - TimeCtrl.Instance:GetServerTime()
		self:SetActTime(diff_time)
	end
end

-- 活动倒计时
function KuaFuMiningView:SetActTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			if self.is_show then
				if self.gift_close_time < 0 then
					 self:OnClickGiftViewVisable()
				end
				self.gift_close_time = self.gift_close_time - 0.5				
			end
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)

					self.count_down = nil
				end
				return
			end
			self.lbl_act_time:SetValue(TimeUtil.FormatSecond2Str(left_time))
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(diff_time, 0.5, diff_time_func)
	end
end

function KuaFuMiningView:SetShowText(is_show)
	self.show_text:SetValue(is_show)
end

function KuaFuMiningView:SetCloseGiftViewTime()
	local other_cfg = KuaFuMiningData.Instance:GetMiningOtherCfg()
	if other_cfg then
		self.gift_close_time = other_cfg.role_waiting_time_s
	end
end

-- 是否显示挖矿面板
function KuaFuMiningView:SetGatherVisable(is_show)
	self.show_gather_view:SetValue(is_show)
	if self.mining_gather_view and is_show then
		self.mining_gather_view:Start()
		self:SetBoxViewVisable(false)
		self:ClearDelayTime()
	end
end

-- 显示当前获得面板
function KuaFuMiningView:SetBoxViewVisable(is_show)
	self.show_get_view:SetValue(is_show)
	if is_show then
		self:SetGatherVisable(false)
	end
end

-- 是否显示排行面板
function KuaFuMiningView:SetRankViewVisable(is_show)
	if self.show_rank_view then
		self.show_rank_view:SetValue(is_show)
	end
end

function KuaFuMiningView:EnterFightState()
	if self.is_show then
		self:OnClickGiftViewVisable()
	end

	if KuaFuMiningData.Instance:GetMiningIsAuto() or KuaFuMiningCtrl.Instance:GetGuideState() then
		KuaFuMiningCtrl.Instance:StopAutoMining()
	end
	self.show_guide_mining:SetValue(false)
end

function KuaFuMiningView:ExitFightState()
	self.show_guide_mining:SetValue(true)
end

-- 是否显示获得面板
function KuaFuMiningView:OnClickGiftViewVisable()
	self.is_show = not self.is_show
	self.gift_panel:SetActive(self.is_show)
	self:SetCloseGiftViewTime()
	if self.is_show then
		self.gift_panel:Flush()
	end
end

-- 停止挖矿
function KuaFuMiningView:StopMining()
	if self.mining_gather_view then
		self.mining_gather_view:StopMining()
	end
end

-- 自动挖矿
function KuaFuMiningView:OnClickAuto()
	local main_role = Scene.Instance:GetMainRole()
	if main_role:IsAtk() then 
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotOpen)
		return 
	end

	local function ok_callback()
		if self.mining_gather_view then
			self.mining_gather_view:OnClickAuto()
		end
	end

	if UnityEngine.PlayerPrefs.GetInt("aoto_buy_auto_mining") == 1 then
		if self.mining_gather_view then
			self.mining_gather_view:OnClickAuto()
		end
	else
		TipsCtrl.Instance:ShowCommonTip(ok_callback, nil, Language.KuaFuFMining.AutoMiningTip, nil, nil, true, false, "aoto_buy_auto_mining")
	end
end

-- 寻找矿物
function KuaFuMiningView:OnClickGuide()
	self:SetGuideState(true)
	if self.mining_gather_view then
		self.mining_gather_view:AutoMining()
	end
end

function KuaFuMiningView:SetGuideState(value)
	self.is_guide = value
	self.show_guide_mining:SetValue(not value)
end

function KuaFuMiningView:GetGuideState()
	return self.is_guide
end

-- function KuaFuMiningView:OnRolePosChange()
-- 	if KuaFuMiningCtrl.Instance:GetMiningState() then
-- 		self:OnClickCancelAuto()
-- 	end
-- end

function KuaFuMiningView:OnMoveByClick()
	KuaFuMiningCtrl.Instance:StopAutoMining()
end

function KuaFuMiningView:OnMainRoleMoveEnd()
	if KuaFuMiningData.Instance:GetIsMaxMiningTimes() then return end
	if KuaFuMiningData.Instance:GetMiningIsAuto() or KuaFuMiningCtrl.Instance:GetGuideState() then
		local delay_time = 3
		self:ClearDelayTime()
		self.delay_mining_auto = GlobalTimerQuest:AddDelayTimer(function ()
			if KuaFuMiningData.Instance:GetMiningIsAuto() or KuaFuMiningCtrl.Instance:GetGuideState() then
				if not KuaFuMiningCtrl.Instance:GetMiningState() then
					if self.mining_gather_view then
						self.mining_gather_view:AutoMining()
					end
				end
			end
			self:ClearDelayTime()
		end, delay_time)
	end
end

function KuaFuMiningView:ClearDelayTime()
	if nil ~= self.delay_mining_auto then
		GlobalTimerQuest:CancelQuest(self.delay_mining_auto)
		self.delay_mining_auto = nil
	end
end

function KuaFuMiningView:OnClickCancelAuto()
	self:StopMining()
	if self.mining_gather_view then
		self.mining_gather_view:OnClickCancelAuto()
	end
end

function KuaFuMiningView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "all" then
			local mining_info = KuaFuMiningData.Instance:GetMiningRoleInfo()
			local is_show = mining_info.status ~= SPECIAL_CROSS_MINING_ROLE_STATUS.SPECIAL_CROSS_MINING_ROLE_STATUS_AUTO_MINING
			self.auto_mining:SetValue(is_show)
			self.cancel_auto_mining:SetValue(not is_show)
			local flag = mining_info.combo_times > 1
		    self.show_score:SetValue(flag or false)
			self.cur_combo:SetValue(mining_info.combo_times)

			-- self.task_view:Flush()
			if self.score_view then
				self.score_view:Flush()
			end
			if self.gift_panel then
				self.gift_panel:Flush()
			end
			if self.mining_gather_view then
				self.mining_gather_view:Flush("click")
			end
			if self.rank_view then
				self.rank_view:Flush()
			end
		elseif k == "box_view" then						-- 获得矿石面板
			if self.mining_box_view then
				self:SetBoxViewVisable(true)
				self.mining_box_view:Flush()
			end
		elseif k == "gather_view" then					-- 采集面板
			if self.mining_gather_view then
				self.mining_gather_view:Flush()
			end
		elseif k == "rank_view" then					-- 排行面板
			if self.rank_view then
				self.rank_view:Flush()
			end
		end
	end
end