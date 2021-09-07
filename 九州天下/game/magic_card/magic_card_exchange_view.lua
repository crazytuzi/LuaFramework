--------------------------------------------------------------------------
-- MaGicCardExChangeView 魔卡抽奖面板
--------------------------------------------------------------------------
MaGicCardExChangeView = MaGicCardExChangeView or BaseClass(BaseRender)

local PAGE_NUM = 2		-- 页数
local ROW = 2
local COL = 6


function MaGicCardExChangeView:__init()
	self:InitView()
end

function MaGicCardExChangeView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function MaGicCardExChangeView:InitView()
	self.BlueMg = self:FindVariable("BlueMg")
	self.PurpleMg = self:FindVariable("PurpleMg")
	self.OrangeMg = self:FindVariable("OrangeMg")
	self.RedMg = self:FindVariable("RedMg")

	self.RightBt = self:FindObj("Right_Bt")
	self.LeftBt = self:FindObj("Left_Bt")

	self:ListenEvent("LeftClick", BindTool.Bind(self.LeftBtClick, self))
	self:ListenEvent("RightClick", BindTool.Bind(self.RightBtClick, self))

	self.page = 0

	-- self:FlushData()
	self:InitScroller()

	-- self.fun = BindTool.Bind(self.SetBtnActive,self)
	-- self.scroller.list_page_scroll.JumpToPageEvent = self.scroller.list_page_scroll.JumpToPageEvent + self.fun
end

function MaGicCardExChangeView:FlushData()
	self.bluemg_num = MagicCardData.Instance:GetMagicNumByColor(0)
	self.purplemg_num = MagicCardData.Instance:GetMagicNumByColor(1)
	self.orangemg_num = MagicCardData.Instance:GetMagicNumByColor(2)
	self.redmg_num = MagicCardData.Instance:GetMagicNumByColor(3)

	self.BlueMg:SetValue(self.bluemg_num)
	self.PurpleMg:SetValue(self.purplemg_num)
	self.OrangeMg:SetValue(self.orangemg_num)
	self.RedMg:SetValue(self.redmg_num)
end

function MaGicCardExChangeView:FlushInfoView()
	self:FlushData()
end

function MaGicCardExChangeView:InitScroller()
	self.scroller = self:FindObj("Scroller")

	self.cell_list = {}
	self.card_info = {}
	self.card_info = MagicCardData.Instance:GetCardExchangeInfo()

	self.list_view_delegate = self.scroller.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfLeftCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function MaGicCardExChangeView:GetNumberOfLeftCells()
	return 10
end

function MaGicCardExChangeView:RefreshView(cell, data_index, cell_index)
	self.scroller.scroller.scrollerScrollingChanged = function ()
		self:SetBtnActive()
	end
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = ExchangeCellGroup.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	for i = 1, ROW do
		local index = data_index * 2 + i
		local data = {}
		data = self.card_info[index][1]
		if data then
			group_cell:SetIndex(i, index)
			group_cell:SetParent(i, self)
			group_cell:SetData(i, data)
		end
	end
end

function MaGicCardExChangeView:SetBtnActive()
	self.page = self.scroller.list_page_scroll:GetNowPage()
	if self.page == 0 then
		self.LeftBt:SetActive(false)
		self.RightBt:SetActive(true)
	else
		self.LeftBt:SetActive(true)
		self.RightBt:SetActive(false)
	end
end

function MaGicCardExChangeView:LeftBtClick()
	if self.page <= 0 then
		return
	end
	self.page = self.page - 1

	self:BagJumpPage(self.page)
	self:SetBtnActive()
end


function MaGicCardExChangeView:RightBtClick()
	if self.page > 1 then
		return
	end
	self.page = self.page + 1

	self:BagJumpPage(self.page)
	self:SetBtnActive()
end

function MaGicCardExChangeView:BagJumpPage(page)
	self.scroller.list_page_scroll:JumpToPage(page)
end

-- 兑换格子
ExchangeCellGroup = ExchangeCellGroup or BaseClass(BaseRender)

function ExchangeCellGroup:__init()
	self.item_cell = {}
	for i = 1, 2 do
		local card_item = ExchangeItemCell.New(self:FindObj("Card" .. i))
		table.insert(self.item_cell, card_item)
	end
end

function ExchangeCellGroup:__delete()
	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
end

function ExchangeCellGroup:SetIndex(i,index)
	self.item_cell[i]:SetIndex(index)
end

function ExchangeCellGroup:SetToggleGroup(i, group)
	self.item_cell[i].root_node.toggle.group = group
end

function ExchangeCellGroup:SetParent(i, parent)
	self.item_cell[i].daily_view = parent
end

function ExchangeCellGroup:SetData(i, data)
	self.item_cell[i]:SetData(data)
end

--------------------------------------------------------------------------
-- MagicCardItemCell 魔卡兑换物体
--------------------------------------------------------------------------
ExchangeItemCell = ExchangeItemCell or BaseClass(BaseCell)

function ExchangeItemCell:__init()
	self.icon = self:FindVariable("Icon")
	self.level = self:FindVariable("level")
	self.num = self:FindVariable("Num")
	self.magic_ghost = self:FindVariable("magic_ghost")
	self.effect = self:FindVariable("effect")
	self.Name = self:FindVariable("Name")
	self.is_active = self:FindVariable("is_active")

	self:ListenEvent("OnAttributeClick", BindTool.Bind(self.OnAttributeClick, self))
	self:ListenEvent("OnExchangeClick", BindTool.Bind(self.OnExchangeClick, self))
end

function ExchangeItemCell:__delete()

end

function ExchangeItemCell:OnAttributeClick()
	TipsCtrl.Instance:ShowMCAttrView(self.data,2)
end

function ExchangeItemCell:OnExchangeClick()
	if not next(self.data) then return end

	if MagicCardData.Instance:GetBagCardNum() <= 120 then
		local num = MagicCardData.Instance:GetMagicNumByColor(self.data.color)
		local color = MagicCardData.Instance:GetRgbByColor(self.data.color)
		local name = MagicCardData.Instance:GetMoHunNameByColor(self.data.color)
		if num < self.data.need_sprit_num then
			TipsCtrl.Instance:ShowSystemMsg(string.format("<color=%s>%s</color>"..Language.Common.NotEnough,color,name))
		else
			MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_EXCHANGE, self.data.card_id)
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.NotBagRoom)
	end
end

function ExchangeItemCell:OnFlush()
	if not next(self.data) then return end
	if (MagicCardData.Instance:GetCardIsActive(self.data.card_id)) then
		self.is_active:SetValue(true)
	else
		self.is_active:SetValue(false)
	end

	self.Name:SetValue(self.data.card_name)
	self.level:SetValue(1)
	self.num:SetValue(self.data.need_sprit_num)
	self:SetAssetByAsset(self.data.item_id)
	self:SetMgByColor(self.data.color)
end

function ExchangeItemCell:SetAssetByAsset(asset)
	local str = "Card_"..asset
	self.icon:SetAsset("uis/views/magiccardview", str)
end

function ExchangeItemCell:SetMgByColor(color)
	if color == 0 then
		self.magic_ghost:SetAsset("uis/images","blue_mg")
		self.effect:SetAsset("effects2/prefab/ui/ui_mohun_b_prefab","UI_mohun_b")
	elseif color == 1 then
		self.magic_ghost:SetAsset("effects2/prefab/ui/purple_mg_prefab","purple_mg")
		self.effect:SetAsset("effects2/prefab/ui/ui_mohun_z_prefab","UI_mohun_z")
	elseif color == 2 then
		self.magic_ghost:SetAsset("uis/images","orange_mg")
		self.effect:SetAsset("effects2/prefab/ui/ui_mohun_y_prefab","UI_mohun_y")
	else
		self.magic_ghost:SetAsset("uis/images","red_mg")
		self.effect:SetAsset("effects2/prefab/ui/ui_mohun_r_prefab","UI_mohun_r")
	end
end