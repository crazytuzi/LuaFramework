HeFuFullServerSnapView =  HeFuFullServerSnapView or BaseClass(BaseRender)

function HeFuFullServerSnapView:__init()
	self.contain_cell_list = {}
	self.reward_list = {}
	self.time_change_day = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.SendActivityInfo, self))

	self.current_page = 0

    self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.rest_time = self:FindVariable("rest_time")
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end

	local rest_time, next_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SERVER_PANIC_BUY)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)

	self.rank_levle = self:FindVariable("rank_levle")

	self.page_num = self:FindVariable("page_num")
end

function HeFuFullServerSnapView:__delete()
   if self.time_change_day then
		GlobalEventSystem:UnBind(self.time_change_day)
		self.time_change_day = nil
	end

	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
    
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
end

function HeFuFullServerSnapView:OpenCallBack()
	self.reward_list = HefuActivityData.Instance:GetPanicBuyItemListData(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SERVER_PANIC_BUY) or {}
	self.list_view.list_view:Reload()
	self.list_view.list_view:JumpToIndex(0)
	self.list_view.list_page_scroll2:JumpToPageImmidate(0)
end

function HeFuFullServerSnapView:CloseCallBack()
	if self.list_view then
		self.list_view.list_view:Reload()
		self.list_view.list_page_scroll2:JumpToPageImmidate(0)
	end
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function HeFuFullServerSnapView:SendActivityInfo()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SERVER_PANIC_BUY)
end

function HeFuFullServerSnapView:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function HeFuFullServerSnapView:OnFlush()
	self.reward_list = HefuActivityData.Instance:GetPanicBuyItemListData(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SERVER_PANIC_BUY) or {}
	if self.list_view then
		self.list_view.list_view:Reload()
	end
end

function HeFuFullServerSnapView:SetTime(rest_time)
	local left_day = math.floor(rest_time / 86400)
	if left_day > 0 then
		time_str = TimeUtil.FormatSecond(rest_time, 8)
	else
		time_str = TimeUtil.FormatSecond(rest_time)
	end
	self.rest_time:SetValue(time_str)
end

local PAGE_COUNT = 3

function HeFuFullServerSnapView:GetNumberOfCells()
	local count = math.ceil(#self.reward_list / PAGE_COUNT)
	if self.page_num then
		self.page_num:SetValue(count)
		self.list_view.list_page_scroll2:SetPageCount(count)
	end
	return math.ceil(#self.reward_list / 3) * 3
end

function HeFuFullServerSnapView:RefreshCell(cell_index, cell)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = HeFuFullServerSnapCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetItemData(self.reward_list[cell_index])
	contain_cell.root_node:SetActive(self.reward_list[cell_index] ~= nil)
	contain_cell:Flush()
end

----------------------------HeFuFullServerSnapCell---------------------------------
HeFuFullServerSnapCell = HeFuFullServerSnapCell or BaseClass(BaseCell)

function HeFuFullServerSnapCell:__init()
	self.reward_data = {}
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
	self.text = self:FindVariable("text")
	self.text1 = self:FindVariable("text1")

	self.btn_name = self:FindVariable("BtnName")
	self.is_active = self:FindVariable("is_active")
	self.can_get = self:FindVariable("can_get")
	self.is_get = self:FindVariable("is_get")
	self.cost_gold = self:FindVariable("cost_gold")
	self.rander_name = self:FindVariable("rander_name")

	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	-- for i = 1, 3 do
	self.item_cell_obj_list[1] = self:FindObj("item_1")
	local item_cell = ItemCell.New()
	self.item_cell_list[1] = item_cell
	item_cell:SetInstanceParent(self.item_cell_obj_list[1])
	-- end
end

function HeFuFullServerSnapCell:__delete()
	self.text = nil
	self.item_cell_obj_list = {}

	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
	self.text1 = nil
	self.btn_name = nil
	self.is_active = nil
	self.can_get = nil
	self.is_get = nil
	self.rander_name = nil
	self.cost_gold = nil
end

function HeFuFullServerSnapCell:OnClickGet()
		if self.reward_data.is_no_item == 1 then
		return
	end
	self.reward_data.get_callback()
end

function HeFuFullServerSnapCell:SetItemData(data)
	self.reward_data = data
end

function HeFuFullServerSnapCell:OnFlush()
	if not self.reward_data  then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.reward_data.reward_item.item_id) or {}
	self.item_cell_list[1]:SetData(self.reward_data.reward_item)
	self.text1:SetValue(self.reward_data.server_limit)
	self.text:SetValue(self.reward_data.person_limit)
	self.rander_name:SetValue(item_cfg.name)
	self.cost_gold:SetValue(self.reward_data.gold_price or 0)
	self.can_get:SetValue(self.reward_data.is_no_item == 0)
end