EquipmentUpLvPage = EquipmentUpLvPage or BaseClass()

function EquipmentUpLvPage:__init()
	self.view = nil
end	

function EquipmentUpLvPage:__delete()
	self:RemoveEvent()
	
	self.view = nil
end	

--初始化页面接口
function EquipmentUpLvPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.tabbar_type = 1
	self.index = 1
	self:InitEvent()
end	

function EquipmentUpLvPage:InitEvent()
	self:CreateTabbar()
	self:CreateEquipUpList()
	self:CreateCell()
	self.view.node_t_list.layout_equipment_up.layout_eq_uplevel.btn_clear_cell.node:setLocalZOrder(999)
	self.view.node_t_list.layout_eq_uplevel["btn_upLevel"].node:addClickEventListener(BindTool.Bind(self.UpEquipment, self))
	self.view.node_t_list.layout_eq_uplevel["btn_eq_desc_tip"].node:addClickEventListener(BindTool.Bind(self.OpenUpDesc, self))
	self.view.node_t_list.layout_equipment_up.layout_eq_uplevel.btn_clear_cell.node:addClickEventListener(BindTool.Bind(self.ClearCell, self))
	self.equipmentdata_change_callback = BindTool.Bind1(self.EquipmentDataChangeCallback,self)	--监听装备数据变化
	EquipData.Instance:NotifyDataChangeCallBack(self.equipmentdata_change_callback)
	self.itemdata_change_callback = BindTool.Bind1(self.OnItemChangBack, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	self.hero_equip_data_change_evt = GlobalEventSystem:Bind(HeroDataEvent.HERO_EQUIP_CHANGE,BindTool.Bind1(self.OnHeroEquipDataChange, self))
	self.view.node_t_list.layout_eq_uplevel.layout_equip_hook["btn_equip_nohint_checkbox"].node:addClickEventListener(BindTool.Bind(self.OnClickUseitem, self))
	self.view.node_t_list.layout_eq_uplevel.layout_equip_hook["img_equip_hook"].node:setVisible(EquipmentData.Instance:GetBoolUse() == 1)
	--rich_desc
	RichTextUtil.ParseRichText(self.view.node_t_list.layout_eq_uplevel.rich_desc.node, Language.Equipment.UpLevelTips)
	XUI.RichTextSetCenter(self.view.node_t_list.layout_eq_uplevel.rich_desc.node)

	ClientCommonButtonDic[CommonButtonType.EQUIPBOOST_UPLEVEL_BTN] = self.view.node_t_list.layout_eq_uplevel["btn_upLevel"].node
end

function EquipmentUpLvPage:OnClickUseitem()
	local vis = self.view.node_t_list.layout_eq_uplevel.layout_equip_hook["img_equip_hook"].node:isVisible()
	EquipmentData.Instance:SetBoolUseItem(vis and 0 or 1)	
	self.view.node_t_list.layout_eq_uplevel.layout_equip_hook["img_equip_hook"].node:setVisible(not vis)
	self:FlushPreview()
end

function EquipmentUpLvPage:OnItemChangBack(change_type, item_id, index, series, reason)
	if ItemData.GetIsEquip(item_id) then
		self:FlushData()
		if self.equip_up_list ~= nil then
			self.equip_up_list:SelectIndex(1)
		end
		--self:FlushUplvPoint()
	end
end

function EquipmentUpLvPage:RemoveEvent()
	if self.tabbar ~= nil then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	if self.equip_up_list ~=nil then
		self.equip_up_list:DeleteMe()
		self.equip_up_list = nil 
	end
	if self.priview_cell ~= nil then
		self.priview_cell:DeleteMe()
		self.priview_cell = nil 
	end

	if self.soures_cell ~= nil then
		self.soures_cell:DeleteMe()
		self.soures_cell = nil 
	end

	if self.target_cell ~= nil then
		self.target_cell:DeleteMe()
		self.target_cell = nil 
	end

	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	if self.equipmentdata_change_callback then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equipmentdata_change_callback)
		self.equipmentdata_change_callback = nil 
	end
	if self.hero_equip_data_change_evt then
		GlobalEventSystem:UnBind(self.hero_equip_data_change_evt)
		self.hero_equip_data_change_evt = nil
	end
	if self.alert_view then
		self.alert_view:DeleteMe()
		self.alert_view = nil 
	end
	if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil 
	end

	ClientCommonButtonDic[CommonButtonType.EQUIPBOOST_UPLEVEL_GRID] = nil
	ClientCommonButtonDic[CommonButtonType.EQUIPBOOST_UPLEVEL_BTN] = nil
end

function EquipmentUpLvPage:EquipmentDataChangeCallback()
	self:FlushData()
	--self:FlushUplvPoint()
end

function EquipmentUpLvPage:OnHeroEquipDataChange()
	self:FlushData()
	--self:FlushUplvPoint()
end

function EquipmentUpLvPage:CreateTabbar()
	if self.tabbar == nil then
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.view.node_t_list["layout_equipment_up"].node, 4, 559,
			BindTool.Bind1(self.SelectEquipCallback, self), 
			Language.Equipment.TabGroup_1, false, ResPath.GetCommon("toggle_104_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar:SetSpaceInterval(5)
	end
end

function EquipmentUpLvPage:CreateEquipUpList()
	if nil == self.equip_up_list  then
		local ph = self.view.ph_list.ph_eq_list
		self.equip_up_list = ListView.New()
		self.equip_up_list:Create(ph.x, ph.y, ph.w, ph.h, nil, EquipUpListItem, nil, nil, self.view.ph_list.ph_eq_item)
		self.view.node_t_list["layout_equipment_up"].node:addChild(self.equip_up_list:GetView(), 999)
		self.equip_up_list:SetMargin(5)
		self.equip_up_list:SetItemsInterval(5)
		self.equip_up_list:SelectIndex(1)
		self.equip_up_list:GetView():setAnchorPoint(0, 0)
		self.equip_up_list:SetJumpDirection(ListView.Top)
		self.equip_up_list:SetSelectCallBack(BindTool.Bind1(self.SelectEquipUpListCallBack, self))

		ClientCommonButtonDic[CommonButtonType.EQUIPBOOST_UPLEVEL_GRID] = self.equip_up_list
	end
end

function EquipmentUpLvPage:CreateCell()
	if self.priview_cell == nil  then
		local ph = self.view.ph_list.ph_eq_cell_1
		self.priview_cell = BaseCell.New()
		self.priview_cell:SetPosition(ph.x +8 , ph.y + 12)
		self.priview_cell:GetView():setAnchorPoint(0, 0)
		self.priview_cell:SetCellBg(ResPath.GetEquipment("cell_1_bg"))
		self.view.node_t_list.layout_equipment_up.layout_eq_uplevel.node:addChild(self.priview_cell:GetView(), 100)
	end
	if self.soures_cell == nil then
		local ph = self.view.ph_list.ph_eq_cell_2
		self.soures_cell = BaseCell.New()
		self.soures_cell:SetPosition(ph.x, ph.y)
		self.soures_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_equipment_up.layout_eq_uplevel.node:addChild(self.soures_cell:GetView(), 100)
	end
	if self.target_cell == nil then
		local ph = self.view.ph_list.ph_eq_cell_4
		self.target_cell = BaseCell.New()
		self.target_cell:SetPosition(ph.x, ph.y)
		self.target_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_equipment_up.layout_eq_uplevel.node:addChild(self.target_cell:GetView(), 100)
	end
	if self.item_cell == nil then
		local ph = self.view.ph_list.ph_eq_cell_3
		self.item_cell = BaseCell.New()
		self.item_cell:SetPosition(ph.x, ph.y)
		self.item_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_equipment_up.layout_eq_uplevel.node:addChild(self.item_cell:GetView(), 100)
	end
end

function EquipmentUpLvPage:SelectEquipUpListCallBack(item, index)
	if item == nil or item:GetData() == nil then return end
	self.index = index
	self:FlushListData(item:GetData().item)
end

function EquipmentUpLvPage:SelectEquipCallback(index)
	self.tabbar_type = index
	self:FlushData()
	self.equip_up_list:SelectIndex(1)
end

function EquipmentUpLvPage:OpenUpDesc()
	DescTip.Instance:SetContent(Language.Equipment.UpequipContent, Language.Equipment.UpequipTitle)
end

function EquipmentUpLvPage:UpdateData(data)
	self.tabbar:SelectIndex(1)
	self:FlushData()
	self.equip_up_list:SelectIndex(1)
end

function EquipmentUpLvPage:FlushData()
	local equip_data = {}
	if self.tabbar_type == 1 then
		equip_data = EquipmentData.Instance:GetBodyEquipCanUp()
	elseif self.tabbar_type == 2 then
		equip_data = EquipmentData.Instance:GetBagCanUp()
	elseif self.tabbar_type == 3 then
		equip_data = EquipmentData.Instance:GetHeroEquipUp() or {}
	end
	self:FlushSingleData(equip_data)
	self.equip_up_list:SetDataList(equip_data)
end

function EquipmentUpLvPage:FlushSingleData(equip_data)
	self.select_data = equip_data[self.index] 
	if self.select_data ~= nil then 
		self:FlushListData(self.select_data.item)
	else
		self:ClearCell()
	end
end

function EquipmentUpLvPage:FlushUplvPoint()
	if self.tabbar == nil then return end
	-- local num_1 = EquipmentData.Instance:GetBoolUpByIndex(TabbarIndex.BodyEquip)
	-- local num_2 = EquipmentData.Instance:GetBoolUpByIndex(TabbarIndex.BagEquip)
	-- local num_3 = EquipmentData.Instance:GetBoolUpByIndex(TabbarIndex.HeroEquip)
	self.tabbar:SetRemindByIndex(TabbarIndex.BodyEquip, RemindManager.Instance:GetRemind(RemindName.RoleEquipUp) > 0)
	self.tabbar:SetRemindByIndex(TabbarIndex.BagEquip, RemindManager.Instance:GetRemind(RemindName.BagEquipUp) > 0)
	self.tabbar:SetRemindByIndex(TabbarIndex.HeroEquip, RemindManager.Instance:GetRemind(RemindName.HeroEquipUp) > 0)
end

function EquipmentUpLvPage:FlushListData(select_data)
	if select_data ~= nil then
		self.soures_cell:SetData(select_data)
		local cfg = EquipmentData.GetUpConfigByitemId(select_data.item_id) 
		if cfg ~= nil then
			local consume_data  = {item_id = cfg.equipConsumes[1].id, num = 1, is_bind = 0}
			self.target_cell:SetData(consume_data)
			local had_consume = 0
			if self.tabbar_type == 2 then
				if select_data.item_id ==  consume_data.item_id then --从背包中取出一个了，如果消耗是一样
					had_consume = ItemData.Instance:GetItemNumInBagById(cfg.equipConsumes[1].id, bind_type)
					had_consume = had_consume <= 0 and 0 or had_consume - 1
				else
					had_consume = ItemData.Instance:GetItemNumInBagById(cfg.equipConsumes[1].id, bind_type)
				end
			else
				had_consume = ItemData.Instance:GetItemNumInBagById(cfg.equipConsumes[1].id, bind_type)
			end
			local color = COLOR3B.GREEN 
			local txt_2 =  had_consume .. "/" .. cfg.equipConsumes[1].count
			if had_consume >= cfg.equipConsumes[1].count then
				color = COLOR3B.GREEN 
			else
				color = COLOR3B.RED 
			end
			self.target_cell:SetCenterBottomText(txt_2, color)
			self:FlushPreview()

			local item_data = {item_id = cfg.inheritConsumes[1].id, num = 1, is_bind = 0}
			self.item_cell:SetData(item_data)
			local had_consume_1 = ItemData.Instance:GetItemNumInBagById(cfg.inheritConsumes[1].id, bind_type)
			local color = COLOR3B.GREEN 
			local txt =  had_consume_1 .. "/" .. cfg.inheritConsumes[1].count
			if had_consume_1 >= cfg.inheritConsumes[1].count then
				color = COLOR3B.GREEN 
			else
				color = COLOR3B.RED 
			end
			self.item_cell:SetCenterBottomText(txt, color)

		end
		if self.soures_cell:GetData() == nil then
			self.view.node_t_list.layout_equipment_up.layout_eq_uplevel.btn_clear_cell.node:setVisible(false)
		else
			self.view.node_t_list.layout_equipment_up.layout_eq_uplevel.btn_clear_cell.node:setVisible(true)
		end
	else
		self:ClearCell()
	end
end

function EquipmentUpLvPage:FlushPreview()
	local select_data = self.soures_cell:GetData()
	if select_data ~= nil then
		local cfg = EquipmentData.GetUpConfigByitemId(select_data.item_id) 
		local priview_data = {}
		if cfg ~= nil then
			if EquipmentData.Instance:GetBoolUse() == 1 then
			 	priview_data = {item_id = cfg.newEquipId, num = 1, is_bind = 0, strengthen_level = select_data.strengthen_level, lucky_value = select_data.lucky_value,
					infuse_level = select_data.infuse_level, property_1 = select_data.property_1, property_2 = select_data.property_2, property_3 = select_data.property_3, property_jipin = select_data.property_jipin}	
			else
				local str_level = select_data.strengthen_level <= 0 and 0 or select_data.strengthen_level - 1
				local in_level = select_data.infuse_level <= 0 and 0 or select_data.infuse_level - 1
				local luck  = select_data.lucky_value <= 0 and select_data.lucky_value or select_data.lucky_value - 1
				priview_data = {item_id = cfg.newEquipId, num = 1, is_bind = 0, strengthen_level = str_level, lucky_value = luck,
					infuse_level = in_level, property_1 = 0, property_2 = 0, property_3 = 0, property_jipin = select_data.property_jipin}	
			end
			self.priview_cell:SetData(priview_data)
		end
	end
end

function EquipmentUpLvPage:ClearCell()
	if self.soures_cell:GetData() ~= nil then
		self.soures_cell:ClearData()
	end
	if self.target_cell:GetData() ~= nil then
		self.target_cell:ClearData()
	end
	if self.priview_cell:GetData() ~= nil then
		self.priview_cell:ClearData()
	end
	if self.item_cell:GetData() ~= nil then
		self.item_cell:ClearData()
	end
	self.view.node_t_list.layout_equipment_up.layout_eq_uplevel.btn_clear_cell.node:setVisible(false)
end

function EquipmentUpLvPage:UpEquipment()
	if self.soures_cell:GetData() ~= nil then
		local data = self.soures_cell:GetData()
		local cfg = EquipmentData.GetUpConfigByitemId(data.item_id) 
		local consume_id =  cfg.equipConsumes[1].id
		local target_data = self.target_cell:GetData()
		local bool = GodWeaponEtremeData.Instance:GetBoolHad(target_data.item_id, data.series)
		local bool_use_item = EquipmentData.Instance:GetBoolUse()
		if bool then
			if self.alert_view == nil then
				self.alert_view = Alert.New()
			end
			self.alert_view:SetShowCheckBox(false)
			self.alert_view:SetLableString(Language.Equipment.UpTips)
			self.alert_view:Open()
			self.alert_view:SetOkFunc(function ()
				EquipmentCtrl.Instance:SendUpEquip(data.series, GODWEAPONETREMEDATA_TYPE.COMMON, bool_use_item, 1)
			end)
		else
			EquipmentCtrl.Instance:SendUpEquip(data.series, GODWEAPONETREMEDATA_TYPE.COMMON,bool_use_item, 0)
		end
	end
end

function EquipmentUpLvPage:ClearEquipCell()
	self:ClearCell()
end


EquipUpListItem = EquipUpListItem or BaseClass(BaseRender)
function EquipUpListItem:__init()
	-- body
end

function EquipUpListItem:__delete()
	-- body
end

function EquipUpListItem:CreateChild()
	BaseRender.CreateChild(self)
	if self.equip_cell == nil then
		local ph = self.ph_list.ph_eq_item_cell
		self.equip_cell = BaseCell.New()
		self.equip_cell:SetPosition(ph.x, ph.y)
		self.equip_cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.equip_cell:GetView(), 100)
	end
end

function EquipUpListItem:OnFlush()
	if self.data == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item.item_id)
	self.node_tree["txt_equip_name"].node:setString(item_cfg.name)
	if item_cfg.color ~= nil then
		local color = string.format("%06x", item_cfg.color)
		self.node_tree["txt_equip_name"].node:setColor(Str2C3b(color))
	end
	self.node_tree["txt_level"].node:setString(Language.Equipment.Quanghua.."   ".."+".." "..self.data.item.strengthen_level)
	self.equip_cell:SetData(self.data.item)
end

function EquipUpListItem:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width-50, size.height / 2+10, ResPath.GetCommon("stamp_5"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

function EquipUpListItem:CompareGuideData(data)
	return self.data and self.data.item_id == data
end