------------------------------------------------------------
--神炉装备tips
------------------------------------------------------------
ComposeEquipTip = ComposeEquipTip or BaseClass(XuiBaseView)

function ComposeEquipTip:__init()
	self.is_async_load = false
	self.zorder = COMMON_CONSTS.ZORDER_ITEM_TIPS
	self.is_any_click_close = true
	self.texture_path_list[1] = 'res/xui/equipment.png'
	self.config_tab = {{"itemtip_ui_cfg", 1, {0}}}
	self.is_modal = true
end	

function ComposeEquipTip:__delete()
end

function ComposeEquipTip:LoadCallBack()
	self.rich_itemname_txt = self.node_t_list.rich_itemname_txt.node
	self.lbl_marks = self.node_t_list.top_txt3.node
	self.lbl_marks:setVisible(false)
	self.lbl_level = self.node_t_list.top_txt2.node
	self.lbl_type = self.node_t_list.top_txt1.node
	self.lbl_sex = self.node_t_list.top_txt4.node
	self.lbl_sex:setVisible(false)
	self.layout_btns = self.node_t_list.layout_btns.node
	self.layout_btns:setAnchorPoint(0.5, 0)
	self.layout_btns:setVisible(false)
	self.itemtips_bg = self.node_t_list.img9_itemtips_bg.node

	self.cell = BaseCell.New()
	self.layout_content_top = self.node_t_list.layout_content_top.node
	self.layout_content_top:setAnchorPoint(0.5, 0)
	self.layout_content_top:addChild(self.cell:GetCell(), 200)
	local ph_itemcell = self.ph_list.ph_itemcell --占位符
	self.cell:GetCell():setPosition(ph_itemcell.x, ph_itemcell.y)
	self.cell:SetIsShowTips(false)

	local layout = XUI.CreateLayout(0, 0, 0, 200)
	local line = XImage:create(ResPath.GetCommon("line_101"), true)
	layout:addChild(line, 2)
	line:setPosition(150, 360)
	local line_2 = XImage:create(ResPath.GetCommon("line_101"), true)
	line_2:setPosition(150, 442)
	layout:addChild(line_2, 2)
	self.root_node:addChild(layout,100)

	self.baseAttrTitles = {}
	self.baseAttrs = {}
	for i = 1, 3 do
		self.baseAttrTitles[i] = XUI.CreateText(70,i * (-30) + 360,100,30,0," ")
		self.baseAttrs[i] = XUI.CreateText(70 + 100,i * (-30) +360,100,30,0," ")
		layout:addChild(self.baseAttrTitles[i],100)
		layout:addChild(self.baseAttrs[i],100)
	end	
	local strengthen_title = XUI.CreateText(40, 414, 40, 30, cc.TEXT_ALIGNMENT_LEFT, Language.Tip.Qianghua, font, font_size, COLOR3B.R_Y, v_alignment)
	local infuse_spiri_title = XUI.CreateText(40, 381, 40, 30, cc.TEXT_ALIGNMENT_LEFT, Language.Tip.InfuseLevel, font, font_size, COLOR3B.R_Y, v_alignment)
	layout:addChild(strengthen_title)
	layout:addChild(infuse_spiri_title)
	self.star_diamond_layout = self.node_t_list.layout_star_diamond.node
	self.star_diamond_layout:setPosition(80, 296)
	self.itemtips_bg:setContentWH(455, 350)
	self.layout_content_top:setPositionY(350)
	self.node_t_list.btn_close_window.node:setPositionY(464)
end	


function ComposeEquipTip:OnFlush(param_t)
	self:ShowTipContent()
end

function ComposeEquipTip:SetData(data)
	self.data = data
	self:Open()
	self:Flush()
end

function ComposeEquipTip:ShowTipContent()
	self.cell:SetData(self.data)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.lbl_level:setString("Lv." .. self.data.compose_level)
	RichTextUtil.ParseRichText(self.rich_itemname_txt, item_cfg.name, 20, Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))


	local composeType = ComposeData.Instance:GetComposeTypeByItemType(item_cfg.type)
	local attrs_t = ComposeData.Instance:GetAttr(composeType,self.data.compose_level)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local title_attrs = RoleData.FormatRoleAttrStr(attrs_t, is_range)
	
	for i = 1, 3 do
		self.baseAttrTitles[i]:setString(title_attrs[i] and title_attrs[i].type_str .. "：" or "")
		self.baseAttrs[i]:setString(title_attrs[i] and title_attrs[i].value_str or "")
	end

	self.diamond_list = {}
	local star = self.data.infuse_level or 0
	local length = item_cfg.injectLimit or 0
	local ph = self.ph_list.ph_diamond_s
	local path = nil
	for i = 1, length, 1 do
		if star >= i then
			path = ResPath.GetCommon("icon_diamond")
		else
			path = ResPath.GetCommon("icon_diamond_an")
		end
		local img = XUI.CreateImageView(ph.x + (i - 1) * 28, ph.y, path, true)
		self.star_diamond_layout:addChild(img)
	end	

	star = self.data.strengthen_level or 0
	length = item_cfg.strongLimit or 0
	ph = self.ph_list.ph_star_s
	path = nil
	for i = 1, length, 1 do
		if star >= i then
			path = ResPath.GetCommon("star_1_select")
		else
			path = ResPath.GetCommon("star_1_lock")
		end
		local img = XUI.CreateImageView(ph.x + (i - 1) * 28, ph.y, path, true)
		self.star_diamond_layout:addChild(img)
	end
end

