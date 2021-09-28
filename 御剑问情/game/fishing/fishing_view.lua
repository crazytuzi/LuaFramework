-- require("game/fishing/fish_bait_view")

require("game/fishing/other_panel/creel_panel_view")
require("game/fishing/other_panel/fishing_table_panel_view")


CrossFishingView = CrossFishingView or BaseClass(BaseView)

function CrossFishingView:__init()
	self.ui_config = {"uis/views/fishing_prefab", "FishingView"}

	self.m_is_open_creel_valua = false
	self.m_is_open_fish_bait_valua = false

	self.active_close = false
	self.m_is_start_fishing = false								-- 是否开始钓鱼
	self.m_is_role_move = false									-- 角色是否移动中
	self.fishing_effect_list = {}								-- 钓鱼的特效列表
	self.is_safe_area_adapter = true

	self.is_first_find_way = true
end

function CrossFishingView:__delete()
end

function CrossFishingView:ReleaseCallBack()
	self:CancelFlushTimer()
	self:RemoveEventCountDown()
	
	if self.creel_view then
		self.creel_view:DeleteMe()
		self.creel_view = nil
	end
	if self.table_view then
		self.table_view:DeleteMe()
		self.table_view = nil
	end

	if self.btn_fishing then
		self.btn_fishing:DeleteMe()
		self.btn_fishing = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.pull_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.pull_count_down)
		self.pull_count_down = nil
		if self.lbl_pull_rod_time then
			self.lbl_pull_rod_time:SetValue("")
		end
	end

	if self.creel_panel_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.creel_panel_count_down)
		self.creel_panel_count_down = nil
	end

	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
		self.menu_toggle_event = nil
	end

	for k,v in pairs(self.fishing_effect_list) do
		v:Destroy()
		v:DeleteMe()
	end

	self.fishing_effect_list = {}

	self:DeleteFishBait()
	self:DeleteFishSucc()

	self.is_open_creel = nil
	self.is_open_table = nil
	self.is_open_fish_bait = nil
	self.is_open_fish_rod = nil
	self.is_open_fish_succ = nil
	self.lbl_act_time = nil
	self.progre_pull_rod = nil
	self.lbl_pull_rod_time = nil
	self.lbl_auto_fishing = nil
	self.lbl_pull_rod = nil
	self.is_start_fishing = nil
	self.is_fishing_area = nil
	self.is_countdown_show = nil
	self.is_fast_fishing_show = nil
	self.show_creel_effecf = nil
	self.show_fishing_effecf = nil
	self.tips_desc = nil

	self.show_effect = nil
	self.obj_buoy = nil

	self.obj_btn_fishing_image = nil
	self.obj_btn_fishing_text = nil
	self.time_up_text = nil

	self.text_up = nil
	self.text_down = nil
	self.event_image = nil

	self.magic_count = nil
	self:ClearTimer()
	self.is_time_up = nil
end

function CrossFishingView:LoadCallBack()
	--监听UI事件
	self:ListenEvent("OnClose", BindTool.Bind(self.OnCloseHandler, self))
	self:ListenEvent("OnOpenCreel", BindTool.Bind(self.OnOpenCreelHandler, self))
	self:ListenEvent("OnOpenFishBait", BindTool.Bind(self.OnOpenFishBaitHandler, self))
	self:ListenEvent("OnOpenRaidersTips", BindTool.Bind(self.OnOpenRaidersTipsHandler, self))

	self:ListenEvent("OnQiuckRod", BindTool.Bind(self.OnQiuckRodHandler, self))
	self:ListenEvent("OnAutoFishing", BindTool.Bind(self.OnAutoFishingHandler, self))
	self:ListenEvent("OnStartFishing", BindTool.Bind(self.OnStartFishingHandler, self))

	self:ListenEvent("OnBtnFishing", BindTool.Bind(self.OnBtnFishingHandler, self))
	self:ListenEvent("OnAutoGoFishing", BindTool.Bind(self.OnAutoGoFishingHandler,self))
	for i = 0, 2 do
		self:ListenEvent("OnBtnGear" .. i, BindTool.Bind(self.OnBtnGearHandler, self, i))
	end

	self.is_open_creel = self:FindVariable("IsOpenCreel")									-- 是否打开鱼篓界面
	self.is_open_table = self:FindVariable("IsOpenTable")									-- 左下角按钮控制
	self.is_open_fish_bait = self:FindVariable("IsOpenFishBait")							-- 是否打开鱼饵界面
	self.is_open_fish_rod = self:FindVariable("IsOpenFishRodPanel")							-- 是否打开钓鱼拉杆界面
	self.is_open_fish_succ = self:FindVariable("IsOpenFishSuccPanel")						-- 是否打开钓鱼成功界面
	self.lbl_act_time = self:FindVariable("LabelActTime")									-- 活动倒计时
	self.progre_pull_rod = self:FindVariable("ProgreBarPullRod")							-- 拉杆倒计时进度
	self.lbl_pull_rod_time = self:FindVariable("LabelPullRodTime")							-- 拉杆倒计时
	self.lbl_pull_rod_time:SetValue("")
	self.show_effect = self:FindVariable("ShowEffect")

	self.text_up = self:FindVariable("EventText_1")
	self.text_down = self:FindVariable("EventText_2")
	self.event_image = self:FindVariable("EventImage")

	self.tips_desc = self:FindVariable("TipsDesc")
	self.lbl_auto_fishing = self:FindVariable("LabelAutoFishing")							-- 自动钓鱼
	self.lbl_pull_rod = self:FindVariable("LabelPullRod")							-- 自动钓鱼
	self.is_start_fishing = self:FindVariable("IsStartFishing")								-- 是否开始钓鱼
	self.is_fishing_area = self:FindVariable("IsFishingArea")								-- 是否钓鱼区域
	self.is_countdown_show = self:FindVariable("IsCountDownShow")							-- 是否打開倒計時
	self.is_fast_fishing_show = self:FindVariable("IsFastFishing")						    -- 是否显示快速钓鱼
	self.show_creel_effecf = self:FindVariable("ShowCreelEffecf")							-- 是否显示鱼篓特效
	self.show_fishing_effecf = self:FindVariable("ShowFishingEffecf")						-- 是否显示上钩特效
	-- 游标	
	self.obj_buoy =self:FindObj("Buoy")
							
	self.obj_btn_fishing_image = self:FindVariable("BtnFishingImage")						-- 收抛竿Image
	self.obj_btn_fishing_text = self:FindVariable("BtnFishingText")							-- 收抛竿Text
	self.time_up_text = self:FindVariable("TimeUpText")                                     -- 加速上钩时间
	self.is_time_up = self:FindVariable("IsTimeUp")
    self:ClearTimer()
    self.timer_quest = 	GlobalTimerQuest:AddRunQuest(BindTool.Bind2(self.Time, self), 1)
	-- local oil_special_status_duration = CrossFishingData.Instance:GetFishingOtherCfg().oil_special_status_duration
	-- self.time_up_text:SetValue(oil_special_status_duration.."s")
	-- -- 标签页
	-- self.toggle_info = self:FindObj("ToggleInfo")
    
	-- 鱼篓面板
	
	local top_creel_panel = self:FindObj("CreelPanel")
	top_creel_panel.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.creel_view = CreelPanelView.New(obj)
		self.creel_view:Flush()
	end)

	-- 积分面板
	
	local table_panel = self:FindObj("TablePanel")
	table_panel.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.table_view = FishingTablePanelView.New(obj)
		self.table_view:Flush()
	end)


	self:InitFishBait()				-- 初始化鱼饵面板信息
	self:InitFishSucc()				-- 初始化钓鱼成功面板信息

	self:OnMainRolePosChangeHandler()

	self.magic_count = {}
	for i = 1, 3 do
		self.magic_count[i] = self:FindVariable("CountText" .. i)		
	end
	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.PortraitToggleChange, self))
end

function CrossFishingView:OpenCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	-- 监听玩家移动
	if self.role_pos_change == nil then
		self.role_pos_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind1(self.OnMainRolePosChangeHandler, self))
	end
	-- 监听玩家移动
	if self.role_move_end == nil then
		self.role_move_end = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_MOVE_END, BindTool.Bind1(self.OnMainRoleMoveEndHandler, self))
	end

	-- 请求钓鱼排行榜信息
	FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_RANK_INFO)
end

function CrossFishingView:CloseCallBack()
	--移除物品回调
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	
	if nil ~= self.role_pos_change then
		GlobalEventSystem:UnBind(self.role_pos_change)
		self.role_pos_change = nil
	end
	if nil ~= self.role_move_end then
		GlobalEventSystem:UnBind(self.role_move_end)
		self.role_move_end = nil
	end
end

function CrossFishingView:OnCloseHandler()
	local yes_func = function ()
		FuBenCtrl.Instance:SendExitFBReq()
		ViewManager.Instance:Close(ViewName.FishingView)
	end
	-- TipsCtrl.Instance:ShowTwoOptionView(Language.Common.ExitCurrentScene, yes_func)
	TipsCtrl.Instance:ShowCommonTip(yes_func,nil,Language.Fishing.LeaveFishing)
end

--决定显示那个界面
function CrossFishingView:ShowIndexCallBack(index)
	local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_FISHING)
	if activity_info then
		local diff_time = activity_info.next_time - TimeCtrl.Instance:GetServerTime()  
		self:SetActTime(diff_time)
	end

	CrossFishingData.Instance:SetAutoFishing(0)
	self.lbl_auto_fishing:SetValue(Language.Fishing.LabelAutoFishing[2])
	self.lbl_pull_rod:SetValue(Language.Fishing.LabelAutoFishing[0])

	-- if CrossFishingData.Instance:GetFishingUserInfo().is_consumed_auto_fishing ~= 0 then
	-- 	self.is_fast_fishing_show:SetValue(false)
	-- end
	self:Flush()
end

function CrossFishingView:OnFlush(param_list)
	self:FlushEffect()
	for k, v in pairs(param_list) do
		if k == "all" then
			self:FlushFishBait()
		elseif k == "flush_fish_bait_view" then					-- 鱼饵面板
			self:FlushFishBait()

		elseif k == "flush_creel_view" then						-- 鱼篓面板
			if self.creel_view then
				self.creel_view:Flush(v)
			end
		elseif k == "flush_table_view" then						-- 积分面板
			if self.table_view then
				self.table_view:Flush(v)
			end

		elseif k == "flush_rod_time" then						-- 刷新拉杆倒计时
			self:SetRodTime()

		elseif k == "flush_fish_succ" then						-- 刷新钓鱼成功
			self:FlushFishSucc()
			if self.creel_view then
				self.creel_view:Flush(v)
			end
		elseif k == "flush_fish_steal" then						-- 刷新偷鱼成功
			self:CancelFlushTimer()
			self.flush_timer = GlobalTimerQuest:AddDelayTimer(
				function()
					self.is_open_fish_succ:SetValue(true)
				end, 0)			
			self:FlushFishSteal()
			if self.creel_view then
				self.creel_view:Flush(v)
			end
		elseif k == "flush_use_gear" then						-- 刷新法宝使用成功
			self.is_open_fish_succ:SetValue(true)
			self:FlushUseGear()
			if self.creel_view then
				self.creel_view:Flush(v)
			end
		elseif k == "flush_fish_result" then
			self.is_open_fish_succ:SetValue(true)
			self:FlushFishResult()
			if self.creel_view then
				self.creel_view:Flush(v)
			end
		elseif k == "flush_fishing_area" then
			local main_role = Scene.Instance:GetMainRole()
			local m_fishing_area = main_role:IsFishing()
			-- 是否在钓鱼区域中
			self.is_fishing_area:SetValue(m_fishing_area)

			-- 获取信息
			local fishing_user_info = CrossFishingData.Instance:GetFishingUserInfo()
			local fishing_auto_go = CrossFishingData.Instance:GetAutoGoFishing()
			self.m_is_start_fishing = fishing_user_info.fishing_status > 0
			self.is_start_fishing:SetValue(self.m_is_start_fishing and m_fishing_area)
			if fishing_auto_go and m_fishing_area then
				main_role:StopMove()
				GuajiCtrl.Instance:StopGuaji()
			end
		elseif k == "flush_fishing_lagan_btn" then				-- 刷新拉杆按钮
			local bundle, asset = ResPath.GetFishingRes("lagan")
			self.obj_btn_fishing_image:SetAsset(bundle, asset)
			bundle, asset = ResPath.GetFishingRes("lagantxt")
			self.obj_btn_fishing_text:SetAsset(bundle, asset)
		elseif k == "flush_fishing_paogan_btn" then				-- 刷新抛竿按钮
			local bundle1, asset1 = ResPath.GetFishingRes("paogan")
			self.obj_btn_fishing_image:SetAsset(bundle1, asset1)
			local bundle2, asset2 = ResPath.GetFishingRes("paogantxt")
			self.obj_btn_fishing_text:SetAsset(bundle2, asset2)
			if CrossFishingData.Instance:GetAutoFishing() == 0 then
				self.lbl_auto_fishing:SetValue(Language.Fishing.LabelAutoFishing[2])
				self.lbl_pull_rod:SetValue(Language.Fishing.LabelAutoFishing[0])
			end
		end
	end
end

function CrossFishingView:CancelFlushTimer()
	if self.flush_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.flush_timer)
		self.flush_timer = nil
	end
end

function CrossFishingView:HideFishing(is_on)
	self.is_open_fish_succ:SetValue(is_on)
end

function CrossFishingView:FlushEffect()
	self.show_effect:SetValue(CrossFishingData.Instance:IsCanExchange())
end

function CrossFishingView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:FlushFishBait()
end

function CrossFishingView:GetMagicCount()
	local fishing_user_info = CrossFishingData.Instance:GetFishingUserInfo() or nil	
	if fishing_user_info then
		for i=1,3 do
			if self.magic_count and self.magic_count[i] then
				self.magic_count[i]:SetValue(fishing_user_info.gear_num_list[i])
			end
		end
	end
end

function CrossFishingView:OnOpenCreelHandler()
	self.m_is_open_creel_valua = not self.m_is_open_creel_valua
	self.is_open_creel:SetValue(self.m_is_open_creel_valua)
	self.show_creel_effecf:SetValue(false)
	if self.m_is_open_creel_valua == true then
		self:SetCloseCreelTime()
	end
	if self.creel_view then
		self.creel_view:Flush()
	end
end

function CrossFishingView:OnOpenFishBaitHandler()
	self.m_is_open_fish_bait_valua = not self.m_is_open_fish_bait_valua
	self.is_open_fish_bait:SetValue(self.m_is_open_fish_bait_valua)
end

function CrossFishingView:OnOpenRaidersTipsHandler()													--游戏帮助
	-- 钓鱼Tips
	TipsCtrl.Instance:ShowHelpTipView(217)
end

-- 设置鱼篓关闭界面倒计时
function CrossFishingView:SetCloseCreelTime()
	if self.creel_panel_count_down == nil then
		local count_down_time = CrossFishingData.Instance:GetFishingCreelTimeCfg()
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(count_down_time - elapse_time + 0.5)
			if CrossFishingData.Instance:GetCreelViewtime() == 1 then
				CountDown.Instance:SetElapseTime(self.creel_panel_count_down, 0)
				CrossFishingData.Instance:SetCreelViewtime(0)
			end
			if left_time <= 0 or not self.m_is_open_creel_valua then
				if self.creel_panel_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.creel_panel_count_down)
					self.creel_panel_count_down = nil
					self.m_is_open_creel_valua = false
					self.is_open_creel:SetValue(false)
				end
				return
			end
			-- self.lbl_pull_rod_time:SetValue(string.format(Language.Fishing.LabelPullRodTime, TimeUtil.FormatSecond2Str(left_time)))
		end

		diff_time_func(0, count_down_time)
		self.creel_panel_count_down = CountDown.Instance:AddCountDown(count_down_time, 0.5, diff_time_func)
	end
end



-- 活动倒计时
function CrossFishingView:SetActTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)

					self.count_down = nil
				end
				return
			end
			self.lbl_act_time:SetValue(string.format(Language.Common.ActTime, TimeUtil.FormatSecond2Str(left_time)))
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(diff_time, 0.5, diff_time_func)
	end
end

-- 拉杆倒计时处理函数
function CrossFishingView:SetRodTime()
	local is_fast_fishing = CrossFishingData.Instance:GetFishingUserInfo().is_consumed_auto_fishing
	local is_auto_fishing = CrossFishingData.Instance:GetAutoFishing()
	-- if is_fast_fishing == 1 and is_auto_fishing == 1 then
	-- 	FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_PULL_RODS)  
	-- 	return
	-- end
	if is_auto_fishing ~= 1 then
		self.show_fishing_effecf:SetValue(true)
	end
	if self.pull_count_down == nil then
		local pull_count_down_time = CrossFishingData.Instance:GetFishingOtherCfg().pull_count_down_s or 0
		self.is_countdown_show:SetValue(true)
		local flag = true
		local pull_count_down_startpos = self.obj_buoy.transform.localPosition
		local time = 0
		local time_part = 0
		local timer =  pull_count_down_time / 3																	--游标转圈次数
		function diff_time_func(elapse_time, total_time)
			local fishing_user_info = CrossFishingData.Instance:GetFishingUserInfo()
			if time > timer then
				flag = false
			elseif time < 0 then
				flag = true
			end
			if flag then	
				time = time + (elapse_time - time_part)
			else
				time = time - (elapse_time - time_part)
			end
			
			local length = 620 / timer * time
			self.obj_buoy.transform.localPosition = pull_count_down_startpos + Vector3(length, 0, 0)
			 self.progre_pull_rod:SetValue(elapse_time / total_time)
			local left_time = math.floor(total_time - elapse_time)
			if (bit:_and(1, bit:_rshift(fishing_user_info.special_status_flag, 2)) == 1 and length >= 465) or 
				(bit:_and(1, bit:_rshift(fishing_user_info.special_status_flag, 1)) == 1 and is_auto_fishing == 1 and left_time <= 0) or 
				fishing_user_info.fishing_status ~= FISHING_STATUS.FISHING_STATUS_HOOKED or left_time <= 0 then				--倒计时小于0或者状态改变
				if self.pull_count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.pull_count_down)
					self.pull_count_down = nil
					self.lbl_pull_rod_time:SetValue("")
					self.obj_buoy.transform.localPosition = pull_count_down_startpos
					self.is_countdown_show:SetValue(false)
					self.show_fishing_effecf:SetValue(false)
					if CrossFishingData.Instance:GetAutoFishing() == 1 then
						FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_PULL_RODS)  
					end
				end
				return
			end
			self.lbl_pull_rod_time:SetValue(string.format(Language.Fishing.LabelPullRodTime, TimeUtil.FormatSecond2Str(left_time)))
			time_part = elapse_time
		end

		diff_time_func(0, pull_count_down_time)
		self.pull_count_down = CountDown.Instance:AddCountDown(pull_count_down_time, 0.01, diff_time_func)
	end
end

-- 快速拉杆
function CrossFishingView:OnQiuckRodHandler()
	-- if CrossFishingData.Instance:GetFishingUserInfo().is_consumed_auto_fishing ~= 0 then 
	-- 	return
	-- end
	local is_auto_fishing = CrossFishingData.Instance:GetAutoFishing()
	if is_auto_fishing == 1 then
		FishingCtrl.Instance:SendAutoFishing(0, SPECIAL_STATUS.SPECIAL_STATUS_AUTO_FISHING_VIP)
		CrossFishingData.Instance:SetAutoFishing(0)
		FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_START_FISHING)
		self.lbl_pull_rod:SetValue(Language.Fishing.LabelAutoFishing[0])
		return
	end
	local other_cfg = CrossFishingData.Instance:GetFishingOtherCfg()
	if other_cfg then
		local des = string.format(Language.Fishing.IsBuyAutoQiuckRod, other_cfg.auto_fishing_need_gold)
		local is_consumed_auto_fishing = CrossFishingData.Instance:GetFishingUserInfo().is_consumed_auto_fishing

		local ok_fun = function ()
			-- if is_consumed_auto_fishing == 0 then
				FishingCtrl.Instance:SendAutoFishing(1, SPECIAL_STATUS.SPECIAL_STATUS_AUTO_FISHING_VIP)
			-- end
			local is_auto_fishing = CrossFishingData.Instance:GetAutoFishing()
			if is_auto_fishing == 0 then
				self.lbl_pull_rod:SetValue(Language.Fishing.LabelAutoFishing[1])
			else
				self.lbl_pull_rod:SetValue(Language.Fishing.LabelAutoFishing[0])
			end
			FishingCtrl.Instance.view:OnFishingHandler()
		end

		if is_consumed_auto_fishing == 1 then
			ok_fun()
		else
			TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, des, nil, nil, true, false)
		end
	end
end

-- 自动钓鱼
function CrossFishingView:OnAutoFishingHandler()
	local is_auto_fishing = CrossFishingData.Instance:GetAutoFishing()
	if is_auto_fishing == 0 then
		FishingCtrl.Instance:SendAutoFishing(1, SPECIAL_STATUS.SPECIAL_STATUS_AUTO_FISHING)
		FishingCtrl.Instance:SendAutoFishing(0, SPECIAL_STATUS.SPECIAL_STATUS_AUTO_FISHING_VIP)
		self.lbl_auto_fishing:SetValue(Language.Fishing.LabelAutoFishing[1])
	else
		FishingCtrl.Instance:SendAutoFishing(0, SPECIAL_STATUS.SPECIAL_STATUS_AUTO_FISHING)
		self.lbl_auto_fishing:SetValue(Language.Fishing.LabelAutoFishing[2])
	end
	self:OnFishingHandler()
end

function CrossFishingView:OnFishingHandler()
	local is_auto_fishing = CrossFishingData.Instance:GetAutoFishing()
	local fish_bait = CrossFishingData.Instance:GetBaitFishing(0)
	if fish_bait <= 0 and is_auto_fishing == 0 then
		FishingCtrl.Instance:SendFishing(0)
		return
	end
	if is_auto_fishing == 0 then
		-- 设置自动钓鱼
		CrossFishingData.Instance:SetAutoFishing(1)
		-- 使用0普通鱼饵
		if CrossFishingData.Instance:GetFishingUserInfo().fishing_status == FISHING_STATUS.FISHING_STATUS_WAITING then
			 FishingCtrl.Instance:SendFishing(0)
		end
	else
		CrossFishingData.Instance:SetAutoFishing(0)
		FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_START_FISHING)
	end
end


--自动寻路
function CrossFishingView:OnAutoGoFishingHandler()
	local fishing_location_cfg = CrossFishingData.Instance:GetFishinglocationCfg()
	local rand_index = 1
	if self.is_first_find_way then
		rand_index = math.random(1, GetListNum(fishing_location_cfg))
		self.is_first_find_way = false
	else
		rand_index = CrossFishingData.Instance:FindNearPosIndex()
	end

	local cfg = fishing_location_cfg[rand_index]

	if cfg then
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), cfg.x, cfg.y)
		CrossFishingData.Instance:SetAutoGoFishing(true)
	end
end


-- 钓鱼的状态
-- FISHING_STATUS = {
-- 	FISHING_STATUS_IDLE = 0,							-- 未钓鱼，即不在钓鱼界面
-- 	FISHING_STATUS_WAITING = 1,							-- 在钓鱼界面等待抛竿
-- 	FISHING_STATUS_CAST = 2,							-- 已经抛竿，等待触发事件
-- 	FISHING_STATUS_HOOKED = 3,							-- 已经触发事件，等待拉杆
-- 	FISHING_STATUS_PULLED = 4,							-- 已经拉杆，等待玩家做选择
-- 钓鱼抛竿
function CrossFishingView:OnBtnFishingHandler()
	local fish_bait = CrossFishingData.Instance:GetBaitFishing(0)
	local fishing_user_info = CrossFishingData.Instance:GetFishingUserInfo()
	if fishing_user_info.fishing_status == FISHING_STATUS.FISHING_STATUS_WAITING then			-- 在钓鱼界面等待抛竿
		-- 使用0普通鱼饵
		FishingCtrl.Instance:SendFishing(0)    
	elseif fishing_user_info.fishing_status == FISHING_STATUS.FISHING_STATUS_CAST then			-- 已经抛竿，等待触发事件
		SysMsgCtrl.Instance:ErrorRemind(Language.Fishing.FishNoHookTips)
	elseif fishing_user_info.fishing_status == FISHING_STATUS.FISHING_STATUS_HOOKED then		-- 已经触发事件，等待拉杆
		FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_PULL_RODS)   		
	elseif fishing_user_info.fishing_status == FISHING_STATUS.FISHING_STATUS_PULLED then		-- 已经拉杆，等待玩家做选择

	end
end


-- 法宝按钮
function CrossFishingView:OnBtnGearHandler(gear_type)
	-- 	FISHING_GEAR.FISHING_GEAR_NET = 0,		-- 渔网
	-- 	FISHING_GEAR.FISHING_GEAR_SPEAR = 1,	-- 鱼叉
	-- 	FISHING_GEAR.FISHING_GEAR_OIL = 2,		-- 香油
	FishingCtrl.Instance:SendUseGear(gear_type)
end

-- 请求钓鱼状态
function CrossFishingView:OnStartFishingHandler()

	-- -- self.move_end_pos.x, self.move_end_pos.y = GameMapHelper.LogicToWorld(pos_x, pos_y)
	-- local delta_pos = u3d.vec2(target_x, target_y)

	-- -- local delta_pos = u3d.v2Sub(self.move_end_pos, self.real_pos)
	-- local move_total_distance = u3d.v2Length(delta_pos)
	-- local move_dir = u3d.v2Normalize(delta_pos)


	-- Quaternion.LookRotation (source - target)
	FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_START_FISHING)
end

-- 角色移动处理函数
function CrossFishingView:OnMainRolePosChangeHandler(x, y)
	self.m_is_role_move = true
	local is_auto_fishing = CrossFishingData.Instance:GetAutoFishing()
	if is_auto_fishing == 1 then
		FishingCtrl.Instance:SendAutoFishing(0, SPECIAL_STATUS.SPECIAL_STATUS_AUTO_FISHING_VIP)
		CrossFishingData.Instance:SetAutoFishing(0)
		FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_START_FISHING)
		self.lbl_pull_rod:SetValue(Language.Fishing.LabelAutoFishing[0])
		return
	end
	if self.m_is_start_fishing and (self.self_x ~= x or self.self_y ~= y) then
		-- 取消钓鱼状态
		FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_STOP_FISHING)
		CrossFishingData.Instance:SetAutoFishing(0)
	end
	self:Flush("flush_fishing_area")
end

-- 角色移动结束处理函数
function CrossFishingView:OnMainRoleMoveEndHandler()
	self.m_is_role_move = false
	CrossFishingData.Instance:SetAutoGoFishing(false)
	self:Flush("flush_fishing_area")
end

function CrossFishingView:RemoveFishingEffect(role_id)
	if nil ~= self.fishing_effect_list[role_id] then
		self.fishing_effect_list[role_id]:Destroy()
		self.fishing_effect_list[role_id]:DeleteMe()
		self.fishing_effect_list[role_id] = nil
	end
end

function CrossFishingView:ClearTimer()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function CrossFishingView:Time()
	-- 剩余时间
	local server_time = TimeCtrl.Instance:GetServerTime()
    local Timetext = CrossFishingData.Instance:GetFishingUserInfo().special_status_oil_end_timestamp
	local time_up_text = Timetext - server_time
	local str = TimeUtil.FormatSecond(time_up_text, 2)	
	self.time_up_text:SetValue(str)
    self.is_time_up:SetValue(true)
    if time_up_text <= 0 then
    	self.is_time_up:SetValue(false)
    end
end

function CrossFishingView:PortraitToggleChange(state)
	if self.is_open_table then
		self.is_open_table:SetValue(state)
	end
end
