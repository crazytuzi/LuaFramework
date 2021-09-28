KuaFuMiningView = KuaFuMiningView or BaseClass(BaseView)

function KuaFuMiningView:__init()
	self.ui_config = {"uis/views/kuafumining_prefab","KuaFuMiningInfoView"}

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

	if nil ~= self.click_other_obj then
		GlobalEventSystem:UnBind(self.click_other_obj)
		self.click_other_obj = nil
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

	if self.skill_cd_progress_count_down then
		CountDown.Instance:RemoveCountDown(self.skill_cd_progress_count_down)
		self.skill_cd_progress_count_down = nil
	end

	if self.skill_cd_time_count_down then
		CountDown.Instance:RemoveCountDown(self.skill_cd_time_count_down)
		self.skill_cd_time_count_down = nil
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
	self.is_fight_status = nil
	self.mining_skill_remain_times = nil
	self.show_go_mining_button = nil
	self.skill_cd_time = nil
	self.skill_cd_progress = nil
	self.show_package_effect = nil
	
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
	self:ListenEvent("UseSkill", BindTool.Bind(self.OnClickUseSkill, self))
	--self:ListenEvent("CloseRankList",BindTool.Bind(self.SetRankViewVisable, self, false))
	--self:ListenEvent("OpenRankView",BindTool.Bind(self.SetRankViewVisable, self, true))
	self:ListenEvent("CloseGiftPanel",BindTool.Bind(self.OnClickGiftViewVisable, self))

	-- if self.main_role_pos_change_callback == nil then
	-- 	self.main_role_pos_change_callback = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind(self.OnRolePosChange, self))
	-- end
	
	if self.move_by_click == nil then
		self.move_by_click = GlobalEventSystem:Bind(OtherEventType.MOVE_BY_CLICK, BindTool.Bind(self.OnMoveByClick, self))
	end

	if self.click_other_obj == nil then
		self.click_other_obj = GlobalEventSystem:Bind(ObjectEventType.CLICK_KF_MINING, BindTool.Bind(self.OnClickOtherObj, self))
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
	self.show_gather_view = self:FindVariable("ShowGatherView") 							-- 展示转盘面板
	self.show_get_view = self:FindVariable("ShowGetView") 									-- 展示当前获得物品面板
	self.show_go_mining_button = self:FindVariable("ShowGoMiningButton") 					-- 展示挖矿按钮
	self.is_fight_status = self:FindVariable("IsFightStatus") 								-- 是否属于战斗状态（战斗状态不显示挖矿按钮）
	self.mining_skill_remain_times = self:FindVariable("MiningSkillRemainTimes") 			-- 技能剩余使用次数
	self.skill_cd_time = self:FindVariable("SkillCD") 										-- 技能冷却时间
	self.skill_cd_progress = self:FindVariable("SkillCDProgress") 							-- 技能冷却进度条进度
	self.show_package_effect = self:FindVariable("ShowPackageEffect") 						-- 矿包特效是否显示

	self.show_rank_view:SetValue(false)
	self.show_gather_view:SetValue(false)
	self.show_get_view:SetValue(false)
	self.show_go_mining_button:SetValue(true)
	--self:OnClickGiftViewVisable()

	if self.show_or_hide_other_button == nil then
		self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
			BindTool.Bind(self.SwitchButtonState, self))
	end
	self:FlushKuaFuMiningSkill()
	KuaFuMiningData.Instance:SetPackageEffectState() --设置矿包的特效状态
end

function KuaFuMiningView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end

function KuaFuMiningView:SwitchPackageEffectState(enable)
	if self.show_package_effect then
		self.show_package_effect:SetValue(enable)
	end
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
					 --self:OnClickGiftViewVisable() --根据配置定时关闭矿石兑换面板，现屏蔽，不进行自动关闭
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

--设置矿石兑换面板自动关闭时间
function KuaFuMiningView:SetCloseGiftViewTime()
	local other_cfg = KuaFuMiningData.Instance:GetMiningOtherCfg()
	if other_cfg then
		self.gift_close_time = other_cfg.role_waiting_time_s
	end
end

-- 是否显示挖矿面板(转盘)
function KuaFuMiningView:SetGatherVisable(is_show)
	self.show_gather_view:SetValue(is_show)
	if self.mining_gather_view and is_show then
		self.mining_gather_view:Start()
		self:SetBoxViewVisable(false)
		self:ClearDelayTime()
	end
end

-- 是否显示挖矿按钮
function KuaFuMiningView:SetMiningButtonVisable(is_show)
	if self.show_go_mining_button then
		self.show_go_mining_button:SetValue(is_show)
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

-- 进入战斗状态
function KuaFuMiningView:EnterFightState()
	if self.is_show then
		self:OnClickGiftViewVisable()
	end

	if KuaFuMiningData.Instance:GetMiningIsAuto() or KuaFuMiningCtrl.Instance:GetGuideState() then
		KuaFuMiningCtrl.Instance:StopAutoMining()
	end
	self.is_fight_status:SetValue(true)
end

-- 退出战斗状态
function KuaFuMiningView:ExitFightState()
	self.is_fight_status:SetValue(false)
end

-- 是否显示获得面板
function KuaFuMiningView:OnClickGiftViewVisable()
	if not self.gift_panel then
		return
	end
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
	if KuaFuMiningData.Instance:GetIsMaxMiningTimes() then  				--挖矿次数达到上限
		TipsCtrl.Instance:ShowSystemMsg(Language.KuaFuFMining.MiningLimit)
	else
		self:SetGuideState(true)
		if self.mining_gather_view then
			self.mining_gather_view:AutoMining()
		end
	end
end

function KuaFuMiningView:OnClickUseSkill()
	local cd = KuaFuMiningData.Instance:GetSkillRemainColdDown()

	-- 技能CD中
	if cd > 0 or nil ~= self.skill_cd_progress_count_down or nil ~= self.skill_cd_time_count_down then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.SkillCD)
		return
	end

	-- 技能剩余使用次数判断
	if KuaFuMiningData.Instance:GetSkillRemainTimes() <= 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.Role.NoUseSkillTimes)
		return
	end

	-- 获得攻击目标
	local obj = GuajiCtrl.Instance:SelectFriend()
	if nil == obj then
		TipsCtrl.Instance:ShowSystemMsg(Language.Fight.NoRoleTarget)
		return
	end
	local pos_x, pos_y = obj:GetLogicPos()
	local skill_dis = KuaFuMiningData.Instance:GetSkillDistance()

	-- 检测目标坐标是否在攻击范围内
	if not self:CheckRange(pos_x, pos_y, skill_dis) then
		-- TipsCtrl.Instance:ShowSystemMsg(Language.Role.AttackDistanceFar)
		local scene_id = Scene.Instance:GetSceneId()
		MoveCache.end_type = MoveEndType.UseXuanYunSkill
		GuajiCtrl.Instance:MoveToPos(scene_id, pos_x, pos_y, skill_dis - 3, 0)
		--self:SetGuideState(true)
		return
	end
	KuaFuMiningCtrl.Instance:UseSkill()
end

-- 检测目标坐标是否在攻击范围内
function KuaFuMiningView:CheckRange(x, y, distance)
	local self_x, self_y = Scene.Instance:GetMainRole():GetLogicPos()
	return math.floor((x - self_x) * (x - self_x)) + math.floor((y - self_y) * (y - self_y)) <= distance * distance
end

-- 设置技能冷却时间倒计时
function KuaFuMiningView:SetSkillCDTime()
	if not self.skill_cd_time then
		return 
	end
	local cd = KuaFuMiningData.Instance:GetSkillRemainColdDown()
	if nil == self.skill_cd_time_count_down then
		self.skill_cd_time:SetValue(cd)
		self.skill_cd_time_count_down = CountDown.Instance:AddCountDown(
			cd, 1.0, function(elapse_time, total_time)
				self.skill_cd_time:SetValue(math.ceil(total_time - elapse_time))
				if math.ceil(total_time - elapse_time) <= 0 and nil ~= self.skill_cd_time_count_down then
					CountDown.Instance:RemoveCountDown(self.skill_cd_time_count_down)
					self.skill_cd_time_count_down = nil
				end
			end)
	end
end

-- 设置技能冷却进度
function KuaFuMiningView:SetSkillCDProgress()
	if not self.skill_cd_progress then
		return
	end
	local cd = KuaFuMiningData.Instance:GetSkillRemainColdDown()
	self.skill_cd_progress:SetValue(0)
	if nil == self.skill_cd_progress_count_down and cd > 0.05 then
		self.skill_cd_progress_count_down = CountDown.Instance:AddCountDown(
			cd, 0.05, function(elapse_time, total_time)
				local progress = (total_time - elapse_time) / total_time
				self.skill_cd_progress:SetValue(progress)

				if progress <= 0 and nil ~= self.skill_cd_progress_count_down then
					CountDown.Instance:RemoveCountDown(self.skill_cd_progress_count_down)
					self.skill_cd_progress_count_down = nil
				end
			end)
	end
end

--刷新技能相关显示
function KuaFuMiningView:FlushKuaFuMiningSkill()
	if self.mining_skill_remain_times then
		self.mining_skill_remain_times:SetValue(KuaFuMiningData.Instance:GetSkillRemainTimes())
	end
	self:SetSkillCDProgress()
	self:SetSkillCDTime()
end

function KuaFuMiningView:SetGuideState(value)
	self.is_guide = value
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

function KuaFuMiningView:OnClickOtherObj()
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
	--self:StopMining()
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

			--self.task_view:Flush()
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
				--self.rank_view:Flush()
			end
		elseif k == "box_view" then						-- 获得矿石的面板
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