EquipmentClearEquipPage = EquipmentClearEquipPage or BaseClass()


function EquipmentClearEquipPage:__init()
	
end	

function EquipmentClearEquipPage:__delete()
	--self:RemoveEvent()
	if self.equip_list then
		self.equip_list:DeleteMe()
		self.equip_list = nil 
	end
	if self.target_cell then
		self.target_cell:DeleteMe()
		self.target_cell = nil 
	end
	if self.tabbar_equip then
		self.tabbar_equip:DeleteMe()
		self.tabbar_equip = nil
	end

	if self.tabbar_select_type then
		self.tabbar_select_type:DeleteMe()
		self.tabbar_select_type = nil 
	end

	if self.priview_cell then
		self.priview_cell:DeleteMe()
		self.priview_cell = nil 
	end

	if self.soures_cell then
		self.soures_cell:DeleteMe()
		self.soures_cell = nil 
	end

	if self.target_cell_zy then
		self.target_cell_zy:DeleteMe()
		self.target_cell_zy = nil 
	end

	if self.alert_window then
		self.alert_window:DeleteMe()
		self.alert_window = nil
	end

	if self.hero_equip_data_change_evt then
		GlobalEventSystem:UnBind(self.hero_equip_data_change_evt)
		self.hero_equip_data_change_evt = nil
	end

	self:RemoveEvent()
end	

--初始化页面接口
function EquipmentClearEquipPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.select_equip_index = 1
	self:CreateLockToggleButton()
	self:InitClearEquipTabbar()
	self:InitBtnTabbar()
	self:CreateClearEquipList()
	self:CreateZyCell()
	self.text_node = RichTextUtil.CreateLinkText("", 20, COLOR3B.WHITE, nil, true)
	self.view.node_t_list.layout_clear["layout_clear_equip"].node:addChild(self.text_node, 999)
	self.text_node:setPosition(285, 86)
	XUI.AddClickEventListener(self.text_node, BindTool.Bind1(self.OpenItemTip, self), true)
	self.select_index = 1
	self.clear_type = 1
	self:CreateCell()
	self:InitEvent()
end	

function EquipmentClearEquipPage:InitClearEquipTabbar()
	if self.tabbar_equip == nil then
		self.tabbar_equip = Tabbar.New()
		self.tabbar_equip:CreateWithNameList(self.view.node_t_list["layout_clear"].node, -48, 556,
			BindTool.Bind1(self.SelectEquipCallback, self), 
			Language.Equipment.TabGroup_1, false, ResPath.GetCommon("toggle_104_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar_equip:SetSpaceInterval(5)
	end
end

function EquipmentClearEquipPage:InitBtnTabbar()
	if self.tabbar_select_type == nil then
		self.tabbar_select_type = Tabbar.New()
		self.tabbar_select_type:CreateWithNameList(self.view.node_t_list["layout_clear"].node, 620, 556,
			BindTool.Bind1(self.SelectEquipTypeCallback, self), 
			Language.Equipment.TabGroup_5, false, ResPath.GetCommon("toggle_104_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar_select_type:SetSpaceInterval(5)
	end
end

function EquipmentClearEquipPage:SelectEquipTypeCallback(type)
	self.clear_type = type
	if self.equip_list ~= nil then
		self.equip_list:CancelSelect()
	end
	self:BoolShowClearLayout()
	self:FlushClearEquipData()
end

function EquipmentClearEquipPage:SelectEquipCallback(index)
	self.select_index = index
	self:FlushBtnState()
	self:FlushClearEquipData()
	self:OnFlushBg()
end

function EquipmentClearEquipPage:BoolShowClearLayout()
	self.view.node_t_list.layout_clear["layout_clear_equip"].node:setVisible(self.clear_type == 1)
	self.view.node_t_list.layout_clear["layout_clear_equip_zy"].node:setVisible(self.clear_type == 2)
end

function EquipmentClearEquipPage:CreateClearEquipList()
	if self.equip_list == nil then
		local ph = self.view.ph_list.ph_clear_list
		self.equip_list = ListView.New()
		self.equip_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ClearEquipListItem, nil, nil, self.view.ph_list.ph_clear_item)
		self.view.node_t_list.layout_clear.node:addChild(self.equip_list:GetView(), 999)
		self.equip_list:SetMargin(5)
		self.equip_list:SetItemsInterval(5)
		self.equip_list:SelectIndex(1)
		self.equip_list:GetView():setAnchorPoint(0, 0)
		self.equip_list:SetJumpDirection(ListView.Top)
		self.equip_list:SetSelectCallBack(BindTool.Bind1(self.SelectClearEquipListCallBack, self))
	end
end

function EquipmentClearEquipPage:SelectClearEquipListCallBack(item, index)
	if self.clear_type == 2 then 
		if item == nil or item:GetData() == nil then return end
		self.zy_equip_data_1 = item:GetData()
		if self.soures_cell:GetData() == nil then
			self.soures_cell:SetData(self.zy_equip_data_1.item)
			self:FlushClearEquipData()
		else
			if item == nil or item:GetData() == nil then return end
			self.zy_equip_data_2 = item:GetData()
			self.target_cell_zy:SetData(self.zy_equip_data_2.item)
			self:FlushClearEquipData()
		end
	else
		if item == nil or item:GetData() == nil then return end
		self:FlushBtnState()
		self:OnFlushBg()
		self.select_equip_index = item:GetIndex()
		self.select_equip_data = item:GetData()
		self:FlushListdata(self.select_equip_data)
	end
end

function EquipmentClearEquipPage:CreateCell()
	if self.target_cell == nil then
		local ph = self.view.ph_list.ph_item_cell
		self.target_cell = BaseCell.New()
		self.target_cell:SetPosition(ph.x, ph.y)
		self.target_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_clear["layout_clear_equip"].node:addChild(self.target_cell:GetView(), 100)
	end
end

function EquipmentClearEquipPage:CreateLockToggleButton()
	self.toggle_list = {}
	for i = 1, 3 do
		local ph = self.view.ph_list["ph_lock_"..i]
		local toggle = XUI.CreateToggleButton(ph.x, ph.y + 20, 50, 47, false, ResPath.GetEquipment("lock_open"), ResPath.GetEquipment("lock_close"), "", true)
		self.view.node_t_list.layout_clear["layout_clear_equip"].node:addChild(toggle, 999)
		XUI.AddClickEventListener(toggle, BindTool.Bind1(self.LockOpen, self), true)
		self.toggle_list[i] = toggle
	end
end

function EquipmentClearEquipPage:LockOpen()
	self:FlushClearEquipData()
	self:OnFlushBg()
end

function EquipmentClearEquipPage:InitEvent()
	self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)			--监听物品数据变化
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	self.equipmentdata_change_callback = BindTool.Bind1(self.EquipmentDataChangeCallback,self)	--监听装备数据变化
	EquipData.Instance:NotifyDataChangeCallBack(self.equipmentdata_change_callback)
	self.view.node_t_list.layout_clear.layout_clear_equip["btn_tips"].node:addClickEventListener(BindTool.Bind(self.OpenDescTip, self))
	self.view.node_t_list.layout_clear.layout_clear_equip["btn_clear_equip"].node:addClickEventListener(BindTool.Bind(self.ClearEquip, self))
	self.view.node_t_list.layout_clear.layout_clear_equip_zy["btn_tip"].node:addClickEventListener(BindTool.Bind(self.OpenZyDescTip, self))
	self.view.node_t_list.layout_clear.layout_clear_equip_zy["btn_zy_clear"].node:addClickEventListener(BindTool.Bind(self.ClearEquipZy, self))
	self.view.node_t_list.layout_clear.layout_clear_equip_zy["btn_qiuchu"].node:addClickEventListener(BindTool.Bind(self.QingChu, self))
	self.view.node_t_list.layout_clear.layout_clear_equip_zy["btn_qiuchu"].node:setVisible(false)
	self.hero_equip_data_change_evt = GlobalEventSystem:Bind(HeroDataEvent.HERO_EQUIP_CHANGE,BindTool.Bind1(self.OnHeroEquipDataChange, self))
end

function EquipmentClearEquipPage:OnHeroEquipDataChange()
	self.view:Flush(TabIndex.equipment_clear_equip)
end

function EquipmentClearEquipPage:UpdateData(data)
	self:BoolShowClearLayout()
	
	local result = EquipmentData.Instance:GetZyClearEquipResult()
	if result == 1 then
		if self.soures_cell:GetData() ~= nil then
			self.soures_cell:ClearData()
		end
		if self.target_cell_zy:GetData() ~= nil then
			self.target_cell_zy:ClearData()
		end
		if self.priview_cell:GetData() ~= nil then
			self.priview_cell:ClearData()
		end
	end
	self:FlushClearEquipData()
	if self.clear_type == 1 then
		if self.select_index == 1 then
			if self.equip_data[1] == nil then 
				local data = EquipmentData.Instance:GetBagClearEquip()
				if data[1] ~= nil then
					self.tabbar_equip:SelectIndex(2)
				end
			end
		end
	end
end

function EquipmentClearEquipPage:RemoveEvent()
	if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil 
	end
	if self.equipmentdata_change_callback then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equipmentdata_change_callback)
		self.equipmentdata_change_callback = nil 
	end
end

function EquipmentClearEquipPage:OpenItemTip()
	if self.select_data and self.select_data.item.item_id then
 		local data = {item_id = 4092, num = 1, is_bind = 0}
 		TipsCtrl.Instance:OpenItem(data, EquipTip.FROM_NORMAL,{not_compare = true})
	end
end

function EquipmentClearEquipPage:ItemDataChangeCallback()
	self.view:Flush(TabIndex.equipment_clear_equip)
end

function EquipmentClearEquipPage:EquipmentDataChangeCallback()
	self.view:Flush(TabIndex.equipment_clear_equip)
end

function EquipmentClearEquipPage:FlushClearEquipData()
	self.equip_data = {}
	self.bag_equip_data = {}
	if self.clear_type == 1 then
		if self.select_index == 1 then
			self.equip_data = EquipmentData.Instance:GetClearEquip()
		elseif self.select_index == 2 then
			self.equip_data = EquipmentData.Instance:GetBagClearEquip()
		elseif self.select_index == 3 then
			self.equip_data = EquipmentData.Instance:GetHeroDataClearEquip()
		end
		self:FlushRightView(self.equip_data)
		self.equip_list:SetDataList(self.equip_data)
		self:OnFlushBg()
	else
		if self.select_index == 1 then
			if self.soures_cell:GetData() == nil then
				self.bag_equip_data = EquipmentData.Instance:HadClearEquip()
				self.equip_list:CancelSelect()
			else
				local data = self.soures_cell:GetData()
				self.bag_equip_data = EquipmentData.Instance:WeiXilianData(data)
				if self.target_cell_zy:GetData() == nil then
					self.equip_list:CancelSelect()
				end
			end
			self.equip_list:SetData(self.bag_equip_data)
			self:FlushItem()
		elseif self.select_index == 2 then
			if self.soures_cell:GetData() == nil then
				self.bag_equip_data = EquipmentData.Instance:HadBagClearEquip()
				self.equip_list:CancelSelect()
			else
				local data = self.soures_cell:GetData()
				self.bag_equip_data = EquipmentData.Instance:GetHadBagClearEquip(data)
				if self.target_cell_zy:GetData() == nil then
					self.equip_list:CancelSelect()
				end
			end
			self.equip_list:SetData(self.bag_equip_data)
			self:FlushItem()
		end
	end
end

function EquipmentClearEquipPage:FlushRightView(data)
	self.select_data = data[self.select_equip_index] 
	if self.select_equip_data ~= nil  and data[self.select_equip_index] ~= nil then
		if self.select_data ~= nil then
			local select_data = data[self.select_equip_index]
			self:FlushListdata(select_data)
		end	
	else
		self.text_node:setVisible(false)
		RichTextUtil.ParseRichText(self.view.node_t_list.txt_consume_count.node, "", 20, COLOR3B.WHITE)
		if self.target_cell:GetData() ~= nil then
			self.target_cell:ClearData()
		end
		RichTextUtil.ParseRichText(self.view.node_t_list["rich_txt_1"].node, "", 20, COLOR3B.WHITE)
		RichTextUtil.ParseRichText(self.view.node_t_list["rich_txt_2"].node, "", 20, COLOR3B.WHITE)
		RichTextUtil.ParseRichText(self.view.node_t_list["rich_txt_3"].node, "", 20, COLOR3B.WHITE)
		self.view.node_t_list.txt_3.node:setString("")
		self.view.node_t_list.txt_2.node:setString("")
		self.view.node_t_list.txt_1.node:setString("")
		self.view.node_t_list["txt_consume_yuanboa"].node:setString("")
	end
end

function EquipmentClearEquipPage:FlushListdata(select_data)
	if select_data ~= nil then
		local cur_data = select_data and select_data.item
		local circle = select_data and select_data.circle
		local level = select_data and select_data.level

		self.target_cell:SetData(cur_data)
		local cfg = ItemData.Instance:GetItemConfig(cur_data.item_id)
		local num = 0
		if cfg ~= nil then
			num = cfg.smithAttrMax
		end
		local bool_data = EquipmentData.Instance:GetEquipBoolCfg(num)
		for i = 1, 3 do
			local content = ""
			local max_value_desc = ""
			local max_value = 0 	
			if bool_data[i] == 1 then
				local cfg = EquipmentData.Instance:GetPropData(select_data and select_data.item["property_"..i])
				local attr_level = EquipmentData.Instance:GetCurLevelByRoleLevelAndCircle(circle, level)
				local color, max_value = EquipmentData.Instance:GetColorCfg(cfg, attr_level)
				if cfg.value > 0 then
					content = string.format(Language.Equipment.ClearEquip_Color, color,RoleData.FormatAttrContent({cfg}))
					self.toggle_list[i]:setVisible(true)
					max_value_desc = string.format(Language.Equipment.MaxValue, max_value or 0)
				else
					content = Language.Equipment.WeiXiLian
					max_value_desc  = ""
					self.toggle_list[i]:setVisible(false)
				end
			else
				content = Language.Equipment.Clear_Condition[i]
				max_value_desc = ""
				self.toggle_list[i]:setVisible(false)
			end
			self.view.node_t_list["txt_"..i].node:setString(max_value_desc)
			RichTextUtil.ParseRichText(self.view.node_t_list["rich_txt_"..i].node, content, 20, COLOR3B.WHITE)
			XUI.RichTextSetCenter(self.view.node_t_list["rich_txt_"..i].node)
		end
		local n = 0
		local m = 0
		for i = 1, 3 do
			local cfg = EquipmentData.Instance:GetPropData(select_data and select_data.item["property_"..i])
			if cfg.value > 0 then
				n = n + 1
			end
			if self.toggle_list[i]:isTogglePressed() then
				m = m + 1
			end
		end
		local comsume_yunbao, consume_count = EquipmentData.Instance:GetEquipConsumeCfg(select_data and select_data.circle, n, m, select_data.level)
		local txt = ""
		if comsume_yunbao == 0 then
			txt = ""
		else
			txt = string.format(Language.Equipment.Gold_Num, comsume_yunbao)
		end
		self.view.node_t_list["txt_consume_yuanboa"].node:setString(txt)
		local consume_id = EquipmentData.Instance:GetConsumeId()
		local count = ItemData.Instance:GetItemNumInBagById(consume_id, nil)
		local cfg = ItemData.Instance:GetItemConfig(consume_id)
		if cfg == nil then
			return 
		end
		self.text_node:setVisible(true)
		local name = cfg.name
		local color = cfg.color
		local txt_2 = string.format(Language.Equipment.Consume, name, consume_count)
		local color = string.format("%06x", cfg.color)
		local color_1 = C3b2Str(Str2C3b(color))
		XUI.RichTextSetCenter(self.view.node_t_list.txt_consume_item.node)
		if self.text_node ~= nil then
			self.text_node:setString(txt_2)
			self.text_node:setColor(COLOR3B.PURPLE2)
		end
		local txt_1 = ""
		local color = "00ff00"
		if count >= consume_count then
			color = "00ff00"
		else
			color = "ff5500"
		end
		local txt_1 = string.format(Language.Equipment.EquipCount_1, color, count)
		RichTextUtil.ParseRichText(self.view.node_t_list.txt_consume_count.node, txt_1, 20, COLOR3B.WHITE)
	end
end

function EquipmentClearEquipPage:FlushBtnState()
	for i = 1, 3 do
		self.toggle_list[i]:setTogglePressed(false)
	end
end

function EquipmentClearEquipPage:OnFlushBg()
	if self.select_data ~= nil and self.select_equip_data ~= nil then
		local cfg = ItemData.Instance:GetItemConfig(self.select_data.item.item_id)
		local num = 0
		if cfg ~= nil then
			num = cfg.smithAttrMax
		end
		--local circle = self.select_data.circle or 3
		local bool_data = EquipmentData.Instance:GetEquipBoolCfg(num)
		for i, v in ipairs(bool_data) do
			local bool = self.toggle_list[i] and self.toggle_list[i]:isTogglePressed()
			if v == 1 then
				if bool == false then
					path = ResPath.GetEquipment("bg_tm_2")
				else
					path = ResPath.GetEquipment("bg_tm_1")
				end
			else
				self.toggle_list[i]:setVisible(false)
				path = ResPath.GetEquipment("bg_tm_1")
			end
			self.view.node_t_list["img_bg_"..i].node:loadTexture(path)
		end
	else
		for i = 1, 3 do
			local path = ResPath.GetEquipment("bg_tm_1")
			self.view.node_t_list["img_bg_"..i].node:loadTexture(path)
			if self.toggle_list[i] ~= nil then
				self.toggle_list[i]:setVisible(false)
			end
		end
	end
end

function EquipmentClearEquipPage:ClearEquip()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	local data = self.target_cell:GetData()
	if data ~= nil then
		local n1 = self.toggle_list[1]:isTogglePressed() == false and 0 or 2
		local n2 = self.toggle_list[2]:isTogglePressed() == false and 0 or 2
		local n3 = self.toggle_list[3]:isTogglePressed() == false and 0 or 2
		EquipmentCtrl.Instance:SendClearEquipReq(data.series, n1, n2, n3)
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function EquipmentClearEquipPage:OpenDescTip()
	DescTip.Instance:SetContent(Language.Equipment.Clear_Equip_content, Language.Equipment.Clear_Equip_Title)
end

function EquipmentClearEquipPage:CreateZyCell()
	local ph = self.view.ph_list.ph_zy_cell_1
	self.priview_cell = BaseCell.New()
	self.priview_cell:SetPosition(ph.x, ph.y)
	self.priview_cell:GetView():setAnchorPoint(0, 0)
	self.view.node_t_list.layout_clear["layout_clear_equip_zy"].node:addChild(self.priview_cell:GetView(), 100)

	local ph = self.view.ph_list.ph_zy_cell_2
	self.soures_cell = BaseCell.New()
	self.soures_cell:SetPosition(ph.x, ph.y)
	self.soures_cell:GetView():setAnchorPoint(0, 0)
	self.view.node_t_list.layout_clear["layout_clear_equip_zy"].node:addChild(self.soures_cell:GetView(), 100)

	local ph = self.view.ph_list.ph_zy_cell_3
	self.target_cell_zy = BaseCell.New()
	self.target_cell_zy:SetPosition(ph.x, ph.y)
	self.target_cell_zy:GetView():setAnchorPoint(0, 0)
	self.view.node_t_list.layout_clear["layout_clear_equip_zy"].node:addChild(self.target_cell_zy:GetView(), 100)
end

function EquipmentClearEquipPage:OpenZyDescTip()
	DescTip.Instance:SetContent(Language.Equipment.Clear_Equip_Zy_content, Language.Equipment.Clear_Equip_Zy_Title)
end

function EquipmentClearEquipPage:ClearEquipZy()
	local soures_data = self.soures_cell:GetData() or {}
	local target_data = self.target_cell_zy:GetData() or {}
	if soures_data ~= nil and target_data ~= nil then
		if target_data.property_1 > 0 then
			if self.alert_view == nil then
				self.alert_window = Alert.New()
			end
			self.alert_window:SetLableString(Language.Equipment.Alert_Desc)
			self.alert_window:Open()
			self.alert_window:SetOkFunc(function ()
				EquipmentCtrl.Instance:SendReqClearEquipZy(soures_data.series, target_data.series)
			end)
		else
			 EquipmentCtrl.Instance:SendReqClearEquipZy(soures_data.series, target_data.series)
		end
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function EquipmentClearEquipPage:FlushItem()
	local select_data = self.soures_cell:GetData()
	if select_data ~= nil then
		self.view.node_t_list["layout_common_bg_1"].node:setVisible(true)
		self.view.node_t_list["icon_bg_2"].node:setVisible(true)
		self.view.node_t_list["btn_qiuchu"].node:setVisible(true)	
		self.view.node_t_list["btn_qiuchu"].node:setLocalZOrder(999)
		--self.soures_cell:SetData(select_data)
		local target_cell_data = self.target_cell_zy:GetData()
		if target_cell_data ~= nil then
			self.priview_cell:SetData(select_data)
		end	
		local consume = EquipmentData.Instance:GetClearZyComsume(select_data)
		local cfg = ItemData.Instance:GetItemConfig(consume and consume.id)
		local had_num = ItemData.Instance:GetItemNumInBagById(consume and consume.id, nil)
		if cfg == nil then return end
		local name = cfg.name
		local txt = string.format(Language.Equipment.Consume, name, consume.count)
		self.view.node_t_list.txt_consume.node:setString(txt)
		local color = "00ff00"
		if had_num >= (consume.count or 1) then
			color = "00ff00"
		else
			color = "ff5500"
		end
		local txt_1 = string.format(Language.Equipment.EquipCount_1, color, had_num)
		RichTextUtil.ParseRichText(self.view.node_t_list.txt_had.node, txt_1, 20, COLOR3B.WHITE)
	else
		self.view.node_t_list["btn_qiuchu"].node:setVisible(false)
		self.view.node_t_list["icon_bg_2"].node:setVisible(false)
		self.view.node_t_list["layout_common_bg_1"].node:setVisible(false)
		self.view.node_t_list.txt_consume.node:setString("")
		RichTextUtil.ParseRichText(self.view.node_t_list.txt_had.node, "")
	end
	local target_cell_data = self.target_cell_zy:GetData()
	local txt = ""
	if select_data == nil and target_cell_data == nil then -- 未放入装备
		txt = Language.Equipment.Desc_1
	elseif select_data ~= nil and target_cell_data == nil then -- 已放入源装备
		txt = Language.Equipment.Desc_2
	else
		txt = " "
	end
	self.view.node_t_list.layout_clear.layout_clear_equip_zy["txt_qingqiu"].node:setString(txt)
end

function EquipmentClearEquipPage:QingChu()
	if self.soures_cell:GetData() ~= nil then
		self.soures_cell:ClearData()
	end
	if self.target_cell_zy:GetData() ~= nil then
		self.target_cell_zy:ClearData()
	end
	if self.priview_cell:GetData() ~= nil then
		self.priview_cell:ClearData()
	end
	self:FlushClearEquipData()
end

ClearEquipListItem = ClearEquipListItem or BaseClass(BaseRender)
function ClearEquipListItem:__init()
	self.equip_cell = nil 
end

function ClearEquipListItem:__delete()
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil 
	end
end

function ClearEquipListItem:CreateChild()
	BaseRender.CreateChild(self)
	if self.equip_cell ~= nil then return end
	local ph = self.ph_list.ph_item_cell
	self.equip_cell = ClearEquipCell.New()
	self.equip_cell:SetPosition(ph.x, ph.y)
	self.equip_cell:GetView():setAnchorPoint(0, 0)
	self.view:addChild(self.equip_cell:GetView(), 100)
end

function ClearEquipListItem:OnFlush()
	if self.data == nil then return end
	if self.data.item.item_id == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item.item_id)
	if item_cfg == nil then
		return
	end
	self.node_tree["txt_equip_name"].node:setString(item_cfg.name)
	local  color = string.format("%06x", item_cfg.color)
	self.node_tree["txt_equip_name"].node:setColor(Str2C3b(color))
	self.equip_cell:SetData(self.data.item)
end

-- 创建选中特效
function ClearEquipListItem:CreateSelectEffect()
	if self.node_tree["img9_bg"] == nil then
		return
	end
	local size = self.node_tree["img9_bg"].node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_120"), true)
	if nil == self.select_effect then
		ErrorLog("InfoListItem:CreateSelectEffect fail")
	end
	self.view:addChild(self.select_effect, 99)
end

ClearEquipCell = ClearEquipCell or BaseClass(BaseCell)
function ClearEquipCell:__init()
end	

function ClearEquipCell:__delete()
end

function ClearEquipCell:InitEvent()
end	

