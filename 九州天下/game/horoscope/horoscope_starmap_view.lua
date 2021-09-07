--------------------------------------------------------------------------
-- HoroscopeStarMapView 星座星图面板
--------------------------------------------------------------------------
HoroscopeStarMapView = HoroscopeStarMapView or BaseClass(BaseRender)

function HoroscopeStarMapView:__init()
	HoroscopeStarMapView.Instance = self
	self:InitView()
end

function HoroscopeStarMapView:__delete()
	for k, v in pairs(self.icon_cell_list) do
		v:DeleteMe()
	end
	self.icon_cell_list = {}

	for k, v in pairs(self.mid_view_list) do
		v:DeleteMe()
	end
	self.mid_view_list = {}

	if self.need_item then
		self.need_item:DeleteMe()
		self.need_item = nil
	end

	if self.protect_item then
		self.protect_item:DeleteMe()
		self.protect_item = nil
	end

	if self.all_attr then
		self.all_attr:DeleteMe()
		self.all_attr = nil
	end
	self.is_mid_frist = true
	self.is_high_frist = true
end

function HoroscopeStarMapView:InitView()
	self.cur_zodiac = 0
	self.cur_level = 0
	self.is_addclick = false
	self.is_enough = false

	self.suc_rate = self:FindVariable("suc_rate")
	self.hp = self:FindVariable("hp")
	self.atk = self:FindVariable("atk")
	self.def = self:FindVariable("def")
	self.fight = self:FindVariable("fight")
	self.item_num = self:FindVariable("item_num")
	self.protect_num = self:FindVariable("protect_num")
	self.protect_icon = self:FindVariable("protect_icon")
	self.max_level = self:FindVariable("max_level")
	self.is_equip_level = self:FindVariable("is_equip_level")
	self.bt_text = self:FindVariable("bt_text")

	self.Attribute = self:FindObj("Attribute")
	self.AddItemBt = self:FindObj("AddItemBt")

	self:ListenEvent("UpGrade", BindTool.Bind(self.OnUpGrade,self))
	self:ListenEvent("AddItem", BindTool.Bind(self.OnAddItem,self))
	self:ListenEvent("HelpClick", BindTool.Bind(self.OnHelpClick,self))
	self:ListenEvent("AllAttriClick", BindTool.Bind(self.OnAllAttriClick,self))

	self.need_item = ItemCell.New(self:FindObj("need_item"))
	self.protect_item = ItemCell.New(self:FindObj("protect_item"))
	self.all_attr = StarMapAttrView.New(self:FindObj("Attribute"))

	self.icon_cell_list = {}
	self.mid_obj_list = {}
	self.mid_view_list = {}
	for i=1,12 do
		self.mid_obj_list[i] = self:FindObj("starmap"..i)
		self.mid_view_list[i] = MidStarMap.New(self.mid_obj_list[i])
	end

	self:InitListView()
	self:ShowMidByIndex(0)
	self.is_mid_frist = true
	self.is_high_frist = true

	self:SetHide()
	self:FlushRedPoint()
end

function HoroscopeStarMapView:OnHelpClick()
	local tips_id = 83 -- 星图帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function HoroscopeStarMapView:FlushRedPoint()
	for i=1,12 do
		local cur_level = HoroscopeData.Instance:GetXhLevelBySeq(i - 1)
		local need_data = HoroscopeData.Instance:GetDataBySeqAndLevel(i - 1,cur_level)
		local have_num = ItemData.Instance:GetItemNumInBagById(need_data.consume_stuff_id)
		local need_num = need_data.consume_stuff_num
		if have_num >= need_num and cur_level < 12 then
			MoLongView.Instance:HoroscopeStarMapShowRedPoint(true)
			return
		end
	end
	MoLongView.Instance:HoroscopeStarMapShowRedPoint(false)
end

function HoroscopeStarMapView:OnAllAttriClick()
	self:OpenSuitAttr()
end

function HoroscopeStarMapView:OpenSuitAttr()
	local suit_level = HoroscopeData.Instance:GetSuitLevel(true)
	local cur_data = HoroscopeData.Instance:GetSuitAttrByLevel(suit_level)
	local next_data = HoroscopeData.Instance:GetSuitAttrByLevel(HoroscopeData.Instance:GetEquipSuitNextLevel(suit_level))
	TipsCtrl.Instance:ShowTotalAttrView(Language.Horoscope.XinTuTaoZ, suit_level, cur_data, next_data,Language.Horoscope.XinTuLevelGo)
end

function HoroscopeStarMapView:OnUpGrade()
	if self.is_enough then
		if self.is_addclick then
			MoLongCtrl.Instance:SendChineseZodiacPromoteXingHun(self.cur_zodiac,0,1)
		else
			MoLongCtrl.Instance:SendChineseZodiacPromoteXingHun(self.cur_zodiac)
		end
	else
		local need_data = HoroscopeData.Instance:GetDataBySeqAndLevel(self.cur_zodiac,self.cur_level)
		TipsCtrl.Instance:ShowItemGetWayView(need_data.consume_stuff_id)
	end
end

function HoroscopeStarMapView:OnAddItem()
	local item_id = HoroscopeData.Instance:GetProtectItemId()
	local have_num = ItemData.Instance:GetItemNumInBagById(item_id)
	if have_num < 1 then
		local need_data = HoroscopeData.Instance:GetDataBySeqAndLevel(self.cur_zodiac,self.cur_level)
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
	else
		self.is_addclick = not self.is_addclick
		self.protect_item:IsDestroyEffect(true)
		self:ItemCellFlush()
	end
end

function HoroscopeStarMapView:SetHide()
	self.Attribute:SetActive(false)
end

-- 总属性
function HoroscopeStarMapView:ShowAttr(is_show)
	self.Attribute:SetActive(is_show)
end

-- 消耗道具
function HoroscopeStarMapView:ItemCellFlush()
	self.cur_level = HoroscopeData.Instance:GetXhLevelBySeq(self.cur_zodiac)
	local need_data = HoroscopeData.Instance:GetDataBySeqAndLevel(self.cur_zodiac,self.cur_level)
	local need_info = {}
	local protect_info = {}
	if self.cur_level < 12 then
		self.is_equip_level:SetValue(false)
		self.bt_text:SetValue(Language.Common.Up)
	else
		self.is_equip_level:SetValue(true)
		self.bt_text:SetValue(Language.Common.YiManJi)
	end

	need_info.item_id = need_data.consume_stuff_id
	need_info.num = 0
	need_info.is_bind = 0
	local have_num = ItemData.Instance:GetItemNumInBagById(need_info.item_id)
	local need_num = need_data.consume_stuff_num
	if have_num < need_num then
		self.is_enough = false
		self.is_item_enough = false
		self.item_num:SetValue(string.format("%s/%s", ToColorStr(have_num, TEXT_COLOR.RED), need_num))
	else
		self.is_enough = true
		self.is_item_enough = true
		self.item_num:SetValue(string.format("%s/%s", have_num, need_num))
	end

	protect_info.item_id = HoroscopeData.Instance:GetProtectItemId()
	protect_info.num = 0
	protect_info.is_bind = 0
	have_num = ItemData.Instance:GetItemNumInBagById(protect_info.item_id)
	if have_num < 1 then
		self.protect_num:SetValue(string.format("%s", ToColorStr(have_num, TEXT_COLOR.RED)))
		self.AddItemBt:SetActive(true)
		self.protect_item:SetData({})
		self.is_addclick = false
		local str = "plus"
		self.protect_icon:SetAsset("uis/images",str)
	else
		self.protect_num:SetValue(have_num)
		if self.is_addclick then
			self.AddItemBt:SetActive(false)
			self.protect_item:SetData(protect_info)
			self.protect_item:IsDestroyEffect(false)
		else
			self.AddItemBt:SetActive(true)
			local str = "plus"
			self.protect_icon:SetAsset("uis/images",str)
			self.protect_item:SetData({})
		end
	end

	if need_info.item_id == 27009 then
		self.need_item:IsDestroyEffect(true)
	end

	if need_info.item_id == 27010 then
		if self.is_mid_frist then
			self.is_mid_frist = false
			self.need_item:IsDestroyEffect(true)
		end
	else
		self.is_mid_frist = true
	end

	if need_info.item_id == 27011 then
		if self.is_high_frist then
			self.is_high_frist = false
			self.need_item:IsDestroyEffect(true)
		end
	else
		self.is_high_frist = true
	end

	self.need_item:SetData(need_info)

	if need_info.item_id > 27009 then
		self.need_item:IsDestroyEffect(false)
	end
end

function HoroscopeStarMapView:SetZodiac(id)
	self.cur_zodiac = id
end

function HoroscopeStarMapView:GetZodiac()
	return self.cur_zodiac
end

function HoroscopeStarMapView:SetCurLevel(level)
	self.cur_level = level
end

function HoroscopeStarMapView:ShowMidByIndex(index)
	for i=1,12 do
		if (index + 1) == i then
			self.mid_obj_list[i]:SetActive(true)
		else
			self.mid_obj_list[i]:SetActive(false)
		end
	end
end

function HoroscopeStarMapView:FlushRightInfo()
	local data = HoroscopeData.Instance:GetDataBySeqAndLevel(self.cur_zodiac,self.cur_level)

	self.suc_rate:SetValue(data.succ_percent)
	self.hp:SetValue(data.maxhp)
	self.atk:SetValue(data.gongji)
	self.def:SetValue(data.fangyu)

	local attr_list = CommonStruct.Attribute()
	attr_list.max_hp = data.maxhp
	attr_list.gong_ji = data.gongji
	attr_list.fang_yu = data.fangyu
	attr_list.ming_zhong = data.mingzhong
	attr_list.bao_ji = data.baoji
	attr_list.shan_bi = data.shanbi
	attr_list.jian_ren = data.jianren

	local fight = CommonDataManager.GetCapabilityCalculation(attr_list)
	self.fight:SetValue(fight)
end

function HoroscopeStarMapView:FlushInfoView()
	self:FlushRedPoint()
	self.scroller_list_view.scroller:RefreshActiveCellViews()
	self:FlushInfoMid(self.cur_zodiac + 1)
end

-- list_view 逻辑
function HoroscopeStarMapView:InitListView()
	self.scroller_list_view = self:FindObj("icon_list_view")
	local list_delegate = self.scroller_list_view.list_simple_delegate
	-- 有有多少个cell
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- 更新cell
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function HoroscopeStarMapView:GetNumberOfCells()
	return 12
end

function HoroscopeStarMapView:RefreshCell(cell, data_index)
	local icon_cell = self.icon_cell_list[cell]
	if icon_cell == nil then
		icon_cell = StarLeftCell.New(cell.gameObject)
		icon_cell.root_node.toggle.group = self.scroller_list_view.toggle_group
		self.icon_cell_list[cell] = icon_cell
	end
	local data = {}
	data = HoroscopeData.Instance:GetSingDataById(data_index)
	icon_cell:SetIndex(data_index)
	icon_cell:SetData(data)
end

function HoroscopeStarMapView:FlushInfoMid(index)
	self.max_level:SetValue(HoroscopeData.Instance:GetMaxLevelById(index))
	self.mid_view_list[index]:FlushInfo()
	self:ItemCellFlush()
	self:FlushRightInfo()
end
--end

--------------------------------------------------------------------------
-- LeftCell 	左格子
--------------------------------------------------------------------------
StarLeftCell = StarLeftCell or BaseClass(BaseCell)

function StarLeftCell:__init(instance)
	self:IconInit()
end

function StarLeftCell:IconInit()
	self.icon_sprite = self:FindObj("icon_sprite")
	self.icon_select = self:FindObj("icon_select")
	self.name = self:FindVariable("name")
	self.head = self:FindVariable("head")
	self.level = self:FindVariable("level")
	self.show_red_point = self:FindVariable("show_red_point")

	self.icon_level = self:FindObj("icon_level")

	self:ListenEvent("icon_btn_click",BindTool.Bind(self.IconOnClick, self))
end

function StarLeftCell:IconOnClick()
	self.root_node.toggle.isOn = true
	HoroscopeStarMapView.Instance:ShowMidByIndex(self.index)
	HoroscopeStarMapView.Instance:SetZodiac(self.index)
	HoroscopeStarMapView.Instance:FlushInfoMid(self.index + 1)
end

function StarLeftCell:GetIsSelect()
	return self.root_node.toggle.isOn
end

function StarLeftCell:OnFlush()
	if not next(self.data) then return end

	-- 刷新选中特效
	local select_index = HoroscopeStarMapView.Instance:GetZodiac()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end

	self.name:SetValue(self.data.name)
	local str = "Item_"..self.data.item_id
	self.head:SetAsset(ResPath.GetItemIcon(str))

	local level = HoroscopeData.Instance:GetXhLevelBySeq(self.data.seq)
	self.level:SetValue(level)

	self:FlushRedPt()
end

function StarLeftCell:FlushRedPt()
	local cur_level = HoroscopeData.Instance:GetXhLevelBySeq(self.index)
	local need_data = HoroscopeData.Instance:GetDataBySeqAndLevel(self.index,cur_level)
	local have_num = ItemData.Instance:GetItemNumInBagById(need_data.consume_stuff_id)
	local need_num = need_data.consume_stuff_num
	if have_num < need_num and cur_level < 12 then
		self.show_red_point:SetValue(false)
	else
		self.show_red_point:SetValue(true)
	end
end

--------------------------------------------------------------------------
-- MidStarMap 	中星图
--------------------------------------------------------------------------
MidStarMap = MidStarMap or BaseClass(BaseRender)

function MidStarMap:__init(instance)
	self:IconInit()
	self:OnClick(1)
end

function MidStarMap:IconInit()
	self.bt_image_list = {}
	self.is_active_list = {}
	for i=1,12 do
		self.bt_image_list[i] = self:FindVariable("bt_image"..i)
		self:ListenEvent("bt_click_"..i,BindTool.Bind2(self.OnClick, self, i))
		self.is_active_list[i] = self:FindVariable("is_active"..i)
	end
end

function MidStarMap:OnClick(i)
	HoroscopeStarMapView.Instance:SetCurLevel(i)
	HoroscopeStarMapView.Instance:FlushRightInfo()
	HoroscopeStarMapView.Instance:ItemCellFlush()
end

function MidStarMap:FlushInfo()
	local level = HoroscopeData.Instance:GetXhLevelBySeq(HoroscopeStarMapView.Instance:GetZodiac())
	for i=1,level do
		self.is_active_list[i]:SetValue(true)
		self.bt_image_list[i]:SetAsset("uis/views/horoscopeview","horoscope_bt01")
	end

	for i=level + 1,12 do
		self.is_active_list[i]:SetValue(false)
		self.bt_image_list[i]:SetAsset("uis/views/horoscopeview","horoscope_bt02")
	end

end

--------------------------------------------------------------------------
-- StarMapAttrView 	星图属性
--------------------------------------------------------------------------
StarMapAttrView = StarMapAttrView or BaseClass(BaseRender)

function StarMapAttrView:__init(instance)
	self.all_hp = self:FindVariable("all_hp")
	self.all_atk = self:FindVariable("all_atk")
	self.all_def = self:FindVariable("all_def")
	self.all_fight = self:FindVariable("all_fight")
	self.level = self:FindVariable("level")
	self.hp = self:FindVariable("hp")
	self.atk = self:FindVariable("atk")
	self.def = self:FindVariable("def")
	self.fight = self:FindVariable("fight")

	self.attr = self:FindObj("attr")

	self:ListenEvent("closenclick", BindTool.Bind(self.OnClosenClick,self))
end

function StarMapAttrView:OnClosenClick()
	HoroscopeStarMapView.Instance:ShowAttr(false)
end

function StarMapAttrView:FlushInfo()
	local suit_level = HoroscopeData.Instance:GetSuitLevel(false)
	-- if suit_level >= 3 then
		-- self.attr:SetActive(true)
	local data = HoroscopeData.Instance:GetSuitAttrByLevel(suit_level)
	self.level:SetValue(suit_level)
	self.hp:SetValue(data.max_hp)
	self.atk:SetValue(data.gong_ji)
	self.def:SetValue(data.fang_yu)

	local fight = CommonDataManager.GetCapabilityCalculation(data)
	self.fight:SetValue(fight)
	-- else
		-- self.attr:SetActive(false)
	-- end
	local suit_real_data = HoroscopeData.Instance:GetSuitAttrByLevel(HoroscopeData.Instance:GetSuitLevel(true))
	local attr_list = HoroscopeData.Instance:GetAllAttr()
	self.all_hp:SetValue(attr_list.max_hp + suit_real_data.max_hp)
	self.all_atk:SetValue(attr_list.gong_ji + suit_real_data.gong_ji)
	self.all_def:SetValue(attr_list.fang_yu + suit_real_data.fang_yu)

	local all_fight = CommonDataManager.GetCapabilityCalculation(attr_list) + CommonDataManager.GetCapabilityCalculation(suit_real_data)
	self.all_fight:SetValue(all_fight)
end