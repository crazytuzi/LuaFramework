local CCostSavePage = class("CCostSavePage", CPageBase)

function CCostSavePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CCostSavePage.OnInitPage(self)
	self.m_GetBox = self:NewUI(1, CBox)
	self.m_SaveTimeLabel = self:NewUI(2, CLabel)
	self.m_AniSpr1 = self:NewUI(3, CSprite)
	self.m_GetTimeLabel = self:NewUI(4, CLabel)
	self.m_PercentLabel = self:NewUI(5, CLabel)
	self.m_GoldLabel = self:NewUI(6, CLabel)
	self.m_AniSpr2 = self:NewUI(7, CSprite)
	self.m_HelpLabel1 = self:NewUI(8, CLabel)
	self.m_HelpLabel2 = self:NewUI(9, CLabel)
	self.m_GetBox:AddUIEvent("click", callback(self, "OnGetPackage"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvnet"))
end

function CCostSavePage.OnGetPackage(self)
	nethuodong.C2GSGetResumeRestoreReward()
end

function CCostSavePage.ShowPage(self)
	CPageBase.ShowPage(self)
	self:SetData()
end

function CCostSavePage.SetData(self)
	local sSaveTime = g_WelfareCtrl.m_CostSaveStartTime or 0
	local eSaveTime = g_WelfareCtrl.m_CostSaveEndTime or 0
	-- local helpTips1 = "1111"
	-- local helpTips2 = "2222"
	local gold = g_WelfareCtrl.m_CostSaveGold
	local percent = 0
	local t = data.globaldata.GLOBAL.resume_restore_ratio.value
	if t and t ~= "" then
		local ratio = string.safesplit(t, ",")
		if ratio and ratio[g_WelfareCtrl.m_CostSavePlanId] then
			percent = tonumber(ratio[g_WelfareCtrl.m_CostSavePlanId])
		end 
	end
	self.m_GetStatus = g_WelfareCtrl.m_CostSaveGetStatue
	self.m_AniSpr1:SetActive(g_WelfareCtrl:IsCostSaveRedDot())
	self.m_AniSpr2:SetActive(not g_WelfareCtrl:IsCostSaveRedDot())
	self.m_SaveTimeLabel:SetText(string.format("红包收纳时间：%s-%s", g_TimeCtrl:GetDayByTimeS(sSaveTime), g_TimeCtrl:GetDayByTimeS(eSaveTime - 3600 * 24 * 2, false)))
	self.m_GetTimeLabel:SetText(string.format("红包领取时间：%s", g_TimeCtrl:GetDayByTimeS(eSaveTime - 3600 * 24 )))
	self.m_GoldLabel:SetText(string.format("#w2%d", gold * percent ))
	self.m_PercentLabel:SetText(string.format("%d%%", percent * 100))
	-- self.m_HelpLabel1:SetText(helpTips1)
	-- self.m_HelpLabel2:SetText(helpTips2)
end

function CCostSavePage.OnWelfareEvnet(self)
	self:SetData()
end

return CCostSavePage