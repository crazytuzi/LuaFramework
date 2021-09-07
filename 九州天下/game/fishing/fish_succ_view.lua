-- FishingView = FishingView or BaseClass(BaseView)

function FishingView:InitFishSucc()
	self.succ_panel_count_down = nil

	self.check_event_result_type = 0			-- 如果是宝箱才使用1 其他全部是0不赠送

	self:ListenEvent("OnCloseSuccPanel", BindTool.Bind(self.OnCloseSuccPanelHandler, self))
	self:ListenEvent("OnBtnGather", BindTool.Bind(self.OnBtnGatherHandler, self))
	

	self.lbl_fish_succ = self:FindVariable("LabelFishSucc")						-- 鱼饵数量
	self.asset_fish_succ_img = self:FindVariable("AssetFishSuccImg")			-- 钓到的鱼类型
	self.show_fisher = self:FindVariable("ShowFisher")							-- 渔翁卡
	self.show_robber = self:FindVariable("ShowRobber")							-- 强盗卡

	self.fisher = self:FindObj("Fisher")
	self.robber = self:FindObj("Robber")

	self.show_reward_panel = self:FindVariable("IsShowReward")
	self.show_old_box = self:FindVariable("ShowOldBox")	
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
end

function FishingView:DeleteFishSucc()
	self.lbl_fish_succ = nil
	self.asset_fish_succ_img = nil
	self.show_fisher = nil
	self.show_robber = nil
	self.fisher = nil
	self.robber = nil
	self.show_old_box = nil
	self.show_reward_panel = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.icon_time_quest)
	end
	self.time_quest = nil
end

-- enum EVENT_TYPE
-- 	{
-- 		EVENT_TYPE_GET_FISH = 0,						// 鱼类上钩
-- 		EVENT_TYPE_TREASURE,							// 破旧宝箱
-- 		EVENT_TYPE_YUWANG,								// 渔网
-- 		EVENT_TYPE_YUCHA,								// 渔叉
-- 		EVENT_TYPE_OIL,									// 香油
-- 		EVENT_TYPE_ROBBER,								// 盗贼
-- 		EVENT_TYPE_BIGFISH,								// 传说中的大鱼

-- 		EVENT_TYPE_COUNT,
-- 	};

function FishingView:FlushFishSucc()
	self:ReleaseTimer()
	local result_info = FishingData.Instance:GetFishingCheckEventResult()
	self.check_event_result_type = result_info.event_type
	local result_image = ""
	if result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_GET_FISH then					--钓鱼
	-- or result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_BIGFISH  then
		local fish_cfg = FishingData.Instance:GetFishingFishCfgByType(result_info.param1)
		if fish_cfg then
			local score_num = fish_cfg.score * result_info.param2
			if self.lbl_fish_succ then
				self.lbl_fish_succ:SetValue(string.format(Language.Fishing.LabelFishSucc, result_info.param2, fish_cfg.name, score_num))
				result_image = "fish_" .. result_info.param1
			end
		end
		self.show_reward_panel:SetValue(true)

	-- elseif result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_TREASURE then				--钓宝箱
	-- 	if self.lbl_fish_succ then
	-- 		self.lbl_fish_succ:SetValue(Language.Fishing.LabelOldBox)
	-- 	end
	-- 	self.show_old_box:SetValue(true)
	-- 	local treasure_cfg = FishingData.Instance:GetFishingCfg().treasure
	-- 	self.item_cell:SetData(treasure_cfg[1].reward_item)
	-- 	self.show_reward_panel:SetValue(true)

	elseif result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_YUWANG or
	 result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_YUCHA  or 
	 result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_YUCHA then					--钓法宝
	 	if self.lbl_fish_succ then
			self.lbl_fish_succ:SetValue(string.format(Language.Fishing.LabelGetGear, Language.Fishing.LabelGear[result_info.param1]))
			result_image = "gear_" .. result_info.param1 
		end
		self.show_fisher:SetValue(true)
		self.fisher.animation:Play()
		self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
			self.show_reward_panel:SetValue(true)
		end, 0.5)

	elseif result_info.event_type == FISHING_EVENT_TYPE.EVENT_TYPE_ROBBER then					--钓强盗
		local fish_cfg = FishingData.Instance:GetFishingFishCfgByType(result_info.param1)
		if self.lbl_fish_succ and fish_cfg then 
			self.lbl_fish_succ:SetValue(string.format(Language.Fishing.LabelRobber, result_info.param2, fish_cfg.name))
			result_image = "fish_" .. result_info.param1
		else
			self.lbl_fish_succ:SetValue(Language.Fishing.LabelRobberFaiure)
		end
		self.show_robber:SetValue(true)
		self.robber.animation:Play()
		self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
			self.show_reward_panel:SetValue(true)
		end, 0.5)
	end

	if self.asset_fish_succ_img and result_info.event_type ~= FISHING_EVENT_TYPE.EVENT_TYPE_TREASURE then
		local bundle, asset = ResPath.GetFishingRes(result_image)
		self.asset_fish_succ_img:SetAsset(bundle, asset) 
		self.show_old_box:SetValue(false)
	end

	FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_CONFIRM_EVENT, self.check_event_result_type)
	-- 设置倒计时关闭面板
	self:SetCloseSuccTime()

end

function FishingView:FlushFishSteal()
	local steal_result = FishingData.Instance:GetFishingStealResult()
	if steal_result then
	local fish_cfg = FishingData.Instance:GetFishingFishCfgByType(steal_result.fish_type)
		if fish_cfg then
			local score_num = fish_cfg.score * steal_result.fish_num
			if self.lbl_fish_succ then
				if steal_result.is_succ == 1 then
					self.lbl_fish_succ:SetValue(string.format(Language.Fishing.LabelFishSteal, steal_result.fish_num, fish_cfg.name, score_num))
				end
			end
		end

		if self.asset_fish_succ_img then
			local bundle, asset = ResPath.GetFishingRes("fish_" .. steal_result.fish_type)
			self.asset_fish_succ_img:SetAsset(bundle, asset)
		end
	end

	self:SetCloseSuccTime()
end

function FishingView:FlushUseGear()
	-- 	FISHING_GEAR.FISHING_GEAR_NET = 0,		-- 渔网
	-- 	FISHING_GEAR.FISHING_GEAR_SPEAR = 1,	-- 鱼叉
	-- 	FISHING_GEAR.FISHING_GEAR_OIL = 2,		-- 香油
	local use_gear_info = FishingData.Instance:GetFishingGearUseResult()
	local fish_cfg = FishingData.Instance:GetFishingFishCfgByType(use_gear_info.param1)
	self:SetCloseSuccTime()
	if fish_cfg then
		if self.lbl_fish_succ then
			self.show_reward_panel:SetValue(true)
			if use_gear_info.gear_type == FISHING_GEAR.FISHING_GEAR_OIL then
				self.lbl_fish_succ:SetValue(Language.Fishing.LabelUseOil)
				if self.asset_fish_succ_img then
					local bundle, asset = ResPath.GetFishingRes("gear_2")
					self.asset_fish_succ_img:SetAsset(bundle, asset)
				end
				return
			else
				self.lbl_fish_succ:SetValue(string.format(Language.Fishing.LabelUseGear, Language.Fishing.LabelGear[use_gear_info.gear_type], use_gear_info.param2, fish_cfg.name))
			end
		end
	end
	if self.asset_fish_succ_img then
		local bundle, asset = ResPath.GetFishingRes("fish_" .. use_gear_info.param1)
		self.asset_fish_succ_img:SetAsset(bundle, asset)
	end
end

function FishingView:FlushFishResult()
	local cofirm_result = FishingData.Instance:GetFishingConfirmResult()
	if cofirm_result.confirm_type == FISHING_EVENT_TYPE.EVENT_TYPE_TREASURE then				--钓宝箱
		if self.lbl_fish_succ then
			self.lbl_fish_succ:SetValue(Language.Fishing.LabelOldBox)
		end
		self.show_old_box:SetValue(true)
		self.item_cell:SetData({item_id = cofirm_result.short_param_1, num = cofirm_result.param_2, is_bind = cofirm_result.param_3})
		self.show_reward_panel:SetValue(true)
	end
end

-- 刷新前释放计时器，奖励面板置为不显示
function FishingView:ReleaseTimer()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.icon_time_quest)
	end
	self.time_quest = nil
	self.show_reward_panel:SetValue(false)
end

function FishingView:OnBtnGatherHandler()
	self:OnCloseSuccPanelHandler()
	-- FISHING_OPERA_REQ_TYPE_CONFIRM_EVENT 操作类型时参数说明：
	-- 确认事件与玩家当前获得事件相关

	-- 当事件是EVENT_TYPE_GET_FISH（得到鱼）， param_1为赠送玩家uid（uid 为零则不赠送）
	-- 当事件是EVENT_TYPE_TREASURE（获得宝箱），param_1位是否打开宝箱（1打开，0丢弃）
	-- 当事件是EVENT_TYPE_BIGFISH（传说中的大鱼），param_1为赠送玩家uid（uid 为零则不赠送）
	-- 其他事件类型，则不需要参数
end

function FishingView:OnCloseSuccPanelHandler()
	if self.is_open_fish_succ then
		self.is_open_fish_succ:SetValue(false)
	end
	if self.show_fisher then
		self.show_fisher:SetValue(false)
	end
	if self.show_robber then
		self.show_robber:SetValue(false)
	end
end

-- 设置关闭成功界面倒计时
function FishingView:SetCloseSuccTime()
	if self.succ_panel_count_down == nil then
		local count_down_time = 2
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(count_down_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.succ_panel_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.succ_panel_count_down)
					self.succ_panel_count_down = nil
					if self.is_open_fish_succ then
						self:OnBtnGatherHandler()
					end
				end
				return
			end
			-- self.lbl_pull_rod_time:SetValue(string.format(Language.Fishing.LabelPullRodTime, TimeUtil.FormatSecond2Str(left_time)))
		end

		diff_time_func(0, count_down_time)
		self.succ_panel_count_down = CountDown.Instance:AddCountDown(count_down_time, 0.5, diff_time_func)
	end
end