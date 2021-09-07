--------------------------------------------------------------------------
-- HoroscopeEquipView 星座装备面板
--------------------------------------------------------------------------
HoroscopeEquipView = HoroscopeEquipView or BaseClass(BaseRender)

function HoroscopeEquipView:__init()
	HoroscopeEquipView.Instance = self
	self:InitView()
end

function HoroscopeEquipView:__delete()
	for k, v in pairs(self.icon_cell_list) do
		v:DeleteMe()
	end
	self.icon_cell_list = {}

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
end

function HoroscopeEquipView:InitView()
	self.icon_cell_list = {}
	self.cur_zodiac = 0
	self.cur_equip = 0

	self.hp = self:FindVariable("hp")
	self.atk = self:FindVariable("atk")
	self.def = self:FindVariable("def")
	self.fight = self:FindVariable("fight")
	self.number = self:FindVariable("number")
	self.is_equip_max = self:FindVariable("is_equip_max")
	self.bt_text = self:FindVariable("bt_text")
	self.add_hp = self:FindVariable("add_hp")
	self.add_atk = self:FindVariable("add_atk")
	self.add_def = self:FindVariable("add_def")

	self.all_hp = self:FindVariable("all_hp")
	self.all_atk = self:FindVariable("all_atk")
	self.all_def = self:FindVariable("all_def")
	self.all_fight = self:FindVariable("all_fight")
	self.is_open_allattr = self:FindVariable("is_open_allattr")

	self:ListenEvent("UpGrade", BindTool.Bind(self.OnUpGrade,self))
	self:ListenEvent("AllAttrClick", BindTool.Bind(self.OnAllAttrClick,self))
	self:ListenEvent("ClosenAttr", BindTool.Bind(self.OnClosenAttr,self))

	-- 获取控件
	self.role_display = self:FindObj("RoleDisplay")

	self.role_model = RoleModel.New()

	self.is_open_allattr:SetValue(false)
	self:InitListView()
	self:InitEquipCell()
	self:FlushRedPoint()
	self.item_cell = ItemCell.New(self:FindObj("item_cell"))
	-- self:EquipOnClick(1)
end

function HoroscopeEquipView:FlushRedPoint()
	local show_pt = false
	for j=1,12 do
		for i=1,8 do
			local zodiac_level = HoroscopeData.Instance:GetXzLevelBySeq(j-1)
			local level = HoroscopeData.Instance:GetEquipLevelBySeqAndType(j-1,i - 1)
			local equip_data = HoroscopeData.Instance:GetEquipDataByIndex(i - 1,level)
			local have_num = ItemData.Instance:GetItemNumInBagById(equip_data.consume_stuff_id)
			if have_num >= 1 and zodiac_level > 0 and level < 50 then
				show_pt = true
				MoLongView.Instance:HoroscopeEquipShowRedPoint(show_pt)
				return
			end
		end
	end
	MoLongView.Instance:HoroscopeEquipShowRedPoint(show_pt)
end

function HoroscopeEquipView:SetRoleData()
	local main_role = Scene.Instance:GetMainRole()
	self.role_model:SetDisplay(self.role_display.ui3d_display)
	self.role_model:SetRoleResid(main_role:GetRoleResId())
	self.role_model:SetWeaponResid(main_role:GetWeaponResId())
	self.role_model:SetWeapon2Resid(main_role:GetWeapon2ResId())
	self.role_model:SetWingResid(main_role:GetWingResId())
	self.role_model:SetHaloResid(main_role:GetHaloResId())
end

function HoroscopeEquipView:OnClosenAttr()
	self.is_open_allattr:SetValue(false)
end

function HoroscopeEquipView:OnAllAttrClick()
	self.is_open_allattr:SetValue(true)
	self:FlushAllAttr()
end

function HoroscopeEquipView:FlushAllAttr()
	local all_data = HoroscopeData.Instance:GetXzAllEquipAttr()
	local attr = {}
	attr = CommonStruct.Attribute()
	attr.max_hp = all_data.maxhp
	attr.gong_ji = all_data.gongji
	attr.fang_yu = all_data.fangyu
	attr.ming_zhong = all_data.mingzhong
	attr.shan_bi = all_data.shanbi
	attr.bao_ji = all_data.baoji
	attr.jian_ren = all_data.jianren
	local fight = CommonDataManager.GetCapabilityCalculation(attr,true)

	self.all_fight:SetValue(fight)
	self.all_hp:SetValue(all_data.maxhp)
	self.all_atk:SetValue(all_data.gongji)
	self.all_def:SetValue(all_data.fangyu)
end

function HoroscopeEquipView:OnUpGrade()
	local level = HoroscopeData.Instance:GetEquipLevelBySeqAndType(self.cur_zodiac,self.cur_equip)
	local equip_data = HoroscopeData.Instance:GetEquipDataByIndex(self.cur_equip,level)
	local have_num = ItemData.Instance:GetItemNumInBagById(equip_data.consume_stuff_id)

	if have_num >= 1 then
		MoLongCtrl.Instance:SendChineseZodiacPromoteEquip(self.cur_zodiac,self.cur_equip)
	else
		TipsCtrl.Instance:ShowItemGetWayView(equip_data.consume_stuff_id)
	end
end

function HoroscopeEquipView:SetZodiac(id)
	self.cur_zodiac = id
end

function HoroscopeEquipView:GetZodiac()
	return self.cur_zodiac
end

-- 右边
function HoroscopeEquipView:FlushRightAttr(data, add_data)
	self.hp:SetValue(data.maxhp)
	self.atk:SetValue(data.gongji)
	self.def:SetValue(data.fangyu)

	self.add_hp:SetValue(add_data.maxhp)
	self.add_atk:SetValue(add_data.gongji)
	self.add_def:SetValue(add_data.fangyu)

	local attr = {}
	attr = CommonStruct.Attribute()
	attr.max_hp = data.maxhp
	attr.gong_ji = data.gongji
	attr.fang_yu = data.fangyu
	attr.ming_zhong = data.mingzhong
	attr.shan_bi = data.shanbi
	attr.bao_ji = data.baoji
	attr.jian_ren = data.jianren

	local fight = CommonDataManager.GetCapabilityCalculation(attr,true)
	self.fight:SetValue(fight)
end

-- 消耗道具
function HoroscopeEquipView:ItemCellFlush(data)
	local item_data = {}

	item_data.item_id = data.consume_stuff_id
	item_data.num = 0
	item_data.is_bind = 0
	local have_num = ItemData.Instance:GetItemNumInBagById(item_data.item_id)
	if have_num < 1 then
		self.number:SetValue(string.format("%s",ToColorStr(have_num, TEXT_COLOR.RED)))
	else
		self.number:SetValue(have_num)
	end
	self.item_cell:SetData(item_data)
end

-- 装备格子
function HoroscopeEquipView:InitEquipCell()
	self.equip_list = {}
	self.variable_table_list = {}
	self.event_table_list = {}
	self.icon_list = {}
	self.gray_list = {}
	self.level_list = {}
	self.is_active_list = {}
	self.red_pt_list = {}
	self.quality_list = {}
	self.effect_list = {}

	for i=1,8 do
		self.equip_list[i] = self:FindObj("item"..i)
		self.variable_table_list[i] = self.equip_list[i]:GetComponent(typeof(UIVariableTable))
		self.event_table_list[i] = self.equip_list[i]:GetComponent(typeof(UIEventTable))

		self.icon_list[i] = self.variable_table_list[i]:FindVariable("Icon")
		self.gray_list[i] = self.variable_table_list[i]:FindVariable("is_gray")
		self.level_list[i] = self.variable_table_list[i]:FindVariable("level")
		self.is_active_list[i] = self.variable_table_list[i]:FindVariable("is_active")
		self.red_pt_list[i] = self.variable_table_list[i]:FindVariable("ShowRedPoint")
		self.quality_list[i] = self.variable_table_list[i]:FindVariable("Quality")
		self.effect_list[i] = self.variable_table_list[i]:FindVariable("effect")

		self.event_table_list[i]:ListenEvent("Click", BindTool.Bind2(self.EquipOnClick, self, i))
	end

	self.equip_list[1].toggle.isOn = true
end

function HoroscopeEquipView:EquipOnClick(i)
	self.equip_list[i].toggle.isOn = true
	self.cur_equip = i - 1
	local level = HoroscopeData.Instance:GetEquipLevelBySeqAndType(self.cur_zodiac,i - 1)
	local equip_data = HoroscopeData.Instance:GetEquipDataByIndex(i - 1,level)
	local add_data = HoroscopeData.Instance:GetEquipDataByIndex(i - 1,level,true)

	if level >= 50 then
		self.is_equip_max:SetValue(true)
		self.bt_text:SetValue(Language.Common.YiManJi)
	else
		self.is_equip_max:SetValue(false)
		self.bt_text:SetValue(Language.Common.Up)
		self:ItemCellFlush(equip_data)
	end
	self:FlushRightAttr(equip_data, add_data)
end

function HoroscopeEquipView:FlushEquipInfo()
	local equip_data = {}
	for i=1,8 do
		local level = HoroscopeData.Instance:GetEquipLevelBySeqAndType(self.cur_zodiac,i - 1)
		equip_data = HoroscopeData.Instance:GetEquipDataByIndex(i - 1,level)
		local str = "Item_"..equip_data.consume_stuff_id
		self.icon_list[i]:SetAsset(ResPath.GetItemIcon(str))
		self.level_list[i]:SetValue(level)
		if level > 0 then
			self.gray_list[i]:SetValue(false)
			self.is_active_list[i]:SetValue(true)
			local id = 1
			local quality_path = "uis/images"
			local quality_res = "bg_mirror_green"
			if level > 0 and level <= 5 then
				quality_res = "bg_mirror_green"
				id = 1
			elseif level > 5 and level <= 10 then
				quality_res = "bg_mirror_blue"
				id = 2
			elseif level > 10 and level <= 15 then
				quality_res = "bg_mirror_purple"
				id = 3
			elseif level > 15 and level <= 20 then
				quality_res = "bg_mirror_orange"
				id = 4
			else
				quality_res = "bg_mirror_red"
				id = 5
			end
			self.quality_list[i]:SetAsset(quality_path,quality_res)
			local path, res = ResPath.GetItemEffect(id)
			self.effect_list[i]:SetAsset(path,res)
		else
			self.quality_list[i]:SetAsset("","")
			self.effect_list[i]:SetAsset("","")
			self.is_active_list[i]:SetValue(false)
			self.gray_list[i]:SetValue(true)
		end

		local zodiac_level = HoroscopeData.Instance:GetXzLevelBySeq(self.cur_zodiac)
		local have_num = ItemData.Instance:GetItemNumInBagById(equip_data.consume_stuff_id)
		if have_num >= 1 and zodiac_level > 0 and level < 50 then
			self.red_pt_list[i]:SetValue(true)
		else
			self.red_pt_list[i]:SetValue(false)
		end
	end
end
-- end

function HoroscopeEquipView:FlushInfoView()
	self:FlushRedPoint()
	self:FlushEquipInfo()
	self:EquipOnClick(self.cur_equip + 1)
	self.scroller_list_view.scroller:RefreshActiveCellViews()
end

-- list_view 逻辑
function HoroscopeEquipView:InitListView()
	self.scroller_list_view = self:FindObj("icon_list_view")
	local list_delegate = self.scroller_list_view.list_simple_delegate
	-- 有有多少个cell
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	-- 更新cell
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function HoroscopeEquipView:GetNumberOfCells()
	return 12
end

function HoroscopeEquipView:RefreshCell(cell, data_index)
	local icon_cell = self.icon_cell_list[cell]
	if icon_cell == nil then
		icon_cell = HoroscopeLeftCell.New(cell.gameObject)
		icon_cell.root_node.toggle.group = self.scroller_list_view.toggle_group
		self.icon_cell_list[cell] = icon_cell
	end
	local data = {}
	data = HoroscopeData.Instance:GetSingDataById(data_index)
	icon_cell:SetIndex(data_index)
	icon_cell:SetData(data)
end

function HoroscopeEquipView:FlushInfo()

end
--end

--------------------------------------------------------------------------
-- HoroscopeLeftCell 	左格子
--------------------------------------------------------------------------
HoroscopeLeftCell = HoroscopeLeftCell or BaseClass(BaseCell)

function HoroscopeLeftCell:__init(instance)
	self:IconInit()
end

function HoroscopeLeftCell:IconInit()
	self.icon_sprite = self:FindObj("icon_sprite")
	self.icon_select = self:FindObj("icon_select")
	self.name = self:FindVariable("name")
	self.head = self:FindVariable("head")
	self.show_red_point = self:FindVariable("show_red_point")
	self.is_gray = self:FindVariable("is_gray")

	self.icon_level = self:FindObj("icon_level")

	self:ListenEvent("icon_btn_click",BindTool.Bind(self.IconOnClick, self))
	self.icon_level:SetActive(false)
end

function HoroscopeLeftCell:IconOnClick()
	self.root_node.toggle.isOn = true
	HoroscopeEquipView.Instance:SetZodiac(self.index)
	HoroscopeEquipView.Instance:EquipOnClick(1)
	HoroscopeEquipView.Instance:FlushEquipInfo()
end

function HoroscopeLeftCell:GetIsSelect()
	return self.root_node.toggle.isOn
end

function HoroscopeLeftCell:OnFlush()
	if not next(self.data) then return end

	-- 刷新选中特效
	local select_index = HoroscopeEquipView.Instance:GetZodiac()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end

	local level = HoroscopeData.Instance:GetXzLevelBySeq(self.data.seq)
	if level > 0 then
		self:FlushRedPt()
		self.is_gray:SetValue(false)
	else
		self.is_gray:SetValue(true)
	end
	self.name:SetValue(self.data.name)
	local str = "Item_"..self.data.item_id
	self.head:SetAsset(ResPath.GetItemIcon(str))
end

function HoroscopeLeftCell:FlushRedPt()
	local show_pt = false
	for i=1,8 do
		local level = HoroscopeData.Instance:GetEquipLevelBySeqAndType(self.index,i - 1)
		local equip_data = HoroscopeData.Instance:GetEquipDataByIndex(i - 1,level)
		local have_num = ItemData.Instance:GetItemNumInBagById(equip_data.consume_stuff_id)

		if have_num >= 1 and level < 50 then
			show_pt = true
			break
		end
	end
	self.show_red_point:SetValue(show_pt)
end