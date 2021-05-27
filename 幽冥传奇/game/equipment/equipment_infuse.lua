EquipmentInfusePage = EquipmentInfusePage or BaseClass()


function EquipmentInfusePage:__init()
	self.view = nil
end	

function EquipmentInfusePage:__delete()
	self:RemoveEvent()
	if self.tabbar_infuse then
		self.tabbar_infuse:DeleteMe()
		self.tabbar_infuse = nil 
	end

	if self.tabbar_equip_infuse then
		self.tabbar_equip_infuse:DeleteMe()
		self.tabbar_equip_infuse = nil 
	end

	if self.equip_item_list then
		self.equip_item_list:DeleteMe()
		self.equip_item_list = nil 
	end

	if self.infuse_cell then
		self.infuse_cell:DeleteMe()
		self.infuse_cell = nil 
	end

	if self.recycle_cell then
		self.recycle_cell:DeleteMe()
		self.recycle_cell = nil
	end
	self.view = nil
end	


--初始化页面接口
function EquipmentInfusePage:InitPage(view)
	--绑定要操作的元素

	self.view = view
	self.infuse_index = 1
	self.infuse_bag_index = 1
	self.equip_infuse_index = nil
	self.select_infuse_data = nil
	self:InitBar()
	self:InitEquipInfuseTabbar()
	self:CreateEquipList()
	self:CreateZlCell()
	self:CreateRecycleCell()
	self:CreateZhanshi()
	
	self:InitEvent()
end	

function EquipmentInfusePage:InitBar()
	if self.tabbar_infuse ~= nil then return end
	self.tabbar_infuse = Tabbar.New()
	self.tabbar_infuse:CreateWithNameList(self.view.node_t_list["layout_infuse"].node, 748, 551,
		BindTool.Bind1(self.SelectInfuseCallback, self), 
		Language.Equipment.TabGroup_3, false, ResPath.GetCommon("toggle_104_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
	self.tabbar_infuse:SetSpaceInterval(5)
end

function EquipmentInfusePage:InitEquipInfuseTabbar()
	if self.tabbar_equip_infuse ~= nil then return end
	self.tabbar_equip_infuse = Tabbar.New()
	self.tabbar_equip_infuse:CreateWithNameList(self.view.node_t_list["layout_infuse"].node, -3, 551,
		BindTool.Bind1(self.SelectEquipInfuseCallback, self), 
		Language.Equipment.TabGroup_1, false, ResPath.GetCommon("toggle_104_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
	self.tabbar_equip_infuse:SetSpaceInterval(5)
end

function EquipmentInfusePage:SelectEquipInfuseCallback(index)
	self.infuse_bag_index = index 
	self:FlushInfuseItem()
end

function EquipmentInfusePage:CreateEquipList()
	if self.equip_item_list == nil then
		local ph = self.view.ph_list.ph_zl_item_list
		self.equip_item_list = ListView.New()
		self.equip_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, EquipZlListItem, nil, nil, self.view.ph_list.ph_zl_equip_item)
		self.view.node_t_list["layout_infuse"].node:addChild(self.equip_item_list:GetView(), 99)
		self.equip_item_list:SetMargin(10)
		self.equip_item_list:SetItemsInterval(5)
		self.equip_item_list:GetView():setAnchorPoint(0, 0)
		self.equip_item_list:SelectIndex(1)
		self.equip_item_list:SetJumpDirection(ListView.Top)
		self.equip_item_list:SetSelectCallBack(BindTool.Bind1(self.SelectEquipListDataCallBack, self))
	end
end

function EquipmentInfusePage:SelectEquipListDataCallBack(item, index)
	self.equip_infuse_index = index
	if self.infuse_index == 1 then
		if item == nil or item:GetData() == nil then return end
		local data = item:GetData()
		---self:FlushInfuseItem()
		self:FlushListSelectInfuseData(data)
	elseif self.infuse_index == 2 then
		if item == nil or item:GetData() == nil then return end
		self.select_data_1 = item:GetData()
		self:FlushInfuseItem()
	end
end

function EquipmentInfusePage:CreateZlCell()
	local ph = self.view.ph_list.ph_zl_cell
	self.infuse_cell = BaseCell.New()
	self.infuse_cell:SetPosition(ph.x+10, ph.y+10)
	self.infuse_cell:GetView():setAnchorPoint(0, 0)
	self.infuse_cell:SetCellBg(ResPath.GetEquipment("cell_1_bg"))
	self.view.node_t_list.layout_infuse["layout_zl_equip"].node:addChild(self.infuse_cell:GetView(), 100)
end

function EquipmentInfusePage:CreateRecycleCell()
	local ph = self.view.ph_list.ph_item_cycle_cell
	self.recycle_cell = BaseCell.New()
	self.recycle_cell:SetPosition(ph.x, ph.y)
	self.recycle_cell:GetView():setAnchorPoint(0, 0)
	self.recycle_cell:SetCellBg(ResPath.GetEquipment("cell_1_bg"))
	self.view.node_t_list.layout_infuse["layout_recycle_zl"].node:addChild(self.recycle_cell:GetView(), 100)
end

function EquipmentInfusePage:SelectInfuseCallback(index)
	self.infuse_index = index
	self:BoolShowInfuseLayout()
	self:FlushInfuseItem()
end

function EquipmentInfusePage:BoolShowInfuseLayout()
	self.view.node_t_list["layout_zl_equip"].node:setVisible(self.infuse_index == 1)
	self.view.node_t_list["layout_recycle_zl"].node:setVisible(self.infuse_index == 2)
end

--初始化事件
function EquipmentInfusePage:InitEvent()
	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
	self.equipmentdata_change_callback = BindTool.Bind1(self.EquipmentDataChangeCallback,self)	--监听装备数据变化
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	EquipData.Instance:NotifyDataChangeCallBack(self.equipmentdata_change_callback)
	self.view.node_t_list["btn_zhuling"].node:addClickEventListener(BindTool.Bind(self.ZhulingEquip, self))
	self.view.node_t_list["btn_recycle"].node:addClickEventListener(BindTool.Bind(self.RecycleEquip, self))
	self.view.node_t_list.layout_recycle_zl["btn_warn"].node:addClickEventListener(BindTool.Bind(self.OpenWarnTipView, self))
	self.view.node_t_list.layout_zl_equip["btn_open_tips"].node:addClickEventListener(BindTool.Bind(self.OpenZlEquipTipView, self))
	self.equip_data_change_evt = GlobalEventSystem:Bind(HeroDataEvent.HERO_EQUIP_CHANGE,BindTool.Bind1(self.OnHeroEquipDataChange, self))
end

function EquipmentInfusePage:OnHeroEquipDataChange()
	self.view:Flush(TabIndex.equipment_infuse)
end

--移除事件
function EquipmentInfusePage:RemoveEvent()
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end
	if self.equipmentdata_change_callback then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equipmentdata_change_callback)
		self.equipmentdata_change_callback = nil 
	end
	if self.equip_data_change_evt then
		GlobalEventSystem:UnBind(self.equip_data_change_evt)
		self.equip_data_change_evt = nil
	end
end

--更新视图界面
function EquipmentInfusePage:UpdateData(data)
	self:BoolShowInfuseLayout()
	self.view.node_t_list["img_infuse_bg"].node:setVisible(false)
	self.view.node_t_list["img_infuse_bg_2"].node:setVisible(false)
	local infuse_type = EquipmentData.Instance:GetInfuseType()
	local infuse_result = EquipmentData.Instance:GetInfuseResult()
	if infuse_type == 2 and infuse_result == 1 then
		local data = self.recycle_cell:GetData()
		if data ~= nil then
			self.recycle_cell:ClearData()
		end
	end
	self:FlushInfuseItem()
	self.equip_item_list:SelectIndex(self.equip_infuse_index)
	self.view.node_t_list.layout_infuse_common_bg["txt_zl_had"].node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INJECT_POWER))
	if self.infuse_index == 1 then 
		if self.infuse_bag_index == 1 then
			local data_1 =  EquipmentData.GetCanInfuseEquip()
			if data_1[1] == nil then 
				local data = EquipmentData.GetCanInfuseBagEquip()
				if data[1] ~= nil then
					self.tabbar_equip_infuse:SelectIndex(2)
				else 
					self.tabbar_equip_infuse:SelectIndex(1)
				end
			else 
				self.tabbar_equip_infuse:SelectIndex(1)
			end
		end
	else
		if self.infuse_bag_index == 1 then
			local data_2 = EquipmentData.GetInfuseRecycle()
			if data_2[1] == nil then 
				local data = EquipmentData.GetBagInfuseRecycle()
				if data[1] ~= nil then
					self.tabbar_equip_infuse:SelectIndex(2)
				else
					self.tabbar_equip_infuse:SelectIndex(1)
				end
			else
				self.tabbar_equip_infuse:SelectIndex(1)	
			end
		end
	end
end	

function EquipmentInfusePage:FlushInfuseItem()
	if self.infuse_index == 1 then
		if self.infuse_bag_index == 1 then
			self.infuse_data = EquipmentData.GetCanInfuseEquip()
		elseif self.infuse_bag_index == 2 then
			self.infuse_data = EquipmentData.GetCanInfuseBagEquip()
		elseif self.infuse_bag_index == 3 then
			self.infuse_data = EquipmentData.Instance:GetHeroEquipCanInfuse()
		end
		self:FlushInfuseData(self.infuse_data)
	elseif self.infuse_index ==2 then
		if self.infuse_bag_index == 1 then
			self.infuse_data = EquipmentData.GetInfuseRecycle()
		elseif self.infuse_bag_index == 2 then
			self.infuse_data = EquipmentData.GetBagInfuseRecycle()
		elseif self.infuse_bag_index == 3 then
			self.infuse_data = EquipmentData.GetHeroInfuseRecycle()
		end
		self:FlushInfuseRecycleData(self.infuse_data)
	end
	self.equip_item_list:SetDataList(self.infuse_data)
end

function EquipmentInfusePage:FlushInfuseData(data)
	if self.select_data ~= nil and data[self.equip_infuse_index] ~= nil then
		if self.select_data ~= nil then
			local select_data = data[self.equip_infuse_index]
			self:FlushListSelectInfuseData(select_data)
		end
	else
		for i,v in pairs(self.bg_list) do
			v:setVisible(false)
		end
		for i,v in pairs(self.stone_list) do
			v:setVisible(false)
		end
		self.view.node_t_list["txt_zl_consume"].node:setString("")
		self.view.node_t_list["txt_zl_percent"].node:setString("")
		self.view.node_t_list["layout_infuse_common_bg"].node:setVisible(false)
		self.view.node_t_list.layout_zl_equip["txt_infuse_xiaohao"].node:setVisible(false)
		if self.infuse_cell:GetData() ~= nil then
			self.infuse_cell:ClearData()
		end
		self.view.node_t_list.layout_zl_equip["layout_pexture_1"].node:setVisible(false)
		for i = 1, 4 do
			self.view.node_t_list.layout_zl_equip["layout_bg"..i].node:setVisible(false)
		end
	end
end

function EquipmentInfusePage:FlushListSelectInfuseData(select_data)
	self.view.node_t_list.layout_zl_equip["txt_infuse_xiaohao"].node:setVisible(true)
	self.view.node_t_list["layout_infuse_common_bg"].node:setVisible(true)
	local level = select_data.infuse_level
	local cfg = EquipmentData.GetInfuseCfg(level + 1)
	self.infuse_cell:SetData(select_data)
	self:SetStone(level)
	if cfg ~= nil then
		local consume = cfg[1] and cfg[1].count
		self.view.node_t_list["txt_zl_consume"].node:setString(consume)
		local item_cfg = ItemData.Instance:GetItemConfig(select_data.item_id)
		local limit = item_cfg.injectLimit
		self.view.node_t_list["txt_zl_percent"].node:setString(level.."/"..limit)
		for i, v in ipairs(self.bg_list) do
			if i > limit  then
				v:setVisible(false)
			else
				v:setVisible(true)
			end
		end
		for i, v in ipairs(self.stone_list) do
			if i > limit  then
				v:setVisible(false)
			else
				v:setVisible(true)
			end
		end
	else
		self.view.node_t_list["txt_zl_consume"].node:setString(0)
		local item_cfg = ItemData.Instance:GetItemConfig(select_data.item_id)
		local limit = item_cfg.injectLimit
		self.view.node_t_list["txt_zl_percent"].node:setString(limit.."/"..limit)
		for i, v in ipairs(self.bg_list) do
			if i > limit  then
				v:setVisible(false)
			else
				v:setVisible(true)
			end
		end
		for i, v in ipairs(self.stone_list) do
			if i > limit  then
				v:setVisible(false)
			else
				v:setVisible(true)
			end
		end
	end
	local infuse_cfg = ItemData.Instance:GetItemConfig(select_data.item_id)
	if infuse_cfg == nil then
		return 
	end
	local limit = infuse_cfg.injectLimit
	local strength_level =  select_data.strengthen_level
	local equip_type = infuse_cfg.type
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if self.infuse_bag_index == 3 then
		prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	end
	local attr_cfg = EquipmentData.GetAddAtrrEquipment(infuse_cfg, strength_level, level, select_data.item_id, select_data.compose_level, prof)
	local attr_next_cfg = EquipmentData.GetAddAtrrEquipment(infuse_cfg, strength_level, level+1, select_data.item_id, select_data.compose_level, prof)
	local current_content = nil 
	local next_content = nil 
	if level == 0 then  --未强化时
		current_content = RoleData.FormatRoleAttrStr(attr_cfg)
		next_content = RoleData.FormatRoleAttrStr(attr_next_cfg, is_range)
		self.view.node_t_list["img_infuse_bg"].node:setVisible(false)
		self.view.node_t_list["img_infuse_bg_2"].node:setVisible(true)
	else
		if level == limit then -- 强化到顶级时
			self.view.node_t_list["txt_zl_consume"].node:setString(0)
			current_content = RoleData.FormatRoleAttrStr(attr_cfg, is_range)
			next_content = {Language.Equipment.Max_level}
			self.view.node_t_list["img_infuse_bg"].node:setVisible(true)
			self.view.node_t_list["img_infuse_bg_2"].node:setVisible(false)
		else
			current_content = RoleData.FormatRoleAttrStr(attr_cfg, is_range)
			next_content = RoleData.FormatRoleAttrStr(attr_next_cfg, is_range)
			self.view.node_t_list["img_infuse_bg"].node:setVisible(false)
			self.view.node_t_list["img_infuse_bg_2"].node:setVisible(true)
		end
	end
	self.view.node_t_list.layout_zl_equip["layout_pexture_1"].node:setVisible(true)
	for i = 1, 4 do
		self.view.node_t_list.layout_zl_equip["layout_bg" .. i]["attr_title" .. i].node:setString(current_content[i] and current_content[i].type_str.. "：" or "")
		self.view.node_t_list.layout_zl_equip["layout_bg" .. i]["cur_attr" .. i].node:setString(current_content[i] and current_content[i].value_str or "")
		self.view.node_t_list.layout_zl_equip["layout_bg" .. i]["attr_title" .. i].node:setPositionY(28)
		self.view.node_t_list.layout_zl_equip["layout_bg" .. i]["cur_attr" .. i].node:setPositionY(28)
		if current_content[i] == nil then
			self.view.node_t_list.layout_zl_equip["layout_bg"..i].node:setVisible(false)
		else
			self.view.node_t_list.layout_zl_equip["layout_bg"..i].node:setVisible(true)
		end
	end
	for i = 1, 4 do
		self.view.node_t_list.layout_zl_equip["layout_bg" .. i]["nex_attr" .. i].node:setString(next_content[i] and next_content[i].value_str or next_content[i] or "")
		self.view.node_t_list.layout_zl_equip["layout_bg" .. i]["nex_attr" .. i].node:setPositionY(28)
	end
end

function EquipmentInfusePage:FlushInfuseRecycleData(data)
	if  data[self.equip_infuse_index] ~= nil  then
		local select_data =  data[self.equip_infuse_index]
		self.recycle_cell:SetData(select_data)
		self.view.node_t_list["layout_infuse_common_bg"].node:setVisible(true)
		self.view.node_t_list.layout_recycle_zl["text_recycle"].node:setVisible(true)
		local level = select_data.infuse_level
		local cfg = EquipmentData.GetInfuseRecycleCfg(level)
		if cfg ~= nil then
			local consume = cfg[1] and cfg[1].count
			self.view.node_t_list.layout_infuse.layout_recycle_zl.txt_recycle_had.node:setString(consume)
		end
	else
		self.view.node_t_list.layout_recycle_zl["txt_recycle_had"].node:setString("")
		local data = self.recycle_cell:GetData()
		if data ~= nil then
			self.recycle_cell:ClearData()
		end
		self.view.node_t_list.layout_recycle_zl["text_recycle"].node:setVisible(false)
		self.view.node_t_list["layout_infuse_common_bg"].node:setVisible(false)
		if self.recycle_cell:GetData() ~= nil then
			self.recycle_cell:ClearData()
		end
	end
end

function EquipmentInfusePage:CreateZhanshi()
	self.bg_list = {}
	self.stone_list = {}
	local ph = self.view.ph_list.ph_img_zl_1
	for i = 1, 15 do
		local file = ResPath.GetCommon("icon_diamond_an")	
		local star = XUI.CreateImageView(ph.x + (i - 1) * 32.2 - 80, ph.y+15, file)
		self.view.node_t_list["layout_zl_equip"].node:addChild(star, 999)
		table.insert(self.stone_list, star)

		local file = ResPath.GetCommon("bg_15")	
		local bg = XUI.CreateImageView(ph.x + (i - 1) * 32.2 - 80, ph.y+15, file)
		self.view.node_t_list["layout_zl_equip"].node:addChild(bg, 990)
		table.insert(self.bg_list, bg)
	end
end

function EquipmentInfusePage:SetStone(stones)
	for i,v in ipairs(self.stone_list) do
		if stones >= i then
			v:loadTexture(ResPath.GetCommon("icon_diamond"))
		else
			v:loadTexture(ResPath.GetCommon("icon_diamond_an"))
		end
	end
end

function EquipmentInfusePage:ZhulingEquip()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	local data = self.infuse_cell:GetData()
	if data ~= nil then
		series = data.series
		EquipmentCtrl.Instance:SendEquipmentInfuse(series, 1)
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function EquipmentInfusePage:RecycleEquip()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	local data = self.recycle_cell:GetData()
	if data ~= nil then
		series = data.series
		EquipmentCtrl.Instance:SendEquipmentInfuse(series, 2)
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function EquipmentInfusePage:OpenWarnTipView()
	DescTip.Instance:SetContent(Language.Equipment.Tiele_infuse_recycle_content, Language.Equipment.Tiele_infuse_recycle)
end

function EquipmentInfusePage:OpenZlEquipTipView()
	DescTip.Instance:SetContent(Language.Equipment.TiTle_infuse_content, Language.Equipment.TiTle_infuse)
end

function EquipmentInfusePage:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_INJECT_POWER then
		self.view:Flush(TabIndex.equipment_infuse)
	end 
end

function EquipmentInfusePage:EquipmentDataChangeCallback()
	self.view:Flush(TabIndex.equipment_infuse)
end
----------------------------------------------------------------------------------------------------
EquipZlListItem = EquipZlListItem or BaseClass(BaseRender)
function EquipZlListItem:__init()
	self.cell_render = nil 
end

function EquipZlListItem:__delete()
	if self.cell_render then
		self.cell_render:DeleteMe()
		self.cell_render = nil 
	end
end

function EquipZlListItem:CreateChild()
	BaseRender.CreateChild(self)
	if self.cell_render ~= nil then return end
	local ph = self.ph_list.ph_zl_equip_cell
	self.cell_render = InfuseEquipCell.New()
	self.cell_render:SetPosition(ph.x, ph.y)
	self.cell_render:GetView():setAnchorPoint(0, 0)
	self.view:addChild(self.cell_render:GetView(), 100)
end

function EquipZlListItem:OnFlush()
	if self.data == nil then return end
	local cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if cfg == nil then
		return 
	end
	local  color = string.format("%06x", cfg.color)
	self.node_tree["txt_zl_equip_name"].node:setColor(Str2C3b(color))
	self.node_tree["txt_zl_equip_name"].node:setString(cfg.name)
	self.node_tree["txt_infuse_level"].node:setString(Language.Equipment.Zhuling.."   ".."+".." "..self.data.infuse_level)
	self.cell_render:SetData(self.data)
end

-- 创建选中特效
function EquipZlListItem:CreateSelectEffect()
	if self.node_tree["img9_bg_2"] == nil then
		return
	end
	local size = self.node_tree["img9_bg_2"].node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width+20, size.height+20, ResPath.GetCommon("img9_173"), true)
	if nil == self.select_effect then
		ErrorLog("InfoListItem:CreateSelectEffect fail")
	end
	self.view:addChild(self.select_effect, 99)
end

InfuseEquipCell = InfuseEquipCell or BaseClass(BaseCell)
function InfuseEquipCell:__init()
end	

function InfuseEquipCell:__delete()
end

function InfuseEquipCell:InitEvent()
end	
