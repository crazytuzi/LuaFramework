ZhanjiangView = ZhanjiangView or BaseClass(XuiBaseView)

function ZhanjiangView:InitRonghunView()
	self.ronghun_item_list = {}
	self.select_ronghun_cell = nil
	self.select_ronghun_slot = 1
	self.ronghun_attr_list = nil

	self:CreateRonghunItems()
	self:CreateRonghunAttrList()
	self:CreateRonghunAttrView()

	self.node_t_list.img_flag_3.node:setVisible(false)
	XUI.AddClickEventListener(self.node_t_list.btn_back.node, function() self:ChangeToIndex(TabIndex.zhanjiang_zhanjiang) end)
	XUI.AddClickEventListener(self.node_t_list.btn_active_ronghun.node, BindTool.Bind(self.OnClickActiveBtn, self))
	XUI.RichTextSetCenter(self.node_t_list.rich_ronghun_totallevel.node)
	XUI.RichTextSetCenter(self.node_t_list.rich_ronghun_consume.node)
end

function ZhanjiangView:DeleteRonghunView()
	if self.ronghun_item_list then
		for k, v in pairs(self.ronghun_item_list) do
			v:DeleteMe()
		end
		self.ronghun_item_list = nil
	end
	if self.select_ronghun_cell then
		self.select_ronghun_cell:DeleteMe()
		self.select_ronghun_cell = nil
	end

	if self.ronghun_attr_list then
		self.ronghun_attr_list:DeleteMe()
		self.ronghun_attr_list = nil
	end

	if self.ronghun_attr_view then
		self.ronghun_attr_view:DeleteMe()
		self.ronghun_attr_view = nil
	end

	self.select_ronghun_effect = nil
	self.old_level_list = nil
end

function ZhanjiangView:CreateRonghunItems()
	for i = 1, 8 do
		local ph = self.ph_list["ph_ronghun_item" .. i]
		local item_render = RonghunItemRender.New()
		item_render:SetPosition(ph.x, ph.y)
		item_render:SetIndex(i)
		item_render:SetAnchorPoint(0, 0)
		item_render:SetUiConfig(ph, false)
		item_render:AddClickEventListener(BindTool.Bind(self.OnClickRonghunItem, self, i))
		item_render:Flush()
		self.node_t_list.layout_ronghun.node:addChild(item_render:GetView(), 100)
		table.insert(self.ronghun_item_list, item_render)
	end
	local ph = self.ph_list.ph_select_ronghun_cell
	self.select_ronghun_cell = BaseCell.New()
	self.select_ronghun_cell:SetPosition(ph.x, ph.y)
	self.select_ronghun_cell:SetAnchorPoint(0.5, 0.5)
	self.select_ronghun_cell:SetIsShowTips(false)
	self.select_ronghun_cell:SetCellBg(ResPath.GetCommon("cell_105"))
	self.node_t_list.layout_ronghun_upgrade.node:addChild(self.select_ronghun_cell:GetView(), 100)

	self.select_ronghun_effect = AnimateSprite:create()
	self.select_ronghun_effect:setPosition(ph.x, ph.y)
	self.node_t_list.layout_ronghun_upgrade.node:addChild(self.select_ronghun_effect, 999)
end

function ZhanjiangView:CreateRonghunAttrList()
	local ph = self.ph_list.ph_ronghun_attr_list
	self.ronghun_attr_list = ListView.New()
	self.ronghun_attr_list:Create(ph.x, ph.y, ph.w, ph.h, nil, RonghunAttrItem, nil, nil, self.ph_list.ph_ronghun_attr_item)
	self.ronghun_attr_list:SetItemsInterval(5)
	self.ronghun_attr_list:GetView():setAnchorPoint(0, 0)
	self.ronghun_attr_list:SetJumpDirection(ListView.Top)
	self.node_t_list.layout_ronghun.node:addChild(self.ronghun_attr_list:GetView(), 100)
end

function ZhanjiangView:CreateRonghunAttrView()
	self.ronghun_attr_view = AttrView.New(300, 25, 20)
	self.ronghun_attr_view:GetView():setPosition(115, 176)
	self.ronghun_attr_view:SetDefTitleText(Language.Common.No)
	self.ronghun_attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	self.node_t_list.layout_ronghun_upgrade.node:addChild(self.ronghun_attr_view:GetView(), 100)
end

function ZhanjiangView:OnFlushRonghun(param_t)
	for k, v in pairs(param_t) do
		if k == "all" then
			self:CheckRonghunLevelup()

			local total_tab = ZhanjiangData.Instance:GetRonghunTotalAttr()
			local ronghun_data_list = ZhanjiangData.Instance:GetRonghunDataList()

			RichTextUtil.ParseRichText( self.node_t_list.rich_ronghun_totallevel.node, string.format(Language.Zhanjiang.RonghunTotalLevel, total_tab.total_level), 24,  COLOR3B.GOLD)
			for k, v in pairs(self.ronghun_item_list) do
				v:SetData(ronghun_data_list[k])
			end

			if total_tab.total_attr_cfg then
				self.ronghun_attr_list:SetDataList(RoleData.FormatRoleAttrStr(total_tab.total_attr_cfg))
			end

			if self.select_ronghun_slot > 0 then
				self:OnClickRonghunItem(self.select_ronghun_slot)
			end
		end
	end
	
end

function ZhanjiangView:CheckRonghunLevelup()
	if self.old_level_list == nil then
		self.old_level_list = {}
		for k, v in pairs(ZhanjiangData.Instance:GetRonghunDataList()) do
			self.old_level_list[k] = v.level
		end
	else
		for k, v in pairs(ZhanjiangData.Instance:GetRonghunDataList()) do
			local old_lv = self.old_level_list[k]
			if old_lv == 0 and v.level > old_lv then
				self:PlayShowEffect(901, 750, 250)
			elseif old_lv ~= 0 and v.level > old_lv then
				self:PlayShowEffect(902, 750, 250)
			end
			self.old_level_list[k] = v.level
		end
	end
end

function ZhanjiangView:OnClickRonghunItem(ronghun_slot)
	local name = ZhanjiangData.Instance:GetRonghunNameBySlot(ronghun_slot)
	self.select_ronghun_cell:SetBgTa(ResPath.GetWingResPath("ronghun_" .. ronghun_slot))
	RichTextUtil.ParseRichText(self.node_t_list.rich_select_ronghun_info.node, name)
	self.select_ronghun_slot = ronghun_slot

	local item_render = self.ronghun_item_list[ronghun_slot]
	local data = item_render and item_render:GetData()
	if nil == data then return end

	for k , v in pairs(self.ronghun_item_list) do
		v:SetSelect(k == ronghun_slot)
	end
	self.node_t_list.img_flag_3.node:setVisible(ZhanjiangData.Instance:CanRonghunLevelup(data) > 0)

	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(ronghun_slot + 1212 - 1)
	self.select_ronghun_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)

	local level = data.level
	local max_level = ZhanjiangData.Instance:GetRonghunMaxLevel(ronghun_slot)

	if level >= max_level then
		self.node_t_list.rich_ronghun_consume.node:setVisible(false)
		self.node_t_list.btn_active_ronghun.node:setVisible(false)
		self.ronghun_attr_view:SetDefTitleText(Language.Zhanjiang.RonghunMaxLevel)
		self.ronghun_attr_view:SetData()
	else
		self.node_t_list.rich_ronghun_consume.node:setVisible(true)
		self.node_t_list.btn_active_ronghun.node:setVisible(true)
		self.ronghun_attr_view:SetDefTitleText(Language.Common.No)
		RichTextUtil.ParseRichText(self.node_t_list.rich_select_ronghun_info.node, string.format("%s Lv：%d", name, level), 23, cc.c3b(0xde, 0xa5, 0x28))

		local btn_txt = level > 0 and Language.Zhanjiang.RonghunUpLevelBtnTxt[2] or Language.Zhanjiang.RonghunUpLevelBtnTxt[1]
		self.node_t_list.btn_active_ronghun.node:setTitleText(btn_txt)
		if level > 0 then
			local attr_cfg = ZhanjiangData.GetRonghunAttrCfg(ronghun_slot, level)
			local n_attr_cfg = ZhanjiangData.GetRonghunAttrCfg(ronghun_slot, level + 1)
			self.ronghun_attr_view:SetData(attr_cfg, CommonDataManager.LerpAttributeAttr(attr_cfg, n_attr_cfg))
		else
			self.ronghun_attr_view:SetData()
		end

		local consume_data = ZhanjiangData.Instance:GetRonghunUpGradeData(ronghun_slot, level + 1)
		if consume_data then
			local item_cfg = ItemData.Instance:GetItemConfig(consume_data.item_id)
			if item_cfg then
				local bag_num = BagData.Instance:GetItemNumInBagById(consume_data.item_id)
				local color = bag_num < consume_data.num and "#ff0000" or"#00ff00"
				XUI.SetButtonEnabled(self.node_t_list.btn_active_ronghun.node, bag_num >= consume_data.num)
				self.node_t_list.img_flag_3.node:setVisible(bag_num >= consume_data.num)
				RichTextUtil.ParseRichText(self.node_t_list.rich_ronghun_consume.node, string.format(Language.Zhanjiang.RonghunUpConsume, item_cfg.name, consume_data.num, color, bag_num))
			end
		end
	end
end

function ZhanjiangView:OnClickActiveBtn()
	ZhanjiangCtrl.UpgradeExerEnergyReq(self.select_ronghun_slot)
end

-- 融魂技能
RonghunItemRender = RonghunItemRender or BaseClass(BaseRender)
function RonghunItemRender:__init()

end

function RonghunItemRender:__delete()
	if self.ronghun_cell then
		self.ronghun_cell:DeleteMe()
		self.ronghun_cell = nil
	end
	self.ronghun_effect = nil
end

function RonghunItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_ronghun_cell
	self.ronghun_cell = BaseCell.New()
	self.ronghun_cell:SetPosition(ph.x, ph.y)
	self.ronghun_cell:SetAnchorPoint(0.5, 0.5)
	self.ronghun_cell:SetIsShowTips(false)
	self.ronghun_cell:GetCell():setTouchEnabled(false)
	self.ronghun_cell:SetSkinStyle( {bg = ResPath.GetCommon("cell_105"), bg_ta = "", cell_desc = ""} )
	self.ronghun_cell:SetOpen(false)
	self.view:addChild(self.ronghun_cell:GetCell())

	self.ronghun_effect = RenderUnit.CreateEffect(self.index + 1212 - 1, self.view, 100)
	self.ronghun_effect:setPosition(ph.x, ph.y)
	self.ronghun_effect:setVisible(false)
	XUI.RichTextSetCenter(self.node_tree.rich_ronghun_state.node)
end

function RonghunItemRender:OnFlush()
	if not self.data then return end
	local level = self.data.level
	local slot = self.data.slot
	local bg_ta = ResPath.GetWingResPath("ronghun_" .. slot)
	local consume_data = ZhanjiangData.Instance:GetRonghunUpGradeData(slot, level + 1)
	local state_text = ""
	if level > 0 then
		state_text = string.format(Language.Zhanjiang.RonghunItemStateTxt[1], level)
	else
		if consume_data ~= nil then
			local bag_num = BagData.Instance:GetItemNumInBagById(consume_data.item_id)
			state_text = bag_num >= consume_data.num and Language.Zhanjiang.RonghunItemStateTxt[2] or Language.Zhanjiang.RonghunItemStateTxt[3]
		else
			state_text = Language.Zhanjiang.RonghunItemStateTxt[3]
		end
	end
	self.ronghun_cell:SetOpen(level > 0)
	self.ronghun_cell:SetBgTa(level > 0 and bg_ta or "")
	self.ronghun_effect:setVisible(level > 0)
	RichTextUtil.ParseRichText(self.node_tree.rich_ronghun_state.node, state_text, 14)
end

function RonghunItemRender:CreateSelectEffect()
	-- self.select_effect = RenderUnit.CreateEffect(924, self.view, 999)
	-- self.select_effect:setPosition(self.ronghun_cell:GetView():getPosition())
	-- self.select_effect:setScale(1.25)
end

-- 融魂属性
RonghunAttrItem = RonghunAttrItem or BaseClass(BaseRender)
function RonghunAttrItem:__init()
end

function RonghunAttrItem:CreateChild()
	BaseRender.CreateChild(self)
	XUI.RichTextSetCenter(self.node_tree.rich_attr_value.node)
	self.node_tree.lbl_attr_name.node:setColor(cc.c3b(0xf5, 0xf3, 0xdf))
end

function RonghunAttrItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str .. "：")
	RichTextUtil.ParseRichText(self.node_tree.rich_attr_value.node, self.data.value_str)
end

function RonghunAttrItem:CreateSelectEffect()
end
