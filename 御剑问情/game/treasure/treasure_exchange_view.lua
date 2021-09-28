TreasureExchangeView = TreasureExchangeView or BaseClass(BaseRender)

function TreasureExchangeView:__init(instance)
	self.exchange_contain_list = {}
	self.coin_text = self:FindVariable("gold_text")
	self.item_cfg_list = TreasureData.Instance:GetItemIdListByJobAndType(TREASURE_EXCHANGE_CONVER_TYPE, EXCHANGE_PRICE_TYPE.TREASURE,GameVoManager.Instance:GetMainRoleVo().prof)
	self.pagecount = self:FindVariable("PageCount")
	local all_item_cfg = {}
	self.has_flash_change = TreasureData.Instance:IsFlashChange()
	if self.has_flash_change then
		self.rare_change = TreasureData.Instance:GetRareChangeList()
		for k,v in pairs(self.rare_change) do
			table.insert(all_item_cfg, v)
		end
		for k,v in pairs(self.item_cfg_list) do
			table.insert(all_item_cfg, v)
		end
		self.item_cfg_list = all_item_cfg
	end
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.pagecount:SetValue(self:GetNumberOfCells())
	self.list_view.list_page_scroll:SetPageCount(self:GetNumberOfCells())
end

function TreasureExchangeView:__delete()
	if self.exchange_contain_list ~= nil then
		for k, v in pairs(self.exchange_contain_list) do
			v:DeleteMe()
		end
	end
	self.exchange_contain_list = {}
end

function TreasureExchangeView:GetNumberOfCells()
	local count = #self.item_cfg_list
	if count%8 ~= 0 then
		return math.floor(count/8) + 1
	else
		return count/8
	end
end

function TreasureExchangeView:RefreshCell(cell, cell_index)
	local exchange_contain = self.exchange_contain_list[cell]
	if exchange_contain == nil then
		exchange_contain = TreasureExchangeContain.New(cell.gameObject, self)
		self.exchange_contain_list[cell] = exchange_contain
	end
	cell_index = cell_index + 1
	local item_id_list = TreasureData.Instance:GetItemListByJobAndIndex(TREASURE_EXCHANGE_CONVER_TYPE, EXCHANGE_PRICE_TYPE.TREASURE,GameVoManager.Instance:GetMainRoleVo().prof,cell_index)
	exchange_contain:SetData(item_id_list)
end

function TreasureExchangeView:OnFlush()
	for k,v in pairs(self.exchange_contain_list) do
		v:Flush()
	end
end

----------------------------------------------------------------------------
TreasureExchangeContain = TreasureExchangeContain or BaseClass(BaseCell)
function TreasureExchangeContain:__init()
	self.item_list = {}
	for i=1, 8 do
		self.item_list[i] = TreasureExchangeItem.New(self:FindObj("item_"..i))
	end
end
function TreasureExchangeContain:__delete()
	if self.item_list ~= nil then
		for k, v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}
end

function TreasureExchangeContain:OnFlush()
	for i=1,8 do
		self.item_list[i]:SetData(self.data[i])
	end
end
----------------------------------------------------------------------------
TreasureExchangeItem = TreasureExchangeItem or BaseClass(BaseCell)

function TreasureExchangeItem:__init()
	self.name = self:FindVariable("name")
	self.coin = self:FindVariable("coin")
	-- self.max_times = self:FindVariable("MaxTimes")
	self.had_use_times = self:FindVariable("HadUseTimes")
	self.show_no_limit = self:FindVariable("ShowNoLimit")
	self.max_times = self:FindVariable("MaxTimes")
	self.show_limit = self:FindVariable("ShowLimit")
	self.left_day = self:FindVariable("LeftDay")
	self.left_hour = self:FindVariable("LeftHour")
	self.left_minute = self:FindVariable("LeftMinute")
	self.left_second = self:FindVariable("LeftSecond")
	self.least_time = self:FindVariable("least_time")
	self.duihuan_num = self:FindVariable("duihuan_num")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))
	self:ListenEvent("click", BindTool.Bind(self.OnExchangeClick, self))

	self.bg_img = self:FindVariable("bg")
	self.bg_img:SetAsset(ResPath.GetImages("label_04","treasureview"))
	self.is_rare = self:FindVariable("israre")
	self.is_rare:SetValue(false)
	self.rare_change_list = TreasureData.Instance:GetRareChangeList()
end

function TreasureExchangeItem:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil

	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function TreasureExchangeItem:OnFlush()
	self.root_node:SetActive(true)
	if self.data[1] == 0 then
		self.root_node:SetActive(false)
		return
	end
	for k,v in pairs(self.rare_change_list) do
		if self.data[1] == v[1] then
			self.bg_img:SetAsset(ResPath.GetImages("rarechange_bg","treasureview"))
			self.is_rare:SetValue(true)
		end
	end
	local item_info = ExchangeData.Instance:GetExchangeCfg(self.data[1], EXCHANGE_PRICE_TYPE.TREASURE)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data[1])
	local prop_name = "<color="..SOUL_NAME_COLOR[item_cfg and item_cfg.color or 1]..">"..item_cfg.name.."</color>"
	self.name:SetValue(prop_name)
	self.coin:SetValue(item_info.price)
	self.item_cell:IsDestoryActivityEffect(item_info.price < 1000)
	self.item_cell:SetActivityEffect()
	self.max_times:SetValue(item_info.limit_convert_count)
	local text = ""
	self.show_no_limit:SetValue(item_info.limit_convert_count == 0)
	self.show_limit:SetValue(item_info.limit_convert_count ~= 0)
	if item_info.limit_convert_count ~= 0 then
		local conver_value = ExchangeData.Instance:GetConvertCount(item_info.seq, EXCHANGE_CONVER_TYPE.DAO_JU, EXCHANGE_PRICE_TYPE.TREASURE)
		text = tostring(conver_value)
		-- if conver_value == item_info.limit_convert_count then
		-- 	text = tostring(conver_value)
		-- 	text = ToColorStr(text, TEXT_COLOR.RED)
		-- else
		-- 	text = tostring(conver_value)
		-- 	text = ToColorStr(text, TEXT_COLOR.BLUE)
		-- end
	end
	self.had_use_times:SetValue(text)
	local data = {}
	data.item_id = self.data[1]
	data.is_jueban = self.data[2]
	data.is_bind = item_info.is_bind
	self.item_cell:SetData(data)
	if self.data[2] == 1 then
		self.least_time:SetValue(true)
		self.duihuan_num:SetValue(false)
		self:InitData()
	else
		self.least_time:SetValue(false)
		self.duihuan_num:SetValue(true)
	end
end

function TreasureExchangeItem:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function TreasureExchangeItem:InitData()
	local activity_type = RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_RARE_CHANGE
	local time_tab = TimeUtil.Format2TableDHMS(ActivityData.Instance:GetActivityResidueTime(activity_type))
	self:SetTime(time_tab)

	local rareChange_time = time_tab.day * 24 * 3600 + time_tab.hour * 3600 + time_tab.min * 60 + time_tab.s
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end

	self.least_time_timer = CountDown.Instance:AddCountDown(rareChange_time, 1, function ()
			time_tab = TimeUtil.Format2TableDHMS(ActivityData.Instance:GetActivityResidueTime(activity_type))
            self:SetTime(time_tab)
        end)

end

function TreasureExchangeItem:SetTime(time_tab)
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
		self.left_day:SetValue(ToColorStr(time_tab.day .. "天", "#ffff00"))
		self.left_hour:SetValue(ToColorStr(time_tab.hour .. "时", "#ffff00"))
		self.left_minute:SetValue(ToColorStr(time_tab.min .. "分", "#ffff00"))
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

function TreasureExchangeItem:OnExchangeClick()
	local exchange_data = ExchangeData.Instance
	local exchange_item_cfg = exchange_data:GetExchangeCfg(self.data[1], EXCHANGE_PRICE_TYPE.TREASURE)
	-- if exchange_data:GetScoreList()[EXCHANGE_PRICE_TYPE.TREASURE] >= exchange_item_cfg.price then
	-- 	ExchangeCtrl.Instance:SendScoreToItemConvertReq(exchange_item_cfg.conver_type, exchange_item_cfg.seq, 1)
	-- else
	-- 	TipsCtrl.Instance:ShowSystemMsg(Language.Common.LackTreasureScore)
	-- end
	TipsCtrl.Instance:ShowExchangeView(self.data[1], EXCHANGE_PRICE_TYPE.TREASURE, TREASURE_EXCHANGE_CONVER_TYPE, close_func)
end