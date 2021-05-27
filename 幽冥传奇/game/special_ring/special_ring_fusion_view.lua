--------------------------------------------------------
-- 特戒-融合  配置 SpecialRingHandleCfg
--------------------------------------------------------

local SpecialRingFusionView = SpecialRingFusionView or BaseClass(SubView)

function SpecialRingFusionView:__init()
	self.texture_path_list[1] = 'res/xui/special_ring.png'
	self:SetModal(true) 
	self.config_tab = {
		{"special_ring_ui_cfg", 2, {0}},
		{"special_ring_ui_cfg", 4, {0}},
	}

	self.cell_list = {}
	self.view_index = 1
	self.can_fusion = false
	self.consume_item_cfg = nil
	self.is_long_click = false -- 是否是长按
	self.eff_list = nil
	self.cur_slot = nil
end

function SpecialRingFusionView:__delete()
end

--释放回调
function SpecialRingFusionView:ReleaseCallBack()
	self.is_long_click = nil
	self.eff_list = nil
	self.change_item_data = nil
end

--加载回调
function SpecialRingFusionView:LoadCallBack(index, loaded_times)
	self:CreateCellList()
	self:CreateAttrList()
	self:CreatePower()
	self:CreateSkillList()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnClickBtn, self))
	XUI.AddClickEventListener(self.node_t_list["btn_ques6"].node, BindTool.Bind(self.OpenTip, self))

	-- 数据监听
	EventProxy.New(SpecialRingData.Instance, self):AddEventListener(SpecialRingData.IN_PUT_LIST_CHANGE, BindTool.Bind(self.OnInPutListChange, self))
	EventProxy.New(SpecialRingData.Instance, self):AddEventListener(SpecialRingData.SLOT_INFO_CHANGE, BindTool.Bind(self.OnSlotInfoChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))


end

function SpecialRingFusionView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function SpecialRingFusionView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	SpecialRingData.Instance:ResetInPutList()
	SpecialRingData.Instance:SetInPutType(nil)
	self.can_fusion = false
	self.consume_item_cfg = nil
end

--显示指数回调
function SpecialRingFusionView:ShowIndexCallBack()
	self.cur_slot = nil

	self:Flush()
end
----------视图函数----------

function SpecialRingFusionView:OnFlush()
	self:FlushCellList()
	self:FlushConsume()
	self:FlusAttrList()
	self:FlushPower()
	self:FlushSkillList()
end

-- 创建格子
function SpecialRingFusionView:CreateCellList()
	local ph, cell
	local parent = self.node_t_list["layout_fusion"].node
	ph = self.ph_list["ph_cell"]
	cell = BaseCell.New()
	cell:SetPosition(ph.x, ph.y)
	cell:SetCellBgVis(false)
	cell:SetIsShowTips(false)
	cell:SetClickCallBack(BindTool.Bind(self.OnClickCell, self, 1))
	cell:SetLongClickCallBack(BindTool.Bind(self.OnLongClickCell, self, cell))
	parent:addChild(cell:GetView(), 50)
	self.main_cell = cell

	-- 最大融合次数
	local consume_cfg = SpecialRingHandleCfg and SpecialRingHandleCfg.fuseConsumesCfg or {}
	self.max_fusion_times = #consume_cfg

	local cell_list = {}
	for slot = 1, self.max_fusion_times do
		ph = self.ph_list["ph_cell_" .. slot] or {x = 0, y = 0}
		cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetIsShowTips(false)
		cell:SetClickCallBack(BindTool.Bind(self.OnClickCell, self, 2, slot))
		cell:SetLongClickCallBack(BindTool.Bind(self.OnLongClickCell, self, cell))
		parent:addChild(cell:GetView(), 10)
		table.insert(cell_list, cell)
	end
	self.vice_cell_list = cell_list

	ph = self.ph_list["ph_consume"] or {x = 0, y = 0}
	local cell = ActBaseCell.New()
	cell:GetView():setPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 20)
	self.consume_cell = cell

	self:AddObj("main_cell")
	self:AddObj("vice_cell_list")
	self:AddObj("consume_cell")
end

function SpecialRingFusionView:CreateAttrList()
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

function SpecialRingFusionView:CreatePower()
	local ph = self.ph_list["ph_power"]
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, ResPath.GetCommon("num_133_"))
	number_bar:SetSpace(-5)
	self.node_t_list["layout_bg"].node:addChild(number_bar:GetView(), 50)
	self.power = number_bar
	self:AddObj("power")
end

function SpecialRingFusionView:CreateSkillList()
	local ph = self.ph_list["ph_skill_list"]
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, self.SkillIconRender, nil, nil, self.ph_list["ph_skill_item"])
	list:SetItemsInterval(2)
	list:SetMargin(2)
	self.node_t_list["layout_bg"].node:addChild(list:GetView(), 50)
	self.skill_list = list
	self:AddObj("skill_list")
end

function SpecialRingFusionView:FlushCellList()
	self.special_ring_list = {}
	self.cur_slot = nil
	local in_put_list = SpecialRingData.Instance:GetInPutList()

	local main_item_data = in_put_list[1]
	self.main_cell:SetData(main_item_data)
	if main_item_data then
		local item_cfg = ItemData.Instance:GetItemConfig(main_item_data.item_id)
		table.insert(self.special_ring_list, main_item_data.item_id) -- 缓存主戒item_id
		self.node_t_list["lbl_main_name"].node:setString(item_cfg.name)
		self.node_t_list["lbl_main_name"].node:setColor(Str2C3b(string.format("%06x", item_cfg.color)))

		 -- 获取主戒的已融合信息
		local special_ring = main_item_data.special_ring or {}

		local item_id_index = SpecialRingHandleCfg and SpecialRingHandleCfg.ItemIdIndxs or {}
		for slot, fusion_info in ipairs(special_ring) do
			local cell = self.vice_cell_list[slot]
			local text_node = self.node_t_list["lbl_vice_name_" .. slot]
			if cell then
				if fusion_info.type ~= nil and fusion_info.type ~= 0 then

					----------从配置中获取融合的特戒item_id----------
					local _type = fusion_info.type
					local index = fusion_info.index or 0
					local item_id_list = item_id_index[_type] or {}
					local item_id = item_id_list.ids and item_id_list.ids[index]
					-----------------------end-----------------------
					table.insert(self.special_ring_list, item_id) -- 缓存副戒item_id

					local item_cfg = ItemData.Instance:GetItemConfig(item_id)
					cell:SetData(item_cfg)
					if text_node then
						text_node.node:setString(item_cfg.name)
						text_node.node:setColor(Str2C3b(string.format("%06x", item_cfg.color)))
					end
				else
					if not self.cur_slot then
						self.node_t_list["img_main_equip"].node:setVisible(true)
						local ph = self.ph_list["ph_cell_" .. slot] or {x = 0, y = 0}
						self.node_t_list["img_main_equip"].node:setPosition(ph.x + 40, ph.y + 40)
						self.cur_slot = slot
					end

					cell:SetData()
					if text_node then
						text_node.node:setString("未融合")
						text_node.node:setColor(Str2C3b("e5d69c"))
					end
				end
			end
		end
	else
		self.node_t_list["lbl_main_name"].node:setString("")
		local ph = self.ph_list["ph_cell"] or {x = 0, y = 0}
		self.node_t_list["img_main_equip"].node:setVisible(true)
		self.node_t_list["img_main_equip"].node:setPosition(ph.x + 40, ph.y + 40)

		for slot = 1, self.max_fusion_times do
			local cell = self.vice_cell_list[slot]
			cell:SetData()
			local text_node = self.node_t_list["lbl_vice_name_" .. slot]
			if  text_node then
				text_node.node:setString("")
				text_node.node:setColor(Str2C3b("e5d69c"))
			end
		end
	end
end

function SpecialRingFusionView:FlushConsume()
	local can_fusion = false -- 可进行融合
	local in_put_list = SpecialRingData.Instance:GetInPutList()
	local main_item_data = in_put_list[1] or {} -- 主戒
	local fusion_num = #(main_item_data.special_ring or {}) -- 可融合的特戒数量
	for i,v in ipairs(main_item_data.special_ring or {}) do
		if v.type == 0 then
			fusion_num = fusion_num - 1
			can_fusion = true
		end
	end

	if (not can_fusion) then
		-- 不可进行融合时
		self.node_t_list["btn_1"].node:setEnabled(false)
		if self.consume_cell then
			self.consume_cell:GetView():setVisible(false)
		end
		self.node_t_list["lbl_consume_count"].node:setString("")
		return
	end

	local cfg = SpecialRingHandleCfg or {}
	local consume_list = cfg.fuseConsumesCfg or {}
	local consume_data = consume_list[fusion_num + 1] and consume_list[fusion_num + 1][1] or {}
	local consume_id = consume_data.id or 1
	local consume_cfg_num = consume_data.count or 1
	local consume_bag_num = BagData.Instance:GetItemNumInBagById(consume_id)
	self.can_fusion = consume_bag_num >= consume_cfg_num
	local consume_color = self.can_fusion and COLOR3B.GREEN or COLOR3B.RED
	self.consume_item_cfg = {item_id = consume_id, num = (consume_cfg_num - consume_bag_num)} -- 缓存消耗需求

	self.consume_cell:GetView():setVisible(true)
	self.consume_cell:SetData({["item_id"] = consume_data.id, ["num"] = 1, ["is_bind"] = 0})
	
	-- 示例: "(0/2)"
	local text = string.format("%d/%d", consume_bag_num, consume_cfg_num)
	self.node_t_list["lbl_consume_count"].node:setString(text)
	self.node_t_list["lbl_consume_count"].node:setColor(consume_color)

	self.node_t_list["btn_1"].node:setEnabled(nil ~= in_put_list[2]) -- 已投入副戒时,启用按钮
end

function SpecialRingFusionView:FlusAttrList()
	local in_put_list = SpecialRingData.Instance:GetInPutList()
	local main_item_data = in_put_list[1] or {} -- 投入的主戒
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

function SpecialRingFusionView:FlushPower()
	local in_put_list = SpecialRingData.Instance:GetInPutList()
	if in_put_list[1] then
		local score = ItemData.Instance:GetItemScoreByData(in_put_list[1], self.slot_info_change)
		self.power:SetNumber(score)
		self.slot_info_change = false
	else
		self.power:SetNumber(0)
	end
end

function SpecialRingFusionView:FlushSkillList()
	self.skill_list:SetDataList(self.special_ring_list or {})
end

----------end----------

function SpecialRingFusionView:OnClickBtn()
	if self.can_fusion then
		local in_put_list = SpecialRingData.Instance:GetInPutList()

		if nil == in_put_list[1] or nil == in_put_list[2] then -- 正常情况下,都不会为空
			SysMsgCtrl.Instance:FloatingTopRightText("请投入主戒或副戒，再进行融合")
			return
		end

		local main_series = in_put_list[1].series or 0
		local vice_series = in_put_list[2].series or 0
		SpecialRingCtrl.SendSpecialRingFusionReq(main_series, vice_series)
	else
		local item_id = self.consume_item_cfg.item_id or 0
		local num = self.consume_item_cfg.num or 1
		TipCtrl.Instance:OpenGetNewStuffTip(item_id, num)
		-- local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
		-- local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
		-- TipCtrl.Instance:OpenBuyTip(data)
	end
end

function SpecialRingFusionView:OpenTip()
	DescTip.Instance:SetContent(Language.DescTip.TeJieContent, Language.DescTip.TeJieTitle)
end

function SpecialRingFusionView:OnClickCell(_type, slot)
	 if self.is_long_click then
	 	self.is_long_click = false
	 	return
	 end

	 -- 点击 主戒 和 当前融合槽位 才可投入特戒
	 if _type == 1 or self.cur_slot == slot then
		SpecialRingData.Instance:SetInPutType(_type)
		ViewManager.Instance:OpenViewByDef(ViewDef.SpecialRingBag)
	 end

end

function SpecialRingFusionView:OnLongClickCell(cell)
	local item_data = cell:GetData()
	self.is_long_click = item_data ~= nil
	if self.is_long_click then
		TipCtrl.Instance:OpenItem(item_data, EquipTip.FROM_NORMAL)
	end
end

function SpecialRingFusionView:OnInPutListChange(_type, item_data)
	if _type == 1 then
		self:Flush()
	elseif _type == 2 then
		local cell = self.vice_cell_list[self.cur_slot or 0]
		if cell then
			cell:SetData(item_data)
		end
		self.node_t_list["img_main_equip"].node:setVisible(false)

		self:FlushConsume()
	end
end

function SpecialRingFusionView:OnSlotInfoChange(_type, item_data)
	if _type > 0 then
		SpecialRingCtrl.Instance:OpenTip(item_data) -- 打开融合成功提示面板
		self.slot_info_change = true
	end

	self:Flush()
end

function SpecialRingFusionView:OnBagItemChange()
	self:FlushConsume()
end

-- 属性文本
SpecialRingFusionView.AttrTextRender = BaseClass(BaseRender)
local AttrTextRender = SpecialRingFusionView.AttrTextRender
function AttrTextRender:__init()
end

function AttrTextRender:__delete()
end

function AttrTextRender:CreateChild()
	BaseRender.CreateChild(self)
end

function AttrTextRender:OnFlush()
	if nil == self.data then 
		self.node_tree.lbl_attr_txt.node:setString("")
		return 
	end
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str .. "：")
	self.node_tree.lbl_attr_txt.node:setString(self.data.value_str)
end

function AttrTextRender:CreateSelectEffect()
end

----------------------------------------
-- 技能图标Render
----------------------------------------
SpecialRingFusionView.SkillIconRender = BaseClass(BaseRender)
local SkillIconRender = SpecialRingFusionView.SkillIconRender
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
	local cfg = VirtualSkillCfg or {}
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
return SpecialRingFusionView