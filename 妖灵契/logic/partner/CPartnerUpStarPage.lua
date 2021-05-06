local CPartnerUpStarPage = class("CPartnerUpStarPage", CPageBase)

function CPartnerUpStarPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CPartnerUpStarPage.OnInitPage(self)
	self.m_LStarGrid = self:NewUI(1, CGrid)
	self.m_RStarGrid = self:NewUI(2, CGrid)
	self.m_StarBox = self:NewUI(3, CBox)
	self.m_AttrPart = self:NewUI(4, CBox)
	self.m_ConfirmBtn = self:NewUI(5, CButton)
	self.m_NeedItemPart = self:NewUI(6, CBox)
	self.m_TipLabel = self:NewUI(7, CLabel)
	self.m_TipBtn = self:NewUI(8, CButton)
	self.m_UpStarPart = self:NewUI(9, CObject)
	self.m_FullPart = self:NewUI(10, CObject)
	self.m_StarBox:SetActive(false)
	self.m_TipLabel:SetActive(false)
	self:InitAttrPart()
	self:InitNeedItem()
	self.m_TipBtn:AddHelpTipClick("partner_upstar")
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnUpStar"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
end

function CPartnerUpStarPage.InitAttrPart(self)
	self.m_AttrList = {}
	local list = {"maxhp", "defense", "attack"}
	for i, name in ipairs(list) do
		self.m_AttrList[name] = self.m_AttrPart:NewUI(i*2-1, CLabel)
		self.m_AttrList["next_"..name] = self.m_AttrPart:NewUI(i*2, CLabel)
	end
	for i = 1, 5 do
		local spr = self.m_StarBox:Clone()
		spr.m_Effect = spr:NewUI(1, CUIEffect)
		spr.m_Spr = spr:NewUI(2, CSprite)
		spr.m_Effect:Above(self.m_StarBox)
		spr.m_Effect:SetActive(false)
		spr:SetActive(true)

		self.m_LStarGrid:AddChild(spr)
		local spr2 = self.m_StarBox:Clone()
		spr2.m_Effect = spr2:NewUI(1, CUIEffect)
		spr2.m_Spr = spr2:NewUI(2, CSprite)
		spr2.m_Effect:Above(self.m_StarBox)
		spr2.m_Effect:SetActive(false)
		spr2:SetActive(true)

		self.m_RStarGrid:AddChild(spr2)
	end
	self.m_LStarGrid:Reposition()
	self.m_RStarGrid:Reposition()
end

function CPartnerUpStarPage.InitNeedItem(self)
	self.m_ItemBox = self.m_NeedItemPart:NewUI(1, CItemTipsBox)
	self.m_AmountLabel = self.m_NeedItemPart:NewUI(2, CLabel)
	self.m_GoldLabel = self.m_NeedItemPart:NewUI(3, CLabel)
	self.m_Slider = self.m_NeedItemPart:NewUI(4, CSlider)
end

function CPartnerUpStarPage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		if oCtrl.m_EventData == self.m_CurParID then
			self.m_CacheData = {}
			self:UpdatePartner()
		end
	end
end

function CPartnerUpStarPage.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if oCtrl.m_EventData["dAttr"]["coin"] then
			local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
			if oPartner then
				self:UpdateCost(oPartner)
			end
		end
	end
end

function CPartnerUpStarPage.SetPartnerID(self, parid)
	self.m_CurParID = parid
	self:UpdatePartner()
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if oPartner then
		oPartner:SetUpStarRedPoint()
	end
end

function CPartnerUpStarPage.UpdatePartner(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end

	if oPartner:GetValue("partner_type") == 302 then
		g_GuideCtrl:AddGuideUI("partner_up_star_confirm_302_btn", self.m_ConfirmBtn)
		local guide_ui = {"partner_up_star_confirm_302_btn"}
		g_GuideCtrl:LoadTipsGuideEffect(guide_ui)		
	end

	if oPartner:GetValue("star") == 5 then
		self.m_UpStarPart:SetActive(false)
		self.m_FullPart:SetActive(true)
		return
	else
		self.m_UpStarPart:SetActive(true)
		self.m_FullPart:SetActive(false)
	end
	self:UpdateStar(oPartner)
	self:UpdateCost(oPartner)
	self:UpdateAttr(oPartner)
	g_GuideCtrl:TriggerAll()
end

function CPartnerUpStarPage.UpdateStar(self, oPartner)
	local iStar = oPartner:GetValue("star")
	for i, spr in ipairs(self.m_LStarGrid:GetChildList()) do
		if i <= iStar then
			spr.m_Spr:SetSpriteName("pic_chouka_dianliang")
		else
			spr.m_Spr:SetSpriteName("pic_chouka_weidianliang")
		end
	end
	local iRStar = math.min(iStar+1, 5)
	for i, spr in ipairs(self.m_RStarGrid:GetChildList()) do
		if i <= iRStar then
			spr.m_Spr:SetSpriteName("pic_chouka_dianliang")
		else
			spr.m_Spr:SetSpriteName("pic_chouka_weidianliang")
		end
	end
end

function CPartnerUpStarPage.DoUpEffect(self)
	if self.m_CloseEffctTimer then
		Utils.DelTimer(self.m_CloseEffctTimer)
	end
	self:CloseUpEffect()
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if not oPartner then
		return
	end
	local iStar = oPartner:GetValue("star")
	for i, spr in ipairs(self.m_LStarGrid:GetChildList()) do
		if i == iStar + 1 then
			spr.m_Effect:SetActive(true)
		end
	end
	local iRStar = math.min(iStar+1, 5)
	for i, spr in ipairs(self.m_RStarGrid:GetChildList()) do
		if i == iRStar + 1 then
			spr.m_Effect:SetActive(true)
		end
	end
	self.m_CloseEffctTimer = Utils.AddTimer(callback(self, "CloseUpEffect"), 0, 2)
end

function CPartnerUpStarPage.CloseUpEffect(self)
	for i, spr in ipairs(self.m_LStarGrid:GetChildList()) do
		spr.m_Effect:SetActive(false)
	end
	for i, spr in ipairs(self.m_RStarGrid:GetChildList()) do
		spr.m_Effect:SetActive(false)
	end
	self.m_CloseEffctTimer = nil
end

function CPartnerUpStarPage.UpdateAttr(self, oPartner)
	self.m_CacheData = self.m_CacheData or {}
	local dict = self.m_CacheData[oPartner.m_ID] or {}
	local list = {"maxhp", "attack", "defense"}
	for i, name in ipairs(list) do
		self.m_AttrList[name]:SetText(tostring(oPartner:GetValue(name)))
		self.m_AttrList["next_"..name]:SetText(dict[name] or "")
	end
	if not dict["maxhp"] then
		netpartner.C2GSOpenPartnerUI(oPartner.m_ID, 2)
	end
end

function CPartnerUpStarPage.UpdateAttrResult(self, iParID, dApplyList)
	local dict = {}
	for _, dAttr in ipairs(dApplyList) do
		dict[dAttr.key] = dAttr.value
	end
	self.m_CacheData = self.m_CacheData or {}
	self.m_CacheData[iParID] = dict
	
	if self.m_CurParID == iParID then
		local list = {"maxhp", "attack", "defense"}
		for i, name in ipairs(list) do
			self.m_AttrList["next_"..name]:SetText(tostring(dict[name]))
		end
	end
end

function CPartnerUpStarPage.UpdateCost(self, oPartner)
	local iStar = oPartner:GetValue("star")
	if iStar >= 5 then
		self.m_NeedItemPart:SetActive(false)
		self.m_TipLabel:SetActive(true)
		self.m_TipLabel:SetText("该伙伴已经满星了")
		return
	else
		self.m_NeedItemPart:SetActive(true)
	end
	local upstardata = data.partnerdata.UPSTAR
	local iNeedAmount = upstardata[iStar]["cost_amount"]
	local iGold = upstardata[iStar]["cost_coin"]
	local iLimitGrade = upstardata[iStar]["limit_level"]
	if oPartner:GetValue("grade") < iLimitGrade then
		self.m_ConfirmBtn:SetActive(false)
		self.m_TipLabel:SetActive(true)
		self.m_GoldLabel:SetActive(false)
		self.m_TipLabel:SetText(string.format("需要伙伴%d级才能升星", iLimitGrade))
	else
		self.m_GoldLabel:SetActive(true)
		self.m_ConfirmBtn:SetActive(true)
		self.m_TipLabel:SetActive(false)
	end

	local iChipType = g_PartnerCtrl:GetChipByPartner(oPartner:GetValue("partner_type"))
	local oItem = g_PartnerCtrl:GetSingleChipInfo(iChipType)
	self.m_ItemBox:SetItemData(iChipType, 1, nil, {isLocal = true, uiType = 1, openView = self.m_ParentView})
	local iAmount = oItem:GetValue("amount")
	self.m_AmountLabel:SetText(string.format("%d/%d", iAmount, iNeedAmount))
	self.m_Slider:SetValue(iAmount / iNeedAmount)
	--self.m_GoldLabel:SetActive(iAmount >= iNeedAmount)
	if g_AttrCtrl.coin >= iGold then
		self.m_GoldLabel:SetRichText(string.format("#w1%s", string.numberConvert(iGold)))
	else
		self.m_GoldLabel:SetRichText(string.format("#R #w1%s", string.numberConvert(iGold)))
	end
end

function CPartnerUpStarPage.OnUpStar(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if oPartner then
		netpartner.C2GSUpgradePartnerStar(oPartner.m_ID)
	end
	g_GuideCtrl:ReqTipsGuideFinish("partner_up_star_confirm_302_btn")
end

return CPartnerUpStarPage