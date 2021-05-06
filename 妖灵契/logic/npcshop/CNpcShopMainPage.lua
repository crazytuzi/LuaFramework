local CNpcShopMainPage = class("CNpcShopMainPage", CBox)

function CNpcShopMainPage.ctor(self, ob)
	CBox.ctor(self, ob)

	self.m_CurrentItem = nil
	self.m_CurrentPageBtn = nil
	self.m_CurrentTagBtn = nil
	self.m_ItemCellPool = {}
	self.m_TableCellPool = {}
	self.m_PageBtnPool = {}
	self.m_TagBtnPool = {}
	self.m_ShopIdToTagBtn = {}
	self.m_GoodsPosToItemCell = {}
	self.m_CurrentCurrency = nil
	-- self.m_TextColor = Color.New(0.5, 0.38, 0.53, 1)
	self:OnInitPage()
end

function CNpcShopMainPage.OnInitPage(self)
	self.m_TableSprite = self:NewUI(1, CSprite)
	self.m_PageBtn = self:NewUI(2, CBox)
	self.m_PageBtnGrid = self:NewUI(3, CTabGrid)
	self.m_ItemScrollView = self:NewUI(4, CScrollView)
	self.m_TagGrid = self:NewUI(5, CTabGrid)
	self.m_TagBtn = self:NewUI(6, CBox)
	self.m_ItemGrid = self:NewUI(7, CGrid)
	self.m_ItemCell = self:NewUI(8, CNpcShopItemBox)
	self.m_CountDownLabel = self:NewUI(9, CCountDownLabel)
	self.m_RefreshBtn = self:NewUI(10, CBox)
	self.m_ShopCostInfoPart = self:NewUI(11, CShopCostInfoPart)
	self.m_OwnLabel = self:NewUI(12, CLabel)
	self.m_OwnCurrencySprite = self:NewUI(13, CSprite)
	self.m_TableGrid = self:NewUI(14, CGrid)
	self.m_TipsSprite = self:NewUI(15, CSprite)
	self.m_PartnerEquipInfoPart = self:NewUI(16, CShopCostInfoPart)
	self.m_RechargeBtn = self:NewUI(17, CBox)
	self.m_RechargePart = self:NewUI(18, CNpcShopRechargePart)
	self.m_NormalPart = self:NewUI(19, CBox)
	self.m_RechargeTips = self:NewUI(20, CLabel)
	self.m_ShowSkinBtn = self:NewUI(21, CButton)
	self.m_ShowSkinSprite = self:NewUI(22, CSprite)
	self.m_RMBInfoPart = self:NewUI(23, CShopCostInfoPart)

	self:InitContent()
end

function CNpcShopMainPage.InitContent(self)
	self.m_RefreshBox = self:CreateRefreshBtn()
	self.m_ItemCell:SetActive(false)
	-- self.m_TagBtn:SetActive(false)
	self.m_PageBtn:SetActive(false)
	self.m_TableSprite:SetActive(false)
	self.m_ShowSkinBtn:AddUIEvent("click", callback(self, "ShowRoleSkin"))
	self.m_CountDownLabel:SetTickFunc(callback(self, "SetCountDownText"))
	self.m_OwnLabel:AddUIEvent("click", callback(self, "ShowCurrencyGuide"))

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotifyRefresh"))
	g_NpcShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemNotify"))
	self:CreatePageBtn()
	self.m_TagGrid:InitChild(function (obj, idx)
		local tagBtn = CBox.New(obj)
		tagBtn.m_Btn = tagBtn:NewUI(1, CButton)
		tagBtn.m_Icon = tagBtn:NewUI(2, CSprite)
		tagBtn.m_SelectSprite = tagBtn:NewUI(3, CSprite)
		tagBtn.m_SelectIcon = tagBtn:NewUI(4, CSprite)
		tagBtn.m_HingeJoint2D = tagBtn:GetComponent(classtype.HingeJoint2D)
		tagBtn.m_Rigidbody2D = tagBtn:GetComponent(classtype.Rigidbody2D)
		
		-- tagBtn.m_TagData = tagData
		tagBtn.m_SelectSprite:SetActive(false)
		self.m_TagBtnPool[idx] = tagBtn

		tagBtn.m_Btn:SetClickSounPath(define.Audio.SoundPath.Tab)
		tagBtn.m_Btn:AddUIEvent("click", callback(self,"OnClickTag", tagBtn))
		return tagBtn
	end)
	self.m_BtnTimer = Utils.AddTimer(function ()
		for i = 1, #self.m_TagBtnPool do
			self.m_TagBtnPool[i].m_HingeJoint2D.enabled = false
			self.m_TagBtnPool[i].m_Rigidbody2D.isKinematic = true
		end
	end, 0, 6)
end

function CNpcShopMainPage.SetCountDownText(self, value)
	if self.m_TipsText ~= "" then
		-- self.m_CountDownLabel:SetText(self.m_TipsText)
	else
		self.m_CountDownLabel:SetText(string.format("自动刷新：%d:%02d", math.modf(value / 60), (value % 60)))
	end
end

function CNpcShopMainPage.ShowCurrencyGuide(self)
	if self.m_RechargePart:GetActive() then
		return
	end
	CCurrencyGuideView:ShowView(function (oView)
		oView:SetData(self.m_CurrentCurrency)
	end)
end

function CNpcShopMainPage.ShowRoleSkin(self)
	g_WelfareCtrl.m_TotalLockSkin = true
	g_OpenUICtrl:OpenTotalPay()
end

function CNpcShopMainPage.CreateRefreshBtn(self)
	local oBtn = self.m_RefreshBtn
	oBtn.m_TipsLabel = oBtn:NewUI(1, CLabel)
	oBtn.m_CurrencySprite = oBtn:NewUI(2, CSprite)
	oBtn.m_Label = oBtn:NewUI(3, CLabel)
	oBtn.m_Btn = oBtn:NewUI(4, CButton)
	oBtn:AddUIEvent("click", callback(self, "RefreshShop"))

	function oBtn.SetData(self, refreshInfo)
		-- printc("refreshInfo")
		-- table.print(refreshInfo, "refreshInfo-------------->")
		oBtn.m_TipsLabel:SetActive(refreshInfo.refresh_rule ~= 0)
		oBtn.m_CurrencySprite:SetActive(refreshInfo.refresh_rule ~= 0)
		oBtn.m_CurrencySprite:SetActive(refreshInfo.refresh_rule ~= 0)
		if refreshInfo.refresh_cost == 0 then
			oBtn.m_CurrencySprite:SetActive(false)
			oBtn.m_TipsLabel:SetText("免费刷新")
			oBtn.m_Label:SetText("")
		else
			if refreshInfo.refresh_count > 0 then
				oBtn.m_TipsLabel:SetText("刷 新")
			else
				oBtn.m_TipsLabel:SetText("次数已尽")
			end
			oBtn.m_CurrencySprite:SetSpriteName(g_NpcShopCtrl:GetCurrency(refreshInfo.refresh_coin_type).icon)
			oBtn.m_CurrencySprite:SetActive(true)
			oBtn.m_Label:SetText(refreshInfo.refresh_cost)
		end
	end

	function oBtn.SetShow(self, bShow)
		oBtn.m_TipsLabel:SetActive(bShow)
		oBtn.m_CurrencySprite:SetActive(bShow)
		oBtn.m_Label:SetActive(bShow)
		oBtn.m_Btn:SetEnabled(bShow)
	end

	return oBtn
end

function CNpcShopMainPage.SetShopData(self, shopid, goodsID)
	self.m_ParentView:ShowMain()
	self:SelectPage(g_NpcShopCtrl:GetPageIdByShopId(shopid), shopid)
	self:SetDefaultClickItem(goodsID)
end

--更新商店货物
function CNpcShopMainPage.RefreshShop(self)
	local shopId = self.m_CurrentTagBtn.m_TagData.id
	local refreshInfo = g_NpcShopCtrl:GetRefreshInfo(shopId)
	if refreshInfo.refresh_count <= 0 then
		g_NotifyCtrl:FloatMsg("本日手动刷新次数已消耗完")
	elseif refreshInfo.refresh_cost > g_NpcShopCtrl:GetCurrencyValue(refreshInfo.refresh_coin_type) then
		g_NotifyCtrl:FloatMsg("货币不足，无法刷新")
		self:ShowCurrencyGuide()
	else
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSRefreshShop"]) then
			netstore.C2GSRefreshShop(shopId)
		end
	end
end

function CNpcShopMainPage.SetRefreshInfo(self, shopId)
	self.m_CountDownLabel:SetText("")
	local shopID = self.m_CurrentTagBtn.m_TagData.id
	self.m_TipsText = data.npcstoredata.StoreTag[shopID].refresh_tips
	if self.m_TipsText ~= "" then
		self.m_CountDownLabel:SetText(self.m_TipsText)
	end
	local refreshInfo = g_NpcShopCtrl:GetRefreshInfo(shopId)
	self.m_RefreshBox:SetData(refreshInfo)
	self.m_RefreshBox.m_Btn:SetEnabled(refreshInfo.refresh_count > 0)
	if refreshInfo.refresh_rule == 1 or refreshInfo.refresh_rule == 3 then
		self.m_CountDownLabel:SetTimeUPCallBack(callback(self, "OnRefreshTimeUP"))
		self.m_CountDownLabel:BeginCountDown(g_NpcShopCtrl:GetRestRefreshTime(shopId))
	else
		self.m_CountDownLabel:OnTimeUP()
	end
end

function CNpcShopMainPage.OnRefreshTimeUP(self)
	if self.m_TipsText ~= "" then
		-- self.m_CountDownLabel:SetText(self.m_TipsText)
	else
		self.m_CountDownLabel:SetText("")
		if self.m_CurrentTagBtn and g_NpcShopCtrl:HasRefreshRult(self.m_CurrentTagBtn.m_TagData.id) then
			g_NpcShopCtrl:OpenShop(self.m_CurrentTagBtn.m_TagData.id)
		end
	end
end

--创建分页按钮
function CNpcShopMainPage.CreatePageBtn(self)
	local pages = g_NpcShopCtrl:GetPageSort()
	for i,v in ipairs(pages) do
		local oPageBtn = self.m_PageBtn:Clone("oPageBtn")
		self:InitPageBtn(oPageBtn)
		oPageBtn.m_PageData = g_NpcShopCtrl:GetPageData(v)
		if oPageBtn.m_PageData.id == 4 then
			oPageBtn.m_Mark:SetActive(true)
		end
		self.m_PageBtnPool[oPageBtn.m_PageData.id] = oPageBtn
		self.m_PageBtnGrid:AddChild(oPageBtn)
		oPageBtn.m_Icon:SetSpriteName(oPageBtn.m_PageData.icon)
		oPageBtn.m_SelectIcon:SetSpriteName(oPageBtn.m_PageData.selected_icon)

		local tabs = g_NpcShopCtrl:GetTagIds(oPageBtn.m_PageData.id)
		if tabs ~= nil then
			oPageBtn.m_DefaultTab = tabs[1]
		else
			oPageBtn.m_DefaultTab = nil
		end
		oPageBtn.m_Btn:SetClickSounPath(define.Audio.SoundPath.Tab)
		oPageBtn.m_Btn:AddUIEvent("click",callback(self,"OnClickPage", oPageBtn))
	end
	self:InitPageBtn(self.m_RechargeBtn)
	self.m_RechargeBtn:SetAsLastSibling()
	self.m_RechargeBtn.m_Btn:AddUIEvent("click",callback(self,"OnClickPage", self.m_RechargeBtn))
end

function CNpcShopMainPage.InitPageBtn(self, oPageBtn)
	oPageBtn.m_Btn = oPageBtn:NewUI(1, CButton)
	oPageBtn.m_Icon = oPageBtn:NewUI(2, CSprite)
	oPageBtn.m_SelectSprite = oPageBtn:NewUI(3, CSprite)
	oPageBtn.m_SelectIcon = oPageBtn:NewUI(4, CSprite)
	oPageBtn.m_Mark = oPageBtn:NewUI(5, CBox)
	oPageBtn:SetActive(true)
	oPageBtn.m_SelectSprite:SetActive(false)
	oPageBtn.m_Mark:SetActive(false)
end

--选择商店大类
function CNpcShopMainPage.SelectPage(self, pageId, shopId)
	self:SetSelectBtn(self.m_PageBtnPool[pageId])

	local tagIds = g_NpcShopCtrl:GetTagIds(pageId)
	local count = 0
	if tagIds ~= nil then
		for i,v in ipairs(tagIds) do
			count = count + 1
			self.m_TagBtnPool[i].m_TagData = g_NpcShopCtrl:GetTagData(v)
			self.m_ShopIdToTagBtn[v] = self.m_TagBtnPool[i]
			self.m_TagBtnPool[i].m_Icon:SetSpriteName(self.m_TagBtnPool[i].m_TagData.icon)
			self.m_TagBtnPool[i].m_SelectIcon:SetSpriteName(self.m_TagBtnPool[i].m_TagData.selected_icon)
			self.m_TagBtnPool[i].m_Icon:MakePixelPerfect()
			self.m_TagBtnPool[i].m_SelectIcon:MakePixelPerfect()
			self.m_TagBtnPool[i]:SetActive(true)
		end
	end
	count = count + 1
	if #tagIds == 1 then
		count = 1
	end
	for i = count, #self.m_TagBtnPool do
		self.m_TagBtnPool[i]:SetActive(false)
	end

	self:SelectShopTag(shopId)
end

function CNpcShopMainPage.OnClickPage(self, pageBtn)
	if self.m_RechargeBtn == pageBtn then
		self:OnRecharge()
	else
		g_NpcShopCtrl:OpenShop(pageBtn.m_DefaultTab)
	end
end

function CNpcShopMainPage.OnClickTag(self, tagBtn)
	g_NpcShopCtrl:OpenShop(tagBtn.m_TagData.id)
end

--选择商店标签
function CNpcShopMainPage.SelectShopTag(self, shopId)
	-- if self.m_CurrentItem ~= nil then
	-- 	self.m_CurrentItem.m_OnSelectSprite:SetActive(false)
	-- end
	self.m_CurrentItem = nil
	if shopId ~= nil then
		self.m_ShopCostInfoPart:SetActive(false)
		self.m_PartnerEquipInfoPart:SetActive(false)
		if self.m_CurrentTagBtn ~= nil then
			self.m_CurrentTagBtn.m_Btn:SetActive(true)
			self.m_CurrentTagBtn.m_SelectSprite:SetActive(false)
		end
		self.m_CurrentTagBtn = self.m_ShopIdToTagBtn[shopId]
		self.m_CurrentTagBtn.m_Btn:SetActive(false)
		self.m_CurrentTagBtn.m_SelectSprite:SetActive(true)
		self.m_RechargePart:SetActive(false)
		self.m_RMBInfoPart:SetActive(false)
		self.m_RechargeTips:SetActive(false)
		self.m_ShowSkinSprite:SetActive(shopId == define.Store.Page.PartnerSkin or shopId == define.Store.Page.LimitSkin)
		self.m_RefreshBox:SetShow(true)
		self.m_NormalPart:SetActive(true)
		self.m_CountDownLabel:SetActive(true)
		self.m_TipsSprite:SetActive(true)
	end
	self:SetRefreshInfo(shopId)
	self:SetOnSellData(shopId)
end

function CNpcShopMainPage.OnRecharge(self)
	self:SetSelectBtn(self.m_RechargeBtn)
	for i = 1, #self.m_TagBtnPool do
		self.m_TagBtnPool[i]:SetActive(false)
	end
	self.m_ShopCostInfoPart:SetActive(false)
	self.m_PartnerEquipInfoPart:SetActive(false)
	self.m_RMBInfoPart:SetActive(false)
	self.m_RechargePart:SetActive(true)
	self.m_RechargeTips:SetActive(true)
	self.m_ShowSkinSprite:SetActive(false)
	self.m_RefreshBox:SetShow(false)
	self.m_NormalPart:SetActive(false)
	self.m_CountDownLabel:SetActive(false)
	self.m_TipsSprite:SetActive(false)
	self:RefreshUI()
end

function CNpcShopMainPage.SetSelectBtn(self, oBtn)
	if self.m_CurrentPageBtn ~= nil then
		self.m_CurrentPageBtn.m_Btn:SetActive(true)
		self.m_CurrentPageBtn.m_SelectSprite:SetActive(false)
		for i = 1, #self.m_TagBtnPool do
			self.m_TagBtnPool[i].m_HingeJoint2D.enabled = false
			self.m_TagBtnPool[i].m_Rigidbody2D.isKinematic = true
			self.m_TagBtnPool[i]:SetLocalPos(Vector3.New(0, - i * 100, 0))
			self.m_TagBtnPool[i]:SetLocalRotation(Quaternion.identity)
		end
	end
	self.m_CurrentPageBtn = oBtn
	self.m_CurrentPageBtn.m_Btn:SetActive(false)
	self.m_CurrentPageBtn.m_SelectSprite:SetActive(true)
end

--设置当前标签出售商品
function CNpcShopMainPage.SetOnSellData(self, shopId)
	local count = 0
	local goodsPosList = g_NpcShopCtrl:GetGoodsPosList(shopId)

	if shopId ~= nil and goodsPosList ~= nil then
		for k,v in ipairs(goodsPosList) do
			count = count +1
			if self.m_ItemCellPool[count] == nil then
				self.m_ItemCellPool[count] = self:CreateItemCell()
			end
			self.m_GoodsPosToItemCell[v] = self.m_ItemCellPool[count]
			self.m_ItemCellPool[count]:SetData(g_NpcShopCtrl:GetCommonGoodsData(g_NpcShopCtrl:GetGoodsInfo(v).item_id))
			self.m_ItemCellPool[count]:Refresh(g_NpcShopCtrl:GetGoodsInfo(v))
		end
	end

	local tableNum = math.ceil(count / self.m_ItemGrid:GetMaxPerLine())
	for i = 1, tableNum do
		if self.m_TableCellPool[i] == nil then
			self.m_TableCellPool[i] = self.m_TableSprite:Clone()
			self.m_TableGrid:AddChild(self.m_TableCellPool[i])
		end
		self.m_TableCellPool[i]:SetActive(true)
	end
	self.m_TipsSprite:SetActive(tableNum > 2)
	tableNum = tableNum + 1
	for i = tableNum, #self.m_TableCellPool do
		self.m_TableCellPool[i]:SetActive(false)
	end

	count = count + 1
	for i = count, #self.m_ItemCellPool do
		self.m_ItemCellPool[i]:SetActive(false)
	end
	self:RefreshUI()
	self.m_ItemScrollView:ResetPosition()
	self.m_ItemGrid:Reposition()
end

function CNpcShopMainPage.CreateItemCell(self)
	local oItemCell = self.m_ItemCell:Clone("oItemCell")
	oItemCell:SetActive(true)

	oItemCell.m_Currency = nil
	oItemCell.m_ParentView = self
	oItemCell:AddUIEvent("click",callback(self, "OnItemCellClick", oItemCell))
	self.m_ItemGrid:AddChild(oItemCell)
	return oItemCell
end

function CNpcShopMainPage.OnItemCellClick(self, oItemCell)
	-- if self.m_CurrentItem ~= nil then
		-- self.m_CurrentItem.m_OnSelectSprite:SetActive(false)
	-- end
	self.m_CurrentItem = oItemCell
	-- self.m_CurrentItem.m_OnSelectSprite:SetActive(true)
	if oItemCell.m_GoodsData.currency.currency_type == define.Currency.Type.RMB then
		self.m_RMBInfoPart:SetInfo(oItemCell)
	elseif oItemCell.m_GoodsData.gType == define.Store.GoodsType.PartnerSkin then
		self.m_ParentView:ShowSkin(oItemCell)
	elseif oItemCell.m_GoodsData.gType == define.Store.GoodsType.PartnerEquip then
		self:RefreshUI()
		self.m_PartnerEquipInfoPart:SetInfo(oItemCell)
	else
		self:RefreshUI()
		self.m_ShopCostInfoPart:SetInfo(oItemCell)
	end
end

function CNpcShopMainPage.OnNotifyRefresh(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshUI()
	end
end

function CNpcShopMainPage.OnItemNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshPartnerSkin then
		if self.m_CurrentTagBtn and self.m_CurrentTagBtn.m_TagData.id == define.Store.Page.PartnerSkin then
			self:SetShopData(define.Store.Page.PartnerSkin)
		end
	end
end

function CNpcShopMainPage.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Store.Event.CloseGold2Coin then
		self.m_ParentView:CloseView()
	elseif oCtrl.m_EventID == define.Store.Event.RefreshItem or oCtrl.m_EventID == define.Item.Event.RefreshPartnerSkin then
		if self.m_CurrentTagBtn and oCtrl.m_EventData.shopId == self.m_CurrentTagBtn.m_TagData.id then
			self:RefreshItem(oCtrl.m_EventData.goodsInfo)
		end
	elseif oCtrl.m_EventID == define.Store.Event.SetShopData then
		self:SetShopData(oCtrl.m_EventData)
	end
end

function CNpcShopMainPage.RefreshUI(self)
	if self.m_RechargePart:GetActive() then
		self.m_OwnLabel:SetNumberString(g_AttrCtrl.goldcoin)
		self.m_OwnCurrencySprite:SetSpriteName("1003")
	else
		local shopId = nil
		if self.m_CurrentTagBtn then
			shopId = self.m_CurrentTagBtn.m_TagData.id
		end
		if shopId ~= nil then
			self.m_OwnLabel:SetNumberString(g_NpcShopCtrl:GetCurrencyValue(g_NpcShopCtrl:GetTagData(shopId).coin_typ))
			self.m_OwnCurrencySprite:SetSpriteName(g_NpcShopCtrl:GetCurrency(g_NpcShopCtrl:GetTagData(shopId).coin_typ).icon)
			self.m_CurrentCurrency = g_NpcShopCtrl:GetCurrency(g_NpcShopCtrl:GetTagData(shopId).coin_typ)
		end
	end
end

function CNpcShopMainPage.RefreshItem(self, goodsInfo)
	local oItemCell = self.m_GoodsPosToItemCell[goodsInfo.pos]
	oItemCell:Refresh(goodsInfo)
end

function CNpcShopMainPage.SetDefaultClickItem(self, goodsID)
	if not goodsID then
		return
	end
	for k,oItemCell in pairs(self.m_ItemCellPool) do
		if oItemCell.m_GoodsData.id == goodsID then
			self:OnItemCellClick(oItemCell)
			return
		end
	end
end

function CNpcShopMainPage.Destroy(self)
	-- CViewBase.Destroy(self)
	if self.m_BtnTimer then
		Utils.DelTimer(self.m_BtnTimer)
		self.m_BtnTimer = nil
	end
end

return CNpcShopMainPage