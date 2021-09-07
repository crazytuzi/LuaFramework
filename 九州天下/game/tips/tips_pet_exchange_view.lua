TipsPetExchangeView = TipsPetExchangeView or BaseClass(BaseView)
function TipsPetExchangeView:__init()
	self.ui_config = {"uis/views/tips/pettips", "ShowPetExchangeView"}
	self.view_layer = UiLayer.Pop
	self.contain_cell_list = {}
	self.play_audio = true
end

function TipsPetExchangeView:__delete()
end

function TipsPetExchangeView:LoadCallBack()
	self:InitListView()
	self.money_text = self:FindVariable("money_text")
	self:FlushMoney()
	self:ListenEvent("close_view",BindTool.Bind(self.OnCloseClick, self))
end

function TipsPetExchangeView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipsPetExchangeView:GetNumberOfCells()
	return #PetData.Instance:GetExchangeCfg()/4
end

function TipsPetExchangeView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = PetExchangeList.New(cell.gameObject)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local item_info_list = PetData.Instance:GetShowExchangeList(cell_index)
	contain_cell:SetItemInfoList(item_info_list)
	contain_cell:OnFlushList()
end

function TipsPetExchangeView:OnCloseClick()
	self:Close()
end

function TipsPetExchangeView:FlushMoney()
	local value = PetData.Instance:GetAllInfoList().score
	if value > 99999 and value <= 99999999 then
		value = value / 10000
		value = math.floor(value)
		value = value .. "万"
	elseif value > 99999999 then
		value = value / 100000000
		value = math.floor(value)
		value = value .. "亿"
	end
	self.money_text:SetValue(value)
end
---------------------------------------------------
PetExchangeList = PetExchangeList  or BaseClass(BaseCell)
function PetExchangeList:__init()
	self.exchange_list = {}
	for i = 1, 4 do
		self.exchange_list[i] = PetExchangeItem.New(self:FindObj("item_" .. i))
	end
end

function PetExchangeList:SetItemInfoList(item_info_list)
	for i = 1, 4 do
		self.exchange_list[i]:SetItemInfo(item_info_list[i])
	end
end

function PetExchangeList:OnFlushList(item_info_list)
	for i = 1, 4 do
		self.exchange_list[i]:OnFlush()
	end
end
---------------------------------------------------
PetExchangeItem = PetExchangeItem or BaseClass(BaseCell)
function PetExchangeItem:__init()
	self.name = self:FindVariable("name")
	self.coin = self:FindVariable("coin")
	self.coin_icon = self:FindVariable("coin_icon")
	self.show_gold_icon = self:FindVariable("show_gold_icon")
	self.show_youshan_text = self:FindVariable("show_youshan_text")
	self.show_exchange_text = self:FindVariable("show_exchange_text")
	self.show_gold_icon:SetValue(true)
	self.show_youshan_text:SetValue(false)
	self.show_exchange_text:SetValue(false)
	self.remain_text = self:FindVariable("remain_text")
	self.item_cell = ItemCell.New(self:FindObj("item"))
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleClick,self))
	self.item_info = nil
	local bundle, asset = ResPath.GetExchangeNewIcon("Friendly")
	self.coin_icon:SetAsset(bundle, asset)
end

function PetExchangeItem:OnToggleClick()
	TipsCtrl.Instance:ShowPetExchangeBuyView(self.item_info.item_id)
end

function PetExchangeItem:SetItemInfo(item_info)
	self.item_info = item_info
end

function PetExchangeItem:OnFlush()
	self.root_node:SetActive(true)
	if self.item_info == nil then
		self.root_node:SetActive(false)
		return
	end
	local data = ItemData.Instance:GetItemConfig(self.item_info.item_id)
	data.item_id = self.item_info.item_id
	data.is_bind = self.item_info.is_bind
	self.item_cell:SetData(data)
	self.name:SetValue(data.name)
	self.coin:SetValue(PetData.Instance:GetSingleExchangeCfg(self.item_info.item_id).need_score)
end

