local CEqualArenaMainPage = class("CEqualArenaMainPage", CPageBase)

function CEqualArenaMainPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
	self.m_HelpBtn = self:NewUI(1, CButton)
	self.m_MedalInfoLabel = self:NewUI(2, CLabel)
	self.m_RewardBtn = self:NewUI(3, CButton)
	self.m_PointInfoLabel = self:NewUI(4, CLabel)
	self.m_FightBtn = self:NewUI(5, CButton)
	self.m_MedalLabel = self:NewUI(6, CLabel)
	self.m_ExchangeBtn = self:NewUI(7, CButton)
	self.m_ChangePartnerPart = self:NewUI(8, CEqualArenaChangePartnerPart)
	self.m_RankButton = self:NewUI(9, CButton)
	self.m_WatchBtn = self:NewUI(10, CButton)
	self.m_ReplayBtn = self:NewUI(11, CButton)

	self:InitContent()
end

function CEqualArenaMainPage.InitContent(self)
	self.m_TextureCache = {}

	self.m_RewardBtn:AddUIEvent("click", callback(self, "OnClickReward"))
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	self.m_FightBtn:AddUIEvent("click", callback(self, "OnClickFight"))
	self.m_ExchangeBtn:AddUIEvent("click", callback(self, "OnClickExchange"))
	self.m_WatchBtn:AddUIEvent("click", callback(self, "OnClickWatch"))
	self.m_ReplayBtn:AddUIEvent("click", callback(self, "OnClickReplay"))
	self.m_RankButton:AddUIEvent("click", callback(self, "OnClickRank"))

	g_EqualArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotifyMedal"))
end

function CEqualArenaMainPage.OnClickHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp(define.Help.Key.EqualArena)
	end)
end

function CEqualArenaMainPage.OnClickReward(self)
	CEqualRewardView:ShowView()
end

function CEqualArenaMainPage.SetData(self)
	self.m_Point = g_EqualArenaCtrl.m_ArenaPoint
	self.m_CurrentGrade = g_EqualArenaCtrl:GetGradeDataByPoint(self.m_Point)
	self.m_ThisWeekMedal = g_EqualArenaCtrl.m_WeekyMedal
	self.m_CurrentMedal = g_AttrCtrl.arenamedal
	-- self.m_WatchBtn:SetActive(g_EqualArenaCtrl.m_OpenWatch)
	self.m_MedalInfoLabel:SetText(string.format("活动时间：周六~周日 16:00-18:00\n每场获胜可获得%d荣誉\n本月已获得%d/%d荣誉\n选伙伴后，属性公平", self.m_CurrentGrade.award_per_game, self.m_ThisWeekMedal, self.m_CurrentGrade.weeky_limit))
	self.m_PointInfoLabel:SetText(self.m_Point)
	self.m_MedalLabel:SetText(self.m_CurrentMedal)
	self.m_ChangePartnerPart:RefreshGrid()
	-- Utils.AddTimer(function() 
	-- 	self.m_ChangePartnerPart.m_PartnerScroll:HideCardNoEffect()
	-- 	self.m_ChangePartnerPart.m_PartnerScroll:SetType("lineup")
	-- end, 0, 0)
	
end

function CEqualArenaMainPage.OnClickRank(self)
	g_RankCtrl:OpenRank(define.Rank.RankId.EqualArena)
end

function CEqualArenaMainPage.OnClickFight(self)
	g_EqualArenaCtrl:Match()
end

function CEqualArenaMainPage.OnClickExchange(self)
	g_NpcShopCtrl:OpenShop(define.Store.Page.HonorShop)
end

function CEqualArenaMainPage.OnClickWatch(self)
	-- g_NotifyCtrl:FloatMsg("该功能暂未开放")
	if g_EqualArenaCtrl.m_OpenWatch then
		g_EqualArenaCtrl:OpenWatch()
	else
		g_NotifyCtrl:FloatMsg("暂无可观战对战")
	end
end

function CEqualArenaMainPage.OnClickReplay(self)
	-- g_NotifyCtrl:FloatMsg("战斗回放暂缓")
	g_EqualArenaCtrl:GetArenaHistory()
end

function CEqualArenaMainPage.OnNotify(self, oCtrl)
	-- if oCtrl.m_EventID == define.EqualArena.Event.OpenWatchPage then
	-- 	self.m_ParentView:ShowArenaWatchPage()
	-- elseif oCtrl.m_EventID == define.EqualArena.Event.OpenReplay then
	-- 	self.m_ParentView:ShowArenaHistoryPage()
	-- end
end

function CEqualArenaMainPage.OnNotifyMedal(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self.m_MedalLabel:SetText(g_AttrCtrl.arenamedal)
	end
end

return CEqualArenaMainPage
