TimeLimitTitleView = TimeLimitTitleView or BaseClass(BaseView)

function TimeLimitTitleView:__init()
	self.ui_config = {"uis/views/tips/timelimittitletips_prefab", "TimeLimitTitleView"}
	self.view_layer = UiLayer.Pop
end

function TimeLimitTitleView:__delete()
end

function TimeLimitTitleView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.name = nil
	self.fight_power = nil
	self.hp_value = nil
	self.attack_value = nil
	self.fangyu_value = nil
	self.cost_value = nil
	self.show_buy_btn = nil
	self.show_fetch_flag = nil
	self.des_res = nil
	self.left_time_des = nil
	self.title_res = nil
	self.show_time_limit_des = nil
	self.show_title_model = nil

	self:StopCountDown()
end

function TimeLimitTitleView:LoadCallBack()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))

	self.name = self:FindVariable("Name")
	self.fight_power = self:FindVariable("FightPower")
	self.hp_value = self:FindVariable("hp_value")
	self.attack_value = self:FindVariable("attack_value")
	self.fangyu_value = self:FindVariable("fangyu_value")
	self.cost_value = self:FindVariable("CostValue")
	self.show_buy_btn = self:FindVariable("ShowBuyBtn")
	self.show_fetch_flag = self:FindVariable("ShowFetchFlag")
	self.des_res = self:FindVariable("DesRes")
	self.left_time_des = self:FindVariable("LeftTimeDes")
	self.title_res = self:FindVariable("TitleRes")
	self.show_time_limit_des = self:FindVariable("ShowTimeLimitDes")
	self.show_title_model = self:FindVariable("ShowTitleModel")

	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow,self))
	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy,self))
	self:ListenEvent("OnCLickFetch", BindTool.Bind(self.OnCLickFetch,self))
end

function TimeLimitTitleView:CloseWindow()
	self:Close()
end

function TimeLimitTitleView:OnClickBuy()
	local item_id = self.data.item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end

	local cost_gold = self.data.cost
	local ok_fun = function ()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.gold < cost_gold then
			TipsCtrl.Instance:ShowLackDiamondView(function()
				self:Close()
			end)
			return
		else
			if self.call_back then
				self.call_back(TIME_LIMIT_TITLE_CALL_TYPE.BUY)
			end
			self:Close()
		end
	end

	local gold_des = ToColorStr(cost_gold, TEXT_COLOR.BLUE1)
	local item_color = ITEM_COLOR[item_cfg.color]
	local item_name = ToColorStr(item_cfg.name, item_color)
	local tips_text = string.format(Language.Common.UsedGoldToBuySomething, gold_des, item_name)
	TipsCtrl.Instance:ShowCommonAutoView(nil, tips_text, ok_fun)
end

function TimeLimitTitleView:OnCLickFetch()
	if self.call_back then
		self.call_back(TIME_LIMIT_TITLE_CALL_TYPE.FETCH)
	end
	self:Close()
end

function TimeLimitTitleView:SetData(data)
	self.data = data
	self.call_back = data.call_back
end

function TimeLimitTitleView:OpenCallBack()
	self:Flush()
end

function TimeLimitTitleView:CloseCallBack()
	self:StopCountDown()
end

function TimeLimitTitleView:StopCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function TimeLimitTitleView:StartCountDown()
	local left_time = self.data.left_time
	local can_fetch = self.data.can_fetch
	if left_time <= 0 or can_fetch then
		self.show_time_limit_des:SetValue(false)
		return
	end
	self.show_time_limit_des:SetValue(true)

	local des = TimeUtil.FormatBySituation(left_time)
	local function time_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self.show_time_limit_des:SetValue(false)
			return
		end

		left_time = total_time - math.floor(elapse_time)
		des = TimeUtil.FormatBySituation(left_time)
		self.left_time_des:SetValue(des)
	end

	self.count_down = CountDown.Instance:AddCountDown(left_time, 1, time_func)

	--先设置一次
	self.left_time_des:SetValue(des)
end

function TimeLimitTitleView:FlushTitleRes()
	local item_id = self.data.item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end

	local title_cfg = TitleData.Instance:GetTitleCfg(item_cfg.param1 or 0)
	if title_cfg == nil then
		return
	end

	local bundle, asset = ResPath.GetTitleModel(title_cfg.title_id)
	self.show_title_model:SetValue(false)
	self.title_res:SetAsset(bundle, asset)
	self.show_title_model:SetValue(true)
end

function TimeLimitTitleView:FlushItem()
	self.item_cell:SetData({item_id = self.data.item_id})
	self.item_cell:SetInteractable(false)
end

function TimeLimitTitleView:FlushContent()	
	local item_id = self.data.item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end

	local title_cfg = TitleData.Instance:GetTitleCfg(item_cfg.param1 or 0)
	if title_cfg == nil then
		return
	end

	--刷新名字
	self.name:SetValue(item_cfg.name)

	--刷新属性
	self.hp_value:SetValue(title_cfg.maxhp)
	self.attack_value:SetValue(title_cfg.gongji)
	self.fangyu_value:SetValue(title_cfg.fangyu)

	--设置战斗力
	local cap = CommonDataManager.GetCapabilityCalculation(title_cfg)
	self.fight_power:SetValue(cap)

	--按钮显示
	local can_fetch = self.data.can_fetch
	self.show_fetch_flag:SetValue(can_fetch)
	self.show_buy_btn:SetValue(not can_fetch)

	--设置消耗
	self.cost_value:SetValue(self.data.cost)

	--设置倒计时
	self:StartCountDown()

	--设置描述资源
	local bundle, asset = ResPath.GetTimeLimitTitleResPath("des_" .. self.data.from_panel)
	self.des_res:SetAsset(bundle, asset)
end

function TimeLimitTitleView:OnFlush()
	self:StopCountDown()

	self:FlushContent()
	self:FlushItem()
	self:FlushTitleRes()
end