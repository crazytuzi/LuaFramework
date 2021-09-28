--宠物兑换
local COLUMN = 8

LittlePetExchangeView = LittlePetExchangeView or BaseClass(BaseRender)

function LittlePetExchangeView:__init(instance)
	self.item_cfg_list = {}
	self.exchange_contain_list = {}

	self.coin_text = self:FindVariable("gold_text")
	self.page_count = self:FindVariable("PageCount")
	
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.list_view.list_page_scroll:SetPageCount(self:GetNumberOfCells())
end

function LittlePetExchangeView:__delete()
	if self.exchange_contain_list ~= nil then
		for k, v in pairs(self.exchange_contain_list) do
			v:DeleteMe()
		end
	end
	self.exchange_contain_list = {}
end

function LittlePetExchangeView:OpenCallBack()
	self:GetExchangeDataList()
	local count = self:GetNumberOfCells()
	self.page_count:SetValue(count)
	self.list_view.list_page_scroll:SetPageCount(count)
	self.list_view.scroller:ReloadData(0)
end

function LittlePetExchangeView:CloseCallBack()
	
end

function LittlePetExchangeView:GetExchangeDataList()
	self.item_cfg_list = LittlePetData.Instance:GetExchangeCfg()
end

function LittlePetExchangeView:GetNumberOfCells()
	local count = #self.item_cfg_list
	return math.ceil(count / COLUMN) or 0
end

function LittlePetExchangeView:RefreshCell(cell, cell_index)
	local exchange_contain = self.exchange_contain_list[cell]
	if exchange_contain == nil then
		exchange_contain = LittlePetExchangeContain.New(cell.gameObject, self)
		self.exchange_contain_list[cell] = exchange_contain
	end

	cell_index = cell_index
	exchange_contain:SetIndex(cell_index)
	exchange_contain:SetData(self.item_cfg_list)
end

function LittlePetExchangeView:OnFlush()
	self.list_view.scroller:RefreshAndReloadActiveCellViews(false)
end

----------------------------------------------------------------------------
LittlePetExchangeContain = LittlePetExchangeContain or BaseClass(BaseCell)
function LittlePetExchangeContain:__init()
	self.item_list = {}
	for i=1, COLUMN do
		self.item_list[i] = LittlePetExchangeItem.New(self:FindObj("item_"..i))
	end
end

function LittlePetExchangeContain:__delete()
	if self.item_list ~= nil then
		for k, v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}
end

function LittlePetExchangeContain:SetIndex(index)
	self.index = index
end

function LittlePetExchangeContain:SetData(data_list)
	for i=1, COLUMN do
		local index = self.index * 8 + i
		self.item_list[i]:SetData(data_list[index])
	end
end
----------------------------------------------------------------------------
LittlePetExchangeItem = LittlePetExchangeItem or BaseClass(BaseCell)

function LittlePetExchangeItem:__init()
	self.item_id = 0

	self.name = self:FindVariable("name")
	self.coin = self:FindVariable("coin")
	
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))
	self.item_cell:ShowHighLight(false)

	self:ListenEvent("click", BindTool.Bind(self.OnExchangeClick, self))
end

function LittlePetExchangeItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function LittlePetExchangeItem:OnFlush()
	self.root_node:SetActive(true)
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	end

	local item_list = self.data.exchage_item
	local item_id = item_list and item_list.item_id
	local item_cfg = item_id and ItemData.Instance:GetItemConfig(item_id)
	self.item_id = item_cfg and item_id or 0
	if item_cfg then
		local item_name = item_cfg.name or ""
		local color = item_cfg.color and ITEM_COLOR[item_cfg.color] or TEXT_COLOR.GREEN_SPECIAL_1
		local name_str = ToColorStr(item_name, color)
		self.name:SetValue(name_str)
		self.item_cell:SetData(item_list)
	end

	local need_score = self.data.need_score or 0
	local have_ji_fen = LittlePetData.Instance:GetCurJiFenByInfo() or 0
	local score_color = have_ji_fen >= need_score and TEXT_COLOR.BLUE1 or TEXT_COLOR.RED
	local score_str = ToColorStr(need_score, score_color)
	self.coin:SetValue(score_str)
end

function LittlePetExchangeItem:OnExchangeClick()
	if nil == self.data or self.item_id == 0 then return end

	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	if nil == item_cfg then return end

	local have_ji_fen = LittlePetData.Instance:GetCurJiFenByInfo()
	local need_ji_fen = self.data.need_score
	if have_ji_fen < need_ji_fen then
		SysMsgCtrl.Instance:ErrorRemind(Language.LittlePet.JiFenNotEnough)
		return
	end

	local function ok_callback()
		local opera_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_EXCHANGE
		local param1 = self.data.seq or 0
		local param2 = 1
		LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, param1, param2, param3)
	end
	
	local color = item_cfg.color and ITEM_COLOR[item_cfg.color] or TEXT_COLOR.GREEN_SPECIAL_1
	local little_pet_name = item_cfg.name or ""
	local name_str = ToColorStr(little_pet_name, color)
	local des = string.format(Language.LittlePet.JiFenExchange, need_ji_fen, name_str)
	TipsCtrl.Instance:ShowCommonAutoView("little_pet_exchange", des, ok_callback)
end