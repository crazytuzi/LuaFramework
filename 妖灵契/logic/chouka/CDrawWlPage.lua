local CDrawWlPage = class("CDrawWlPage", CPageBase)

function CDrawWlPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CDrawWlPage.OnInitPage(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CartGrid = self:NewUI(2, CGrid)
	self.m_CardBox = self:NewUI(3, CBox)

	self.m_AgainBtn = self:NewUI(4, CButton)
	self.m_SmallCardBox = self:NewUI(5, CBox)
	self.m_JoinUpBtn = self:NewUI(6, CButton)
	self.m_CloseBtn2 = self:NewUI(7, CButton)
	self.m_BtnContainer = self:NewUI(8, CObject)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CloseBtn2:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AgainBtn:AddUIEvent("click", callback(self, "OnAgain"))
	self:InitCardBox(self.m_CardBox)
	self.m_SmallCardBox:SetActive(false)
	g_GuideCtrl:AddGuideUI("close_wl_result_rt", self.m_CloseBtn)
	g_GuideCtrl:AddGuideUI("close_wl_result_lb", self.m_CloseBtn2)
end

function CDrawWlPage.SyncCardPos(self, oCard, iEffectIdx)
	local oEffect = g_ChoukaCtrl.m_WLEffectList[iEffectIdx]
	local oPos = oEffect:GetPos()
	local oChoukaCam = g_CameraCtrl:GetChoukaCamera()
	local oUICam = g_CameraCtrl:GetUICamera()
	local viewPos = oWarCam:WorldToViewportPoint(warpos)
	local oUIPos = oUICam:ViewportToWorldPoint(viewPos)
	oUIPos.z = 0
	oCard:SetPos(oUIPos)
end

function CDrawWlPage.SetResult(self, parlist)
	g_GuideCtrl:DelGuideUIEffect("close_wl_result_lb", "round")
	if #parlist == 1 then
		self.m_CartGrid:SetActive(false)
		self.m_CardBox:SetActive(true)
		self:SetCardPartner(self.m_CardBox, parlist[1])
		g_ChoukaCtrl:SyncCardPos(self.m_CardBox, 1)
	else
		self.m_CartGrid:Clear()
		self.m_CardBox:SetActive(false)
		self.m_CartGrid:SetActive(true)
		local amount = #parlist
		for i, parid in ipairs(parlist) do
			local oPartner = g_PartnerCtrl:GetPartner(parid)
			if oPartner then
				local smallbox = self.m_SmallCardBox:Clone()
				local box = smallbox:NewUI(1, CBox)
				smallbox.m_CardBox = box
				self:InitCardBox(box)
				self:SetCardPartner(box, parid)
				local v = box:GetLocalPos()
				local x = math.floor(math.abs(i - (1 + amount)/2))
				v.y = v.y + x*5
				box:SetLocalPos(v)
				box:SetDepth(box:GetDepth()+i)
				smallbox:SetActive(true)
				self.m_CartGrid:AddChild(smallbox)
				g_ChoukaCtrl:SyncCardPos(smallbox, i)
			end
		end
		-- self.m_CartGrid:Reposition()
	end

	if g_GuideCtrl:IsCustomGuideFinishByKey("Open_ZhaoMu") and not g_GuideCtrl:IsCustomGuideFinishByKey("DrawCard") then
		self.m_IsInDrawCardGuide = true
	end
end

function CDrawWlPage.SetBtnShow(self, bShow)
	self.m_BtnContainer:SetActive(bShow)
end

function CDrawWlPage.SetCardPartner(self, box, parid)
	local oPartner = g_PartnerCtrl:GetPartner(parid)
	box.m_NameLabel:SetText(oPartner:GetValue("name"))
	box:SetActive(false)
	box.m_StarGrid:Clear()
	for i = 1, 5 do
		local starbox = box.m_StarBox:Clone()
		starbox.m_StarSpr = starbox:NewUI(1, CSprite)
		starbox.m_GreySpr = starbox:NewUI(2, CSprite)
		starbox.m_StarSpr:SetActive(oPartner:GetValue("star") >= i)
		starbox.m_GreySpr:SetActive(oPartner:GetValue("star") < i)
		starbox:SetActive(true)
		box.m_StarGrid:AddChild(starbox)
	end
	box.m_RareSpr:SetSpriteName("text_xiaodengji_"..tostring(oPartner:GetValue("rare")))
	box.m_PartnerTexture:ChangeShape(oPartner:GetValue("shape"), {}, function () box:SetActive(true) end)
end

function CDrawWlPage.InitCardBox(self, box)
	box.m_NameLabel = box:NewUI(1, CLabel)
	box.m_RareSpr = box:NewUI(2, CSprite)
	box.m_PartnerTexture = box:NewUI(3, CActorTexture)
	box.m_StarGrid = box:NewUI(4, CGrid)
	box.m_StarBox = box:NewUI(5, CBox)
	box.m_StarBox:SetActive(false)
end

function CDrawWlPage.OnAgain(self)
	if not g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSDrawWuLingCard"], 5) then
		return
	end
	local bUp = self.m_JoinUpBtn:GetSelected()
	local istate = IOTools.GetRoleData("chouka_bullet") or 1
	netpartner.C2GSDrawWuLingCard(1, istate == 0)
end

function CDrawWlPage.OnAgainMore(self)
	local bUp = self.m_JoinUpBtn:GetSelected()
	netpartner.C2GSDrawWuLingCard(5)
end

function CDrawWlPage.OnClose(self)
	self.m_ParentView:ShowMain()
	g_ChoukaCtrl:ShowMainPage(1)
	if self.m_IsInDrawCardGuide == true then
		g_GuideCtrl:DelayShowDrawCloseLBEffect()
	end
end

return CDrawWlPage