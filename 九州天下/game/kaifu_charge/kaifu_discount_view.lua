KaiFuDiscountView = KaiFuDiscountView or BaseClass(BaseRender)

function KaiFuDiscountView:__init()
	self.ui_config = {"uis/views/kaifuchargeview","DiscountContent"}

	self.auto_buy_flag_list = {
		["auto_type_1"] = false,
	}
end

function KaiFuDiscountView:__delete()
	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end

	if self.toggle_cell_list then
		for k, v in pairs(self.toggle_cell_list) do
			v:DeleteMe()
		end
		self.toggle_cell_list = {}
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function KaiFuDiscountView:LoadCallBack()
	self.list_view = self:FindObj("ListView")
	self.toggle_list = self:FindObj("ToggleList")
	self.serpius_time = self:FindVariable("TimeSrt")
	self.show_discount = self:FindVariable("Show_Discount")
	
	self.cell_list = {}
	self.list_view_info = {}
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshDel, self)

	self.toggle_cell_list = {}
	local toggle_list_delegate = self.toggle_list.list_simple_delegate
	toggle_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetToggleCellNumber, self)
	toggle_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshToggleDel, self)
end

function KaiFuDiscountView:ShowDiscountView(value)
	if self.show_discount then
		self.show_discount:SetValue(value)
	end
end

function KaiFuDiscountView:GetCellNumber()
	return #self.list_view_info or 0
end

function KaiFuDiscountView:RefreshDel(cell, data_index)
	data_index = data_index + 1

	local shop_cell = self.cell_list[cell]
	if shop_cell == nil then
		shop_cell = DisCountCell.New(cell.gameObject)
		self.cell_list[cell] = shop_cell
	end
	shop_cell:SetState(self.auto_buy_flag_list)
	shop_cell:SetIndex(data_index)
	shop_cell:SetData(self.list_view_info[data_index])
end

function KaiFuDiscountView:GetToggleCellNumber()
	local open_info = KaiFuChargeData.Instance:GetDiscountOpenIndex()
	return #open_info or 0
end

function KaiFuDiscountView:RefreshToggleDel(cell, data_index)
	data_index = data_index + 1

	local toggle_cell = self.toggle_cell_list[cell]
	if toggle_cell == nil then
		toggle_cell = DisCountToggle.New(cell.gameObject)
		toggle_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		self.toggle_cell_list[cell] = toggle_cell
	end

	toggle_cell:SetIndex(data_index)
	local data = KaiFuChargeData.Instance:GetDiscountOpenIndex()
	toggle_cell:SetData(data[data_index])
	toggle_cell:SetHighLight(self:GetCurIndex())
end

function KaiFuDiscountView:FlushShopInfo()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end
end

function KaiFuDiscountView:FlushToggleInfo()
	if self.toggle_list.scroller.isActiveAndEnabled then
		self.toggle_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function KaiFuDiscountView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k[1] == "flush_all_type" then
			local data = KaiFuChargeData.Instance:GetDiscountOpenIndex()
			if data and #data > 0 then
				local index = self:GetCurIndex() - 1
				for i = 1, #data do
					if data[i].index == self:GetCurType() then
						index = i
					end
				end
				index = index > #data and 1 or index
				local cur_index = index > 0 and index or 1
				self:SetCurIndex(cur_index)
				self:SetShopInfo(data[cur_index].index)
				self:SetCurType(data[cur_index].index)
			end
		elseif k[1] == "flush_type_cell" then
			self:FlushShopInfo()
		end
	end
	self:FlushToggleInfo()

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Timer, self), 0)
end

function KaiFuDiscountView:OnClickItemCallBack(cell, select_index)
	if nil == cell or nil == cell.data then
		return
	end
	self:SetCurIndex(cell.index)
	self:SetCurType(cell.data.index)
	self:SetShopInfo(cell.data.index)
end

function KaiFuDiscountView:SetShopInfo(index)
	local config = KaiFuChargeData.Instance:GetDiscountInfoCfg(index)
	if config then
		self.list_view_info = config or {}
		KaiFuChargeCtrl.Instance:SendXufuInfoReq(index)
	end
end

function KaiFuDiscountView:Timer()
	local info = KaiFuChargeData.Instance:GetXufuInfo()
	if not next(info) or not next(self.list_view_info) then return end
	local time = info.active_stamp + self.list_view_info[1].last_time - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
		return
	end
	self.serpius_time:SetValue(TimeUtil.FormatSecond(time, 3))
end

function KaiFuDiscountView:SetCurIndex(index)
	self.cur_index = index or 0
end

function KaiFuDiscountView:GetCurIndex()
	return self.cur_index or 0
end

function KaiFuDiscountView:SetCurType(index)
	self.cur_type = index or 0
end

function KaiFuDiscountView:GetCurType()
	return self.cur_type or 0
end

-----------------------------DisCountCell-------------------------------
DisCountCell = DisCountCell or BaseClass(BaseCell)

local GIFT_TYPE = {
	BIND_GOLD = 1,
	GOLD = 2,
	RMB = 3,
}

function DisCountCell:__init()
	
	self.des_type_image = self:FindVariable("DesImage")
	self.gold_image = self:FindVariable("GoldImage")
	self.dis_itme_image = self:FindVariable("DisItemBgImage")
	self.gift_type_image = self:FindVariable("GiftTypeImage")

	self.name = self:FindVariable("Name")
	self.new_price = self:FindVariable("NewPrice")
	self.is_sell_out = self:FindVariable("IsSellOut")
	self.is_show_rmb = self:FindVariable("IsShowRMB")
	
	self.zhe_kou = self:FindVariable("ZheKou")
	self.power = self:FindVariable("Power")
	self.jie_shu = self:FindVariable("JieShu")
	self.is_show_jieshu = self:FindVariable("IsShowJieShu")


	self:ListenEvent("ClickBuy", BindTool.Bind(self.ClickBuy, self))

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
end

function DisCountCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	UnityEngine.PlayerPrefs.DeleteKey("auto_buy_dis_count")
end

function DisCountCell:SetState(temp)
	self.auto_buy_flag_list = temp
end

function DisCountCell:OnFlush()
	if not self.data or not next(self.data) then return end

	self.dis_itme_image:SetAsset(ResPath.GetRawImage("item_bg_0" .. self.data.seq + 1))
	self.des_type_image:SetAsset(ResPath.GetSanXingSongLiDesType(self.data.price_type))
	self.gift_type_image:SetAsset(ResPath.GetSanXingSongLiGiftType(self.data.gift_type))

	self.item_cell:SetData({item_id = self.data.gift_id})

	local str_table = Split(self.data.gift_title, "|")
	if str_table then
		self.name:SetValue(str_table[1])
		self.is_show_jieshu:SetValue(#str_table > 1)
		self.jie_shu:SetValue(#str_table > 1 and str_table[2] or "")
	end

 	if self.data.price_type == GIFT_TYPE.RMB then
 		self.new_price:SetValue(self.data.gift_price/10)
 	else
 		self.new_price:SetValue(self.data.gift_price)
 	end

	self.is_show_rmb:SetValue(self.data.price_type == GIFT_TYPE.RMB)

	self.zhe_kou:SetValue(self.data.gift_discount)
	self.power:SetValue(self.data.gift_combat)

	local info = KaiFuChargeData.Instance:GetXufuInfo()
	if next(info) then
		if self.data.price_type == GIFT_TYPE.BIND_GOLD then
		-- 	info_limit_num = info.bind_gold_buy_times							
			self.gold_image:SetAsset(ResPath.GetGoldIcon(1001))
		elseif self.data.price_type == GIFT_TYPE.GOLD then
		-- 	info_limit_num = info.gold_buy_times										
			self.gold_image:SetAsset(ResPath.GetGoldIcon(1000))
		elseif self.data.price_type == GIFT_TYPE.RMB then
			info_limit_num = info.RMB_buy_times
		end
		local info_limit_num = info.gift_buy_num_list and info.gift_buy_num_list[self.data.seq] or 0
		local limit_num = self.data.buy_limit - info_limit_num
		self.is_sell_out:SetValue(limit_num <= 0)
	end
end

function DisCountCell:ClickBuy()
	if not self.data or not next(self.data) then return end

	local str = ""
	if self.data.price_type == GIFT_TYPE.RMB then
		--付费链接
		RechargeCtrl.Instance:Recharge(self.data.gift_price / 10)
		return
	elseif self.data.price_type == GIFT_TYPE.BIND_GOLD then
		str = Language.Common.UsedGoldToBuySomething
	elseif self.data.price_type == GIFT_TYPE.GOLD then
		str = Language.Common.UsedGoldToBuySomething1
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.gift_id)
	local item_color = GameEnum.ITEM_COLOR_WHITE
	local item_name = ""
	if item_cfg then
		item_color = item_cfg.color
		item_name = item_cfg.name
	end

	local func = function(is_auto)
		self.auto_buy_flag_list["auto_type_1"] = is_auto
		KaiFuChargeCtrl.Instance:SendXufuBuyReq(self.data.seq, self.data.gift_type)
	end

	if self.auto_buy_flag_list["auto_type_1"] then
		func(true)
	else
		local str = string.format(str, ToColorStr(self.data.gift_price, TEXT_COLOR.YELLOW), ToColorStr(item_name, ITEM_COLOR[item_color]))
		TipsCtrl.Instance:ShowCommonAutoView("kaifudiscount", str, func, nil, true, nil, nil, Language.Common.NoGolDenoug)
	end
end

-----------------------DisCountToggle--------------------
DisCountToggle = DisCountToggle or BaseClass(BaseCell)

function DisCountToggle:__init()
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))

	self.name = self:FindVariable("Name")
	self.show_hl = self:FindVariable("ShowHL")
end

function DisCountToggle:OnFlush()
	if self.data then
		self.name:SetValue(Language.Common.GongNeng_Type[self.data.index])
	end
end

function DisCountToggle:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function DisCountToggle:SetHighLight(value)
	if self.show_hl and value then
		self.show_hl:SetValue(value == self.index)
	end
end