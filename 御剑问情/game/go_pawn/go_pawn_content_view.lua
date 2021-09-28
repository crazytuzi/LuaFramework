GoPawnContentView = GoPawnContentView or BaseClass(BaseRender)

function GoPawnContentView:__init(instance)
	GoPawnContentView.Instance = self
	self.item_list = {}
	self.move_obj = self:FindObj("move_eff_obj")
	-- 初始化人物形象
	self.role_model = RoleModel.New()
	self.role_model:SetDisplay(self.move_obj.ui3d_display)
	self.move_obj.ui3d_display:SetRotation(Vector3(0, 210, 0))
	self:SetDisplayInfo()
	self.box_icon_list = {}
	self.ShowOpenItem = {}
	self.item_cells = {}
	for i=1,25 do
		self.item_list[i] = {}
		self.item_list[i].item_pos = self:FindObj("grid_" .. i)
		if i < 25 then
			self.item_list[i].item_box_active = self:FindVariable("open_grid_" .. i)

		end
		if i < 24 then
			self.box_icon_list[i] = self:FindVariable("box_gird_" .. i)
			self.ShowOpenItem[i] = self:FindVariable("ShowOpenItem" .. i)
			self.item_cells[i] = ItemCell.New()
			self.item_cells[i]:SetInstanceParent(self:FindObj("OpenItem" .. i))
		end
	end

	for i = 1,24 do
		self:ListenEvent("OnGridClick_"..i, BindTool.Bind(self.OnGridClick, self, i))
	end

	self.show_crap_list = {}
	for i = 1,6 do
		self.show_crap_list[i] = self:FindObj("crap_show_" .. i)
	end
	self.turn_crap_content = self:FindObj("turn_craps_list")
	self.show_re_item = {}
	self.re_item = {}
	self.re_item_list = {}
	for i = 1,4 do
		self.re_item[i] = self:FindObj("ReItem" .. i )
		self.re_item_list[i] = ItemCell.New()
		self.re_item_list[i]:SetInstanceParent(self.re_item[i])
		self.show_re_item[i] = self:FindVariable("ShowReItem" .. i)
	end
	self:ListenEvent("start_click", BindTool.Bind(self.OnStartClick, self))
	self:ListenEvent("question_click", BindTool.Bind(self.OnQuestionClick, self))
	self:ListenEvent("tips_close", BindTool.Bind(self.TipsCloseOnClick, self))
	self:ListenEvent("reset_btn_click", BindTool.Bind(self.ResetBtnClick, self))
	self:ListenEvent("guild_gopwan", BindTool.Bind(self.GuildGopwan, self))
	self:ListenEvent("OnAddGold",BindTool.Bind(self.HandleAddGold, self))

	self.remain_count_text = self:FindVariable("remain_count")
	self.cash_coupon_text = self:FindVariable("cash_coupon_text")
	self.is_show_tips = self:FindVariable("is_show_tips")
	self.is_show_block = self:FindVariable("is_show_block")
	self.show_start_btn = self:FindVariable("show_start_btn")
	self.show_reset_btn = self:FindVariable("show_reset_btn")
	self.active_slider = self:FindVariable("active_slider")
	self.current_exp_text = self:FindVariable("current_exp_text")
	self.remain_reset_count_text = self:FindVariable("remain_reset_count_text")
	self.img_icon = self:FindVariable("Icon")
	self.show_reset_tips = self:FindVariable("show_reset_tips")
	self.show_red_point = self:FindVariable("show_red_point")
	self.role_gold = self:FindVariable("role_gold")
	self.dimon_sign_count = self:FindVariable("DimonSignCount")
	self.ResultItem = self:FindVariable("ResultItem")
  	self.obj_diamond_animator = self:FindObj("ItemEffectAni")
	self.reset_btn = self:FindObj("reset_btn")
	self.is_show_tips:SetValue(false)
	self.current_index = 1
	self.animator = self.turn_crap_content.animator
	--GoPawnCtrl.Instance:SendMoveChessFreeInfo()
	self.is_init = true
	self.is_use_cash_coupon = 0  --默认不使用代金券
	local item_id = GoPawnData.Instance:GetOtherCfg().item1.item_id
	local item_count = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(item_id), item_id)
	self.cash_coupon_text:SetValue(item_count)

	local other_cfg = GoPawnData.Instance:GetOtherCfg()
	self.dimon_sign_count:SetValue(math.floor(other_cfg.consume_gold_count / other_cfg.item1.num))
	self.item_data_event = nil
	self:SetNotifyDataChangeCallBack()
	-- 单次调用某些功能
	self.asgin_flag = false
	self:ShowRemainRestRips()
	self.ShowItemAni = self:FindVariable("ShowItemAni")
	self.ShowItemAni:SetValue(false)
	self.get_item = ItemCell.New()
	self.get_item:SetInstanceParent(self:FindObj("GetItemAni"))
end

function GoPawnContentView:__delete()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

 	if nil ~= self.get_item then
		self.get_item:DeleteMe()
		self.get_item = nil
	end

 	if self.reward_item_cells then
 		self.reward_item_cells:DeleteMe()
 		self.reward_item_cells = nil
 	end

	for k,v in pairs(self.item_cells) do
		if nil ~= v then
			v:DeleteMe()
			v = nil
		end
	end

	for k,v in pairs(self.re_item_list) do
		if nil ~= v then
			v:DeleteMe()
			v = nil
		end
	end

	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end

	if self.timer_quest_hide_box then
		GlobalTimerQuest:CancelQuest(self.timer_quest_hide_box)
		self.timer_quest_hide_box = nil
	end

	if self.cal_turm_craps_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_turm_craps_time_quest)
		self.cal_turm_craps_time_quest = nil
	end
end

function GoPawnContentView:SetDisplayInfo()
	local main_role = Scene.Instance:GetMainRole()
	self.role_model:SetMainAsset(ResPath.GetRoleModel(main_role.role_res_id))
end

function GoPawnContentView:GuildGopwan()

end

function GoPawnContentView:MoveCrap(number)
	-- 人物跑起来
	self.role_model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
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

-- 调整人物角度
function GoPawnContentView:SetRoleModleFanXiang(step)
	local angle = 10
	if step < 2 then
		angle = 340
	elseif step < 4 then
		angle = 45
	elseif step < 6 then
		angle = 320
	elseif step < 11 then
		angle = 230
	elseif step < 14 then
		angle = 320
	elseif step < 16 then
		angle = 45
	elseif step < 17 then
		angle = 100
	elseif step < 19 then
		angle = 45
	elseif step < 22 then
		angle = 320
	elseif step < 25 then
		angle = 230
	else
		angle = 10
	end
	self.move_obj.ui3d_display:SetRotation(Vector3(0, angle, 0))
end

function GoPawnContentView:OnStartClick()
	if ItemData.Instance:GetEmptyNum() < 6  then
		TipsCtrl.Instance:ShowSystemMsg(Language.GoPawnContenView.BeiNumBuZu)
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
	local tips_text = string.format(Language.GoPawnContenView.TipsText,cfg.consume_gold_count)
	local item_count = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(cfg.item1.item_id),cfg.item1.item_id)
	local ba_wang_quan_cfg = cfg.item1.num
	if item_count >= ba_wang_quan_cfg then
		local tip_text_2 = string.format(Language.GoPawnContenView.TipsText2,cfg.consume_gold_count,cfg.item1.num)
		tip_text_2 = ToColorStr(tip_text_2, COLOR.YELLOW)
		self.is_use_cash_coupon = 1
		TipsCtrl.Instance:ShowCommonAutoView("use_quan1",tips_text .. tip_text_2, func, nil, nil, nil, nil, nil, true, true)
    elseif item_count > 0  then
    	local need_gold_count = cfg.consume_gold_count - (cfg.consume_gold_count / cfg.item1.num * item_count)
    	local tip_text_2 = string.format(Language.GoPawnContenView.TipsText2,need_gold_count,item_count)
		tip_text_2 = ToColorStr(tip_text_2, COLOR.YELLOW)
		self.is_use_cash_coupon = 1
		TipsCtrl.Instance:ShowCommonAutoView("use_quan2",tips_text .. tip_text_2, func, nil, nil, nil, nil, nil, true, true)

	else
		self.is_use_cash_coupon = 0
		TipsCtrl.Instance:ShowCommonAutoView("use_gold1",tips_text, func, nil, nil, nil, nil, nil, true, true)
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
	local need_gold = price - ((price / ba_wang_quan_cfg) * item_count)
	if free_times == cfg.free_times_per_day and GameVoManager.Instance:GetMainRoleVo().gold < need_gold then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end
	self.turn_crap_content:SetActive(true)
	self.is_show_block:SetValue(true)
	-- 请求转动骰子
	GoPawnCtrl.Instance:SendMoveChessShakeReq(self.is_use_cash_coupon,0)
end

function GoPawnContentView:OnQuestionClick()
	local tips_id = 120 -- 幻境寻宝
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function GoPawnContentView:GoRewardOnClick()
	GoPawnCtrl.Instance:GetView():OnCloseBtnClick()
	ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
end

function GoPawnContentView:TipsCloseOnClick()
	self.is_show_tips:SetValue(false)
end
-- 重置投掷骰子次数
function GoPawnContentView:CheckBtnState()
	local move_info = GoPawnData.Instance:GetChessInfo()
	if move_info.move_chess_cur_step >= GO_PAWN_MAX_STEP then
		self.show_start_btn:SetValue(false)
		self.show_reset_btn:SetValue(true)
	else
		self.show_start_btn:SetValue(true)
		self.show_reset_btn:SetValue(false)
	end
	if move_info.move_chess_reset_times >= 2 then
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
	local reset_need_gold = GoPawnData.Instance:GetOtherCfg().reset_consume_gold or 30
	TipsCtrl.Instance:ShowCommonTip(sure_func, nil, string.format(Language.Common.ResetGoPawnDown,reset_need_gold))
end
-- 通关展示界面
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
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime

		-- 超过最大步数后的操作
 		local cha_num = self.current_index - 25
 		local dui_num = cha_num * 0.5 + 0.5
 		if cha_num > 0 then
 			dui_num = cha_num * 0.5 + 0.5
 		else
 			dui_num = 0.5
 		end
		if timer_cal < dui_num then
			if self.asgin_flag then
			    -- 人物停下来
		 		self.role_model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
		 		self.asgin_flag = false
		 		-- 展示奖励物品界面
			 	if self.current_index < 25 then
		 			ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_MOVE_CHESS)
		 		else
		 			self.obj_diamond_animator:SetActive(false)
				end
				self:ShowRemainRestRips()
				self:CheckToShowCompeletedTips()
		 	end
		end

		if timer_cal < 0 then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.ShowItemAni:SetValue(false)
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
	self.obj_diamond_animator:SetActive(true)
	local item_rewart_list = GoPawnData.Instance:GetStepReward()
	if self.timer_quest_hide_box then
		GlobalTimerQuest:CancelQuest(self.timer_quest_hide_box)
		self.timer_quest_hide_box = nil
	end
	self.timer_quest_hide_box = GlobalTimerQuest:AddRunQuest(function()
		local target_pos_list = {}
		if the_end > 25 then
			the_end = 25
		end
		for i= the_first + 1, the_end do
			target_pos_list[i] = self.item_list[i].item_pos.transform.position
		end
		local move_pos = self.move_obj.transform.position
		if Vector3.Distance(move_pos, target_pos_list[current_step + 1]) < 1.5 then
			self.item_list[current_step].item_box_active:SetValue(false)
			if self.item_cells[current_step] then
				self.item_cells[current_step]:SetActive(false)
			end
			self.get_item_animator = self.obj_diamond_animator:GetComponent(typeof(UnityEngine.Animator))
			if self.get_item_animator.isActiveAndEnabled then
				self.get_item_animator:Play("AniItem",0,0)
				self.get_item_animator:SetTrigger("state")
			end
			-- 调整人物角度
			self:SetRoleModleFanXiang(current_step + 1)
			if current_step == the_end - 1 then
				GlobalTimerQuest:CancelQuest(self.timer_quest_hide_box)
			end

			local d_info = item_rewart_list[(current_step + 1) - the_first]
			if d_info then
				local item_info = ItemData.Instance:GetItemConfig(d_info.item_id)
				local bundle, asset = ResPath.GetItemIcon(item_info.icon_id)
				self.get_item:SetData(d_info)
				self.ShowItemAni:SetValue(true)
			end
			current_step = current_step + 1
		end
	end, 0)
end

--转动骰子
function GoPawnContentView:CalTurnCrapsTime()
	local timer_cal = 1
	self.animator:SetTrigger("Turn")
	self.asgin_flag = true
	self.role_gold:SetValue(CommonDataManager.ConverMoney(GameVoManager.Instance:GetMainRoleVo().gold))
	if self.cal_turm_craps_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_turm_craps_time_quest)
		self.cal_turm_craps_time_quest = nil
	end
	self.cal_turm_craps_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		for i=1,6 do
			self.show_crap_list[i]:SetActive(false)
		end
		if timer_cal < 0 then
			self.animator:SetTrigger("Close")

			self.turn_crap_content:SetActive(false)
			local step = GoPawnData.Instance:GetShakePoint()
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
			for i = 1,self.current_index - 1 do
				self.item_list[i].item_box_active:SetValue(false)
			end
		end
		if self.current_index == 1 then
			for i=1,24 do
				self.item_list[i].item_box_active:SetValue(true)
			end
		end
		self.is_init = false
		for i = 1,23 do
			-- 初始化奖励物品
			local ts_reward_list = GoPawnData.Instance:GetTeshuJiangliCfg(i)
			if ts_reward_list and next(ts_reward_list) then
				-- 特殊奖励物品
				self.item_cells[i]:SetData(ts_reward_list)
				self.item_cells[i]:SetActive(true)
				self.ShowOpenItem[i]:SetValue(true)
			else
				if i < 12 then
					local bundle, asset = ResPath.GetGoPawnImg("icon_reward_box_2")
					self.box_icon_list[i]:SetAsset(bundle,asset)
				else
					local bundle, asset = ResPath.GetGoPawnImg("icon_reward_box_1")
					self.box_icon_list[i]:SetAsset(bundle,asset)
				end
			end
		end

		-- 隐藏特殊的奖励格子
		for i = 1,self.current_index - 1 do
			if self.item_cells[i] then
				self.item_cells[i]:SetActive(false)
			end
		end

	end
	-- 初始化人物角度
	self:SetRoleModleFanXiang(step + 1)
	local pawn_state = GoPawnData.Instance:GetShakePoint()
	if pawn_state < 1 then
		pawn_state = 1
	end
	self.show_crap_list[pawn_state]:SetActive(true)
	self.role_gold:SetValue(CommonDataManager.ConverMoney(GameVoManager.Instance:GetMainRoleVo().gold))
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
    local cfg = GoPawnData.Instance:GetOtherCfg()
	local need_dimon_count = cfg.consume_gold_count

	if cfg.free_times_per_day - free_times > 0 then
	 	local miaoshu = string.format(Language.GoPawnContenView.remain_times,(cfg.free_times_per_day - free_times))
 	    self.remain_count_text:SetValue(miaoshu)
 	else
 	 	local item_id = GoPawnData.Instance:GetOtherCfg().item1.item_id
 	    local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local item_count = ItemData.Instance:GetItemNumInBagByIndex(ItemData.Instance:GetItemIndex(item_id), item_id)
 	 	if item_count >= cfg.item1.num then
	 	 	local miaoshu = string.format(Language.GoPawnContenView.ItemTis,cfg.item1.num,item_cfg.name)
	        self.remain_count_text:SetValue(miaoshu)
	    elseif item_count > 0 then
	        local need_some_dimon_count = need_dimon_count - need_dimon_count / cfg.item1.num * item_count
	        local miaoshu = string.format(Language.GoPawnContenView.need_dimon,need_some_dimon_count)
	        self.remain_count_text:SetValue(miaoshu)
        else
        	local miaoshu = string.format(Language.GoPawnContenView.need_dimon,need_dimon_count)
        	self.remain_count_text:SetValue(miaoshu)
  		end
	end
end

function GoPawnContentView:SetActiveSlider(exp,value)
	self.current_exp_text:SetValue(exp)
	self.active_slider:SetValue(value)
end
-- 通过提示剩余挑战次数
function GoPawnContentView:ShowRemainRestRips()
	local go_pawn_data = GoPawnData.Instance
	local move_info = go_pawn_data:GetChessInfo()
	if move_info.move_chess_cur_step == 24 then
		local remain_reset_num = go_pawn_data:GetOtherCfg().reset_time_per_day - move_info.move_chess_reset_times
		self.remain_reset_count_text:SetValue(remain_reset_num)
		self.show_reset_tips:SetValue(true)
		if remain_reset_num > 0 then
			self.ResultItem:SetValue(true)
			self.reward_item_cells = ItemCell.New()
			self.reward_item_cells:SetInstanceParent(self:FindObj("ResetItem"))
			local item_info = GoPawnData.Instance:GetMissionCompeleteList()[4]
			if item_info then
				-- 重置的奖励
				local itemId = item_info.item_id
				local libao_list = ItemData.Instance:GetGiftItemList(itemId)
				if libao_list and next(libao_list) then
					-- 礼包奖励
					for k,v in pairs(self.re_item_list) do
						if libao_list[k] then
							v:SetData(libao_list[k])
							self.show_re_item[k]:SetValue(true)
						end
					end
				else
					-- 非礼包奖励
					self.re_item_list[1]:SetData(item_info)
					self.show_re_item[1]:SetValue(true)
				end
			end
		else
			self.ResultItem:SetValue(false)
		end
	end
end

function GoPawnContentView:SetRedPoint(red_point)
	self.show_red_point:SetValue(red_point)
end

function GoPawnContentView:FlushRedPoint()
	self.show_red_point:SetValue(GoPawnData.Instance:CheckRedPoint())
end

function GoPawnContentView:OnGridClick(i)
	local tittle_name = Language.GoPawnContenView.NormalRewardTips
	if i == 24 then
		tittle_name = Language.GoPawnContenView.LastRewardTips
	end
	TipsCtrl.Instance:ShowRewardView(GoPawnData.Instance:GetRewardListByStep(i), tittle_name)
end

function GoPawnContentView:HandleAddGold()
	print_error("dadfadsfas")
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end