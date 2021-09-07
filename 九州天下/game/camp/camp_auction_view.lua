CampAuctionView = CampAuctionView or BaseClass(BaseRender)

function CampAuctionView:__init()
	self.order_type = 0						-- 拍卖类型
	self.page = 1							-- 当前页数
	self.auction_sale_id = 0
	self.auction_item_id = 0				-- 当前选中的物品id
	self.auction_cur_gold = 0
	self.auction_yikou_gold = 0				-- 一口价
	self.is_only_show = 0					-- 是否只显示我竞价的物品
	self.screen = 0							-- 筛选
end

function CampAuctionView:__delete()
	self.order_type = 0
	self.page = 1
	self.auction_sale_id = 0
	self.auction_item_id = 0
	self.auction_cur_gold = 0
	self.auction_yikou_gold = 0
	self.is_only_show = 0
	self.screen = 0

	if self.camp_auction_cell_list then
		for k,v in pairs(self.camp_auction_cell_list) do
			v:DeleteMe()
		end
	end
	self.camp_auction_cell_list = {}

	if self.camp_auction_itemlog_cell_list then
		for k,v in pairs(self.camp_auction_itemlog_cell_list) do
			v:DeleteMe()
		end
	end
	self.camp_auction_itemlog_cell_list = {}
end

function CampAuctionView:LoadCallBack(instance)

	----------------------------------------------------
	-- 列表生成滚动条
	self.camp_auction_cell_list = {}
	self.camp_auction_listview_data = {}
	self.camp_auction_list = self:FindObj("AcutionListView")
	local camp_auction_list_delegate = self.camp_auction_list.list_simple_delegate
	--生成数量
	camp_auction_list_delegate.NumberOfCellsDel = function()
		return #self.camp_auction_listview_data or 0
	end
	--刷新函数
	camp_auction_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCampAuctionListView, self)
	----------------------------------------------------

	----------------------------------------------------
	-- 日志列表生成滚动条
	self.camp_auction_itemlog_cell_list = {}
	self.camp_auction_itemlog_listview_data = {}
	self.camp_auction_itemlog_list = self:FindObj("AcutionLogListView")
	local camp_auction_itemlog_list_delegate = self.camp_auction_itemlog_list.list_simple_delegate
	--生成数量
	camp_auction_itemlog_list_delegate.NumberOfCellsDel = function()
		return #self.camp_auction_itemlog_listview_data or 0
	end
	--刷新函数
	camp_auction_itemlog_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCampAuctionItemLogListView, self)
	----------------------------------------------------

	self.dropdown = self:FindObj("Dropdown").dropdown


	-- 监听UI事件
	self:ListenEvent("OnPageLeft", BindTool.Bind(self.OnBtnPageHandler, self, 0))
	self:ListenEvent("OnPageRight", BindTool.Bind(self.OnBtnPageHandler, self, 1))
	self:ListenEvent("OnBtnFixedPrice", BindTool.Bind(self.OnBtnFixedPriceHandler, self))
	self:ListenEvent("OnBtnBidding", BindTool.Bind(self.OnBtnBiddingHandler, self))
	self:ListenEvent("OnChangeOnlyShow", BindTool.Bind(self.OnChangeOnlyShowHandler, self))
	self:ListenEvent("OnBtnDropdown", BindTool.Bind(self.OnBtnDropdownHandler, self))
	self:ListenEvent("OnBtnTips", BindTool.Bind(self.OnBtnTipsHandler, self))
	self:ListenEvent("OnBtnTimeSort", BindTool.Bind(self.OnBtnTimeSortHandler, self))
	self:ListenEvent("OnBtnGoldSort", BindTool.Bind(self.OnBtnGoldSortHandler, self))
	-- 获取变量
	self.lbl_camp_gold = self:FindVariable("AuctionCampGold")
	self.lbl_page_num = self:FindVariable("AuctionPageNum")
	self.lbl_bidding_gold = self:FindVariable("AuctionBiddingGold")
	self.Is_Open_1 = self:FindVariable("IsOpen1")
	self.Is_Open_2 = self:FindVariable("IsOpen2")

	self.order_type = CAMP_SALE_ITEM_ORDER_TYPE.CAMP_SALE_ITEM_ORDER_TYPE_DEFUALT
end

function CampAuctionView:SendRequest()
	CampAuctionItemRender.SelectIndex = -1
	-- 请求拍卖-获取售卖结果列表
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_SALE_GET_ITEM_LIST, self.order_type, self.page, self.is_only_show, nil, self.screen)
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_SALE_GET_RESULT_LIST)
end

function CampAuctionView:OnFlush(param_list)
	local camp_saleitem_info = CampData.Instance:GetCampSaleItemList()

	self.lbl_camp_gold:SetValue(camp_saleitem_info.camo_gold)
	self.lbl_page_num:SetValue(camp_saleitem_info.page .. "/" .. camp_saleitem_info.total_page)

	-- 设置list数据
	self.camp_auction_listview_data = camp_saleitem_info.item_info_list
	if self.camp_auction_list.scroller.isActiveAndEnabled then
		self.camp_auction_list.scroller:ReloadData(0)
	end

	-- 设置itemloglist数据
	local camp_saleresult = CampData.Instance:GetCampSaleResultList()
	self.camp_auction_itemlog_listview_data = camp_saleresult.sale_result_item_list
	if self.camp_auction_itemlog_list.scroller.isActiveAndEnabled then
		self.camp_auction_itemlog_list.scroller:ReloadData(0)
	end

	if self.auction_item_id <= 0 or CampAuctionItemRender.SelectIndex == -1 or next(self.camp_auction_listview_data) == nil then
		self.auction_item_id = 0
		local other_cfg = CampData.Instance:GetCampSaleOtherCfg()
		self.lbl_bidding_gold:SetValue(string.format(Language.Camp.AuctionBiddingGold, other_cfg.add_percent or 0))
	end

	if CampAuctionItemRender.SelectIndex ~= -1 and next(self.camp_auction_listview_data) ~= nil then
		local campsale_items_cfg = CampData.Instance:GetCampSaleItemsCfg()
		for k, v in pairs(campsale_items_cfg) do
			if v.sale_item and v.sale_item.item_id == self.auction_item_id then
				-- 当前竞价=当前价格+（起拍*加价百分比）
				local gold = math.floor(self.auction_cur_gold + (v.base_gold * (v.add_gold_percent / 100)))
				self.auction_cur_gold = gold
				self.lbl_bidding_gold:SetValue(gold .. Language.Common.ZuanShi)
			end
		end
	end
	------------是否显示.暂无.提示
	if #self.camp_auction_itemlog_listview_data > 0 then
	   self.Is_Open_1:SetValue(true)
	else
		self.Is_Open_1:SetValue(false)
	end
	if #self.camp_auction_listview_data > 0 then
		self.Is_Open_2:SetValue(true)
	else
		self.Is_Open_2:SetValue(false)
	end
end

function CampAuctionView:FlushItemList()
	if self.camp_auction_cell_list ~= nil then
		self.camp_auction_list.scroller:JumpToDataIndex(1)
		for k,v in pairs(self.camp_auction_cell_list) do
			if nil~= v.index and 1 == v.index then
				v:OnClickItemHandler()
			end
		end
	end
end

-- 列表listview
function CampAuctionView:RefreshCampAuctionListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local camp_auction_cell = self.camp_auction_cell_list[cell]
	if camp_auction_cell == nil then
		camp_auction_cell = CampAuctionItemRender.New(cell.gameObject)
		camp_auction_cell:SetToggleGroup(self.camp_auction_list.toggle_group)
		camp_auction_cell:SetClickCallBack(BindTool.Bind1(self.ClickCampAuctionHandler, self))
		self.camp_auction_cell_list[cell] = camp_auction_cell
	end
	camp_auction_cell:SetIndex(data_index)
	camp_auction_cell:SetData(self.camp_auction_listview_data[data_index])
end

-- 回调函数
function CampAuctionView:ClickCampAuctionHandler(cell)
	if nil == cell or nil == cell.data then return end

	local is_flush = true
	if self.auction_sale_id == cell.data.sale_id
		and self.auction_item_id == cell.data.item_id
		and self.auction_cur_gold == cell.data.cur_gold then

		is_flush = false
	end
	self.auction_sale_id = cell.data.sale_id
	self.auction_item_id = cell.data.item_id
	self.auction_cur_gold = cell.data.cur_gold

	local campsale_items_cfg = CampData.Instance:GetCampSaleItemsCfg()
	for k, v in pairs(campsale_items_cfg) do
		if v.sale_item and v.sale_item.item_id == self.auction_item_id then
			self.auction_yikou_gold = v.must_sale_gold
		end
	end

	if is_flush then
		self:Flush()
	end
end

-- 日志列表listview
function CampAuctionView:RefreshCampAuctionItemLogListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local camp_auction_item_log_cell = self.camp_auction_itemlog_cell_list[cell]
	if camp_auction_item_log_cell == nil then
		camp_auction_item_log_cell = CampAuctionItemLogItemRender.New(cell.gameObject)
		self.camp_auction_itemlog_cell_list[cell] = camp_auction_item_log_cell
	end
	camp_auction_item_log_cell:SetIndex(data_index)
	camp_auction_item_log_cell:SetData(self.camp_auction_itemlog_listview_data[data_index])
end

-- 翻页
function CampAuctionView:OnBtnPageHandler(page_type)
	local camp_saleitem_info = CampData.Instance:GetCampSaleItemList()
	if page_type == 0 then
		if self.page - 1 > 0 then
			CampAuctionItemRender.SelectIndex = -1
			self.auction_item_id = 0
			self.page = self.page - 1
			CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_SALE_GET_ITEM_LIST, self.order_type, self.page, self.is_only_show, nil, self.screen)
		end
	else

		if camp_saleitem_info.total_page >= self.page + 1 then
			CampAuctionItemRender.SelectIndex = -1
			self.auction_item_id = 0
			self.page = self.page + 1
			CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_SALE_GET_ITEM_LIST, self.order_type, self.page, self.is_only_show, nil, self.screen)
		end
	end
end

-- 一口价
function CampAuctionView:OnBtnFixedPriceHandler()
	if self.auction_item_id > 0 then
		local item_cfg = ItemData.Instance:GetItemConfig(self.auction_item_id)
		if item_cfg then
			local des = string.format(Language.Camp.IsHuaFeiYiKouJia, self.auction_yikou_gold, ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
			TipsCtrl.Instance:ShowCommonAutoView("camp_auction_auto_buy", des, function ()
				local camp_saleitem_info = CampData.Instance:GetCampSaleItemList()
				if self.page ~= camp_saleitem_info.page then
					self.page = camp_saleitem_info.page
				end
				CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_SALE_BUY, self.auction_sale_id, self.page, self.is_only_show, nil, self.screen)
				CampAuctionItemRender.SelectIndex = -1
				self.auction_item_id = 0
			end)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Camp.ConfirmItemTips)
	end
end

-- 竞价
function CampAuctionView:OnBtnBiddingHandler()
	if self.auction_item_id > 0 then
		local item_cfg = ItemData.Instance:GetItemConfig(self.auction_item_id)
		if item_cfg then
			local des = string.format(Language.Camp.IsHuaFeiJingJia, self.auction_cur_gold, ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
			TipsCtrl.Instance:ShowCommonAutoView("Camp_Auction", des, function ()
				local camp_saleitem_info = CampData.Instance:GetCampSaleItemList()
				if self.page ~= camp_saleitem_info.page then
					self.page = camp_saleitem_info.page
				end
				CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_SALE_ASK_PRICE, self.auction_sale_id, self.page, self.is_only_show, nil, self.screen)
			end)
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Camp.ConfirmItemTips)
	end
end

-- 只显示我竞价过的物品
function CampAuctionView:OnChangeOnlyShowHandler(value)
	self.page = 1
	self.is_only_show = value and 1 or 0
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_SALE_GET_ITEM_LIST, self.order_type, self.page, self.is_only_show, nil, self.screen)
end

-- 下拉框
function CampAuctionView:OnBtnDropdownHandler()
	self.screen = 0
	local campsale_items_cfg = CampData.Instance:GetCampSaleItemsCfg()
	for k, v in pairs(campsale_items_cfg) do
		if v.sale_item and v.select_type == self.dropdown.value then
			self.screen = v.sale_item.item_id
			if v.is_rare == 1 then
				self.screen = -1
			end
		end
	end
	self.page = 1
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_SALE_GET_ITEM_LIST, self.order_type, self.page, self.is_only_show, nil, self.screen)
end

-- 时间排序
function CampAuctionView:OnBtnTimeSortHandler()
	CampAuctionItemRender.SelectIndex = -1
	self.order_type = CAMP_SALE_ITEM_ORDER_TYPE.CAMP_SALE_ITEM_ORDER_TYPE_OTHER_1
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_SALE_GET_ITEM_LIST, self.order_type, self.page, self.is_only_show, nil, self.screen)
end

-- 价格排序
function CampAuctionView:OnBtnGoldSortHandler()
	CampAuctionItemRender.SelectIndex = -1
	self.order_type = CAMP_SALE_ITEM_ORDER_TYPE.CAMP_SALE_ITEM_ORDER_TYPE_OTHER_2
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_SALE_GET_ITEM_LIST, self.order_type, self.page, self.is_only_show, nil, self.screen)
end

function CampAuctionView:OnBtnTipsHandler()
	-- 拍卖Tips
	TipsCtrl.Instance:ShowHelpTipView(171)
end

----------------------------------------------------------------------------
--CampAuctionItemRender	拍卖
----------------------------------------------------------------------------
CampAuctionItemRender = CampAuctionItemRender or BaseClass(BaseCell)
CampAuctionItemRender.SelectIndex = -1

function CampAuctionItemRender:__init()
	-- self.item_cell = ItemCell.New(self:FindObj("ItemCell"))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self.lbl_item_name = self:FindVariable("LabelItemName")
	self.lbl_time_limit = self:FindVariable("LabelTimeLimit")
	self.lbl_upset_price = self:FindVariable("LabelUpsetPrice")
	self.lbl_fixed_price = self:FindVariable("LabelFixedPrice")
	self.lbl_curr_prices = self:FindVariable("LabelCurrPrice")
	self.is_auction = self:FindVariable("IsAuction")

	self:ListenEvent("OnClickItem", BindTool.Bind(self.OnClickItemHandler, self))
end

function CampAuctionItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.lbl_item_name = nil
	self.lbl_time_limit = nil
	self.lbl_upset_price = nil
	self.lbl_fixed_price = nil
	self.lbl_curr_prices = nil
	self.is_auction = nil
end

function CampAuctionItemRender:OnFlush()
	if not self.data or not next(self.data) then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local campsale_items_cfg = CampData.Instance:GetCampSaleItemsCfg()
	for k, v in pairs(campsale_items_cfg) do
		if v.sale_item and v.sale_item.item_id == self.data.item_id then
			self.item_cell:SetData(v.sale_item)
			if item_cfg then
				self.lbl_item_name:SetValue(ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
			end
			-- 起拍价
			self.lbl_upset_price:SetValue(v.base_gold)
			-- 一口价
			self.lbl_fixed_price:SetValue(v.must_sale_gold)
		end
	end

	-- 是否显示竞拍中
	self.is_auction:SetValue(PlayerData.Instance.role_vo.role_id == self.data.cur_uid and true or false)

	-- 限时
	local server_time = self.data.xiajia_timestamp - TimeCtrl.Instance:GetServerTime()
	self.lbl_time_limit:SetValue(server_time >= 60 and TimeUtil.FormatSecond2Str(server_time, 1) or Language.Camp.AuctionTimeNo)
	-- 当前价格
	self.lbl_curr_prices:SetValue(self.data.cur_gold)

	local is_select = CampAuctionItemRender.SelectIndex == self.index
	self.root_node.toggle.isOn = is_select
	if is_select then
		self:OnClick()
	end
end

function CampAuctionItemRender:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function CampAuctionItemRender:OnClickItemHandler()
	self.root_node.toggle.isOn = true
	CampAuctionItemRender.SelectIndex = self.index
	self:OnClick()
end

----------------------------------------------------------------------------
--CampAuctionItemLogItemRender	日志itemder
----------------------------------------------------------------------------
CampAuctionItemLogItemRender = CampAuctionItemLogItemRender or BaseClass(BaseCell)
function CampAuctionItemLogItemRender:__init()
	self.lbl_log_text = self:FindVariable("LogText")
end

function CampAuctionItemLogItemRender:__delete()
	
end

function CampAuctionItemLogItemRender:OnFlush()
	if not self.data or not next(self.data) then return end

	local str = ""
	local time = os.date('%Y-%m-%d %H:%M:%S', self.data.sold_timestamp)
	local item_str = ""
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg then
		item_str = ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])
	end

	if self.data.result_type == CAMP_SALE_RESULT_TYPE.CAMP_SALE_RESULT_TYPE_RECYCLE then		-- 被回收
		str = string.format(Language.Camp.AuctionItemLog[self.data.result_type], 
			time, item_str, self.data.recycle_gold)

	elseif self.data.result_type == CAMP_SALE_RESULT_TYPE.CAMP_SALE_RESULT_TYPE_SOLD then		-- 卖出
		str = string.format(Language.Camp.AuctionItemLog[self.data.result_type], 
			time, item_str, self.data.name, self.data.sold_gold, self.data.sold_gold)

	elseif self.data.result_type == CAMP_SALE_RESULT_TYPE.CAMP_SALE_RESULT_TYPE_BUY then		-- 被一口价购买
		str = string.format(Language.Camp.AuctionItemLog[self.data.result_type], 
			time, item_str, self.data.name, self.data.sold_gold, self.data.sold_gold)
	end
	self.lbl_log_text:SetValue(str)
end
