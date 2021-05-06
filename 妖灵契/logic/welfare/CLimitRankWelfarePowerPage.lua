local CLimitRankWelfarePowerPage = class("CLimitRankWelfarePowerPage", CPageBase)

function CLimitRankWelfarePowerPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CLimitRankWelfarePowerPage.OnInitPage(self)
	self.m_OpenRankBtn = self:NewUI(1, CButton)
	self.m_TimeLabel = self:NewUI(2, CLabel)
	self.m_AwardBox = self:NewUI(3, CBox)
	self.m_WrapContent = self:NewUI(4, CWrapContent)
	
	self:InitContent()
end

function CLimitRankWelfarePowerPage.InitContent(self)
	local sStart = os.date("%Y年%m月%d日", g_WelfareCtrl.m_RankBackStartTime)
	local sEnd = os.date("%Y年%m月%d日%H时", g_WelfareCtrl.m_RankBackEndTime)
	self.m_TimeLabel:SetText(string.format("%s-%s", sStart, sEnd))
	self.m_OpenRankBtn:AddUIEvent("click", callback(self, "OpenRank"))
	self.m_WrapContent:SetCloneChild(self.m_AwardBox, callback(self, "CreateInfoBox"))
	self.m_WrapContent:SetRefreshFunc(function(oBox, dData)
		if dData then
			oBox:SetData(dData)
			oBox:SetActive(true)
		else
			oBox:SetActive(false)
		end
	end)
	self.m_WrapContent:SetData(data.welfaredata.PowerRank, true)
	self.m_AwardBox:SetActive(false)
end

function CLimitRankWelfarePowerPage.OpenRank(self)
	g_RankCtrl:OpenRank(define.Rank.RankId.Power)
end

function CLimitRankWelfarePowerPage.CreateInfoBox(self, oInfoBox)
	oInfoBox.m_DescLabal = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_Grid = oInfoBox:NewUI(2, CGrid)
	oInfoBox.m_ItemTipsBox = oInfoBox:NewUI(3, CItemTipsBox)
	oInfoBox.m_ItemArr = {}
	function oInfoBox.SetData(self, oData)
		oInfoBox.m_DescLabal:SetText(oData.range_desc)
		for i,v in ipairs(oData.reward) do
			if oInfoBox.m_ItemArr[i] == nil then
				oInfoBox.m_ItemArr[i] = oInfoBox.m_ItemTipsBox:Clone()
				oInfoBox.m_Grid:AddChild(oInfoBox.m_ItemArr[i])
			end
			oInfoBox.m_ItemArr[i]:SetActive(true)
			oInfoBox.m_ItemArr[i]:SetSid(v.sid, v.amount, {isLocal = true, uiType = 1})
		end
		for i=#oData.reward + 1, #oInfoBox.m_ItemArr do
			oInfoBox.m_ItemArr[i]:SetActive(false)
		end
		oInfoBox.m_Grid:Reposition()
	end

	return oInfoBox
end

return CLimitRankWelfarePowerPage