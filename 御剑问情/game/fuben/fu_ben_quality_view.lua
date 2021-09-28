--永恒
FuBenQualityView = FuBenQualityView or BaseClass(BaseRender)

function FuBenQualityView:__init(instance)
	self.cur_select_index = FuBenData.Instance:GetQualityDefindIndex()
	-- self.enter_btn = self:FindObj("EnterBtn")
	self.is_can_enter = self:FindVariable("CanEnter")
	self.list_view = self:FindObj("ListView")
	self.list = {}
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListCell, self)
	self.list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.FlushAllHL, self))

	self.item_cells = {}
	self.show_reward_list = {}
	for i = 1, 4 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self:FindObj("ItemCell"..i))
		self.show_reward_list[i] = self:FindVariable("ShowReward" .. i)
	end

	self.open_level = self:FindVariable("OpenLevel")
	self.enter_times = self:FindVariable("BuyTimes")
	self.cur_layer = self:FindVariable("EnterTimes")
	self.total_layer = self:FindVariable("TotalTimes")
	self.left_challenge_times = self:FindVariable("LeftChallengeTimes")
	self.challenge_btn_text = self:FindVariable("ChallengeBtnText")
	self.can_enter_into = self:FindVariable("CanEnterInto")
	self.can_restart = self:FindVariable("CanReStart")
	if self.cur_select_index > 3 then
		self.delay_set_attached = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.JumpToIndex, self), 0.1)
	end
	self:ListenEvent("ClickReStart",BindTool.Bind(self.ClickReStart, self))
	self:ListenEvent("OnClickEnter",BindTool.Bind(self.OnClickEnter, self))
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("AddChallengeTime",BindTool.Bind(self.AddChallengeTime, self))
	self:ListenEvent("ClickChallenge",BindTool.Bind(self.ClickChallenge, self))
	self.turntable_info = TurntableInfoCell.New(self:FindObj("Turntable"))

	-- self:ListenEvent("ClickZhuanPan",BindTool.Bind(self.ClickZhuanPan, self))
	self:FlushView()
end

function FuBenQualityView:CloseCallBack()
	-- body
end

function FuBenQualityView:__delete()
	for k, v in pairs(self.list) do
		if v then
			v:DeleteMe()
		end
	end
	for k, v in pairs(self.item_cells) do
		if v then
			v:DeleteMe()
		end
	end
	self.item_cells = {}
	for k, v in pairs(self.show_reward_list) do
		v = nil
	end
	self.show_reward_list = nil
	self.is_can_enter = nil
	-- self.enter_btn = nil
	self.cur_select_index = 0
	if self.turntable_info ~= nil then
		self.turntable_info:DeleteMe()
	end
	self:RemoveDelayTime()
end

function FuBenQualityView:RemoveDelayTime()
	if self.delay_set_attached then
		GlobalTimerQuest:CancelQuest(self.delay_set_attached)
		self.delay_set_attached = nil
	end
end

function FuBenQualityView:JumpToIndex()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		local jump_index = self.cur_select_index
		-- jump_index = 6 - jump_index
		local scrollerOffset = 0
		local cellOffset = -1.7
		local useSpacing = false
		local scrollerTweenType = self.list_view.scroller.snapTweenType
		local scrollerTweenTime = 0
		local scroll_complete = function()
		end
		self.list_view.scroller:JumpToDataIndex(
			jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
	end
end

function FuBenQualityView:OpenCallBack()
	FuBenCtrl.Instance:ReqChallengeFbInfo()
	self:FlushCurInfo()
end

function FuBenQualityView:GetNumberOfCells()
	return  FuBenData.Instance:GetChallengCfgLength()
end

function FuBenQualityView:RefreshListCell(cell, data_index)
	local qualit_item = self.list[cell]
	if qualit_item == nil then
		qualit_item = QualityItem.New(cell.gameObject)
		qualit_item.root_node.toggle.group = self.list_view.toggle_group
		qualit_item.parent_view = self
		self.list[cell] = qualit_item
	end
	local fb_cfg = FuBenData.Instance:GetChallengCfgByLevel(data_index)
	local data = {}
	data.cfg = fb_cfg
	data.index = data_index
	qualit_item:SetData(data)
end

function FuBenQualityView:FlushAllHL()
	for k,v in pairs(self.list) do
		v:FlushHL()
		v:ShowPowerValue()
	end
end

function FuBenQualityView:FlushView()
	self:FlushListInfo()
	self:FlushCurInfo()
	self:FlushAllHL()
end

function FuBenQualityView:IsShowEffect()
	self.turntable_info:SetShowEffect(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)
end

function FuBenQualityView:FlushListInfo()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

function FuBenQualityView:FlushCurInfo()
	self.can_enter_into:SetValue(true)
	local fb_cfg = FuBenData.Instance:GetChallengCfgByLevel(self.cur_select_index)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local str_level = string.format(Language.Mount.ShowGreenNum, fb_cfg.role_level)
	if level < fb_cfg.role_level then
		str_level = string.format(Language.Mount.ShowRedNum, fb_cfg.role_level)
	end
	-- self.open_level:SetValue(str_level)

	for k, v in pairs(self.item_cells) do
		v:SetActive(false)
		self.show_reward_list[k]:SetValue(false)
		if fb_cfg["drop_item_"..k] ~= "" then
			self.show_reward_list[k]:SetValue(true)
			v:SetActive(true)
			v:SetData({item_id = fb_cfg["drop_item_"..k]})
		end
	end
	local fb_info = FuBenData.Instance:GetOneLevelChallengeInfoByLevel(self.cur_select_index)
	local can_enter = FuBenData.Instance:GetCanEnterByLevel(self.cur_select_index) and (fb_info.state == 0 or fb_info.state == 2)
	-- self.enter_btn.grayscale.GrayScale = can_enter and 0 or 255
	self.is_can_enter:SetValue(can_enter)

	self.total_layer:SetValue(FuBenData.Instance:GetTotalLayerByLevel(self.cur_select_index))
	local cur_fight_layer = fb_info.fight_layer >= 0 and fb_info.fight_layer or 0
	self.cur_layer:SetValue(cur_fight_layer)

	local enter_time_str = string.format(Language.Mount.ShowGreenNum, 1)
	if not can_enter then
		enter_time_str = string.format(Language.Mount.ShowRedNum, 0)
	end
	self.enter_times:SetValue(enter_time_str)

	self:ButtonAndButtonTextShow(fb_info)
end

function FuBenQualityView:ButtonAndButtonTextShow(fb_info)
	local fb_info = fb_info
	local other_cfg = FuBenData.Instance:GetChallengMaxOtherCfg()
	if nil == fb_info or nil == other_cfg then return end

	local buy_times = FuBenData.Instance:GetQualityBuyCount()
	local enter_times = FuBenData.Instance:GetQualityEnterCount()
	local challenge_btn_text = Language.FuBen.Challnge
	local can_restart = true
	local can_enter = true

	--按钮文字
	if fb_info.history_max_reward >= other_cfg.auto_need_star then
		challenge_btn_text = Language.FuBen.Auto
	elseif fb_info.is_continue == 1 then
		challenge_btn_text = Language.FuBen.Continue
	end
	self.challenge_btn_text:SetValue(challenge_btn_text)

	--是否能重置
	if fb_info.is_continue <= 0 then
		can_restart = false
	end
	self.can_restart:SetValue(can_restart)

	--计算剩余挑战次数
	local day_free_times = other_cfg.day_free_times
	local total_times = day_free_times + buy_times
	local left_times = total_times - enter_times
	self.left_challenge_times:SetValue(left_times)

	--是否能进入
	if fb_info.is_pass > 0 and left_times <= 0 and fb_info.is_continue <= 0 then
		can_enter = false
	end
	self.can_enter_into:SetValue(can_enter)
end

function FuBenQualityView:OnToggleChange(index)
	self.cur_select_index = index
	self:FlushCurInfo()
	self:FlushAllHL()
end

function FuBenQualityView:GetCurIndex()
	return self.cur_select_index
end

function FuBenQualityView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(186)
end

function FuBenQualityView:ClickChallenge()
	local other_cfg = FuBenData.Instance:GetChallengMaxOtherCfg()
	if nil == other_cfg then
		return
	end

	local fb_info = FuBenData.Instance:GetOneLevelChallengeInfoByLevel(self.cur_select_index)
	if fb_info.history_max_reward >= other_cfg.auto_need_star then
		--星级足够（可扫荡副本）
		local function ok_callback()
			FuBenCtrl.Instance:SendChallengeFBReq(CHALLENGE_FB_OPERATE_TYPE.CHALLENGE_FB_OPERATE_TYPE_AUTO_FB, self.cur_select_index)
		end
		local des = Language.FuBen.AffirmMoppinGup
		TipsCtrl.Instance:ShowCommonAutoView("1", des, ok_callback)
	else
		FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_CHALLENGE, self.cur_select_index)
	end
end

function FuBenQualityView:AddChallengeTime()
	local other_cfg = FuBenData.Instance:GetChallengMaxOtherCfg()
	if nil == other_cfg then
		return
	end
	local buy_max_times = other_cfg.buy_max_times or 0
	local buy_times = FuBenData.Instance:GetQualityBuyCount()
	if buy_times >= buy_max_times then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.AddChallengeMaxDes)
		return
	end

	local cost = FuBenData.Instance:GetCostGoldByTimes(buy_times)
	local des = string.format(Language.FuBen.AddChallengeDes, cost)
	local function ok_callback()
		FuBenCtrl.Instance:SendChallengeFBReq(CHALLENGE_FB_OPERATE_TYPE.CHALLENGE_FB_OPERATE_TYPE_BUY_TIMES)
	end
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
end

function FuBenQualityView:ClickReStart()
	local fb_cfg = FuBenData.Instance:GetChallengCfgByLevel(self.cur_select_index)
	local des = string.format(Language.FuBen.ResetTip, fb_cfg.fbname)
	local function ok_callback()
		FuBenCtrl.Instance:SendChallengeFBReq(CHALLENGE_FB_OPERATE_TYPE.CHALLENGE_FB_OPERATE_TYPE_RESET_FB, self.cur_select_index)
	end
	TipsCtrl.Instance:ShowCommonAutoView("quality_restart", des, ok_callback)
end

function FuBenQualityView:ClickZhuanPan()
	ViewManager.Instance:Open(ViewName.Welfare, TabIndex.welfare_goldturn)
end

function FuBenQualityView:OnClickEnter()
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_CHALLENGE, self.cur_select_index)
	FuBenCtrl.Instance:CloseView()
end

QualityItem = QualityItem or BaseClass(BaseRender)

function QualityItem:__init()
	self.parent_view = nil
	self.had_active = self:FindVariable("HadActive")
	self.raw_image = self:FindVariable("RawImage")
	self.fb_name = self:FindVariable("FbName")
	self.last_name = self:FindVariable("LastName")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.can_click_btn = self:FindVariable("CanClickBtn")
	self.btn_text = self:FindVariable("BtnText")
	self.show_cost_money = self:FindVariable("ShowCostMoney")
	self.show_finish = self:FindVariable("ShowFinish")
	self.cost_mony_text = self:FindVariable("CostMoney")
	self.is_show_power = self:FindVariable("IsShowPower")
	self.power_value = self:FindVariable("PowerValue")

	self.anim = self:FindObj("Anim")
	self.star_list = {}
	for i = 1, 3 do
		self.star_list[i] = self:FindObj("Star" .. i)
	end
	self.state = -1

	self.item_list = {}
	for i = 1, 2 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item" .. i))
		item_cell:SetData(nil)
		table.insert(self.item_list, item_cell)
	end

	self:ListenEvent("OnClickChallenge",BindTool.Bind(self.OnClickChallenge, self))
	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickItem, self))
end

function QualityItem:__delete()
	self.parent_view = nil
	self.had_active = nil
	self.raw_image = nil
	self.fb_name = nil
	self.last_name = nil
	self.show_red_point = nil
	self.can_click_btn = nil
	self.btn_text = nil
	self.show_cost_money = nil
	self.show_finish = nil
	self.anim = nil
	self.is_show_power = nil
	self.power_value = nil
	self.state = -1
	for _, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function QualityItem:OnClickChallenge()
	if self.state == -1 then return end
	if self.state == 1 or self.state == 2  or self.state == 3 then
		FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_CHALLENGE, self.data.index)
		FuBenCtrl.Instance:CloseView()
	elseif self.state == 4 then
		self:OnClickReset()
	elseif self.state == 5 then 
		FuBenCtrl.Instance:SendChallengeFBReq(CHALLENGE_FB_OPERATE_TYPE.CHALLENGE_FB_OPERATE_TYPE_AUTO_FB, self.data.cfg.level)
	elseif self.state == 6 then
		self:OnClickAuto()
	end
end

function QualityItem:OnClickReset()
	local func = function()
		FuBenCtrl.Instance:SendChallengeFBReq(CHALLENGE_FB_OPERATE_TYPE.CHALLENGE_FB_OPERATE_TYPE_RESET_FB, self.data.cfg.level)
	end
	local other_cfg = FuBenData.Instance:GetChallengOtherCfg()
	local str = string.format(Language.FuBen.BuyResetTip, other_cfg.reset_cost)
	TipsCtrl.Instance:ShowCommonTip(func, nil, str)
end

function QualityItem:OnClickAuto()
	local func = function()
		FuBenCtrl.Instance:SendChallengeFBReq(CHALLENGE_FB_OPERATE_TYPE.CHALLENGE_FB_OPERATE_TYPE_RESET_AND_AUTO, self.data.cfg.level)
	end
	local other_cfg = FuBenData.Instance:GetChallengOtherCfg()
	local str = string.format(Language.FuBen.BuyAutoTip, other_cfg.reset_cost)
	TipsCtrl.Instance:ShowCommonTip(func, nil, str)
end

function QualityItem:OnClickItem()
	local cur_index = self.parent_view:GetCurIndex()
	local is_active = FuBenData.Instance:GetCanEnterByLevel(self.data.index)
	if not is_active then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.OpenReq)
		return
	end
	if cur_index ~= self.data.index then
		self.parent_view:OnToggleChange(self.data.index)
	end
end

function QualityItem:SetData(data)
	if not data then return end
	self.data = data
	self:Flush()
end

function QualityItem:OnFlush()
	if self.data == nil then return end
	self.can_click_btn:SetValue(true)
	local fb_info = FuBenData.Instance:GetOneLevelChallengeInfoByLevel(self.data.index)
	local other_cfg = FuBenData.Instance:GetChallengOtherCfg()
	local can_enter = FuBenData.Instance:GetCanEnterByLevel(self.data.index) and (fb_info.state == 0 or fb_info.state == 2)
	local total_layer = FuBenData.Instance:GetTotalLayerByLevel(self.data.index)
	local cur_layer = fb_info.fight_layer >= 0 and fb_info.fight_layer or 0
	self.fb_name:SetValue(self.data.cfg.fbname .. ToColorStr(cur_layer,TEXT_COLOR.RED) .. ToColorStr("/"..total_layer,TEXT_COLOR.WHITE)) -- 
	self.cost_mony_text:SetValue(other_cfg.gold_cost)
	--local small_key = "quality".. self.data.cfg.level + 1
	local small_key = "quality".. 1
	--local big_key = "Quality".. self.data.cfg.level + 1
	local big_key = "Quality".. 1
	local bundle, asset = ResPath.GetFubenRawImage(small_key, big_key)
	self.raw_image:SetAsset(bundle, asset)
	local is_active = FuBenData.Instance:GetCanEnterByLevel(self.data.index)
	self.had_active:SetValue(is_active)
	self.show_red_point:SetValue((FuBenData.Instance:GetCanEnterByLevel(self.data.index) and (fb_info.state == 0 or fb_info.state == 2) and 
		FuBenData.Instance:IsCanShowQualityEnterByLevel(self.data.index)) or ((fb_info.state == 0 or fb_info.state == 2) and fb_info.history_max_reward >= 3))
	if not is_active then
		local fb_cfg = FuBenData.Instance:GetChallengCfgByLevel(self.data.index - 1)
		self.last_name:SetValue(fb_cfg.fbname)
		self.can_click_btn:SetValue(false)
	end
	if cur_layer <= 0 and fb_info.history_max_reward > 0 then
		self.fb_name:SetValue(self.data.cfg.fbname .. ToColorStr(total_layer,TEXT_COLOR.WHITE) .. ToColorStr("/"..total_layer,TEXT_COLOR.WHITE)) -- 
	end

	for k,v in pairs(self.star_list) do
		v.grayscale.GrayScale = 255
	end
	if fb_info.history_max_reward > 0 then
		for i = 1, fb_info.history_max_reward do
			self.star_list[i].grayscale.GrayScale = 0
		end
	end
	self.show_cost_money:SetValue(false)
	self.show_finish:SetValue(false)
	if fb_info.history_max_reward <= 0 and cur_layer <= 0 then
		self.btn_text:SetValue(Language.FuBen.Challnge)
		self.state = 1
	elseif fb_info.history_max_reward <= 0 and cur_layer > 0 then
		self.btn_text:SetValue(Language.FuBen.Continue)
		self.state = 2
	elseif fb_info.history_max_reward > 0 and can_enter and fb_info.history_max_reward < 3 then
		self.btn_text:SetValue(Language.FuBen.Challnge)
		self.state = 3
	elseif fb_info.history_max_reward > 0 and not can_enter and fb_info.history_max_reward < 3 then
		self.btn_text:SetValue(Language.FuBen.Challnge)
		self.state = 4
		self.show_cost_money:SetValue(true)
	elseif fb_info.history_max_reward > 0 and can_enter and fb_info.history_max_reward >= 3 then
		self.btn_text:SetValue(Language.FuBen.Auto)
		self.state = 5
	elseif fb_info.history_max_reward > 0 and not can_enter and fb_info.history_max_reward >= 3 then
		self.btn_text:SetValue(Language.FuBen.Auto)
		self.state = 6
		self.show_cost_money:SetValue(true)
	end
	if fb_info.state == 3 then
		self.can_click_btn:SetValue(false)
		self.show_cost_money:SetValue(false)
		self.show_finish:SetValue(true)
	end
	--设置奖励信息
	local new_fb_cfg = FuBenData.Instance:GetChallengCfgByLevel(self.data.index)
	for k, v in ipairs(self.item_list) do
		if new_fb_cfg["drop_item_"..k] ~= "" then
			v:SetData({item_id = new_fb_cfg["drop_item_"..k]})
		end
	end
end

function QualityItem:FlushHL()
	if self.data == nil then return end
	local cur_index = self.parent_view:GetCurIndex()
	self.anim.animator:SetBool("fold", self.data.index == cur_index)
end

function QualityItem:ShowPowerValue()
	if self.data == nil then return end

	local cur_index = self.parent_view:GetCurIndex()
	local power_flag = cur_index == self.data.index
	self.is_show_power:SetValue(power_flag)

	if not power_flag then return end

	local fb_info = FuBenData.Instance:GetOneLevelChallengeInfoByLevel(cur_index)
	if nil == fb_info then return end
	local pass_layer = fb_info.fight_layer < 0 and 0 or fb_info.fight_layer
	local layer_cfg = FuBenData.Instance:GetChallengLayerCfgByLevelAndLayer(cur_index, pass_layer)
	if nil == layer_cfg then return end
	local str_fight_power = layer_cfg.zhanli or 0

	self.power_value:SetValue(str_fight_power)
end