FuhuoNoBtnView = FuhuoNoBtnView or BaseClass(FuhuoView)

function FuhuoNoBtnView:__init()
	self.config_tab = {
		{"fuhuo_ui_cfg", 2, {0},},
	}
end

function FuhuoNoBtnView:__delete()

end

function FuhuoNoBtnView:LoadCallBack()
	local content_size = self.root_node:getContentSize()
	self:CreateTopTitle(Language.Fuhuo.FuhuoName, content_size.width / 2, content_size.height - 15)
	self.rich_tips = self.node_t_list.rich_tips.node
	
	self.shijian = self.node_t_list.lbl_tips2

	self.scrollview = self.node_t_list.scroll_gongneng_0.node
	self.scrollview:setScorllDirection(ScrollDir.Horizontal)
	self.btn_arrow_l = self.node_t_list.btn_arrow_l.node
	self.btn_arrow_r = self.node_t_list.btn_arrow_r.node
	self.btn_arrow_l:setVisible(false)
	self.gongneng_sort = {
		{	-- 装备
			img_name = 'btn_equip',
			view_name = GuideModuleName.Equipment,
			tab_index = TabIndex.equipment_strength,
		},
		{	-- 进阶
			img_name = 'btn_appearance',
			view_name = GuideModuleName.Appearance,
			tab_index = TabIndex.upgrade_jinjie,
		},
		{	-- 坐骑
			img_name = 'btn_ride',
			view_name = GuideModuleName.Mount,
			tab_index = TabIndex.mount_huanhua,
		},
		{	-- 仙女
			img_name = 'btn_peri',
			view_name = GuideModuleName.Peri,
			tab_index = nil,
		},
		{	-- 技能
			img_name = 'btn_card',
			view_name = GuideModuleName.Card,
			tab_index = TabIndex.card_yewai,
		},
	}
	self:CreateGongNengHead()
	self:RegisterEvents()
	self.alert_view = Alert.New()
	--显示赎魂灯价格
	local cost = ShopData.Instance:GetItemGold(26900)
	self.alert_view:SetLableString(string.format(Language.Fuhuo.BuyFuHuo, cost))
	self.alert_view:SetOkFunc(BindTool.Bind1(self.OnConfirmHandler, self))
	self.alert_view:SetShowCheckBox(true)
end

function FuhuoNoBtnView:RegisterEvents()
	XUI.AddClickEventListener(self.btn_arrow_l, BindTool.Bind1(self.ScrollMoveLeft, self), true)
	XUI.AddClickEventListener(self.btn_arrow_r, BindTool.Bind1(self.ScrollMoveRight, self), true)

	self.scrollview:addScrollEventListener(BindTool.Bind1(self.OnScrollChange, self))
	self:OnScrollChange()
end

function FuhuoNoBtnView:ShowIndexCallBack()

end

function FuhuoNoBtnView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			local tips = string.format(Language.Fuhuo.FuHuoTips, self.killer_name)
			RichTextUtil.ParseRichText(self.rich_tips, tips, FuhuoView.FONTSIZE, COLOR3B.WHITE)
			self.rich_tips:refreshView()
			local render_size = self.rich_tips:getInnerContainerSize()
			self.rich_tips:setAnchorPoint(cc.p(0, 1))
			self.rich_tips:setPosition(435 - render_size.width / 2, 365)
		elseif k == "daojishi" then
			self:DaoJiShi(v.time)
		end
	end
end