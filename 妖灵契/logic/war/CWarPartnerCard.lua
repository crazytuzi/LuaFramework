	local CWarPartnerCard = class("CWarPartnerCard", CBox)

function CWarPartnerCard.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_RareInSpr = self:NewUI(2, CSprite)
	self.m_RareOutSpr = self:NewUI(3, CSprite)
	self.m_PartnerTexture = self:NewUI(4, CTexture)
	self.m_GradeLabel = self:NewUI(5, CLabel)
	self.m_AwakeSpr = self:NewUI(7, CSprite)
	self.m_StarGrid = self:NewUI(8, CGrid)
	self.m_StarSpr = self:NewUI(9, CSprite)
	self.m_LockSpr = self:NewUI(10, CSprite)
	self.m_RareTxtSpr = self:NewUI(11, CSprite)
	self.m_RareLabel = self:NewUI(12, CLabel)
	self.m_StateLabel = self:NewUI(13, CLabel)
	self.m_PataHpGroup = self:NewUI(14, CBox)
	self.m_PataHpProgress = self:NewUI(15, CSlider)
	self.m_PartnerID = nil
	self.m_State = nil
	self.m_StarSpr:SetActive(false)
	self.m_PartnerTexture:SetMainTexture(nil)
	self.m_PartnerTexture:SetAsyncLoad(true)
	self.m_StarGrid:InitChild(function (obj, idx)
		obj:SetActive(false)
	end)
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvent"))
end

function CWarPartnerCard.Destroy(self)
	g_UITouchCtrl:DelDragObject(self)
	CBox.Destroy(self)
end

function CWarPartnerCard.OnWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.PartnerChange or
		oCtrl.m_EventID == define.War.Event.Replace then
		self:Refresh()
	end
end

function CWarPartnerCard.SetPartnerID(self, parid)
	self.m_PartnerID = parid
	self:Refresh()
end

function CWarPartnerCard.Refresh(self)
	if self.m_PartnerID then
		local oPartner = g_PartnerCtrl:GetPartner(self.m_PartnerID)
		local sName = oPartner:GetValue("name")
		local iState = g_WarCtrl:GetPartnerState(self.m_PartnerID)
		local sState
		local bGrey = false
		if iState == define.Partner.State.InWar then
			sState = "#G(参战中)"
		elseif iState == define.Partner.State.AlreadyWar then
			sState = "#Y(已参战)"
			bGrey = true
		elseif iState == define.Partner.State.Died then
			sState = "#R(已阵亡)"
			bGrey = true
		end

		if sState then
			self.m_StateLabel:SetActive(true)
			self.m_StateLabel:SetText(sState)
		else
			self.m_StateLabel:SetActive(false)
		end
		
		self.m_PataHpGroup:SetActive(false)
		if g_WarCtrl:GetWarType() == define.War.Type.Pata then
			if iState ~= define.Partner.State.Died then
				local pataHp = oPartner:GetValue("patahp") or 0
				local maxHp = oPartner:GetValue("max_hp") or 1
				self.m_PataHpProgress:SetValue(pataHp / maxHp)
				self.m_PataHpGroup:SetActive(true)
			end
		end

		self.m_NameLabel:SetText(sName)
		if g_WarCtrl:IsReplace() and not g_WarCtrl:IsPrepare() then

		end
		self.m_PartnerTexture:LoadCardPhoto(oPartner:GetShape())
		local iRare = oPartner:GetValue("rare")

		self.m_RareInSpr:SetSpriteName("pic_card_out"..tostring(iRare+2))
		self.m_RareOutSpr:SetSpriteName("pic_card_in"..tostring(iRare+2))
		self.m_AwakeSpr:SetSpriteName("pic_card_awake"..tostring(iRare+2))
		self.m_RareTxtSpr:SetSpriteName("pic_card_rare"..tostring(iRare+2))
		self.m_RareLabel:SetText(g_PartnerCtrl:GetRareText(iRare))

		self.m_LockSpr:SetActive(oPartner:IsLock())
		if oPartner:GetValue("awake") == 1 then
			self.m_AwakeSpr:SetActive(true)
			self.m_RareLabel:SetLocalPos(Vector3.New(44, -18, 0))
		else
			self.m_AwakeSpr:SetActive(false)
			self.m_RareLabel:SetLocalPos(Vector3.New(30, -18, 0))
		end

		self.m_AwakeSpr:SetActive(oPartner:GetValue("awake") == 1)
		self.m_RareInSpr:SetGrey(bGrey)
		self.m_RareOutSpr:SetGrey(bGrey)
		self:SetGrey(bGrey)
		self.m_State = iState
		self.m_GradeLabel:SetText(string.format("%d", oPartner:GetValue("grade")))
		local iStar = oPartner:GetValue("star")
		if self.m_StarGrid:GetCount() ~= iStar then
			self.m_StarGrid:Clear()
			for i=1, iStar do
				local oStar = self.m_StarSpr:Clone()
				oStar:SetActive(true)
				self.m_StarGrid:AddChild(oStar)
			end
		end
	end
end

function CWarPartnerCard.GetWarStateText(self)

end

function CWarPartnerCard.IsCanFight(self)
	if g_WarCtrl:IsInReplceInfos(self.m_PartnerID) then
		return true
	else
		return self.m_State == nil
	end
end

return CWarPartnerCard