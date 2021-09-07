--------------------------------------------------------------------------
-- MaGicCardAttrView 魔卡属性面板
--------------------------------------------------------------------------
MaGicCardAttrView = MaGicCardAttrView or BaseClass(BaseRender)

local PAGE_CELL_NUM = 4		--一页的个数
-- 背包常量
local BAG_MAX_GRID_NUM = 120
local BAG_ROW = 6
local BAG_COLUMN = 5

function MaGicCardAttrView:__init()
	MaGicCardAttrView.Instance = self
	self:InitView()

	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function MaGicCardAttrView:__delete()
	MaGicCardAttrView.Instance = nil

	for k, v in pairs(self.left_cell_list) do
		v:DeleteMe()
	end
	self.left_cell_list = {}

	for k, v in pairs(self.right_cell_list) do
		v:DeleteMe()
	end
	self.right_cell_list = {}

	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function MaGicCardAttrView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	GlobalEventSystem:Fire(BagFlushEventType.BAG_FLUSH_CONTENT, index)
end

function MaGicCardAttrView:FlushBagView()
	self.rightscroller.scroller:RefreshActiveCellViews()
end

function MaGicCardAttrView:InitView()
	self:ListenEvent("all_attribute_click", BindTool.Bind(self.AttributeBtnOnClick, self))
	self:ListenEvent("help_click", BindTool.Bind(self.HelpBtnOnClick, self))
	self:ListenEvent("upgrade_click", BindTool.Bind(self.OnClickKeyButton, self))

	self.up_button_obj = self:FindObj("UpButton")

	self.card_name = self:FindVariable("CardName")
	self.card_status = self:FindVariable("CardStatus")
	self.score = self:FindVariable("Score")
	self.card_explain = self:FindVariable("CardExplain")
	self.cur_level = self:FindVariable("cur_level")
	self.cur_name = self:FindVariable("cur_name")
	self.atk = self:FindVariable("Atk")
	self.hp = self:FindVariable("Hp")
	self.def = self:FindVariable("Def")
	self.add_hp = self:FindVariable("add_hp")
	self.add_atk = self:FindVariable("add_atk")
	self.add_def = self:FindVariable("add_def")
	self.is_maxlevel = self:FindVariable("is_maxlevel")

	self.button_text = self:FindVariable("button_text")
	self.card_icon = self:FindVariable("card_icon")
	self.is_gray = self:FindVariable("is_gray")

	self.left_cell_list = {}
	self.right_cell_list = {}
	self.cur_data = {}
	self.cur_chosen_index = 1
	self.card_info = MagicCardData.Instance:GetCardInfoCfg()

	self:InitLeftScroller()
	self:InitRightScroller()
	self:GoActivedCard()
	self.cur_data = self.card_info[self.cur_chosen_index]
	-- self:FlushCurCardAttr(self.card_info[self.cur_chosen_index])
end

function MaGicCardAttrView:SetCurIndex(index)
	self.cur_chosen_index = index
end

function MaGicCardAttrView:GoActivedCard()
	for i=1,16 do
		if MagicCardData.Instance:GetCardIsActive(i) then
			self.cur_chosen_index = i
			return
		end
	end
end

function MaGicCardAttrView:GetCurIndex()
	return self.cur_chosen_index
end

function MaGicCardAttrView:FlushCurCardAttr(data)
	self.cur_data = data
	self.cur_data.level = MagicCardData.Instance:GetCardInfoListByIndex(data.card_id).strength_level
	self.attr_list = {}
	self.attr_list = MagicCardData.Instance:GetCardInfoByIdAndLevel(data.card_id,self.cur_data.level)
	self.cur_data.is_active = MagicCardData.Instance:GetCardIsActive(data.card_id)

	local info_list = {}
	info_list.max_hp = self.attr_list.maxhp
	info_list.gong_ji = self.attr_list.gongji
	info_list.fang_yu = self.attr_list.fangyu
	info_list.ming_zhong = self.attr_list.mingzhong
	info_list.shan_bi = self.attr_list.shanbi

	self.cur_data.fight = CommonDataManager.GetCapabilityCalculation(info_list)

	self.card_suit = {}
	self.card_suit = MagicCardData.Instance:GetCardTaoZByColor(data.color)

	local color = MagicCardData.Instance:GetRgbByColor(data.color)
	self.card_name:SetValue(string.format("<color=%s>%s</color>",color,data.card_name))
	self.cur_name:SetValue(data.card_name)

	local str = "Card_"..data.item_id
	self.card_icon:SetAsset("uis/views/magiccardview", str)

	if self.cur_data.is_active then
		self.card_status:SetValue(string.format("<color=#00ff00>Lv.%s</color>",data.level))
		self.button_text:SetValue(Language.MagicCard.UpGrade)
		self.is_gray:SetValue(false)
	else
		self.card_status:SetValue(string.format("<color=#ff0000>(" .. Language.Common.NoActivate .. ")</color>"))
		self.button_text:SetValue(Language.MagicCard.Active)
		self.is_gray:SetValue(true)
	end
	self.score:SetValue(self.cur_data.fight)
	self.card_explain:SetValue(string.format(Language.MagicCard.TaozhuangDesc,self.card_suit.taoka_name,data.card_name))
	self.cur_level:SetValue(data.level)
	self.atk:SetValue(self.attr_list.gongji)
	self.hp:SetValue(self.attr_list.maxhp)
	self.def:SetValue(self.attr_list.fangyu)

	if self.cur_data.level >= 10 then
		-- self.is_maxlevel:SetValue(true)
		self.up_button_obj.button.interactable = false
		self.up_button_obj.grayscale.GrayScale = 255
		self.button_text:SetValue(Language.MagicCard.MaxButtonText)
	else
		-- self.is_maxlevel:SetValue(false)
		self.up_button_obj.button.interactable = true
		self.up_button_obj.grayscale.GrayScale = 0
		-- local  next_attr = MagicCardData.Instance:GetCardInfoByIdAndLevel(data.card_id,self.cur_data.level + 1)
		-- self.add_hp:SetValue(next_attr.maxhp)
		-- self.add_atk:SetValue(next_attr.gongji)
		-- self.add_def:SetValue(next_attr.fangyu)
	end
end

function MaGicCardAttrView:OnClickKeyButton()
	if nil == self.cur_data then return end

	if self.cur_data.is_active then
		self:JumpUpGrade(true)
	else
		if MagicCardData.Instance:GetIsActiveById(self.cur_data.card_id) then
			MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_USE_CARD,self.cur_data.card_id)
		else
			TipsCtrl.Instance:ShowItemGetWayView(self.cur_data.item_id)
		end
	end
end

function MaGicCardAttrView:FlushCurCardData()
	self:JumpUpGrade(self.cur_data.is_active)
end

function MaGicCardAttrView:JumpUpGrade(is_active)
	MoLongView.Instance:OnUpMcUpLevelToggle()
	MagicCardUpView.Instance:GetCardData(self.cur_data)
	MagicCardUpView.Instance:GetCurCardData(self.cur_data)
	MagicCardUpView.Instance:FlushUpLevel(is_active)
	MagicCardUpView.Instance:FlushData()
	MagicCardUpView.Instance:SetCurIndex(self.cur_chosen_index)
end

function MaGicCardAttrView:BagJumpPage(page)
	self.leftscroller.list_page_scroll:JumpToPage(page)
end

function MaGicCardAttrView:FlushInfoView()
	self.leftscroller.scroller:RefreshActiveCellViews()
	self:FlushBagView()
	self:FlushCurCardAttr(self.cur_data)
	-- self:FlushRedPoint()
end

function MaGicCardAttrView:FlushRedPoint()
	for k,v in pairs(self.right_cell_list) do
		for i=1,BAG_ROW do
			local data = {}
			data = v:GetData(i)
			local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
			data.card_id = MagicCardData.Instance:GetCardIdByItemId(data.item_id)
			if nil ~= item_cfg1 and MagicCardData.Instance:GetIsActiveById(data.card_id) then
				v:SetRedPoint(i,true)
				return
			else
				v:SetRedPoint(i,false)
			end
		end
	end
end

--初始化左滚动条 -- start
function MaGicCardAttrView:InitLeftScroller()
	self.leftscroller = self:FindObj("LeftScroller")

	self.list_view_delegate = self.leftscroller.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfLeftCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshLeftView, self)
end

function MaGicCardAttrView:GetNumberOfLeftCells()
	return PAGE_CELL_NUM
end

function MaGicCardAttrView:RefreshLeftView(cell, data_index)
	local group_cell = self.left_cell_list[cell]
	if group_cell == nil then
		group_cell = MaGicCardListView.New(cell.gameObject)
		self.left_cell_list[cell] = group_cell
	end
	for i = 1, PAGE_CELL_NUM do
		local index = data_index * PAGE_CELL_NUM + i
		local data = self.card_info[index]
		if data then
			group_cell:SetIndex(i, index)
			group_cell:SetParent(i, self)
			group_cell:SetData(i, data)
		end
	end
end
-- end

--初始化右滚动条 -- start
function MaGicCardAttrView:InitRightScroller()
	self.rightscroller = self:FindObj("RightScroller")

	self.list_view_delegate = self.rightscroller.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfRightCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRightView, self)
end

function MaGicCardAttrView:GetNumberOfRightCells()
	return BAG_COLUMN * PAGE_CELL_NUM
end

function MaGicCardAttrView:RefreshRightView(cell, data_index)
	local group_cell = self.right_cell_list[cell]
	if group_cell == nil then
		group_cell = CardItemCellGroup.New(cell.gameObject)
		group_cell:SetToggleGroup(self.root_node.toggle_group)
		self.right_cell_list[cell] = group_cell
	end
	-- 计算索引
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN  + column + (page * grid_count)

		-- 获取数据信息
		local data = {}
		if MagicCardData.Instance:GetMCBagData()[index + 1] then
			local item_id = MagicCardData.Instance:GetMCBagData()[index + 1].item_id
			local card_id = MagicCardData.Instance:GetMCBagData()[index + 1].card_id
			data = {item_id = item_id, num = 1, is_bind = 0, show_red_point = MagicCardData.Instance:GetIsActiveById(card_id)}
			if data.index == nil then
				data.index = index
			end
		end
		group_cell:SetData(i, data)
		group_cell:SetInteractable(i, nil ~= data.item_id)
		if data.show_red_point ~= nil then
			group_cell:SetRedPoint(i,data.show_red_point)
		end
		group_cell:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group_cell, i))
	end
end

function MaGicCardAttrView:HandleBagOnClick(data, group, group_index)
	local close_callback = function (_data)
		group:SetHighLight(group_index, false)
		group:ShowHighLight(group_index, false)
		if _data then
			self:BagJumpPage(_data.color)
			self.cur_chosen_index = _data.card_id
		end
	end

	group:ShowHighLight(group_index, true)

	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
	data.card_id = MagicCardData.Instance:GetCardIdByItemId(data.item_id)
	if nil ~= item_cfg1 then
		TipsCtrl.Instance:ShowMCView(data,close_callback)
	end
end
-- 			Right end

function MaGicCardAttrView:AttributeBtnOnClick()
	TipsCtrl.Instance:ShowMCAllAttrView()
end

function MaGicCardAttrView:HelpBtnOnClick()
	local tips_id = 81 -- 魔卡帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--------------------------------------------------------------------------
-- MaGicCardListView 魔卡物体左list面板
--------------------------------------------------------------------------
MaGicCardListView = MaGicCardListView or BaseClass(BaseRender)

function MaGicCardListView:__init()
	self:InitView()
end

function MaGicCardListView:__delete()
	for k, v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
end

function MaGicCardListView:InitView()
	self.item_cell = {}
	for i = 1, 4 do
		local card_item = MagicCardAttrItemCell.New(self:FindObj("CardItem" .. i))
		table.insert(self.item_cell, card_item)
	end
end

function MaGicCardListView:SetIndex(i,index)
	self.item_cell[i]:SetIndex(index)
end

function MaGicCardListView:SetToggleGroup(i, group)
	self.item_cell[i].root_node.toggle.group = group
end

function MaGicCardListView:SetParent(i, parent)
	self.item_cell[i].daily_view = parent
end

function MaGicCardListView:SetData(i, data)
	self.item_cell[i]:SetData(data)
end

--------------------------------------------------------------------------
-- MaGicCardObjView 魔卡物体面板
--------------------------------------------------------------------------
MagicCardAttrItemCell = MagicCardAttrItemCell or BaseClass(BaseCell)

function MagicCardAttrItemCell:__init()
	self.icon = self:FindVariable("Icon")
	self.level = self:FindVariable("level")
	self.name = self:FindVariable("name")

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
	self.Image = self:FindObj("Image")
end

function MagicCardAttrItemCell:__delete()
end

function MagicCardAttrItemCell:OnClick()
	MaGicCardAttrView.Instance:SetCurIndex(self.index)
	-- TipsCtrl.Instance:ShowMCAttrView(self.data)
	MaGicCardAttrView.Instance:FlushCurCardAttr(self.data)
end

function MagicCardAttrItemCell:OnFlush()
	if not next(self.data) then return end
	self.data.index = self.index
	self.level:SetValue(MagicCardData.Instance:GetCardInfoListByIndex(self.data.card_id).strength_level)
	self.name:SetValue(self.data.card_name)

	self:SetAssetByAsset(self.data.item_id)
	if MaGicCardAttrView.Instance:GetCurIndex() == self.index then
		MaGicCardAttrView.Instance:FlushCurCardAttr(self.data)
	end

	local is_active = MagicCardData.Instance:GetCardIsActive(self.index)
	if is_active then
		self.Image.grayscale.GrayScale = 0
	else
		self.Image.grayscale.GrayScale = 255
	end
end

function MagicCardAttrItemCell:SetAssetByAsset(asset)
	local str = "Card_"..asset
	self.icon:SetAsset("uis/views/magiccardview", str)
end

-- 物品格子
CardItemCellGroup = CardItemCellGroup or BaseClass(BaseRender)

function CardItemCellGroup:__init()
	self.cells = {}
	self.cells = {
		ItemCell.New(self:FindObj("Item1")),
		ItemCell.New(self:FindObj("Item2")),
		ItemCell.New(self:FindObj("Item3")),
		ItemCell.New(self:FindObj("Item4")),
		ItemCell.New(self:FindObj("Item5")),
		ItemCell.New(self:FindObj("Item6")),
	}
end

function CardItemCellGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function CardItemCellGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function CardItemCellGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function CardItemCellGroup:SetToggleGroup(toggle_group)
	self.cells[1]:SetToggleGroup(toggle_group)
	self.cells[2]:SetToggleGroup(toggle_group)
	self.cells[3]:SetToggleGroup(toggle_group)
	self.cells[4]:SetToggleGroup(toggle_group)
	self.cells[5]:SetToggleGroup(toggle_group)
	self.cells[6]:SetToggleGroup(toggle_group)
end

function CardItemCellGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function CardItemCellGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function CardItemCellGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end

function CardItemCellGroup:SetNotRedPoint(i, enable)
	self.cells[i]:SetNotShowRedPoint(enable)
end

function CardItemCellGroup:GetData(i)
	return self.cells[i]:GetData()
end

function CardItemCellGroup:SetRedPoint(i,is_show)
	self.cells[i]:SetRedPoint(is_show)
end
