
EquipmentQianghuaPage = EquipmentQianghuaPage or BaseClass()


function EquipmentQianghuaPage:__init()
	self.view = nil
end	

function EquipmentQianghuaPage:__delete()
	self:RemoveEvent()
	if self.tabbar_list then
		self.tabbar_list:DeleteMe()
		self.tabbar_list = nil 
	end

	if self.tabbar_equip then
		self.tabbar_equip:DeleteMe()
		self.tabbar_equip = nil 
	end

	if self.equip_list then
		self.equip_list:DeleteMe()
		self.equip_list = nil 
	end

	if self.qianghua_cell then
		self.qianghua_cell:DeleteMe()
		self.qianghua_cell = nil 
	end

	if self.priview_cell then
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

	if self.alert_equipment_view then
		self.alert_equipment_view:DeleteMe()
		self.alert_equipment_view = nil 
	end

	if self.play_effect ~= nil then
		self.play_effect:setStop()
		self.play_effect = nil 
	end

	if self.number_rade ~= nil then
		self.number_rade:DeleteMe()
		self.number_rade = nil
	end
	
	self.view = nil
end	

--初始化页面接口
function EquipmentQianghuaPage:InitPage(view)
	--绑定要操作的元素

	self.view = view
	self.qianghua_type = 1
	self.equip_index = 1
	self.bag_equip_index = 1
	self.equip_select_index = nil 
	self.alert_equipment_view = nil 
	self.equip_data = {}
	self.select_data = nil
	self:InitBar()
	self:CreateStar()
	self:CreateEquipList()
	self:CreateCell()
	self:CrateZyCellList()
	self:InitEquipTabbar()
	self:CreateTip()
	self:InitEvent()
end	

function EquipmentQianghuaPage:InitBar()
	if self.tabbar_list ~= nil then return end
	self.tabbar_list = Tabbar.New()
	self.tabbar_list:CreateWithNameList(self.view.node_t_list["layout_qianghua"].node, 742, 551,
		BindTool.Bind1(self.SelectTabCallback, self), 
		Language.Equipment.TabGroup_2, false, ResPath.GetCommon("toggle_104_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
	self.tabbar_list:SetSpaceInterval(5)
end

function EquipmentQianghuaPage:InitEquipTabbar()
	if self.tabbar_equip ~= nil then return end
	self.tabbar_equip = Tabbar.New()
	self.tabbar_equip:CreateWithNameList(self.view.node_t_list["layout_qianghua"].node, -9, 551,
		BindTool.Bind1(self.SelectEquipCallback, self), 
		Language.Equipment.TabGroup_1, false, ResPath.GetCommon("toggle_104_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
	self.tabbar_equip:SetSpaceInterval(5)
end

function EquipmentQianghuaPage:CreateEquipList()
	if self.equip_list == nil then
		local ph = self.view.ph_list.ph_qianghua_list
		self.equip_list = ListView.New()
		self.equip_list:Create(ph.x, ph.y, ph.w, ph.h, nil, EquipListItem, nil, nil, self.view.ph_list.ph_qianghua_item)
		self.view.node_t_list["layout_qianghua"].node:addChild(self.equip_list:GetView(), 999)
		self.equip_list:SetMargin(5)
		self.equip_list:SetItemsInterval(5)
		self.equip_list:SelectIndex(1)
		self.equip_list:GetView():setAnchorPoint(0, 0)
		self.equip_list:SetJumpDirection(ListView.Top)
		self.equip_list:SetSelectCallBack(BindTool.Bind1(self.SelectEquipListCallBack, self))
	end
end

function EquipmentQianghuaPage:SelectEquipListCallBack(item, index)
	self.equip_index = index
	if self.qianghua_type == 2 then
		if nil == item or item:GetData() == nil then return end
		self.select_data_4 = item:GetData()
		if self.soures_cell:GetData() == nil then
			self.soures_cell:SetData(self.select_data_4)
			self:FlushEquipItem()
		else
			if nil == item and item:GetData() == nil then return end
			self.select_data_5 = item:GetData()
			self.target_cell:SetData(self.select_data_5)
			self:FlushEquipItem()
		end
		item:SetVisibleEffect(false)
	else
		if nil == item or item:GetData() == nil then return end
		local select_data = item:GetData()
		self:CreateBg(select_data)
		self:FlushListData(select_data)
		--self:FlushEquipItem()
	end
end

function EquipmentQianghuaPage:CreateCell()
	local ph = self.view.ph_list.ph_qianghua_cell
	self.qianghua_cell = BaseCell.New()
	self.qianghua_cell:SetPosition(ph.x+10, ph.y+10)
	self.qianghua_cell:GetView():setAnchorPoint(0, 0)
	self.qianghua_cell:SetCellBg(ResPath.GetEquipment("cell_1_bg"))
	self.view.node_t_list.layout_qianghua["layout_equip_qianghua"].node:addChild(self.qianghua_cell:GetView(), 100)
end

function EquipmentQianghuaPage:CrateZyCellList()
	local ph = self.view.ph_list.ph_zy_cell_1
	self.priview_cell = BaseCell.New()
	self.priview_cell:SetPosition(ph.x, ph.y)
	self.priview_cell:GetView():setAnchorPoint(0, 0)
	self.view.node_t_list.layout_qianghua["layout_qianghua_zy"].node:addChild(self.priview_cell:GetView(), 100)

	local ph = self.view.ph_list.ph_zy_cell_2
	self.soures_cell = BaseCell.New()
	self.soures_cell:SetPosition(ph.x, ph.y)
	self.soures_cell:GetView():setAnchorPoint(0, 0)
	self.view.node_t_list.layout_qianghua["layout_qianghua_zy"].node:addChild(self.soures_cell:GetView(), 100)

	local ph = self.view.ph_list.ph_zy_cell_3
	self.target_cell = BaseCell.New()
	self.target_cell:SetPosition(ph.x, ph.y)
	self.target_cell:GetView():setAnchorPoint(0, 0)
	self.view.node_t_list.layout_qianghua["layout_qianghua_zy"].node:addChild(self.target_cell:GetView(), 100)
end

function EquipmentQianghuaPage:SelectTabCallback(index)
	self.qianghua_type = index
	if self.equip_list ~= nil then
		self.equip_list:CancelSelect()
	end
	self:BoolShowLayout()
	self:FlushEquipItem()
	self:SetVis()
end

function EquipmentQianghuaPage:SelectEquipCallback(index)
	self.bag_equip_index = index
	self:FlushEquipItem()
	self:SetVis()
	--self.equip_list:SelectIndex(1)
end

function EquipmentQianghuaPage:BoolShowLayout()
	self.view.node_t_list["layout_equip_qianghua"].node:setVisible(self.qianghua_type == 1)
	self.view.node_t_list["layout_qianghua_zy"].node:setVisible(self.qianghua_type == 2)
end

function EquipmentQianghuaPage:SetSelectBtn(data)
	self.tabbar_list:SelectIndex(2)
	self.tabbar_equip:SelectIndex(data[3])
	if self.soures_cell:GetData() == nil then
		self.soures_cell:SetData(data[1])
		self:FlushEquipItem()
		local config = ItemData.Instance:GetItemConfig(data[1].item_id)
		local list = self.equip_list:GetDataList()
		local cur_data = {}
		for k, v in pairs(list) do
			local cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if cfg.type == config.type then
				table.insert(cur_data, k)
			end
		end
		for k, v in pairs(cur_data) do
			local item = self.equip_list:GetItemAt(v)
			local efftct = item:GetEffect()
			efftct:setVisible(true)
		end
	end
end

--初始化事件
function EquipmentQianghuaPage:InitEvent()
	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
	self.equipmentdata_change_callback = BindTool.Bind1(self.EquipmentDataChangeCallback,self)	--监听装备数据变化
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	EquipData.Instance:NotifyDataChangeCallBack(self.equipmentdata_change_callback)
	self.view.node_t_list["btn_qianghua"].node:addClickEventListener(BindTool.Bind(self.StrengthenEquip, self))
	self.view.node_t_list["btn_zy_qianghua"].node:addClickEventListener(BindTool.Bind(self.TransferStrengthen, self))
	self.view.node_t_list.layout_qianghua_zy["btn_tip"].node:addClickEventListener(BindTool.Bind(self.OpenTipView, self))
	self.hero_equip_data_change_evt = GlobalEventSystem:Bind(HeroDataEvent.HERO_EQUIP_CHANGE,BindTool.Bind1(self.OnHeroEquipDataChange, self))
	-- self.view.node_t_list["btn_up_infuse"].node:addClickEventListener(BindTool.Bind(self.MoveUp, self))
	-- self.view.node_t_list["btn_down_infuse"].node:addClickEventListener(BindTool.Bind(self.MoveDown, self))
	-- self.view.node_t_list["btn_up_infuse"].node:setVisible(false)
	-- self.view.node_t_list["btn_down_infuse"].node:setVisible(false)
	self.view.node_t_list.layout_qianghua.layout_equip_qianghua.layout_common_qianhua["btn_recover"].node:addClickEventListener(BindTool.Bind(self.RecoverLimit, self))
	self.view.node_t_list["btn_qiuchu"].node:addClickEventListener(BindTool.Bind(self.QuChu, self))
	self.view.node_t_list["btn_qiuchu"].node:setVisible(false)
	self.view.node_t_list.layout_equip_qianghua["btn_explain"].node:addClickEventListener(BindTool.Bind(self.OpenViewShouMing, self))
	self.view.node_t_list.layout_equip_qianghua.layout_autocompose_hook["btn_nohint_checkbox"].node:addClickEventListener(BindTool.Bind(self.OnClickEquipmnetAuto, self))
	self.view.node_t_list.layout_equip_qianghua.layout_autocompose_hook["img_hook"].node:setVisible(EquipmentData.Instance:GetKeyData() == 1)
	self.number_rade = self:CreateNumBar(370, 375, 30, 29)
	self.view.node_t_list.layout_qianghua["layout_equip_qianghua"].node:addChild(self.number_rade:GetView(),999)
	self.number_rade:GetView():setVisible(false)

	ClientCommonButtonDic[CommonButtonType.EQUIPBOOST_QIANGHUA_BTN] = self.view.node_t_list["btn_qianghua"].node
end

function EquipmentQianghuaPage:OnHeroEquipDataChange()
	self.view:Flush(TabIndex.equipment_qianghua)
end

--移除事件
function EquipmentQianghuaPage:RemoveEvent()
	ClientCommonButtonDic[CommonButtonType.EQUIPBOOST_QIANGHUA_BTN] = nil
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end
	if self.equipmentdata_change_callback then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equipmentdata_change_callback)
		self.equipmentdata_change_callback = nil 
	end
	if self.hero_equip_data_change_evt then
		GlobalEventSystem:UnBind(self.hero_equip_data_change_evt)
		self.hero_equip_data_change_evt = nil
	end
end

--更新视图界面
function EquipmentQianghuaPage:UpdateData(data)
	self:BoolShowLayout()
	local result = EquipmentData.Instance:GetTransmitResult()
	if result == 1 then
		if self.soures_cell:GetData() ~= nil then
			self.soures_cell:ClearData()
		end
		if self.target_cell:GetData() ~= nil then
			self.target_cell:ClearData()
		end
		if self.priview_cell:GetData() ~= nil then
			self.priview_cell:ClearData()
		end
	end
	if self.qianghua_type == 1 then 
		if self.bag_equip_index == 1 then
			local data_1 = EquipmentData.Instance:GetCanStengthEquip()
			if data_1[1] == nil then 
				local data = EquipmentData.Instance:GetBagCanstrenthEquip()
				if data[1] ~= nil then
					self.tabbar_equip:SelectIndex(2)
				else
					local data_hero = EquipmentData.Instance:GetHeroEquipCanStrength()
					if data_hero[1] ~= nil then
						self.tabbar_equip:SelectIndex(3)
					else
						self.tabbar_equip:SelectIndex(1)
					end
				end
			else
				self.tabbar_equip:SelectIndex(1)
			end
		end
	else
		--if self.bag_equip_index == 1 then
		local data_2 = EquipmentData.Instance:GetEquipHadStrenth() 
		if data_2[1] == nil then 
			local data = EquipmentData.Instance:GetBagHadStrenth()
			if data[1] ~= nil then
				self.tabbar_equip:SelectIndex(2)
			else
				local hero_data = EquipmentData.Instance:GetHeroEquipStrenth()
				if hero_data[1] ~= nil then
					self.tabbar_equip:SelectIndex(3)
				else
					self.tabbar_equip:SelectIndex(1)
				end
			end
		else
			self.tabbar_equip:SelectIndex(1)
		end
		--end
	end

	self:FlushEquipItem()
	--self.equip_list:SelectIndex(1)
end	

function EquipmentQianghuaPage:FlushEquipItem()
	self.equip_data = {}
	if self.qianghua_type == 1 then -- 强化
		if self.bag_equip_index == 1 then
			self.equip_data = EquipmentData.Instance:GetCanStengthEquip()
		elseif self.bag_equip_index == 2 then
			self.equip_data = EquipmentData.Instance:GetBagCanstrenthEquip()
		elseif self.bag_equip_index == 3 then
			self.equip_data = EquipmentData.Instance:GetHeroEquipCanStrength()
		end
		self:FlushData(self.equip_data)
		self.equip_list:SetDataList(self.equip_data)

	elseif self.qianghua_type == 2 then
		if self.bag_equip_index == 1 then
			if self.soures_cell:GetData() == nil then
				self.equip_data = EquipmentData.Instance:GetEquipHadStrenth() -- 已强化
			else
				local data = self.soures_cell:GetData()
				self.equip_data = EquipmentData.Instance:GetNotLimitStrengthBody(data) -- 未强化
			end
		elseif self.bag_equip_index == 2 then
			if self.soures_cell:GetData() == nil then
				self.equip_data = EquipmentData.Instance:GetBagHadStrenth()  -- 已强化
				self.equip_list:CancelSelect()
			else
				local data = self.soures_cell:GetData()
				self.equip_data = EquipmentData.Instance:GetBagLimitNotStrength(data) -- 装备未强化	
				if self.target_cell:GetData() == nil then
					self.equip_list:CancelSelect()
				end
			end
		elseif self.bag_equip_index == 3 then
			if self.soures_cell:GetData() == nil then
				self.equip_data = EquipmentData.Instance:GetHeroEquipStrenth()  -- 已强化
				self.equip_list:CancelSelect()
			else
				local data = self.soures_cell:GetData()
				self.equip_data = EquipmentData.Instance:GetHeroNotLimitStrengthBody(data) -- 装备未强化	
				if self.target_cell:GetData() == nil then
					self.equip_list:CancelSelect()
				end
			end
		end
		self:FlushEquipmentZyData()
		self.equip_list:SetDataList(self.equip_data)
	end	
end

function EquipmentQianghuaPage:FlushData(data)
	self.select_data = data[self.equip_index] 
	self:CreateBg(self.select_data)
	if self.select_data ~= nil then 
		self:FlushListData(self.select_data)
	else
		self.view.node_t_list.layout_qianghua.layout_equip_qianghua["layout_common_qianhua"].node:setVisible(false)
		self.view.node_t_list["txt_comsume_money"].node:setString("")
		-- RichTextUtil.ParseRichText(self.view.node_t_list.rich_qh_cur_txt.node, "", 20, COLOR3B.OLIVE)
		-- RichTextUtil.ParseRichText(self.view.node_t_list.rich_qh_next_txt.node, "", 20, COLOR3B.OLIVE)
		self.view.node_t_list.layout_equip_qianghua["layout_pexture"].node:setVisible(false)
		for i = 1, 4 do
			self.view.node_t_list.layout_equip_qianghua["layout_bg"..i].node:setVisible(false)
		end
		self.view.node_t_list["btn_recover"].node:setVisible(false)
		self.number_rade:GetView():setVisible(false)
		self.view.node_t_list.layout_equip_qianghua.layout_autocompose_hook.node:setVisible(false)
		self.view.node_t_list.layout_equip_qianghua["rich_text_yunbao"].node:setVisible(false)
		self.view.node_t_list["img_icon"].node:setVisible(false)
		self.view.node_t_list["layout_common_bg_1"].node:setVisible(false)
		if self.qianghua_cell:GetData() ~= nil then
			self.qianghua_cell:ClearData()
		end
	end
end

function EquipmentQianghuaPage:OnClickEquipmnetAuto()
	local vis = self.view.node_t_list.layout_equip_qianghua.layout_autocompose_hook["img_hook"].node:isVisible()
	EquipmentData.Instance:SetKeyCompose(vis and 0 or 1)	
	self.view.node_t_list.layout_equip_qianghua.layout_autocompose_hook["img_hook"].node:setVisible(not vis)
	self:FlushEquipItem()
end

function EquipmentQianghuaPage:CreateBg(select_data)
	if select_data ~= nil then  
		self.qianghua_cell:SetData(select_data)
		local id = select_data.item_id
		local cfg = ItemData.Instance:GetItemConfig(id)
		local limit = cfg.strongLimit
		local length = (limit - select_data.strengthen_loss_star_level) < select_data.strengthen_level and select_data.strengthen_level or (limit - select_data.strengthen_loss_star_level)
		for i, v in ipairs(self.bg_list) do
			if i > length  then
				v:setVisible(false)
			else
				v:setVisible(true)
			end
		end
		for i, v in ipairs(self.stars_list) do
			if i > length then 
				v:setVisible(false)
			else
				v:setVisible(true)
			end
		end
		if  select_data.strengthen_loss_star_level > 0 and length == select_data.strengthen_level then --只显示一次
			self.view.node_t_list["btn_recover"].node:setVisible(true)
		else
			self.view.node_t_list["btn_recover"].node:setVisible(false)
		end
	else
		for i, v in ipairs(self.bg_list) do
			v:setVisible(false)
		end
		for i, v in ipairs(self.stars_list) do
			v:setVisible(false)
		end
	end
end

function EquipmentQianghuaPage:FlushListData(select_data)
	self.view.node_t_list.layout_qianghua.layout_equip_qianghua["layout_common_qianhua"].node:setVisible(true)
	self.view.node_t_list.layout_equip_qianghua["rich_text_yunbao"].node:setVisible(true)
	self.view.node_t_list["img_icon"].node:setVisible(true)
	self.view.node_t_list["layout_common_bg_1"].node:setVisible(true)
	local level = select_data.strengthen_level
	local cfg = ItemData.Instance:GetItemConfig(select_data.item_id)
	local limit = cfg.strongLimit
	self.view.node_t_list.layout_equip_qianghua.layout_common_qianhua["img_bg_2"].node:setVisible(level < limit)
	self.view.node_t_list.layout_equip_qianghua.layout_common_qianhua["img_percent"].node:setVisible(level < limit)
	self.view.node_t_list.layout_equip_qianghua.layout_common_qianhua["img_bg"].node:setVisible(not (level < limit))
	self:SetLightStar(level)
	local cfg = EquipmentData.GetEquipmentConsumneCfg(level + 1)
	self.view.node_t_list.layout_equip_qianghua.layout_autocompose_hook.node:setVisible(true)
	if cfg ~= nil then
		local consume_count = cfg.starConsumes[1] and cfg.starConsumes[1].count
		local bool_use_gold = EquipmentData.Instance:GetKeyData()
		local rade = 0
		if bool_use_gold == 1 then
			local rade_1 = cfg.addRate
			rade = rade_1 + cfg.starRate
		else
			rade = cfg.starRate
		end
		self.number_rade:GetView():setVisible(true)
		self.number_rade:SetNumber(rade)
		local count = cfg.addRateConsumes[1] and cfg.addRateConsumes[1].count
		local txt = string.format(Language.Equipment.UseGold, count)
		RichTextUtil.ParseRichText(self.view.node_t_list.layout_equip_qianghua["rich_text_yunbao"].node, txt, 20, COLOR3B.OLIVE)
		self.view.node_t_list["txt_comsume_money"].node:setString(consume_count)
		local money_type = cfg.starConsumes[1] and cfg.starConsumes[1].type
		local had_money = RoleData.Instance:GetMoneyNumByAWardType(money_type) 
		local icon_path = RoleData.GetMoneyTypeIconByAwarType(money_type) 
		self.view.node_t_list.layout_common_bg_1["txt_had_money"].node:setString(GameMath.FormatNum(had_money))
		self.view.node_t_list["img_icon"].node:loadTexture(icon_path)
		self.view.node_t_list["img_icon_1"].node:loadTexture(icon_path)
	end
	local cfg = ItemData.Instance:GetItemConfig(select_data.item_id)
	if cfg == nil then
		return 
	end
	local infuse_level = select_data.infuse_level
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if self.bag_equip_index == 3 then
		prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	end
	local attr_cfg = EquipmentData.GetAddAtrrEquipment(cfg, level, infuse_level, select_data.item_id, select_data.compose_level, prof)
	local attr_next_cfg = EquipmentData.GetAddAtrrEquipment(cfg, level + 1, infuse_level, select_data.item_id, select_data.compose_level, prof)
	local current_content = nil 
	local next_content = nil 
	if level == limit then -- 强化到顶级时
		current_content =  RoleData.FormatRoleAttrStr(attr_cfg, is_range)
		next_content = {Language.Equipment.Max_level}
		self.number_rade:GetView():setVisible(false)
	else
		self.number_rade:GetView():setVisible(true)
		current_content = RoleData.FormatRoleAttrStr(attr_cfg, is_range)
		next_content = RoleData.FormatRoleAttrStr(attr_next_cfg, is_range)
	end
	self.view.node_t_list.layout_equip_qianghua["layout_pexture"].node:setVisible(true)
	for i = 1, 4 do
		self.view.node_t_list.layout_equip_qianghua["layout_bg" .. i]["attr_title" .. i].node:setString(current_content[i] and current_content[i].type_str.. "：" or "")
		self.view.node_t_list.layout_equip_qianghua["layout_bg" .. i]["cur_attr" .. i].node:setString(current_content[i] and current_content[i].value_str or "")
		self.view.node_t_list.layout_equip_qianghua["layout_bg" .. i]["attr_title" .. i].node:setPositionY(28)
		self.view.node_t_list.layout_equip_qianghua["layout_bg" .. i]["cur_attr" .. i].node:setPositionY(28)
		if current_content[i] == nil then
			self.view.node_t_list.layout_equip_qianghua["layout_bg"..i].node:setVisible(false)
		else
			self.view.node_t_list.layout_equip_qianghua["layout_bg"..i].node:setVisible(true)
		end
	end
	for i = 1, 4 do
		self.view.node_t_list.layout_equip_qianghua["layout_bg" .. i]["nex_attr" .. i].node:setString(next_content[i] and next_content[i].value_str or next_content[i] or "")
		self.view.node_t_list.layout_equip_qianghua["layout_bg" .. i]["nex_attr" .. i].node:setPositionY(28)
	end
end

function EquipmentQianghuaPage:CreateStar()
	self.bg_list = {}
	self.stars_list = {}
	local ph = self.view.ph_list.ph_img
	for i = 1, 15 do
		local file = ResPath.GetCommon("star_1_lock")	
		local start = XUI.CreateImageView(ph.x - 80 + (i - 1) * 32.2, ph.y + 20, file)
		self.view.node_t_list["layout_equip_qianghua"].node:addChild(start, 999)
		table.insert(self.stars_list, start)

		local file = ResPath.GetCommon("bg_15")	
		local bg = XUI.CreateImageView(ph.x - 80 + (i - 1) * 32.2, ph.y + 20, file)
		self.view.node_t_list["layout_equip_qianghua"].node:addChild(bg, 990)
		table.insert(self.bg_list, bg)
	end
end

function EquipmentQianghuaPage:SetLightStar(star)
	local result = EquipmentData.Instance:GetQianghuaResult()
	local qianghua_type = EquipmentData.Instance:GetEquiptype()
	if result and qianghua_type == 1 then
		local ph = self.view.ph_list.ph_qianghua_effec
		local effct_id = 46
		if result == 0 then
			effct_id = 47
		end
		self:SetPlayEffect(effct_id, ph.x, ph.y)
		-- AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.EquipmentQianghua))
	end
	EquipmentData.Instance:ResetQianghuaResult()
	for i, v in ipairs(self.stars_list) do
		if star >= i then
			v:loadTexture(ResPath.GetCommon("star_1_select"))
		else
			v:loadTexture(ResPath.GetCommon("star_1_lock"))
		end	
	end
end

function EquipmentQianghuaPage:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_BIND_COIN or key == OBJ_ATTR.ACTOR_GOLD then
		self:FlushEquipItem()
	end
end

function EquipmentQianghuaPage:QuChu()
	if self.soures_cell:GetData() ~= nil then
		self.soures_cell:ClearData()
	end
	if self.target_cell:GetData() ~= nil then
		self.target_cell:ClearData()
	end
	if self.priview_cell:GetData() ~= nil then
		self.priview_cell:ClearData()
	end
	self:FlushEquipItem()
end

function EquipmentQianghuaPage:EquipmentDataChangeCallback()
	self:FlushEquipItem()
end

function EquipmentQianghuaPage:StrengthenEquip()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	local data = self.qianghua_cell:GetData()
	if data ~= nil then
		local series = data.series
		local bool_use_gold = EquipmentData.Instance:GetKeyData()
		EquipmentCtrl:SendQianghuaReq(series, 1, bool_use_gold)
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function EquipmentQianghuaPage:SetVis()
	local items = self.equip_list:GetAllItems()
	for k, v in pairs(items) do
		v:SetVisibleEffect(false)
	end
end

function EquipmentQianghuaPage:FlushEquipmentZyData()
	local select_data = self.soures_cell:GetData()
	if select_data ~= nil  then
		local level = select_data.strengthen_level
		local cfg = EquipmentData.GetEquipmentTransmitCfg(level)
		self.view.node_t_list["layout_common_bg_1"].node:setVisible(true)
		self.view.node_t_list["icon_bg_2"].node:setVisible(true)
		if cfg ~= nil then
			local consume = cfg[1] and cfg[1].count 
			local money_type = cfg[1] and cfg[1].type -- 金钱类型
			self.view.node_t_list["txt_comsume_zy_money"].node:setVisible(true)
			self.view.node_t_list["txt_comsume_zy_money"].node:setString(consume)
			local icon_path = nil 
			if money_type == 3 then
				had_money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN)
				icon_path = ResPath.GetCommon("icon_money")
			elseif money_type == 5 then
				had_money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD)
				icon_path = ResPath.GetCommon("bind_gold")
			elseif money_type == 10 then
				had_money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
				icon_path = ResPath.GetCommon("gold")
			end
			self.view.node_t_list["icon_bg_2"].node:loadTexture(icon_path)
			self.view.node_t_list["img_icon_1"].node:loadTexture(icon_path)
			self.view.node_t_list["txt_had_money"].node:setString(GameMath.FormatNum(had_money))
		end
		-- local txt = "+"..level
		-- self.soures_cell:SetLeftTopText(txt)
		self.view.node_t_list["btn_qiuchu"].node:setVisible(true)	
		self.view.node_t_list["btn_qiuchu"].node:setLocalZOrder(999)	
	else
		self.view.node_t_list["txt_comsume_zy_money"].node:setVisible(false)
		self.view.node_t_list["btn_qiuchu"].node:setVisible(false)
		self.view.node_t_list["icon_bg_2"].node:setVisible(false)
		self.view.node_t_list["layout_common_bg_1"].node:setVisible(false)
		self.view.node_t_list["layout_common_bg_1"].node:setVisible(false)
	end
	local select_data_6 = self.target_cell:GetData()
	self.priview_cell:SetData(select_data_6)
	-- if select_data_6 ~= nil then
	-- 	local num = 0
	-- 	local txt = "+"..num
	-- 	-- self.target_cell:SetLeftTopText(txt)
	-- end

	-- if select_data ~= nil and select_data_6 ~= nil and self.priview_cell:GetData() then
	-- 	local qianhua_level = select_data.strengthen_level
	-- 	local txt = "+"..qianhua_level
	-- 	self.priview_cell:SetLeftTopText(txt)
	-- end
	local txt = ""
	if select_data == nil and select_data_6 == nil then -- 未放入装备
		txt = Language.Equipment.Desc_1
	elseif select_data ~= nil and select_data_6 == nil then -- 已放入源装备
		txt = Language.Equipment.Desc_2
	else
		txt = " "
	end
	self.view.node_t_list.layout_qianghua.layout_qianghua_zy["txt_qingqiu"].node:setString(txt)
end

function EquipmentQianghuaPage:TransferStrengthen()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	local data = self.soures_cell:GetData()
	local data_2 = self.target_cell:GetData()
	if data ~= nil and data_2 ~= nil  then
		local soures_series = data.series
		local target_series = data_2.series
		EquipmentCtrl.Instance:SendQianghuaTansmitReq(soures_series, target_series)
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function EquipmentQianghuaPage:OpenTipView()
	DescTip.Instance:SetContent(Language.Equipment.Title_Transmit_content, Language.Equipment.Title_Transmit)
end

function EquipmentQianghuaPage:OpenViewShouMing()
	DescTip.Instance:SetContent(Language.Equipment.Titel_Qianghua_content, Language.Equipment.Titel_Qianghua)
end

-- function EquipmentQianghuaPage:MoveUp()
-- 	if self.equip_index > 1 then
-- 		self.equip_index = self.equip_index - 1
-- 		self.equip_list:SelectIndex(self.equip_index)
-- 	end
-- end

-- function EquipmentQianghuaPage:MoveDown()
-- 	if self.equip_index < #self.equip_data then
-- 		self.equip_index = self.equip_index + 1
-- 		self.equip_list:SelectIndex(self.equip_index)
-- 	end
-- end

function EquipmentQianghuaPage:RecoverLimit()
	local data = self.qianghua_cell:GetData()
	if data ~= nil then
		local level = data.strengthen_level
		local cfg = EquipmentData.GetEquipmentRecoverCfg(level + 1)
		if cfg ~= nil then 
			local consume = cfg[1] and cfg[1].count
			local money_type = cfg[1] and cfg[1].type 
			local txt = Language.Equipment.Money_type[money_type]
			local des = string.format(Language.Equipment.TipDesc, consume, txt)
			self.alert_equipment_view:SetShowCheckBox(true)
			self.alert_equipment_view:Open()
			self.alert_equipment_view:SetLableString(des)
		end
	end
end

function EquipmentQianghuaPage:CreateNumBar(x, y, w, h)
	local number_bar = NumberBar.New()
	number_bar:SetRootPath(ResPath.GetMainuiRoot() .. "num_")
	number_bar:SetPosition(x, y)
	number_bar:SetContentSize(w, h)
	number_bar:SetSpace(-2)
	return number_bar
end

function EquipmentQianghuaPage:CreateTip()
	if nil == self.alert_equipment_view then
		self.alert_equipment_view = Alert.New()
	end
	self.alert_equipment_view:SetOkFunc(BindTool.Bind2(self.SendRecoverLimit, self))
	self.alert_equipment_view:SetCancelFunc(BindTool.Bind2(self.CloseWindow, self))
end

function EquipmentQianghuaPage:CloseWindow()
	self.alert_equipment_view:Close()
end

function EquipmentQianghuaPage:SendRecoverLimit()
	local data = self.qianghua_cell:GetData()
	if data ~= nil then
		local series = data.series
		EquipmentCtrl.Instance:SendQianghuaReq(series, 2, 1)
	end
end

function EquipmentQianghuaPage:SetPlayEffect(effct_id, x, y)
	if self.play_effect == nil then
		self.play_effect = AnimateSprite:create()
		self.view.node_t_list.layout_qianghua.node:addChild(self.play_effect,999)
	end	
	self.play_effect:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effct_id)
	self.play_effect:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

----------------------------------------------------------------------------------------------------
EquipListItem = EquipListItem or BaseClass(BaseRender)
function EquipListItem:__init()
	self.equip_cell = nil 
	self:SetPlayItemEffect(10, 160, 60)
	self.special_effect:setVisible(false)
end

function EquipListItem:__delete()
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil 
	end
	if self.special_effect then
		self.special_effect:setStop()
		self.special_effect = nil 
	end
end

function EquipListItem:CreateChild()
	BaseRender.CreateChild(self)
	if self.equip_cell == nil then
		local ph = self.ph_list.ph_item_cell
		self.equip_cell = QianghuaEquipCell.New()
		self.equip_cell:SetPosition(ph.x, ph.y)
		self.equip_cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.equip_cell:GetView(), 100)
	end
end

function EquipListItem:OnFlush()
	if self.data == nil then return end
	if self.data.item_id == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	self.node_tree["txt_equip_name"].node:setString(item_cfg.name)
	if item_cfg.color ~= nil then
		local color = string.format("%06x", item_cfg.color)
		self.node_tree["txt_equip_name"].node:setColor(Str2C3b(color))
	end
	self.node_tree["txt_level"].node:setString(Language.Equipment.Quanghua.."   ".."+".." "..self.data.strengthen_level)
	self.equip_cell:SetData(self.data)
end

-- 创建选中特效
function EquipListItem:CreateSelectEffect()
	if nil == self.node_tree.img9_bg then
		return
	end
	local size = self.node_tree["img9_bg"].node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width+20, size.height+20, ResPath.GetCommon("img9_173"), true)
	if nil == self.select_effect then
		ErrorLog("InfoListItem:CreateSelectEffect fail")
	end
	self.view:addChild(self.select_effect, 99)
end

function EquipListItem:GetEffect()
	-- print("333333333", self.special_effect)
	return self.special_effect
end

function EquipListItem:SetVisibleEffect(vis)
	if self.special_effect ~= nil then
		self.special_effect:setVisible(vis)
	end
end

function EquipListItem:SetPlayItemEffect(effct_id, x, y)
	if self.special_effect == nil then
		self.special_effect = AnimateSprite:create()
		self.view:addChild(self.special_effect,999)
	end	
	self.special_effect:setPosition(x, y)
	self.special_effect:setScaleX(1.4)
	self.special_effect:setScaleY(1.9)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effct_id)
	self.special_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
end


QianghuaEquipCell = QianghuaEquipCell or BaseClass(BaseCell)
function QianghuaEquipCell:__init()
end	

function QianghuaEquipCell:__delete()
end

function QianghuaEquipCell:InitEvent()
end	