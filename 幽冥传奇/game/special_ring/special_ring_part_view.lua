--------------------------------------------------------
-- 特戒-分离  配置 SpecialRingHandleCfg
--------------------------------------------------------

local SpecialRingPartView = SpecialRingPartView or BaseClass(SubView)

function SpecialRingPartView:__init()
	self.texture_path_list[1] = 'res/xui/special_ring.png'
	self:SetModal(true)
	self.config_tab = {
		{"special_ring_ui_cfg", 2, {0}},
		{"special_ring_ui_cfg", 5, {0}},
	}

	self.cell_list = {}
	self.view_index = 1
	self.select_slot = nil
	self.can_part = false
	self.consume_item_cfg = nil
end

function SpecialRingPartView:__delete()
end

--释放回调
function SpecialRingPartView:ReleaseCallBack()
	self.select_slot = nil
end

--加载回调
function SpecialRingPartView:LoadCallBack(index, loaded_times)
	self:CreateCellList()
	self:CreateAttrList()
	self:CreatePower()
	self:CreateSkillList()

	self.node_t_list["img_select"].node:setVisible(false)

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnClickBtn, self))
	XUI.AddClickEventListener(self.node_t_list["btn_ques6"].node, BindTool.Bind(self.OpenTip, self))

	-- 数据监听
	EventProxy.New(SpecialRingData.Instance, self):AddEventListener(SpecialRingData.IN_PUT_LIST_CHANGE, BindTool.Bind(self.OnInPutListChange, self))
	EventProxy.New(SpecialRingData.Instance, self):AddEventListener(SpecialRingData.SLOT_INFO_CHANGE, BindTool.Bind(self.OnSlotInfoChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function SpecialRingPartView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function SpecialRingPartView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	
	SpecialRingData.Instance:ResetInPutList()
	SpecialRingData.Instance:SetInPutType(nil)
	if self.select_slot then
		self.cell_list[self.select_slot]:SetIsShowTips(false)
		self.select_slot = nil
	end
	if self.node_t_list["img_select"] then
		self.node_t_list["img_select"].node:setVisible(false)
	end
	self.can_part = false
	self.consume_item_cfg = nil
end

--显示指数回调
function SpecialRingPartView:ShowIndexCallBack(index)
	self:Flush()
end

function SpecialRingPartView:OnFlush(index)
	self:FlushCellList()
	self:FlushConsume()
	self:FlusAttrList()
	self:FlushPower()
	self:FlushSkillList()
end

----------视图函数----------

-- 创建格子
function SpecialRingPartView:CreateCellList()
	local ph, cell
	local parent = self.node_t_list["layout_part"].node
	ph = self.ph_list["ph_cell"]
	cell = BaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	cell:SetCellBgVis(false)
	cell:SetIsShowTips(false)
	cell:SetClickCallBack(BindTool.Bind(self.OnClickCell, self, 3))
	parent:addChild(cell:GetView(), 50)
	self.main_cell = cell

	local cell_list = {}
	for slot = 1, 5 do
		ph = self.ph_list["ph_cell_" .. slot]
		cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetIsShowTips(false)
		cell:SetClickCallBack(BindTool.Bind(self.OnClickSlotCell, self, slot))
		parent:addChild(cell:GetView(), 50)
		cell_list[slot] = cell
	end
	self.cell_list = cell_list

	ph = self.ph_list["ph_consume"] or {x = 0, y = 0}
	local cell = ActBaseCell.New()
	cell:GetView():setPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 20)
	self.consume_cell = cell

	self:AddObj("main_cell")
	self:AddObj("cell_list")
	self:AddObj("consume_cell")
end

function SpecialRingPartView:CreateAttrList()
	local ph = self.ph_list["ph_basis_attr"]
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.AttrTextRender, nil, nil, self.ph_list["ph_attr_txt_item"])
	list:SetItemsInterval(2)
	list:SetMargin(2)
	self.node_t_list["layout_bg"].node:addChild(list:GetView(), 50)
	self.basis_attr_list = list
	self:AddObj("basis_attr_list")

	local ph = self.ph_list["ph_fusion_attr"]
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.AttrTextRender, nil, nil, self.ph_list["ph_attr_txt_item"])
	list:SetItemsInterval(2)
	list:SetMargin(2)
	self.node_t_list["layout_bg"].node:addChild(list:GetView(), 50)
	self.fusion_attr_list = list
	self:AddObj("fusion_attr_list")
end

function SpecialRingPartView:CreatePower()
	local ph = self.ph_list["ph_power"]
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, ResPath.GetCommon("num_133_"))
	number_bar:SetSpace(-5)
	self.node_t_list["layout_bg"].node:addChild(number_bar:GetView(), 50)
	self.power = number_bar
	self:AddObj("power")
end

function SpecialRingPartView:CreateSkillList()
	local ph = self.ph_list["ph_skill_list"]
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, self.SkillIconRender, nil, nil, self.ph_list["ph_skill_item"])
	list:SetItemsInterval(2)
	list:SetMargin(2)
	self.node_t_list["layout_bg"].node:addChild(list:GetView(), 50)
	self.skill_list = list
	self:AddObj("skill_list")
end

function SpecialRingPartView:FlushCellList()
	self.special_ring_list = {}
	local item_data
	local in_put_list = SpecialRingData.Instance:GetInPutList()

	item_data = in_put_list[3]
	self.main_cell:SetData(item_data)

	self.select_slot = nil
	if item_data then
		table.insert(self.special_ring_list, item_data.item_id) -- 缓存主戒item_id
		for i,v in ipairs(item_data.special_ring) do
			local text_node = self.node_t_list["lbl_vice_name_" .. i]
			local _type = v.type
			local index = v.index
			if _type > 0 then
				local cfg = SpecialRingHandleCfg or {}
				local item_id_list = cfg.ItemIdIndxs and cfg.ItemIdIndxs[_type] and cfg.ItemIdIndxs[_type].ids or {}
				local item_id = item_id_list[index] or 1
				table.insert(self.special_ring_list, item_id) -- 缓存副戒item_id
				local item_cfg = ItemData.Instance:GetItemConfig(item_id)
				self.cell_list[i]:SetData(item_cfg)

				if text_node then
					text_node.node:setString(item_cfg.name)
					text_node.node:setColor(Str2C3b(string.format("%06x", item_cfg.color)))
				end

				if nil == self.select_slot then
					self:OnClickSlotCell(i, self.cell_list[i])
				end
			else
				self.cell_list[i]:SetData()

				if text_node then
					text_node.node:setString("未融合")
					text_node.node:setColor(Str2C3b("e5d69c"))
				end
			end
		end
		self.node_t_list["img_main_equip"].node:setVisible(false)
	else
		for i,v in ipairs(self.cell_list) do
			v:SetData()
			local text_node = self.node_t_list["lbl_vice_name_" .. i]
			if text_node then
				text_node.node:setString("")
				text_node.node:setColor(Str2C3b("e5d69c"))
			end
		end
		self.node_t_list["img_main_equip"].node:setVisible(true)
	end

end

function SpecialRingPartView:FlushConsume()
	local in_put_list = SpecialRingData.Instance:GetInPutList()
	local main_ring = in_put_list[3] -- 主戒

	if nil == main_ring then
		self.node_t_list["btn_1"].node:setEnabled(false)
		if self.consume_cell then
			self.consume_cell:GetView():setVisible(false)
		end
		self.node_t_list["lbl_consume_count"].node:setString("")
		return
	end
	local fusion_num = #main_ring.special_ring -- 已融合的特戒数量
	for i,v in ipairs(main_ring.special_ring) do
		if v.type == 0 then
			fusion_num = fusion_num - 1
		end
	end

	local cfg = SpecialRingHandleCfg or {}
	local consume_list = cfg.separateConsumes or {}
	local consume_data = consume_list[1] or {}
	local consume_id = consume_data.id or 1
	local consume_cfg_num = consume_data.count or 1
	local consume_bag_num = BagData.Instance:GetItemNumInBagById(consume_id)
	self.can_part = consume_bag_num >= consume_cfg_num
	self.consume_item_cfg = {item_id = consume_id, num = (consume_cfg_num - consume_bag_num)} -- 缓存消耗需求
	local consume_color = self.can_part and COLOR3B.GREEN or COLOR3B.RED

	self.consume_cell:GetView():setVisible(true)
	self.consume_cell:SetData({["item_id"] = consume_data.id, ["num"] = 1, ["is_bind"] = 0})

	-- 示例: "(0/2)"
	local text = string.format("%d/%d", consume_bag_num, consume_cfg_num)
	self.node_t_list["lbl_consume_count"].node:setString(text)
	self.node_t_list["lbl_consume_count"].node:setColor(consume_color)

	self.node_t_list["btn_1"].node:setEnabled(nil ~= self.select_slot) -- 消耗物品充足且已投入副戒时,启用按钮
end


function SpecialRingPartView:FlusAttrList()
	local in_put_list = SpecialRingData.Instance:GetInPutList()
	local main_item_data = in_put_list[3] or {} -- 投入的主戒
	local item_cfg = ItemData.Instance:GetItemConfig(main_item_data.item_id)
	local attr = ItemData.GetStaitcAttrs(item_cfg)
	-- 获取主戒属性
	local basis_attr_list = {}
	for i,v in ipairs(attr) do
		-- 筛选出要显示的属性
		if SpecialRingData.show_attr[v.type] then
			basis_attr_list[#basis_attr_list + 1] = v
		end
	end

	-- 获取所有融合特戒的属性
	local item_id_index = SpecialRingHandleCfg and SpecialRingHandleCfg.ItemIdIndxs or {}
	local fusion_attr_list = {}
	for i, fusion_info in ipairs(main_item_data.special_ring or {}) do
		if fusion_info.type ~= nil and fusion_info.type ~= 0 then
			----------从配置中获取融合的特戒item_id----------
			local _type = fusion_info.type
			local index = fusion_info.index or 0
			local item_id_list = item_id_index[_type] or {}
			local item_id = item_id_list.ids and item_id_list.ids[index]
			-----------------------end-----------------------
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			local attr = ItemData.GetStaitcAttrs(item_cfg)
			local show_attr = {}
			for i,v in ipairs(attr) do
				-- 筛选出要显示的属性
				if SpecialRingData.show_attr[v.type] then
					show_attr[#show_attr + 1] = v
				end
			end
			fusion_attr_list = CommonDataManager.AddAttr(fusion_attr_list, show_attr)
		end
	end
	basis_attr_list = CommonDataManager.AddAttr(basis_attr_list, fusion_attr_list)

	self.basis_attr_list:SetDataList(RoleData.FormatRoleAttrStr(basis_attr_list))
	self.fusion_attr_list:SetDataList(RoleData.FormatRoleAttrStr(fusion_attr_list))
end

function SpecialRingPartView:FlushPower()
	local in_put_list = SpecialRingData.Instance:GetInPutList()
	if in_put_list[3] then
		local score = ItemData.Instance:GetItemScoreByData(in_put_list[3], self.slot_info_change)
		self.power:SetNumber(score)
		self.slot_info_change = false
	else
		self.power:SetNumber(0)
	end
end

function SpecialRingPartView:FlushSkillList()
	self.skill_list:SetDataList(self.special_ring_list or {})
end

----------end----------

function SpecialRingPartView:OnClickBtn()
	if self.can_part then
		local in_put_list = SpecialRingData.Instance:GetInPutList()

		if nil == in_put_list[3] and self.select_slot then -- 正常情况下,都不会为空
			-- 请投入特戒或选择要分离的特戒，再进行分离
			SysMsgCtrl.Instance:FloatingTopRightText(Language.SpecialRing.FloatingText[9])
			return
		end

		local main_series = in_put_list[3].series or 0
		local slot = self.select_slot or 0
		SpecialRingCtrl.SendSpecialRingPartReq(main_series, slot - 1)

	else
		local item_id = self.consume_item_cfg.item_id
		local num = self.consume_item_cfg.num or 1
		TipCtrl.Instance:OpenGetNewStuffTip(item_id, num)
	end
end

function SpecialRingPartView:OpenTip()
	DescTip.Instance:SetContent(Language.DescTip.TeJieContent2, Language.DescTip.TeJieTitle2)
end

function SpecialRingPartView:OnClickSlotCell(slot, item)
	if type(item:GetData()) ~= "table" or nil == next(item:GetData()) then
		return
	end

	if self.select_slot then
		if self.select_slot == slot then
			return
		end

		self.cell_list[self.select_slot]:SetIsShowTips(false)
		self.node_t_list["img_select"].node:setVisible(false)
	end

	local x, y = item:GetView():getPosition()
	self.node_t_list["img_select"].node:setPosition(x + 40, y + 38)
	self.node_t_list["img_select"].node:setVisible(true)
	item:SetIsShowTips(true)

	self.select_slot = slot
	self:FlushConsume()
end

function SpecialRingPartView:OnClickCell(_type)
	SpecialRingData.Instance:SetInPutType(_type)
	ViewManager.Instance:OpenViewByDef(ViewDef.SpecialRingBag)
end

function SpecialRingPartView:OnInPutListChange(_type, item_data)
	self:Flush()
	if self.select_slot then
		self.cell_list[self.select_slot]:SetIsShowTips(false)
		self.node_t_list["img_select"].node:setVisible(false)
		self.select_slot = nil
	end
end

function SpecialRingPartView:OnSlotInfoChange(_type, item_data)
	self:Flush()
	if self.select_slot then
		self.cell_list[self.select_slot]:SetIsShowTips(false)
		self.node_t_list["img_select"].node:setVisible(false)
		self.select_slot = nil
	end
end

function SpecialRingPartView:OnBagItemChange()
	self:FlushConsume()
end

-- 属性文本
SpecialRingPartView.AttrTextRender = BaseClass(BaseRender)
local AttrTextRender = SpecialRingPartView.AttrTextRender
function AttrTextRender:__init()
end

function AttrTextRender:__delete()
end

function AttrTextRender:CreateChild()
	BaseRender.CreateChild(self)
end

function AttrTextRender:OnFlush()
	if type(self.data) ~= "table" then 
		self.node_tree["lbl_attr_txt"].node:setString("")
		return
	end

	local type_str = self.data.type_str or ""
	local value_str = self.data.value_str or ""
	self.node_tree["lbl_attr_name"].node:setString(type_str .. "：")
	self.node_tree["lbl_attr_txt"].node:setString(value_str)
end

function AttrTextRender:CreateSelectEffect()
end

----------------------------------------
-- 技能图标Render
----------------------------------------
SpecialRingPartView.SkillIconRender = BaseClass(BaseRender)
local SkillIconRender = SpecialRingPartView.SkillIconRender
function SkillIconRender:__init()

end

function SkillIconRender:__delete()
	self.skill_icon = nil
end

function SkillIconRender:CreateChild()
	BaseRender.CreateChild(self)
end

function SkillIconRender:OnFlush()
	if nil == self.data then return end

	local cfg = VirtualSkillCfg or {}
	local item_id = self.data
	local cur_skill = cfg[item_id] or {}
	local path = ResPath.GetItem(cur_skill.icon or 0)

	if self.skill_icon then
		self.skill_icon:loadTexture(path)
	else
		local x, y = 28, 28
		self.skill_icon = XUI.CreateImageView(x, y, path, XUI.IS_PLIST)
		self.skill_icon:setScale(0.7)
		self.view:addChild(self.skill_icon, 20)
		XUI.AddClickEventListener(self.skill_icon, BindTool.Bind(self.OnSkillIcon, self), true)	
	end
end

function SkillIconRender:OnSkillIcon()
	local item_id = self.data or 0
	SpecialRingCtrl.Instance:OpenSkillTip(item_id)
end

function SkillIconRender:CreateSelectEffect()
	return
end

function SkillIconRender:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end


--------------------
return SpecialRingPartView