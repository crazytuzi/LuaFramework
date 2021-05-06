local CTeamPvpRankView = class("CTeamPvpRankView", CViewBase)

function CTeamPvpRankView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Activity/TeamPvp/TeamPvpRankView.prefab", ob)
	-- self.m_GroupName = "WarMain"
end

function CTeamPvpRankView.OnCreateView(self)
	self.m_TimeLabel = self:NewUI(1, CCountDownLabel)
	self.m_HelpBtn = self:NewUI(2, CButton)
	self.m_RankGrid = self:NewUI(3, CGrid)
	self.m_RankBox = self:NewUI(4, CBox)
	self.m_PlayerRankBox = self:NewUI(5, CBox)
	self.m_HideBtn = self:NewUI(6, CButton)
	self.m_FightBtn = self:NewUI(7, CButton)
	self.m_BgSrpite = self:NewUI(8, CSprite)
	self.m_TweenSprite = self:NewUI(9, CSprite)
	self.m_LeaveBtn = self:NewUI(10, CButton)
	self.m_BgTween = self.m_BgSrpite:GetComponent(classtype.TweenHeight)
	self.m_SpriteTween = self.m_TweenSprite:GetComponent(classtype.TweenRotation)
	self:InitContent()
end

function CTeamPvpRankView.InitContent(self)
	if (not g_TeamPvpCtrl.m_IsInTeamPvpScene) or g_WarCtrl:IsWar() then
		self:DelayCall(0, "OnClose")
		return
	end
	self.m_BgHeight = self.m_BgSrpite:GetHeight()
	self.m_PlayerRankBox:SetActive(false)
	self.m_RankBox:SetActive(false)
	self.m_RankBoxArr = {}
	self.m_IsHide = false
	self.m_IsHiding = false
	self.m_FightBtn.m_IgnoreCheckEffect = true
	self.m_FightBtn:AddEffect("fire")
	self.m_LeaveBtn:AddUIEvent("click", callback(self, "OnClickLeave"))
	self.m_FightBtn:AddUIEvent("click", callback(self, "OnClickFight"))
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	self.m_HideBtn:AddUIEvent("click", callback(self, "OnClickHide"))
	g_TeamPvpCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamPvpEvent"))
	self:InitPlayerBox()
	Utils.AddTimer(callback(self, "GetDataFromGS"), 60, 60)
	self.m_TimeLabel:SetText("")
	self.m_TimeLabel:BeginCountDown(g_TeamPvpCtrl:GetEndLeftTime())
	self.m_TimeLabel:SetTickFunc(callback(self, "SetTickFunc"))
	self:SetData()
end

function CTeamPvpRankView.OnClickLeave(self)
	if g_TeamPvpCtrl.m_IsMatching then
		g_NotifyCtrl:FloatMsg("请先停止匹配")
		return
	end
	netarena.C2GSTeamPVPLeaveScene()
end

function CTeamPvpRankView.SetTickFunc(self, iValue)
	local iStart = g_TeamPvpCtrl:GetStartLeftTime()
	if iStart > 0 then
		self.m_TimeLabel:SetText(string.format("开启时间：%s", g_TimeCtrl:GetLeftTime(iStart)))
	else
		self.m_TimeLabel:SetText(string.format("剩余时间：%s", g_TimeCtrl:GetLeftTime(iValue)))
	end
end

function CTeamPvpRankView.OnShowView(self)
	if (not g_TeamPvpCtrl.m_IsInTeamPvpScene) or g_WarCtrl:IsWar() then
		self:DelayCall(0, "OnClose")
	end
end

function CTeamPvpRankView.OnTimeUp(self)
	self.m_TimeLabel:SetText("活动结束")
end

function CTeamPvpRankView.GetDataFromGS(self)
	netarena.C2GSOpenTeamPVPRank()
	return true
end

function CTeamPvpRankView.InitPlayerBox(self)
	local oPlayerBox = self.m_PlayerRankBox
	oPlayerBox.m_RankLabel = oPlayerBox:NewUI(1, CLabel)
	oPlayerBox.m_PointLabel = oPlayerBox:NewUI(2, CLabel)
	oPlayerBox.m_ResultLabel = oPlayerBox:NewUI(3, CLabel)
end

function CTeamPvpRankView.SetPlayerData(self)
	self.m_PlayerRankBox:SetActive(true)
	local rankData = g_TeamPvpCtrl:GetOwnRandData()
	if rankData.rank == 0 then
		self.m_PlayerRankBox.m_RankLabel:SetText("榜外")
	else
		self.m_PlayerRankBox.m_RankLabel:SetText(rankData.rank)
	end
	self.m_PlayerRankBox.m_PointLabel:SetText(string.format("%s", rankData.score))
	self.m_PlayerRankBox.m_ResultLabel:SetText(string.format("[04ff98]%s胜[ff5050]%s负", rankData.win, rankData.fail))
end

function CTeamPvpRankView.OnTeamPvpEvent(self, oCtrl)
	if oCtrl.m_EventID == define.TeamPvp.Event.UpdateRankData then
		self:SetData()
	elseif oCtrl.m_EventID == define.TeamPvp.Event.LeaveScene then
		self:OnClose()
	end
end

function CTeamPvpRankView.SetData(self)
	local rankData = g_TeamPvpCtrl:GetRandData()
	for i,v in ipairs(rankData) do
		if self.m_RankBoxArr[i] == nil then
			self.m_RankBoxArr[i] = self:CreateRankBox()
			self.m_RankGrid:AddChild(self.m_RankBoxArr[i])
		end
		self.m_RankBoxArr[i]:SetData(v)
		self.m_RankBoxArr[i]:SetActive(true)
	end

	for i= #rankData + 1, #self.m_RankBoxArr do
		self.m_RankBoxArr[i]:SetActive(false)
	end
	self:SetPlayerData()
end

function CTeamPvpRankView.CreateRankBox(self)
	local oRankBox = self.m_RankBox:Clone()
	oRankBox.m_RankLabel = oRankBox:NewUI(1, CLabel)
	oRankBox.m_NameLabel = oRankBox:NewUI(2, CLabel)
	oRankBox.m_PointLabel = oRankBox:NewUI(3, CLabel)
	oRankBox.m_ResultLabel = oRankBox:NewUI(4, CLabel)

	function oRankBox.SetData(self, oData)
		oRankBox.m_RankLabel:SetText(oData.rank)
		oRankBox.m_NameLabel:SetText(oData.name)
		oRankBox.m_PointLabel:SetText(string.format("积分：%s", oData.score))
		oRankBox.m_ResultLabel:SetText(string.format("胜场：%s", oData.win))
	end

	return oRankBox
end

function CTeamPvpRankView.OnClickFight(self)
	if g_TeamPvpCtrl.m_IsMatching then
		g_NotifyCtrl:FloatMsg("正在匹配")
	elseif g_TeamPvpCtrl:GetMemberSize() > 1 and not g_TeamPvpCtrl:IsLeader(g_AttrCtrl.pid) then
		g_NotifyCtrl:FloatMsg("请让队长来进行匹配")
	else
		netarena.C2GSTeamPVPMatch()
	end
end

function CTeamPvpRankView.OnClickHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("teampvp_rank")
	end)
end

function CTeamPvpRankView.OnClickHide(self)
	if self.m_IsHiding then
		return
	end
	self.m_IsHiding = true
	Utils.AddTimer(callback(self, "AfterTween"), 0.3, 0.3)
	self.m_BgTween:Toggle()
	self.m_SpriteTween:Toggle()
end

function CTeamPvpRankView.AfterTween(self)
	self.m_IsHiding = false
end

return CTeamPvpRankView
