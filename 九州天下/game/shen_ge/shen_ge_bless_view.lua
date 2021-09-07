ShenGeBlessView = ShenGeBlessView or BaseClass(BaseRender)

local POINTER_ANGLE_LIST = {
	-- [1] = -270,
	-- [2] = -270,
	-- [3] = -225,
	-- [4] = -180,
	-- [5] = -135,
	-- [6] = -90,
	-- [10] = -315,
	-- [11] = -45,
	-- [12] = 0,
}

function ShenGeBlessView:__init(instance)
	self.count = 0
	self.quality = 0
	self.types = 0
	self.is_click_once = true
	self.is_rolling = false
	self.is_auto_buy = false

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	local cfg = ShenGeData.Instance:GetOtherCfg().once_chou_item

	self.once_btn = self:FindObj("OnceBtn")
	self.ten_btn = self:FindObj("TenBtn")

	self.center_pointer = self:FindObj("CenterPointer")
	self.play_ani_toggle = self:FindObj("PlayAniToggle").toggle
	self.play_ani_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))


	self:ListenEvent("OnClickOnce", BindTool.Bind(self.OnClickRoll, self, 1))
	self:ListenEvent("OnClickTence", BindTool.Bind(self.OnClickRoll, self, 10))

	self.item_list = {}
	self.show_hight_list = {}
	for i = 1, 8 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
		self.item_list[i]:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		self.item_list[i]:ShowHighLight(false)

		self.show_hight_list[i] = self:FindVariable("ShowHightLight" .. i)
	end

	self.show_time = self:FindVariable("ShowTime")
	self.show_free = self:FindVariable("ShowFree")

	-- self.show_hight_light_10 = self:FindVariable("ShowHightLight10")
	-- self.show_hight_light_11 = self:FindVariable("ShowHightLight11")
	-- self.show_hight_light_12 = self:FindVariable("ShowHightLight12")
	-- self.show_hight_light_5 = self:FindVariable("ShowHightLight5")
	-- self.show_hight_light_0 = self:FindVariable("ShowHightLight0")

	-- self.show_hight_light_1 = self:FindVariable("ShowHightLight1")
	-- self.show_hight_light_2 = self:FindVariable("ShowHightLight2")
	-- self.show_hight_light_3 = self:FindVariable("ShowHightLight3")
	-- self.show_hight_light_4 = self:FindVariable("ShowHightLight4")

	self.hour = self:FindVariable("Hour")
	self.min = self:FindVariable("Min")
	self.sec = self:FindVariable("Sec")

	self.once_cost = self:FindVariable("OnceCost")
	self.tence_cost = self:FindVariable("TenceCost")
	self.my_items = self:FindVariable("MyItems")
	self.my_items_ten = self:FindVariable("MyItemsTen")

	self.is_auto = self:FindVariable("IsBuy")
	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))

	if nil == self.item_change then
		self.item_change = BindTool.Bind(self.ItemDataChangeCallBack, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change)
	end

	self:FlushItemInfo(cfg.item_id)
	self:Flush()
end

function ShenGeBlessView:ReleaseCallBack()
	if self.item_list ~= nil then
		for k,v in pairs(self.item_list) do
			if v ~= nil then
				v:DeleteMe()
			end
		end

		self.item_list = nil
	end

	self.show_hight_list = {}
end

function ShenGeBlessView:__delete()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.item_change then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end
end

function ShenGeBlessView:OnClickRoll(roll_type)
	if self.item_id == nil or roll_type == nil then
		return
	end

	ShenGeData.Instance:SetCurBlessQuickBuyState(false)
	ShenGeData.Instance:SetCurBlessAutoBuyState(false)
	local buy_num = roll_type == 10 and 9 or roll_type

	if ItemData.Instance:GetItemNumInBagById(self.item_id) < buy_num and not self.is_auto_buy then
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.is_auto_buy = is_buy_quick
				if self.is_auto ~= nil then
					self.is_auto:SetValue(is_buy_quick)
					TipsCtrl.Instance:HodeAutoBuyValue("auto_shenge_bless", is_buy_quick)
				end
			end
		end
		if roll_type == 10 then
			TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nil, buy_num - ItemData.Instance:GetItemNumInBagById(self.item_id))
		else
			TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nil, 1)
		end

		ShenGeData.Instance:SetCurBlessQuickBuyState(true)
		self:SetConsumeItemNum()
		return
	end

	local function ok_callback(is_auto)

		if is_auto ~= nil then
			self.is_auto_buy = is_auto

			if self.is_auto ~= nil and is_auto ~= nil then
				self.is_auto:SetValue(is_auto)
			end
		end

		if roll_type == 10 then
			self.is_click_once = false
		else
			self.is_click_once = true
		end
		self:ResetVariable()
		self:ResetHighLight()
		ShenGeData.Instance:SetBlessAniState(self.play_ani_toggle.isOn)
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_CHOUJIANG, roll_type, self.is_auto_buy and 1 or 0)
	end

	--if not TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shenge_zk"] or not TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shenge_zk"].is_auto_buy then
	ShenGeData.Instance:SetCurBlessAutoBuyState(self.is_auto_buy)
	if not self.is_auto_buy and ItemData.Instance:GetItemNumInBagById(self.item_id) < buy_num then
		local str = string.format(Language.ShenGe.ZKUpTip, roll_type)
		TipsCtrl.Instance:ShowCommonAutoView("auto_shenge_bless", str, ok_callback, canel_callback, true, nil, nil, nil, true)
	else
		ok_callback()
	end

end

function ShenGeBlessView:OnDataChange(info_type, param1, param2, param3, bag_list)
	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO then
		self:ResetVariable()
		self:ResetHighLight()
		-- self:SetButtonData(param1, param3, bag_list)
		-- self:SetRestTime(param3, param1)

		self:SaveVariable(param2, bag_list)
		self:TrunPointer()

		if self.play_ani_toggle.isOn then
			self:ShowRawardTip()
			self:ShowHightLight()
		end
		self:FlushAutoBuy()
	end
end

function ShenGeBlessView:ItemDataChangeCallBack(item_id)
	local cfg = ShenGeData.Instance:GetOtherCfg().once_chou_item
	if item_id == cfg.item_id then
		self:FlushItemInfo(item_id)
	end
end

function ShenGeBlessView:FlushItemInfo(item_id)
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
	self.item_cell:SetData({item_id = item_id, num = item_num, is_bind = 0})
	
	local str = ToColorStr(item_num, TEXT_COLOR.GREEN)
	local str2 = ToColorStr(item_num, TEXT_COLOR.RED)
	if self.my_items and self.my_items_ten then
		self.my_items:SetValue(item_num > 0 and str or str2)
		self.my_items_ten:SetValue(item_num >= 9 and str or str2)
	end
end

function ShenGeBlessView:SetConsumeItemNum()
	local cfg = ShenGeData.Instance:GetOtherCfg().once_chou_item
	if cfg == nil then
		return
	else
		self.item_id = cfg.item_id
	end

	if self.item_id == nil then
		return
	end

	-- local item_amount_val = ItemData.Instance:GetItemNumInBagById(self.item_id)
	-- local item_amount_str = ""
	-- self.item_amount:SetValue(item_amount_val)
	-- -- if item_amount_val == 0 then
	-- -- 	item_amount_str = "<color='#FF0000FF'>" .. item_amount_val .. "</color>"
	-- -- else
	-- -- 	item_amount_str = item_amount_val
	-- -- end
	-- --self.item_amount:SetValue(item_amount_str)
	-- local color = ITEM_COLOR[ItemData.Instance:GetItemConfig(self.item_id).color]

	-- if self.consume_item ~= nil then
	-- 	self.consume_item:SetData({item_id = self.item_id})
	-- end
end

function ShenGeBlessView:OnToggleChange(is_on)
	ShenGeData.Instance:SetBlessAniState(is_on)
	TipsCtrl.Instance:SetTreasurePlayAniFlag(TREASURE_TYPE.SHEN_GE_BLESS, is_on)
end

function ShenGeBlessView:SetItemShow()
	for i = 1, 8 do
		self.item_list[i]:SetData(ShenGeData.Instance:GetShenGeBlessShowData(i - 1))
		self.item_list[i]:SetShenGeInfo(ShenGeData.Instance:GetShenGeBlessShowData(i - 1))
	end
end

function ShenGeBlessView:SetBlessCost()
	local other_cfg = ShenGeData.Instance:GetOtherCfg()
	if nil == other_cfg then
		self.once_cost:SetValue(0)
		self.tence_cost:SetValue(0)
		return
	end
	self.once_cost:SetValue(other_cfg.one_chou_need_gold)
	self.tence_cost:SetValue(other_cfg.ten_chou_need_gold)
end

function ShenGeBlessView:OnClickBuy()
	self.is_auto_buy = not self.is_auto_buy
	if self.is_auto ~= nil then
		self.is_auto:SetValue(self.is_auto_buy)
		TipsCommonBuyView.AUTO_LIST[self.item_id] = self.is_auto_buy
	end
	TipsCtrl.Instance:HodeAutoBuyValue("auto_shenge_bless", self.is_auto_buy)
end

function ShenGeBlessView:TrunPointer()
	if self.is_rolling then
		return
	end
	if self.play_ani_toggle.isOn then
		local angle = ShenGeData.Instance:GetBlessIndex(self.types, self.quality + 1) * -45
		self.center_pointer.transform.localRotation = Quaternion.Euler(0, 0, angle)
		self:ShowHightLight()
		self:ShowRawardTip()
		return
	end
	self.is_rolling = true
	self.once_btn.button.interactable = false
	self.ten_btn.button.interactable = false
	local time = 0
	local tween = self.center_pointer.transform:DORotate(
		Vector3(0, 0, -360 * 20),
		20,
		DG.Tweening.RotateMode.FastBeyond360)
	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function ()
		time = time + UnityEngine.Time.deltaTime
		if time >= 1 and self.count > 0 then
			tween:Pause()
			local angle = ShenGeData.Instance:GetBlessIndex(self.types, self.quality + 1) *  -45
			local tween1 = self.center_pointer.transform:DORotate(
					Vector3(0, 0, -360 * 3 + angle),
					2,
					DG.Tweening.RotateMode.FastBeyond360)
			tween1:OnComplete(function ()
				self.is_rolling = false
				self:ShowHightLight()
				self:ShowRawardTip()
				self.once_btn.button.interactable = true
				self.ten_btn.button.interactable = true
			end)
		end
	end)
end

function ShenGeBlessView:SaveVariable(count, data_list)
	self.count = count
	self.quality = data_list[0] and data_list[0].quality or 0
	self.types = data_list[0] and data_list[0].type or 0
end

function ShenGeBlessView:ResetVariable()
	self.count = 0
	self.quality = 0
	self.types = 0
end

function ShenGeBlessView:ResetHighLight()
	-- self.show_hight_light_10:SetValue(false)
	-- self.show_hight_light_11:SetValue(false)
	-- self.show_hight_light_12:SetValue(false)
	-- self.show_hight_light_5:SetValue(false)
	-- self.show_hight_light_0:SetValue(false)

	-- self.show_hight_light_1:SetValue(false)
	-- self.show_hight_light_2:SetValue(false)
	-- self.show_hight_light_3:SetValue(false)
	-- self.show_hight_light_4:SetValue(false)
	if self.show_hight_list ~= nil then
		for k,v in pairs(self.show_hight_list) do
			if v ~= nil then
				v:SetValue(false)
			end
		end
	end
end

function ShenGeBlessView:ShowRawardTip()
	local function call()
		if self.play_ani_toggle then
			self.play_ani_toggle.isOn = TipsCtrl.Instance:GetTreasurePlayAniFlag(TREASURE_TYPE.SHEN_GE_BLESS)
		end
	end

	if self.is_click_once then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_1, true, call)
	else
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_SHEN_GE_BLESS_MODE_10, true, call)
	end
end

function ShenGeBlessView:ShowHightLight()
	-- local index = self.types or 0
	-- if index >= 10 then
	-- 	self["show_hight_light_"..index]:SetValue(true)
	-- else
	-- 	index = self.quality
	-- 	self["show_hight_light_"..index]:SetValue(true)
	-- end
	if self.types ~= nil and self.quality ~= nil then
		local index = ShenGeData.Instance:GetBlessIndex(self.types, self.quality + 1)
		if self.show_hight_list ~= nil and self.show_hight_list[index + 1] ~= nil then
			self.show_hight_list[index + 1]:SetValue(true)
		end
	end
end

function ShenGeBlessView:OnFlush(param_list)
	self:SetItemShow()
	self:SetBlessCost()
	-- self:SetButtonData()
	-- self:SetRestTime()
	self:ResetHighLight()
	self:SetConsumeItemNum()
	self:FlushAutoBuy()
	if self.play_ani_toggle then
		self.play_ani_toggle.isOn = TipsCtrl.Instance:GetTreasurePlayAniFlag(TREASURE_TYPE.SHEN_GE_BLESS)
	end
end

function ShenGeBlessView:FlushAutoBuy()
	if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_shenge_bless"] then
		if self.is_auto ~= nil then
			self.is_auto:SetValue(TipsCommonBuyView.AUTO_LIST[self.item_id])
			ShenGeData.Instance:SetCurBlessAutoBuyState(TipsCommonBuyView.AUTO_LIST[self.item_id])
		end
	end
end

function ShenGeBlessView:OnClickItem(index)
	local data = ShenGeData.Instance:GetShenGeBlessShowData(index - 1)
	if nil == data then return end
	ShenGeCtrl.Instance:ShowBlessPropTip(data)
end