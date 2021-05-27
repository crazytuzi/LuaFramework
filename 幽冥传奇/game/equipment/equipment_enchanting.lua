EquipmentEnchantingPage = EquipmentEnchantingPage or BaseClass()


function EquipmentEnchantingPage:__init()
	self.view = nil
	self.is_first_login = true
end	

function EquipmentEnchantingPage:__delete()
	if self.equip_cells ~= nil then
		for k,v in ipairs(self.equip_cells) do
			v:DeleteMe()
		end
		self.equip_cells = {}
	end
	if self.fumo_cell ~= nil then
		self.fumo_cell:DeleteMe()
		self.fumo_cell = nil
	end
	self:RemoveEvent()
	self.view = nil
	self.effec = nil
	self.toggle_fumo = nil
end	

--初始化页面接口
function EquipmentEnchantingPage:InitPage(view)
	--绑定要操作的元素

	self.view = view
	self.select_index = 1
	self.consume_item = nil
	if self.toggle_fumo == nil then
		local ph = self.view.ph_list.ph_lock_4
		self.toggle_fumo = XUI.CreateToggleButton(ph.x, ph.y + 20, 50, 47, false, ResPath.GetEquipment("lock_open"), ResPath.GetEquipment("lock_close"), "", true)
		self.view.node_t_list.layout_fumo.node:addChild(self.toggle_fumo, 100)
	end

	local ph = self.view.ph_list.ph_zhanwei
	self.xilian_text_node = RichTextUtil.CreateLinkText("", 20, COLOR3B.WHITE, nil, true)
	self.view.node_t_list.layout_fumo.layout_fumo_consume.node:addChild(self.xilian_text_node, 999)
	self.xilian_text_node:setPosition(ph.x + 20, ph.y + 5)
	XUI.AddClickEventListener(self.xilian_text_node, BindTool.Bind1(self.OpenItemXiLianTip, self), true)

	self:CreateEquipCells()
	self:CreateFumoCells()
	self:InitEvent()
end	

function EquipmentEnchantingPage:CreateEquipCells()
	self.equip_cells = {}
	for i = 0, 9 do
		local ph = self.view.ph_list["ph_equip_cell_"..i]
		local data = EquipmentData.Instance:GetBodyFuMoEquip()
		local cur_data = data[i]
		local cell = self:CreateRender(i, ph, cur_data)
		cell:SetIndex(i)

		cell:AddClickEventListener(BindTool.Bind1(self.OnClickEquipCell, self), true)
		self.equip_cells[i] = cell
	end
end

function EquipmentEnchantingPage:OpenItemXiLianTip()
	if self.consume_item ~= nil then
		local data = {item_id = self.consume_item[1] and self.consume_item[1].id, num = 1, is_bind = 0}
 		TipsCtrl.Instance:OpenItem(data, EquipTip.FROM_NORMAL,{not_compare = true})
	end
end

function EquipmentEnchantingPage:CreateFumoCells()
	if self.fumo_cell == nil then
		local ph = self.view.ph_list.ph_fumo_cell
		self.fumo_cell = BaseCell.New()
		self.fumo_cell:SetPosition(ph.x, ph.y)
		self.fumo_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_fumo.node:addChild(self.fumo_cell:GetView(), 100)
		self.fumo_cell:SetSkinStyle({bg = ResPath.GetEquipment("cell_bg_1")})
	end
end

function EquipmentEnchantingPage:CreateRender(i, ph, cur_data)
	local cell = EnchantingEquipListItem.New()
	local render_ph = nil 
	render_ph = self.view.ph_list.ph_cell
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setPosition(ph.x, ph.y)
	self.view.node_t_list.layout_fumo.node:addChild(cell:GetView(), 101)
	if cur_data then
		cell:SetData(cur_data)
	end
	return cell
end

function EquipmentEnchantingPage:OnClickEquipCell(item, index)
	if item == nil then return end
	self.select_data = item:GetData()
	self.select_index = item:GetIndex()
	if self.select_data ~= nil then
		self.fumo_cell:SetData(self.select_data)
	end
	self.toggle_fumo:setTogglePressed(false)
	self:FlushRightView()
end

function EquipmentEnchantingPage:InitEvent()
	self.view.node_t_list["btn_fumo"].node:addClickEventListener(BindTool.Bind(self.FumoToEquip, self))
	self.view.node_t_list.btn_explain_fumo.node:addClickEventListener(BindTool.Bind(self.OpenDescTip, self))

	self.equipmentdata_change_callback = BindTool.Bind1(self.EquipmentDataChangeCallback,self)	--监听装备数据变化
	EquipData.Instance:NotifyDataChangeCallBack(self.equipmentdata_change_callback)

	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)

	-- self.effec = RenderUnit.CreateEffect(10, self.view.node_t_list.layout_gongming.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
	-- self.effec:setScaleX(2.85)
	-- self.effec:setScaleY(0.8)
	-- self.effec:setPositionX(330)

	self.data_change_fumo = GlobalEventSystem:Bind(EquipmentFumoEventType.FUMOLEVEL_CHANGE,BindTool.Bind(self.OnFumoLevelChange, self))
	-- XUI.AddClickEventListener(self.view.node_t_list.layout_gongming.node, BindTool.Bind(self.OpenUnionView, self), true)
end

function EquipmentEnchantingPage:RemoveEvent()
	if self.equipmentdata_change_callback then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equipmentdata_change_callback)
		self.equipmentdata_change_callback = nil 
	end

	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end

	if self.data_change_fumo then
		GlobalEventSystem:UnBind(self.data_change_fumo)
		self.data_change_fumo = nil
	end	
end

-- function EquipmentEnchantingPage:OpenUnionView()
-- 	self.is_first_login = false
-- 	self.effec:setVisible(self.is_first_login)
-- 	ViewManager.Instance:Open(ViewName.UnionProperty)
-- 	ViewManager.Instance:FlushView(ViewName.UnionProperty, 0, "fumo")
-- end

function EquipmentEnchantingPage:UpdateData(data)
	local data_list = EquipmentData.Instance:GetBodyFuMoEquip()
	for k, v in pairs(self.equip_cells) do
		v:SetData(data_list[k])		
	end
	self:FlushRightView()
end


function EquipmentEnchantingPage:EquipmentDataChangeCallback()
	self.view:Flush(TabIndex.equipment_enchanting)
end

function EquipmentEnchantingPage:RoleDataChangeCallback(key, value, old_value)
	if key == OBJ_ATTR.ACTOR_BIND_COIN or key == OBJ_ATTR.ACTOR_BIND_GOLD or key == OBJ_ATTR.ACTOR_GOLD then
		local num = RoleData.Instance:GetAttr(key)
		local txt_4 = string.format(Language.Equipment.HadNumConsume, num)
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_had_consume.node, txt_4, 20, COLOR3B.GREEN)
	end
end

function EquipmentEnchantingPage:FlushRightView()
	if self.fumo_cell:GetData() ~= nil then
		local data_list = EquipData.Instance:GetDataList()
		local equip = data_list[self.select_index] or {}
		local type_data  = EquipmentData.Instance:GetPropData(equip.fumo_proprty)
		-- 设置cell 背景
		local bg = ResPath.GetEquipment("cell_bg_1")
		if type_data.type == 0 then
			bg = ResPath.GetEquipment("cell_bg_1")
		else
			local bg_type = EquipEnchantPathByType[type_data.type]
			bg = ResPath.GetEquipment("cell_"..bg_type.. "_bg")
		end
		self.fumo_cell:SetSkinStyle({bg = bg})
		--属性显示
		local cur_txt = RoleData.FormatAttrContent({type_data})
		local name = EquipmentData.Instance:GetFuMoPropety(type_data.type)
		local config = ItemData.Instance:GetItemConfig(equip.item_id)
		if config == nil then return end
		local circle = 0
		local level = 0
		for k,v in pairs(config.conds) do
			if v.cond == ItemData.UseCondition.ucLevel then
				level = v.value
			end
			if v.cond == ItemData.UseCondition.ucMinCircle then
				circle = v.value
			end 
		end
		local bool, activite_desc = EquipmentData:GetAtcivateConditionByPropertyType(config.type, type_data.type)
		if type_data.type == 0 then
			RichTextUtil.ParseRichText(self.view.node_t_list["rich_desc"].node, "", 20, COLOR3B.GREEN)
			XUI.RichTextSetCenter(self.view.node_t_list["rich_desc"].node)
		else
			RichTextUtil.ParseRichText(self.view.node_t_list["rich_desc"].node, activite_desc, 20, COLOR3B.GREEN)
			XUI.RichTextSetCenter(self.view.node_t_list["rich_desc"].node)
		end
		if name == nil then
			RichTextUtil.ParseRichText(self.view.node_t_list["rich_fumo_txt"].node, Language.Equipment.WeiFuMo, 20, COLOR3B.GREEN)
			XUI.RichTextSetCenter(self.view.node_t_list["rich_fumo_txt"].node)
		else
			local color = COLOR3B.GREEN
			local color_1 = "878787"
			if bool then
				color = COLOR3B.GREEN
				color_1 = EquipEnchantColorCfg[type_data.type]
			else
				color = COLOR3B.GRAY
				color_1= "878787"
			end
			local txt = string.format(Language.Equipment.Enchanting_proprty, color_1, name, cur_txt)
			RichTextUtil.ParseRichText(self.view.node_t_list["rich_fumo_txt"].node, txt, 20, color)
			XUI.RichTextSetCenter(self.view.node_t_list["rich_fumo_txt"].node)
		end
		--消耗显示
		
		local consume_item, lock_consumes = EquipmentData.Instance:GetFumoConsume(circle, level)
		if consume_item == nil or lock_consumes == nil then return end
		if lock_consumes[1] and lock_consumes[1].id == 0 then
			local num = RoleData.Instance:GetMoneyNumByAWardType(lock_consumes[1] and lock_consumes[1].type)
			local txt_4 = string.format(Language.Equipment.HadNumConsume, num)
			RichTextUtil.ParseRichText(self.view.node_t_list.rich_had_consume.node, txt_4, 20, COLOR3B.GREEN)
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(lock_consumes[1] and lock_consumes[1].type) 
			local cfg = ItemData.Instance:GetItemConfig(virtual_item_id)
			if cfg == nil then return end
			local txt_5 = string.format(Language.Equipment.Consume, cfg.name, lock_consumes[1] and lock_consumes[1].count or 1)
			self.view.node_t_list.txt_consume_gold.node:setString(txt_5)
		end
		self.consume_item = consume_item 
		local count = ItemData.Instance:GetItemNumInBagById(consume_item[1].id, nil)
		local txt_3 = string.format(Language.Equipment.HadNumConsume, count)
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_txt.node, txt_3, 20, COLOR3B.GREEN)
		local cfg = ItemData.Instance:GetItemConfig(consume_item[1].id)
		local name = cfg.name
		local txt_2 = string.format(Language.Equipment.Consume, name, consume_item[1] and consume_item[1].count or 1)
		if self.xilian_text_node ~= nil then
			self.xilian_text_node:setString(txt_2)
			self.xilian_text_node:setColor(COLOR3B.PURPLE2)
		end

		self.view.node_t_list.layout_fumo_consume.node:setVisible(true)
		self.view.node_t_list.layout_lock_consume.node:setVisible(true)
		self.toggle_fumo:setVisible(true)
		self.view.node_t_list.pro_bg_1.node:setVisible(true)
		self.view.node_t_list.prog9_fumo.node:setVisible(true)
		self:FlushFuMoLevelData()
	else
		self.view.node_t_list.layout_fumo_consume.node:setVisible(false)
		self.view.node_t_list.layout_lock_consume.node:setVisible(false)
		self.toggle_fumo:setVisible(false)
		self.view.node_t_list.pro_bg_1.node:setVisible(false)
		self.view.node_t_list.prog9_fumo.node:setVisible(false)
	end
	-- self:BoolActivity()
end

function EquipmentEnchantingPage:FumoToEquip()
	if self.select_data ~= nil then
		if self.consume_item ~= nil then
			local n1 = self.toggle_fumo:isTogglePressed() == false and 0 or 1
			EquipmentCtrl.Instance:FuMoToEquip(self.select_data.series, n1)
		else
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.CanNot_Enchanting)
		end
	end
end

function EquipmentEnchantingPage:OnFumoLevelChange()
	self:FlushFuMoLevelData()
	-- self:BoolActivity()
end

function EquipmentEnchantingPage:FlushFuMoLevelData( )
	local level, cur_exp = EquipmentData.Instance:GetFumoInfoData()
	local max_exp = EquipmentData.Instance:GetConfigExp(level + 1)
	local txt = ""
	if max_exp == 0 or max_exp == nil then
		self.view.node_t_list.prog9_fumo.node:setPercent(1/1*100)
		txt = Language.Equipment.Enchanting_Level_Max
	else
		txt = cur_exp .. "/" .. max_exp
		self.view.node_t_list.prog9_fumo.node:setPercent(cur_exp/max_exp*100)
	end
	self.view.node_t_list.txt_percent.node:setString(txt)
	self.view.node_t_list.txt_level_fumo.node:setString(string.format(Language.Equipment.Enchanting_Level,level))
end

-- function EquipmentEnchantingPage:BoolActivity()
-- 	local num = EquipmentData.Instance:GetBoolGongMingActive()
-- 	local path = ResPath.GetCommon("img9_202")
-- 	local bg_path = ResPath.GetCommon("stamp_33")
-- 	if num > 0 then
-- 		path = ResPath.GetCommon("img9_203")
-- 		bg_path = ResPath.GetCommon("stamp_32")	
-- 	end
-- 	self.view.node_t_list.layout_gongming.img9_open.node:loadTexture(path)
-- 	self.view.node_t_list.layout_gongming.img_txt.node:loadTexture(bg_path)
-- end

function EquipmentEnchantingPage:OpenDescTip()
	DescTip.Instance:SetContent(Language.Equipment.Enchanting_Content, Language.Equipment.Enchanting_Title)
end

EnchantingEquipListItem = EnchantingEquipListItem or BaseClass(BaseRender)
function EnchantingEquipListItem:__init()
	self.equip_cell = nil 
end

function EnchantingEquipListItem:__delete()
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil 
	end
end

function EnchantingEquipListItem:CreateChild()
	BaseRender.CreateChild(self)
	if self.equip_cell == nil then
		local ph = self.ph_list.ph_item_cell
		self.equip_cell = EnchantingEquipCell.New()
		self.equip_cell:SetPosition(ph.x, ph.y)
		self.equip_cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.equip_cell:GetView(), 100)
	end

end

function EnchantingEquipListItem:OnFlush()
	if self.data == nil then
		self.equip_cell:SetSkinStyle({bg = ResPath.GetEquipment("cell_bg_1") , bg_ta = ResPath.GetEquipBg("equip_ta_".. self.index), cell_desc = nil})
	end
	if self.data ~= nil then
		self.equip_cell:SetData(self.data)
		local type_data = EquipmentData.Instance:GetPropData(self.data.fumo_proprty)
		local bg = ResPath.GetEquipment("cell_bg_1")
		if type_data.type == 0 then
			bg = ResPath.GetEquipment("cell_bg_1")
		else
			local bg_type = EquipEnchantPathByType[type_data.type]
			bg = ResPath.GetEquipment("cell_"..bg_type.. "_bg")
		end
		self.equip_cell:SetSkinStyle({bg = bg})
	end
end


EnchantingEquipCell = EnchantingEquipCell or BaseClass(BaseCell)
function EnchantingEquipCell:__init()
end	

function EnchantingEquipCell:__delete()
end

function EnchantingEquipCell:InitEvent()
end	

function EnchantingEquipCell:OnClick()

end