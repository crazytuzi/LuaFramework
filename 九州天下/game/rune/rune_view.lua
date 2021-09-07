require("game/rune/rune_inlay_view")
require("game/rune/rune_analyze_view")
require("game/rune/rune_exchange_view")
require("game/rune/rune_treasure_view")
require("game/rune/rune_compose_view")
require("game/rune/rune_tower_view")
require("game/rune/rune_zhuling_view")

RuneView = RuneView or BaseClass(BaseView)
function RuneView:__init()
	self:SetMaskBg()
    self.ui_config = {"uis/views/rune", "RuneView"}
    self.play_audio = true
    self.is_async_load = false
    self.is_check_reduce_mem = true
    self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function RuneView:__delete()
end

function RuneView:ReleaseCallBack()
	if self.inlay_view then
		self.inlay_view:DeleteMe()
		self.inlay_view = nil
	end
	if self.analyze_view then
		self.analyze_view:DeleteMe()
		self.analyze_view = nil
	end
	if self.exchange_view then
		self.exchange_view:DeleteMe()
		self.exchange_view = nil
	end
	if self.treasure_view then
		self.treasure_view:DeleteMe()
		self.treasure_view = nil
	end
	if self.compose_view then
		self.compose_view:DeleteMe()
		self.compose_view = nil
	end
	if self.preview_view then
		self.preview_view:DeleteMe()
		self.preview_view = nil
	end
	if self.tower_view then
		self.tower_view:DeleteMe()
		self.tower_view = nil
	end

	if self.zhuling_view then
		self.zhuling_view:DeleteMe()
		self.zhuling_view = nil
	end

	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	-- 清理变量和对象
	self.gold = nil
	self.sui_pian = nil
	self.show_compose = nil
	self.tab_inlay = nil
	self.tab_analyze = nil
	self.tab_exchange = nil
	self.tab_treasure = nil
	self.tab_compose = nil
	self.tab_tower = nil
	self.tab_zhuling = nil
	self.red_point_list = nil
	self.show_jilian = nil
end

function RuneView:LoadCallBack()
	--镶嵌
	local inlay_content = self:FindObj("InlayContent")
	inlay_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.inlay_view = RuneInlayView.New(obj)
		self.inlay_view:InitView()
	end)

	--分解
	local analyze_content = self:FindObj("AnalyzeContent")
	analyze_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.analyze_view = RuneAnalyzeView.New(obj)
		self.analyze_view:InitView()
	end)

	--兑换
	local exchange_content = self:FindObj("ExchangeContent")
	exchange_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.exchange_view = RuneExchangeView.New(obj)
		self.exchange_view:InitView()
	end)

	--寻宝
	local treasure_content = self:FindObj("TreasureContent")
	treasure_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.treasure_view = RuneTreasureView.New(obj)
		self.treasure_view:InitView()
	end)

	--合成
	local compose_content = self:FindObj("ComposeContent")
	compose_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.compose_view = RuneComposeView.New(obj)
		self.compose_view:InitView()
	end)

	--符文塔
	local tower_content = self:FindObj("TowerContent")
	tower_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.tower_view = RuneTowerView.New(obj)
		self.tower_view:InitView()
	end)

	--祭炼
	local zhuling_content = self:FindObj("ZhuLingContent")
	zhuling_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.zhuling_view = RuneZhuLingView.New(obj)
		self.zhuling_view:InitView()
	end)

	self.sui_pian = self:FindVariable("RuneScrap")
	self.show_compose = self:FindVariable("ShowCompose")
	self.show_jilian = self:FindVariable("ShowJiLian")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickRecharge", BindTool.Bind(self.ClickRecharge, self))
	self:ListenEvent("ClickTower", BindTool.Bind(self.ClickTower, self))

	self.money = MoneyBar.New()
	self.money:SetInstanceParent(self:FindObj("MoneyBar"))

	self.tab_inlay = self:FindObj("Tab_Inlay")
	self.tab_analyze = self:FindObj("Tab_Analyze")
	self.tab_exchange = self:FindObj("Tab_Exchange")
	self.tab_treasure = self:FindObj("Tab_Treasure")
	self.tab_compose = self:FindObj("Tab_Compose")
	self.tab_tower = self:FindObj("Tab_Tower")
	self.tab_zhuling = self:FindObj("Tab_ZhuLing")

	self.tab_inlay.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.rune_inlay))
	self.tab_analyze.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.rune_analyze))
	self.tab_exchange.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.rune_exchange))
	self.tab_treasure.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.rune_treasure))
	self.tab_compose.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.rune_compose))
	self.tab_tower.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.rune_tower))
	self.tab_zhuling.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.rune_zhuling))

	self.red_point_list = {
		[RemindName.RuneTower] = self:FindVariable("TowerRedPoint"),		--获取
		[RemindName.RuneInlay] = self:FindVariable("InlayRedPoint"),		--镶嵌
		[RemindName.RuneAnalyze] = self:FindVariable("AnalyzeRedPoint"),	--分解
		[RemindName.RuneExchange] = self:FindVariable("ExchangeRedPoint"),	--兑换
		[RemindName.RuneTreasure] = self:FindVariable("TreasureRedPoint"),	--铭刻
		[RemindName.RuneCompose] = self:FindVariable("ComposeRedPoint"),	--合成		
		[RemindName.RuneJiLian] = self:FindVariable("JiLianRedPoint"),		--祭炼
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function RuneView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function RuneView:OnToggleChange(index, isOn)
	if not isOn then
		return
	end
	self:ChangeToIndex(index)
end

function RuneView:CloseWindow()
	self:Close()
end

function RuneView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function RuneView:ShowIndexCallBack(index)
	if index == TabIndex.rune_inlay then
		self.tab_inlay.toggle.isOn = true
		if self.inlay_view then
			self.inlay_view:InitView()
		end
	elseif index == TabIndex.rune_analyze then
		self.tab_analyze.toggle.isOn = true
		if self.analyze_view then
			self.analyze_view:InitView()
		end
	elseif index == TabIndex.rune_exchange then
		self.tab_exchange.toggle.isOn = true
		if self.exchange_view then
			self.exchange_view:InitView()
		end
		ClickOnceRemindList[RemindName.RuneExchange] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.RuneExchange)
	elseif index == TabIndex.rune_treasure then
		self.tab_treasure.toggle.isOn = true
		if self.treasure_view then
			self.treasure_view:InitView()
		end
	elseif index == TabIndex.rune_compose then
		self.tab_compose.toggle.isOn = true
		if self.compose_view then
			self.compose_view:InitView()
		end
	elseif index == TabIndex.rune_tower then
		self.tab_tower.toggle.isOn = true
		if self.tower_view then
			self.tower_view:InitView()
		end
	elseif index == TabIndex.rune_zhuling then
		self.tab_zhuling.toggle.isOn = true
		if self.zhuling_view then
			self.zhuling_view:InitView()
		end
		ClickOnceRemindList[RemindName.RuneJiLian] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.RuneJiLian)
	end
end

function RuneView:UpdateRedPoint()
	self.inlay_red_point:SetValue(RuneData.Instance:GetRedPoint("Inlay"))
	self.treasure_red_point:SetValue(RuneData.Instance:GetRedPoint("Treasure"))
	self.compose_red_point:SetValue(RuneData.Instance:GetRedPoint("Compose"))
end

function RuneView:InitTab()
	local pass_layer = RuneData.Instance:GetPassLayer()
	local other_cfg = RuneData.Instance:GetOtherCfg()
	local need_pass_layer = other_cfg.rune_compose_need_layer
	self.show_compose:SetValue(pass_layer >= need_pass_layer)
end

function RuneView:InitMoney()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local gold_str = CommonDataManager.ConverMoney(main_vo.gold)
	local suipian = RuneData.Instance:GetSuiPian()
	local suipian_str = CommonDataManager.ConverMoney(suipian)
	self.sui_pian:SetValue(suipian_str)
end

function RuneView:FlushSuiPian()
	local suipian = RuneData.Instance:GetSuiPian()
	local suipian_str = CommonDataManager.ConverMoney(suipian)
	self.sui_pian:SetValue(suipian_str)
end

function RuneView:OpenCallBack()
	self:InitMoney()
	self:InitTab()
	if self.tab_inlay.toggle.isOn then
		self:ChangeToIndex(TabIndex.rune_inlay)
	elseif self.tab_analyze.toggle.isOn then
		self:ChangeToIndex(TabIndex.rune_analyze)
	elseif self.tab_exchange.toggle.isOn then
		self:ChangeToIndex(TabIndex.rune_exchange)
	elseif self.tab_treasure.toggle.isOn then
		self:ChangeToIndex(TabIndex.rune_treasure)
	elseif self.tab_compose.toggle.isOn then
		self:ChangeToIndex(TabIndex.rune_compose)
	elseif self.tab_tower.toggle.isOn then
		self:ChangeToIndex(TabIndex.rune_tower)
	elseif self.tab_zhuling.toggle.isOn then
		self:ChangeToIndex(TabIndex.rune_zhuling)
	else
		self:ChangeToIndex(TabIndex.rune_tower)
	end

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	local show_jilian = OpenFunData.Instance:CheckIsHide("rune_zhuling")
	self.show_jilian:SetValue(show_jilian)
end

function RuneView:CloseCallBack()
	if self.tower_view then
		self.tower_view:CloseCallBack()
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function RuneView:ClickTower()
	self.tower_view:FlushView()
end

function RuneView:ItemDataChangeCallback()
	if self.compose_view then
		self.compose_view:FlushView()
	end
end

function RuneView:OnFlush(params_t)
	self:FlushSuiPian()
	for k, v in pairs(params_t) do
		if k == "inlay" and self.tab_inlay.toggle.isOn then
			if self.inlay_view then
				self.inlay_view:FlushView()
			end
		elseif k == "analyze" and self.tab_analyze.toggle.isOn then
			if self.analyze_view then
				self.analyze_view:PlayAni()
				self.analyze_view:FlushView()
			end
		elseif k == "exchange" and self.tab_exchange.toggle.isOn then
			if self.exchange_view then
				self.exchange_view:FlushView()
			end
		elseif k == "treasure" and self.tab_treasure.toggle.isOn then
			if self.treasure_view then
				self.treasure_view:FlushView()
			end
		elseif k == "tower" and self.tab_tower.toggle.isOn then
			if self.tower_view then
				self.tower_view:FlushView()
			end
		elseif (k == "zhuling" or k == "zhuling_bless")and self.tab_zhuling.toggle.isOn then
			if self.zhuling_view then
				if k == "zhuling" then
					self.zhuling_view:FlushView()
				elseif k == "zhuling_bless" then
					self.zhuling_view:OnRewardDataChange(v[1], v[2])
				end
			end
		elseif k == "compose" and self.tab_compose.toggle.isOn then
			if self.compose_view then
				self.compose_view:FlushView()
			end
		elseif k == "compose_effect" and self.tab_compose.toggle.isOn then
			if self.compose_view then
				self.compose_view:PlayUpEffect()
			end
		end
	end
end