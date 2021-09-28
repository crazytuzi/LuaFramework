require("game/treasure/treasure_content_view")
require("game/treasure/treasure_exchange_view")
require("game/treasure/treasure_warehouse_view")
require("game/treasure/forge_compose_view")
require("game/treasure/treasure_equip_exchange_view")
-- 寻宝界面
TreasureView = TreasureView or BaseClass(BaseView)

local TREASURE_INDEX =
{
	TabIndex.treasure_choujiang,		--寻宝抽奖
	TabIndex.treasure_exchange,			--寻宝兑换
	TabIndex.treasure_warehouse,		--寻宝仓库
	TabIndex.treasure_compose,			--寻宝合成
	TabIndex.treasure_equip_exchange,	--寻宝装备兑换
}

function TreasureView:__init()
	self.ui_config = {"uis/views/treasureview_prefab","TreasureView"}
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenTreasure)
	end
	self.full_screen = true
	self.play_audio = true
	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
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

	local equip_exchange_content = self:FindObj("equip_exchange_content_view")
	equip_exchange_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.equip_exchange_content_view = TreasureEquipExchangeView.New(obj)
		self.equip_exchange_content_view:InitView()
	end)

	local compose_content = self:FindObj("compose_content_view")
	compose_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.compose_content_view = ForgeComposeView.New(obj)
		self:Flush("compose")
	end)

	self.is_rare_change = self:FindVariable("israrechange")
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	self.is_rare_change:SetValue(TreasureData.Instance:IsFlashChange())
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
		self.is_rare_change:SetValue(TreasureData.Instance:IsFlashChange())
	end, 1)

	self.show_xunbao_red_point = self:FindVariable("show_xunbao_red_point")
	self.show_warehouse_red_point = self:FindVariable("show_warehouse_red_point")
	self.diamond = self:FindVariable("Diamond")
	self.xunbao_coin_text = self:FindVariable("xunbao_coin_text")
	self.equip_exchange_coin = self:FindVariable("equip_exchange_coin")
	self.bind_gold = self:FindVariable("bind_gold")
	self.is_show_limit_time = self:FindVariable("IsShowLimitTime")
	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseBtnClick, self))
	self:ListenEvent("add_gold", BindTool.Bind(self.HandleAddGold, self))

	self.toggle_list = {}
	for i=1, 5 do
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, TREASURE_INDEX[i]))
		self.toggle_list[i] = self:FindObj("toggle_" .. i)
	end

	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.Treasure, BindTool.Bind(self.GetUiCallBack, self))
	ExchangeCtrl.Instance:SendGetSocreInfoReq()

	--红点
	self.red_point_list = {
		[RemindName.RedEquipExchange] = self:FindVariable("show_equip_exchange_remind"),
	}
	for k,v in pairs(self.red_point_list) do
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
	if self.equip_exchange_content_view then
		self.equip_exchange_content_view:DeleteMe()
		self.equip_exchange_content_view = nil
	end
	if self.compose_content_view then
		self.compose_content_view:DeleteMe()
		self.compose_content_view = nil
	end

	if PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
	end
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.Treasure)
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	-- 清理变量和对象
	self.is_rare_change = nil
	self.show_xunbao_red_point = nil
	self.show_warehouse_red_point = nil
	self.diamond = nil
	self.xunbao_coin_text = nil
	self.equip_exchange_coin = nil
	self.toggle_list = nil
	self.get_all_btn = nil
	self.one_times_btn = nil
	self.bind_gold = nil
	self.is_show_limit_time = nil
	self.red_point_list = nil
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

function TreasureView:OpenTrigger()
	if self:IsOpen() then
		local is_open_compose = OpenFunData.Instance:CheckIsHide("treasure_compose")

		self.toggle_list[4]:SetActive(is_open_compose)
	end
end

function TreasureView:ChangeRedEquipExchangeCoin()
	--写死策划说的
	local num = ItemData.Instance:GetItemNumInBagById(27588)
	self.equip_exchange_coin:SetValue(num)
end

function TreasureView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	self:ChangeRedEquipExchangeCoin()

	self:OpenTrigger()
	self:Flush()
end

function TreasureView:OpenRollingBarrageView()
	if RollingBarrageData.Instance:GetRecordBarrageState(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP) then
		return
	end

	local cur_index = self:GetShowIndex()
	if cur_index == TabIndex.treasure_choujiang then
		-- 打开弹幕
		RollingBarrageData.Instance:SetNowCheckType(CHEST_SHOP_TYPE.CHEST_SHOP_TYPE_EQUIP)
		ViewManager.Instance:Open(ViewName.RollingBarrageView)
	else
		self:CloseRollingBarrageView()
	end
end

function TreasureView:CloseRollingBarrageView()
	if ViewManager.Instance:IsOpen(ViewName.RollingBarrageView) then
		ViewManager.Instance:Close(ViewName.RollingBarrageView)
	end
end

function TreasureView:CloseCallBack()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	
	self:CloseRollingBarrageView()
	self:DeleteContentTimeQuest()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function TreasureView:OnFlush(param)
	for k,v in pairs(param) do
		if k == "treasure" then
			if self.show_index == TabIndex.treasure_choujiang then
				self.xunbao_coin_text:SetValue(CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore()))
				if self.treasure_content_view then
					self.treasure_content_view:Flush()
				end
			end
		elseif k == "exchange" then
			if self.show_index == TabIndex.treasure_exchange then
				self.xunbao_coin_text:SetValue(CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore()))
				if self.exchange_content_view then
					self.exchange_content_view:Flush()
				end
			end
		elseif k == "equip_exchange" then
			if self.show_index == TabIndex.treasure_equip_exchange then
				if self.equip_exchange_content_view then
					self.equip_exchange_content_view:Flush()
				end
			end
		elseif k == "warehouse" then
			if self.show_index == TabIndex.treasure_warehouse then
				if self.warehouse_content_view then
					self.warehouse_content_view:Flush()
				end
			end
		elseif k == "compose" then
			if self.show_index == TabIndex.treasure_compose then
				if self.compose_content_view then
					self.compose_content_view:FlushRightView()
				end
			end
		elseif k == "compose_redpoint" and self.compose_content_view then
			self.compose_content_view:FlushRedPoint()
		elseif k == "compose_jump" then
			ForgeComposeView.INDEX1, ForgeComposeView.INDEX2 = ForgeData.Instance:GetColorComposeIndexByStuff(v.item_id)
			if self.compose_content_view then
				self.compose_content_view:FlushRightView()
			end
		end
	end
	self:CheckRedPoint()
	self.is_show_limit_time:SetValue(TreasureData.Instance:GetIsShowLimitTimeInfo())
end

function TreasureView:FlushCoinText()
	self.xunbao_coin_text:SetValue(CommonDataManager.ConverMoney(TreasureData.Instance:GetTreasureScore()))
end

function TreasureView:CheckRedPoint()
	if self.show_warehouse_red_point then
		self.show_warehouse_red_point:SetValue(TreasureData.Instance:GetRemindWareHouse())
	end
	if self.show_xunbao_red_point then
		self.show_xunbao_red_point:SetValue(TreasureData.Instance:GetXunBaoRedPoint())
	end
end

function TreasureView:OnCloseBtnClick()
	self:Close()
end

function TreasureView:OnToggleClick(i,is_click)
	self:ChangeToIndex(i)
end

function TreasureView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.diamond:SetValue(CommonDataManager.ConverMoney(value))
	elseif attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(value))
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

function TreasureView:DeleteContentTimeQuest()
	if self.treasure_content_view then
		self.treasure_content_view:DeleteTimeQuest()
	end
end

function TreasureView:ShowIndexCallBack(index)
	if index ~= TabIndex.treasure_choujiang then
		self:DeleteContentTimeQuest()
	end

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
	elseif index == TabIndex.treasure_warehouse then
		if not self.toggle_list[3].toggle.isOn then
			self.toggle_list[3].toggle.isOn = true
		end
		self:Flush("warehouse")
	elseif index == TabIndex.treasure_compose then
		if not self.toggle_list[4].toggle.isOn then
			self.toggle_list[4].toggle.isOn = true
		end
		self:Flush("compose")
	elseif index == TabIndex.treasure_equip_exchange then
		if not self.toggle_list[5].toggle.isOn then
			self.toggle_list[5].toggle.isOn = true
		end
		if self.equip_exchange_content_view then
			self.equip_exchange_content_view:InitView()
		end

		RemindManager.Instance:Fire(RemindName.RedEquipExchange, true)
	end

	self:OpenRollingBarrageView()
end

function TreasureView:ItemDataChangeCallback()
	self:ChangeRedEquipExchangeCoin()
end