require("game/treasure/treasure_content_view")
require("game/treasure/treasure_exchange_view")
require("game/treasure/treasure_warehouse_view")
TreasureView = TreasureView or BaseClass(BaseView)

local TREASURE_INDEX =
{
	TabIndex.treasure_choujiang,		--寻宝抽奖
	TabIndex.treasure_exchange,			--寻宝兑换
	TabIndex.treasure_warehouse,		--寻宝仓库
}

local TabName = {
	[1] = "treasure_choujiang",
	[2] = "treasure_exchange",
	[3] = "treasure_warehouse",
}

function TreasureView:__init()
	self.ui_config = {"uis/views/treasureview","TreasureView"}
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenTreasure)
	end
	self.play_audio = true
	self:SetMaskBg()
	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function TreasureView:__delete()
end

function TreasureView:LoadCallBack()
	ExchangeCtrl.Instance:SendGetConvertRecordInfo()
	ExchangeCtrl.Instance:SendGetSocreInfoReq()
	TreasureCtrl.Instance:SendChestShopItemListReq(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)

	local treasure_content = self:FindObj("treasure_content_view")
	treasure_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.treasure_content_view = TreasureContentView.New(obj)
		-- 引导用按钮
		self.one_times_btn = self.treasure_content_view.one_times_btn
		self:Flush("treasure")
	end)

	local warehouse_content = self:FindObj("warehouse_content_view")
	warehouse_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.warehouse_content_view = TreasureWarehouseView.New(obj)
		self.warehouse_content_view:Flush("warehouse")
		-- 引导用按钮
		self.get_all_btn = self.warehouse_content_view.get_all_btn
	end)

	local exchange_content = self:FindObj("exchange_content_view")
	exchange_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.exchange_content_view = TreasureExchangeView.New(obj)
		self.exchange_content_view:Flush("exchange")
	end)

	-- self.show_xunbao_red_point = self:FindVariable("show_xunbao_red_point")
	-- self.show_warehouse_red_point = self:FindVariable("show_warehouse_red_point")
	-- self.show_duihuan_red_point = self:FindVariable("show_duihuan_red_point")
	self.diamond = self:FindVariable("Diamond")
	self.xunbao_coin_text = self:FindVariable("xunbao_coin_text")
	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseBtnClick, self))
	self:ListenEvent("add_gold", BindTool.Bind(self.HandleAddGold, self))

	self.toggle_list = {}
	for i=1,3 do
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, TREASURE_INDEX[i]))
		self.toggle_list[i] = self:FindObj("toggle_" .. i)
	end
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self.show_consumables_bar = self:FindVariable("ShowConsumablesBar")
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Treasure, BindTool.Bind(self.GetUiCallBack, self))
	ExchangeCtrl.Instance:SendGetSocreInfoReq()
	
	self.consumable_bar = ConsumablesBar.New()
	self.consumable_bar:SetInstanceParent(self:FindObj("ConsumablesBar"))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.CheckRedPoint, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	self.red_point_list = {
		[RemindName.XunBaoTreasure] = self:FindVariable("show_xunbao_red_point"),
		[RemindName.XunBaoWarehouse] = self:FindVariable("show_warehouse_red_point"),
		[RemindName.XunBaoExchange] = self:FindVariable("show_duihuan_red_point"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function TreasureView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function TreasureView:ReleaseCallBack()
	if self.treasure_content_view then
		self.treasure_content_view:DeleteMe()
		self.treasure_content_view = nil
	end
	if self.warehouse_content_view then
		self.warehouse_content_view:DeleteMe()
		self.warehouse_content_view = nil
	end
	if self.exchange_content_view then
		self.exchange_content_view:DeleteMe()
		self.exchange_content_view = nil
	end
	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	if self.consumable_bar then
		self.consumable_bar:DeleteMe()
		self.consumable_bar = nil
	end

	if PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
	end
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Treasure)
	end

	-- 清理变量和对象
	-- self.show_xunbao_red_point = nil
	-- self.show_warehouse_red_point = nil
	-- self.show_duihuan_red_point = nil
	self.diamond = nil
	self.xunbao_coin_text = nil
	self.toggle_list = nil
	self.get_all_btn = nil
	self.one_times_btn = nil
	self.show_consumables_bar = nil
	self.red_point_list = nil

	if self.item_data_event then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function TreasureView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function TreasureView:GetTreasureExchange()
	return self.exchange_content_view
end

function TreasureView:GetTreasureWareView()
	return self.warehouse_content_view
end

function TreasureView:GetTreasureContentView()
	return self.treasure_content_view
end

function TreasureView:OpenCallBack()
	if self.treasure_content_view then
		self.treasure_content_view.is_click = false
	end
	self:Flush()
	for k,v in pairs(self.toggle_list) do
		local is_open = OpenFunData.Instance:CheckIsHide(TabName[k])
		v:SetActive(is_open)
	end
end

function TreasureView:OnFlush(param)
	for k,v in pairs(param) do
		if k == "treasure" then
			if self.show_index == TabIndex.treasure_choujiang then
				self.xunbao_coin_text:SetValue(CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore()))
				self.show_consumables_bar:SetValue(false)
				if self.treasure_content_view then
					self.treasure_content_view:Flush()
				end
			end
		elseif k == "exchange" then
			if self.show_index == TabIndex.treasure_exchange then				
				self.xunbao_coin_text:SetValue(CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore()))
				self.show_consumables_bar:SetValue(true)
				local treasure_list = TreasureData.Instance:GetOtherCfg()
				local bundle, asset = ResPath.GetItemIcon(treasure_list.score_item_id)
				local data = {}
				data.listener_type = LISTEN_TYPE.item_listener
				data.bundle = bundle
				data.asset = asset
				data.num = ItemData.Instance:GetItemNumInBagById(treasure_list.score_item_id)
				data.item_id = treasure_list.score_item_id
				self.consumable_bar:ListenClick(BindTool.Bind(self.SetConsumablesBarClick, self))
				self.consumable_bar:SetData(data)
				if self.exchange_content_view then
					self.exchange_content_view:Flush()
				end
			end
		elseif k == "warehouse" then
			if self.show_index == TabIndex.treasure_warehouse then
				self.show_consumables_bar:SetValue(false)
				if self.warehouse_content_view then
					self.warehouse_content_view:Flush()
				end
			end
		end
	end
	-- self:CheckRedPoint()
end

function TreasureView:CheckRedPoint()
	RemindManager.Instance:Fire(RemindName.XunBaoTreasure)
	RemindManager.Instance:Fire(RemindName.XunBaoExchange)
	RemindManager.Instance:Fire(RemindName.XunBaoWarehouse)
end

function TreasureView:OnCloseBtnClick()
	self:Close()
end

function TreasureView:OnToggleClick(i,is_click)
	if is_click then
		self:ChangeToIndex(i)
	end
end

function TreasureView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.diamond:SetValue(CommonDataManager.ConverMoney(value))
	end
end

function TreasureView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end

function TreasureView:ShowIndexCallBack(index)
	if index == TabIndex.treasure_choujiang then
		if not self.toggle_list[1].toggle.isOn then
			self.toggle_list[1].toggle.isOn = true
		end
		self:Flush("treasure")
	elseif index == TabIndex.treasure_exchange then
		if not self.toggle_list[2].toggle.isOn then
			self.toggle_list[2].toggle.isOn = true
		end
		self:Flush("exchange")
		ClickOnceRemindList[RemindName.XunBaoExchange] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.XunBaoExchange)
	elseif index == TabIndex.treasure_warehouse then
		if not self.toggle_list[3].toggle.isOn then
			self.toggle_list[3].toggle.isOn = true
		end
		self:Flush("warehouse")
	end
end

function TreasureView:SetConsumablesBarClick()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_choujiang)
end