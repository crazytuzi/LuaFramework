GoPawnContentView = GoPawnContentView or BaseClass(BaseRender)

function GoPawnContentView:__init(instance)
	GoPawnContentView.Instance = self
	self.item_list = {}
	self.move_obj = self:FindObj("move_obj")
	for i=1,25 do
		self.item_list[i] = {}
		self.item_list[i].item_pos = self:FindObj("grid_" .. i)
		if i < 25 then
			self.item_list[i].item_box_active = self:FindVariable("open_grid_" .. i)
		end
	end
	self.show_crap_list = {}
	for i=1,6 do
		self.show_crap_list[i] = self:FindObj("crap_show_" .. i)
	end
	self.turn_crap_content = self:FindObj("turn_craps_list")
	self:ListenEvent("start_click", BindTool.Bind(self.OnStartClick, self))
	self:ListenEvent("question_click", BindTool.Bind(self.OnQuestionClick, self))
	self:ListenEvent("toggle_click", BindTool.Bind(self.ToggleOnClick, self))
	self:ListenEvent("go_reward_click", BindTool.Bind(self.GoRewardOnClick, self))
	self:ListenEvent("tips_close", BindTool.Bind(self.TipsCloseOnClick, self))
	self:ListenEvent("reset_btn_click", BindTool.Bind(self.ResetBtnClick, self))
	self.remain_count_text = self:FindVariable("remain_count")
	self.cash_coupon_text = self:FindVariable("cash_coupon_text")
	self.is_show_tips = self:FindVariable("is_show_tips")
	self.is_show_block = self:FindVariable("is_show_block")
	self.show_start_btn = self:FindVariable("show_start_btn")
	self.show_reset_btn = self:FindVariable("show_reset_btn")
	self.active_slider = self:FindVariable("active_slider")
	self.current_exp_text = self:FindVariable("current_exp_text")
	self.remain_reset_count_text = self:FindVariable("remain_reset_count_text")
	self.show_reset_tips = self:FindVariable("show_reset_tips")
	self.show_red_point = self:FindVariable("show_red_point")
	self.reset_btn = self:FindObj("reset_btn")
	local handler = function()
			local close_call_back = function()
				self.item_cell:SetToggle(false)
			end
			self.item_cell:SetToggle(true)
			TipsCtrl.Instance:OpenItem(self.item_cell:GetData(), nil, nil, close_call_back)
		end
	self.item_cell = ItemCell.New(self:FindObj("item_cell"))
	self.item_cell:ListenClick(handler)
	local huo_yue_cfg = GoPawnData.Instance:GetHuoYueCfg()
	local data = ItemData.Instance:GetItemConfig(huo_yue_cfg.item_id)
	data.item_id = huo_yue_cfg.item_id
	data.is_bind = 1
	data.num = huo_yue_cfg.num
	self.item_cell:SetData(data)
	self.is_show_tips:SetValue(false)
	self.current_index = 1
	self.animator = self.turn_crap_content.animator
	GoPawnCtrl.Instance:SendMoveChessFreeInfo(1)
	self.is_init = true
	self.is_use_cash_coupon = 1  --默认使用代金券
	local item_id = GoPawnData.Instance:GetOtherCfg().item1.item_id
	local item_count = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(item_id), item_id)
	self.cash_coupon_text:SetValue(item_count)
	self.item_data_event = nil
	self:SetNotifyDataChangeCallBack()
end

function GoPawnContentView:__delete()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function GoPawnContentView:MoveCrap(number)
	local loop_tweener = self.move_obj.loop_tweener
	if loop_tweener ~= nil then
		loop_tweener:Play()
	end
	timer = number * 0.5
	self.time_quest = GlobalTimerQuest:AddDelayTimer(function()
		local item = self.move_obj
		local path = {}
		local the_first = self.current_index - number
		local the_end = self.current_index
		if the_end >= 25 then
			the_end = 25
			timer = (the_end - (self.current_index - number)) * 0.5
		end
		for i = the_first, the_end do
			local pos = self.item_list[i].item_pos.transform.position
			table.insert(path, pos)
		end
		local tweener = item.transform:DOPath(
			path,
			timer,
			DG.Tweening.PathType.Linear,
			DG.Tweening.PathMode.TopDown2D,
			1,
			nil)
		tweener:SetEase(DG.Tweening.Ease.Linear)
		tweener:SetLoops(0)
		self.move_obj.loop_tweener = tweener
	end, 0)
end

function GoPawnContentView:OnStartClick()
	if ItemData.Instance:GetEmptyNum() < 6  then
		TipsCtrl.Instance:ShowSystemMsg("剩余背包不足6个，无法挑战")
		return
	end

	local func = function()
		self:GoToChallenge()
	end

	local free_times = GoPawnData.Instance:GetChessInfo().move_chess_free_times
	local cfg = GoPawnData.Instance:GetOtherCfg()
	if free_times < cfg.free_times_per_day then --如果有免费次数
		self:GoToChallenge()
		return
	end
	local tips_text = "是否花费"..cfg.consume_gold_count.."钻石挑战幻境寻宝"
	if self.is_use_cash_coupon == 1 then  --选择使用霸王金券
		local item_count = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(cfg.item1.item_id),cfg.item1.item_id)
		local ba_wang_quan_cfg = cfg.item1.num
		if item_count < ba_wang_quan_cfg then
			if UnityEngine.PlayerPrefs.GetInt("use_gold") == 1 then
				self:GoToChallenge()
			else
				TipsCtrl.Instance:ShowCommonTip(func, nil, tips_text, nil, nil, true, false, "use_gold")
			end
		else
			local tip_text_2 = "\n花费减少"..cfg.consume_gold_count.."(霸王金券:"..cfg.item1.num.."个)"
			tip_text_2 = ToColorStr(tip_text_2, COLOR.YELLOW)
			if UnityEngine.PlayerPrefs.GetInt("use_quan") == 1 then
				self:GoToChallenge()
			else
				TipsCtrl.Instance:ShowCommonTip(func, nil, tips_text .. tip_text_2, nil, nil, true, false, "use_quan")
			end
		end
	else
		if UnityEngine.PlayerPrefs.GetInt("use_gold") == 1 then
			self:GoToChallenge()
		else
			TipsCtrl.Instance:ShowCommonTip(func, nil, tips_text, nil, nil, true, false, "use_gold")
		end
	end
end

function GoPawnContentView:GoToChallenge()
	if self.current_index >= 25 then
		return
	end
	local cfg = GoPawnData.Instance:GetOtherCfg()
	local item_count = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(cfg.item1.item_id),cfg.item1.item_id)
	local free_times = GoPawnData.Instance:GetChessInfo().move_chess_free_times
	local price = cfg.consume_gold_count
	local ba_wang_quan_cfg = cfg.item1.num
	if self.is_use_cash_coupon == 1 then
		if free_times == cfg.free_times_per_day and item_count < ba_wang_quan_cfg and GameVoManager.Instance:GetMainRoleVo().gold < price then
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		end
	else
		if free_times == cfg.free_times_per_day and GameVoManager.Instance:GetMainRoleVo().gold < price then
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		end
	end
	self.turn_crap_content:SetActive(true)
	self.is_show_block:SetValue(true)
	GoPawnCtrl.Instance:SendGetPointReq()
end

function GoPawnContentView:OnQuestionClick()
	TipsCtrl.Instance:ShowHelpTipView(Language.GoPawn.GoPawnTips)
end

function GoPawnContentView:ToggleOnClick(is_click)
	if is_click then
		self.is_use_cash_coupon = 1
	else
		self.is_use_cash_coupon = 0
	end
end

function GoPawnContentView:GoRewardOnClick()
	GoPawnCtrl.Instance:GetView():OnCloseBtnClick()
	ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao)
end

function GoPawnContentView:TipsCloseOnClick()
	self.is_show_tips:SetValue(false)
end

function GoPawnContentView:CheckBtnState()
	local move_info = GoPawnData.Instance:GetChessInfo()
	if move_info.move_chess_cur_step >= GO_PAWN_MAX_STEP then
		self.show_start_btn:SetValue(false)
		self.show_reset_btn:SetValue(true)
	else
		self.show_start_btn:SetValue(true)
		self.show_reset_btn:SetValue(false)
	end
	if move_info.move_chess_reset_times >=2 then
		self.reset_btn.grayscale.GrayScale = 255
		self.reset_btn.button.interactable = false
	else
		self.reset_btn.grayscale.GrayScale = 0
		self.reset_btn.button.interactable = true
	end
end

function GoPawnContentView:ResetBtnClick()
	local sure_func = function()
		self.current_index = 1
		self.is_init = true
		self.is_show_no_tips = true
		self.is_show_no_tips_2 = true
		GoPawnCtrl.Instance:SendMoveChessResetReq()
		self.show_reset_tips:SetValue(false)
	end
	TipsCtrl.Instance:ShowCommonTip(sure_func, nil, Language.Common.ResetGoPawnDown)
end

function GoPawnContentView:CheckToShowCompeletedTips()
	local move_info = GoPawnData.Instance:GetChessInfo()
	if move_info.move_chess_cur_step >= GO_PAWN_MAX_STEP then
		local item_info_list = GoPawnData.Instance:GetMissionCompeleteList()
		local again_call_back = function()
			self:ResetBtnClick()
			self.show_reset_tips:SetValue(false)
		end
		TipsCtrl.Instance:ShowMissionCompletedView(item_info_list, GoPawnData.Instance:GetOtherCfg().reset_consume_gold, again_call_back)
	end
end

function GoPawnContentView:CalTime(timer)
	local timer_cal = timer + 0.5
	local flag = false
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal < 0.5 and flag == false then
			flag = true
		end
		if flag == true then
			GoPawnCtrl.Instance:SendMoveChessShakeReq(self.is_use_cash_coupon, GoPawnData.Instance:GetChessInfo().move_chess_shake_point)
		end
		if timer_cal < 0 then
			GlobalTimerQuest:CancelQuest(self.time_quest)
		end

		if timer_cal < -0.5 then
			self.is_show_block:SetValue(false)
			GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		end
	end, 0)
end

function GoPawnContentView:CloseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)
end

--隐藏宝箱
function GoPawnContentView:HideBox(the_first, the_end)
	local current_step = the_first
	self.timer_quest_hide_box = GlobalTimerQuest:AddRunQuest(function()
		local target_pos_list = {}
		if the_end > 25 then
			the_end = 25
		end
		for i=the_first + 1, the_end do
			target_pos_list[i] = self.item_list[i].item_pos.transform.position
		end
		local move_pos = self.move_obj.transform.position
		if Vector3.Distance(move_pos, target_pos_list[current_step + 1]) < 1.5 then
			self.item_list[current_step].item_box_active:SetValue(false)
			if current_step == the_end - 1 then
				GlobalTimerQuest:CancelQuest(self.timer_quest_hide_box)
			end
			current_step = current_step + 1
		end
	end, 0)
end

--转动骰子
function GoPawnContentView:CalTurnCrapsTime()
	local timer_cal = 1
	self.animator:SetTrigger("Turn")
	self.cal_turm_craps_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
			for i=1,6 do
				self.show_crap_list[i]:SetActive(false)
			end
		if timer_cal < 0 then
			self.animator:SetTrigger("Close")
			self.turn_crap_content:SetActive(false)
			local step = GoPawnData.Instance:GetChessInfo().move_chess_shake_point
			self.show_crap_list[step]:SetActive(true)
			self.current_index = self.current_index + step
			self:CalTime(0.5 * step)
			self:MoveCrap(step)
			self:HideBox(self.current_index - step, self.current_index)
			GlobalTimerQuest:CancelQuest(self.cal_turm_craps_time_quest)
		end
	end, 0)
end

function GoPawnContentView:InitCrapsPos(step)
	if self.is_init then
		self.current_index = step + 1
		self.move_obj.transform.position = self.item_list[self.current_index].item_pos.transform.position
		if self.current_index - 1 == 1 then
			self.item_list[self.current_index - 1].item_box_active:SetValue(false)
		else
			for i=1,self.current_index - 1 do
				self.item_list[i].item_box_active:SetValue(false)
			end
		end
		if self.current_index == 1 then
			for i=1,24 do
				self.item_list[i].item_box_active:SetValue(true)
			end
		end
		self.is_init = false
		self:CheckBtnState()
	end
end

function GoPawnContentView:GetInitState()
	return self.is_init
end

--移除物品回调
function GoPawnContentView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

-- 设置物品回调
function GoPawnContentView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function GoPawnContentView:ItemDataChangeCallback()
	local item_id = GoPawnData.Instance:GetOtherCfg().item1.item_id
	local item_count = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(item_id),item_id)
	self.cash_coupon_text:SetValue(item_count)
end

function GoPawnContentView:FlushRemainText(free_times)
	self.remain_count_text:SetValue(GoPawnData.Instance:GetFreeCountCfg() - free_times)
end

function GoPawnContentView:SetActiveSlider(exp,value)
	self.current_exp_text:SetValue(exp)
	self.active_slider:SetValue(value)
end

function GoPawnContentView:ShowRemainRestRips()
	local go_pawn_data = GoPawnData.Instance
	local move_info = go_pawn_data:GetChessInfo()
	if move_info.move_chess_cur_step == 24 then
		self.remain_reset_count_text:SetValue(go_pawn_data:GetOtherCfg().reset_time_per_day - move_info.move_chess_reset_times)
		self.show_reset_tips:SetValue(true)
	end
end

function GoPawnContentView:SetRedPoint(red_point)
	self.show_red_point:SetValue(red_point)
end

function GoPawnContentView:FlushRedPoint()
	self.show_red_point:SetValue(GoPawnData.Instance:CheckRedPoint())
end



