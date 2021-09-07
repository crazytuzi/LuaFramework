SpiritExchangeView = SpiritExchangeView or BaseClass(BaseRender)

local COLUMN = 4

function SpiritExchangeView:__init(instance)
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshExchangeCells, self)

	self.cell_list = {}
end

function SpiritExchangeView:__delete()
	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = nil
end

function SpiritExchangeView:GetNumOfCells()
	return math.ceil(#SpiritData.Instance:GetSpiritExchangeCfgList() / COLUMN)
end

function SpiritExchangeView:RefreshExchangeCells(cell, data_index)
	local group = self.cell_list[cell]
	local exchange_list = SpiritData.Instance:GetSpiritExchangeCfgList()
	if group == nil then
		group = SpiritExchangeGroup.New(cell.gameObject)
		self.cell_list[cell] = group
	end

	if #SpiritData.Instance:GetSpiritExchangeCfgList() % COLUMN ~= 0
		and data_index == math.floor(#SpiritData.Instance:GetSpiritExchangeCfgList() / COLUMN) then
		for i = #SpiritData.Instance:GetSpiritExchangeCfgList() % COLUMN + 1, 4 do
			group:SetActive(i, false)
		end
		for i = 1, #SpiritData.Instance:GetSpiritExchangeCfgList() % COLUMN do
			local index = i + data_index * COLUMN
			group:SetData(i, exchange_list[index])
			group:ListenClick(i, BindTool.Bind(self.OnClickExChangeButton, self, index, exchange_list[index]))
		end
	else
		for i = 1, 4 do
			local index = i + data_index * COLUMN
			group:SetData(i, exchange_list[index])
			group:SetActive(i, true)
			group:ListenClick(i, BindTool.Bind(self.OnClickExChangeButton, self, index, exchange_list[index]))
		end
	end
end

function SpiritExchangeView:OnClickExChangeButton(index, data)
	-- local score = SpiritData.Instance:GetSpiritExchangeScore()
	-- local func = function (num)
	-- 	SpiritCtrl.Instance:SendExchangeJingLingReq(SpiritDataExchangeType.Type, index - 1, num)
	-- end
	-- local max_num = math.floor(score / data.price)
	-- if max_num <= 0 then
	-- 	max_num = 1
	-- end
	SpiritCtrl.Instance:SendExchangeJingLingReq(SpiritDataExchangeType.Type, index - 1, 1)
	-- TipsCtrl.Instance:OpenCommonInputView(1, func, nil, max_num)
end


-- 兑换列表
SpiritExchangeGroup = SpiritExchangeGroup or BaseClass(BaseRender)

function SpiritExchangeGroup:__init(instance)
	self.cells = {}
	for i = 1, 4 do
		self.cells[i] = {item = self:FindObj("Item"..i), cell = SpiritExchangeCell.New(self:FindObj("Item"..i))}
	end
end

function SpiritExchangeGroup:__delete()
	for k, v in pairs(self.cells) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.cells = {}
end

function SpiritExchangeGroup:SetActive(i, value)
	self.cells[i].item:SetActive(value)
end

function SpiritExchangeGroup:SetData(i, data)
	self.cells[i].cell:SetData(data)
end

function SpiritExchangeGroup:ListenClick(i, handler)
	self.cells[i].cell:ListenClick(handler)
end


-- 兑换格子
SpiritExchangeCell = SpiritExchangeCell or BaseClass(BaseRender)

function SpiritExchangeCell:__init(instance)
	self.name = self:FindVariable("name")
	self.coin = self:FindVariable("coin")
	self.max_tiems = self:FindVariable("MaxTimes")
	self.had_use_times = self:FindVariable("HadUseTimes")
	self.show_no_limit = self:FindVariable("ShowNoLimit")
	self.show_limit = self:FindVariable("ShowLimit")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))
end

function SpiritExchangeCell:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function SpiritExchangeCell:SetData(data)
	if data == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	self.item:SetData(data)

	self.show_no_limit:SetValue(data.limit_convert_count == 0)
	self.show_limit:SetValue(data.limit_convert_count ~= 0)
	if item_cfg ~= nil then
		local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
		self.name:SetValue(name_str)
		self.coin:SetValue(data.price)
		self.max_tiems:SetValue(data.limit_convert_count)
	end
end

function SpiritExchangeCell:ListenClick(handler)
	self:ClearEvent("click")
	self:ListenEvent("click", handler)
end

