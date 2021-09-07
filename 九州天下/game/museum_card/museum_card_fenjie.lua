MuseumCardFenJie = MuseumCardFenJie or BaseClass(BaseView)

local BAG_MAX_GRID_NUM = 120		-- 最大格子数
local BAG_ROW = 4					-- 每一页有4行
local BAG_COLUMN = 6				-- 每一页有6列

function MuseumCardFenJie:__init()
	self.ui_config = {"uis/views/museumcardview", "MuseumCardFenJie"}
	self:SetMaskBg()
	self.play_audio = true
	self.is_async_load = false
	self.active_close = false
	self.is_sort = false
end

function MuseumCardFenJie:__delete()
	
end

function MuseumCardFenJie:ReleaseCallBack()
	for k, v in pairs(self.bag_cell) do
		v:DeleteMe()
	end
	self.bag_cell = {}

	self.fenjie_item_list = {}
	self.fenjie_data_list = {}

	self.bag_list_view = nil
	self.select_toggle = nil

	UnityEngine.PlayerPrefs.DeleteKey("show_fenjie")
end

function MuseumCardFenJie:LoadCallBack()
	self.bag_cell = {}

	self.fenjie_item_list = {}
	self.fenjie_data_list = {}

	self.bag_list_view = self:FindObj("ListView")
	local list_delegate = self.bag_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self.select_toggle = self:FindObj("SelectToggle")

	self:ListenEvent("OnClickFenJie", BindTool.Bind(self.OnClickFenJie, self))
	self:ListenEvent("OnClickSort", BindTool.Bind(self.OnClickSort, self))
	self:ListenEvent("OnClickSelectAll", BindTool.Bind(self.OnClickSelectAll, self))
	self:ListenEvent("OnClose", BindTool.Bind(self.Close, self))
end

function MuseumCardFenJie:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function MuseumCardFenJie:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function MuseumCardFenJie:ItemDataChangeCallback()
	if self.bag_list_view then
		self.bag_list_view.scroller:ReloadData(0)
	end
end

function MuseumCardFenJie:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM / BAG_ROW
end

function MuseumCardFenJie:BagRefreshCell(cell, data_index, cell_index)
	-- 构造Cell对象
	local group = self.bag_cell[cell]
	if nil == group then
		group = MuseumCardItemGroup.New(cell.gameObject)
		group.parent = self
		self.bag_cell[cell] = group
	end

	-- 计算索引
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN  + column + (page * grid_count)
	
		self.fenjie_data_list = MuseumCardData.Instance:GetCardItemInBag(self.is_sort)
		local data = self.fenjie_data_list[index + 1]
		if nil == data then data = {} end

		group:SetData(index, i, data, true)
	end
end

function MuseumCardFenJie:OnFlush(param_t)
end

function MuseumCardFenJie:OpFenJieList(index, data)
	self.fenjie_item_list[index] = data
end

function MuseumCardFenJie:OnClickFenJie()
	if nil == next(self.fenjie_item_list) then
		SysMsgCtrl.Instance:ErrorRemind(Language.MuseumCard.SelectFenJie)
		return
	end

	local func = function ()
		for k, v in pairs(self.fenjie_item_list) do
			if next(v) then
				MuseumCardCtrl.Instance:SendCommonOperateReq(RA_MUSEUM_CARD_OPERA_TYPE.RA_MUSEUM_CARD_OPERA_TYPE_FENJIE, v.item_id, v.num)
			end
		end
		self.fenjie_item_list = {}
		self.select_toggle.toggle.isOn = false
	end

	local has_unlock = MuseumCardData.Instance:GetCarHasUnLock(self.fenjie_item_list)
	if has_unlock then
		if UnityEngine.PlayerPrefs.GetInt("show_fenjie") == 1 then
			func()
		else
			TipsCtrl.Instance:ShowCommonTip(func, nil, Language.MuseumCard.CofirmFenJie, nil, nil, true, false, "show_fenjie")
		end
	else
		func()
	end
end

function MuseumCardFenJie:OnClickSort()
	self.is_sort = true
	if self.bag_list_view then
		self.bag_list_view.scroller:ReloadData(0)
	end
	self.is_sort = false
end

function MuseumCardFenJie:OnClickSelectAll()
	local page = self.bag_list_view.list_page_scroll:GetNowPage()
	local is_show = self.select_toggle.toggle.isOn
	for k, v in pairs(self.bag_cell) do
		v:SetAllCellsHighLight(is_show, page)
	end
end

---------------------------- 卡牌分解背包 begin-------------------------------------
MuseumCardItemGroup = MuseumCardItemGroup or BaseClass(BaseRender)

function MuseumCardItemGroup:__init()
	self.cells = {}
	for i = 1, BAG_ROW do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end

	self.index_table = {}
end

function MuseumCardItemGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
	self.parent = nil
end

function MuseumCardItemGroup:SetData(index, i, data, enable)
	if nil == data then return end
	self.cells[i]:SetData(data, enable)
	self.index_table[i] = index

	self.cells[i]:ListenClick(BindTool.Bind(self.OnClickItem, self, i, index))

	for k,v in pairs(self.cells) do
		self.cells[k]:ShowHighLight(false)
	end
end

function MuseumCardItemGroup:OnClickItem(index, bag_index)
	local data = self.cells[index]:GetData()

	local is_select = self.cells[index]:GetToggleIsOn()
	if is_select then
		self.parent:OpFenJieList(bag_index, data)
		self.cells[index]:ShowHighLight(true)
	else
		self.parent:OpFenJieList(bag_index, nil)
		self.cells[index]:ShowHighLight(false)
	end
end

function MuseumCardItemGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function MuseumCardItemGroup:SetAllCellsHighLight(is_show, page)
	for i = 1, BAG_ROW do
		if next(self.cells[i]:GetData()) then
			if self.index_table[i] < (page + 1) * 24 then		-- 只选择当前页
				if is_show then
					self.parent:OpFenJieList(self.index_table[i], self.cells[i]:GetData())
				else
					self.parent:OpFenJieList(self.index_table[i], nil)
				end
				self.cells[i]:ShowHighLight(is_show)
				self.cells[i]:SetHighLight(is_show)
			end
		end
	end
end
------------------------------ 卡牌分解背包 end-------------------------------------
