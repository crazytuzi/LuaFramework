DressShopView = DressShopView or BaseClass(BaseView)
MAX_PAGE_NUM = 4
function DressShopView:__init()
	self.ui_config = {"uis/views/serveractivity/dressshop","DressShopContent"}
	self:SetMaskBg()
	self.play_audio = true
	self.cell_list = {}
	self.toggle_list = {}
	self.page_toggle_list = {}
end

function DressShopView:__delete()

end

function DressShopView:LoadCallBack()
	self.cur_index = 0
	self.close_day = -1
	self.is_show_time = 0
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self.act_time = self:FindVariable("ActTime")
	self.list_view = self:FindObj("ListView")
	self.show_act_time = self:FindVariable("Show_Time")
	self.shop_info = {}
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.GetRefreshCell, self)
	self:InitScroller()
	for i = 1, MAX_PAGE_NUM do
		self.page_toggle_list[i] = self:FindObj("PageToggle"..i)
	end
end

function DressShopView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k, v in pairs(self.toggle_list) do
		v:DeleteMe()
	end
	self.toggle_list = {}
	for k,v in pairs(self.page_toggle_list) do
		v = nil
	end
	self.page_toggle_list = {}
	-- 清理变量和对象
	self.list_view = nil
	self.toggle = nil
	self.act_time = nil
	self.show_act_time = nil
end

function DressShopView:InitScroller()
	--顶部边框
	self.toggle = self:FindObj("ToggleList")
	local delegate = self.toggle.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		local cfg1, num1, type_cfg1 = DressShopData.Instance:GetCurShopCfg()
		return num1
	end

	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		local cfg, num, type_cfg = DressShopData.Instance:GetCurShopCfg()
		if type_cfg[data_index] ~= nil then
			local target_cell = self.toggle_list[cell]

			if nil == target_cell then
				self.toggle_list[cell] = DressShopTabCell.New(cell.gameObject)
				target_cell = self.toggle_list[cell]
				target_cell:SetIndex(data_index)
				target_cell:SetData(type_cfg[data_index])
				target_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self, data_index))
			end
			if self.close_day < 0 then
				self.close_day = type_cfg[data_index].close_day
				self.is_show_time = type_cfg[data_index].is_show_time
			end
			target_cell:ShowHightLight(self:GetCurIndex())
		end
	end
end   

function DressShopView:GetRefreshCell(cell, data_index, cell_index)
	data_index = data_index * MAX_PAGE_NUM
	local target_cell = self.cell_list[cell]
	local cfg, num, type_cfg = DressShopData.Instance:GetCurShopCfg()
	if nil == target_cell then
		self.cell_list[cell] =  DressShopCell.New(cell.gameObject)
		target_cell = self.cell_list[cell]
	end
	if cfg == nil or type_cfg == nil or type_cfg[self:GetCurIndex()] == nil then return end
	local cur_type = type_cfg[self:GetCurIndex()].type or 1
	for i = 0, MAX_PAGE_NUM - 1 do
		target_cell:SetData(cfg[cur_type][i + data_index],i)
	end
end

function DressShopView:GetNumberOfCells()
	local cfg, _num, type_cfg = DressShopData.Instance:GetCurShopCfg()
	local num = 1
	if cfg == nil or type_cfg == nil or type_cfg[self:GetCurIndex()] == nil then return end
	local cur_type = type_cfg[self:GetCurIndex()].type or 1
	if cfg[cur_type] then 
	 	num = math.ceil((#cfg[cur_type] + 1) / MAX_PAGE_NUM)
	end
	for i = 1, MAX_PAGE_NUM do
		self.page_toggle_list[i]:SetActive(i <= num)
	end
	local list_page_scroll = self.list_view.list_page_scroll
	list_page_scroll:SetPageCount(num)
	return num
end

function DressShopView:OpenCallBack()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	if self.toggle.scroller.isActiveAndEnabled then
		self.toggle.scroller:ReloadData(0)
	end
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end 
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_IMAGE_CHANGE_SHOP,RA_IMAGE_EXCHANGE_SHOP_OPERA_REQ.RA_IMAGE_EXCHANGE_SHOP_OPERA_REQ_INFO)
end

function DressShopView:CloseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function DressShopView:OnClickItemCallBack(data_index)
	if nil == data_index then
		return
	end
	self:SetCurIndex(data_index)
end

function DressShopView:SetCurIndex(index)
	local _n, _m,type_cfg = DressShopData.Instance:GetCurShopCfg()
	self.close_day = type_cfg[index].close_day
	self.is_show_time = type_cfg[index].is_show_time
	self.cur_index = index or 0
	if self.toggle.scroller.isActiveAndEnabled then
		self.toggle.scroller:RefreshAndReloadActiveCellViews(true)
	end
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end 
	self.page_toggle_list[1].toggle.isOn = true
end

function DressShopView:GetCurIndex()
	return self.cur_index 
end

function DressShopView:OnFlush(param_t)
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end 
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function DressShopView:FlushNextTime()
	local time = DressShopData.Instance:GetDifferTime(self.close_day)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	self.show_act_time:SetValue(self.is_show_time == 1)
	self.act_time:SetValue("<color='#ffffff'>" .. TimeUtil.FormatSecond2DHMS(time, 1) .. "</color>")	
end



---------------------------------------------------------------
--顶部格子

DressShopTabCell = DressShopTabCell or BaseClass(BaseCell)

function DressShopTabCell:__init()
	self.name = self:FindVariable("Name")
	self.show_hl = self:FindVariable("ShowHL")
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function DressShopTabCell:__delete()

end

function DressShopTabCell:OnFlush()
	if self.data then
		self.name:SetValue(self.data.type_name)
	end
end

function DressShopTabCell:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function DressShopTabCell:ShowHightLight(value)
	self.show_hl:SetValue(value == self.index)
end

---------------------------------------------------------------
--滚动条格子

DressShopCell = DressShopCell or BaseClass(BaseCell)

function DressShopCell:__init()
	self.data = {}
	self.name_list = {}
	self.power_list = {}
	self.str_list = {}
	self.item_list = {}
	self.need_item = {}
	self.exchange_count_list = {}
	self.item = {}
	for i = 0, MAX_PAGE_NUM - 1 do
		self:ListenEvent("ClickBuy"..i, BindTool.Bind(self.ClickGet, self, i))
		self.name_list[i] = self:FindVariable("Name_"..i)
		self.power_list[i] = self:FindVariable("Power_"..i)
		self.str_list[i] = self:FindVariable("NumStr_"..i)
		self.exchange_count_list[i] = self:FindVariable("Num_Time_"..i)
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("ItemCell_"..i))
		local item2 = ItemCell.New()
		item2:SetInstanceParent(self:FindObj("NeedItem_"..i))
		self.item_list[i] = item
		self.need_item[i] = item2
		self.item[i] = self:FindObj("item_"..i)
	end
end

function DressShopCell:__delete()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	for k, v in pairs(self.need_item) do
		v:DeleteMe()
	end
	self.need_item = {}
end

function DressShopCell:OnFlush()

end

function DressShopCell:ClickGet(index)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_IMAGE_CHANGE_SHOP,RA_IMAGE_EXCHANGE_SHOP_OPERA_REQ.RA_IMAGE_EXCHANGE_SHOP_OPERA_REQ_EXCHANGE,self.data[index].type,self.data[index].index)
end

function DressShopCell:SetData(data, i)
	self.data[i] = data 
	self.item[i]:SetActive(data ~= nil)
	if not self.data[i] then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data[i].reward_item.item_id)
	local cur_num = DressShopData.Instance:GetRedEquipIsYes(self.data[i].need_item_id_1)
	local need_num = self.data[i].num_1

	local cur_exchange_count = DressShopData.Instance:GetNumTimeInfo(self.data[i].type,self.data[i].index)
	local all_exchange_count = self.data[i].exchange_count
	local surplus_count = all_exchange_count - cur_exchange_count
	self.item_list[i]:SetData(self.data[i].reward_item)
	self.need_item[i]:SetData({item_id = self.data[i].need_item_id_1})
	self.name_list[i]:SetValue(item_cfg.name)
	self.str_list[i]:SetValue(cur_num < need_num and string.format(Language.DressShop.CostNumDes,cur_num,need_num)
		or string.format(Language.DressShop.CostNumDes2,cur_num,need_num))
	self.power_list[i]:SetValue(self.data[i].power)
	self.exchange_count_list[i]:SetValue( surplus_count > 0 and string.format(Language.DressShop.ExchangeCount,surplus_count,all_exchange_count)
		or string.format(Language.DressShop.ExchangeFull))
end