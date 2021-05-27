--护盾页面
ComposeHdPage = ComposeHdPage or BaseClass()

function ComposeHdPage:__init()
	self.view = nil
	self.page = nil
	self.upLevelBtn = nil
	self.lookBtn = nil
	self.helpBtn = nil
	self.equipType = nil
	self.is_first_login = true
	
end	

function ComposeHdPage:__delete()
	ClientCommonButtonDic[CommonButtonType.COMPOSE_SD_ACTIVATE_BTN] = nil
	self:RemoveEvent()
	if nil ~= self.buy_scroll_list then
		self.buy_scroll_list:DeleteMe()
		self.buy_scroll_list = nil
	end	
	self.effec = nil
	self.effec_1 = nil
	self.page = nil
	self.view = nil
	self.equipType = nil

	Runner.Instance:RemoveRunObj(self)
end	

--初始化页面接口
function ComposeHdPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.page = view.node_t_list.page2
	self.innerContainer = self.page.componment1.innerContainer.node
	self.innerContainerY = self.innerContainer:getPositionY()
	self.actionDir = 1

	self.equipType = ComposeType.Shendun

	
	self:CreateViewElement()
	self:UpdateShop()
	self:InitEvent()
	-- XUI.AddClickEventListener(self.view.node_t_list.layout_gongming.node, BindTool.Bind(self.OpenUnionView, self), true)
	ClientCommonButtonDic[CommonButtonType.COMPOSE_SD_ACTIVATE_BTN] = self.page.componment5.active_btn.node
	Runner.Instance:AddRunObj(self)
end

function ComposeHdPage:OpenUnionView( ... )
	self.is_first_login = false
	ViewManager.Instance:Open(ViewName.UnionProperty)
	ViewManager.Instance:FlushView(ViewName.UnionProperty, 0, "Compose")
end

-- function ComposeHdPage:BoolCanShowActive()
-- 	local num = ComposeData.Instance:GetCanActiveUnionProperty()
-- 	local path = ResPath.GetCommon("img9_202")
-- 	local bg_path = ResPath.GetCommon("stamp_33")
-- 	if num > 0 then
-- 		path = ResPath.GetCommon("img9_203")
-- 		bg_path = ResPath.GetCommon("stamp_32")	
-- 	end
-- 	self.view.node_t_list.layout_gongming.img9_open.node:loadTexture(path)
-- 	self.view.node_t_list.layout_gongming.img_txt.node:loadTexture(bg_path)
-- end

function ComposeHdPage:CreateViewElement()
	if nil == self.buy_scroll_list then
		local ph = self.view.ph_list.ph_buy_list
		self.buy_scroll_list = ListView.New()
		self.buy_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ComposeShopItemRender, nil, nil, self.view.ph_list.ph_buy_item)
		self.page.componment4.node:addChild(self.buy_scroll_list:GetView(), 100)
		self.buy_scroll_list:SetItemsInterval(5)
		self.buy_scroll_list:SetJumpDirection(ListView.Top)
		-- self.buy_scroll_list:SetDataList(ShopData.Instance:GetShopQuickBuyItem(QuicklyBuyType.Type_4))
		self.buy_scroll_list:JumpToTop()
	end
end	


--初始化事件
function ComposeHdPage:InitEvent()
	XUI.AddClickEventListener(self.page.componment3.uplevelBtn.node,BindTool.Bind(self.OnClickUpLevel,self),true)
	XUI.AddClickEventListener(self.page.componment3.lookseeBtn.node,BindTool.Bind(self.OnLook,self),true)
	XUI.AddClickEventListener(self.page.componment3.questBtn.node,BindTool.Bind(self.OnHelp,self),true)
	XUI.AddClickEventListener(self.page.componment5.node,BindTool.Bind(self.OnActive,self),false)
	XUI.AddClickEventListener(self.page.componment5.active_btn.node,BindTool.Bind(self.OnActive,self),true)

	self.item_list_event = BindTool.Bind1(self.ItemDataListChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_list_event, true)

	self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)

	-- self.effec = RenderUnit.CreateEffect(10, self.view.node_t_list.layout_gongming.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
	-- self.effec:setScaleX(2)
	-- self.effec:setScaleY(0.8)
	-- self.effec:setPositionX(240)

	self.shop_event = GlobalEventSystem:Bind(ShopEventType.FAST_SHOP_DATA_UPDATE, BindTool.Bind(self.UpdateShop, self))
end

--移除事件
function ComposeHdPage:RemoveEvent()
	if self.item_list_event then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_list_event)
		self.item_list_event = nil
	end
	if self.role_data_event then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
		self.role_data_event = nil
	end	

	if self.shop_event then
		GlobalEventSystem:UnBind(self.shop_event)
		self.shop_event = nil
	end
end

function ComposeHdPage:Update(now_time, elapse_time)
	if self.innerContainer then
		local tempY = self.innerContainer:getPositionY()

		if tempY > self.innerContainerY + 20 then
			self.actionDir = 0
		elseif tempY < self.innerContainerY - 20 then
			self.actionDir = 1
		end	

		if self.actionDir == 1 then
			self.innerContainer:setPositionY(tempY + 1)
		else
			self.innerContainer:setPositionY(tempY - 1)
		end	

		
	end	
end	

--更新视图界面
function ComposeHdPage:UpdateData(data)
	local equip = EquipData.Instance:GetEquipByType(ItemData.ItemType.itStoveShield)--检测是否有血符装备
	if equip then
		self.page.componment5.node:setVisible(false)
		self:UpdateAttr(equip)
		if not self.effec then
			self.effec = RenderUnit.CreateEffect(43, self.page.componment1.img_layout.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
			self.effec:setLocalZOrder(-10)
		end
		if not self.effec_1 then
			self.effec_1 = RenderUnit.CreateEffect(43, self.page.componment1.img_layout_1.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
			self.effec_1:setLocalZOrder(109)
			self.effec_1:setOpacity(90)
		end
	else
		self:Clear()
		self.page.componment5.node:setVisible(true)
		self:UpdateConsume(0)
	end	
	-- self:BoolCanShowActive()
end



--激活
function ComposeHdPage:OnActive()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	ComposeCtrl.Instance:SendActiveReq(self.equipType)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end	


--帮助点击
function ComposeHdPage:OnHelp()
	DescTip.Instance:SetContent(Language.Compose.Content[self.equipType],Language.Compose.Title[self.equipType])
end	

--预览点击
function ComposeHdPage:OnLook()
	ViewManager.Instance:Open(ViewName.ComposeBroswer)
	ViewManager.Instance:FlushView(ViewName.ComposeBroswer,0,"type",{type = self.equipType})
	AudioManager.Instance:PlayClickBtnSoundEffect()
end	

--升级点击
function ComposeHdPage:OnClickUpLevel()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	ComposeCtrl.Instance:SendUpLevelReq(self.equipType)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

--物品改变
function ComposeHdPage:ItemDataListChangeCallback()
	self:UpdateData()
end

function ComposeHdPage:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_SHIELD_SPIRIT then
		self:UpdateData()
	end	
end	

function ComposeHdPage:UpdateAttr(equip)
	local level = equip.compose_level
	local attrs_t = ComposeData.Instance:GetAttr(self.equipType,level)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local title_attrs = RoleData.FormatRoleAttrStr(attrs_t, is_range)
	for i = 1, 5 do
		self.page.componment2["layout_bg" .. i]["attr_title" .. i].node:setString(title_attrs[i] and title_attrs[i].type_str .. "：" or "")
		self.page.componment2["layout_bg" .. i]["cur_attr" .. i].node:setString(title_attrs[i] and title_attrs[i].value_str or "")
		if title_attrs[i] == nil then
			self.page.componment2["layout_bg" .. i].node:setVisible(false)
		end
	end	
	local nexLevel = level + 1
	local attrs_t = ComposeData.Instance:GetAttr(self.equipType,nexLevel)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local title_attrs = RoleData.FormatRoleAttrStr(attrs_t, is_range)
	for i = 1, 5 do
		self.page.componment2["layout_bg" .. i]["nex_attr" .. i].node:setString(title_attrs[i] and title_attrs[i].value_str or "")
	end	

	local step,star = ComposeData.Instance:GetStepStar(level)

	self.page.componment1.step_image.node:loadTexture(ResPath.GetCommon("step_" .. step))
	local config = ComposeData.Instance:GetStepStarConfig(self.equipType,level)
	if config then
		local itemCfg = ItemData.Instance:GetItemConfig(config.itemId)
		self.page.componment1.nameText.node:setString(itemCfg.name)

		self.innerContainer:setVisible(true)
		
		self.page.componment1.innerContainer.innerImg.node:loadTexture(ResPath.GetComposeInner(config.icon or 1))
	else	
		self.page.componment1.nameText.node:setString("")
	end
	self:UpdateConsume(level)

	for i = 1, 10 do
		self.page.componment3["starImg" .. i].node:setVisible(false)
	end

	for i = 1,star do
		self.page.componment3["starImg" .. i].node:setVisible(true)
		self.page.componment3["starImg" .. i].node:loadTexture(ResPath.GetCommon("star_0_select"))
	end	
	for i = star + 1,10 do
		self.page.componment3["starImg" .. i].node:setVisible(true)
		self.page.componment3["starImg" .. i].node:loadTexture(ResPath.GetCommon("star_0_lock"))
	end	

end	

function ComposeHdPage:UpdateShop()
	if self.buy_scroll_list then
		self.buy_scroll_list:SetDataList(ShopData.Instance:GetShopQuickBuyItem(QuicklyBuyType.Type_4))
	end
end	

function ComposeHdPage:Clear()
	for i = 1, 5 do
		self.page.componment2["layout_bg" .. i]["attr_title" .. i].node:setString("")
		self.page.componment2["layout_bg" .. i]["cur_attr" .. i].node:setString("")
		self.page.componment2["layout_bg" .. i]["nex_attr" .. i].node:setString("")
	end	
	for i = 1, 10 do
		self.page.componment3["starImg" .. i].node:setVisible(false)
	end	
	self.page.componment1.nameText.node:setString("")
	self.innerContainer:setVisible(false)
end	

function ComposeHdPage:UpdateConsume(level)
	local step,star = ComposeData.Instance:GetStepStar(level)
	
	local consume = ComposeData.Instance:GetConsume(self.equipType,level + 1)
	if consume then
		--local itemConfig = ItemData.Instance:GetConfig(ItemData.Instance:GetVirtualItemId(consume.type)) 
		consume = consume[1]
		local itemConfig = ItemData.Instance:GetItemConfig(ItemData.Instance:GetVirtualItemId(consume.type))
		local result = string.format(Language.Compose.ConsumeFormatTip,star,"",consume.count, itemConfig.name)
		self.page.componment3.consumeTipText.node:setString(result)

		local roleValue = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SHIELD_SPIRIT)
		self.page.componment3.progress_bar.node:setPercent(roleValue / consume.count * 100)
		self.page.componment3.progressText.node:setString(roleValue .. "/" .. consume.count)
	else
		self.page.componment3.consumeTipText.node:setString(Language.Compose.Top_level)
		self.page.componment3.progress_bar.node:setPercent(0)
		self.page.componment3.progressText.node:setString("")	
	end
end	


