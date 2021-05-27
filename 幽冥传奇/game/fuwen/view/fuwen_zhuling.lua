
local FuwenZhulingView = BaseClass(SubView)

function FuwenZhulingView:__init()
	self.texture_path_list = {
		'res/xui/fuwen.png',
	}
	self.config_tab = {
		{"fuwen_ui_cfg", 3, {0}},
	}
end

function FuwenZhulingView:__delete()
end

function FuwenZhulingView:ReleaseCallBack()
	if self.cur_attr then
		self.cur_attr:DeleteMe()
		self.cur_attr = nil
	end

	if self.next_attr then
		self.next_attr:DeleteMe()
		self.next_attr = nil
	end
end

function FuwenZhulingView:LoadCallBack(index, loaded_times)
	local size = self.node_t_list.img_title_1.node:getContentSize()
	self.node_t_list.img_title_1.node:addChild(XUI.CreateTextByType(size.width / 2, size.height / 2, 200, 20, "注灵属性", 1))

	self.node_t_list.btn_zhuling.node:setTitleText("注 灵")
	self.node_t_list.btn_zhuling.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_zhuling.node:setTitleFontSize(22)
	self.node_t_list.btn_zhuling.node:setTitleColor(COLOR3B.G_W2)
	self.node_t_list.btn_zhuling.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.btn_zhuling.node, 1)
	XUI.AddClickEventListener(self.node_t_list.btn_zhuling.node, BindTool.Bind(self.OnClickZhuling, self), true)

	XUI.RichTextSetCenter(self.node_t_list.rich_zhuling_suit_attr.node)
	XUI.RichTextSetCenter(self.node_t_list.rich_zhuling_consume.node)

	self.cur_attr = self:CreateAttrView(self.node_t_list.layout_fw_zhuling.node, self.ph_list.ph_cur_attr)
	self.next_attr = self:CreateAttrView(self.node_t_list.layout_fw_zhuling.node, self.ph_list.ph_next_attr)

	local event_proxy = EventProxy.New(FuwenData.Instance, self)
	event_proxy:AddEventListener(FuwenData.FUWEN_ZHULING_CHANGE, BindTool.Bind(self.OnFuwenZhulingChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function FuwenZhulingView:OpenCallBack()
end

function FuwenZhulingView:ShowIndexCallBack(index)
	self:Flush()
end

function FuwenZhulingView:OnFlush(param_t, index)
	self.cur_attr:SetData(FuwenData.Instance:GetZhulingAllAttrCfg())
	self.next_attr:SetData(FuwenData.Instance:GetNextZhulingAllAttrCfg())

	-- RichTextUtil.ParseRichText(self.node_t_list.rich_zhuling_suit_attr.node, )

	local consume_data = FuwenData.Instance:GetFuwenZhulingConsume()
	local rich_content = ""
	local is_enough = false
	if nil ~= consume_data then
		local need_num = consume_data[1] and consume_data[1].count or 0
		local have_num = BagData.Instance:GetItemNumInBagById(CLIENT_GAME_GLOBAL_CFG.fuwen_jh_id)
		is_enough = have_num >= need_num
		local color = is_enough and COLORSTR.GREEN or COLORSTR.RED
		rich_content = string.format("消耗：{color;%s;%d}/%d", color, have_num, need_num)
	end

	self.node_t_list.btn_zhuling.remind_eff:setVisible(is_enough)

	RichTextUtil.ParseRichText(self.node_t_list.rich_zhuling_consume.node, rich_content, 20, COLOR3B.OLIVE)
end

--------------------------------------------------------------------------------

function FuwenZhulingView:OnBagItemChange()
	self:Flush()
end

function FuwenZhulingView:OnFuwenZhulingChange()
	self:Flush()
end

function FuwenZhulingView:CreateAttrView(parent_node, ph)
	local attr_view = AttrView.New(300, 25, 20)
	attr_view:SetDefTitleText("")
	attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	attr_view:GetView():setPosition(ph.x, ph.y)
	attr_view:GetView():setAnchorPoint(0.5, 0.5)
	attr_view:SetContentWH(ph.w, ph.h)
	parent_node:addChild(attr_view:GetView(), 50)
	return attr_view
end

function FuwenZhulingView:OnClickZhuling()
	FuwenCtrl.SendUpFuwenReq()
end

return FuwenZhulingView
