local CClubArenaCtrl = class("CClubArenaCtrl", CCtrlBase)

define.ClubArena = {
	Event = {
		Show = 1,
		Club = 2,
		AddTime = 3,
		DefenseLineUp = 4,
	},
	WarResult = {
		Win = 1,
		Fail = 2,
		NotReceive = 3,
	},
}

function CClubArenaCtrl.ctor(self, ob)
	CCtrlBase.ctor(self, ob)
	
	self:ResetCtrl()
end

function CClubArenaCtrl.ResetCtrl(self)
	self.m_CurClub = 1
	self.m_CDFight = nil
	self.m_CoinReward = 0
	self.m_GoldReward = 0
	self.m_ClubInfo = {}
	self.m_HistoryInfo = {}
	self.m_DefenseLineUp = {}
	self.m_ViewSide = 0
	self.m_ResultData = nil
end

function CClubArenaCtrl.IsOpen(self)
	return data.globalcontroldata.GLOBAL_CONTROL.clubarena.is_open == "y" and 
	g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.clubarena.open_grade
end

function CClubArenaCtrl.ShowArena(self)
	netarena.C2GSOpenClubArenaMain()
end

function CClubArenaCtrl.OnShowArena(self, iClub, cd_fight, coin_reward, gold_reward, max_times, use_times, master)
	self.m_CurClub = iClub
	self.m_CDFight = cd_fight
	self.m_CoinReward = coin_reward
	self.m_GoldReward = gold_reward
	self.m_Maxtimes = max_times
	self.m_UseTimes = use_times
	self.m_Masters = master
	local oView = CArenaView:GetView()
	if oView then
		self:OnEvent(define.ClubArena.Event.Show)
	else
		CArenaView:ShowView(function (oView)
			self:OnEvent(define.ClubArena.Event.Show)
		end)
	end
end

function CClubArenaCtrl.IsMaster(self)
	for i,v in ipairs(self.m_Masters) do
		if v == g_AttrCtrl.name then
			return true, i+1
		end
	end	
	return false, false
end

function CClubArenaCtrl.GetCurClub(self)
	return self.m_CurClub
end

function CClubArenaCtrl.GetClubArenaInfo(self, iClub)
	return self.m_ClubInfo[iClub]
end

function CClubArenaCtrl.RequestClubArenaInfo(self, iClub)
	netarena.C2GSOpenClubArenaInfo(iClub)
end

function CClubArenaCtrl.ReceiveClubArenaInfo(self, club, power, enemy, master, win)
	self.m_ClubInfo[club] = {
		club = club,
		power = power,
		enemy = enemy,
		master = master,
		win = win,
	}
	self:OnEvent(define.ClubArena.Event.Club)
end

function CClubArenaCtrl.GetDefenseLineUp(self)
	return self.m_DefenseLineUp
end

function CClubArenaCtrl.ReceiveDefenseLineUp(self, parlist)
	self.m_DefenseLineUp = parlist
	self:OnEvent(define.ClubArena.Event.DefenseLineUp)
end

--打开回放记录界面
function CClubArenaCtrl.GetArenaHistory(self)
	netarena.C2GSShowClubArenaHistory()
end

function CClubArenaCtrl.OnReceiveArenaHistory(self, historyInfo)
	self.m_HistoryInfo = historyInfo
	CClubArenaHistoryView:ShowView()
end

function CClubArenaCtrl.ShowWarStartView(self, infoList)
	--结算用缓存
	local oPlayerInfo = nil
	local oEnemyInfo = nil
	if (self.m_ViewSide ~= 0 and infoList[2].camp == self.m_ViewSide) 
		or (infoList[2].pid == g_AttrCtrl.pid) then
		oPlayerInfo = infoList[2]
		oEnemyInfo = infoList[1]
	else
		oPlayerInfo = infoList[1]
		oEnemyInfo = infoList[2]
	end
	
	self.m_PlayerInfo = self:CopyStartInfo(oPlayerInfo)
	self.m_EnemyInfo = self:CopyStartInfo(oEnemyInfo)
	CArenaWarStartView:ShowView(function (oView)
		oView:SetData({oPlayerInfo, oEnemyInfo})
	end)
end

function CClubArenaCtrl.CopyStartInfo(self, oInfo)
	local dInfo = {
		name = oInfo.name,
		shape = oInfo.shape,
		pid = oInfo.pid,
	}
	return dInfo
end

function CClubArenaCtrl.OnReceiveFightResult(self, medal, result, info1, info2)
	self.m_ResultData = {
		medal = medal,
		result = result,
		info1 = info1,
		info2 = info2,
	}
	if CClubArenaWarResultView:GetView() == nil then
		self:OnEvent(define.EqualArena.Event.OnWarEnd, self.m_ResultData)
	else
		CClubArenaWarResultView:ShowView(function (oView)
			oView:SetData(medal, result, info1, info2)
		end)		
	end
end

function CClubArenaCtrl.ShowWarResult(self, oCmd)
	if CClubArenaWarResultView:GetView() == nil then
		CClubArenaWarResultView:ShowView(function (oView)
			if self.m_ResultData then
				oView:SetData(
					self.m_ResultData.medal, 
					self.m_ResultData.result, 
					self.m_ResultData.info1, 
					self.m_ResultData.info2)
			end
		end)	
	end
end

return CClubArenaCtrl