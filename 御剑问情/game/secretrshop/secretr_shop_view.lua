SecretrShopView = SecretrShopView or BaseClass(BaseView)

local PAGE_ROW = 1					--行
local PAGE_COLUMN = 3				--列

function SecretrShopView:__init()
	self.ui_config = {"uis/views/secretrshopview_prefab","SecretrShopView"}
	self.full_screen = false
	self.play_audio = true
	self.def_index = 0
	-- self:SetMaskBg()
end

function SecretrShopView:ReleaseCallBack()
	if self.exchange_cell_list ~= nil then
		for k, v in pairs(self.exchange_cell_list) do
			v:DeleteMe()
		end
	end

	self.left_time = nil
	self.exchange_cell_list = nil
	-- 清理变量和对象
	self.exchange_list = nil
	self.toggle_1 = nil
	self.page_num = nil
	self.description = nil
end

function SecretrShopView:CloseCallBack()
	self:StopLeftCountDown()
end

function SecretrShopView:BackOnClick()
	ViewManager.Instance:Close(ViewName.SecretrShopView)
end

function SecretrShopView:LoadCallBack()
	self.scroller_is_load = false
	self.target_page = -1
	self:ListenEvent("close_view", BindTool.Bind(self.BackOnClick, self))
	self.exchange_list = self:FindObj("ListView")
	self.toggle_1 = self:FindObj("Toggle1")
	self.page_num = self:FindVariable("PageNum")
	self.description = self:FindVariable("Description")
	self.left_time = self:FindVariable("LeftTime")
	self.exchange_listview_data = {}
	self.exchange_cell_list = {}
	self.exchange_listview_data = SecretrShopData.Instance:GetSortRewardCfg()

	local page = math.ceil(#self.exchange_listview_data/PAGE_COLUMN)
	self.page_num:SetValue(page)
	self.exchange_list.list_page_scroll:SetPageCount(page)
	self.toggle_1.toggle.isOn = true

	local exchange_list_delegate = self.exchange_list.list_simple_delegate
	exchange_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	exchange_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshDel, self)
	SecretrShopData.Instance:SecretrShopOpen()
end

function SecretrShopView:GetCellNumber()
	return math.ceil(#self.exchange_listview_data/PAGE_COLUMN)
end

function SecretrShopView:RefreshDel(cell, data_index)
	self.scroller_is_load = true
	-- if self.target_page > -1 then
	-- 	-- self:JumpPage()
	-- 	self.target_page = -1
	-- end
	local exchange_group_cell = self.exchange_cell_list[cell]
	if not exchange_group_cell then
		exchange_group_cell = SecretrShopGroupCell.New(cell.gameObject)
		self.exchange_cell_list[cell] = exchange_group_cell
	end

	for i = 1, PAGE_COLUMN do
		local index = data_index * PAGE_COLUMN + i
		local data = self.exchange_listview_data[index]
		if data then
			exchange_group_cell:SetActive(i, true)
			exchange_group_cell:SetIndex(i, index)
			exchange_group_cell:SetData(i, data)
		else
			exchange_group_cell:SetActive(i, false)
		end
	end
end

function SecretrShopView:StopLeftCountDown()
	if self.left_count_down then
		CountDown.Instance:RemoveCountDown(self.left_count_down)
		self.left_count_down = nil
	end
end

function SecretrShopView:StartLeftCountDown()
	self:StopLeftCountDown()

	--计算时间函数
	local function calc_times(times)
		local time_tbl = TimeUtil.Format2TableDHMS(times)
		local time_des = ""
		if time_tbl.day > 0 then
			--大于1天的只显示天数和时间
			time_des = string.format("%s%s%s%s", time_tbl.day, Language.Common.TimeList.d, time_tbl.hour, Language.Common.TimeList.h)
		else
			--小于一天的就显示三位时间
			time_des = TimeUtil.FormatSecond(times)
		end
		self.left_time:SetValue(time_des)
	end

	local function time_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self.left_time:SetValue("00:00:00")
			self:StopLeftCountDown()
		end

		--先计算出剩余时间秒数
		local times = total_time - math.floor(elapse_time)
		calc_times(times)
	end

	local left_act_times = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP)
	--不足1s按1s算（向上取整）
	left_act_times = math.ceil(left_act_times)
	if left_act_times > 0 then
		--活动进行中
		calc_times(left_act_times)
		self.left_count_down = CountDown.Instance:AddCountDown(left_act_times, 1, time_func)
	else
		--活动已结束
		self.left_time:SetValue("00:00:00")
	end
end

function SecretrShopView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP)
	self:Flush()

	--开始计算活动剩余时间
	self:StartLeftCountDown()
end

-- 刷新
function SecretrShopView:OnFlush(param_t, index)
	-- 设置数据
	self.exchange_listview_data = SecretrShopData.Instance:GetSortRewardCfg()
	self.exchange_list.scroller:RefreshActiveCellViews()
	-- self:JumpPage()
end

-- 自动跳转页面
function SecretrShopView:JumpPage()
	local now_page = SecretrShopData.Instance:GetNowPage()
	if self.scroller_is_load then
		self.exchange_list.list_page_scroll:JumpToPageImmidate(now_page)
	else
		self.target_page = now_page
	end
end
--------------------------------------------------------------------------------------------------

SecretrShopGroupCell = SecretrShopGroupCell or BaseClass(BaseRender)

function SecretrShopGroupCell:__init()
	self.exchange_list = {}
	for i=1, PAGE_COLUMN do
		local exchange_cell = SecretrShopItem.New(self:FindObj("GoldMemberItem" .. i))
		table.insert(self.exchange_list, exchange_cell)
	end
end

function SecretrShopGroupCell:__delete()
	for k, v in ipairs(self.exchange_list) do
		v:DeleteMe()
	end
	self.exchange_list = {}
end

function SecretrShopGroupCell:SetActive(i, enable)
	self.exchange_list[i]:SetActive(enable)
end

function SecretrShopGroupCell:SetIndex(i, index)
	self.exchange_list[i]:SetIndex(index)
end

function SecretrShopGroupCell:SetData(i, data)
	self.exchange_list[i]:SetData(data)
end

function SecretrShopGroupCell:StopCountDown()
	for k, v in ipairs(self.exchange_list) do
		v:ClearCountDown()
	end
end

---------------------------------------------------------------------------
SecretrShopItem = SecretrShopItem or BaseClass(BaseCell)

function SecretrShopItem:__init(instance, left_view)
	self.left_view = left_view
	self:IconInit()
end

function SecretrShopItem:__delete()
	self.item_cell:DeleteMe()
end

function SecretrShopItem:IconInit()
	self.show_btn = self:FindVariable("ShowBtn")
	self.icon_name = self:FindVariable("icon_name")
	self.integral = self:FindVariable("integral")
	self.exchange_integral = self:FindVariable("exchange_integral")
	self.btn_text = self:FindVariable("button_price")
	self.count_limit = self:FindVariable("CountLimit")
	self.now_price = self:FindVariable("now_price")
	self.can_buy_num = self:FindVariable("can_buy_num")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))
	self:ListenEvent("exchange",BindTool.Bind(self.ExchangeOnClick, self))
end

function SecretrShopItem:OnFlush()
	if not self.data or not next(self.data) then return end
	self.item_cell:SetData(self.data.reward_item)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	self.icon_name:SetValue(item_cfg.name)

	local num_buy = SecretrShopData.Instance:GetSecretBuyNum(self.data.index) or 0
	local max = self.data.count_limit - num_buy
	if max > 0 then
		self.show_btn:SetValue(false)
		self.btn_text:SetValue(Language.Activity.SecretrShopBtnText1..self.data.rmb_num / 10)
	else
		self.show_btn:SetValue(true)
		self.btn_text:SetValue(Language.Activity.SecretrShopBtnText2)
	end
	self.integral:SetValue(self.data.source_price)
	self.now_price:SetValue(self.data.rmb_num / 10)
	self.can_buy_num:SetValue(max)
end

function SecretrShopItem:ExchangeOnClick()
	if not self.data or not next(self.data) then return end
	RechargeCtrl.Instance:Recharge(self.data.rmb_num / 10)
end
