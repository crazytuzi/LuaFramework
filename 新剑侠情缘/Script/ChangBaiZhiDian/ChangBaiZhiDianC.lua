ChangBaiZhiDian.nDefaultFontSize = 14
ChangBaiZhiDian.nSelfFontSize = 20

function ChangBaiZhiDian:OnSyncChooseFactionInfo(tbFactionInfo)
	self.tbChoosedFactions = tbFactionInfo
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGBAI_FACTION)
end

function ChangBaiZhiDian:SetClientLeftTime(nState, nLeftTime)
	self.nLeftTime = nLeftTime
	self.nState = nState

	if self.nTimerLeftTime then
		Timer:Close(self.nTimerLeftTime)
		self.nTimerLeftTime = nil
	end

	self.nTimerLeftTime = Timer:Register(Env.GAME_FPS, function()
		self.nLeftTime = self.nLeftTime - 1
		if self.nLeftTime <= 0 then
			self.nState = self.nState + 1
			local tbNextStateInfo = self.Def.tbTimeState[self.nState]
			if not tbNextStateInfo then
				self.nState = self.nState - 1
				self.nTimerLeftTime = nil
				return false
			end
			self.nLeftTime = self:GetState2EndTime(self.nState)
		end
		return true
	end)
	if not self:IsChoosingFaction() then
		local tbInfo = {nEndTime = GetTime() + nLeftTime, tbTargetInfo = {[1] = self.Def.tbTimeState[self.nState].szDesc or ""}}
		if not Ui:WindowVisible("HomeScreenFuben") then
			Ui:OpenWindow("HomeScreenFuben", "ChangBaiZhiDian", tbInfo)
		else
			me.tbFubenInfo = tbInfo
			UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE)
		end
	end
end

function ChangBaiZhiDian:OnStartSignUp(tbMatchTime)
	if ChangBaiZhiDian:GetJoinCount(me) < 1 then
		return
	end
	--推送感叹号提示
	local tbMsgData = {}
	tbMsgData.szType = "ChangBaiZhiDian"
	tbMsgData.nTimeOut = GetTime() + self.Def.nMatchInterval * self.Def.nMatchTimes	 --有效期和总匹配时间保持一致
	Ui:SynNotifyMsg(tbMsgData)
	self.tbMatchTime = tbMatchTime
end

function ChangBaiZhiDian:OnEnterBattleMap(nState, nLeftTime, tbFactionSet, tbChoosedFactions, nCamp)
	self.nState = nState
	self.nLeftTime = nLeftTime
	self.tbFactionSet = tbFactionSet
	self.tbTeamReportInfo = {}
	self.tbNpcOccupiedInfo = {}
	self.tbChoosedFactions = tbChoosedFactions

	self.nSyncTeamReportInfoVersion = 0
	self.nSyncNpcOccupiedInfoVersion = 0

	self.nRank = 1;
	self.nScore = 0;
	self.nCamp = nCamp or 1
	me.GetNpc().SetTitleID(self.Def.tbBattleMapPos[nCamp].nTitleID)
	if not self.bRegistNotofy then
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterNewMap, self)  --进新的非战场图， 正常离开或重连超时时
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveCurMap, self)  --离开战场图  返回登录时
		UiNotify:RegistNotify(UiNotify.emNOTIFY_SET_PLAYER_NAME, self.OnSetPlayerName, self)  --同步设置玩家名字时
		self.bRegistNotofy = true;
	end
	if self:IsChoosingFaction() then
		Ui:OpenWindow("ChangBaiZhiDianChoicePanel", self.tbFactionSet)
	else --非选择门派期间(断线重连等情况)
		Ui:OpenWindow("ChangBaiZhiDianIntegralInfo")
	end
	--重新初始化一下小地图上的文字信息
	Map:LoadMapTextPosInfo(self.Def.nBattleMapTID)
	RemoteServer.ChangBaiC2ZCall("SyncClientTime")
	Fuben:ShowHelp("ChangbaiHelp")
end

function ChangBaiZhiDian:OnBattleStart()
	Ui:OpenWindow("ChangBaiZhiDianIntegralInfo")
	AutoFight:ChangeState(AutoFight.OperationType.Auto, true)
	local _, nCamp = me.GetNpc().GetPkMode()
	self.nCamp = nCamp or 1
end

function ChangBaiZhiDian:OnBattleEnd()
	me.tbFubenInfo = {tbTargetInfo = {[1] = "战斗结束"}}
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE)
	Ui:OpenWindow("ChangBaiZhiDianReportPanel")
	--把小地图上的文字信息重置为初始配置
	Map:LoadMapTextPosInfo(self.Def.nBattleMapTID)
end

function ChangBaiZhiDian:OnEnterNewMap(nMapTemplateId)
	self:OnCloseBattleMap()
end

function ChangBaiZhiDian:OnLeaveCurMap(nMapTemplateId)
	self:OnCloseBattleMap()
end

function ChangBaiZhiDian:OnSetPlayerName(nNpcId)
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		return 
	end
	if pNpc.dwTeamID == TeamMgr:GetTeamId() then
		return
	end
	pNpc.SetName("神秘人")
end

function ChangBaiZhiDian:OnCloseBattleMap()
	ChatMgr:LeaveCurChatRoom()
	Ui:ChangeUiState(0, true)
	if self.bRegistNotofy then
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self)
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_SET_PLAYER_NAME, self)

		self.bRegistNotofy = nil
	end

	if self.nTimerLeftTime then
		Timer:Close(self.nTimerLeftTime)
		self.nTimerLeftTime = nil
	end
	self.nState = nil
	self.nLeftTime = nil
	self.tbFactionSet = nil
	self.tbTeamReportInfo = nil
	self.tbNpcOccupiedInfo = nil

	self.nSyncTeamReportInfoVersion = nil
	self.nSyncNpcOccupiedInfoVersion = nil

	me.tbFubenInfo = nil
	Ui:CloseWindow("HomeScreenFuben")
	Ui:CloseWindow("ChangBaiZhiDianChoicePanel")
	Ui:CloseWindow("ChatLargePanel")
	Ui:CloseWindow("ChangBaiZhiDianIntegralInfo")
	--TODO 关闭主界面上的队伍积分和排名界面

end

function ChangBaiZhiDian:OnStopSignUp()
	--
end
--开始战斗倒计时，数字放大
function ChangBaiZhiDian:StartCountdownTips()
	--因为倒计时的数字是从9开始的，所以延迟一秒，和主界面的倒计时保持一致
	Timer:Register(Env.GAME_FPS, function()
		Ui:OpenWindow("SpecialTips", "战斗即将开始！")
	end)
end
--结束战斗倒计时，数字放大
function ChangBaiZhiDian:EndCountdownTips()
	--因为倒计时的数字是从9开始的，所以延迟一秒，和主界面的倒计时保持一致
	Timer:Register(Env.GAME_FPS, function()
		Ui:OpenWindow("SpecialTips", "战斗即将结束！")
	end)
end

function ChangBaiZhiDian:OnSyncTeamReportInfo(tbTeamReportInfo, nVersion)
	self.tbTeamReportInfo = tbTeamReportInfo or self.tbTeamReportInfo
	self.nSyncTeamReportInfoVersion = nVersion
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_CHANGBAI_REPORT_DATA)
end

function ChangBaiZhiDian:OnSyncNpcOccupiedInfo(tbNpcOccupiedInfo, nVersion)
	self.tbNpcOccupiedInfo = tbNpcOccupiedInfo or self.tbNpcOccupiedInfo 	--[nIndex] = {nTId = nTemplateId, nCamp = nCamp, nQuality = nQuality, szIndex = szIndex}
	self.nSyncNpcOccupiedInfoVersion = nVersion
	local tbMapTextPosInfo = Map:GetMapTextPosInfo(self.Def.nBattleMapTID) or {}
	for _, tbNpcInfo in ipairs(self.tbNpcOccupiedInfo) do
		local szIndex = tbNpcInfo.szIndex or ""
		for k, v in pairs(tbMapTextPosInfo) do
			if szIndex == v.Index then
				local szCamp = tbNpcInfo.nCamp > 0 and ("（"..self.Def.tbBattleMapPos[tbNpcInfo.nCamp].szName.."）") or ""
				v.Text = KNpc.GetNameByTemplateId(tbNpcInfo.nTId)..szCamp
				v.Color = self.Def.tbNameColorByQuality[tbNpcInfo.nQuality][2]
				if self.nCamp == tbNpcInfo.nCamp then
					v.FontSize = self.nSelfFontSize
				else
					v.FontSize = self.nDefaultFontSize
				end
			end
		end
	end
end

function ChangBaiZhiDian:ReadTeamReport()
	RemoteServer.ChangBaiC2ZCall("SyncTeamReportInfo", self.nSyncTeamReportInfoVersion)
	Ui:OpenWindow("ChangBaiZhiDianReportPanel")
end

function ChangBaiZhiDian:OnOpenMiniMap()
	RemoteServer.ChangBaiC2ZCall("SyncNpcOccupiedInfo", self.nSyncNpcOccupiedInfoVersion)
end

function ChangBaiZhiDian:SetChangBaiOpen(bOpen)	--设置客户端活动开启关闭（展示入口等）
	self.Def.bOpen = bOpen
	Log("[ChangBaiZhiDian] SetChangBaiOpen", tostring(bOpen))
end

function ChangBaiZhiDian:IsChoosingFaction()
	return self.nState and self.nState <= 2
end

function ChangBaiZhiDian:OnRequestMatchTime(tbMatchTime)
	self.tbMatchTime = tbMatchTime
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_CHANGBAI_MATCH_TIME)
end

function ChangBaiZhiDian:UpdateRankAndScore(tbResult)
	table.sort(tbResult, function(a, b)
		return a.nScore > b.nScore
		end)
	for nRank, v in ipairs(tbResult) do
		if self.nCamp == v.nCamp then
			self.nRank = nRank
			self.nScore = v.nScore
			break
		end
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGBAI_UPDATE_RANK_SCORE);
end

function ChangBaiZhiDian:OnPlayerDeath(nReviveTimePoint)
	self.nReviveTimePoint = nReviveTimePoint or 0
end