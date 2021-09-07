YunbiaoViewMain = YunbiaoViewMain or BaseClass(BaseRender)

local delay_time = 0.3

function YunbiaoViewMain:__init(instance)
	if instance == nil then
		return
	end

	self.toggle = self:FindObj("Toggle").toggle
	self.auto_toggle = self:FindObj("AutoToggle").toggle

	self.carriage = {}
	for i = 1, 5 do
		self.carriage[i] = {}
		self.carriage[i].show_high_light = self:FindVariable("ShowHighLight" .. i)
		self.carriage[i].exp = self:FindVariable("Exp" .. i)
		self.carriage[i].mache = YunbiaoMaCheCell.New(self:FindObj("MaChe" .. i))
		self.carriage[i].cell_list = YunbiaoCellList.New(self:FindObj("CellList" .. i), i)
	end

	self.free_times = self:FindVariable("FreeTimes")
	self.rest_count = self:FindVariable("RestCount")
	self.buy_count = self:FindVariable("BuyCount")
	self.lingpai_count = self:FindVariable("LingPaiCount")
	self.cost_count = self:FindVariable("CostCount")
	self.str_color = self:FindVariable("Color")
	self.activity_isopen = self:FindVariable("activity_isopen")

	self.start_husong_btn = self:FindObj("StartHusongBtn")

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
	self:ListenEvent("OnClickRed",
		BindTool.Bind(self.OnClickRed, self))

	self.last_color = YunbiaoData.Instance:GetTaskColor() or 1
	self.guide_husong_color = 0

	self.item_change = BindTool.Bind(self.ItemChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change)

	self:ItemChange()

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.YunbiaoView, BindTool.Bind(self.GetUiCallBack, self))
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
	for k,v in pairs(self.carriage) do
		if v.cell_list then
			v.cell_list:DeleteMe()
		end
	end
	self.carriage = {}
end

function YunbiaoViewMain:SetGuideHusongColor(color)
	self.guide_husong_color = color
end

function YunbiaoViewMain:Flush()
	local free_times = YunbiaoData.Instance:GetFreeRefreshNum()
	self.free_times:SetValue(free_times)
	local rest_count = YunbiaoData.Instance:GetHusongRemainTimes()
	self.rest_count:SetValue(ToColorStr(rest_count, COLOR.GREEN) .. Language.Common.UnitName[6])
	local buy_count = YunbiaoData.Instance:GetMaxGoumaiNum()
	self.buy_count:SetValue(buy_count)
	local give_times = YunbiaoData.Instance:GetYunBiaoStuffCount()
	self.cost_count:SetValue(give_times)

	local reward_config = YunbiaoData.Instance:GetRewardConfig()
	if reward_config then
		for i = 1, 5 do
			if reward_config[i] then
				local exp = CommonDataManager.ConverMoney(reward_config[i].exp or 0)
				self.carriage[i].exp:SetValue(exp)
			end
		end
	end

	for i = 1, 5 do
		self.carriage[i].show_high_light:SetValue(false)
	end

	if self.guide_husong_color > 0 then
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
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.HUSONG) or CampData.Instance:GetCampYunbiaoIsOpen() then
		self.activity_isopen:SetValue(ToColorStr(Language.Activity.KaiQiZhong, TEXT_COLOR.GREEN))
	else
		self.activity_isopen:SetValue(ToColorStr(Language.Activity.YiJieShu, TEXT_COLOR.RED))
	end
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

function YunbiaoViewMain:OnClickRed()
	if YunbiaoData.Instance:GetIsHuShong() then
		SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.InYunBiao)
		return
	end
	if YunbiaoData.Instance:GetTaskColor() ~= 5 then
		local describe = Language.YunBiao.YiJianAlert
		local yes_func = function() YunbiaoCtrl.Instance.Instance:SendRefreshHusongTask(1, 1) end
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.MaxLevel)
	end
end

function YunbiaoViewMain:OnClickFlush()
	if YunbiaoData.Instance:GetIsHuShong() then
		SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.InYunBiao)
		return
	end
	if YunbiaoData.Instance:GetTaskColor() ~= 5 then
		if self.toggle.isOn then
			local describe = Language.YunBiao.YiJianAlert
			local yes_func = function() YunbiaoCtrl.Instance.Instance:SendRefreshHusongTask(1, 1) end
			TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
		else
			local auto_buy = self.auto_toggle.isOn
			local has_count = ItemData.Instance:GetItemNumInBagById(YunbiaoData.Instance.yunbiao_item_id)
			local cost_count = YunbiaoData.Instance:GetYunBiaoStuffCount()
			local free_times = YunbiaoData.Instance:GetFreeRefreshNum()
			local buy_count = cost_count - has_count
			if free_times >= 1 then
				YunbiaoCtrl.Instance.Instance:SendRefreshHusongTask(0, 0)
				return
			end
			if has_count < 1 and free_times < 1 then
				if auto_buy then
					YunbiaoCtrl.Instance.Instance:SendRefreshHusongTask(0, 1)
				else
					local func = function(item_id, num, is_bind, is_tip_use, is_buy_quick) 
						ExchangeCtrl.Instance:SendCSShopBuy(item_id, num, is_bind, is_tip_use, 0, 0) 
						if is_buy_quick then
							self.auto_toggle.isOn = true
						end
					end
					TipsCtrl.Instance:ShowCommonBuyView(func, YunbiaoData.Instance.yunbiao_item_id, nil, buy_count)
				end
			else
				if has_count < cost_count then
					local func = function(item_id, num, is_bind, is_tip_use, is_buy_quick) 
						ExchangeCtrl.Instance:SendCSShopBuy(item_id, num, is_bind, is_tip_use, 0, 0) 
						if is_buy_quick then
							self.auto_toggle.isOn = true
						end
					end
					TipsCtrl.Instance:ShowCommonBuyView(func, YunbiaoData.Instance.yunbiao_item_id, nil, buy_count)
				else
					YunbiaoCtrl.Instance.Instance:SendRefreshHusongTask(0, 0)
				end
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
		describe = string.format(Language.YunBiao.GouMaiTips3, ToColorStr(gold_cost, TEXT_COLOR.GREEN), ToColorStr(goumaicishu, TEXT_COLOR.GREEN))
		yes_func = function() YunbiaoCtrl.Instance:SendHusongBuyTimes() end
	elseif goumaicishu - 1 < YunbiaoData.Instance:GetMaxGoumaiCiShu() then
		describe = Language.YunBiao.GouMaiTips4
	else
		describe = Language.YunBiao.GouMaiTips2
	end

	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

-- 接护送任务
function YunbiaoViewMain:DealClickHuSong()
	if YunbiaoData.Instance:GetIsHuShong() then
		SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.InYunBiao)
		return
	end
	
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
	local yunbiao_isopen = CampData.Instance:GetCampYunbiaoIsOpen()
	if act_isopen or yunbiao_isopen then
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
	local str = Language.YunBiao.Tip
	TipsCtrl.Instance:ShowHelpTipView(str)
end

function YunbiaoViewMain:ItemChange()
	local count = ItemData.Instance:GetItemNumInBagById(YunbiaoData.Instance.yunbiao_item_id) or 0
	local color = TEXT_COLOR.PURPLE
	if count <= 0 then
		color = TEXT_COLOR.RED
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

end

function YunbiaoMaCheCell:__delete()
	self:RemoveDelayTime()
end

function YunbiaoMaCheCell:StartShake()
	if self.anim then
		self.anim:SetBool("Shake", true)
	end
	self:RemoveDelayTime()
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:OpenBox() end, 0.5)
end

function YunbiaoMaCheCell:StopShake()
	if self.anim then
		self.anim:SetBool("Shake", false)
	end
	self:RemoveDelayTime()
end

function YunbiaoMaCheCell:OpenBox()
	self:RemoveDelayTime()
	if self.anim then
		self.anim:SetBool("Shake", false)
	end
end

function YunbiaoMaCheCell:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end


YunbiaoCellList = YunbiaoCellList or BaseClass(BaseCell)

function YunbiaoCellList:__init(obj, index)
	self.cell_list = {}
	local item_data = ConfigManager.Instance:GetAutoConfig("husongcfg_auto").task_reward_list
	local num_list = YunbiaoData.Instance:GetRewardCfg()
	for i=1,3 do
		self.cell_list[i] = ItemCell.New(self:FindObj("cell" .. i))
		if nil == item_data[1].reward_item[i - 1] or nil == next(item_data[1].reward_item[i - 1]) then return end
		self.cell_list[i]:SetData({item_id = item_data[1].reward_item[i - 1].item_id, num = num_list[index], is_bind = item_data[1].reward_item[i - 1].is_bind})--(item_data[200].reward_item[i - 1])
	end
end

function YunbiaoCellList:__delete()
	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end




