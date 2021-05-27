
ExtremeWeaponPage = ExtremeWeaponPage or BaseClass()


function ExtremeWeaponPage:__init()
	
end	

function ExtremeWeaponPage:__delete()
	self.view = nil
	self:RemoveEvent()
end	

--初始化页面接口
function ExtremeWeaponPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:InitEvent()
	self:CreateAccrodition()
	self:CreateDispLay()
	self.select_index = 1
	self.btn_index = 1
	self.view.node_t_list.layout_equip_hook["btn_equip_nohint_checkbox"].node:addClickEventListener(BindTool.Bind(self.OnClickUseJiChen, self))
	self.view.node_t_list.layout_equip_hook["img_equip_hook"].node:setVisible(GodWeaponEtremeData.Instance:GetBoolUse() == 1)
	XUI.AddClickEventListener(self.view.node_t_list["layout_btn_up_weapon"].node, BindTool.Bind(self.UpWeapon, self), true)
	self.view.node_t_list["btn_weapon_desc"].node:addClickEventListener(BindTool.Bind(self.OpenWeaponDesc, self))
	self.itemdata_change_callback = BindTool.Bind1(self.OnItemChangBack, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	RichTextUtil.ParseRichText(self.view.node_t_list.layout_godWeapon.rich_weapon_desc.node, Language.Equipment.UpLevelTips2)
	XUI.RichTextSetCenter(self.view.node_t_list.layout_godWeapon.rich_weapon_desc.node)
end	

function ExtremeWeaponPage:OnClickUseJiChen()
	local vis = self.view.node_t_list.layout_equip_hook["img_equip_hook"].node:isVisible()
	GodWeaponEtremeData.Instance:SetWeaponUseItem(vis and 0 or 1)
	self.view.node_t_list.layout_equip_hook["img_equip_hook"].node:setVisible(not vis)
	self:FlushPreviewCell()
end

function ExtremeWeaponPage:OnItemChangBack(change_type, item_id, index, series, reason)
	if GodWeaponEtremeData.Instance:GetBoolFlushTabbarByItemId(item_id, GODWEAPONETREMEDATA_TYPE.WEAPON) then
		self:FlushData()
		self:FlushRightView()
	end
end


function ExtremeWeaponPage:UpWeapon()
	local  resoures_data = self.soures_cell:GetData() 
	if resoures_data and resoures_data.series ~= nil then
		local target_data = self.target_cell:GetData()
		local bool = GodWeaponEtremeData.Instance:GetBoolHad(target_data.item_id, resoures_data.series)
		local bool_use_item = GodWeaponEtremeData.Instance:GetBoolUse()
		if bool then
			if self.alert_view == nil then
				self.alert_view = Alert.New()
			end
			self.alert_view:SetShowCheckBox(false)
			self.alert_view:SetLableString(Language.Equipment.UpTips)
			self.alert_view:Open()
			self.alert_view:SetOkFunc(function ()
				EquipmentCtrl.Instance:SendUpEquip(resoures_data.series, GODWEAPONETREMEDATA_TYPE.WEAPON,bool_use_item, 1)
			end)
		else
			EquipmentCtrl.Instance:SendUpEquip(resoures_data.series, GODWEAPONETREMEDATA_TYPE.WEAPON,bool_use_item, 0)
		end
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.GodWeapon.UpFashionTip)
	end
end

function ExtremeWeaponPage:OpenWeaponDesc()
	DescTip.Instance:SetContent(Language.GodWeapon.Content, Language.GodWeapon.TiTle)
end

function ExtremeWeaponPage:CreateAccrodition()
	if nil == self.tabbar then
		local size = self.view.node_t_list.scroll_tabbar.node:getContentSize()
		self.tabbar = Accordion.New()
		self.tabbar:SetItemsInterval(12)
		self.tabbar:Create(self.view.node_t_list.scroll_tabbar.node, 0, -3, size.width, size.height, AccordionGodWeaponRender, 1, 1)
		self.tabbar:SetTreeItemSelectCallBack(BindTool.Bind(self.SelectTreeNodeCallback, self))
		self.tabbar:SetSelectCallBack(BindTool.Bind(self.SelectChildCallback, self))
		self.tabbar:SetExpandCallBack(BindTool.Bind(self.TreeExpandCallback, self))
		self.tabbar:SetUnExpandCallBack(BindTool.Bind(self.TreeUnExpandCallback, self))
		self.tabbar:SetChildrenInterval(2)
	end
end

function ExtremeWeaponPage:SelectTreeNodeCallback(item)
	if not item or not item:GetData() then return end
	self.btn_index = item:GetData().index
	self.tabbar:SetCurSelectChildIndex(1)
	self:FlushRightView()
end

function ExtremeWeaponPage:SelectChildCallback(item)
	if not item or not item:GetData() then return end
	self.select_data = item:GetData()
	self.select_index = item:GetData().index
	self:FlushRightView()
	--PrintTable(self.select_data)
end

function ExtremeWeaponPage:TreeExpandCallback(item)
	if nil == item or nil == item:GetData() then return end
	item:OnSelectChange(true)
end

function ExtremeWeaponPage:TreeUnExpandCallback(item)
	if nil == item or nil == item:GetData() then return end
	item:OnSelectChange(false)
end

function ExtremeWeaponPage:CreateDispLay()
	if self.current_display == nil then
		self.current_display = ModelAnimate.New(ResPath.GetWuqiBigAnimPath, self.view.node_t_list.current_container.node, GameMath.MDirDown)
		self.current_display:SetAnimPosition(0,0)
		self.current_display:SetFrameInterval(FrameTime.RoleStand)
	end
end


--初始化事件
function ExtremeWeaponPage:InitEvent()
	self:CreateCells()
end

function ExtremeWeaponPage:CreateCells()
	if self.priview_cell == nil  then
		local ph = self.view.ph_list.ph_cell_pre
		self.priview_cell = BaseCell.New()
		self.priview_cell:SetPosition(ph.x -0.5 , ph.y + 12)
		self.priview_cell:GetView():setAnchorPoint(0, 0)
		self.priview_cell:SetCellBg(ResPath.GetEquipment("cell_1_bg"))
		self.view.node_t_list.layout_godWeapon.node:addChild(self.priview_cell:GetView(), 100)
	end
	if self.soures_cell == nil then
		local ph = self.view.ph_list.ph_cell_cos
		self.soures_cell = BaseCell.New()
		self.soures_cell:SetPosition(ph.x, ph.y)
		self.soures_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_godWeapon.node:addChild(self.soures_cell:GetView(), 100)
	end
	if self.target_cell == nil then
		local ph = self.view.ph_list.ph_cell_f
		self.target_cell = BaseCell.New()
		self.target_cell:SetPosition(ph.x, ph.y)
		self.target_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_godWeapon.node:addChild(self.target_cell:GetView(), 100)
	end
	if self.materials_cell == nil then
		local ph = self.view.ph_list.ph_cell_m
		self.materials_cell = BaseCell.New()
		self.materials_cell:SetPosition(ph.x, ph.y)
		self.materials_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_godWeapon.node:addChild(self.materials_cell:GetView(), 100)
	end
	if self.item_cell == nil then
		local ph = self.view.ph_list.ph_cell_i
		self.item_cell = BaseCell.New()
		self.item_cell:SetPosition(ph.x, ph.y)
		self.item_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_godWeapon.node:addChild(self.item_cell:GetView(), 100)
	end
end

function ExtremeWeaponPage:FlushRightView()
	if self.select_data ~= nil then
		local soures_id = self.select_data.item_id 
		local config = ItemData.Instance:GetItemConfig(soures_id)
		if config ~= nil then
			self.current_display:Show(config.shape)
			self.current_display:GetAnimNode():stopAllActions()
			self.current_display:SetAnimPosition(0,0)
			local moveTo = cc.MoveTo:create(0.8, cc.p(0,30))
			local moveTo_back = cc.MoveTo:create(0.8, cc.p(0, 0))
			local move = cc.Sequence:create(moveTo, moveTo_back)
			self.current_display:GetAnimNode():runAction(cc.RepeatForever:create(move))
			local txt_1 = string.format(Language.Equipment.BaoShiName, GuideColorCfg[config.bgquality]or"ffffff", config.name)
			RichTextUtil.ParseRichText(self.view.node_t_list.txt_equip_name.node, txt_1)
			XUI.RichTextSetCenter(self.view.node_t_list.txt_equip_name.node)
		end
		local consume_id = self.select_data.consume_id
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
		local weapon_config = GodWeaponEtremeData.Instance:GetWeaponCfg(consume_id)
		local equipConsumes = weapon_config.equipConsumes
		local count = equipConsumes[1] and equipConsumes[1].count
		local item_id = equipConsumes[1] and equipConsumes[1].id
		self.target_cell:SetData({item_id = item_id, num = 1, is_bind = 0})
		local had_consume = 0
		if equip_data == nil and soures_data.item_id == item_id then
			if soures_data.series ~= nil then
				had_consume = ItemData.Instance:GetItemNumInBagById(item_id, nil) - 1
			else
				had_consume = ItemData.Instance:GetItemNumInBagById(item_id, nil)
			end
		else
			had_consume = ItemData.Instance:GetItemNumInBagById(item_id, nil)
		end
		local color = COLOR3B.GREEN 
		local txt_4 =  had_consume .. "/" .. count
		if had_consume >= count then
			color = COLOR3B.GREEN 
		else
			color = COLOR3B.RED 
		end
		self.target_cell:SetCenterBottomText(txt_4, color)
		local materialConsumes = weapon_config.materialConsumes
		local count = materialConsumes[1].count
		local id = materialConsumes[1].id
		self.materials_cell:SetData({item_id = id, num = 1, is_bind = 0})
		local had_consume_1 = ItemData.Instance:GetItemNumInBagById(id, nil)
		local color = COLOR3B.GREEN 
		local txt_2 =  had_consume_1 .. "/" .. count
		if had_consume_1 >= count then
			color = COLOR3B.GREEN 
		else
			color = COLOR3B.RED 
		end
		self.materials_cell:SetCenterBottomText(txt_2, color)

		local inheritConsumes = weapon_config.inheritConsumes
		local in_count = inheritConsumes[1].count
		local in_id = inheritConsumes[1].id
		self.item_cell:SetData({item_id = in_id, num = 1, is_bind = 0})
		local had_consume_2 = ItemData.Instance:GetItemNumInBagById(in_id, nil)
		local color = COLOR3B.GREEN 
		local txt_3 =  had_consume_2 .. "/" .. in_count
		if had_consume_2 >= in_count then
			color = COLOR3B.GREEN 
		else
			color = COLOR3B.RED 
		end
		self.item_cell:SetCenterBottomText(txt_3, color)

		self:FlushPreviewCell()
		local my_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		local comsume_circle = 0
		local config = ItemData.Instance:GetItemConfig(weapon_config.newEquipId)
		for k, v in pairs(config.conds) do
			if v.cond == ItemData.UseCondition.ucMinCircle then
				consume_circle = v.value
			end
		end
		XUI.SetLayoutImgsGrey(self.view.node_t_list["layout_btn_up_weapon"].node, my_circle < comsume_circle, true)
	end
end

function ExtremeWeaponPage:FlushPreviewCell()
	local data = self.soures_cell:GetData()
	if data  ~= nil then
		local config = GodWeaponEtremeData.Instance:GetWeaponCfg(data.item_id)
		if config and config.newEquipId then
			local preview_data = {}
			if data.series ~= nil then
				if GodWeaponEtremeData.Instance:GetBoolUse() == 1 then -- 继承属性
					preview_data = {
						item_id = config.newEquipId, strengthen_level = data.strengthen_level,
						infuse_level = data.infuse_level, property_1 = data.property_1,
						property_2 = data.property_2, property_3 = data.property_3,num = 1, is_bind = 0,
						lucky_value = data.lucky_value, property_jipin = 0,
					}
				else
					local str_level = data.strengthen_level <= 0 and 0 or data.strengthen_level - 1
					local in_level = data.infuse_level <= 0 and 0 or data.infuse_level - 1
					preview_data = {
						item_id = config.newEquipId, strengthen_level = str_level ,
						infuse_level = in_level, num = 1, is_bind = 0,
						lucky_value = data.lucky_value >= 1 and (data.lucky_value - 1) or data.lucky_value,
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

--移除事件
function ExtremeWeaponPage:RemoveEvent()
	if self.priview_cell ~= nil then
		self.priview_cell:DeleteMe()
		self.priview_cell = nil 
	end
	if self.soures_cell then
		self.soures_cell:DeleteMe()
		self.soures_cell = nil
	end
	if self.target_cell then
		self.target_cell:DeleteMe()
		self.target_cell = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	if self.materials_cell then
		self.materials_cell:DeleteMe()
		self.materials_cell = nil
	end
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil 
	end
	self.current_display:GetAnimNode():stopAllActions()
	if self.current_display then
		self.current_display:DeleteMe()
		self.current_display = nil
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

--更新视图界面
function ExtremeWeaponPage:UpdateData(data)
	local cur_data = GodWeaponEtremeData.Instance:GetAccoridtionData()
	self.tabbar:SetData(cur_data)
	self.btn_index = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	self.tabbar:SetSelectChildIndex(1, self.btn_index, false)
end	

function ExtremeWeaponPage:FlushData()
	local cur_data = GodWeaponEtremeData.Instance:GetAccoridtionData()
	self.tabbar:SetData(cur_data)
	self.tabbar:SetSelectChildIndex(self.select_index, self.btn_index, true)
end

AccordionGodWeaponRender = AccordionGodWeaponRender or BaseClass(AccordionItemRender)
function AccordionGodWeaponRender:__init(w, h, parent_node)
	self.width = parent_node and w - 16 or w
	self.height = 54
	self.img_normal = XUI.CreateImageViewScale9(self.width / 2, self.height / 2, self.width, self.height, ResPath.GetCommon("btn_106_normal"), true)
	self.img_select = XUI.CreateImageViewScale9(self.width / 2, self.height / 2, self.width, self.height, ResPath.GetCommon("btn_106_select"), true)
	self.img_select:setVisible(false)
	self.view:addChild(self.img_normal)
	self.view:addChild(self.img_select)

	self.txt_title = XUI.CreateText(self.width / 2, self.height / 2, w, h, h_alignment, "", font, font_size, COLOR3B.OLIVE, v_alignment)
	self.view:addChild(self.txt_title, 1, 1)
	if nil == self.img_expland then
		self.img_expland = XUI.CreateImageView(20, self.height / 2, ResPath.GetCommon("btn_down_3"))
		self.view:addChild(self.img_expland, 99)
	end
	-- if self:IsChild() then
	self.img_flag = XUI.CreateImageView(self.width - 20, self.height - 20, ResPath.GetMainui("remind_flag"))
	self.view:addChild(self.img_flag)
	self.img_flag:setVisible(false)
	--end
end

function AccordionGodWeaponRender:__delete()
	self.has_changed_img = nil
end

function AccordionGodWeaponRender:CreateChild()
	BaseRender.CreateChild(self)
	self.view:setContentWH(self.width, self.height)
	if self:IsChild() then
		self.img_expland:setVisible(false)
	end
end

-- 刷新
function AccordionGodWeaponRender:OnFlush()
	if not self.data then return end
	-- self.change_to_index = self.data.index
	local str = DelNumByString(self.data.name)

	self.txt_title:setString(str)
	if self.data.child ~= nil then
	end

	if self:IsChild() then
		if self.has_changed_img == nil then
			self.has_changed_img = true
			-- self.img_normal:setVisible(false)
			-- self.img_child_normal:setVisible(true)
			self.img_normal:loadTexture(ResPath.GetCommon("img9_158"))
		end
		local num = GodWeaponEtremeData.Instance:GetBoolShowPoint(self.data.consume_id, self.data.equipConsumes, self.data.materialConsumes)
		self.img_flag:setVisible(num > 0)
	else
		local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		local num = GodWeaponEtremeData.Instance:GetWeaponPointByItemId(self.data.index, circle)
		self.img_flag:setVisible(num > 0)
	end

end

-- 选择状态改变
function AccordionGodWeaponRender:OnSelectChange(is_select)
	if self.img_expland ~= nil then
		local path = ResPath.GetCommon("btn_down_3")
		if is_select then
			path = ResPath.GetCommon("btn_down_4")
		end
		self.img_expland:loadTexture(path)
	end
end

function AccordionGodWeaponRender:CreateSelectEffect()
	if self:IsChild() then
		local height = self:GetHeight()
		self.select_effect = XUI.CreateImageViewScale9(self.width / 2, height / 2, self.width + 15, height + 15, ResPath.GetCommon("select_effect_1"), true, cc.rect(18, 21, 9, 7))
		self.view:addChild(self.select_effect, 200, 200)
	end
end