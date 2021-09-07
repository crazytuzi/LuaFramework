HeFuFullServerSnapView =  HeFuFullServerSnapView or BaseClass(BaseRender)

function HeFuFullServerSnapView:__init()
	self.contain_cell_list = {}
	self.reward_list = {}

	self.current_page = 0
end

function HeFuFullServerSnapView:__delete()
 
end

function HeFuFullServerSnapView:LoadCallBack()
    self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.rest_time = self:FindVariable("rest_time")
	self.rank_levle = self:FindVariable("rank_levle")

	self.page_num = self:FindVariable("page_num")

	self.list_view.list_view:Reload()
	self.list_view.list_view:JumpToIndex(0)
	self.list_view.list_page_scroll2:JumpToPageImmidate(0)
end

function HeFuFullServerSnapView:OpenCallBack()
	self.reward_list = HefuActivityData.Instance:GetPanicBuyItemListData(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SERVER_PANIC_BUY) or {}

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end

	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_SERVER_PANIC_BUY)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)

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
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
end

function HeFuFullServerSnapView:SetCurTyoe(cur_type)
	self.cur_type = cur_type
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
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local str = ""
	if time_tab.day > 0 then
		str = TimeUtil.FormatSecond2DHMS(rest_time, 1)
	else
		str = TimeUtil.FormatSecond(rest_time)
	end
	self.rest_time:SetValue(str)
end

local PAGE_COUNT = 3

function HeFuFullServerSnapView:GetNumberOfCells()
	return math.ceil(#HefuActivityData.Instance:GetPanicBuyNumList()/ 3) * 3
end

function HeFuFullServerSnapView:RefreshCell(cell_index, cell)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = ActHotSellPageItemRender.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetItemData(self.reward_list[cell_index])
	contain_cell.root_node:SetActive(self.reward_list[cell_index] ~= nil)
	contain_cell:Flush()
end

----------------------------ActHotSellPageItemRender---------------------------------
ActHotSellPageItemRender = ActHotSellPageItemRender or BaseClass(BaseCell)

function ActHotSellPageItemRender:__init()
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
	self.item_bg = self:FindVariable("item_bg")
	self.title_bg = self:FindVariable("TitleBg")
	self.basecell_bg = self:FindVariable("BaseCellBg")
	self.max_person = self:FindVariable("MaxPerSon")
	self.max_quanfu = self:FindVariable("MaxQuanFu")
	self.is_cellimage = self:FindVariable("IsSellImage")

	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	-- for i = 1, 3 do
	self.item_cell_obj_list[1] = self:FindObj("item_1")
	local item_cell = ItemCell.New()
	self.item_cell_list[1] = item_cell
	item_cell:SetInstanceParent(self.item_cell_obj_list[1])

	-- end
end

function ActHotSellPageItemRender:__delete()
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
	self.item_bg = nil
	self.title_bg = nil
	self.basecell_bg = nil
	self.max_person = nil
	self.max_quanfu = nil
	self.is_cellimage = nil
end

function ActHotSellPageItemRender:OnClickGet()
	if self.reward_data and self.reward_data.is_no_item ~= 1 then
		local str = string.format(Language.Activity.BuyGiftTip, self.reward_data.gold_price)
		TipsCtrl.Instance:ShowCommonAutoView("panel_snap_buy", str, self.reward_data.get_callback)
	end
end

function ActHotSellPageItemRender:SetItemData(data)
	self.reward_data = data
end

function ActHotSellPageItemRender:OnFlush()
	if not self.reward_data  then return end 
	local item_cfg = ItemData.Instance:GetItemConfig(self.reward_data.reward_item.item_id) or {}
	self.item_cell_list[1]:SetData(self.reward_data.reward_item)
	self.text1:SetValue(self.reward_data.server_limit)
	self.text:SetValue(self.reward_data.person_limit)
	self.rander_name:SetValue(item_cfg.name)
	self.cost_gold:SetValue(self.reward_data.gold_price or 0)
	self.can_get:SetValue(self.reward_data.is_no_item == 0)
		-- 这里根据index设置显示哪张图片
	local three_index = self.reward_data.seq % 3 + 1
	self.item_bg:SetAsset(ResPath.GetRawImage("itemcell_bg_" .. three_index))
	self.title_bg:SetAsset(ResPath.GetPersonalBuyTitleBg(three_index))
	local two_index = three_index > 1 and 2 or 1
	self.basecell_bg:SetAsset(ResPath.GetPersonalBuyItemBaseBg(two_index))
	self.max_person:SetValue(self.reward_data.maxperson)
	self.max_quanfu:SetValue(self.reward_data.maxquanfu)
	self.is_cellimage:SetValue(self.reward_data.is_no_image == 1)
end