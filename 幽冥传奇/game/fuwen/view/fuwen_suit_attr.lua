
local FuwenSuitAttrView = BaseClass(SubView)

function FuwenSuitAttrView:__init()
	self.texture_path_list = {
		'res/xui/fuwen.png',
	}
	self.config_tab = {
		{"fuwen_ui_cfg", 2, {0}},
	}
	self.remind_bg_sprite = {}
end
function FuwenSuitAttrView:__delete()
end

function FuwenSuitAttrView:ReleaseCallBack()
	self.rich_preview_attr = nil
	self.remind_bg_sprite = {}
end

function FuwenSuitAttrView:LoadCallBack(index, loaded_times)
	self:ShowPreviewRich()

	local size = self.node_t_list.img_title_1.node:getContentSize()
	self.node_t_list.img_title_1.node:addChild(XUI.CreateTextByType(size.width / 2, size.height / 2, 200, 20, "属性预览", 1))

	local size = self.node_t_list.img_title_2.node:getContentSize()
	self.node_t_list.img_title_2.node:addChild(XUI.CreateTextByType(size.width / 2, size.height / 2, 200, 20, "当前属性", 1))

	self.node_t_list.rich_suit_addition.node:setVerticalSpace(10)

	XUI.AddClickEventListener(self.node_t_list.img_decompose.node, function()
		self:GetViewManager():OpenViewByDef(ViewDef.FuwenDecompose)
	end, true)

	XUI.AddClickEventListener(self.node_t_list.img_exchange.node, function()
		self:GetViewManager():OpenViewByDef(ViewDef.FuwenExchange)
	end, true)

	local event_proxy = EventProxy.New(FuwenData.Instance, self)
	event_proxy:AddEventListener(FuwenData.FUWEN_ITEM_CHNAGE, BindTool.Bind(self.OnFuwenItemChange, self))
	event_proxy:AddEventListener(FuwenData.FUWEN_ZHULING_STATE, BindTool.Bind(self.OnFuwenZhulingState, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function FuwenSuitAttrView:OpenCallBack()
end

function FuwenSuitAttrView:ShowIndexCallBack(index)
	self:OnFlush()
end

function FuwenSuitAttrView:OnFlush()
	RichTextUtil.ParseRichText(self.node_t_list.rich_suit_addition.node, "{colorandsize;af8e58;22;必杀套装累计加成}\n" .. FuwenData.Instance:GetFuwenSuitAttrsRich())
	RichTextUtil.ParseRichText(self.node_t_list.rich_suit_list.node, FuwenData.Instance:GetSuitWordStateRich())

	local vis
	vis = FuwenData.Instance.GetCanDecomposeFuwenRemind() > 0
	self:SetRemind(self.node_t_list.img_decompose.node, vis, 1)

	vis = FuwenData.Instance.GetCanExchangeFuwenRemind() > 0
	self:SetRemind(self.node_t_list.img_exchange.node, vis, 2)
end

-- 设置提醒
function FuwenSuitAttrView:SetRemind(node, vis, index, path, x, y)
	path = path or ResPath.GetMainui("remind_flag")
	local size = node:getContentSize()
	x = x or size.width - 15
	y = y or size.height - 17
	if vis and nil == self.remind_bg_sprite[index] then
		self.remind_bg_sprite[index] = XUI.CreateImageView(x, y, path, true)
		node:addChild(self.remind_bg_sprite[index], 1, 1)
	elseif self.remind_bg_sprite[index] then
		self.remind_bg_sprite[index]:setVisible(vis)
	end
end

function FuwenSuitAttrView:ShowPreviewRich()
	local rich_content = FuwenData.Instance:GetSuitAttrsPreviewRich()
	local size = self.node_t_list.scroll_preview.node:getContentSize()
	if nil == self.rich_preview_attr then
		self.rich_preview_attr = RichTextUtil.ParseRichText(nil, "")
		self.rich_preview_attr:setAnchorPoint(0, 1)
		self.node_t_list.scroll_preview.node:addChild(self.rich_preview_attr)
		self.node_t_list.scroll_preview.node:setBounceEnabled(true)
	end

	RichTextUtil.ParseRichText(self.rich_preview_attr, rich_content, nil, nil, 0, 0, size.width, size.height, false)
	self.rich_preview_attr:refreshView()
	local content_size = self.rich_preview_attr:getInnerContainerSize()
	local scroll_h = math.max(content_size.height + 5, size.height)
	self.rich_preview_attr:setPosition(0, scroll_h)
	self.node_t_list.scroll_preview.node:setInnerContainerSize(cc.size(size.width, scroll_h))
	self.node_t_list.scroll_preview.node:jumpToTop()
end

function FuwenSuitAttrView:OnFuwenZhulingState()
	self:ShowPreviewRich()
end

function FuwenSuitAttrView:OnFuwenItemChange()
	self:OnFlush()
end
function FuwenSuitAttrView:OnBagItemChange()
	self:Flush()
end

return FuwenSuitAttrView
