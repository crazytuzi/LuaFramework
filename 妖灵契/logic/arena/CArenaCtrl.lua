local CArenaCtrl = class("CArenaCtrl", CCtrlBase)

function CArenaCtrl.ctor(self, ob)
	CCtrlBase.ctor(self, ob)
	self.m_TimeStr = {
		{value = 1, desc = "秒前"},
		{value = 60, desc = "分钟前"},
		{value = 60, desc = "小时前"},
		{value = 24, desc = "天前"},
		{value = 30, desc = "月前"},
		{value = 999, desc = "年前"},
	}
	self:ResetCtrl()
end

function CArenaCtrl.ResetCtrl(self)
	self.m_ArenaPoint = 0
	self.m_WeekyMedal = 0
	self.m_ResultPoint = 0
	self.m_ResultMedal = 0
	self.m_Result = define.Arena.WarResult.NotReceive
	self.m_Rank = 999
	self.m_LeftTime = 0
	self.m_EnemyInfo = {}
	self.m_PlayerInfo = {}
	self.m_ViewSide = 0
end

function CArenaCtrl.GetGradeDataByPoint(self, point)
	for i,v in ipairs(data.arenadata.SortId) do
		if point >= data.arenadata.DATA[v].basescore then
			return data.arenadata.DATA[v]
		end
	end
	return data.arenadata.DATA[data.arenadata.SortId[#data.arenadata.SortId]]
end

function CArenaCtrl.GetSortIds(self)
	return data.arenadata.SortId
end

function CArenaCtrl.GetArenaGradeData(self, id)
	return data.arenadata.DATA[id]
end

function CArenaCtrl.ShowArena(self)
	netarena.C2GSOpenArena()
end

function CArenaCtrl.OnShowArena(self, point, weekyMedal, rankInfo, playerRank, openWatch)
	self.m_ArenaPoint = point
	self.m_WeekyMedal = weekyMedal
	self.m_RankInfo = {}
	for k,v in pairs(rankInfo) do
		self.m_RankInfo[k] = v
	end
	self.m_Rank = playerRank
	self.m_OpenWatch = openWatch
	-- CArenaView:ShowView(function (oView)
	-- 	oView:ShowArenaMainPage()
	-- end)
	local oView = CArenaView:GetView()
	if oView then
		oView:ShowArenaPage()
	else
		CArenaView:ShowView(function (oView)
			oView:ShowArenaPage()
		end)
	end
end

function CArenaCtrl.Match(self)
	if g_TeamCtrl:GetMemberSize() > 1 then
		g_NotifyCtrl:FloatMsg("组队状态下禁止匹配")
	else
		self.m_Result = define.Arena.WarResult.NotReceive
		netarena.C2GSArenaMatch()
	end
end

--匹配操作反馈
function CArenaCtrl.OnReceiveMatchResult(self, result)
	self:OnEvent(define.Arena.Event.ReceiveMatchResult, result)
end

--匹配成功对手信息
function CArenaCtrl.OnReceiveMatchPlayer(self, data)
	self.m_EnemyInfo = data
	self:OnEvent(define.Arena.Event.ReceiveMatchPlayer, data)
end

--获取观战数据
function CArenaCtrl.OpenWatch(self)
	netarena.C2GSArenaOpenWatch()
end

--打开观战界面
function CArenaCtrl.OnReceiveWatch(self, data)
	self.m_WatchInfo = {}
	for k,v in pairs(data) do
		self.m_WatchInfo[v.stage] = v
	end
	-- self:OnEvent(define.Arena.Event.OpenWatchPage)
	CArenaWatchView:ShowView()
end

--打开回放记录界面
function CArenaCtrl.GetArenaHistory(self)
	netarena.C2GSArenaHistory()
end

function CArenaCtrl.OnReceiveArenaHistory(self, historyInfo, historyOnShow)
	self.m_HistoryInfo = {}
	self.m_HistoryInfoSort = {}
	for k,v in pairs(historyInfo) do
		self.m_HistoryInfo[v.fid] = v
		self.m_HistoryInfoSort[k] = v.fid
	end

	self.m_ShowingHistory = historyOnShow
	-- self:OnEvent(define.Arena.Event.OpenReplay)
	CArenaHistoryView:ShowView()
end

function CArenaCtrl.OnReceiveFightResult(self, point, medal, result, currentpoint, weekyMedal, infoList)
	-- printc(string.format("OnReceiveFightResult: %s point %s medal %s result", point, medal, result))
	self.m_ArenaPoint = currentpoint
	self.m_WeekyMedal = weekyMedal
	self.m_ResultPoint = point
	self.m_ResultMedal = medal
	self.m_PlayerInfo = nil
	self.m_EnemyInfo = nil

	for k,v in pairs(infoList) do
		if self.m_ViewSide ~= 0 and v.camp == self.m_ViewSide and self.m_PlayerInfo == nil then
			self.m_PlayerInfo = v
		elseif v.pid == g_AttrCtrl.pid and self.m_PlayerInfo == nil then
			self.m_PlayerInfo = v
		else
			self.m_EnemyInfo = v
		end
	end
	if self.m_PlayerInfo.camp == result then
		self.m_Result = define.Arena.WarResult.Win
	else
		self.m_Result = define.Arena.WarResult.Fail
	end

	if self.m_Result == define.Arena.WarResult.Win then
		self.m_ArenaPoint = self.m_ArenaPoint + self.m_ResultPoint
	else
		self.m_ArenaPoint = self.m_ArenaPoint - self.m_ResultPoint
	end

	self:OnEvent(define.Arena.Event.OnWarEnd)
end

function CArenaCtrl.OnReceiveSetShowing(self, fid)
	self.m_ShowingHistory = self.m_HistoryInfo[fid]
	self:OnEvent(define.Arena.Event.SetShowing, fid)
end

function CArenaCtrl.GetDateText(self, time)
	local timeStr = "刚刚"
	local timeSpace = g_TimeCtrl:GetTimeS() - time
	local count = 1
	while timeSpace > 0 do
		timeStr = timeSpace .. self.m_TimeStr[count].desc
		count = count + 1
		if self.m_TimeStr[count] then
			timeSpace = math.floor(timeSpace / self.m_TimeStr[count].value)
		else
			timeSpace = -1
			timeStr = "史前"
		end
	end
	return timeStr
end

function CArenaCtrl.OnReceiveLeftTime(self, ileft)
	self.m_LeftTime = ileft + g_TimeCtrl:GetTimeS()
	self:OnEvent(define.Arena.Event.OnReceiveLeftTime)
end

function CArenaCtrl.GetLeftTimeText(self)
	local leftTime = self.m_LeftTime - g_TimeCtrl:GetTimeS()
	if leftTime <= 0 then
		return nil
	end
	local hour = math.modf(leftTime / 3600)
	local min = math.modf((leftTime % 3600) / 60)
	local sec = leftTime % 60
	return string.format("%02d:%02d:%02d", hour, min, sec)
end

function CArenaCtrl.ShowWarStartView(self, infoList)
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

function CArenaCtrl.CopyStartInfo(self, oInfo)
	local dInfo = {
		name = oInfo.name,
		shape = oInfo.shape,
		pid = oInfo.pid,
	}
	return dInfo
end

return CArenaCtrl