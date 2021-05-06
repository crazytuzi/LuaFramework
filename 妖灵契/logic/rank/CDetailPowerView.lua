local CDetailPowerView = class("CDetailPowerView", CViewBase)

function CDetailPowerView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Rank/DetailPowerView.prefab", ob)
	self.m_ExtendClose = "Black"
end

function CDetailPowerView.OnCreateView(self)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_PowerLabel = self:NewUI(2, CLabel)
	self.m_InfoGrid = self:NewUI(3, CGrid)
	self.m_InfoBox = self:NewUI(4, CBox)

	self:InitContent()
end

function CDetailPowerView.InitContent(self)
end

function CDetailPowerView.SetData(self, oData)
	local playerData = {}
	local partnerDataList = {}
	local totalPower = 0
	local x = 1
	for k,v in pairs(oData) do
		if v.ttype == 0 then
			playerData = v
		else
			table.insert(partnerDataList, v)
		end
		totalPower = totalPower + v.power
	end
	self.m_NameLabel:SetText(playerData.name)
	self.m_PowerLabel:SetText("战力:" .. totalPower)
	
	self:CreateInfoBox(self.m_InfoBox)
	self:SetPlayerData(self.m_InfoBox, playerData)

	for i,v in ipairs(partnerDataList) do
		local oInfoBox = self.m_InfoBox:Clone()
		self:CreateInfoBox(oInfoBox)
		self:SetPartnerData(oInfoBox, v)
		oInfoBox.m_BgSprite:SetSpriteName("pic_di0" .. ((i + 1) % 2 + 1))
		self.m_InfoGrid:AddChild(oInfoBox)
	end
	self.m_InfoGrid:Reposition()
end

function CDetailPowerView.CreateInfoBox(self, oInfoBox)
	oInfoBox.m_Shape = oInfoBox:NewUI(1, CSprite)
	oInfoBox.m_PowerLabel = oInfoBox:NewUI(2, CLabel)
	oInfoBox.m_NameLabel = oInfoBox:NewUI(3, CLabel)
	oInfoBox.m_GradeLabel = oInfoBox:NewUI(4, CLabel)
	oInfoBox.m_QualitySprite = oInfoBox:NewUI(5, CSprite)
	oInfoBox.m_BgSprite = oInfoBox:NewUI(6, CSprite)
end

function CDetailPowerView.SetPlayerData(self, oInfoBox, playerData)
	oInfoBox.m_Shape:SpriteAvatar(playerData.model_info.shape)
	oInfoBox.m_PowerLabel:SetText("战力:" .. playerData.power)
	oInfoBox.m_NameLabel:SetText(string.format("%s(%s)", playerData.name, playerData.othername))
	oInfoBox.m_GradeLabel:SetText(playerData.grade)
	oInfoBox.m_BgSprite:SetSpriteName("pic_di02")
end

function CDetailPowerView.SetPartnerData(self, oInfoBox, partnerData)
	oInfoBox.m_Shape:SpriteAvatar(partnerData.model_info.shape)
	oInfoBox.m_PowerLabel:SetText("战力:" .. partnerData.power)
	oInfoBox.m_NameLabel:SetText(partnerData.name == "" and partnerData.othername or partnerData.name)
	oInfoBox.m_GradeLabel:SetText(partnerData.grade)
	local parData = data.partnerdata.DATA[partnerData.parsid] or {}
	oInfoBox.m_QualitySprite:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(parData.rare))
end


return CDetailPowerView