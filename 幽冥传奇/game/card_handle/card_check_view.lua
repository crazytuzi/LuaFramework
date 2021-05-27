CardHandlebookCheckView = CardHandlebookCheckView or BaseClass(BaseView)

function CardHandlebookCheckView:__init()
	self:SetIsAnyClickClose(true)
	self.def_index = 1
	self.texture_path_list[1] = 'res/xui/card_handlebook.png'
	self.config_tab = {
		{"card_handlebook_ui_cfg", 4, {0}},
	}
	self.is_jihuo = false
end

function CardHandlebookCheckView:__delete()
end

function CardHandlebookCheckView:ReleaseCallBack()
	if self.card_up_progressbar then
		self.card_up_progressbar:DeleteMe()
		self.card_up_progressbar = nil
	end

	if self.card_item then
		self.card_item:DeleteMe()
		self.card_item = nil
	end
	
	self.top_tip = nil
end

function CardHandlebookCheckView:LoadCallBack(index, loaded_times)
	self.card_up_progressbar = ProgressBar.New()
	self.card_up_progressbar:SetView(self.node_t_list.prog9_card.node)
	self.card_up_progressbar:SetTailEffect(991, nil, true)
	self.card_up_progressbar:SetEffectOffsetX(-20)
	self.card_up_progressbar:SetPercent(0)
	self:CreateCardItem()

	XUI.RichTextSetCenter(self.node_t_list.rich_jihuo_need.node)

	self.type_index = 0
	self.caowei_index = 0

	-- self.decompose_txt = RichTextUtil.CreateLinkText("", 20, COLOR3B.GREEN, nil, true)
	-- self.decompose_txt:setPosition(self.node_t_list.layout_check.node:getContentSize().width / 4 * 3+10, 70)
	-- XUI.AddClickEventListener(self.decompose_txt, BindTool.Bind(self.OnClickOpenView, self), true)
	-- self.node_t_list.layout_check.node:addChild(self.decompose_txt, 10)

	EventProxy.New(CardHandlebookData.Instance, self):AddEventListener(CardHandlebookData.UPDATE_CARD_INFO, BindTool.Bind(self.OnFlushCardInfo, self))
	EventProxy.New(CardHandlebookData.Instance, self):AddEventListener(CardHandlebookData.CLICK_CARD_DATA, BindTool.Bind(self.OnClickCardData, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	
	self:OnClickCardData()
end

function CardHandlebookCheckView:CreateCardItem()
	local ph = self.ph_list.ph_check_item
	self.card_item = CardGridItemRender.New()
	self.card_item:SetUiConfig(ph, true)
	self.node_t_list.layout_check.node:addChild(self.card_item:GetView(), 999)
	self.card_item:GetView():setPosition(ph.x, ph.y)
end

local get_need_string = function (id)
	local item_cfg = ItemData.Instance:GetItemConfig(id)
	if nil == item_cfg then return end
	local color = string.format("%06x", item_cfg.color)
	local item_name = ItemData.Instance:GetItemName(id)
	return string.format(Language.CardHandlebook.NeedText, color, item_name)
end

function CardHandlebookCheckView:OnFlush(param_t)
end

function CardHandlebookCheckView:OnClickOpenView()
	if self.is_jihuo then
		ViewManager.Instance:OpenViewByDef(ViewDef.CardHandlebook.Descompose)
	else

	end
end

function CardHandlebookCheckView:OnClickCardData()
	local data = CardHandlebookData.Instance:GetOpenCardData()
	if data then 
		self.type_index = data.xl_index
		self.caowei_index = data.cw_index
		self:OnFlushCardInfo()
	end
end

function CardHandlebookCheckView:OnFlushCardInfo()
	local data = CardHandlebookData.Instance:GetOneCardShowData(self.type_index, self.caowei_index)
	self:FlushCardLevel(data)
	self:FlushCardAttr(data)
	self:FlushProgData(data)
	self:FlushActiveConsume(data)
end

function CardHandlebookCheckView:FlushCardLevel(data)
	self.card_item:SetData(data)
	self.is_jihuo = data.is_jihuo
	-- local txt = data.is_jihuo and Language.CardHandlebook.ObtainExp[2] or Language.CardHandlebook.ObtainExp[1]
	-- self.decompose_txt:setString(txt)
	local max_level = #CardHandlebookData.GetServerPokedexAttrCfg(self.type_index)[self.caowei_index] - 1
	self.node_t_list.layout_jihuo_view.node:setVisible(not data.is_jihuo)
	self.node_t_list.layout_up_view.node:setVisible(data.is_jihuo and data.level < max_level)
	if data.level == max_level and nil == self.top_tip then
		self.top_tip = XUI.CreateImageView(240, 130, ResPath.GetCardHandlebook("top_tip"))
		self.node_t_list.layout_check.node:addChild(self.top_tip, 99)
	end
	if self.top_tip then
		self.top_tip:setVisible(data.is_jihuo and data.level == max_level)
	end
end

function CardHandlebookCheckView:FlushCardAttr(data)
	local right_txt, left_txt = CardHandlebookData.GetOneCardAttrShowString(self.type_index, self.caowei_index, data.level)
	if nil == right_txt or nil == left_txt then
		local one_txt = right_txt and right_txt or left_txt
		RichTextUtil.ParseRichText(self.node_t_list.rich_card_one_attr.node, one_txt, 18):setVerticalSpace(10)
	else	
		RichTextUtil.ParseRichText(self.node_t_list.rich_card_attr1.node, right_txt, 18):setVerticalSpace(10)
		RichTextUtil.ParseRichText(self.node_t_list.rich_card_attr2.node, left_txt, 18):setVerticalSpace(10)
	end
	self.node_t_list.rich_card_one_attr.node:setVisible(nil == right_txt or nil == left_txt)
	self.node_t_list.img_arrow.node:setVisible(nil ~= right_txt and nil ~= left_txt)
	self.node_t_list.rich_card_attr1.node:setVisible(nil ~= right_txt and nil ~= left_txt)
	self.node_t_list.rich_card_attr2.node:setVisible(nil ~= right_txt and nil ~= left_txt)
end

function CardHandlebookCheckView:FlushProgData(data)
	local per = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RIDE_LEVEL) / CardHandlebookData.Instance.GetOneCardConsumNum(self.type_index, self.caowei_index, data.level)
	local per_show_string = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RIDE_LEVEL) .. "/" ..  CardHandlebookData.Instance.GetOneCardConsumNum(self.type_index, self.caowei_index, data.level)
	self.card_up_progressbar:SetPercent(per * 100, false)
	self.node_t_list.lbl_wing_prog.node:setString(per_show_string)
end

function CardHandlebookCheckView:FlushActiveConsume(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then return end
	local color = string.format("%06x", item_cfg.color)
	local item_name = ItemData.Instance:GetItemName(data.item_id)
	local str = string.format(Language.CardHandlebook.NeedText, color, item_name)
	RichTextUtil.ParseRichText(self.node_t_list.rich_jihuo_need.node, str, 22)
end

function CardHandlebookCheckView:OnBagItemChange(event)
	event.CheckAllItemDataByFunc(function (vo)
		if ItemData.GetIsCard(vo.item_id) then
			self:OnFlushCardInfo()
		end
	end)
end