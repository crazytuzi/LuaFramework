YunbiaoViewMain = YunbiaoViewMain or BaseClass(BaseRender)

local delay_time = 0.3
function YunbiaoViewMain:__init(instance)
	local activity_config = ConfigManager.Instance:GetAutoConfig("daily_act_cfg_auto")
	self.husong_cfg = ListToMapList(activity_config.show_cfg, "act_id")
	if instance == nil then
		return
	end
	self.toggle = self:FindObj("Toggle").toggle
	self.auto_toggle = self:FindObj("AutoToggle").toggle

	self.toggle.isOn = YunbiaoData.Instance:GetToggleRed() or false
	self.is_auto_buy_value = false

	self.carriage = {}
	self.model_play_list = {}
	for i = 1, 5 do
		self.carriage[i] = {}
		self.carriage[i].show_high_light = self:FindVariable("ShowHighLight" .. i)
		self.carriage[i].exp = self:FindVariable("Exp" .. i)
		self.carriage[i].mache = YunbiaoMaCheCell.New(self:FindObj("MaChe" .. i))
		self.model_play_list[i] = self:FindObj("modeldisplay_"..i)
	end

	self.free_times = self:FindVariable("FreeTimes")
	self.rest_count = self:FindVariable("RestCount")
	self.buy_count = self:FindVariable("BuyCount")
	self.lingpai_count = self:FindVariable("LingPaiCount")
	self.cost_count = self:FindVariable("CostCount")
	self.str_color = self:FindVariable("Color")
	self.start_husong_btn = self:FindObj("StartHusongBtn")
	self.turntable_info = TurntableInfoCell.New(self:FindObj("Turntable"))

	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickEnter",
		BindTool.Bind(self.DealClickHuSong, self))
	self:ListenEvent("OnClickFlush",
		BindTool.Bind(self.OnClickFlush, self))
	self:ListenEvent("OnClickPlus",
		BindTool.Bind(self.OnClickPlus, self))
	self:ListenEvent("OnClickHelp",
		BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickToggleRed",
		BindTool.Bind(self.OnClickToggleRed, self))
	-- self:ListenEvent("OnClickToggleAuto",
	-- 	BindTool.Bind(self.OnClickToggleAuto, self))

	self.last_color = YunbiaoData.Instance:GetTaskColor() or 1
	self.guide_husong_color = 0

	self.item_change = BindTool.Bind(self.ItemChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change)

	self.cost_count:SetValue(1)
	self:ItemChange()

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.YunbiaoView, BindTool.Bind(self.GetUiCallBack, self))
	self:Flush()
	self:FlushModel()
end

function YunbiaoViewMain:__delete()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.YunbiaoView)
	end

	self:RemoveCountDown()
	if self.item_change then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end

	for k,v in pairs(self.carriage) do
		if v.mache then
			v.mache:DeleteMe()
		end
	end
	self.carriage = {}

	if self.turntable_info then
		self.turntable_info:DeleteMe()
	end

	for i = 1, 5 do
		if nil ~= self.model[i] then
			self.model[i]:ClearModel()
			self.model[i]:DeleteMe()
		end
	end
end

function YunbiaoViewMain:FlushModel()
	local task_reward_factor_list = ConfigManager.Instance:GetAutoConfig("husongcfg_auto").task_reward_factor_list
	self.model = {}
	for i = 1, 5 do
		if nil == self.model[i] then
			local dispalay_name = "escort_panel_"..i
			self.model[i] = RoleModel.New(dispalay_name)
			self.model[i]:SetDisplay(self.model_play_list[i].ui3d_display)
		end
		local asset, bundle = ResPath.GetNpcModel(task_reward_factor_list[i].show_model)
		self.model[i]:SetMainAsset(asset, bundle, complete_callback)
	end
end

function YunbiaoViewMain:SetGuideHusongColor(color)
	self.guide_husong_color = color
end

--转换财富
function YunbiaoViewMain:ConverMoney(value)
	local husong_act_isopen = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HUSONG)
	value = tonumber(value)
	local result = nil
	if value >= 100000 and value < 100000000 then
		result = ToColorStr(math.floor(value / 10000) .. Language.Common.Wan, TEXT_COLOR.WHITE)
		if husong_act_isopen then
			result = ToColorStr(math.floor(value / 10000) .. Language.Common.Wan, TEXT_COLOR.WHITE) .. " x2"
		end
		return result
	end
	if value >= 100000000 then
		result = ToColorStr(math.floor(value / 10000) .. Language.Common.Yi, TEXT_COLOR.WHITE)
		if husong_act_isopen then
			result = ToColorStr(math.floor(value / 10000) .. Language.Common.Yi, TEXT_COLOR.WHITE) .. " x2"
		end
		return result
	end
	return value
end

function YunbiaoViewMain:Flush()
	local free_times = YunbiaoData.Instance:GetFreeRefreshNum()
	self.free_times:SetValue(free_times)
	local rest_count = math.max(0, YunbiaoData.Instance:GetHusongRemainTimes())
	self.rest_count:SetValue(rest_count)
	local buy_count = math.max(0, YunbiaoData.Instance:GetMaxGoumaiNum())
	self.buy_count:SetValue(buy_count)

	local husong_act_isopen = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HUSONG)
	local reward_config = YunbiaoData.Instance:GetRewardConfig()
	if reward_config then
		for i = 1, 5 do
			if reward_config[i] then
				local exp = reward_config[i].exp or 0
				local str = ""
				if exp > 99999999 then
					exp = exp / 100000000
					exp = string.format("%.1f", exp)
					str = ToColorStr(exp .. Language.Common.Yi, TEXT_COLOR.WHITE)
					if husong_act_isopen then
						str = ToColorStr(exp .. Language.Common.Yi, TEXT_COLOR.WHITE).." x2"
					end
				else
					str = self:ConverMoney(exp)
				end
				self.carriage[i].exp:SetValue(str)
			end
		end
	end

	for i = 1, 5 do
		self.carriage[i].show_high_light:SetValue(false)
	end

	if self.guide_husong_color > 0 then
		if self.carriage[self.last_color] then
			self.carriage[self.last_color].mache:StopShake()
			self.carriage[self.last_color].show_high_light:SetValue(false)
		end
		self:FlushHighLight(self.guide_husong_color, self.guide_husong_color)
	else
		local level = YunbiaoData.Instance:GetTaskColor()
		if level > self.last_color then
			self:FlushHighLight(self.last_color + 1, level)
		else
			self:FlushHighLight(self.last_color, level)
		end

		self.last_color = level

		self:ItemChange()
	end
	self.turntable_info:SetShowEffect(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)
end

function YunbiaoViewMain:Close()
	ViewManager.Instance:Close(ViewName.YunbiaoView)
end

function YunbiaoViewMain:FlushHighLight(last_color, next_color)
	if last_color < 1 or next_color > 5 then return end
	self:RemoveCountDown()
	self.carriage[last_color].show_high_light:SetValue(true)
	self.carriage[last_color].mache:StartShake()
	self.count_down = CountDown.Instance:AddCountDown((next_color - last_color + 1) * delay_time, delay_time,
		function()
			if self.carriage[last_color - 1] then
				self.carriage[last_color - 1].mache:StopShake()
				self.carriage[last_color - 1].show_high_light:SetValue(false)
			end
			if self.carriage[last_color] then
				self.carriage[last_color].mache:StartShake()
				self.carriage[last_color].show_high_light:SetValue(true)
			end
			last_color = last_color + 1
		end)
end

function YunbiaoViewMain:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function YunbiaoViewMain:OnClickFlush()
	if YunbiaoData.Instance:GetTaskColor() ~= 5 then
		if self.toggle.isOn then
			local describe = Language.YunBiao.YiJianAlert
			local yes_func = function() YunbiaoCtrl.Instance.Instance:SendRefreshHusongTask(1, 1) end
			TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
		else
			local auto_buy = self.is_auto_buy_value
			local number = ItemData.Instance:GetItemNumInBagById(YunbiaoData.Instance.yunbiao_item_id)
			local free_times = YunbiaoData.Instance:GetFreeRefreshNum()
			if number < 1 and free_times < 1 then
				if auto_buy then
					YunbiaoCtrl.Instance.Instance:SendRefreshHusongTask(0, 1)
				else
					local func = function(item_id, num, is_bind, is_tip_use, is_buy_quick)
					 	ExchangeCtrl.Instance:SendCSShopBuy(item_id, num, is_bind, is_tip_use, 0, 0)
					 	self.is_auto_buy_value = is_buy_quick
					end
					TipsCtrl.Instance:ShowCommonBuyView(func, YunbiaoData.Instance.yunbiao_item_id, nil, 1)
				end
			else
				YunbiaoCtrl.Instance.Instance:SendRefreshHusongTask(0, 0)
			end
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.MaxLevel)
	end
end

function YunbiaoViewMain:OnClickPlus()
	local free_count = YunbiaoData.Instance:GetFreeHusongNum()
	local max_count = YunbiaoData.Instance:GetMaxGoumaiNum()
	local describe = ""
	local yes_func = nil
	-- if free_count > 0 then
	-- 	describe = string.format(Language.YunBiao.GouMaiTips1, ToColorStr(free_count, TEXT_COLOR.GREEN))
	local goumaicishu = YunbiaoData.Instance:GetGouMaiCishu() + 1
	if max_count > 0 then
		local gold_cost = ConfigManager.Instance:GetAutoConfig("husongcfg_auto").buy_times_cfg[goumaicishu].gold_cost
		describe = string.format(Language.YunBiao.GouMaiTips3, "<color=#0000f1>"..gold_cost.."</color>", "<color=#0000f1>"..goumaicishu.."</color>")
		yes_func = function() YunbiaoCtrl.Instance:SendHusongBuyTimes() end
	elseif goumaicishu - 1 < YunbiaoData.Instance:GetMaxGoumaiCiShu() then
		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.HUSONG_BUY_TIMES)
		return
	else
		describe = Language.YunBiao.GouMaiTips2
	end

	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

-- 接护送任务
function YunbiaoViewMain:DealClickHuSong()
	if self.guide_husong_color > 0 then
		self.guide_husong_color = 0
		self:Close()
		return
	end

	local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
	if scene_key ~= 0 then
		local describe = Language.YunBiao.CanNotRceive
		local yes_func = function() Scene.SendChangeSceneLineReq(0) end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
		return
	end
	local act_isopen = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HUSONG)
	if act_isopen then
		self:SendHusongReq()
	else
		local describe = Language.YunBiao.HuoDongShiJian
		local yes_func = BindTool.Bind(self.SendHusongReq, self)
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function YunbiaoViewMain:SendHusongReq()
	local task_id = YunbiaoData.Instance:GetTaskIdByCamp()
	if task_id then
		TaskCtrl.SendTaskAccept(task_id)
	end
end

function YunbiaoViewMain:OnClickHelp()
	local str = self.husong_cfg[3][1].play_introduction
	TipsCtrl.Instance:ShowHelpTipView(str)
end

function YunbiaoViewMain:OnClickToggleRed(state)
	YunbiaoData.Instance:SetToggleRed(state)
end

-- function YunbiaoViewMain:OnClickToggleAuto(state)
-- 	self.is_auto_buy_value = state
-- end

function YunbiaoViewMain:ItemChange()
	local count = ItemData.Instance:GetItemNumInBagById(YunbiaoData.Instance.yunbiao_item_id) or 0
	local color = TEXT_COLOR.PURPLE2
	if count <= 0 then
		color = TEXT_COLOR.RED2
	end
	self.str_color:SetValue(color)
	self.lingpai_count:SetValue(count)
end

function YunbiaoViewMain:GetUiCallBack(ui_name, ui_param)
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end

	return nil
end

------------------------------------------------------------------MaChe---------------------------------------------------------------

YunbiaoMaCheCell = YunbiaoMaCheCell or BaseClass(BaseCell)

function YunbiaoMaCheCell:__init()
	self.box_close = self:FindObj("BoxClose")
	self.box_open = self:FindObj("BoxOpen")
	self.box_close:SetActive(true)
	self.box_open:SetActive(false)
	--self.anim = self.box_close:GetComponent(typeof(UnityEngine.Animator))
end

function YunbiaoMaCheCell:__delete()
	self:RemoveDelayTime()
end

function YunbiaoMaCheCell:StartShake()
	self.box_open:SetActive(false)
	self.box_close:SetActive(true)
	--if self.anim then
		--self.anim:SetBool("Shake", true)
	--end
	self:RemoveDelayTime()
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:OpenBox() end, 0.5)
end

function YunbiaoMaCheCell:StopShake()
	self.box_open:SetActive(false)
	self.box_close:SetActive(true)
	--if self.anim then
		--self.anim:SetBool("Shake", false)
	--end
	self:RemoveDelayTime()
end

function YunbiaoMaCheCell:OpenBox()
	self:RemoveDelayTime()
	self.box_open:SetActive(true)
	self.box_close:SetActive(false)
	--if self.anim then
		--self.anim:SetBool("Shake", false)
	--end
end

function YunbiaoMaCheCell:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end