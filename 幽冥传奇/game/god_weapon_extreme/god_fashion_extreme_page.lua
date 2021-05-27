
ExtremeFashionPage = ExtremeFashionPage or BaseClass()


function ExtremeFashionPage:__init()
	
end	

function ExtremeFashionPage:__delete()
	self.view = nil 
	self:RemoveEvent()
	if self.priview_cell then
		self.priview_cell:DeleteMe()
		self.priview_cell = nil 
	end
	if self.soures_cell then
		self.soures_cell:DeleteMe()
		self.soures_cell = nil 
	end
	if self.materials_cell then
		self.materials_cell:DeleteMe()
		self.materials_cell = nil 
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	if self.consume_cells then
		for k,v in pairs(self.consume_cells) do
			v:DeleteMe()
		end
		self.consume_cells = {}
	end
	if self.alert_view then
		self.alert_view:DeleteMe()
		self.alert_view = nil
	end
	if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil 
	end
end	

--初始化页面接口
function ExtremeFashionPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.tabbar_index = 1
	self.equip_index =1
	self:InitEvent()
end	

--初始化事件
function ExtremeFashionPage:InitEvent()
	self:CreateTabbar()
	self:CreateChildList()
	self:CreateCellShow()
	
	XUI.AddClickEventListener(self.view.node_t_list.layout_up_fashion.node, BindTool.Bind(self.UpFashion, self), true)
	self.view.node_t_list.layout_fashion_hook["btn_fashion_nohint_checkbox"].node:addClickEventListener(BindTool.Bind(self.OnClickFashionUse, self))
	self.view.node_t_list.layout_fashion_hook["img_fashion_hook"].node:setVisible(GodWeaponEtremeData.Instance:GetFashionUse() == 1)
	self.view.node_t_list["btn_desc_fashion"].node:addClickEventListener(BindTool.Bind(self.OnOpenFashiondesc, self))
	self.itemdata_change_callback = BindTool.Bind1(self.OnItemChangBack, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_fashion_desc.node, Language.Equipment.UpLevelTips)
	XUI.RichTextSetCenter(self.view.node_t_list.rich_fashion_desc.node)
end

function ExtremeFashionPage:OnOpenFashiondesc()
	DescTip.Instance:SetContent(Language.GodWeapon.FaShionContent, Language.GodWeapon.FaShionTitle)
end

function ExtremeFashionPage:OnClickFashionUse()
	local vis = self.view.node_t_list.layout_fashion_hook["img_fashion_hook"].node:isVisible()
	GodWeaponEtremeData.Instance:SetFashionBoolUse(vis and 0 or 1)
	self.view.node_t_list.layout_fashion_hook["img_fashion_hook"].node:setVisible(not vis)
	self:FlushPreviewData()
end

function ExtremeFashionPage:OnItemChangBack()
	self:FlushData()
	self:FlushRightData()
	self:FlushTabbar()
end

function ExtremeFashionPage:FlushTabbar()
	local name_list = GodWeaponEtremeData.Instance:GetGroupNameData()
	for i=1, #name_list do
		local num = GodWeaponEtremeData.Instance:GetFashionPointByItemId(i)
		self.tabbar:SetRemindByIndex(i, num > 0)
	end
end

function ExtremeFashionPage:UpFashion()
	local  resoures_data = self.soures_cell:GetData() 

	if resoures_data and resoures_data.series then
		local bool = false
		for k, v in pairs(self.consume_cells) do
			local target_data = v:GetData()
			if  GodWeaponEtremeData.Instance:GetBoolHad(target_data.item_id, resoures_data.series) then
				bool = true
				break
			end
		end
		-- local target_data = self.consume_cells[1]:GetData()
		-- local m, n = GodWeaponEtremeData.Instance:GetBoolHad(target_data.item_id, resoures_data.series)
		local bool_use_item = GodWeaponEtremeData.Instance:GetFashionUse()
		if bool then
			if self.alert_view == nil then
				self.alert_view = Alert.New()
			end
			self.alert_view:SetShowCheckBox(false)
			self.alert_view:SetLableString(Language.Equipment.UpTips)
			self.alert_view:Open()
			self.alert_view:SetOkFunc(function ()
				EquipmentCtrl.Instance:SendUpEquip(resoures_data.series, GODWEAPONETREMEDATA_TYPE.FASHION,bool_use_item, 1)
			end)
		else
			EquipmentCtrl.Instance:SendUpEquip(resoures_data.series, GODWEAPONETREMEDATA_TYPE.FASHION, bool_use_item, 0)
		end
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.GodWeapon.UpFashionTip)
	end
end


function ExtremeFashionPage:CreateTabbar()
	if self.tabbar == nil then
		local name_list = GodWeaponEtremeData.Instance:GetGroupNameData()
		self.tabbar = ScrollTabbar.New()
		self.tabbar.space_interval_V = 10
		self.tabbar:SetSpaceInterval(6)
		self.tabbar:CreateWithNameList(self.view.node_t_list.scroll_tabbar.node, 0, -20,
			BindTool.Bind1(self.SelectTabCallback, self), name_list, 
			true, ResPath.GetCommon("btn_106_normal"))
	end
end

function ExtremeFashionPage:SelectTabCallback(index)
	self.tabbar_index = index
	self:FlushData()
	self.equip_name_list:SelectIndex(1)
end


function ExtremeFashionPage:CreateCellShow()
	if self.priview_cell == nil  then
		local ph = self.view.ph_list.ph_eq_cell_1
		self.priview_cell = BaseCell.New()
		self.priview_cell:SetPosition(ph.x -1.8, ph.y +12 )
		self.priview_cell:GetView():setAnchorPoint(0, 0)
		self.priview_cell:SetCellBg(ResPath.GetEquipment("cell_1_bg"))
		self.view.node_t_list.layout_fashion.node:addChild(self.priview_cell:GetView(), 100)
	end
	if self.soures_cell == nil then
		local ph = self.view.ph_list.ph_eq_cell_2
		self.soures_cell = BaseCell.New()
		self.soures_cell:SetPosition(ph.x, ph.y)
		self.soures_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_fashion.node:addChild(self.soures_cell:GetView(), 100)
	end
	if self.materials_cell == nil then
		local ph = self.view.ph_list.ph_eq_cell_3
		self.materials_cell = BaseCell.New()
		self.materials_cell:SetPosition(ph.x, ph.y)
		self.materials_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_fashion.node:addChild(self.materials_cell:GetView(), 100)
	end
	if self.item_cell == nil then
		local ph = self.view.ph_list.ph_eq_cell_4
		self.item_cell = BaseCell.New()
		self.item_cell:SetPosition(ph.x, ph.y)
		self.item_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_fashion.node:addChild(self.item_cell:GetView(), 100)
	end
	self.consume_cells = {}
	for i = 1, 3 do
		local ph = self.view.ph_list["ph_consuem_cell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0, 0)
		cell:SetCellBg(ResPath.GetCommon("cell_100"))
		self.view.node_t_list.layout_fashion.node:addChild(cell:GetView(), 200)
		table.insert(self.consume_cells, cell)
	end
end

--移除事件
function ExtremeFashionPage:RemoveEvent()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	if self.equip_name_list then
		self.equip_name_list:DeleteMe()
		self.equip_name_list = nil
	end
end

function ExtremeFashionPage:CreateChildList()
	if self.equip_name_list == nil then
		local ph = self.view.ph_list.ph_tree_list
		self.equip_name_list = ListView.New()
		self.equip_name_list:Create(ph.x, ph.y, ph.w, ph.h, nil, TreeNameListItem, nil, nil, self.view.ph_list.ph_tree_item)
		self.view.node_t_list["layout_fashion"].node:addChild(self.equip_name_list:GetView(), 888)
		self.equip_name_list:SetMargin(10)
		self.equip_name_list:SetItemsInterval(10)
		self.equip_name_list:SelectIndex(1)
		self.equip_name_list:GetView():setAnchorPoint(0, 0)
		self.equip_name_list:SetJumpDirection(ListView.Top)
		self.equip_name_list:SetSelectCallBack(BindTool.Bind1(self.SelectTreeListCallBack, self))
	end
end

function ExtremeFashionPage:SelectTreeListCallBack(item, index)
	if item == nil or item:GetData() == nil then return end
	self.select_data = item:GetData()
	self:FlushRightData()
end

--更新视图界面
function ExtremeFashionPage:UpdateData(data)
	self.tabbar:SelectIndex(1)
	self:FlushData()
	self.equip_name_list:SelectIndex(1)
	self:FlushRightData()
	self:FlushTabbar()
end	

function ExtremeFashionPage:FlushData()
	local data = GodWeaponEtremeData.Instance:GetChildListDataBy(self.tabbar_index)
	self.equip_name_list:SetDataList(data)
end

function ExtremeFashionPage:FlushRightData()
	local data = GodWeaponEtremeData.Instance:GetChildListDataBy(self.tabbar_index) 
	local select_data = self.select_data or data[self.equip_index]
	if select_data ~= nil then
		local consume_id = select_data.consume_id
		local equip_data = GodWeaponEtremeData.Instance:GetBodyEquipbyItemID(consume_id)
		local soures_data = {}
		local had_consume = 0
		if equip_data ~= nil then
			soures_data = equip_data
			had_consume = 1
		else
			local bag_had_consume = GodWeaponEtremeData.Instance:GetItemDataById(consume_id, true)
			if bag_had_consume == nil then
				soures_data = {item_id = consume_id, num = 1, is_bind = 0}
			else
				soures_data = bag_had_consume.item
			end
			had_consume = ItemData.Instance:GetItemNumInBagById(consume_id, nil)
		end
		local color = COLOR3B.GREEN 
		local txt_5 =  had_consume .. "/" .. 1
		if had_consume >= 1 then
			color = COLOR3B.GREEN 
		else
			color = COLOR3B.RED 
		end
		self.soures_cell:SetData(soures_data)
		self.soures_cell:SetCenterBottomText(txt_5, color)
		local equip_consume = select_data.equipConsumes
		for k, v in pairs(equip_consume) do
			if self.consume_cells[k] ~= nil then
				self.consume_cells[k]:SetData({item_id = v.id, num = 1, is_bind = 0})
				local had_consume = ItemData.Instance:GetItemNumInBagById(v.id, nil)
				local color = COLOR3B.GREEN 
				local txt_4 =  had_consume .. "/" .. v.count
				if had_consume >= v.count then
					color = COLOR3B.GREEN 
				else
					color = COLOR3B.RED 
				end
				self.consume_cells[k]:SetCenterBottomText(txt_4, color)
			end
		end
		local materialConsumes = select_data.materialConsumes
		local count = materialConsumes[1].count
		local id = materialConsumes[1].id
		self.materials_cell:SetData({item_id = id, num = 1, is_bind = 0})
		local had_consume = ItemData.Instance:GetItemNumInBagById(id, nil)
		local color = COLOR3B.GREEN 
		local txt_2 =  had_consume .. "/" .. count
		if had_consume >= count then
			color = COLOR3B.GREEN 
		else
			color = COLOR3B.RED 
		end
		self.materials_cell:SetCenterBottomText(txt_2, color)


		local inheritConsumes = select_data.inheritConsumes
		local in_count = inheritConsumes[1].count
		local in_id = inheritConsumes[1].id
		self.item_cell:SetData({item_id = in_id, num = 1, is_bind = 0})
		local had_consume = ItemData.Instance:GetItemNumInBagById(in_id, nil)
		local color = COLOR3B.GREEN 
		local txt_3 =  had_consume .. "/" .. in_count
		if had_consume >= in_count then
			color = COLOR3B.GREEN 
		else
			color = COLOR3B.RED 
		end
		self.item_cell:SetCenterBottomText(txt_3, color)
		self:FlushPreviewData()
		local my_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		local comsume_circle = 0
		local config = ItemData.Instance:GetItemConfig(select_data.newEquipId)
		for k, v in pairs(config and config.conds or {}) do
			if v.cond == ItemData.UseCondition.ucMinCircle then
				consume_circle = v.value
			end
		end
		XUI.SetLayoutImgsGrey(self.view.node_t_list.layout_up_fashion.node, my_circle < comsume_circle, true)
	end
end

function ExtremeFashionPage:FlushPreviewData()
	local data = self.soures_cell:GetData()
	if data  ~= nil then
		local config = GodWeaponEtremeData.Instance:GetUpConfigIdbuId(data.item_id)
		if config and config.newEquipId then
			local preview_data = {}
			if data.series ~= nil then
				if GodWeaponEtremeData.Instance:GetFashionUse() == 1 then -- 继承属性
					preview_data = {
						item_id = config.newEquipId, strengthen_level = data.strengthen_level,
						infuse_level = data.infuse_level, property_1 = data.property_1,
						property_2 = data.property_2, property_3 = data.property_3,num = 1, is_bind = 0,
						lucky_value = data.lucky_value, property_jipin = 0
					}
				else
					local str_level = data.strengthen_level <= 0 and 0 or data.strengthen_level - 1
					local in_level = data.infuse_level <= 0 and 0 or data.infuse_level - 1
					local lucky = data.lucky_value >= 1 and (data.lucky_value - 1) or data.lucky_value
					preview_data = {
						item_id = config.newEquipId, strengthen_level = str_level ,
						infuse_level = in_level, num = 1, is_bind = 0,
						lucky_value = lucky,
						property_1 = 0, property_2 =0, property_3 = 0,property_jipin = 0,
					}
				end
			else
				preview_data = {
						item_id = config.newEquipId, num = 1, is_bind = 0
					}
			end
			self.priview_cell:SetData(preview_data)
		end
	end
end


TreeNameListItem = TreeNameListItem or BaseClass(BaseRender)
function TreeNameListItem:__init()
	-- body
end

function TreeNameListItem:__delete()
	-- body
end

function TreeNameListItem:CreateChild()
	BaseRender.CreateChild(self)
end

function TreeNameListItem:OnFlush()
	if self.data == nil then return end
	local config = ItemData.Instance:GetItemConfig(self.data.preview_id)
	local txt_1 = string.format(Language.Equipment.BaoShiName, GuideColorCfg[config.bgquality]or"ffffff", config.name)
	RichTextUtil.ParseRichText(self.node_tree.txt_equip_name_2.node, txt_1)
	XUI.RichTextSetCenter(self.node_tree.txt_equip_name_2.node)

	local my_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local consume_circle = 0
	local config = ItemData.Instance:GetItemConfig(self.data.preview_id)
	for k, v in pairs(config and config.conds or {}) do
		if v.cond == ItemData.UseCondition.ucMinCircle then
			consume_circle = v.value
		end
	end
	local num = 0
	if my_circle >= consume_circle then
		num = GodWeaponEtremeData.Instance:GetBoolShowPoint(self.data.consume_id, self.data.equipConsumes, self.data.materialConsumes)
	end
	self.node_tree.flg_fashion_remind.node:setVisible(num > 0)
end