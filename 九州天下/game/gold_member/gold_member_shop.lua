GoldMemberShop = GoldMemberShop or BaseClass(BaseView)

local PAGE_ROW = 1					--行
local PAGE_COLUMN = 3				--列

function GoldMemberShop:__init()
	self.ui_config = {"uis/views/goldmember","GoldMemberShopView"}
	self.full_screen = false
	self.play_audio = true
	self.def_index = 0
end

function GoldMemberShop:ReleaseCallBack()
	if self.exchange_cell_list ~= nil then
		for k, v in pairs(self.exchange_cell_list) do
			v:DeleteMe()
		end
	end
	self.exchange_cell_list = nil

	-- 清理变量和对象
	self.diamond = nil
	self.exchange_list = nil
	self.toggle_1 = nil
	self.page_num = nil
	self.description = nil
end

--关闭黄金会员商店
function GoldMemberShop:BackOnClick()
	ViewManager.Instance:Close(ViewName.GoldMemberShop)
end

function GoldMemberShop:OpenVipOnClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function GoldMemberShop:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.BackOnClick, self))
	self:ListenEvent("open_vip_btn", BindTool.Bind(self.OpenVipOnClick, self))
	self.diamond = self:FindVariable("diamond")
	self.exchange_list = self:FindObj("ListView")
	self.toggle_1 = self:FindObj("Toggle1")
	self.page_num = self:FindVariable("PageNum")
	self.description = self:FindVariable("Description")

	self.exchange_listview_data = {}
	self.exchange_cell_list = {}
	self.exchange_listview_data = GoldMemberData.Instance:GetShopInfo()
	local page = math.ceil(#self.exchange_listview_data/PAGE_COLUMN)
	self.page_num:SetValue(page)
	local convert_rate = GoldMemberData.Instance:GetGoldCfg()[1].convert_rate
	local active_convert_gold = GoldMemberData.Instance:GetGoldCfg()[1].active_convert_gold
	self.description:SetValue(string.format(Language.GoldMember.Member_shop_Description, convert_rate, active_convert_gold))
	self.exchange_list.list_page_scroll:SetPageCount(page)
	self.toggle_1.toggle.isOn = true

	local exchange_list_delegate = self.exchange_list.list_simple_delegate
	exchange_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	exchange_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshDel, self)

	self:Flush()
end

function GoldMemberShop:GetCellNumber()
	return math.ceil(#self.exchange_listview_data/PAGE_COLUMN)
end

function GoldMemberShop:RefreshDel(cell, data_index)
	local exchange_group_cell = self.exchange_cell_list[cell]
	if not exchange_group_cell then
		exchange_group_cell = GoldMemberGroupCell.New(cell.gameObject)
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

function GoldMemberShop:OpenCallBack()
	GoldMemberData.Instance:SetIsShowShopRepdt()
	RemindManager.Instance:Fire(RemindName.GoldMember)
end

-- 刷新
function GoldMemberShop:OnFlush(param_t, index)
	-- 设置数据
	self.exchange_listview_data = GoldMemberData.Instance:GetShopInfo()
	self.exchange_list.scroller:RefreshActiveCellViews()
	self.diamond:SetValue(tostring(GoldMemberData.Instance:GetDayScore()))
end


--------------------------------------------------------------------------------------------------

GoldMemberGroupCell = GoldMemberGroupCell or BaseClass(BaseRender)

function GoldMemberGroupCell:__init()
	self.exchange_list = {}
	for i=1, PAGE_COLUMN do
		local exchange_cell = GoldMemberItem.New(self:FindObj("GoldMemberItem" .. i))
		table.insert(self.exchange_list, exchange_cell)
	end
end

function GoldMemberGroupCell:__delete()
	for k, v in ipairs(self.exchange_list) do
		v:DeleteMe()
	end
	self.exchange_list = {}
end

function GoldMemberGroupCell:SetActive(i, enable)
	self.exchange_list[i]:SetActive(enable)
end

function GoldMemberGroupCell:SetIndex(i, index)
	self.exchange_list[i]:SetIndex(index)
end

function GoldMemberGroupCell:SetData(i, data)
	self.exchange_list[i]:SetData(data)
end

function GoldMemberGroupCell:StopCountDown()
	for k, v in ipairs(self.exchange_list) do
		v:ClearCountDown()
	end
end


---------------------------------------------------------------------------
GoldMemberItem = GoldMemberItem or BaseClass(BaseCell)

function GoldMemberItem:__init(instance, left_view)
	self.left_view = left_view
	self:IconInit()
end

function GoldMemberItem:__delete()
	self.item_cell:DeleteMe()
end

function GoldMemberItem:IconInit()
	self.icon_name = self:FindVariable("icon_name")
	self.integral = self:FindVariable("integral")
	self.show_btn = self:FindVariable("ShowBtn")
	self.exchange_integral = self:FindVariable("exchange_integral")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))

	self.bottom_text = self:FindObj("BottomText")
	self.image = self:FindObj("Image")
	self.tips_text = self:FindObj("TipsText")
	self:ListenEvent("exchange",BindTool.Bind(self.ExchangeOnClick, self))
end

function GoldMemberItem:OnFlush()
	if not self.data or not next(self.data) then return end
	if GoldMemberData.Instance:CheckIFOpenSeal(self.index - 1) == false then
	--	self.icon_name:SetValue(Language.GoldMember.Member_shop_open)
		self.show_btn:SetValue(true)
		self.bottom_text:SetActive(false)
		self.image:SetActive(false)
		self.tips_text:SetActive(true)
	else
	--	self.icon_name:SetValue(Language.GoldMember.Member_shop_fen)
		self.show_btn:SetValue(false)
		self.bottom_text:SetActive(true)
		self.image:SetActive(true)
		self.tips_text:SetActive(false)
	end

	local count = 0
	if self.data.limit_times == 0 then
		self.bottom_text:SetActive(false)
	elseif GoldMemberData.Instance:GetShopIndexCount(self.index) ~= nil then
		if self.data.limit_times - GoldMemberData.Instance:GetShopIndexCount(self.index) > 0 then
			count = self.data.limit_times - GoldMemberData.Instance:GetShopIndexCount(self.index)
		else
			count = 0
		end
		self.exchange_integral:SetValue(count)
		if count == 0 then
			self.show_btn:SetValue(true)
		end
	end
	local own_num = GoldMemberData.Instance:GetDayScore()
	local color = own_num >= self.data.consume_val and COLOR.GREEN or COLOR.RED
	self.exchange_integral:SetValue(count)

	local gift_reward_list = ItemData.Instance:GetGiftItemListByProf(self.data.reward_item.item_id) or {}
	if gift_reward_list[1] then
		self.item_cell:SetGiftItemId(self.data.reward_item.item_id)
		self.item_cell:SetData(gift_reward_list[1])
	else
		self.item_cell:SetData(self.data.reward_item)
	end

	--self.item_cell:SetData(self.data.reward_item)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	self.icon_name:SetValue(item_cfg.name)
	self.integral:SetValue(ToColorStr(self.data.consume_val, color))

end

function GoldMemberItem:ExchangeOnClick()
	if not self.data or not next(self.data) then return end

	GoldMemberCtrl.Instance:SendGoldVipOperaReq(GOLD_VIP_OPERA_TYPE.OPERA_TYPE_CONVERT_SHOP, self.data.seq)
end
