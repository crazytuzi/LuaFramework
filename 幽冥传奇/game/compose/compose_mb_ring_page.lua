--麻痹页面
ComposeMbPage = ComposeMbPage or BaseClass()


function ComposeMbPage:__init()
	self.view = nil
	self.page = nil
	self.upLevelBtn = nil
    self.lookBtn = nil
	self.helpBtn = nil
	self.equipType = nil
end	

function ComposeMbPage:__delete()
	--ClientCommonButtonDic[CommonButtonType.COMPOSE_XF_ACTIVATE_BTN] = nil
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
	self.innerContainer = nil
	Runner.Instance:RemoveRunObj(self)
end	

--初始化页面接口
function ComposeMbPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.page = view.node_t_list.page5
	self.innerContainer = self.page.componment1.innerContainer.node
	self.innerContainerY = self.innerContainer:getPositionY()
	self.actionDir = 1
	self.equipType = ComposeType.MabiRing

	self.equipType = ComposeData.Instance:GetComposeTypeByItemType(ItemData.ItemType.itSpecialRing, TabIndex.compose_new_mb)
	self:CreateViewElement()
	self:UpdateShop()
	self:InitEvent()

	--ClientCommonButtonDic[CommonButtonType.COMPOSE_XF_ACTIVATE_BTN] = self.page.componment5.active_btn.node

	Runner.Instance:AddRunObj(self)
	
end	


function ComposeMbPage:CreateViewElement()
	if nil == self.buy_scroll_list then
		local ph = self.view.ph_list.ph_buy_list
		self.buy_scroll_list = ListView.New()
		self.buy_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ComposeShopItemRender, nil, nil, self.view.ph_list.ph_buy_item)
		self.page.componment4.node:addChild(self.buy_scroll_list:GetView(), 100)
		self.buy_scroll_list:SetItemsInterval(5)
		self.buy_scroll_list:SetJumpDirection(ListView.Top)
		
		--self.buy_scroll_list:SetDataList(ShopData.Instance:GetShopQuickBuyItem(QuicklyBuyType.Type_9))
		self.buy_scroll_list:JumpToTop()
	end
end	
	

--初始化事件
function ComposeMbPage:InitEvent()
	XUI.AddClickEventListener(self.page.componment3.uplevelBtn.node,BindTool.Bind(self.OnClickUpLevel,self),true)
	XUI.AddClickEventListener(self.page.componment3.lookseeBtn.node,BindTool.Bind(self.OnLook,self),true)
	XUI.AddClickEventListener(self.page.componment3.questBtn.node,BindTool.Bind(self.OnHelp,self),true)
	XUI.AddClickEventListener(self.page.componment5.node,BindTool.Bind(self.OnActive,self),false)
	XUI.AddClickEventListener(self.page.componment5.active_btn.node,BindTool.Bind(self.OnActive,self),true)
	self.item_list_event = BindTool.Bind1(self.ItemDataListChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_list_event, true)

	self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)

	self.shop_event = GlobalEventSystem:Bind(ShopEventType.FAST_SHOP_DATA_UPDATE, BindTool.Bind(self.UpdateShop, self))

end

--移除事件
function ComposeMbPage:RemoveEvent()
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

function ComposeMbPage:Update(now_time, elapse_time)
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
function ComposeMbPage:UpdateData(data)	
	local equip = EquipData.Instance:GetEquipByType(ItemData.ItemType.itSpecialRing, 0)
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
end	

--点击激活
function ComposeMbPage:OnActive()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	local equipType = ComposeData.Instance:GetComposeTypeByItemType(ItemData.ItemType.itSpecialRing, TabIndex.compose_new_mb)
	ComposeCtrl.Instance:SendActiveReq(equipType)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

--帮助点击
function ComposeMbPage:OnHelp()
	DescTip.Instance:SetContent(Language.Compose.Content[6], Language.Compose.Title[6] or "")
end	

--预览点击
function ComposeMbPage:OnLook()
	ViewManager.Instance:Open(ViewName.ComposeBroswer)
	ViewManager.Instance:FlushView(ViewName.ComposeBroswer,0,"type",{type = self.equipType})
	AudioManager.Instance:PlayClickBtnSoundEffect()
end	
--升级点击
function ComposeMbPage:OnClickUpLevel()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	local equipType = ComposeData.Instance:GetComposeTypeByItemType(ItemData.ItemType.itSpecialRing, TabIndex.compose_new_mb)
	ComposeCtrl.Instance:SendUpLevelReq(equipType)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end
--物品改变
function ComposeMbPage:ItemDataListChangeCallback()
	self:UpdateData()
end

function ComposeMbPage:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_RING_CRYSTAL then
		self:UpdateData()
	end	
end	

function ComposeMbPage:UpdateAttr(equip)
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

function ComposeMbPage:UpdateShop()
	if self.buy_scroll_list then
		self.buy_scroll_list:SetDataList(ShopData.Instance:GetShopQuickBuyItem(QuicklyBuyType.Type_9))
	end
end	

function ComposeMbPage:Clear()
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

function ComposeMbPage:UpdateConsume(level)
	local step,star = ComposeData.Instance:GetStepStar(level)
	
	local consume = ComposeData.Instance:GetConsume(self.equipType,level + 1)
	if consume then
		local ring_consume = consume[1]
		local si_consume = consume[2]

		local roleValue = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RING_CRYSTAL)
		
		if si_consume ~= nil then
			self.page.componment3.progress_bar.node:setPercent(roleValue / si_consume.count * 100)
			self.page.componment3.progressText.node:setString(roleValue .. "/" .. si_consume.count)

			local itemConfig = ItemData.Instance:GetItemConfig(ItemData.Instance:GetVirtualItemId(si_consume.type))
			local result = string.format(Language.Compose.ConsumeFormatTip,star,"",si_consume.count, itemConfig.name)
			local config = ItemData.Instance:GetItemConfig(ring_consume.id)
			if config == nil then
				return 
			end
			local ring = string.format(Language.Compose.NeedRing, config.name, ring_consume.count)
			self.page.componment3.consumeTipText.node:setString(result .. ring)
		else
			self.page.componment3.progress_bar.node:setPercent(roleValue / ring_consume.count * 100)
			self.page.componment3.progressText.node:setString(roleValue .. "/" .. ring_consume.count)
			local itemConfig = ItemData.Instance:GetItemConfig(ItemData.Instance:GetVirtualItemId(ring_consume.type))
			if itemConfig == nil then 
				local config = ItemData.Instance:GetItemConfig(ring_consume.id)
				if config == nil then return end
				local result = string.format(Language.Compose.ConsumeFormatTip, star,"",ring_consume.count, config.name)
				self.page.componment3.consumeTipText.node:setString(result)
			else	
				local result = string.format(Language.Compose.ConsumeFormatTip, star,"",ring_consume.count, itemConfig.name)
				self.page.componment3.consumeTipText.node:setString(result)
			end
		end

	else
		self.page.componment3.consumeTipText.node:setString(Language.Compose.Top_level)
		self.page.componment3.progress_bar.node:setPercent(0)
		self.page.componment3.progressText.node:setString("")
	end
end	