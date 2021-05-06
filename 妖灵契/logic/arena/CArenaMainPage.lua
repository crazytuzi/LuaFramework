local CArenaMainPage = class("CArenaMainPage", CPageBase)

function CArenaMainPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CArenaMainPage.OnInitPage(self)
	self.m_RewardBtn = self:NewUI(1, CButton)
	self.m_MedalInfoLabel = self:NewUI(2, CLabel)
	self.m_GradeSprite = self:NewUI(3, CSprite)
	self.m_PointInfoLabel = self:NewUI(4, CLabel)
	self.m_FightBtn = self:NewUI(5, CButton)
	self.m_MedalLabel = self:NewUI(6, CLabel)
	self.m_ExchangeBtn = self:NewUI(7, CButton)
	self.m_BgTexture = self:NewUI(8, CTexture)
	self.m_RankButton = self:NewUI(9, CButton)
	self.m_WatchBtn = self:NewUI(10, CButton)
	self.m_ReplayBtn = self:NewUI(11, CButton)
	self.m_HelpBtn = self:NewUI(12, CButton)

	self:InitContent()
end

function CArenaMainPage.InitContent(self)
	self.m_TextureCache = {}
	self.m_RewardBtn:AddUIEvent("click", callback(self, "OnClickReward"))
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	self.m_FightBtn:AddUIEvent("click", callback(self, "OnClickFight"))
	self.m_ExchangeBtn:AddUIEvent("click", callback(self, "OnClickExchange"))
	self.m_WatchBtn:AddUIEvent("click", callback(self, "OnClickWatch"))
	self.m_ReplayBtn:AddUIEvent("click", callback(self, "OnClickReplay"))

	self.m_RankButton:AddUIEvent("click", callback(self, "OnClickRank"))

	g_ArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotifyMedal"))
	g_GuideCtrl:AddGuideUI("arena_help_btn", self.m_RewardBtn)
	g_GuideCtrl:AddGuideUI("arena_fight_btn", self.m_FightBtn)
end

function CArenaMainPage.OnClickHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp(define.Help.Key.Arena)
	end)
end

function CArenaMainPage.OnClickReward(self)
	CArenaIntroductView:ShowView()
end

function CArenaMainPage.SetData(self)
	self.m_Point = g_ArenaCtrl.m_ArenaPoint
	self.m_CurrentGrade = g_ArenaCtrl:GetGradeDataByPoint(self.m_Point)
	self.m_ThisWeekMedal = g_ArenaCtrl.m_WeekyMedal
	self.m_CurrentMedal = g_AttrCtrl.arenamedal
	-- self.m_WatchBtn:SetActive(g_ArenaCtrl.m_OpenWatch)
	self.m_MedalInfoLabel:SetText(string.format("活动时间：周一~周五 21:00-22:00\n每场获胜可获得%d荣誉\n本周已获得%d/%d荣誉", self.m_CurrentGrade.award_per_game, self.m_ThisWeekMedal, self.m_CurrentGrade.weeky_limit))
	self.m_GradeSprite:SetSpriteName(string.format("text_duan_%s", self.m_CurrentGrade.id))
	self.m_PointInfoLabel:SetText(self.m_Point)
	self.m_MedalLabel:SetText(self.m_CurrentMedal)
end

function CArenaMainPage.OnClickRank(self)
	g_RankCtrl:OpenRank(define.Rank.RankId.Arena)
end

function CArenaMainPage.OnClickFight(self)
	if g_GuideCtrl:IsInTargetGuide("Arena") then
		netarena.C2GSGuaidArenaWar()
	else
		g_ArenaCtrl:Match()	
	end	
end

function CArenaMainPage.OnClickExchange(self)
	g_NpcShopCtrl:OpenShop(define.Store.Page.HonorShop)
end

function CArenaMainPage.OnClickWatch(self)
	if g_ArenaCtrl.m_OpenWatch then
		g_ArenaCtrl:OpenWatch()
	else
		g_NotifyCtrl:FloatMsg("暂无可观战对战")
	end
end

function CArenaMainPage.OnClickReplay(self)
	g_ArenaCtrl:GetArenaHistory()
end

function CArenaMainPage.OnNotify(self, oCtrl)

end

function CArenaMainPage.OnNotifyMedal(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self.m_MedalLabel:SetText(g_AttrCtrl.arenamedal)
	end
end

return CArenaMainPage
