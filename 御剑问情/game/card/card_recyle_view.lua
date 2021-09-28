CardRecyleView = CardRecyleView or BaseClass(BaseRender)

local BAG_MAX_GRID_NUM = 140			-- 最大格子数
local BAG_PAGE_NUM = 7					-- 页数
local BAG_PAGE_COUNT = 20				-- 每页个数
local BAG_ROW = 4						-- 行数
local BAG_COLUMN = 5					-- 列数
CardRecyleView.SELECT_INDEX_LIST = {}
function CardRecyleView:__init(instance, mother_view)
	self.data_list = {}
	self.cap = self:FindVariable("Cap")
	self.cur_lv = self:FindVariable("CurLv")
	self.next_lv = self:FindVariable("NextLv")
	self.prog = self:FindVariable("Prog")
	self.prog_txt = self:FindVariable("ProgTxt")
	-- self.next_cap = self:FindVariable("NextCap")
	self.maxhp = self:FindVariable("Hp")
	self.gongji = self:FindVariable("Gongji")
	self.fangyu = self:FindVariable("Fangyu")
	self.mingzhong = self:FindVariable("Mingzhong")
	self.shanbi = self:FindVariable("Shanbi")
	self.baoji = self:FindVariable("Baoji")
	self.jianren = self:FindVariable("kangbao")

	self.bag_cell = {}
	-- 获取控件
	self.bag_list_view = self:FindObj("ListView")

	local list_delegate = self.bag_list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)


	self:ListenEvent("OnClickGuaji",BindTool.Bind(self.OnClickGuaji, self))
	self:ListenEvent("OnClickRecyle",BindTool.Bind(self.OnClickRecyle, self))
	self:ListenEvent("OnClickDoRecyle",BindTool.Bind(self.OnClickDoRecyle, self))
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))

	self.check_lover = false
end

function CardRecyleView:__delete()
	if self.bag_cell then
		for k,v in pairs(self.bag_cell) do
			v:DeleteMe()
		end
		self.bag_cell = {}
	end
end

function CardRecyleView:OpenCallBack()
	self.need_jump = true
	-- 设置一个一小时的红点间隔
	if RemindManager.Instance:GetRemind(RemindName.CardRecyle) > 0 then
		DelayTimeRemindList[RemindName.CardRecyle] = 3600
		RemindManager.Instance:Fire(RemindName.CardRecyle)
		CardCtrl.Instance:SetDelayRemind()
	end
	CardRecyleView.SELECT_INDEX_LIST = {}
	self:Flush()
end

function CardRecyleView:FlushBagList()
	for k,v in pairs(self.bag_cell) do
		if v:GetActive() and k.transform.parent == self.bag_list_view.scroll_rect.content then
			self:RefreshCell(v)
		end
	end
end

function CardRecyleView:CloseCallBack()

end

function CardRecyleView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(244)
end

function CardRecyleView:OnClickGuaji()
	CardCtrl.Instance:OpenGuajiView()
end

function CardRecyleView:OnClickRecyle()
	CardCtrl.Instance:OpenRecyleView(BindTool.Bind(self.AutoRecyleColor, self))
end

function CardRecyleView:OnClickDoRecyle()
	for k,v in pairs(CardRecyleView.SELECT_INDEX_LIST) do
		PackageCtrl.Instance:SendDiscardItem(v.index, v.num, v.item_id, v.num, 1)
	end
	CardRecyleView.SELECT_INDEX_LIST = {}
end

function CardRecyleView:AutoRecyleColor(color)
	for i = 1, BAG_MAX_GRID_NUM do
		if self.data_list[i] then
			local item_cfg = ItemData.Instance:GetItemConfig(self.data_list[i].item_id)
			local card_color = CardData.Instance:GetCardColor(self.data_list[i].item_id)
			local is_better, is_open = CardData.Instance:IsBetterCardPiece(self.data_list[i].item_id)
			if is_better and not is_open then
				is_better = card_color > 2
			end
			if item_cfg and card_color <= color and not is_better then
				CardRecyleView.SELECT_INDEX_LIST[self.data_list[i].index] = self.data_list[i]
			else
				CardRecyleView.SELECT_INDEX_LIST[self.data_list[i].index] = nil
			end
		end
	end
	if self.bag_list_view and self.bag_list_view.list_page_scroll2.isActiveAndEnabled then
		self.bag_list_view.list_view:Reload()
	end
	self:SetProgTxt()
end

function CardRecyleView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function CardRecyleView:BagRefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = CardItemCell.New(cellObj)
		-- cell:SetToggleGroup(self.root_node.toggle_group)
		self.bag_cell[cellObj] = cell
	end
	cell.local_index = index
	self:RefreshCell(cell)
end

function CardRecyleView:RefreshCell(cell)
	local index = cell.local_index or 0
	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN

	-- 获取数据信息
	local data = self.data_list[grid_index + 1] or {}

	local cell_data = {}
	cell_data.item_id = data.item_id
	cell_data.index = data.index or grid_index
	cell_data.param = data.param
	cell_data.num = data.num
	cell_data.is_bind = data.is_bind
	cell_data.invalid_time = data.invalid_time

	cell:SetIconGrayScale(false)
	cell:ShowQuality(nil ~= cell_data.item_id)
	cell:ShowHighLight(false)
	cell:SetGetImgVis(data.index ~= nil and CardRecyleView.SELECT_INDEX_LIST[data.index] ~= nil)
	cell:SetData(cell_data, true)
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell, data.index))
	cell:SetInteractable((nil ~= cell_data.item_id or cell_data.locked))
end

function CardRecyleView:HandleBagOnClick(cell, index)
	local data = cell:GetData()
	if index and CardRecyleView.SELECT_INDEX_LIST[index] then
		CardRecyleView.SELECT_INDEX_LIST[index] = nil
		cell:SetGetImgVis(false)
	elseif index and data and data.item_id and data.item_id > 0 then
		CardRecyleView.SELECT_INDEX_LIST[index] = data
		cell:SetGetImgVis(true)
	end
	self:SetProgTxt()
end

function CardRecyleView:OnFlush()
	self.data_list = CardData.Instance:GetAllCardList()
	for k,v in pairs(CardRecyleView.SELECT_INDEX_LIST) do
		if ItemData.Instance:GetItemNumInBagByIndex(k) <= 0 then
			CardRecyleView.SELECT_INDEX_LIST[k] = nil
		end
	end
	if next(self.bag_cell) ~= nil and (not self.need_jump or self.bag_list_view.list_page_scroll2:GetNowPage() == 0) then
		self:FlushBagList()
	else
		self.bag_list_view.list_view:Reload(function()
			self.bag_list_view.list_page_scroll2:JumpToPageImmidate(0)
		end)
		self.bag_list_view.list_view:JumpToIndex(0)
		self.need_jump = false
	end

	local card_level = CardData.Instance:GetCardLevel()
	local card_exp = CardData.Instance:GetCardExp()

	local marry_level_cfg = CardData.Instance:GetCardLevelCfg(card_level)
	if nil == marry_level_cfg then return end
	local cap = CommonDataManager.GetCapability(marry_level_cfg)
	self.cap:SetValue(cap)
	self.cur_lv:SetValue(card_level)
	self.maxhp:SetValue(marry_level_cfg.maxhp)
	self.gongji:SetValue(marry_level_cfg.gongji)
	self.fangyu:SetValue(marry_level_cfg.fangyu)
	self.mingzhong:SetValue(marry_level_cfg.mingzhong)
	self.shanbi:SetValue(marry_level_cfg.shanbi)
	self.baoji:SetValue(marry_level_cfg.baoji)
	self.jianren:SetValue(marry_level_cfg.jianren)

	local marry_level_n_cfg = CardData.Instance:GetCardLevelCfg(card_level + 1)
	if marry_level_n_cfg then
		self.next_lv:SetValue(card_level + 1)
		self.prog:SetValue(card_exp / marry_level_cfg.need_exp)
	else
		self.next_lv:SetValue(card_level)
		self.prog:SetValue(1)
	end
	self:SetProgTxt()
end

function CardRecyleView:SetProgTxt()
	local card_level = CardData.Instance:GetCardLevel()
	local card_exp = CardData.Instance:GetCardExp()
	local marry_level_cfg = CardData.Instance:GetCardLevelCfg(card_level)
	local marry_level_n_cfg = CardData.Instance:GetCardLevelCfg(card_level + 1)
	if marry_level_cfg and marry_level_n_cfg then
		local add_exp = self:GetAllSelectEquipScore()
		add_exp = add_exp > 0 and "<color=#0000f1> +" .. self:GetAllSelectEquipScore() .. "</color>" or ""
		self.prog_txt:SetValue(card_exp .. add_exp .. "/" .. marry_level_cfg.need_exp)
	else
		self.prog_txt:SetValue(Language.Common.YiManJi)
	end
end

function CardRecyleView:GetAllSelectEquipScore()
	local score = 0
	for k,v in pairs(CardRecyleView.SELECT_INDEX_LIST) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			score = score + item_cfg.recyclget * v.num
		end
	end
	return score
end


CardItemCell = CardItemCell or BaseClass(BaseCell)

function CardItemCell:__init()
	self.equip = ItemCell.New()
	self.equip:SetInstanceParent(self:FindObj("Item"))
	self.show_get_img = self:FindVariable("ShowGetimg")
end

function CardItemCell:__delete()
	self.equip:DeleteMe()
	self.equip = nil
end

function CardItemCell:SetData(...)
	BaseCell.SetData(self, ...)
	self.equip:SetData(...)
end

function CardItemCell:GetActive()
	if self.root_node.gameObject and not IsNil(self.root_node.gameObject) then
		return self.root_node.gameObject.activeSelf
	end
	return false
end

function CardItemCell:SetGetImgVis(value)
	self.show_get_img:SetValue(value)
end

function CardItemCell:SetIconGrayScale(...)
	self.equip:SetIconGrayScale(...)
end

function CardItemCell:ShowQuality(...)
	self.equip:ShowQuality(...)
end

function CardItemCell:ShowHighLight(...)
	self.equip:ShowHighLight(...)
end

function CardItemCell:ListenClick(...)
	self.equip:ListenClick(...)
end

function CardItemCell:SetInteractable(...)
	self.equip:SetInteractable(...)
end