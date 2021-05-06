local CTeamPvpCtrl = class("CTeamPvpCtrl", CCtrlBase)

function CTeamPvpCtrl.ctor(self, ob)
	CCtrlBase.ctor(self, ob)
	
	self:ResetCtrl()
end

function CTeamPvpCtrl.ResetCtrl(self)
	self.m_ResultPoint = 0
	self.m_TeamResultInfo = {}
	self.m_OtherResultInfo = {}
	self.m_RankData = {}
	self.m_OwnRankData = {}
	self.m_TeamData = {}
	self.m_InviteData = {}
	self.m_LeftTime = 0
	self.m_ViewSide = 0
	self.m_ArenaPoint = 0
	self.m_StartTime = 0
	self.m_EndTime = 0
	self.m_IsMatching = false
	if self.m_IsInTeamPvpScene then
		self.m_IsInTeamPvpScene = false
		self:OnEvent(define.TeamPvp.Event.LeaveScene)
	end
	self.m_Result = define.TeamPvp.WarResult.NotReceive
end

function CTeamPvpCtrl.RefreshLeftTime(self, iStartTime, iEndTime)
	self.m_StartTime = iStartTime
	self.m_EndTime = iEndTime
	self:OnEvent(define.TeamPvp.Event.OnRrefshLeftTime)
end

function CTeamPvpCtrl.GetStartLeftTime(self)
	return self.m_StartTime - g_TimeCtrl:GetTimeS()
end

function CTeamPvpCtrl.GetEndLeftTime(self)
	return self.m_EndTime - g_TimeCtrl:GetTimeS()
end

function CTeamPvpCtrl.IsInTeamPvpScene(self)
	return self.m_IsInTeamPvpScene
end

function CTeamPvpCtrl.LeaveScene(self)
	self.m_IsInTeamPvpScene = false
	self.m_IsMatching = false
	local lView = {"CTeamPvpInviteView", "CTeamPvpMatchingView", "CTeamPvpMatchResultView", "CTeamPvpRankView"}
	for i,v in ipairs(lView) do
		local oViewScript = _G[v]
		local oView = oViewScript:GetView()
		if oViewScript and oView then
			oView:OnClose()
		end
	end
	self:OnEvent(define.TeamPvp.Event.LeaveScene)
end

function CTeamPvpCtrl.UpdataTeamData(self, oData)
	-- printc("InTeamPvpScene")
	self.m_TeamData = oData
	if not self.m_IsInTeamPvpScene and not g_WarCtrl:IsWar() then
		CTeamPvpRankView:ShowView()
	end
	self.m_IsInTeamPvpScene = true
	self:OnEvent(define.TeamPvp.Event.UpdataTeamData)
end

function CTeamPvpCtrl.GetTeamData(self)
	return self.m_TeamData
end

function CTeamPvpCtrl.GetInviteList(self)
	if self.m_IsMatching then
		g_NotifyCtrl:FloatMsg("请先停止匹配")
		return
	end
	netarena.C2GSGetTeamPVPInviteList({})
end

function CTeamPvpCtrl.OnReveiceInviteList(self, dList)
	self.m_InviteData = {}
	for i,v in ipairs(dList) do
		self.m_InviteData[i] = v
	end
	local oView = CTeamPvpInviteView:GetView()
	if oView then
		oView:Refresh()
	else
		CTeamPvpInviteView:ShowView()
	end
end

function CTeamPvpCtrl.GetInviteData(self)
	return self.m_InviteData
end

function CTeamPvpCtrl.SendInvite(self, inviteList)
	-- printc("SendInvite")
	-- table.print(inviteList)
	netarena.C2GSTeamPVPToInviteList(inviteList)
end

function CTeamPvpCtrl.UpdataRankData(self, oData, ownRankData)
	self.m_RankData = oData
	self.m_OwnRankData = ownRankData
	self:OnEvent(define.TeamPvp.Event.UpdateRankData)
end

function CTeamPvpCtrl.GetRandData(self)
	return self.m_RankData
end

function CTeamPvpCtrl.GetOwnRandData(self)
	return self.m_OwnRankData
end

function CTeamPvpCtrl.OnReceiveStartMatch(self, result, startTime)
	if result == 1 then
		self.m_IsMatching = true
		self.m_Result = define.TeamPvp.WarResult.NotReceive
		if CTeamPvpWarResultView:GetView() then
			CTeamPvpWarResultView:OnClose()
			CTeamPvpRankView:SetShowCB(function (oView)
				if g_TeamPvpCtrl.m_IsMatching then
					CTeamPvpMatchingView:ShowView()
				end
				CTeamPvpRankView:ClearShowCB()
			end)
		else
			CTeamPvpMatchingView:ShowView()
		end
	else
		self.m_IsMatching = false
		local oView = CTeamPvpMatchingView:GetView()
		if oView then
			oView:OnClose()
		end
	end
end

function CTeamPvpCtrl.OnReceiveMatchInfo(self, matchInfo1, matchInfo2)
	self.m_IsMatching = false
	self.m_OwnTeamMatchInfo = matchInfo2
	self.m_OtherTeamMatchInfo = matchInfo1
	for k,v in pairs(matchInfo1) do
		if v.pid == g_AttrCtrl.pid then
			self.m_OwnTeamMatchInfo = matchInfo1
			self.m_OtherTeamMatchInfo = matchInfo2
		end
	end
	CTeamPvpMatchResultView:ShowView()
	local oView = CTeamPvpMatchingView:GetView()
	if oView then
		oView:OnClose()
	end
end

function CTeamPvpCtrl.GetOwnTeamMatchInfo(self)
	return self.m_OwnTeamMatchInfo
end

function CTeamPvpCtrl.GetOtherTeamMatchInfo(self)
	return self.m_OtherTeamMatchInfo
end

function CTeamPvpCtrl.ShowWarResult(self)
	if CTeamPvpWarResultView:GetView() == nil then
		CTeamPvpWarResultView:ShowView()
	end
end

function CTeamPvpCtrl.ShowWarStartView(self, infoList1, infoList2)
	self.m_IsMatching = false
	local ownInfo = infoList2
	local otherInfo = infoList1
	for k,v in pairs(infoList1) do
		if v.pid == g_AttrCtrl.pid then
			ownInfo = infoList1
			otherInfo = infoList2
		end
	end
	self.m_OwnTeamInfo = self:DecodeTeamInfo(ownInfo)
	self.m_OtherTeamInfo = self:DecodeTeamInfo(otherInfo)
	CTeamPvpWarStartView:ShowView()
end

--1队长 2 队员
function CTeamPvpCtrl.DecodeTeamInfo(self, oInfo)
	local oList = {}
	for k,v in pairs(oInfo) do
		table.insert(oList, v)
	end
	local function sortFunc(v1, v2)
		return v1.leader == 1
	end
	table.sort(oList, sortFunc)
	return oList
end

function CTeamPvpCtrl.GetOwnTeamInfo(self)
	return self.m_OwnTeamInfo
end

function CTeamPvpCtrl.GetOtherTeamInfo(self)
	return self.m_OtherTeamInfo
end

function CTeamPvpCtrl.OnReceiveFightResult(self, point, result, currentpoint, infoList1, infoList2)
	self.m_ArenaPoint = currentpoint
	self.m_ResultPoint = point
	self.m_TeamResultInfo = infoList2
	self.m_OtherResultInfo = infoList1
	local needExchange = false
	for k,v in pairs(infoList1) do
		if self.m_ViewSide ~= 0 and v.camp == self.m_ViewSide or v.pid == g_AttrCtrl.pid then
			needExchange = true
		end
	end
	if needExchange then
		self.m_TeamResultInfo = infoList1
		self.m_OtherResultInfo = infoList2
	end
	self.m_TeamResultInfo = self:DecodeTeamInfo(self.m_TeamResultInfo)
	self.m_OtherResultInfo = self:DecodeTeamInfo(self.m_OtherResultInfo)
	if self.m_TeamResultInfo[1].camp == result then
		self.m_Result = define.TeamPvp.WarResult.Win
	else
		self.m_Result = define.TeamPvp.WarResult.Fail
	end

	self:OnEvent(define.TeamPvp.Event.OnWarEnd)
end

function CTeamPvpCtrl.GetOwnResultInfo(self)
	return self.m_TeamResultInfo
end

function CTeamPvpCtrl.GetOtherResultInfo(self)
	return self.m_OtherResultInfo
end

function CTeamPvpCtrl.ShowArena(self)
	CArenaView:ShowView(function (oView)
		oView:OpenTeamPvpPage()
	end)
	
end

function CTeamPvpCtrl.GetMemberSize(self)
	return table.count(self.m_TeamData)
end

function CTeamPvpCtrl.IsLeader(self, pid)
	for k,v in pairs(self.m_TeamData) do
		if v.leader == 1 and v.pid == pid then
			return true
		end
	end
	return false
end


return CTeamPvpCtrl