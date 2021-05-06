local CNpcShopSkinPage = class("CNpcShopSkinPage", CBox)

function CNpcShopSkinPage.ctor(self, ob)
	CBox.ctor(self, ob)
	self:OnInitPage()
end

function CNpcShopSkinPage.OnInitPage(self)
	self.m_BackBtn = self:NewUI(1, CButton)
	self.m_PartnerNameLabel = self:NewUI(2, CLabel)
	-- self.m_SkinNameLabel = self:NewUI(3, CLabel)
	self.m_SkinNameSprite = self:NewUI(3, CSprite)
	self.m_ModelTexture = self:NewUI(4, CActorTexture)
	self.m_SkinGrid = self:NewUI(5, CGrid)
	self.m_SkinTexture = self:NewUI(6, CTexture)
	self.m_MarkLabel = self:NewUI(7, CLabel)
	self.m_BuyBtn = self:NewUI(8, CButton)
	self.m_ScorllView = self:NewUI(9, CScrollView)
	self.m_OwnLabel = self:NewUI(10, CLabel)
	self.m_OwnCurrencySprite = self:NewUI(11, CSprite)
	self.m_CostSprite = self:NewUI(12, CSprite)
	self.m_ZSKBtn = self:NewUI(13, CButton)
	self:InitContent()
end

function CNpcShopSkinPage.InitContent(self)
	self.m_ScorllView.m_UIScrollView.momentumAmount = 35
	self.m_CurrencyType = define.Currency.Type.PiFuQuan
	self.m_CurrentCurrency = g_NpcShopCtrl:GetCurrency(self.m_CurrencyType)
	self.m_SkinBoxArr = {}
	self.m_SkinBoxDic = {}
	self.m_GridX = self.m_SkinGrid:GetLocalPos().x
	self.m_CellWidth, self.m_CellHeight = self.m_SkinGrid:GetCellSize()
	-- printc("self.m_GridX: " .. self.m_GridX)
	-- printc("self.m_CellWidth: " .. self.m_CellWidth)
	self.m_OwnLabel:AddUIEvent("click", callback(self, "ShowCurrencyGuide"))
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnClickBack"))
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnClickBuy"))
	self.m_ZSKBtn:AddUIEvent("click", callback(self, "OnClickZSK"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrNotify"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemNotify"))
end

function CNpcShopSkinPage.ShowCurrencyGuide(self)
	CCurrencyGuideView:ShowView(function (oView)
		oView:SetData(self.m_CurrentCurrency)
	end)
end

function CNpcShopSkinPage.OnClickZSK(self)
	g_OpenUICtrl:OpenYueKa()
end

function CNpcShopSkinPage.SetData(self, oItemCell)
	self.m_BuyBtn:SetActive(false)
	self.m_MarkLabel:SetActive(false)
	self:RefreshUI(oItemCell)
	self.m_PartnerNameLabel:SetText(oItemCell.m_GoodsData.partnerName)
	self.m_ScorllView:CenterOn(self.m_SkinBoxDic[oItemCell.m_GoodsData.item_id].m_Transform)

	-- for i,v in ipairs(self.m_SkinBoxArr) do
	-- 	if v.m_GoodsData.item_id == oItemCell.m_GoodsData.item_id then
	-- 		self.m_ScorllView:MoveRelative(Vector3.New(0 - self.m_ScorllView:GetLocalPos().x - self.m_GridX - self.m_CellWidth * (i - 1)))
	-- 	end
	-- end
end

function CNpcShopSkinPage.RefreshUI(self, oItemCell)
	self.m_CurrentCenter = nil
	self.m_ItemCell = oItemCell
	local skinList = g_PartnerCtrl:GetPartnerSkin(data.itemdata.PARTNER_SKIN[oItemCell.m_GoodsData.item_id].partner_type)
	if skinList == nil then
		self:OnClickBack()
	end
	local count = 0
	for i,v in ipairs(skinList) do
		count = count + 1
		if self.m_SkinBoxArr[count] == nil then
			self.m_SkinBoxArr[count] = self:CreateSkinBox()
		end
		self.m_SkinBoxArr[count]:SetData(oItemCell, v)
		self.m_SkinBoxDic[v.id] = self.m_SkinBoxArr[count]
		self.m_SkinBoxDic[v.id].index = count - 1
		self.m_SkinBoxArr[count]:SetMainTexture(nil)
		self.m_SkinBoxArr[count]:LoadCardPhoto(v.show)
		self.m_SkinBoxArr[count]:SetActive(true)
	end

	count = count + 1
	for i = count, #self.m_SkinBoxArr do
		self.m_SkinBoxArr[i]:SetActive(false)
	end
	self.m_SkinTexture:SetActive(false)
	
	self.m_SkinGrid:Reposition()
	if self.m_TimerID == nil then
		self.m_TimerID = Utils.AddTimer(callback(self, "UpdateScale"), 0, 0)
	end
end

function CNpcShopSkinPage.CreateSkinBox(self)
	local oSkinBox = self.m_SkinTexture:Clone()
	self.m_SkinGrid:AddChild(oSkinBox)
	function oSkinBox.SetData(self, oItemCell, oData)
		oSkinBox.m_ItemCell = oItemCell
		oSkinBox.m_Data = oData
		oSkinBox.m_GoodsInfo = g_NpcShopCtrl:GetGoodsInfoBySkinID(oData.id)
		if oSkinBox.m_GoodsInfo then
			oSkinBox.m_Price = g_NpcShopCtrl:GetGoodsPrice(oSkinBox.m_GoodsInfo.pos)
		else
			oSkinBox.m_Price = 0
		end
		if oSkinBox.m_GoodsInfo ~= nil then
			oSkinBox.m_GoodsData = g_NpcShopCtrl:GetGoodsData(oSkinBox.m_GoodsInfo.item_id)
		end
		oSkinBox:SetName(tostring(oData.id))
	end

	return oSkinBox
end

function CNpcShopSkinPage.UpdateScale(self)
	local tablePos = self.m_ScorllView:GetLocalPos().x
	for i,v in ipairs(self.m_SkinBoxArr) do
		local scaleValue = 1 - (math.abs(v:GetLocalPos().x + tablePos)) * 0.002
		if scaleValue < 0.5 then
			scaleValue = 0.5
		end
		v:SetLocalScale(Vector3.New(scaleValue, scaleValue, scaleValue))
	end
	self:OnCenter()
	return true
end

function CNpcShopSkinPage.OnCenter(self)
	local centerObj = self.m_ScorllView:GetCenteredObject()
	if centerObj == nil or self.m_CurrentCenter == centerObj then
		return
	end
	-- printc("OnCenter: " .. centerObj.name)
	local oSkinBox = self.m_SkinBoxDic[tonumber(centerObj.name)]
	self.m_CurrentSkinBox = oSkinBox
	if self.m_CurrentSkinBox == nil then
		return
	end
	self.m_CurrentCenter = centerObj
	-- self.m_SkinNameLabel:SetText(oSkinBox.m_Data.name)
	self.m_SkinNameSprite:SpriteSkinText(oSkinBox.m_Data.text_icon)
	self.m_SkinNameSprite:MakePixelPerfect()

	local itemlist = g_ItemCtrl:GetItemListBySid(oSkinBox.m_Data.id)
	self.m_ModelTexture:ChangeShape(oSkinBox.m_Data.shape)
	self.m_ModelTexture:SetRotate(0)
	self:RefreshBtn()
end

function CNpcShopSkinPage.RefreshBtn(self)
	if self.m_CurrentSkinBox == nil then
		return
	end
	local itemlist = g_ItemCtrl:GetItemListBySid(self.m_CurrentSkinBox.m_Data.id)
	local skinType = self.m_CurrentSkinBox.m_Data.skin_type
	self.m_OwnLabel:SetActive(false)
	self.m_OwnCurrencySprite:SetActive(false)
	self.m_ZSKBtn:SetActive(false)
	self.m_BuyBtn:SetActive(false)
	self.m_MarkLabel:SetActive(false)
	if self.m_CurrentSkinBox.m_Data.shape == 704 then
		self.m_ZSKBtn:SetActive(true)
	elseif skinType == define.Item.SkinType.Default or skinType == define.Item.SkinType.Awake then
		self.m_MarkLabel:SetActive(true)
		self.m_MarkLabel:SetText(data.itemdata.PARTNER_SKIN_TYPE[skinType].name)
	elseif #itemlist <= 0 and self.m_CurrentSkinBox.m_GoodsInfo ~= nil then
		self.m_OwnLabel:SetActive(true)
		self.m_OwnCurrencySprite:SetActive(true)
		self.m_BuyBtn:SetActive(true)
		self.m_BuyBtn:SetText("购买")
		self.m_CurrencyType = data.npcstoredata.DATA[self.m_CurrentSkinBox.m_GoodsInfo.item_id].coin_typ
		self.m_CurrentCurrency = g_NpcShopCtrl:GetCurrency(self.m_CurrencyType)
		self.m_OwnCurrencySprite:SetSpriteName(self.m_CurrentCurrency.icon)
		self.m_CostSprite:SetSpriteName(self.m_CurrentCurrency.icon)
		self.m_OwnLabel:SetNumberString(g_NpcShopCtrl:GetCurrencyValue(self.m_CurrencyType))
		self.m_BuyBtn:SetText(self.m_CurrentSkinBox.m_Price)
		-- self.m_BuyBtn:SetText("皮肤券:" .. self.m_CurrentSkinBox.m_GoodsInfo.price)
	else
		self.m_MarkLabel:SetActive(true)
		
		if #itemlist > 0 then
			self.m_MarkLabel:SetText("已获得")
		else
			self.m_MarkLabel:SetText(self.m_CurrentSkinBox.m_Data.name)
		end
	end
end

function CNpcShopSkinPage.OnAttrNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self.m_OwnCurrencySprite:SetSpriteName(self.m_CurrentCurrency.icon)
		self.m_OwnLabel:SetNumberString(g_NpcShopCtrl:GetCurrencyValue(self.m_CurrencyType))
	end
end


function CNpcShopSkinPage.OnClickBuy(self)
	if self.m_CurrentSkinBox == nil then
		g_NotifyCtrl:FloatMsg("请选择皮肤!")
		return
	elseif not g_NpcShopCtrl:IsGradeOK(self.m_CurrentSkinBox.m_GoodsData.id) then
		g_NotifyCtrl:FloatMsg("当前等级无法购买")
		return
	elseif self.m_CurrentSkinBox.m_Price > g_NpcShopCtrl:GetCurrencyValue(self.m_CurrencyType) then
		if self.m_CurrencyType == define.Currency.Type.GoldCoin then
			g_SdkCtrl:ShowPayView()
		elseif self.m_CurrencyType == define.Currency.Type.ColorCoin then
			g_SdkCtrl:ShowPayView()
		elseif self.m_CurrencyType == define.Currency.Type.Gold then
			g_NpcShopCtrl:ShowGold2CoinView()
		elseif self.m_CurrencyType == define.Currency.Type.RMB then
			return
		else
			self:ShowCurrencyGuide()
		end
		g_NotifyCtrl:FloatMsg(string.format("您的%s不足", self.m_CurrentCurrency.name))
	else
		-- local windowConfirmInfo = {
		-- 	msg = string.format("是否消耗%s%s购买？\n%s·%s", self.m_CurrentSkinBox.m_GoodsInfo.price, self.m_CurrentCurrency.name, self.m_PartnerNameLabel:GetText(), self.m_CurrentSkinBox.m_Data.name),
		-- 	okStr = "确定",
		-- 	cancelStr = "取消",
		-- 	okCallback = function()
		-- 		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSNpcStoreBuy"]) then
					netstore.C2GSNpcStoreBuy(self.m_CurrentSkinBox.m_GoodsData.id, 1, self.m_CurrentSkinBox.m_Price, self.m_CurrentSkinBox.m_GoodsInfo.pos)
		-- 		else
		-- 			-- g_NotifyCtrl:FloatMsg("你的手速成功超越了网速")
		-- 		end
		-- 	end
		-- }
		-- g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	end
end

function CNpcShopSkinPage.OnClickBack(self)
	self:DelUpdate()
	self.m_ParentView:ShowMain()
end

function CNpcShopSkinPage.DelUpdate(self)
	self.m_CurrentCenter = nil
	self.m_ItemCell = nil

	if self.m_TimerID ~= nil then
		Utils.DelTimer(self.m_TimerID)
		self.m_TimerID = nil
	end
end

function CNpcShopSkinPage.OnItemNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshPartnerSkin then
		if self.m_ItemCell ~= nil then
			self:RefreshUI(self.m_ItemCell)
		end
	end
end

return CNpcShopSkinPage