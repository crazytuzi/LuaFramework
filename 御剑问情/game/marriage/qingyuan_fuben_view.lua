QingYuanFuBenView = QingYuanFuBenView or BaseClass(BaseView)

function QingYuanFuBenView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","QingYuanFuBenView"}
	self.time_count = 0
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.MainUILow
	self.is_safe_area_adapter = true
end

function QingYuanFuBenView:__delete()
end

function QingYuanFuBenView:LoadCallBack()
	self:ListenEvent("BuyClick", BindTool.Bind(self.BuyClick, self))
	-- self:ListenEvent("ExitClick", BindTool.Bind(self.ExitClick, self))

	self.victor_panel = QingYuanVictorPanel.New(self:FindObj("VictorPanel"))
	self.victor_panel:SetActive(false)
	self.left_wave = self:FindVariable("LeftWave")
	self.left_time = self:FindVariable("LeftTime")
	self.diamond_cost = self:FindVariable("DiamondCost")
	self.buff_value = self:FindVariable("BuffValue")
	self.buff_left_time = self:FindVariable("BuffTime")			--buff剩余时间
	self.can_buy_buff = self:FindVariable("CanBuyBuff")			--是否可以购买buff
	local cfg = MarriageData.Instance:GetQingYuanFBBuffInfo()
	self.buff_value:SetValue((cfg.buff_gongjing_per / 100).."%")
	self.show_left_panel = self:FindVariable("ShowLeftPanel")

	-- GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end

function QingYuanFuBenView:OnMainUIModeListChange(is_show)
	self.show_left_panel:SetValue(not is_show)
end

function QingYuanFuBenView:ExitClick()
	local func = function()
		FuBenCtrl.Instance:SendExitFBReq()
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Common.ExitFuBen)
end

function QingYuanFuBenView:ReleaseCallBack()
	self.data = nil
	self.left_wave = nil
	self.left_time = nil
	self.diamond_cost = nil
	self.buff_value = nil
	self.buff_left_time = nil
	self.can_buy_buff = nil
	self.show_left_panel = nil

	if nil ~= self.victor_panel then
		self.victor_panel:DeleteMe()
		self.victor_panel = nil
	end

	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
end

function QingYuanFuBenView:OpenCallBack()
	self:Flush()
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Timer, self), 1)
end

function QingYuanFuBenView:SwitchButtonState(enable)
	self.show_left_panel:SetValue(enable)
end

function QingYuanFuBenView:CloseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)
end

function QingYuanFuBenView:BuyClick()
	local cfg = MarriageData.Instance:GetQingYuanFBBuffInfo()
	local gold_need = cfg.cost_gold * (1 + self.data.buy_buff_times * cfg.add_gold_per * 0.01)

	local function ok_callback()
		MarriageCtrl.Instance:SendBuyFuBenBuff()
	end

	local des = string.format(Language.Common.CostGoldBuyTip, gold_need)
	TipsCtrl.Instance:ShowCommonAutoView("qing_yuan_fuben", des, ok_callback)
end

function QingYuanFuBenView:SetData(data)
	self.data = data

	local time = math.floor(data.per_wave_remain_time - TimeCtrl.Instance:GetServerTime())
	if time > self.time_count then
		self.time_count = time
	end
	if self:IsLoaded() then
		if data.is_finish == 1 then
			time = math.floor(data.kick_out_timestamp - TimeCtrl.Instance:GetServerTime())
			-- self.victor_panel:ShowView(data.total_get_uplevel_stuffs, time)
		else
			self:Flush()
		end
	end
end

function QingYuanFuBenView:Flush()
	self.refresh_tmp_time = self.data.next_refresh_monster_time - TimeCtrl.Instance:GetServerTime()
	if self.refresh_tmp_time > 0 then
		local color = "#00ff90"
		self.left_time:SetValue(ToColorStr(math.floor(self.refresh_tmp_time), color)..Language.Marriage.Flush_Monster)
	end

	local buff_out_timestamp = self.data.buff_out_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	if buff_out_timestamp <= 0 or buff_out_timestamp < server_time then
		self.can_buy_buff:SetValue(true)
	else
		self.can_buy_buff:SetValue(false)
	end

	local cfg = MarriageData.Instance:GetQingYuanFBBuffInfo()
	local gold_need = cfg.cost_gold * (1 + self.data.buy_buff_times * cfg.add_gold_per * 0.01)
	self.diamond_cost:SetValue(gold_need)
	self.left_wave:SetValue(self.data.curr_wave.."/"..self.data.max_wave_count)
	self:SetTime()
	self:SetBuffLeftTime()
end

function QingYuanFuBenView:Timer()
	self.time_count = self.time_count - 1
	if self.time_count < 0 then
		return
	end
	self:SetTime()
	self:SetBuffLeftTime()
end

function QingYuanFuBenView:SetTime()
	if self.refresh_tmp_time > 0 then
		return
	end

	local min = math.floor(self.time_count / 60)
	local sec = self.time_count - (min * 60)
	if min < 10 then
		min = "0"..min
	end
	if sec < 10 then
		sec = "0"..sec
	end
	local color = "#00ff90"
	local text = Language.Marriage.Left_Time..ToColorStr(min..":"..sec, color)
	self.left_time:SetValue(text)
end

function QingYuanFuBenView:SetBuffLeftTime()
	local buff_out_timestamp = self.data.buff_out_timestamp
	local time_str = ""
	local server_time = TimeCtrl.Instance:GetServerTime()
	if buff_out_timestamp <= 0 or buff_out_timestamp < server_time then
		time_str = "00:00"
	else
		local diff_time = buff_out_timestamp - server_time
		diff_time = math.floor(diff_time)
		time_str = TimeUtil.FormatSecond(diff_time, 2)
	end
	self.buff_left_time:SetValue(time_str)
end

------------------VictorPanel-----------------
QingYuanVictorPanel = QingYuanVictorPanel or BaseClass(BaseRender)

function QingYuanVictorPanel:__init()
	self.item_list = {}
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell1"))

	self:ListenEvent("OnClickYes", BindTool.Bind(self.OnClickYes, self))
	self.time = self:FindVariable("Time")
end

function QingYuanVictorPanel:__delete()
	GlobalTimerQuest:CancelQuest(self.time_quest)
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function QingYuanVictorPanel:ShowView(item_num, time)
	self.first = false
	self.time_count = time
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Timer, self), 1)
	self:SetActive(true)
	if item_num > 0 then
		self.item_cell:SetActive(true)
		local item_data = MarriageData.Instance:GetRingUpgradeItem()
		local tmp_data = {}
		tmp_data.item_id = item_data.stuff_id
		tmp_data.num = item_num
		self.item_cell:SetData(tmp_data)
	else
		self.item_cell:SetActive(false)
	end
end

function QingYuanVictorPanel:OnClickYes()
	self:SetActive(false)
	FuBenCtrl.Instance:SendExitFBReq()
end

function QingYuanVictorPanel:SetActive(is_active)
	self.root_node.gameObject:SetActive(is_active)
end

function QingYuanVictorPanel:Timer()
	local time = self.time_count - 1
	if time < 0 then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		return
	end
	self.time_count = time
	self.time:SetValue(self.time_count)
end