local CPartnerDetailPowerView = class("CPartnerDetailPowerView", CViewBase)

function CPartnerDetailPowerView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Rank/PartnerDetailPowerView.prefab", ob)
	self.m_ExtendClose = "Black"
end

function CPartnerDetailPowerView.OnCreateView(self)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_CloseBtn = self:NewUI(2, CBox)
	self.m_InfoGrid = self:NewUI(3, CGrid)
	self.m_InfoBox = self:NewUI(4, CBox)

	self:InitContent()
end

function CPartnerDetailPowerView.InitContent(self)
	self.m_RankType = define.Rank.SubType.Common
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CPartnerDetailPowerView.SetData(self, iSubType, oData)
	self.m_RankType = iSubType
	local iRank
	local iCount = 0
	for i,v in ipairs(oData) do
		local oPartner = g_PartnerCtrl:GetPartner(v.parid)
		if oPartner then
			iCount = iCount + 1
			local oInfoBox = self:CreateInfoBox()
			oInfoBox:AddUIEvent("click", callback(self, "OnClickBox", oInfoBox))
			self.m_InfoGrid:AddChild(oInfoBox)
			oInfoBox:SetData(v, iCount)
			oInfoBox:SetActive(true)
		end
	end
	self.m_InfoBox:SetActive(false)
end

function CPartnerDetailPowerView.OnClickBox(self, oInfoBox)
	g_RankCtrl:GetDataFromServer(define.Rank.RankId.Partner, 1, oInfoBox.m_Data:GetValue("partner_type"), self.m_RankType)
	self:OnClose()
end

function CPartnerDetailPowerView.CreateInfoBox(self, oInfoBox)
	local oInfoBox = self.m_InfoBox:Clone()
	oInfoBox.m_NameLabel = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_PowerLabel = oInfoBox:NewUI(2, CLabel)
	oInfoBox.m_RankLabel = oInfoBox:NewUI(3, CLabel)
	oInfoBox.m_BgSprite = oInfoBox:NewUI(4, CSprite)

	function oInfoBox.SetData(self, oData, idx)
		oInfoBox.m_Data = g_PartnerCtrl:GetPartner(oData.parid)
		oInfoBox.m_NameLabel:SetText(string.format("[u]%s[/u]", oInfoBox.m_Data:GetValue("name")))
		oInfoBox.m_PowerLabel:SetText(oData.power)
		oInfoBox.m_RankLabel:SetText(oData.rank)
		if idx % 2 == 1 then
			oInfoBox.m_BgSprite:SetSpriteName("bg_sanjimianban")
		else
			oInfoBox.m_BgSprite:SetSpriteName("pic_none")
		end
	end
	return oInfoBox
end

return CPartnerDetailPowerView