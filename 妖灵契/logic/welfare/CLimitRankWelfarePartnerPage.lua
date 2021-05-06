local CLimitRankWelfarePartnerPage = class("CLimitRankWelfarePartnerPage", CPageBase)

function CLimitRankWelfarePartnerPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CLimitRankWelfarePartnerPage.OnInitPage(self)
	self.m_OpenRankBtn = self:NewUI(1, CButton)
	self.m_TimeLabel = self:NewUI(2, CLabel)
	self.m_AwardBox = self:NewUI(3, CBox)
	self.m_WrapContent = self:NewUI(4, CWrapContent)
	self:InitContent()
end

function CLimitRankWelfarePartnerPage.InitContent(self)
	local sStart = os.date("%Y年%m月%d日", g_WelfareCtrl.m_RankBackStartTime)
	local sEnd = os.date("%Y年%m月%d日%H时", g_WelfareCtrl.m_RankBackEndTime)
	self.m_TimeLabel:SetText(string.format("%s-%s", sStart, sEnd))
	self.m_OpenRankBtn:AddUIEvent("click", callback(self, "OpenRank"))
	self.m_AwardBox:SetActive(false)
	self.m_WrapContent:SetCloneChild(self.m_AwardBox, callback(self, "CreateInfoBox"))
	self.m_WrapContent:SetRefreshFunc(function(oBox, dData)
		if dData then
			oBox:SetData(dData)
			oBox:SetActive(true)
		else
			oBox:SetActive(false)
		end
	end)
	self.m_WrapContent:SetData(self:GetData(), true)
end

function CLimitRankWelfarePartnerPage.OpenRank(self)
	g_RankCtrl:OpenRank(define.Rank.RankId.Partner)
end

function CLimitRankWelfarePartnerPage.GetData(self)
	local lData = {}
	for k,v in pairs(data.welfaredata.PartnerRank) do
		local oData = {}
		oData.partnerData = data.partnerdata.DATA[v.subtype]
		oData.amount = 0
		if v.reward[1] then
			oData.amount = v.reward[1].amount
			oData.chipData = data.partnerdata.CHIP[tonumber(v.reward[1].sid)]
		end
		table.insert(lData, oData)
	end
	local function sortFunc(v1, v2)
		if v1.partnerData.rare ~= v2.partnerData.rare then
			return v1.partnerData.rare > v2.partnerData.rare
		end
		return v1.partnerData.partner_type < v2.partnerData.partner_type
	end
	table.sort(lData, sortFunc)
	return lData
end

function CLimitRankWelfarePartnerPage.CreateInfoBox(self, oInfoBox)
	oInfoBox.m_NameLabel = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_AvatarSprite = oInfoBox:NewUI(2, CSprite)
	oInfoBox.m_BgSprite = oInfoBox:NewUI(3, CSprite)
	oInfoBox.m_AmountLabel = oInfoBox:NewUI(4, CLabel)
	oInfoBox.m_DescLabel = oInfoBox:NewUI(5, CLabel)
	oInfoBox.m_RareSprite = oInfoBox:NewUI(6, CSprite)

	oInfoBox.m_AvatarSprite:AddUIEvent("click", callback(self, "ShowTips", oInfoBox))
	function oInfoBox.SetData(self, oData)
		oInfoBox.m_Data = oData
		oInfoBox.m_NameLabel:SetText(oData.partnerData.name)
		oInfoBox.m_AmountLabel:SetText(oData.amount)
		oInfoBox.m_AvatarSprite:SpriteAvatar(oData.chipData.icon)
		oInfoBox.m_RareSprite:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(oData.chipData.rare))
		oInfoBox.m_BgSprite:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(oData.chipData.rare))
		oInfoBox.m_DescLabel:SetText(string.format("第1可获得%s个伙伴碎片", oData.amount))
	end
	return oInfoBox
end

function CLimitRankWelfarePartnerPage.ShowTips(self, oInfoBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(oInfoBox.m_Data.chipData.id, {widget = oInfoBox}, nil, {})
end

return CLimitRankWelfarePartnerPage