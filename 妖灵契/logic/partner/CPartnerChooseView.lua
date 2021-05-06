local CPartnerChooseView = class("CPartnerChooseView", CViewBase)

function CPartnerChooseView.ctor(self, cb)
	CViewBase.ctor(self, "UI/partner/PartnerChooseView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CPartnerChooseView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_AmountLabel = self:NewUI(2, CLabel)
	self.m_FilterGrid = self:NewUI(3, CGrid)
	self.m_TitleLabel = self:NewUI(4, CLabel)
	self.m_ScrollView = self:NewUI(5, CScrollView)
	self.m_WrapContent = self:NewUI(6, CWrapContent)
	self.m_CardList = self:NewUI(7, CBox)
	self:InitContent()
	self.m_IsOpenAni = true
end

function CPartnerChooseView.InitContent(self)
	self.m_CardList:SetActive(false)
	self.m_RowAmount = 5
	self:InitFilter()
	self:InitWrapContent()
	self:UpdateFilter(0)
	self.m_FilterGrid:GetChild(1):SetSelected(true)
	local cb = function ()
		if Utils.IsNil(self) then
			return
		end
		self.m_IsOpenAni = false
	end
	Utils.AddTimer(cb, 0, 0.3)	
	g_GuideCtrl:AddGuideUI("partner_choose_partner_403")				
	g_GuideCtrl:AddGuideUI("partner_choose_partner_501")	
	g_GuideCtrl:AddGuideUI("partner_choose_partner_502")		
end

function CPartnerChooseView.InitFilter(self)
	local rarelist = {0, 2, 1,}
	self.m_FilterGrid:InitChild(function(obj, idx)
		local oBtn = CLabel.New(obj, false)
		oBtn:AddUIEvent("click", callback(self, "UpdateFilter", rarelist[idx]))
		oBtn:SetGroup(self.m_FilterGrid:GetInstanceID())
		return oBtn
	end)
end

function CPartnerChooseView.InitWrapContent(self)
	self.m_WrapContent:SetCloneChild(self.m_CardList, callback(self, "CloneCardList"))
	self.m_WrapContent:SetRefreshFunc(callback(self, "RefreshCardList"))
end

--点击回调
function CPartnerChooseView.SetConfirmCb(self, cb)
	self.m_ConfirmCb = cb
end

--过滤回调
function CPartnerChooseView.SetFilterCb(self, cb)
	self.m_FilterCb = cb
	self:RefreshContent()
end

--特殊类型需求
function CPartnerChooseView.SetType(self, sType)
	-- body
end

function CPartnerChooseView.CloneCardList(self, obj)
	obj.m_List = {}
	for i = 1, self.m_RowAmount do
		local oCard = obj:NewUI(i, CBox)
		oCard.m_InBorderSpr = oCard:NewUI(1, CSprite)
		oCard.m_OutBorderSpr = oCard:NewUI(2, CSprite)
		oCard.m_RareLabel = oCard:NewUI(3, CLabel)
		oCard.m_AwakeSpr = oCard:NewUI(4, CSprite)
		oCard.m_Texture = oCard:NewUI(5, CTexture)
		oCard.m_GradeLabel = oCard:NewUI(6, CLabel)
		oCard.m_NameLabel = oCard:NewUI(7, CLabel)
		oCard.m_StarGrid = oCard:NewUI(8, CGrid)
		oCard.m_RareSpr = oCard:NewUI(9, CSprite)
		oCard.m_LockSpr = oCard:NewUI(10, CSprite)
		oCard.m_StarList = {}
		oCard.m_StarGrid:InitChild(function(obj, idx)
			local spr = CSprite.New(obj)
			oCard.m_StarList[idx] = spr
			return spr
		end)
		oCard:SetActive(false)
		obj.m_List[i] = oCard
	end
	return obj
end

function CPartnerChooseView.RefreshCardList(self, obj, dData)
	if dData then
		obj:SetActive(true)
		for i = 1, self.m_RowAmount do			
			self:UpdateCard(obj.m_List[i], dData[i])
			if not g_GuideCtrl:GetGuideUI("partner_choose_partner_403") and dData[i] and dData[i].GetValue and dData[i]:GetValue("partner_type") == 403 then				
				g_GuideCtrl:AddGuideUI("partner_choose_partner_403", obj.m_List[i])				
			end
			if not g_GuideCtrl:GetGuideUI("partner_choose_partner_501") and dData[i] and dData[i].GetValue and dData[i]:GetValue("partner_type") == 501 then
				g_GuideCtrl:AddGuideUI("partner_choose_partner_501", obj.m_List[i])				
			end		
			if not g_GuideCtrl:GetGuideUI("partner_choose_partner_502") and dData[i] and dData[i].GetValue and dData[i]:GetValue("partner_type") == 502 then
				g_GuideCtrl:AddGuideUI("partner_choose_partner_502", obj.m_List[i])				
			end					
		end
	else
		obj:SetActive(false)
	end
end
function CPartnerChooseView.UpdateCard(self, obj, oPartner)
	if oPartner then
		obj:SetActive(true)
		obj.m_Texture:SetActive(false)
		obj.m_Texture:LoadCardPhoto(oPartner:GetIcon(), function () obj.m_Texture:SetActive(true) end)
		if oPartner:GetValue("awake") == 1 then
			obj.m_AwakeSpr:SetActive(true)
			obj.m_RareLabel:SetLocalPos(Vector3.New(-23, 75, 0))
		else
			obj.m_AwakeSpr:SetActive(false)
			obj.m_RareLabel:SetLocalPos(Vector3.New(-38, 75, 0))
		end
		obj.m_LockSpr:SetActive(oPartner:IsLock())
		obj.m_GradeLabel:SetText(tostring(oPartner:GetValue("grade")))
		
		local iRare = oPartner:GetValue("rare")
		obj.m_RareLabel:SetText(g_PartnerCtrl:GetRareText(iRare))
		iRare = iRare + 2
		obj.m_OutBorderSpr:SetSpriteName("pic_card_out"..tostring(iRare))
		obj.m_InBorderSpr:SetSpriteName("pic_card_in"..tostring(iRare))
		obj.m_AwakeSpr:SetSpriteName("pic_card_awake"..tostring(iRare))
		obj.m_RareSpr:SetSpriteName("pic_card_rare"..tostring(iRare))
		obj.m_NameLabel:SetText(oPartner:GetValue("name"))
		local iStar = oPartner:GetValue("star")
		for i = 1, 5 do
			if iStar >= i then
				obj.m_StarList[i]:SetSpriteName("pic_chouka_dianliang")
			else
				obj.m_StarList[i]:SetSpriteName("pic_chouka_weidianliang")
			end
		end
		obj.m_ID = oPartner.m_ID
		obj:AddUIEvent("click", callback(self, "OnClickPartner", obj.m_ID))		

	else
		obj.m_ID = nil
		obj:SetActive(false)
	end
end


function CPartnerChooseView.UpdateFilter(self, iKey)
	self.m_FilterKey = iKey
	self:RefreshContent()
end

function CPartnerChooseView.RefreshContent(self)
	local partnerList = self:GetPartnerList()
	self.m_WrapContent:SetData(partnerList, true)
	self.m_ScrollView:ResetPosition()
end

function CPartnerChooseView.GetPartnerList(self)
	local newlist = {}
	local filterkey = self.m_FilterKey or 0
	newlist = g_PartnerCtrl:GetPartnerByRare(filterkey)
	if self.m_FilterCb then
		newlist = self.m_FilterCb(newlist)
		if newlist == false then
			newlist = {}
		end
	end
	table.sort(newlist, callback(self, "SortFunc"))
	self.m_AmountLabel:SetText("数量："..tostring(#newlist))

	if g_GuideCtrl:IsCustomGuideFinishByKey("DrawCardLineUp_MainMenu") and not g_GuideCtrl:IsCustomGuideFinishByKey("DrawCardLineUp_PartnerMain") then
		newlist = self:SortPartnerByGuide(newlist, 502)	
		
	elseif g_GuideCtrl:IsCustomGuideFinishByKey("DrawCardLineUp_Two_MainMenu") and not g_GuideCtrl:IsCustomGuideFinishByKey("DrawCardLineUp_Two_PartnerMain") then	
		newlist = self:SortPartnerByGuide(newlist, 403)

	elseif g_GuideCtrl:IsCustomGuideFinishByKey("Partner_HPPY_PartnerMain") and not g_GuideCtrl:IsCustomGuideFinishByKey("DrawCardLineUp_Three_PartnerMain") then
		newlist = self:SortPartnerByGuide(newlist, 501)
	end

	newlist = self:GetDivideList(newlist)
	return newlist
end

function CPartnerChooseView.GetDivideList(self, list)
	local newlist = {}
	local data = {}
	for i, oPartner in ipairs(list) do
		table.insert(data, oPartner)
		if #data >= self.m_RowAmount then
			table.insert(newlist, data)
			data = {}
		end
	end
	if #data > 0 then
		table.insert(newlist, data)
	end
	return newlist
end

function CPartnerChooseView.SortFunc(self, oPartner1, oPartner2)
	local pos1 = g_PartnerCtrl:GetFightPos(oPartner1:GetValue("parid")) or 9999
	local pos2 = g_PartnerCtrl:GetFightPos(oPartner2:GetValue("parid")) or 9999
	if pos1 ~= pos2 then
		return pos1 < pos2
	end
	if self.m_FilterKey == 1 then
		local partnertype1 = oPartner1:GetValue("partner_type")
		local partnertype2 = oPartner2:GetValue("partner_type")
		if partnertype1 ~= partnertype2 then
			if partnertype1 == 1753 then return true end
			if partnertype2 == 1753 then return false end
		end
	end
	local iPowner1 = oPartner1:GetValue("power")
	local iPowner2 = oPartner2:GetValue("power")
	if iPowner1 and iPowner2 and iPowner1 ~= iPowner2 then
		return iPowner2 < iPowner1
	end
	return oPartner1:GetValue("parid") < oPartner2:GetValue("parid")
end

function CPartnerChooseView.OnClickPartner(self, iParterID)
	if self.m_ConfirmCb then
		self.m_ConfirmCb(iParterID)
	end
	self:OnClose()
end

function CPartnerChooseView.RefreshGuideContent(self)
	self:DelayCall(0, "UpdateFilter", 2)
	self.m_FilterGrid:GetChild(4):SetSelected(true)
end

function CPartnerChooseView.SortPartnerByGuide(self, partnerList, partner_type)
	local t = {}
	if partnerList and next(partnerList) then
		for i, v in ipairs(partnerList) do
			if v:GetValue("partner_type") == partner_type then
				table.insert(t, 1, v)
			else
				table.insert(t, v)
			end
		end
	end
	return t
end

return CPartnerChooseView