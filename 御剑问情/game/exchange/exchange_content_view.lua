ExchangeContentView = ExchangeContentView or BaseClass(BaseRender)

function ExchangeContentView:__init(instance)
	ExchangeContentView.Instance = self
	self.contain_cell_list = {}
	self.is_default_select = true
	self.current_item_id = -1
	self.current_price_type = ExchangeData.Instance:GetCurIndex() or 1
	self.pagecount = self:FindVariable("PageCount")
	self.toggle1 = self:FindObj("toggle1")
	self:InitListView()
	self.buy_num = -1
	self.coin_icon = self:FindVariable("coin_icon")
	self.coin_text = self:FindVariable("coin_text")
	self.botton_text = self:FindVariable("botom_text")
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 监听系统事件
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function ExchangeContentView:__delete()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
	self.current_price_type = 1
	self.list_view = nil
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end


function ExchangeContentView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num, useless_param, isLast)
	self:FlushAllFrame()
end

function ExchangeContentView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.pagecount:SetValue(self:GetNumberOfCells())
end

function ExchangeContentView:GetNumberOfCells()
	local item_id_list = ExchangeData.Instance:GetItemIdListByJobAndType(2, self.current_price_type,GameVoManager.Instance:GetMainRoleVo().prof)
	if #item_id_list%8 ~= 0 then
		self.list_view.list_page_scroll:SetPageCount(math.ceil(#item_id_list/8))
		return math.ceil(#item_id_list/8)
	else
		self.list_view.list_page_scroll:SetPageCount(#item_id_list/8)
		return #item_id_list/8
	end
end

function ExchangeContentView:PlayerDataChangeCallback(attr_name, value, old_value)
	if self.current_price_type == EXCHANGE_PRICE_TYPE.RONGYAO and attr_name == "cross_honor" then
		self:FlushCoin()
	end
end

function ExchangeContentView:GetCellList()
	return self.contain_cell_list
end

function ExchangeContentView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ExchangeContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
		contain_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	cell_index = cell_index + 1
	local is_activity_open = ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE)
	local item_id_list = ExchangeData.Instance:GetItemListByJobAndIndex(2, self.current_price_type, GameVoManager.Instance:GetMainRoleVo().prof, cell_index, not is_activity_open)
	contain_cell:InitItems(item_id_list)
	contain_cell:SetIndex(cell_index)
end

function ExchangeContentView:SetCurrentItemId(item_id)
	self.current_item_id = item_id
end

function ExchangeContentView:GetCurrentItemId()
	return self.current_item_id
end

function ExchangeContentView:SetBuyNum(buy_num)
	self.buy_num = buy_num
end

function ExchangeContentView:OnFlushAllCell()
	for k,v in pairs(self.contain_cell_list) do
		v:OnFlushAllCell()
	end
end

function ExchangeContentView:SetCurrentPriceType(price_type)
	self.current_price_type = price_type
end

function ExchangeContentView:GetCurrentPriceType()
	return self.current_price_type
end

function ExchangeContentView:OnFlushListView()
	self.list_view.scroller:ReloadData(0)
	self.pagecount:SetValue(self:GetNumberOfCells())
	self.toggle1.toggle.isOn = false
	self.toggle1.toggle.isOn = true
end

function ExchangeContentView:FlushCoin()
	local res = ExchangeData.Instance:GetExchangeRes(self.current_price_type)
	local bundle, asset = ResPath.GetExchangeNewIcon(res)
	self.coin_icon:SetAsset(bundle, asset)
	if self.current_price_type == EXCHANGE_PRICE_TYPE.RONGYAO then
		self.coin_text:SetValue(PlayerData.Instance.role_vo.cross_honor or 0)
	else
		self.coin_text:SetValue(ExchangeData.Instance:GetScoreList()[self.current_price_type] or 0)
	end
	local str = ""
	if self.current_price_type == EXCHANGE_PRICE_TYPE.MOJING then
		str = Language.Exchange.MojingGetWay
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.SHENGWANG then
		str = Language.Exchange.ShengwangGetWay
	elseif self.current_price_type == EXCHANGE_PRICE_TYPE.RONGYAO then
		str = Language.Exchange.RongyuGetWay
	end
	self.botton_text:SetValue(str)
end

function ExchangeContentView:FlushAllFrame()
	for k,v in pairs(self.contain_cell_list) do
		v:FlushAllFrame()
	end
end

function ExchangeContentView:SetIsOpen(is_open)
	self.is_open = is_open
end

function ExchangeContentView:GetIsOpen()
	return self.is_open
end
------------------------------------------------------------------------
ExchangeContain = ExchangeContain  or BaseClass(BaseCell)

function ExchangeContain:__init()
	self.exchange_contain_list = {}
	for i = 1, 8 do
		self.exchange_contain_list[i] = {}
		self.exchange_contain_list[i] = ExchangeItem.New(self:FindObj("item_" .. i))
	end
end

function ExchangeContain:__delete()
	for i=1,8 do
		self.exchange_contain_list[i]:DeleteMe()
		self.exchange_contain_list[i] = nil
	end
end

function ExchangeContain:GetFirstCell()
	return self.exchange_contain_list[1]
end

function ExchangeContain:InitItems(item_id_list)
	for i=1,8 do
		self.exchange_contain_list[i]:SetItemId(item_id_list[i])
		self.exchange_contain_list[i]:OnFlush()
	end
end

function ExchangeContain:FlushItems(item_id_list,toggle_group)
	for i=1,8 do
		local consume_type = ShopData.Instance:GetConsumeType(ShopContentView.Instance:GetCurrentShopType())
		if item_id_list[i] ~= 0 then
			local data = ItemData.Instance:GetItemConfig(item_id_list[i]) or {}
			data.item_id = data.id
			if consume_type == SHOP_BIND_TYPE.BIND then
				data.is_bind = 1
			elseif consume_type == SHOP_BIND_TYPE.NO_BIND then
				data.is_bind = 0
			end
			self.shop_contain_list[i].item_cell:SetData(data)
		end
		self.shop_contain_list[i].item_frame:FlushFrame(item_id_list[i])
	end
end

function ExchangeContain:SetToggleGroup(toggle_group)
	for i=1,8 do
		self.exchange_contain_list[i]:SetToggleGroup(toggle_group)
	end
end

function ExchangeContain:FlushAllFrame()
	for i=1,8 do
		self.exchange_contain_list[i]:OnFlush()
	end
end
----------------------------------------------------------------------------
ExchangeItem = ExchangeItem or BaseClass(BaseCell)

function ExchangeItem:__init()
	self.name = self:FindVariable("name")
	self.coin = self:FindVariable("coin")
	self.coin_icon = self:FindVariable("coin_icon")
	self.remain_text = self:FindVariable("remain_text")
	self.limit_text = self:FindVariable("limit_text")
	self.left_day = self:FindVariable("LeftDay")
	self.left_hour = self:FindVariable("LeftHour")
	self.left_minute = self:FindVariable("LeftMinute")
	self.left_second = self:FindVariable("LeftSecond")
	self.least_time = self:FindVariable("least_time")
	self.show_exchange_text = self:FindVariable("show_exchange_text")
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick,self))
	self.item_id = 0
	self.is_jueban = 0
	self.need_stuff_id = 0
	self.need_stuff_count = 0
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	self.item_cell:ShowHighLight(false)
	self.price_multile = 0
	self.cur_multile_price = 0
	self.multiple_time = 0
	self.is_max_multiple = false
end

function ExchangeItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end
end

function ExchangeItem:SetItemId(item_id_list)
	local cfg = item_id_list
	if cfg == 0 then
		return
	end
	if nil ~= cfg then
		self.item_id = cfg[1]
		self.is_jueban = cfg[2]
		self.need_stuff_id = cfg[3]
		self.need_stuff_count = cfg[4]
	end
end

function ExchangeItem:OnFlush()
	self.price_multile = 0
	self.cur_multile_price = 0
	self.multiple_time = 0
	self.is_max_multiple = false
	self.root_node:SetActive(true)
	if self.item_id == 0 then
		self.root_node:SetActive(false)
		return
	end
	local item_info = ExchangeData.Instance:GetExchangeCfg(self.item_id, ExchangeContentView.Instance:GetCurrentPriceType())
	if not item_info then return end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local text = ""
	local price_type = ExchangeContentView.Instance:GetCurrentPriceType()
	local conver_value = ExchangeData.Instance:GetConvertCount(item_info.seq, EXCHANGE_CONVER_TYPE.DAO_JU, price_type)
	local multiple_cfg = ExchangeData.Instance:GetMultipleCostCfg(conver_value + 1, item_info.multiple_cost_id)
	if multiple_cfg then
		self.multiple_time = multiple_cfg.times_max - conver_value
		text = 0 == multiple_cfg.is_max_times and Language.Exchange.Change .. self.multiple_time .. Language.Exchange.TwoMoney or Language.Exchange.MaxTime
		self.price_multile = multiple_cfg.price_multile
		self.is_max_multiple = 1 == multiple_cfg.is_max_times
	end

	if item_info.require_type == REQUIRE_TYPE.LEVEL and main_role_vo.level < item_info.require_value then
		local level_des = PlayerData.GetLevelString(item_info.require_value)
		text = string.format(Language.Exchange.NeedLevel, level_des)
	end

	local limit_value = ""
	local desc = item_info.lifetime_convert_count > 0 and Language.Exchange.TodayExchange or Language.Exchange.TodayExchange
	if conver_value == item_info.limit_convert_count then
		-- limit_value = desc .. ToColorStr(item_info.limit_convert_count - conver_value, TEXT_COLOR.RED) .. "/" .. item_info.limit_convert_count
		limit_value = string.format(desc, item_info.limit_convert_count - conver_value)
	else
		-- limit_value = desc .. ToColorStr(item_info.limit_convert_count - conver_value, TEXT_COLOR.GREEN) .. "/" .. item_info.limit_convert_count
		limit_value = string.format(desc, item_info.limit_convert_count - conver_value)
	end
	self.limit_text:SetValue((item_info.limit_convert_count == 0 or text ~= "") and "" or limit_value)

	self.remain_text:SetValue(text)
	if self.need_stuff_id > 0 then
		local num = ItemData.Instance:GetItemNumInBagById(self.need_stuff_id)
		local stuff_cfg = ItemData.Instance:GetItemConfig(self.need_stuff_id)
		if stuff_cfg then
			local color = num < self.need_stuff_count and "#ff0000" or "#0000f1"
			self.limit_text:SetValue(string.format(Language.Exchange.Need, color, stuff_cfg.name))
			self.remain_text:SetValue("")
		end
	end
	local res = ExchangeData.Instance:GetExchangeRes(ExchangeContentView.Instance:GetCurrentPriceType())
	local bundle2, asset2 = ResPath.GetExchangeNewIcon(res)
	self.coin_icon:SetAsset(bundle2, asset2)
	local price = item_info.price * (self.price_multile == 0 and 1 or self.price_multile)
	self.cur_multile_price = price
	self.coin:SetValue(price)
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	if item_cfg then
		self.name:SetValue(ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
		self.item_cell:SetData({item_id = self.item_id, is_bind = item_info.is_bind, is_jueban = self.is_jueban})
		self.item_cell:IsDestoryActivityEffect(not ExchangeData.Instance:IsShowEffect(self.item_id))
		self.item_cell:SetActivityEffect()
	end
	if self.click_self then
		self:OnToggleClick(true)
		self.click_self = false
	end
	if self.is_jueban == 1 then
		self.show_exchange_text:SetValue(false)
		self.least_time:SetValue(true)
		self:InitData()
	else
		self.show_exchange_text:SetValue(true)
		self.least_time:SetValue(false)
	end
end



function ExchangeItem:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function ExchangeItem:InitData()
	local activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE
	local time_tab = TimeUtil.Format2TableDHMS(ActivityData.Instance:GetActivityResidueTime(activity_type))
	self:SetTime(time_tab)

	local rareChange_time = time_tab.day * 24 * 3600 + time_tab.hour * 3600 + time_tab.min * 60 + time_tab.s
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end

	self.least_time_timer = CountDown.Instance:AddCountDown(rareChange_time, 1, function (elapse_time, total_time)
			if elapse_time >= total_time then
				ViewManager.Instance:FlushView(ViewName.Exchange, "flush_list_view")
				return
			end
			time_tab = TimeUtil.Format2TableDHMS(ActivityData.Instance:GetActivityResidueTime(activity_type))
            self:SetTime(time_tab)
        end)

end

function ExchangeItem:SetTime(time_tab)
	if time_tab.day < 1 then
		self.left_day:SetValue("")
		if time_tab.hour < 10 then
			self.left_hour:SetValue(ToColorStr("0" .. time_tab.hour, COLOR.RED))
		else
			self.left_hour:SetValue(ToColorStr(time_tab.hour, COLOR.RED))
		end
		if time_tab.min < 10 then
			self.left_minute:SetValue(ToColorStr(":" .. "0" .. time_tab.min, COLOR.RED))
		else
			self.left_minute:SetValue(ToColorStr(":" .. time_tab.min, COLOR.RED))
		end
		if time_tab.s < 10 then
			self.left_second:SetValue(ToColorStr(":" .. "0" .. time_tab.s, COLOR.RED))
		else
			self.left_second:SetValue(ToColorStr(":" .. time_tab.s, COLOR.RED))
		end
	else
		self.left_day:SetValue(ToColorStr(time_tab.day .. "天", TEXT_COLOR.BLUE_4))
		self.left_hour:SetValue("")
		self.left_minute:SetValue("")
		self.left_second:SetValue("")
		-- if time_tab.hour < 10 then
		-- 	self.left_hour:SetValue(ToColorStr("0" .. time_tab.hour, COLOR.GREEN))
		-- else
		-- 	self.left_hour:SetValue(ToColorStr(time_tab.hour, COLOR.GREEN))
		-- end
		-- if time_tab.min < 10 then
		-- 	self.left_minute:SetValue(ToColorStr(":" .. "0" .. time_tab.min, COLOR.GREEN))
		-- else
		-- 	self.left_minute:SetValue(ToColorStr(":" .. time_tab.min, COLOR.GREEN))
		-- end
		-- if time_tab.s < 10 then
		-- 	self.left_second:SetValue(ToColorStr(":" .. "0" .. time_tab.s, COLOR.GREEN))
		-- else
		-- 	self.left_second:SetValue(ToColorStr(":" .. time_tab.s, COLOR.GREEN))
		-- end
	end
end

function ExchangeItem:SelectToggle()
	self.root_node.toggle.isOn = true
end

function ExchangeItem:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
	self.root_node.toggle.isOn = false
end

function ExchangeItem:OnToggleClick(is_click)
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local item_info = ExchangeData.Instance:GetExchangeCfg(self.item_id, ExchangeContentView.Instance:GetCurrentPriceType())
	 if is_click then
		local close_func = function()
			self.root_node.toggle.isOn = false
		end
		if self.price_multile > 0 or self.is_max_multiple then
			local price_type = ExchangeContentView.Instance:GetCurrentPriceType()
			local func = function()
				ExchangeCtrl.Instance:SendScoreToItemConvertReq(item_info.conver_type, item_info.seq, 1)
			end
			local coin_name = ""
			if price_type == EXCHANGE_PRICE_TYPE.MOJING then
				coin_name = Language.Common.MoJing
			elseif price_type == EXCHANGE_PRICE_TYPE.SHENGWANG then
				coin_name = Language.Common.ShengWang
			elseif price_type == EXCHANGE_PRICE_TYPE.RONGYAO then
				coin_name = Language.Common.RongYao
			end
			local prop_name = "<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 1]..">"..item_cfg.name.."</color>"
			local content = string.format(Language.Exchange.Multiple_Tip, self.cur_multile_price, coin_name, prop_name, self.multiple_time)
			if self.is_max_multiple then
				content = string.format(Language.Exchange.Max_Multiple_Tip, self.cur_multile_price, coin_name, prop_name)
			end
			ExchangeCtrl.Instance:ShowExchangeView(self.item_id, ExchangeContentView.Instance:GetCurrentPriceType(),
			EXCHANGE_CONVER_TYPE.DAO_JU, close_func, self.cur_multile_price, self.multiple_time, self.is_max_multiple, click_func)
		else
			TipsCtrl.Instance:ShowExchangeView(self.item_id, ExchangeContentView.Instance:GetCurrentPriceType(), EXCHANGE_CONVER_TYPE.DAO_JU, close_func)
		end
	 end
end







