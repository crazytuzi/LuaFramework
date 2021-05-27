------------------------------------------------------------
--物品tip
------------------------------------------------------------
PreviewTip = PreviewTip or BaseClass(CardBaseTips)

function PreviewTip:__init()
	self.is_async_load = false
	self.zorder = COMMON_CONSTS.ZORDER_ITEM_TIPS
	self.is_any_click_close = true
	self.texture_path_list[1] = 'res/xui/equipment.png'
	self.texture_path_list[2] = 'res/xui/card_handlebook.png'
	self.config_tab = {{"itemtip_ui_cfg", 12, {0}}}
	self.is_modal = true

	self.buttons = {}
	self.label_t = Language.Tip.ButtonLabel
	self.handle_param_t = self.handle_param_t or {}

	self.desc_item_t = nil
	self.data = nil
end

function PreviewTip:ReleaseCallBack()
	self.data = nil
	self.buttons = {}
	self.handle_param_t = {}
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	if self.desc_item_t then
		for k,v in pairs(self.desc_item_t) do
			v:DeleteMe()
			v = nil
		end
	end
	self.desc_item_t = nil
end

function PreviewTip:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		self:CreateItemCell()
		self:CreateCardShowItem()
		self:CreateCardRightDescItem()

		self.buttons = {self.node_t_list.btn_0.node, self.node_t_list.btn_1.node, 
			self.node_t_list.btn_2.node, self.node_t_list.btn_3.node}
		for k, v in pairs(self.buttons) do
			v:addClickEventListener(BindTool.Bind1(self.OperationClickHandler, self))
		end
	end
end

function PreviewTip:OnFlush(param_t)
	self:FlushTop()
	self:FlushCardRightDesc()
	self:ShowOperationState()
end

function PreviewTip:FlushTop()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then 
		return 
	end

	local cell_data = TableCopy(self.data)
	cell_data.num = 0
	self.cell:SetData(cell_data)

	self.card_item:SetData(self.data)

	RichTextUtil.ParseRichText(self.node_t_list.rich_itemname_txt.node, item_cfg.name, 24, Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))
	
	--等级和物品类型
	local limit_level = 0
	local zhuan = 0
	for k,v in pairs(item_cfg.conds) do
		if v.cond == ItemData.UseCondition.ucLevel then
			limit_level = v.value
			if not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
				self.node_t_list.top_txt2.node:setColor(COLOR3B.RED)
			end
		end
		if v.cond == ItemData.UseCondition.ucMinCircle then
			zhuan = v.value
			if v.value > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) then
				self.node_t_list.top_txt2.node:setColor(COLOR3B.RED)
			end
		end
	end
	if zhuan > 0 then
		self.node_t_list.top_txt2.node:setString(string.format(Language.Tip.ZhuanDengJi, zhuan, limit_level))
	else
		self.node_t_list.top_txt2.node:setString(string.format(Language.Tip.DengJi, limit_level))
	end
	self.node_t_list.top_txt1.node:setString(string.format(Language.Tip.ZhuangBeiLeiXing, ItemData.GetItemTypeName(item_cfg.type)))
end

function PreviewTip:FlushCardRightDesc()
	local attrs = CardHandlebookData.Instance:GetAttrByItemId(self.data.item_id)
	local rich_content = RoleData.FormatAttrContent(attrs or {}, {type_str_color = COLOR3B.OLIVE, prof_ignore = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)})
	self.desc_item_t[1]:SetData({desc_name = Language.Tip.BaseAttr, content = rich_content})
	local card_exp = CardHandlebookData.GetDecomposeCardExp(self.data.item_id)
	local content = string.format(Language.CardHandlebook.CardExpStr, CardHandlebookData.Instance:GetCardTypeName(self.data.item_id), card_exp)
	self.desc_item_t[2]:SetData({desc_name = Language.Tip.SerType, content = content})
	self.desc_item_t[2]:GetView():setPositionY(0)
end

function PreviewTip:CreateItemCell()
	self.cell = BaseCell.New()
	self.node_t_list.layout_card_content.node:addChild(self.cell:GetCell(), 200)
	local ph_itemcell = self.ph_list.ph_itemcell --占位符
	self.cell:GetCell():setPosition(ph_itemcell.x, ph_itemcell.y)
	self.cell:SetIsShowTips(false)
end

function PreviewTip:CreateCardShowItem()
	local ph = self.ph_list.ph_card_item
	self.card_item = CardTipsItemRender.New()
	self.card_item:SetUiConfig(ph, true)
	self.node_t_list.layout_preview_item_tips.node:addChild(self.card_item:GetView(), 999)
	self.card_item:GetView():setPosition(ph.x, ph.y)
end

function PreviewTip:CreateCardRightDescItem()
	self:CreateRightDescItem()
	self:CreateRightDescItem()
end

function PreviewTip:CreateRightDescItem()
	self.desc_item_t = self.desc_item_t or {}
	local ph = self.ph_list.ph_right_desc_item
	local desc_item = CardDescItemRender.New()
	desc_item:SetUiConfig(ph, true)
	self.node_t_list.layout_preview_item_tips.node:addChild(desc_item:GetView(), 999)
	desc_item:GetView():setPosition(ph.x, ph.y)
	table.insert(self.desc_item_t, desc_item)
end

-------------------
--图鉴Tips 展示render
-------------------
CardTipsItemRender = CardTipsItemRender or BaseClass(BaseRender)
function CardTipsItemRender:__init()

end

function CardTipsItemRender:__delete()
	if nil ~= self.card_power_num then
		self.card_power_num:DeleteMe()
		self.card_power_num = nil
	end	
end

function CardTipsItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateCardOnePowerNumberBar()
end

function CardTipsItemRender:CreateCardOnePowerNumberBar()
	self.card_power_num = NumberBar.New()
	self.card_power_num:SetRootPath(ResPath.GetMainuiRoot() .. "num_")
	self.card_power_num:SetPosition(60, -2)
	self.card_power_num:SetSpace(-2)
	self.card_power_num:SetGravity(NumberBarGravity.Left)
	self.node_tree.img_peerless_cap.node:addChild(self.card_power_num:GetView(), 300, 300)
end

function CardTipsItemRender:OnFlush()
	if nil == self.data then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then 
		return 
	end

	self.node_tree.img_card.node:loadTexture(ResPath.GetCardHandlebookImg(self.data.item_id))
	local type_index, ser_index = CardHandlebookData.GetCardSeriessAndIndexById(self.data.item_id)
	self.card_power_num:SetNumber(CommonDataManager.GetAttrSetScore(CardHandlebookData.GetOneCardAttr(type_index, ser_index, 0)))

	local color = string.format("%06x", item_cfg.color)
	local level_bg = CardHandlebookData.Instance.GetCardShowLevelByColor(color)
	-- self.node_tree.img_level.node:loadTexture(ResPath.GetCardHandlebook(string.format("level_%d_bg", level_bg)))
	self.node_tree.img_level.node:setScale(0.9)
end

-------------------
--图鉴Tips 描述render
-------------------
CardDescItemRender = CardDescItemRender or BaseClass(BaseRender)

function CardDescItemRender:OnFlush()
	if nil == self.data then return end
	RichTextUtil.ParseRichText(self.node_tree.rich_item_dec.node, self.data.content, 20)
	self.node_tree.rich_item_dec.node:refreshView()
	self.node_tree.lbl_item_descrp.node:setString(self.data.desc_name)
end
