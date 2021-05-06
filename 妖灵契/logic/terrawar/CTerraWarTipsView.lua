local CTerraWarTipsView = class("CTerraWarTipsView", CViewBase)

function CTerraWarTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/TerraWar/TerraWarTipsView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Black"
	self.m_ItemInfo = nil
	self.m_ExtendClose = true
end

function CTerraWarTipsView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_BgSprite = self:NewUI(2, CSprite)
	self.m_PlayerNameLabel = self:NewUI(4, CLabel)
	self.m_OrgNameLabel = self:NewUI(5, CLabel)
	self.m_ScoreLabel = self:NewUI(6, CLabel)
	self.m_StateLabel = self:NewUI(7, CLabel)
	self.m_HelpLabel = self:NewUI(8, CLabel)
	self.m_AtcakLabel = self:NewUI(9, CLabel)
	self.m_GoToLabel = self:NewUI(10, CLabel)
	self:InitContent()
end

function CTerraWarTipsView.InitContent(self)
	self.m_GoToLabel:AddUIEvent("click", callback(self, "OnGoTo"))
end

function CTerraWarTipsView.OnGoTo(self, obj)
	if g_TerrawarCtrl:IsOpenTerrawar() then
		g_TerrawarCtrl:ClientTerraWarHelp(self.m_ID)
		self:CloseView()
		CTerraWarMainView:CloseView()
		COrgActivityCenterView:CloseView()
		COrgMainView:CloseView()
	else
		g_NotifyCtrl:FlogMsg("据点战尚未开启")
	end
end

function CTerraWarTipsView.SetContent(self, info)
	self.m_ID = info.id
	local playername = info.playername
	if not playername or playername == "" then
		playername = "无"
	end
	self.m_PlayerNameLabel:SetText(playername)
	local orgname = info.orgname
	if not orgname or orgname == "" then
		orgname = "无"
	end
	self.m_OrgNameLabel:SetText(orgname)
	self.m_ScoreLabel:SetText(info.orgscore)
	local s = {
		[0] = "未占领",
		[1] = "战斗中",
		[2] = "保护中",
		[3] = "和平中",
	}
	self.m_StateLabel:SetText(s[info.status])
	self.m_HelpLabel:SetText(string.format("支援（%d/%d）", info.help, info.max_help))
	self.m_AtcakLabel:SetText(string.format("攻击（%d/%d）", info.attack, info.max_attack))
end

function CTerraWarTipsView.ExtendCloseView(self)
	if self.m_ExtendClose == false then
		self.m_ExtendClose = true
		return
	end
	self:CloseView()
end

return CTerraWarTipsView