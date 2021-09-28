require("game/rune/rune_inlay_view")
require("game/rune/rune_analyze_view")
require("game/rune/rune_exchange_view")
require("game/rune/rune_treasure_view")
require("game/rune/rune_compose_view")
require("game/rune/rune_tower_view")
require("game/rune/rune_zhuling_view")

RuneView = RuneView or BaseClass(BaseView)
function RuneView:__init()
    self.ui_config = {"uis/views/rune_prefab", "RuneView"}
    self.full_screen = true
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

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	-- 清理变量和对象
	self.gold = nil
	self.bind_gold = nil
	self.sui_pian = nil
	self.show_compose = nil
	self.tab_inlay = nil
	self.tab_analyze = nil
	self.tab_exchange = nil
	self.tab_treasure = nil
	self.tab_compose = nil
	self.tab_tower = nil
	self.red_point_list = nil
	self.tab_zhuling = nil

	self.inlay_content = nil
	self.analyze_content = nil
	self.exchange_content = nil
	self.treasure_content = nil
	self.compose_content = nil
	self.tower_content = nil
	self.zhuling_content = nil

end

function RuneView:LoadCallBack()
	--镶嵌
	self.inlay_content = self:FindObj("InlayContent")

	--分解
	self.analyze_content = self:FindObj("AnalyzeContent")

	--兑换
	self.exchange_content = self:FindObj("ExchangeContent")

	--寻宝
	self.treasure_content = self:FindObj("TreasureContent")

	--合成
	self.compose_content = self:FindObj("ComposeContent")

	--符文塔
	self.tower_content = self:FindObj("TowerContent")

	--祭炼
	self.zhuling_content = self:FindObj("ZhuLingContent")

	self.gold = self:FindVariable("Gold")
	self.sui_pian = self:FindVariable("SuiPian")
	self.bind_gold = self:FindVariable("BindGold")
	self.show_compose = self:FindVariable("ShowCompose")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickRecharge", BindTool.Bind(self.ClickRecharge, self))
	self:ListenEvent("ClickTower", BindTool.Bind(self.ClickTower, self))

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
		[RemindName.RuneInlayGruop] = self:FindVariable("InlayRedPoint"),
		[RemindName.RuneAnalyze] = self:FindVariable("AnalyzeRedPoint"),
		[RemindName.RuneTreasure] = self:FindVariable("TreasureRedPoint"),
		[RemindName.RuneCompose] = self:FindVariable("ComposeRedPoint"),
		[RemindName.RuneTower] = self:FindVariable("TowerRedPoint"),
		[RemindName.RuneZhuLing] = self:FindVariable("ZhuLingRedPoint"),
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
	self:InitPanel(index)

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
		ClickOnceRemindList[RemindName.RuneTower] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.RuneTower)
	elseif index == TabIndex.rune_zhuling then
		self.tab_zhuling.toggle.isOn = true
		if self.zhuling_view then
			self.zhuling_view:InitView()
		end
	end

	if self.zhuling_view and index ~= TabIndex.rune_zhuling then
		self.zhuling_view:CloseCallBack()
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

	local rune_zhuling = OpenFunData.Instance:CheckIsHide("rune_zhuling")
	if self.tab_zhuling then
		self.tab_zhuling:SetActive(rune_zhuling)
	end
end

function RuneView:InitPanel(index)
	if index == TabIndex.rune_inlay and not self.inlay_view then
		UtilU3d.PrefabLoad("uis/views/rune_prefab", "InlayContent",
			function(obj)
				obj.transform:SetParent(self.inlay_content.transform, false)
				obj = U3DObject(obj)
				self.inlay_view = RuneInlayView.New(obj)
				self.inlay_view:InitView()
			end)
	elseif index == TabIndex.rune_analyze and not self.analyze_view then
		UtilU3d.PrefabLoad("uis/views/rune_prefab", "AnalyzeContent",
			function(obj)
				obj.transform:SetParent(self.analyze_content.transform, false)
				obj = U3DObject(obj)
				self.analyze_view = RuneAnalyzeView.New(obj)
				self.analyze_view:InitView()
			end)
	elseif index == TabIndex.rune_exchange and not self.exchange_view then
		UtilU3d.PrefabLoad("uis/views/rune_prefab", "ExchangeContent",
			function(obj)
				obj.transform:SetParent(self.exchange_content.transform, false)
				obj = U3DObject(obj)
				self.exchange_view = RuneExchangeView.New(obj)
				self.exchange_view:InitView()
			end)
	elseif index == TabIndex.rune_treasure and not self.treasure_view then
		UtilU3d.PrefabLoad("uis/views/rune_prefab", "TreasureContent",
			function(obj)
				obj.transform:SetParent(self.treasure_content.transform, false)
				obj = U3DObject(obj)
				self.treasure_view = RuneTreasureView.New(obj)
				self.treasure_view:InitView()
			end)
	elseif index == TabIndex.rune_compose and not self.compose_view then
		UtilU3d.PrefabLoad("uis/views/rune_prefab", "ComposeContent",
			function(obj)
				obj.transform:SetParent(self.compose_content.transform, false)
				obj = U3DObject(obj)
				self.compose_view = RuneComposeView.New(obj)
				self.compose_view:InitView()
			end)
	elseif index == TabIndex.rune_tower and not self.tower_view then
		UtilU3d.PrefabLoad("uis/views/rune_prefab", "TowerContent",
			function(obj)
				obj.transform:SetParent(self.tower_content.transform, false)
				obj = U3DObject(obj)
				self.tower_view = RuneTowerView.New(obj)
				self.tower_view:InitView()
			end)
	elseif index == TabIndex.rune_zhuling and not self.zhuling_view then
		UtilU3d.PrefabLoad("uis/views/rune_prefab", "ZhuLingContent",
			function(obj)
				obj.transform:SetParent(self.zhuling_content.transform, false)
				obj = U3DObject(obj)
				self.zhuling_view = RuneZhuLingView.New(obj)
				self.zhuling_view:InitView()
			end)
	end

	if self.zhuling_view and index ~= TabIndex.rune_zhuling then
		self.zhuling_view:CloseCallBack()
	end


end

function RuneView:InitMoney()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local gold_str = CommonDataManager.ConverMoney(main_vo.gold)
	local bindgold_str = CommonDataManager.ConverMoney(main_vo.bind_gold)
	local suipian = RuneData.Instance:GetSuiPian()
	local suipian_str = CommonDataManager.ConverMoney(suipian)
	self.gold:SetValue(gold_str)
	self.sui_pian:SetValue(suipian_str)
	self.bind_gold:SetValue(bindgold_str)
end

function RuneView:FlushSuiPian()
	local suipian = RuneData.Instance:GetSuiPian()
	local suipian_str = CommonDataManager.ConverMoney(suipian)
	self.sui_pian:SetValue(suipian_str)
end

function RuneView:RoleDataChange(key, value)
	if key == "gold" then
		local gold_str = CommonDataManager.ConverMoney(value)
		self.gold:SetValue(gold_str)
	end
	if key == "bind_gold" then
		local bindgold_str = CommonDataManager.ConverMoney(value)
		self.bind_gold:SetValue(bindgold_str)
	end
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
	self.paly_listen_callback = BindTool.Bind1(self.RoleDataChange, self)
	PlayerData.Instance:ListenerAttrChange(self.paly_listen_callback)
	RemindManager.Instance:Fire(RemindName.RuneZhuLing)
end

function RuneView:CloseCallBack()
	if self.paly_listen_callback then
		PlayerData.Instance:UnlistenerAttrChange(self.paly_listen_callback)
		self.paly_listen_callback = nil
	end
	if self.tower_view then
		self.tower_view:CloseCallBack()
	end

	if self.zhuling_view then
		self.zhuling_view:CloseCallBack()
	end
end

function RuneView:ClickTower()
	self.tower_view:FlushView()
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
	if self.analyze_view then
		self.analyze_view:InitView()
	end
	if self.exchange_view then
		self.exchange_view:FlushView()
	end
end