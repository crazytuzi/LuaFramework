MidAutumnExchangeView = MidAutumnExchangeView or BaseClass(BaseView)
local MAX_PAGE_NUM = 4
function MidAutumnExchangeView:__init()
	self.ui_config = {"uis/views/midautumn","MidAutumnExchange"}
	self:SetMaskBg()
	self.play_audio = true
	self.cell_list = {}
	self.toggle_list = {}
	self.page_toggle_list = {}
	self.list_data = {}
	self.type_num = 0
	self.type_data = {}
end

function MidAutumnExchangeView:__delete()

end

function MidAutumnExchangeView:LoadCallBack()
	self.cur_type = 0
	self.close_day = -1
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))

	self.act_time = self:FindVariable("ActTime")
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.GetRefreshCell, self)

	self:InitScroller()

	for i = 1, MAX_PAGE_NUM do
		self.page_toggle_list[i] = self:FindObj("PageToggle"..i)
	end
end

function MidAutumnExchangeView:ReleaseCallBack()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end

	if self.toggle_list then
		for k, v in pairs(self.toggle_list) do
			v:DeleteMe()
		end
		self.toggle_list = {}
	end

	for k,v in pairs(self.page_toggle_list) do
		v = nil
	end
	self.page_toggle_list = {}

	self.list_data = {}
	self.type_num = nil
	self.type_data = {}
	-- 清理变量和对象
	self.list_view = nil
	self.toggle = nil
	self.act_time = nil
	self.cur_type = nil
	self.close_day = nil
end

--Tab格子设置
function MidAutumnExchangeView:InitScroller()
	self.list_data,self.type_num,self.type_data = MidAutumnExchangeData.Instance:GetCurShopCfg()

	self.toggle = self:FindObj("ToggleList")
	local delegate = self.toggle.list_simple_delegate
	delegate.NumberOfCellsDel = function()
		return self.type_num
	end

	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		if self.type_data[data_index] ~= nil then
			local target_cell = self.toggle_list[cell]

			if nil == target_cell then
				self.toggle_list[cell] = MidExchangeTabCell.New(cell.gameObject)
				target_cell = self.toggle_list[cell]
				target_cell:SetIndex(data_index)
				target_cell:SetData(self.type_data[data_index])
				target_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self, data_index))
			end
			if self.close_day < 0 then
				self.close_day = self.type_data[data_index].close_day
			end
			target_cell:ShowHightLight(self:GetCurType())
		end
	end
end   

--普通物品格子设置
function MidAutumnExchangeView:GetRefreshCell(cell, data_index, cell_index)
	data_index = data_index * MAX_PAGE_NUM - 1
	local target_cell = self.cell_list[cell]
	if nil == target_cell then
		target_cell =  MidExchangeGroupCell.New(cell.gameObject)
		self.cell_list[cell] = target_cell
	end

	local cur_type = self:GetCurType() + 1

	for i = 1, MAX_PAGE_NUM do
		local data = self.list_data[cur_type][i + data_index]
		target_cell:SetData(i,data)
		target_cell:SetActive(i, data ~= nil)
	end
	
end

function MidAutumnExchangeView:GetNumberOfCells()
	local cur_type = self:GetCurType() + 1
	local num = 0
	if self.list_data == nil or self.type_data == nil or self.list_data[cur_type] == nil then return 0 end
	if self.list_data[cur_type] then 
	 	num = math.ceil((#self.list_data[cur_type] + 1) / MAX_PAGE_NUM)
	end
	for i = 1, MAX_PAGE_NUM do
		self.page_toggle_list[i]:SetActive(i <= num)
	end
	local list_page_scroll = self.list_view.list_page_scroll
	list_page_scroll:SetPageCount(num)
	return num
end

function MidAutumnExchangeView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN_ITEM_EXCHANGE,RA_IMAGE_EXCHANGE_SHOP_OPERA_REQ.RA_IMAGE_EXCHANGE_SHOP_OPERA_REQ_INFO)
	local rest_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN_ITEM_EXCHANGE)
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)

	MidAutumnExchangeData.Instance:SetRemind(false)
end

function MidAutumnExchangeView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function MidAutumnExchangeView:OnClickItemCallBack(data_index)
	if nil == data_index then
		return
	end
	self:SetCurType(data_index)
end

function MidAutumnExchangeView:SetCurType(index)
	local _n, _m,type_cfg = MidAutumnExchangeData.Instance:GetCurShopCfg()
	self.close_day = type_cfg[index].close_day
	self.cur_type  = index or 0
	self.page_toggle_list[1].toggle.isOn = true
end

function MidAutumnExchangeView:GetCurType()
	return self.cur_type 
end

function MidAutumnExchangeView:OnFlush(param_t)
	self.list_data,self.type_num,self.type_data = MidAutumnExchangeData.Instance:GetCurShopCfg()
	if self.toggle.scroller.isActiveAndEnabled then
		self.toggle.scroller:RefreshAndReloadActiveCellViews(true)
	end

	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end 
end

function MidAutumnExchangeView:SetTime(remaining_second)
 	local time_tab = TimeUtil.Format2TableDHMS(remaining_second)
  	local str = ""
 	if time_tab.day > 0 then
   		remaining_second = remaining_second - 24 * 60 * 60 * time_tab.day
   	end
	str = TimeUtil.FormatSecond(remaining_second)
	if self.act_time then
	   self.act_time:SetValue(str)
	end
end

---------------------------------------------------------------
--顶部格子

MidExchangeTabCell = MidExchangeTabCell or BaseClass(BaseCell)

function MidExchangeTabCell:__init()
	self.name = self:FindVariable("Name")
	self.show_hl = self:FindVariable("ShowHL")
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function MidExchangeTabCell:__delete()

end

function MidExchangeTabCell:OnFlush()
	local str = ""
	if self.data and next(self.data) ~= nil then
		str = self.data.type_name
	end

	self.name:SetValue(str)
end

function MidExchangeTabCell:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function MidExchangeTabCell:ShowHightLight(value)
	if self.show_hl ~= nil and value ~= nil then
		self.show_hl:SetValue(value == self.index)
	end
end

------------------MidExchangeGroupCell----------------------
-----格子组
MidExchangeGroupCell = MidExchangeGroupCell or BaseClass(BaseRender)
function MidExchangeGroupCell:__init()
	self.item_list = {}
	for i = 1, MAX_PAGE_NUM do
		local item_cell = MidExchangeCell.New(self:FindObj("Item" .. i))
		table.insert(self.item_list, item_cell)
	end
end

function MidExchangeGroupCell:__delete()
	if self.item_list then
		for k, v in ipairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}
end

function MidExchangeGroupCell:SetActive(i, state)
	if self.item_list[i] then
		self.item_list[i]:SetActive(state)
	end
end

function MidExchangeGroupCell:SetData(i, data)
	if data and self.item_list[i] then
		self.item_list[i]:SetData(data)
	end
end

---------------------------------------------------------------
--滚动条格子
MidExchangeCell = MidExchangeCell or BaseClass(BaseCell)

function MidExchangeCell:__init()
		self:ListenEvent("ClickBuy", BindTool.Bind(self.ClickGet, self))

		self.name = self:FindVariable("Name")
		self.power = self:FindVariable("Power")
		self.str = self:FindVariable("NumStr")
		self.exchange_count = self:FindVariable("Num_Time")
		self.red = self:FindVariable("Red")
		self.not_exchange = self:FindVariable("Not_Exchange")
		self.is_show_power = self:FindVariable("Is_Show_Power")

		self.item_reward = ItemCell.New()
		self.item_reward:SetInstanceParent(self:FindObj("ItemCell"))
		self.need_item = ItemCell.New()
		self.need_item:SetInstanceParent(self:FindObj("NeedItem"))
end

function MidExchangeCell:__delete()
	if self.need_item then
		self.need_item:DeleteMe()
	end
	if self.item_reward then
		self.item_reward:DeleteMe()
	end
end

function MidExchangeCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	if not item_cfg then
		return
	end

	local cur_num = ItemData.Instance:GetItemNumInBagById(self.data.need_item_id_1)
	local need_num = self.data.num_1

	--大区限购数量与个人限购数
	local cur_exchange_count = MidAutumnExchangeData.Instance:GetNumTimeInfo(self.data.type,self.data.index, 0)
	local all_exchange_count = self.data.exchange_count
	local curnum_server_exchange = MidAutumnExchangeData.Instance:GetNumTimeInfo(self.data.type,self.data.index, 1)
	local allnum_server_exchange = self.data.server_exchange_count
	local surplus_count = all_exchange_count - cur_exchange_count
	local can_exchange_num = allnum_server_exchange - curnum_server_exchange

	self.item_reward:SetData(self.data.reward_item)
	self.need_item:SetData({item_id = self.data.need_item_id_1})
	self.red:SetValue(can_exchange_num > 0 and surplus_count > 0 and cur_num >= need_num)
	self.not_exchange:SetValue(surplus_count <= 0 or can_exchange_num <=0) 
	self.name:SetValue(item_cfg.name)
	self.power:SetValue(self.data.power)
	self.is_show_power:SetValue(self.data.is_show_zhanli == 1)

	self.str:SetValue(cur_num < need_num and string.format(Language.DressShop.CostNumDes,cur_num,need_num)
		or string.format(Language.DressShop.CostNumDes2,cur_num,need_num))
	self.exchange_count:SetValue(string.format(Language.DressShop.ExchangeCount,surplus_count,all_exchange_count))
end

function MidExchangeCell:ClickGet()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN_ITEM_EXCHANGE,RA_IMAGE_EXCHANGE_SHOP_OPERA_REQ.RA_IMAGE_EXCHANGE_SHOP_OPERA_REQ_EXCHANGE,self.data.type,self.data.index)
end