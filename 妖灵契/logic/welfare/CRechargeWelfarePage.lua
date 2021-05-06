local CRechargeWelfarePage = class("CRechargeWelfarePage", CPageBase)

function CRechargeWelfarePage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CRechargeWelfarePage.OnInitPage(self)
	self.m_RechargeLabel = self:NewUI(1, CLabel)
	self.m_BackLabel = self:NewUI(2, CLabel)
	self.m_PrivilegeLabel = self:NewUI(3, CLabel)
	self.m_GiftLabel = self:NewUI(4, CLabel)
	self:InitContent()
end

function CRechargeWelfarePage.InitContent(self)
	local iCost = g_WelfareCtrl.m_RechargeWelfareRMB
	local iGiveBack = iCost * 20
	self.m_RechargeLabel:SetText(string.format("%s元", iCost))
	self.m_BackLabel:SetText(string.format("%s#w2", (g_WelfareCtrl.m_RechargeWelfareRMBGold or 0)))
	local sList = {}
	if g_WelfareCtrl.m_RechargeWelfareYueKaCnt > 0 then
		table.insert(sList, string.format("月卡（%s）", g_WelfareCtrl.m_RechargeWelfareYueKaCnt))
	end
	if g_WelfareCtrl.m_HasRechargeWelfareZSK then
		table.insert(sList, "终身卡")
	end
	if g_WelfareCtrl.m_HasRechargeWelfareCZJJ then
		table.insert(sList, "成长基金")
	end
	self.m_PrivilegeLabel:SetText(self:GetString(sList))

	local sGift = {}
	if g_WelfareCtrl.m_HasRechargeWelfareGradeGift then
		table.insert(sGift, "限时礼包")
	end
	if g_WelfareCtrl.m_HasRechargeWelfareOneRMB then
		table.insert(sGift, "1元礼包")
	end
	if g_WelfareCtrl.m_HasRechargeWelfareSpecial then
		table.insert(sGift, "每日特权礼包")
	end
	self.m_GiftLabel:SetText(self:GetString(sGift))
end

function CRechargeWelfarePage.GetString(self, sList)
	local sText
	for i,v in ipairs(sList) do
		if sText then
			sText = string.format("%s、%s", sText, v)
		else
			sText = v
		end
	end
	return sText or "无"
end

return CRechargeWelfarePage