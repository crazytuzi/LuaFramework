--英雄转生页面
HeroZhuanShengPage = HeroZhuanShengPage or BaseClass()
function HeroZhuanShengPage:__init()
	self.view = nil
end	

function HeroZhuanShengPage:__delete()

	self:RemoveEvent()
	if nil ~= self.buy_scroll_list then
		self.buy_scroll_list:DeleteMe()
		self.buy_scroll_list = nil
	end	

	if self.zs_lv_numBar then
		self.zs_lv_numBar:DeleteMe()
		self.zs_lv_numBar = nil
	end

	-- if self.zs_exchange_alert then
	-- 	self.zs_exchange_alert:DeleteMe()
	-- 	self.zs_exchange_alert = nil
	-- end

	self.view = nil
	-- ClientCommonButtonDic[CommonButtonType.ROLE_CIRCLE_BTN] = nil
	-- ClientCommonButtonDic[CommonButtonType.ROLE_EXCHANGE_XIUWEI_BTN] = nil
end	

--初始化页面接口
function HeroZhuanShengPage:InitPage(view)
	--绑定要操作的元素
	self.view = view

	self:CreateViewElement()
	XUI.AddClickEventListener(self.view.node_t_list["btn_zhuansheng"].node, BindTool.Bind(self.OnClickZhuansheng, self), true)
	self.view.node_t_list["btn_zs_exchange"].node:addClickEventListener(BindTool.Bind(self.OnClickZsExchange, self))
	self.view.node_t_list["btn_zhuan_tips"].node:addClickEventListener(BindTool.Bind(self.OnClickZhuanshengTips, self))
	XUI.SetRichTextVerticalSpace(self.view.node_t_list.rich_zhuan_cur_attr.node,10)
	XUI.SetRichTextVerticalSpace(self.view.node_t_list.rich_zhuan_n_attr.node,10)
	self.zs_lv_numBar = NumberBar.New()
	self.zs_lv_numBar:SetRootPath(ResPath.GetCommonPath("num_100_"))
	self.zs_lv_numBar:SetPosition(view.ph_list.ph_lev_1.x, view.ph_list.ph_lev_1.y)
	self.zs_lv_numBar:SetGravity(NumberBarGravity.Center)
	self.zs_lv_numBar:SetSpace(-4)
	self.view.node_t_list.layout_zhuansheng_hero.node:addChild(self.zs_lv_numBar:GetView(), 300, 300)

	self:UpdateShop()
	self:InitEvent()
	-- ClientCommonButtonDic[CommonButtonType.ROLE_CIRCLE_BTN] = self.view.node_t_list["btn_zhuansheng"].node
	-- ClientCommonButtonDic[CommonButtonType.ROLE_EXCHANGE_XIUWEI_BTN] = self.view.node_t_list["btn_zs_exchange"].node
end	

--初始化事件
function HeroZhuanShengPage:InitEvent()
	
	self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)
	self.hero_attr_evt = GlobalEventSystem:Bind(HeroDataEvent.HERO_ATTR_CHANGE, BindTool.Bind(self.HeroAttrChange, self))
	self.shop_event = GlobalEventSystem:Bind(ShopEventType.FAST_SHOP_DATA_UPDATE, BindTool.Bind(self.UpdateShop, self))
end

--移除事件
function HeroZhuanShengPage:RemoveEvent()
	if self.role_data_event then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
		self.role_data_event = nil
	end	

	if self.shop_event then
		GlobalEventSystem:UnBind(self.shop_event)
		self.shop_event = nil
	end

	if self.hero_attr_evt then
		GlobalEventSystem:UnBind(self.hero_attr_evt)
		self.hero_attr_evt = nil
	end
end

function HeroZhuanShengPage:CreateViewElement()
	if nil == self.buy_scroll_list then
		local ph = self.view.ph_list.ph_buy_list
		self.buy_scroll_list = ListView.New()
		self.buy_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ComposeShopItemRender, nil, nil, self.view.ph_list.ph_buy_item)
		self.view.node_t_list.layout_zhuansheng_hero.node:addChild(self.buy_scroll_list:GetView(), 100)
		self.buy_scroll_list:SetItemsInterval(5)
		self.buy_scroll_list:SetJumpDirection(ListView.Top)
		-- self.buy_scroll_list:SetDataList(ShopData.Instance:GetShopQuickBuyItem(QuicklyBuyType.Type_1))
		self.buy_scroll_list:JumpToTop()
	end
end	

function HeroZhuanShengPage:UpdateShop()
	if self.buy_scroll_list then
		self.buy_scroll_list:SetDataList(ShopData.Instance:GetShopQuickBuyItem(QuicklyBuyType.Type_2))
	end
end	

--更新视图界面
function HeroZhuanShengPage:UpdateData(data)
	local zhuan = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	self.zs_lv_numBar:SetNumber(zhuan)
	local zhuan_cfg = ZhanjiangData.GetRoleZhuanshengCfg(zhuan)
	local n_zhuan_cfg = ZhanjiangData.GetRoleZhuanshengCfg(zhuan + 1)
	local zhuan_attr_content = Language.Common.No
	local n_zhuan_attr_content = Language.Common.No
	local cur_lv_limit = ZhanjiangData.GetZhuanshengLvLimit(zhuan + 1)
	local n_lv_limit = ZhanjiangData.GetZhuanshengLvLimit(zhuan + 2) 
	local cur_lv_limit_str = string.format(Language.Role.ZhuanshengLvLimits[1], cur_lv_limit)
	local n_lv_limit_str = string.format(Language.Role.ZhuanshengLvLimits[2], n_lv_limit)
	if zhuan_cfg then	
		zhuan_attr_content = RoleData.FormatAttrContent(zhuan_cfg)
	end
	zhuan_attr_content = cur_lv_limit_str .. zhuan_attr_content

	if n_zhuan_cfg then	
		n_zhuan_attr_content = RoleData.FormatAttrContent(n_zhuan_cfg, {value_str_color = COLOR3B.GREEN})
	else
		n_zhuan_attr_content = Language.Common.AlreadyTopLv
		self.view.node_t_list.btn_zhuansheng.node:setEnabled(false)
	end
	n_zhuan_attr_content = n_lv_limit_str .. n_zhuan_attr_content

	RichTextUtil.ParseRichText(self.view.node_t_list.rich_zhuan_cur_attr.node, zhuan_attr_content, 22, COLOR3B.OLIVE)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_zhuan_n_attr.node, n_zhuan_attr_content, 22, COLOR3B.OLIVE)
	self.view.node_t_list.lbl_zhuan_xiuwei_has.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.HERO_CIRCLE_SOUL))
	local zhuan_consume_cfg = ZhanjiangData.GetZhuanshengConsumeCfg(zhuan + 1)
	self.view.node_t_list.lbl_zhuan_xiuwei_consume.node:setString(0)
	if zhuan_consume_cfg then
		for k,v in pairs(zhuan_consume_cfg.consumes) do
			if v.type == tagAwardType.qatHeroCircleSoul then
				self.view.node_t_list.lbl_zhuan_xiuwei_consume.node:setString(v.count)
				self.view.node_t_list.lbl_zhuan_xiuwei_has.node:setColor(RoleData.Instance:GetAttr(OBJ_ATTR.HERO_CIRCLE_SOUL) < v.count and COLOR3B.RED or COLOR3B.GREEN)
				break
			end
		end
	end
	local role_level = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	self.view.node_t_list.lbl_cur_zhuan_lv.node:setString(role_level)
	local zhuan_exchange_cfg = ZhanjiangData.GetZhuanshengSoulExchangeCfg(role_level)
	if zhuan_exchange_cfg then
		self.view.node_t_list.lbl_n_zhuan_lv.node:setString(zhuan_exchange_cfg.chgLevel)
		self.view.node_t_list.lbl_n_zhuan_xiuwei.node:setString(zhuan_exchange_cfg.addSoul)
		self.view.node_t_list.txt_consume_money.node:setString(zhuan_exchange_cfg.consumes[1].count)
	else
		self.view.node_t_list.lbl_n_zhuan_lv.node:setString(role_level)
		self.view.node_t_list.lbl_n_zhuan_xiuwei.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE_SOUL))
		self.view.node_t_list.txt_consume_money.node:setString(0)
	end
	local zhuan_limit_cnt = ZhanjiangData.GetRoleZhuanshengCntLimitByZLv(zhuan + 1)
	local used_time = ZhanjiangData.Instance:GetExchangeUsedTime()
	local zhuan_rest_cnt = (zhuan_limit_cnt - used_time) > 0 and (zhuan_limit_cnt - used_time) or 0
	self.view.node_t_list.lbl_zhuan_count.node:setString(zhuan_rest_cnt)
end	

function HeroZhuanShengPage:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.HERO_CIRCLE_SOUL then
		self:UpdateData()
	end
end	

function HeroZhuanShengPage:HeroAttrChange(key, value)
	if key == OBJ_ATTR.ACTOR_CIRCLE then
		self:UpdateData()
	end
end

function HeroZhuanShengPage:OnClickZhuansheng()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	local hero_id = ZhanjiangData.Instance:GetAttr("hero_id") 
	if hero_id > 0 then
		ZhanjiangCtrl.HeroUpCircleReq(hero_id)
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function HeroZhuanShengPage:OnClickZsExchange()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	if self.zs_exchange_alert == nil then
		self.zs_exchange_alert = Alert.New()
		self.zs_exchange_alert:SetLableString(Language.Role.ZsExchangeConfirm)
		self.zs_exchange_alert:SetOkFunc(BindTool.Bind(ZhanjiangCtrl.HeroExchanCircleSoulReq))
		self.zs_exchange_alert:SetShowCheckBox(true)
		self.zs_exchange_alert:SetData(ZhanjiangData.Instance:GetAttr("hero_id"))
	end
	self.zs_exchange_alert:Open()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function HeroZhuanShengPage:OnClickZhuanshengTips()
	DescTip.Instance:SetContent(Language.Role.ZhuanshengDetail, Language.Role.ZhuanshengTitle)
end
