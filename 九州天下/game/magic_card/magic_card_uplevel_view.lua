--------------------------------------------------------------------------
-- MagicCardUpView 魔卡属性面板
--------------------------------------------------------------------------
MagicCardUpView = MagicCardUpView or BaseClass(BaseRender)

local PAGE_CELL_NUM = 4		--一页的个数
-- 背包常量
local BAG_MAX_GRID_NUM = 60
local BAG_ROW = 3
local BAG_COLUMN = 5

function MagicCardUpView:__init()
	MagicCardUpView.Instance = self
	self:InitView()

	-- 监听系统事件
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function MagicCardUpView:__delete()
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

function MagicCardUpView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	GlobalEventSystem:Fire(BagFlushEventType.BAG_FLUSH_CONTENT, index)
	-- self:FlushBagView()
end

function MagicCardUpView:FlushBagView()
	self.rightscroller.scroller:RefreshActiveCellViews()
end

function MagicCardUpView:InitView()
	self:ListenEvent("all_attribute_click", BindTool.Bind(self.AttributeBtnOnClick, self))
	self:ListenEvent("help_click", BindTool.Bind(self.HelpBtnOnClick, self))
	self:ListenEvent("back_click", BindTool.Bind(self.BackBtnOnClick, self))
	self:ListenEvent("uplevel_click", BindTool.Bind(self.UpLevelBtnOnClick, self))
	self:ListenEvent("chosen_click", BindTool.Bind(self.ChosenBtnOnClick, self))
	self:ListenEvent("card01_click", BindTool.Bind(self.Card01BtnOnClick, self))
	self:ListenEvent("card02_click", BindTool.Bind(self.Card02BtnOnClick, self))
	-- 选择消耗魔卡
	-- start
	self:ListenEvent("Close",BindTool.Bind(self.OnClose, self))
	self:ListenEvent("Sure",BindTool.Bind(self.OnSure, self))

	self.Chosen_Card = self:FindObj("Chosen_Card")
	self.Blue_Card = self:FindObj("Blue_Card")
	self.Purple_Card = self:FindObj("Purple_Card")
	self.Orange_Card = self:FindObj("Orange_Card")
	self.Red_Card = self:FindObj("Red_Card")
	-- end

	-- self.Chosen_left = self:FindObj("Chosen_left")
	self.Chosen_right = self:FindObj("Chosen_right")
	-- self.Up_left = self:FindObj("Up_left")
	self.Up_right = self:FindObj("Up_right")

	self.cur_level = self:FindVariable("cur_level")
	self.next_level = self:FindVariable("next_level")
	self.card_exp_slider = self:FindVariable("card_exp_slider")
	self.tips_text = self:FindVariable("tips_text")
	self.image = self:FindVariable("image")
	self.cur_name = self:FindVariable("name")
	self.card_name = self:FindVariable("card_name")
	self.card_exp_slider_in = self:FindVariable("card_exp_slider_in")
	self.exp = self:FindVariable("exp")
	self.card_status = self:FindVariable("CardStatus")
	self.score = self:FindVariable("Score")
	self.card_explain = self:FindVariable("CardExplain")
	self.atk = self:FindVariable("Atk")
	self.hp = self:FindVariable("Hp")
	self.def = self:FindVariable("Def")
	self.is_gray = self:FindVariable("is_gray")
	self.add_hp = self:FindVariable("add_hp")
	self.add_atk = self:FindVariable("add_atk")
	self.add_def = self:FindVariable("add_def")
	self.is_maxlevel = self:FindVariable("is_maxlevel")
	self.bt_text = self:FindVariable("bt_text")

	self.left_cell_list = {}
	self.right_cell_list = {}
	self.card_suit = {}
	self.attr_list = {}
	self.chosen_list = {}
	for i=0,60 do
		self.chosen_list[i] = 0
	end
	self.card_info = MagicCardData.Instance:GetCardInfoCfg()

	self.addexp = 0
	self.is_uplevel = false
	self.cur_chosen_index = 1

	-- self:InitShow()

	self:InitLeftScroller()
	self:InitRightScroller()
end

-- 魔卡属性
function MagicCardUpView:GoActivedCard()
	-- self:GetCardData(self.card_info[1])
	-- if MagicCardData.Instance:GetCardIsActive(1) then
	-- 	print_log(">>>>>>>>>>>>>>>>>")
	-- 	self:FlushUpLevel(true)
	-- else
	-- 	print_log(">>>>>>>>>>>>>>>>>")
	-- 	self:FlushUpLevel(false)
	-- end
	-- self:SetCurAttrData(self.card_info[1])
	-- self:FlushCurCardAttr()
	-- self:GetCardData(self.card_info[1])
	-- self:FlushData()
end

function MagicCardUpView:SetCurIndex(index)
	self.cur_chosen_index = index
end

function MagicCardUpView:GetCurIndex()
	return self.cur_chosen_index
end

-- 用于内部设置
function MagicCardUpView:SetCurAttrData(data)
	self.cur_data = data
	self.cur_data.level = MagicCardData.Instance:GetCardInfoListByIndex(data.card_id).strength_level
	self.attr_list = MagicCardData.Instance:GetCardInfoByIdAndLevel(data.card_id,self.cur_data.level)
	self.cur_data.is_active = MagicCardData.Instance:GetCardIsActive(data.card_id)

	local info_list = {}
	info_list.max_hp = self.attr_list.maxhp
	info_list.gong_ji = self.attr_list.gongji
	info_list.fang_yu = self.attr_list.fangyu
	info_list.ming_zhong = self.attr_list.mingzhong
	info_list.shan_bi = self.attr_list.shanbi

	self.cur_data.fight = CommonDataManager.GetCapabilityCalculation(info_list)

	self.card_suit = MagicCardData.Instance:GetCardTaoZByColor(data.color)
end

function MagicCardUpView:FlushCurCardAttr()
	local color = MagicCardData.Instance:GetRgbByColor(self.cur_data.color)
	self.cur_name:SetValue(string.format("<color=%s>%s</color>",color,self.cur_data.card_name))
	self.card_name:SetValue(self.cur_data.card_name)

	local str = "Card_"..self.cur_data.item_id
	self.image:SetAsset("uis/views/magiccardview", str)

	if self.cur_data.level >= 10 then
		self.is_maxlevel:SetValue(true)
	else
		self.is_maxlevel:SetValue(false)
		local  next_attr = MagicCardData.Instance:GetCardInfoByIdAndLevel(self.cur_data.card_id,self.cur_data.level + 1)
		self.add_hp:SetValue(next_attr.maxhp)
		self.add_atk:SetValue(next_attr.gongji)
		self.add_def:SetValue(next_attr.fangyu)
	end

	if self.cur_data.is_active then
		self.card_status:SetValue(string.format("<color=#00ff00>Lv.%s</color>",self.cur_data.level))
		self.bt_text:SetValue(Language.MagicCard.UpGrade)
		-- self:FlushUpLevel(true)
		self.is_gray:SetValue(false)
	else
		self.card_status:SetValue(string.format("<color=#ff0000>(" .. Language.Common.NoActivate .. ")</color>"))
		self.bt_text:SetValue(Language.MagicCard.Active)
		-- self:FlushUpLevel(false)
		self.is_gray:SetValue(true)
		self.is_maxlevel:SetValue(true)
	end
	self.score:SetValue(self.cur_data.fight)
	self.card_explain:SetValue(string.format(Language.MagicCard.TaozhuangDesc,self.card_suit.taoka_name,self.cur_data.card_name))
	self.cur_level:SetValue(self.cur_data.level)
	self.atk:SetValue(self.attr_list.gongji)
	self.hp:SetValue(self.attr_list.maxhp)
	self.def:SetValue(self.attr_list.fangyu)
end
-- end

function MagicCardUpView:GetCurCardData(data)
	self.cur_data = data
	self.card_suit = MagicCardData.Instance:GetCardTaoZByColor(data.color)
	self.attr_list = MagicCardData.Instance:GetCardInfoByIdAndLevel(data.card_id,self.cur_data.level)
end

function MagicCardUpView:OnClose()
	self.Chosen_Card:SetActive(false)
end

function MagicCardUpView:OnSure()
	self:ClearChosen()
	if self.Blue_Card.toggle.isOn then
		self:SetCurChosen(0)
	end

	if self.Purple_Card.toggle.isOn then
		self:SetCurChosen(1)
	end

	if self.Orange_Card.toggle.isOn then
		self:SetCurChosen(2)
	end

	if self.Red_Card.toggle.isOn then
		self:SetCurChosen(3)
	end
	self.Chosen_Card:SetActive(false)
	self.rightscroller.scroller:RefreshActiveCellViews()
end

function MagicCardUpView:ClearChosen()
	local data = {}
	for k,v in pairs(self.right_cell_list) do
		for i = 1, BAG_ROW do
			data = v:GetData(i)
			local data_id = MagicCardData.Instance:GetCardIdByItemId(data.item_id)
			if v:GetToggleIsOn(i) then
				v:SetHighLight(i,false)
			end
		end
	end

	for i=0,60 do
		self.chosen_list[i] = 0
	end
	self.addexp = 0
	self.card_exp_slider_in:SetValue(self.card_data.exp/self.card_data.up_level_need_exp)
	self.exp:SetValue(string.format("%s + <color=#00ff00>%s</color> / %s",self.card_data.exp,self.addexp,self.card_data.up_level_need_exp))
end

function MagicCardUpView:SetCurChosen(color)
	local data = {}
	for i=0,60 do
		data = MagicCardData.Instance:GetMCBagData()[i + 1]
		if data ~= nil  and data.color == color then
			if MagicCardData.Instance:GetCardIsActive(data.card_id) or data.type == 2 then
				self.chosen_list[i] = 1
				self.addexp = self.addexp + MagicCardData.Instance:GetCardExpById(MagicCardData.Instance:GetCardIdByItemId(data.item_id))
			end
		end
	end

	self.card_exp_slider_in:SetValue((self.card_data.exp + self.addexp)/self.card_data.up_level_need_exp)
	self.exp:SetValue(string.format("%s + <color=#00ff00>%s</color> / %s",self.card_data.exp,self.addexp,self.card_data.up_level_need_exp))
end

function MagicCardUpView:FlushData()
	if self.card_data then
		-- self.card_data.level = MagicCardData.Instance:GetCardInfoListByIndex(self.card_data.card_id).strength_level
		self.card_data.exp = MagicCardData.Instance:GetCardInfoListByIndex(self.card_data.card_id).exp
		self.card_data.up_level_need_exp = MagicCardData.Instance:GetCardInfoByIdAndLevel(self.card_data.card_id,self.card_data.level).up_level_need_exp

		self.card_exp_slider:SetValue(self.card_data.exp/self.card_data.up_level_need_exp)
		self.card_exp_slider_in:SetValue(self.card_data.exp/self.card_data.up_level_need_exp)
		self.exp:SetValue(string.format("%s + <color=#00ff00>%s</color> / %s",self.card_data.exp,self.addexp,self.card_data.up_level_need_exp))
		self.cur_level:SetValue(self.card_data.level)
		self.card_name:SetValue(self.cur_data.card_name)
		local str = "Card_"..self.card_data.item_id
		self.image:SetAsset("uis/views/magiccardview", str)
		if self.card_data.level >= 10 then
			self.tips_text:SetValue(Language.MagicCard.MaxLevel)
			-- self.Up_right:SetActive(true)
			-- self.Chosen_right:SetActive(false)
			return
		end

		self.next_level:SetValue(self.card_data.level + 1)
	end

	if self.cur_data then
		self:FlushCurCardAttr()
	end
end

function MagicCardUpView:BackBtnOnClick()
	-- self:FlushUpLevel(false)
	self.is_uplevel = false
	self.tips_text:SetValue(Language.MagicCard.CardNotActive)
	if self.card_data then
		self:ClearChosen()
	end
	self.leftscroller.scroller:RefreshActiveCellViews()
end

function MagicCardUpView:UpLevelBtnOnClick()
	if self.cur_data.is_active then
		local data = {}
		local is_up = false
		for i=0,60 do
			data = MagicCardData.Instance:GetMCBagData()[i + 1]
			if data ~= nil and self.chosen_list[i] == 1 then
				is_up = true
				MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_UPGRADE_CARD,
				self.card_data.color,self.card_data.slot_index,data.card_id,1)
			end
		end
		if not is_up then
			TipsCtrl.Instance:ShowSystemMsg(Language.MagicCard.InputUpgrade)
		end
		self.addexp = 0
	else
		if MagicCardData.Instance:GetIsActiveById(self.cur_data.card_id) then
			MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_USE_CARD,self.cur_data.card_id)
		else
			TipsCtrl.Instance:ShowItemGetWayView(self.cur_data.item_id)
		end
	end
end

function MagicCardUpView:InitShow()
	-- self.Chosen_right:SetActive(false)
	-- self.Up_right:SetActive(true)
	-- self.Chosen_Card:SetActive(false)
end

function MagicCardUpView:ChosenBtnOnClick()
	self.Chosen_Card:SetActive(true)
end

function MagicCardUpView:Card01BtnOnClick()
	-- TipsCtrl.Instance:ShowMCAttrView(self.card_data,3,false)
end

function MagicCardUpView:Card02BtnOnClick()
	-- TipsCtrl.Instance:ShowMCAttrView(self.card_data,3,true)
end

function MagicCardUpView:FlushUpLevel(is_show)
	self.Chosen_right:SetActive(is_show)
	self.Up_right:SetActive(not is_show)
end

function MagicCardUpView:FlushInfoView()
	if self.card_data then
		self:ClearChosen()
	end
	self:SetCurAttrData(self.card_info[self.cur_chosen_index])
	self:GetCardData(self.card_info[self.cur_chosen_index])
	self:FlushData()
	self:FlushCurCardAttr()

	-- MaGicCardAttrView.Instance:SetCurIndex(self.cur_chosen_index)

	self.leftscroller.scroller:RefreshActiveCellViews()
	self.rightscroller.scroller:RefreshActiveCellViews()
end

function MagicCardUpView:GetCardData(data)
	self.card_data = data
	self.is_uplevel = true
end

--初始化左滚动条 -- start
function MagicCardUpView:InitLeftScroller()
	self.leftscroller = self:FindObj("LeftScroller")

	self.list_view_delegate = self.leftscroller.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfLeftCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshLeftView, self)
end

function MagicCardUpView:GetNumberOfLeftCells()
	return 4
end

function MagicCardUpView:RefreshLeftView(cell, data_index)
	local group_cell = self.left_cell_list[cell]
	if group_cell == nil then
		group_cell = MaGicCardListUpView.New(cell.gameObject)
		self.left_cell_list[cell] = group_cell
	end
	for i = 1, 4 do
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
function MagicCardUpView:InitRightScroller()
	self.rightscroller = self:FindObj("RightScroller")

	self.list_view_delegate = self.rightscroller.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfRightCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRightView, self)
end

function MagicCardUpView:GetNumberOfRightCells()
	return BAG_COLUMN * PAGE_CELL_NUM
end

function MagicCardUpView:RefreshRightView(cell, data_index)
	local group_cell = self.right_cell_list[cell]
	if group_cell == nil then
		group_cell = CardItemUpCellGroup.New(cell.gameObject)
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
			data = {item_id = item_id, num = 1, is_bind = 0, index = index}
		end
		group_cell:SetData(i, data)
		group_cell:SetInteractable(i, (nil ~= data.item_id))
		group_cell:SetHighLight(i, (self.chosen_list[index] == 1 and nil ~= data.item_id))
		group_cell:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group_cell, i))
	end
end

function MagicCardUpView:HandleBagOnClick(data, group, group_index)
	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
	data.card_id = MagicCardData.Instance:GetCardIdByItemId(data.item_id)
	if nil ~= item_cfg1 then
		if not group:GetToggleIsOn(group_index) and self.chosen_list[data.index] == 0 then
			self.addexp = self.addexp + MagicCardData.Instance:GetCardExpById(data.card_id)
			self.chosen_list[data.index] = 1
		else
			self.addexp = self.addexp - MagicCardData.Instance:GetCardExpById(data.card_id)
			self.chosen_list[data.index] = 0
		end
	end
	if self.is_uplevel then
		self.card_exp_slider_in:SetValue((self.card_data.exp + self.addexp)/self.card_data.up_level_need_exp)
		self.exp:SetValue(string.format("%s + <color=#00ff00>%s</color> / %s",self.card_data.exp,self.addexp,self.card_data.up_level_need_exp))
	end
end
-- end

function MagicCardUpView:AttributeBtnOnClick()
	TipsCtrl.Instance:ShowMCAllAttrView()
end

function MagicCardUpView:HelpBtnOnClick()
	local tips_id = 81 -- 魔卡帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

--------------------------------------------------------------------------
-- MaGicCardListUpView 魔卡物体左list面板
--------------------------------------------------------------------------
MaGicCardListUpView = MaGicCardListUpView or BaseClass(BaseRender)

function MaGicCardListUpView:__init()
	self:InitView()
end

function MaGicCardListUpView:__delete()
	for k, v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
end

function MaGicCardListUpView:InitView()
	self.item_cell = {}
	for i = 1, 4 do
		local card_item = MaGicCardUpObjView.New(self:FindObj("CardItem" .. i))
		table.insert(self.item_cell, card_item)
	end
end

function MaGicCardListUpView:SetIndex(i,index)
	self.item_cell[i]:SetIndex(index)
end

function MaGicCardListUpView:SetToggleGroup(i, group)
	self.item_cell[i].root_node.toggle.group = group
end

function MaGicCardListUpView:SetParent(i, parent)
	self.item_cell[i].daily_view = parent
end

function MaGicCardListUpView:SetData(i, data)
	self.item_cell[i]:SetData(data)
end

function MaGicCardListUpView:FlushCell()
	for k, v in pairs(self.item_cell) do
		v:Flush()
	end
end

--------------------------------------------------------------------------
-- MaGicCardUpObjView 魔卡物体面板
--------------------------------------------------------------------------
MaGicCardUpObjView = MaGicCardUpObjView or BaseClass(BaseCell)

function MaGicCardUpObjView:__init()
	self.icon = self:FindVariable("Icon")
	self.level = self:FindVariable("level")
	self.name = self:FindVariable("name")

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
	self.Image = self:FindObj("Image")
end

function MaGicCardUpObjView:__delete()
end

function MaGicCardUpObjView:OnClick()
	if self.data.level > 0 then
		MagicCardUpView.Instance:GetCardData(self.data)
		-- MagicCardUpView.Instance:FlushUpLevel(true)
		MagicCardUpView.Instance:FlushData()
	else
		MagicCardUpView.Instance:BackBtnOnClick()
	end

	-- MaGicCardAttrView.Instance:SetCurIndex(self.cur_chosen_index)
	MagicCardUpView.Instance:SetCurIndex(self.index)
	MagicCardUpView.Instance:SetCurAttrData(self.data)
	MagicCardUpView.Instance:FlushCurCardAttr()
end

function MaGicCardUpObjView:OnFlush()
	if not next(self.data) then return end
	self.data.index = self.index
	self.data.level = MagicCardData.Instance:GetCardInfoListByIndex(self.data.card_id).strength_level
	self.level:SetValue(MagicCardData.Instance:GetCardInfoListByIndex(self.data.card_id).strength_level)
	self.name:SetValue(self.data.card_name)

	self:SetAssetByAsset(self.data.item_id)

	if MagicCardUpView.Instance:GetCurIndex() == self.index then
		MagicCardUpView.Instance:SetCurAttrData(self.data)
		MagicCardUpView.Instance:FlushCurCardAttr()
	end

	local is_active = MagicCardData.Instance:GetCardIsActive(self.index)
	if is_active then
		self.Image.grayscale.GrayScale = 0
	else
		self.Image.grayscale.GrayScale = 255
	end
end

function MaGicCardUpObjView:SetAssetByAsset(asset)
	local str = "Card_"..asset
	self.icon:SetAsset("uis/views/magiccardview", str)
end

-- 物品格子
CardItemUpCellGroup = CardItemUpCellGroup or BaseClass(BaseRender)

function CardItemUpCellGroup:__init()
	self.cells = {
		ItemCell.New(self:FindObj("Item1")),
		ItemCell.New(self:FindObj("Item2")),
		ItemCell.New(self:FindObj("Item3")),
	}
end

function CardItemUpCellGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function CardItemUpCellGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function CardItemUpCellGroup:SetToggleGroup(toggle_group)
	self.cells[1]:SetToggleGroup(toggle_group)
	self.cells[2]:SetToggleGroup(toggle_group)
	self.cells[3]:SetToggleGroup(toggle_group)
end

function CardItemUpCellGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function CardItemUpCellGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function CardItemUpCellGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end

function CardItemUpCellGroup:GetToggleIsOn(i)
	return self.cells[i]:GetToggleIsOn()
end

function CardItemUpCellGroup:GetData(i, is_show)
	return self.cells[i]:GetData()
end