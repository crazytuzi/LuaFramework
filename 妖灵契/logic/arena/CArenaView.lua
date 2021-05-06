local CArenaView = class("CArenaView", CViewBase)

function CArenaView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Arena/ArenaView.prefab", ob)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	-- self.m_OpenEffect = "Scale"
end

function CArenaView.OnCreateView(self)
	self.m_ArenaMainPage = self:NewPage(1, CArenaMainPage)
	self.m_EqualArenaPage = self:NewPage(2, CEqualArenaMainPage)
	self.m_MatchPart = self:NewUI(3, CArenaMatchPart)
	self.m_BtnGrid = self:NewUI(4, CGrid)
	self.m_BtnBox = self:NewUI(5, CBox)
	self.m_CloseBtn = self:NewUI(6, CButton)
	self.m_TeamPvpPage = self:NewPage(7, CTeamPvpPage)
	self.m_Container = self:NewUI(8, CWidget)
	self.m_ClubArenaPage = self:NewPage(9, CClubArenaPage)
	g_GuideCtrl:AddGuideUI("clubarnea_club_page", self.m_ClubArenaPage)	
	self:InitContent()
end

function CArenaView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container, 4, 4)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_ArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnArenaNotify"))
	g_EqualArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEqualArenaNotify"))
	g_ClubArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnClubArenaNotify"))
	self.m_InitRecord = {}
	self.m_MatchPart:SetActive(false)
	self:InitBtn()
end

function CArenaView.InitBtn(self)
	local btnData = {
		[1]={name = "武馆比武场", cb = callback(self, "OpenClubArenaPage"), isopen = callback(g_ClubArenaCtrl, "IsOpen")},
		[2]={name = "段位比武场", cb = callback(self, "OpenArenaPage")},
		[3]={name = "协同比武场", cb = callback(self, "OpenTeamPvpPage")},
		[4]={name = "公平比武场", cb = callback(self, "OpenEqualArenaPage")},
	}
	self.m_BtnArr = {}
	for i,v in ipairs(btnData) do
		local oBtnBox = self:CreateBtn()
		self.m_BtnArr[i] = oBtnBox
		oBtnBox:SetData(v)
		oBtnBox:SetSelect(false)
		if v.isopen then
			oBtnBox:SetActive(v.isopen())
		end
	end
	self.m_BtnBox:SetActive(false)
end

function CArenaView.CreateBtn(self)
	local oBtnBox = self.m_BtnBox:Clone()
	oBtnBox.m_OnSelectSprite = oBtnBox:NewUI(1, CSprite)
	oBtnBox.m_Label = oBtnBox:NewUI(2, CLabel)
	oBtnBox.m_SelectLabel = oBtnBox:NewUI(3, CLabel)
	oBtnBox.m_OnClickCb = nil
	self.m_BtnGrid:AddChild(oBtnBox)
	oBtnBox:AddUIEvent("click", callback(self, "OnClickBtn"))

	function oBtnBox.SetData(self, oData)
		oBtnBox.m_Label:SetText(oData.name)
		oBtnBox.m_SelectLabel:SetText(oData.name)
		oBtnBox.m_OnClickCb = oData.cb
	end

	function oBtnBox.SetSelect(self, bValue)
		oBtnBox.m_Label:SetActive(not bValue)
		oBtnBox.m_OnSelectSprite:SetActive(bValue)
	end

	return oBtnBox
end

function CArenaView.OnClickBtn(self, oBtnBox)
	if oBtnBox.m_OnClickCb then
		oBtnBox.m_OnClickCb()
	end
end

function CArenaView.SelectBtn(self, oBtnBox)
	if self.m_CurrentBtn then
		self.m_CurrentBtn:SetSelect(false)
	end
	self.m_CurrentBtn = oBtnBox
	self.m_CurrentBtn:SetSelect(true)
end

function CArenaView.ShowArenaPage(self)
	self:SelectBtn(self.m_BtnArr[2])
	self:ShowSubPage(self.m_ArenaMainPage)
	self.m_ArenaMainPage:SetData()
end

function CArenaView.ShowEqualArenaPage(self)
	self:SelectBtn(self.m_BtnArr[4])
	self:ShowSubPage(self.m_EqualArenaPage)
	self.m_EqualArenaPage:SetData()
end

function CArenaView.OpenArenaPage(self)
	g_ArenaCtrl:ShowArena()
end

function CArenaView.OpenEqualArenaPage(self)
	g_EqualArenaCtrl:ShowArena()
end

function CArenaView.OpenTeamPvpPage(self)
	self:SelectBtn(self.m_BtnArr[3])
	self:ShowSubPage(self.m_TeamPvpPage)
end

function CArenaView.OpenClubArenaPage(self)
	g_ClubArenaCtrl:ShowArena()
end

function CArenaView.ShowArenaRankDetailPage(self)
	-- g_RankCtrl:OpenRank(define.Rank.RankId.Arena)
end

function CArenaView.ShowArenaWatchPage(self)
	-- self:ShowSubPage(self.m_ArenaWatchPage)
	-- self.m_ArenaWatchPage:SetData()
end

function CArenaView.OnArenaNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Arena.Event.ReceiveMatchResult then
		if oCtrl.m_EventData == define.Arena.MatchResult.Success then
			self.m_MatchPart:ShowMatching(true)
		else
			self.m_MatchPart:SetActive(false)
		end
	elseif oCtrl.m_EventID == define.Arena.Event.ReceiveMatchPlayer then
		self.m_MatchPart:ShowResult(oCtrl.m_EventData)
	end
end

function CArenaView.OnEqualArenaNotify(self, oCtrl)
	if oCtrl.m_EventID == define.EqualArena.Event.ReceiveMatchResult then
		if oCtrl.m_EventData == define.EqualArena.MatchResult.Success then
			self.m_MatchPart:ShowMatching(false)
		else
			self.m_MatchPart:SetActive(false)
		end
	elseif oCtrl.m_EventID == define.EqualArena.Event.ReceiveMatchPlayer then
		self.m_MatchPart:ShowResult(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.EqualArena.Event.OnSelectSection then
		self.m_MatchPart:SetActive(false)
	end
end

function CArenaView.OnClubArenaNotify(self, oCtrl)
	if oCtrl.m_EventID == define.ClubArena.Event.Show then
		self:SelectBtn(self.m_BtnArr[1])
		self:ShowSubPage(self.m_ClubArenaPage)
	end
end

return CArenaView
