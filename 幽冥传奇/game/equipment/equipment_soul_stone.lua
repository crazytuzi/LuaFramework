
EquipmentSoulStonePage = EquipmentSoulStonePage or BaseClass()


function EquipmentSoulStonePage:__init()
	self.view = nil
end	

function EquipmentSoulStonePage:__delete()
	self:RemoveEvent()
	self.gem_list = {}
	if self.equip_cell ~= nil then
		for k,v in ipairs(self.equip_cell) do
			v:DeleteMe()
		end
	end
	self.equip_cell = nil

	if self.soul_stone ~= nil then
		for k,v in ipairs(self.soul_stone) do
			v:DeleteMe()
		end
	end

	if self.shop_list ~= nil then
		self.shop_list:DeleteMe()
		self.shop_list = nil 
	end
	self.soul_stone = nil
	self.index = nil
	self.view = nil
end	

--初始化页面接口
function EquipmentSoulStonePage:InitPage(view)
	--绑定要操作的元素

	self.view = view
	self.grid_list = nil
	self.select_index = nil 
	self.select_equip_index = nil 
	self.select_data = nil
	self.shop_list = nil 
	self.cell = nil 
	self:CreateGemIcon()
	self:CreateEquipCells()
	self:CreateSoulStoneCell()
	self:CreateShopItemList()
	self:InitEvent()
end	

function EquipmentSoulStonePage:CreateGemIcon()
	self.gem_list = {}
	local ph = self.view.ph_list.ph_gem_1
	for  i = 1, 5 do
		local file = ResPath.GetCommon("orn_1")	
		local start = XUI.CreateImageView(ph.x + (i - 1) * 41, ph.y + 10, file)
		self.view.node_t_list["layout_soul_stone"].node:addChild(start, 99)	
		self.gem_list[i] = start
	end
end

function EquipmentSoulStonePage:CreateEquipCells()
	self.equip_cell = {}
	for i = 1, 10 do
		local ph = self.view.ph_list["ph_cell_"..i]
		local data = EquipmentData.Instance:GetDiamondData()
		local cur_data = data[i]
		local cell = self:CreateRender(i, ph, cur_data)
		cell:SetIndex(i)

		cell:AddClickEventListener(BindTool.Bind1(self.OnClickSoulStoneCell, self), true)
		table.insert(self.equip_cell, cell)
	end
end

function EquipmentSoulStonePage:CreateRender(i, ph, cur_data)
	local cell = SoulStoneRender.New()
	local render_ph = nil 
	local ph_x = nil 
	if i == 1 or i == 5 or i == 6 or i ==7 or i == 8 then
		render_ph = self.view.ph_list.ph_left_item
		ph_x = ph.x 
	else
		ph_x = ph.x 
		render_ph = self.view.ph_list.ph_right_item
	end
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setPosition(ph_x, ph.y)
	self.view.node_t_list["layout_soul_stone"].node:addChild(cell:GetView(), 101)
	if cur_data then
		cell:SetData(cur_data)
	end
	return cell
end

function EquipmentSoulStonePage:OnClickSoulStoneCell(cell)
	if nil == cell and cell:GetData() ~= nil then return end
	self.select_data  = cell:GetData()
	self.select_equip_index = cell:GetIndex()
	if self.select_data.bool_activate == 1 then
		if not cell or self.index == cell:GetIndex() then
			return
		end
		cell:SetSelect(true)
		if self.index and self.equip_cell[self.index] then
			self.equip_cell[self.index]:SetSelect(false)
		end
		self.index = cell:GetIndex()
		self:SetStoneData()
		self:UpdateRightData()
		self:UpdateLeftData()
		ViewManager.Instance:Close(ViewName.EquipmentSoulStoneTip)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.DescTip)
	end
end

function EquipmentSoulStonePage:CreateSoulStoneCell()
	self.soul_stone = {}
	local data = {}
	for i = 1, 5  do
		local ph = self.view.ph_list["ph_img_"..i]
		data[i] = {id = 0, num = 1, is_bind = 0, index = i, level = 0, bool_open = 0, pos = 0, activate =0}
		local cur_data = data[i]
		local cell = self:CreateStoneRender(ph, cur_data)
		cell:AddClickEventListener(BindTool.Bind1(self.OnClickSoulLongZhuStoneCell, self), true)
		table.insert(self.soul_stone, cell)
	end
end

function EquipmentSoulStonePage:CreateStoneRender(ph, cur_data)
	local cell = SoulStoneLongZhuRender.New()
	local render_ph = self.view.ph_list.ph_render_longzhu
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setPosition(ph.x-20, ph.y - 25)
	self.view.node_t_list["layout_soul_stone"].node:addChild(cell:GetView(), 999)
	if cur_data then
		cell:SetData(cur_data)
	end
	return cell
end

function EquipmentSoulStonePage:OnClickSoulLongZhuStoneCell(cell)
	if nil == cell and cell:GetData() ~= nil then return end
	self.select_data1 = cell:GetData()
	local index = cell:GetIndex()
	self.select_index  = index
	self:SetStoneData()
	self:UpdateLeftData()
	self:UpdateRightData()
	EquipmentCtrl.Instance:OpenView(self.select_data1)
end

function EquipmentSoulStonePage:CreateShopItemList()
	if self.shop_list == nil then
		local ph = self.view.ph_list.ph_shop_item_list
		self.shop_list = ListView.New()
		self.shop_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ShopHunZhuRender, nil, nil, self.view.ph_list.ph_shop_item)
		self.shop_list:GetView():setAnchorPoint(0, 0)
		self.shop_list:SetMargin(2)
		self.shop_list:SetItemsInterval(5)
		self.shop_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list["layout_soul_stone"].node:addChild(self.shop_list:GetView(), 100)
	end
end

--初始化事件
function EquipmentSoulStonePage:InitEvent()
	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
	self.equipmentdata_change_callback = BindTool.Bind1(self.EquipmentDataChangeCallback,self)	--监听装备数据变化
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	EquipData.Instance:NotifyDataChangeCallBack(self.equipmentdata_change_callback)
	self.view.node_t_list["btn_warn_hunshi"].node:addClickEventListener(BindTool.Bind(self.WarnUpTip,self))
	-- XUI.AddClickEventListener(self.view.node_t_list["btn_buy_1"].node, BindTool.Bind2(self.OnClickBuyItem, self, SOUL_STONE_CRYSTAL[1]))
	-- XUI.AddClickEventListener(self.view.node_t_list["btn_buy_2"].node, BindTool.Bind2(self.OnClickBuyItem, self, SOUL_STONE_CRYSTAL[2]))
	self.shop_hunzhu_event = GlobalEventSystem:Bind(ShopEventType.FAST_SHOP_DATA_UPDATE, BindTool.Bind(self.UpdateShop, self))
end

function EquipmentSoulStonePage:WarnUpTip()
	DescTip.Instance:SetContent(Language.Equipment.Desc_Content, Language.Equipment.Title_Name)
end

--移除事件
function EquipmentSoulStonePage:RemoveEvent()
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end
	if self.equipmentdata_change_callback then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equipmentdata_change_callback)
		self.equipmentdata_change_callback = nil 
	end
	if self.shop_hunzhu_event then
		GlobalEventSystem:UnBind(self.shop_hunzhu_event)
		self.shop_hunzhu_event = nil
	end
end

--更新视图界面
function EquipmentSoulStonePage:UpdateData(data)
	self.view.node_t_list["txt_had_soul"].node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_DIAMOND_CRYSTAL))
	self:SetShopData()
	self:SetStoneData()
	self:UpdateLeftData()
	self:UpdateRightData()
end	

--设置数据
function EquipmentSoulStonePage:SetStoneData()
	self.data_list = EquipmentData.Instance:GetDiamondData()
	for i,v in ipairs(self.equip_cell) do
		v:SetData(self.data_list[i])
	end
	local cur_data = {} 
	if self.select_data ~= nil then
		cur_data = self.select_data
	else
		cur_data = self.data_list[1]
	end
	local stone_data = {}
	local bool_open = cur_data.bool_open 
	local slots_pos = cur_data.equipment_slots_pos 
	local bool_activate = cur_data.bool_activate 
	for i, v in ipairs(bool_open) do
		local stone_level = cur_data.diamond_level[i]
		stone_data[i] = {id = 0, num = 1, is_bind = 0, index = i, level = stone_level, bool_open = v, pos = slots_pos, activate = bool_activate}
	end
	for i, v in ipairs(self.soul_stone) do
		v:SetData(stone_data[i])
	end
end

function EquipmentSoulStonePage:UpdateRightData()
	local cur_data = {} 
	if self.select_data ~= nil then
		cur_data = self.select_data
	else 
		cur_data = self.data_list[1]
	end
	local index = self.select_equip_index  or 1
	local pos = cur_data.equipment_slots_pos 
	local name = Language.Equipment.Equip_Name[pos]
	local txt = string.format(Language.Equipment.Name_1, name)
	self.view.node_t_list["txt_equip_name"].node:setString(txt)
	local bool_open = cur_data.bool_open
	local txt = {}
	local txt_shuxing = {}
	local color = {} 
	local n = 0 
	for i, v in ipairs(bool_open) do
		if v > 0 then
			n = n + 1
			local level = cur_data.diamond_level[i]
			local count = EquipmentData.GetSoulStoneCfg(level + 1)  
			txt[i] = string.format(Language.Equipment.Name[i], level)
			local num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_DIAMOND_CRYSTAL)
			color[i] = Str2C3b("ff00ff")
			if level == 0 then --可提升
				txt_shuxing[i] = Language.Equipment.Can_Up
			else
				local attr_cfg = EquipmentData.GetDiamondAttrCfg(i, level)
				local txt = RoleData.FormatAttrContent(attr_cfg)
				txt_shuxing[i] = txt
			end
			self.soul_stone[i]:SetEventEnabled(true)
		elseif v <= 0 then
			txt[i] = Language.Equipment.Name_activate[i]
			color[i] = COLOR3B.GRAY
			if i == 4 then
				txt_shuxing[i] = Language.Equipment.JiHou_1
			elseif i == 5 then
				txt_shuxing[i] = Language.Equipment.JiHou_2
			else
				txt_shuxing[i] = Language.Equipment.No_JiHuo
			end
			self.soul_stone[i]:SetEventEnabled(false)
		end
	end
	self:SetDiamond(n)
	self.view.node_t_list["txt_soul_stone_percent"].node:setString( n > 0 and string.format(Language.Equipment.YongYou, n) or Language.Equipment.No_JiHuo)
	for i,v in ipairs(color) do
		self.view.node_t_list["txt_gem_name_"..i].node:setColor(v)
		self.view.node_t_list["txt_"..i].node:setColor(v)
	end

	for i,v in ipairs(txt) do
		self.view.node_t_list["txt_gem_name_"..i].node:setString(v)
	end

	for i,v in ipairs(txt_shuxing) do
		self.view.node_t_list["txt_"..i].node:setString(v)
	end
end

function EquipmentSoulStonePage:UpdateLeftData()
	local cur_data = nil
	if self.select_data ~= nil then
		cur_data = self.select_data
	else 
		cur_data = self.data_list[1]
	end
	local equip_index = self.select_index  or 1
	local level = cur_data.diamond_level[equip_index]
	self.view.node_t_list["txt_had_soul"].node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_DIAMOND_CRYSTAL))
	self.view.node_t_list["txt_had_soul"].node:setColor(COLOR3B.YELLOW)

end

function EquipmentSoulStonePage:UpdateShop()
	self:SetShopData()
end

function EquipmentSoulStonePage:SetShopData()
	local data = ShopData.Instance:GetShopQuickBuyItem(QuicklyBuyType.Type_8)
	self.shop_list:SetDataList(data)
end

function EquipmentSoulStonePage:SetDiamond(Diamond_count)
	for i, v in ipairs(self.gem_list) do
		if Diamond_count >= i then
			v:loadTexture(ResPath.GetCommon("orn_102"))
		else
			v:loadTexture(ResPath.GetCommon("orn_1"))
		end
	end
end

function EquipmentSoulStonePage:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_DIAMOND_CRYSTAL or key == OBJ_ATTR.CREATURE_LEVEL or key == OBJ_ATTR.ACTOR_CIRCLE then
		self.view:Flush(TabIndex.equipment_soul_stone)
	end
end

function EquipmentSoulStonePage:EquipmentDataChangeCallback()
	self.view:Flush(TabIndex.equipment_soul_stone)
end

-- --购买物品
-- function EquipmentSoulStonePage:OnClickBuyItem(item_id)
-- 	local shop_cfg = ShopData.GetItemPriceCfg(item_id)
-- 	if shop_cfg then
-- 		ShopCtrl.BuyItemFromStore(shop_cfg.id, 1, item_id, 1)
-- 	end
-- end

SoulStoneRender = SoulStoneRender or BaseClass(BaseRender)
function SoulStoneRender:__init()
	--self.cache_select = true
end

function SoulStoneRender:__delete()

end

function SoulStoneRender:CreateChild()
	BaseRender.CreateChild(self)
end

function SoulStoneRender:OnFlush()
	if nil == self.data then return end
	local path = nil 

	if self.data.bool_activate == 1 then
		path = ResPath.GetEquipment("eq_bg_".. self.data.equipment_slots_pos)
	else
		if self.data.equipment_slots_pos < 4 then
			path = ResPath.GetEquipBg("equip_ta_".. self.data.equipment_slots_pos)
		elseif self.data.equipment_slots_pos >= 4 then
			path = ResPath.GetEquipBg("equip_ta_"..(self.data.equipment_slots_pos))
		end
	end
	self.node_tree.img_bg_3.node:loadTexture(path)
	if self.data.bool_activate == 1 then
		local n = 0 
		for k, v in pairs(self.data.diamond_level) do
			n = n + v
		end
		self.node_tree.txt_need_level.node:setString("")
		self.node_tree.txt_my_level.node:setString(n)
		-- self.node_tree.img_bg_6.node:setVisible(false)
	else
		local cfg = EquipmentData.GetActivateLevel((self.data.equipment_slots_pos+1))
		local need_level = cfg.level
		local need_circle = cfg.circle
		local txt = string.format(Language.Equipment.Need_Level,need_circle)
		self.node_tree.txt_need_level.node:setString(txt)
		self.node_tree.txt_my_level.node:setString("")
		-- self.node_tree.img_bg_6.node:setVisible(true)
	end
	 XUI.EnableOutline(self.node_tree.txt_my_level.node)
	 XUI.EnableOutline(self.node_tree.txt_need_level.node)
	self.node_tree.txt_need_level.node:setLocalZOrder(998)
	self.node_tree.txt_my_level.node:setLocalZOrder(999)
end


function SoulStoneRender:CreateSelectEffect()
	local size = self.node_tree.img_bg_3.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width/2 + 5 , size.height/2 + 5, 90, 90, ResPath.GetCommon("img9_173"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 500)
end

SoulStoneLongZhuRender = SoulStoneLongZhuRender or BaseClass(BaseRender)
function SoulStoneLongZhuRender:__init()
	
end

function SoulStoneLongZhuRender:__delete()

end

function SoulStoneLongZhuRender:CreateChild()
	BaseRender.CreateChild(self)
end

function SoulStoneLongZhuRender:OnFlush()
	if nil == self.data then return end
	local path = nil 
	if self.data.bool_open == 0 then
		path = ResPath.GetRole("lockChain")
		self.node_tree.img_up_bg.node:setVisible(false)
		self.node_tree.txt_hunshi_level.node:setString("")
		self.node_tree.img_hunzhu.node:setVisible(false)
	else
		self.node_tree.img_hunzhu.node:setVisible(true)
		local txt = string.format(Language.Equipment.Name_3[self.data.index], self.data.level)
		self.node_tree.txt_hunshi_level.node:setString(txt)
		path = ResPath.GetEquipment("longzhu_"..self.data.index.."_"..self.data.level)
		local had_count = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_DIAMOND_CRYSTAL)
		local count = EquipmentData.GetSoulStoneCfg(self.data.level + 1)
		if count ~= nil then
			if had_count >= count then
				self.node_tree.img_up_bg.node:setVisible(true)
			else
				self.node_tree.img_up_bg.node:setVisible(false)
			end
		else
			self.node_tree.img_up_bg.node:setVisible(false)
		end
	end
	self.node_tree.img_bg.node:loadTexture(path) 
end


ShopHunZhuRender = ShopHunZhuRender or BaseClass(BaseRender)
function ShopHunZhuRender:__init()
	
end

function ShopHunZhuRender:__delete()
	if self.shop_cell ~= nil then
		self.shop_cell:DeleteMe()
		self.shop_cell = nil
	end
end

function ShopHunZhuRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.shop_cell == nil then
		local ph = self.ph_list.ph_shopcell
		self.shop_cell = BaseCell.New()
		self.shop_cell:SetPosition(ph.x, ph.y)
		self.shop_cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.shop_cell:GetView(), 100)
	end
	self.node_tree["btn_buy_1"].node:addClickEventListener(BindTool.Bind(self.BuyItem,self))
end

function ShopHunZhuRender:OnFlush()

	if self.data == nil then
		return
	end
	local data = {item_id = self.data.item_cfg.item, num = 1, is_bind = 1}
	self.shop_cell:SetData(data)
	local price = self.data.item_cfg.price[1].price or 0
	self.node_tree.txt_consume_1.node:setString(price)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_cfg.item)
	if item_cfg == nil then
		return 
	end
	self.node_tree.txt_name_1.node:setString(item_cfg.name)
	local cost_path = ShopData.GetMoneyTypeIcon(self.data.item_cfg.price[1].type)
	self.node_tree.img_cost_bg.node:loadTexture(cost_path)
end

function ShopHunZhuRender:BuyItem()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	ShopCtrl.BuyItemFromStore(self.data.item_cfg.id, 1, self.data.item_cfg.item, 1)
end