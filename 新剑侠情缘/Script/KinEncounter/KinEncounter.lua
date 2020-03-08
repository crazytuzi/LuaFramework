function KinEncounter:UpdatePreLeftInfo(tbParam)
	local nTimeLeft, nKinCount, nKinMemberCount = unpack(tbParam)
	if Ui:WindowVisible("QYHLeftInfo") == 1 then
		Ui:DoLeftInfoUpdate({nTimeLeft, nKinCount, nKinMemberCount})
	else
		Ui:OpenWindow("QYHLeftInfo", "KinEncounterPre", {nTimeLeft, nKinCount, nKinMemberCount})
		Timer:Register(1, function()
			UiNotify.OnNotify(UiNotify.emNOTIFY_SHOWTEAM_NO_TASK)
		end)
	end
end

function KinEncounter:OnPrepareBegin(nStartTime)
	self.nStartTime = nStartTime or GetTime()
	
	self:ClearData()
	self.nPrepareEndTime = self.nStartTime + self.Def.nPrepareTime

	if me.nLevel < self.Def.nJoinLevel then
		return
	end
	Ui:SynNotifyMsg({
        szType = "KinEncounter",
        nTimeOut = self.nPrepareEndTime,
    })	
	Player:ServerSyncData("UpdateTopButton")
end

function KinEncounter:OnPrepareEnd()
	Player:ServerSyncData("UpdateTopButton")
end

function KinEncounter:OnGameOver(tbData)
	Ui:OpenWindow("KinEncounterResultPanel", tbData)

	local szUiName = "KinEncounterScreenPanel"
	if Ui:WindowVisible(szUiName) == 1 then
		Ui(szUiName):OnGameOver()
	end
end

function KinEncounter:OnEnterFightMap(tbData)
	self.tbFightData = self.tbFightData or {}
	local szUiName = "KinEncounterScreenPanel"
	if Ui:WindowVisible(szUiName) ~= 1 then
		Ui:OpenWindow(szUiName, tbData)
	end
	Timer:Register(1, function()
		UiNotify.OnNotify(UiNotify.emNOTIFY_SHOWTEAM_NO_TASK)
	end)
end

function KinEncounter:ClearData()
	self.tbFightData = {}
end

function KinEncounter:OnFightDataChange(nKinId, tbChange)
	self.tbFightData[nKinId] = self.tbFightData[nKinId] or {}
	for k, v in pairs(tbChange) do
		self.tbFightData[nKinId][k] = v
	end

	local szUiName = "KinEncounterScreenPanel"
	if Ui:WindowVisible(szUiName) == 1 then
		Ui(szUiName):Refresh()
	end
	self:RefreshShopPanel()
end

function KinEncounter:GetScreenData()
	local tbRet = {}
	for nKinId, tbKinData in pairs(self.tbFightData or {}) do
		tbRet[nKinId] = {
			nScore = tbKinData.nScore,
			nWood = tbKinData.nWood,
			nFood = tbKinData.nFood,
			nKillRank = tbKinData.nKillRank,
		}
	end
	return tbRet
end

function KinEncounter:GetWood()
	local tbKinData = (self.tbFightData or {})[me.dwKinId]
	return tbKinData and tbKinData.nWood or 0
end

function KinEncounter:OnKillRankDataChange(tbData)
	self.tbKillRank = tbData
	local szUiName = "KinEncounterRankPanel"
	if Ui:WindowVisible(szUiName) == 1 then
		Ui(szUiName):Refresh()
	end
end

function KinEncounter:OnUpdateToolInfo(tbInfo)
	self.tbToolInfo = tbInfo
	self:RefreshShopPanel()
end

function KinEncounter:RefreshShopPanel()
	local szUiName = "KinEncounterShopPanel"
	if Ui:WindowVisible(szUiName) ~= 1 then
		return
	end
	Ui(szUiName):UpdateRightPanel()
end

function KinEncounter:OnDeath()
	AutoPath:ClearGoPath()
	Ui:ShowComboKillCount(0)
	self:OpenWay()
end

function KinEncounter:OnRecordUpdated(tbData)
	self.tbRecord = tbData
	local szUiName = "KinEncounterJoinPanel"
	if Ui:WindowVisible(szUiName) ~= 1 then
		return
	end
	Ui(szUiName):UpdateRecord()
end

function KinEncounter:OnLogin(nStartTime)
	self:OnPrepareBegin(nStartTime)

	local szUiName = "PlayerLevelUpGuide"
	if Ui:WindowVisible(szUiName) ~= 1 then
		return
	end
	Ui(szUiName):OnOpen()
end

function KinEncounter:OpenWay()
	local nBarrierType = Map.emBrushType_None		--没有障碍
	self:SetBarrierInfo(nBarrierType)
end

function KinEncounter:CloseWay()
	
	local nBarrierType = Map.emBrushType_Barrier	--不可通过的障碍
	self:SetBarrierInfo(nBarrierType)
end

function KinEncounter:SetBarrierInfo(nBarrierType)
	local nMapId = me.nMapId
	local tbWays = self.Def.tbWays
	for _, tbBarrier in ipairs(tbWays) do
		local tbStartPos = tbBarrier[1]
		local tbEndPos = tbBarrier[2]

		local nCenterPosX = (tbStartPos[1] + tbEndPos[1]) / 2
		local nCenterPosY = (tbStartPos[2] + tbEndPos[2]) / 2

		local nLenX = math.abs(tbStartPos[1] - tbEndPos[1])
		local nLenY = 1
		SetSubWorldBarrierInfo(nMapId, nCenterPosX, nCenterPosY, nLenX, nLenY, nBarrierType)
	end
end