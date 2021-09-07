DisCountView = DisCountView or BaseClass(BaseView)

local PAGE_ROW = 1					--行
local PAGE_COLUMN = 3				--列
local MAX_COUNT = 9					--一个阶段最多显示个数

function DisCountView:__init()
	self.ui_config = {"uis/views/discount","DisCountView"}
	self.play_audio = true
end

function DisCountView:__delete()

end

function DisCountView:ReleaseCallBack()
	for k, v in pairs(self.tab_cell_list) do
		v:DeleteMe()
	end
	self.tab_cell_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	-- 清理变量和对象
	self.list_view = nil
	self.toggle_1 = nil
	self.toggle_list = nil
	self.left_tab_list = nil
	self.page_num = nil
	self.left_times = nil
end

function DisCountView:LoadCallBack()
	-- 查找组件
	self.toggle_1 = self:FindObj("Toggle1")
	self.toggle_list = {}

	-- 查找变量
	self.page_num = self:FindVariable("PageNum")
	self.left_times = self:FindVariable("LeftTimes")

	-- 物品列表
	self.list_data = {}
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local scroller_delegate_1 = self.list_view.list_simple_delegate
	scroller_delegate_1.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate_1.CellRefreshDel = BindTool.Bind(self.RefreshDel, self)

	-- 左边tab列表
	self.select_tab_index = 1					--标签默认选择index
	self.select_tab_phase = 0					--选择的阶段
	self.tab_list_data = {}
	self.tab_cell_list = {}
	self.left_tab_list = self:FindObj("LeftTabList")
	local scroller_delegate_2 = self.left_tab_list.list_simple_delegate
	self.list_view_height = self.left_tab_list.rect.rect.height
	self.tab_cell_height = scroller_delegate_2:GetCellViewSize(self.left_tab_list.scroller, 0)			--单个cell的大小（根据排列顺序对应高度或宽度）
	self.tab_list_spacing = self.left_tab_list.scroller.spacing											--间距
	scroller_delegate_2.NumberOfCellsDel = BindTool.Bind(self.GetTabNumber, self)
	scroller_delegate_2.CellRefreshDel = BindTool.Bind(self.RefreshTabDel, self)

	-- 监听按钮点击事件
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function DisCountView:OpenCallBack()
	DisCountData.Instance:SetRefreshList()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if cur_day > -1 then
		UnityEngine.PlayerPrefs.SetInt("diacount_remind_day", cur_day)
	end
	MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.DisCountRed, {false})
	DisCountData.Instance:SetHaveNewDiscount(false)
end

function DisCountView:CloseCallBack()
	DisCountData.Instance:ClearDiscountList()
	GlobalTimerQuest:CancelQuest(self.timer_quest)
	self:StopCountDown()
	self.model_show = nil
end

function DisCountView:CloseWindow()
	self:Close()
end

function DisCountView:StopCountDown()
	if self.left_time_count_down then
		CountDown.Instance:RemoveCountDown(self.left_time_count_down)
		self.left_time_count_down = nil
	end
end

function DisCountView:StartCountDown()
	self:StopCountDown()
	local info = DisCountData.Instance:GetDiscountInfoByType(self.select_tab_phase)
	if nil == info then
		return
	end

	local close_timestamp = info.close_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_times = math.ceil(close_timestamp - server_time)
	local time_des = "00:00:00"
	if left_times > 0 then
		time_des = TimeUtil.FormatSecond(left_times)
		local function time_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:StopCountDown()
				return
			end
			left_times = math.ceil(total_time - elapse_time)
			time_des = TimeUtil.FormatSecond(left_times)
			self.left_times:SetValue(time_des)
		end
		self.left_time_count_down = CountDown.Instance:AddCountDown(left_times, 1, time_func)
	end
	self.left_times:SetValue(time_des)
end

function DisCountView:GetTabNumber()
	return #self.tab_list_data
end

function DisCountView:RefreshTabDel(cell, data_index)
	data_index = data_index + 1
	local tab_cell = self.tab_cell_list[cell]
	if not tab_cell then
		tab_cell = TabItemCell.New(cell.gameObject)
		tab_cell:SetToggleGroup(self.left_tab_list.toggle_group)
		tab_cell:SetClickCallBack(BindTool.Bind(self.TabClick, self))
		self.tab_cell_list[cell] = tab_cell
	end

	tab_cell:SetIndex(data_index)

	if self.select_tab_index == data_index then
		tab_cell:SetToggleIsOn(true)
	else
		tab_cell:SetToggleIsOn(false)
	end

	tab_cell:SetData(self.tab_list_data[data_index])
end

function DisCountView:TabClick(cell)
	if nil == cell then
		return
	end

	local data = cell:GetData()
	if nil == data then
		return
	end

	local index = cell:GetIndex()
	if index == self.select_tab_index then
		return
	end

	self.select_tab_phase = data.phase
	self.select_tab_index = index

	--处理相关数据
	self:FlushRight(true)
end

function DisCountView:GetCellNumber()
	return math.ceil(#self.list_data / (PAGE_ROW * PAGE_COLUMN))
end

function DisCountView:RefreshDel(cell, data_index)
	local discount_group_cell = self.cell_list[cell]
	if not discount_group_cell then
		discount_group_cell = DisCountGroupCell.New(cell.gameObject)
		self.cell_list[cell] = discount_group_cell
	end

	local grid_count = PAGE_COLUMN * PAGE_ROW
	for i = 1, grid_count do
		local index = data_index * grid_count + i
		discount_group_cell:SetIndex(i, index)
		discount_group_cell:SetData(i, self.list_data[index])
	end
end

function DisCountView:FlushLeft(is_init)
	if is_init then
		self.tab_list_data = DisCountData.Instance:GetNewPhaseList()
		local max_hight = (self.tab_cell_height + self.tab_list_spacing) * (#self.tab_list_data) - self.tab_list_spacing
		local not_see_height = math.max(max_hight - self.list_view_height, 0)
		local bili = 0
		if not_see_height > 0 then
			bili = math.min(((self.tab_cell_height + self.tab_list_spacing) * (self.select_tab_index - 1)) / not_see_height, 1)
		end
		self.left_tab_list.scroller:ReloadData(bili)
	else
		self.tab_list_data = DisCountData.Instance:GetRefreshList()
		self.left_tab_list.scroller:RefreshActiveCellViews()
	end
end

function DisCountView:FlushRight(is_init)
	self.list_data = DisCountData.Instance:GetItemListByPhase(self.select_tab_phase)
	if nil == self.list_data then
		return
	end

	if is_init then
		local page = math.ceil(#self.list_data / (PAGE_COLUMN * PAGE_ROW))
		self.list_view.list_page_scroll:JumpToPageImmidate(0)
		self.page_num:SetValue(page)
		self.list_view.list_page_scroll:SetPageCount(page)
		self.list_view.scroller:ReloadData(0)
	else
		self.list_view.scroller:RefreshActiveCellViews()
	end

	self:StartCountDown()
end

function DisCountView:InitView()
	self:FlushLeft(true)
	self:FlushRight(true)
end

function DisCountView:FlushView()
	self:FlushLeft()
	self:FlushRight()
end

function DisCountView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "index" then
			local data = DisCountData.Instance:GetNewPhaseList()
			if data == nil then
				return
			end

			local index = v[1] ~= "all" and v[1]
			if not index then
				local max_index = #data
				self.select_tab_phase = data[1].phase
				self.select_tab_index = 1
			else
				local phase = data[index] and data[index].phase
				self.select_tab_phase = phase or 0
				self.select_tab_index = index
			end
			self:InitView()
		else
			self:FlushView()
		end
	end
end

TabItemCell = TabItemCell or BaseClass(BaseCell)
function TabItemCell:__init()
	self.text = self:FindVariable("Text")
	self.show_tab = self:FindVariable("ShowTab")

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function TabItemCell:__delete()

end

function TabItemCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function TabItemCell:SetToggleIsOn(state)
	self.root_node.toggle.isOn = state
end

function TabItemCell:OnFlush()
	if self.data == nil then
		return
	end

	self.text:SetValue(self.data.phase_desc)

	--判断该阶段状态
	local server_time = TimeCtrl.Instance:GetServerTime()
	local close_timestamp = self.data.close_timestamp
	local des = ""
	self.is_time_out = false
	self.is_sell_out = false
	if close_timestamp - server_time <= 0 then
		des = Language.Common.HadOverdue
		self.is_time_out = true
	else
		local phase_item_list = self.data.phase_item_list
		self.is_sell_out = true
		for _, v in ipairs(phase_item_list) do
			if v.buy_count < v.buy_limit_count then
				self.is_sell_out = false
				break
			end
		end
		if self.is_sell_out then
			des = Language.Common.SellOut
		end
	end
	self.show_tab:SetValue(des ~= "")
end

DisCountGroupCell = DisCountGroupCell or BaseClass(BaseRender)

function DisCountGroupCell:__init()
	self.cell_list = {}
	for i = 1, PAGE_ROW * PAGE_COLUMN do
		local cell = DisCountItemCell.New(self:FindObj("Cell" .. i))
		table.insert(self.cell_list, cell)
	end
end

function DisCountGroupCell:__delete()
	for _, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
end

function DisCountGroupCell:SetActive(i, enable)
	self.cell_list[i]:SetActive(enable)
end

function DisCountGroupCell:SetIndex(i, index)
	self.cell_list[i]:SetIndex(index)
end

function DisCountGroupCell:SetData(i, data)
	self.cell_list[i]:SetData(data)
end

-------------------------DisCountItemCell-----------------------------------------
DisCountItemCell = DisCountItemCell or BaseClass(BaseCell)

function DisCountItemCell:__init()
	self.name = self:FindVariable("Name")
	self.old_price = self:FindVariable("OldPrice")
	self.new_price = self:FindVariable("NewPrice")
	self.left_time_str = self:FindVariable("LeftTimeStr")
	self.limit_num = self:FindVariable("LimitNum")
	self.is_sell_out = self:FindVariable("IsSellOut")

	self:ListenEvent("ClickBuy", BindTool.Bind(self.ClickBuy, self))

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:SetData(nil)
end

function DisCountItemCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function DisCountItemCell:OnFlush()
	if self.data == nil then
		self:SetActive(false)
		return
	end
	self:SetActive(true)
	local reward_data = self.data.reward_item
	self.item_cell:SetData(reward_data)
	local item_cfg = ItemData.Instance:GetItemConfig(reward_data.item_id)
	local item_color = item_cfg.color or GameEnum.ITEM_COLOR_WHITE
	local item_name = item_cfg.name or ""
	self.name:SetValue(item_name)

	self.old_price:SetValue(self.data.show_price)
	self.new_price:SetValue(self.data.price)

	local limit_num = self.data.buy_limit_count - self.data.buy_count
	local limit_str = tostring(limit_num)
	if limit_num <= 0 then
		limit_str = ToColorStr(limit_num, TEXT_COLOR.RED)
	end
	self.limit_num:SetValue(limit_str)

	self.is_sell_out:SetValue(limit_num <= 0)
end

function DisCountItemCell:ClickBuy()
	if self.data == nil then
		return
	end
	local reward_data = self.data.reward_item
	local item_cfg = ItemData.Instance:GetItemConfig(reward_data.item_id)
	local item_color = GameEnum.ITEM_COLOR_WHITE
	local item_name = ""
	if item_cfg then
		item_color = item_cfg.color
		item_name = item_cfg.name
	end
	local des = string.format(Language.Common.UsedGoldToBuySomething1, ToColorStr(self.data.price, TEXT_COLOR.GOLD), ToColorStr(item_name, ITEM_COLOR[item_color]))
	local function ok_callback()
		DisCountCtrl.Instance:SendDiscountBuyReqBuy(self.data.seq)
	end
	TipsCtrl.Instance:ShowCommonAutoView("dis_count", des, ok_callback)
end