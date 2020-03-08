if not MODULE_GAMECLIENT then	--名将没有客户端的文件夹，就把达摩洞的客户端函数也放在这吧
	return
end

BossLeader.DaMoCave = BossLeader.DaMoCave or {}
local DaMoCave = BossLeader.DaMoCave

function DaMoCave:IsActivityOpen()
	return self.Def.bOpen
end

function DaMoCave:CanJoin(dwKinId)
	return self.tbKinList[dwKinId]
end

function DaMoCave:OnSyncKinList(tbKinList)
	self.tbKinList = tbKinList or {}
end

function DaMoCave:IsDaMoCaveMap(nMapTemplateId)
	return nMapTemplateId == self.Def.tbMapSetting[1].nMapTemplateId or nMapTemplateId == self.Def.tbMapSetting[2].nMapTemplateId
end

function DaMoCave:IsFirstFloor(nMapTemplateId)
	return nMapTemplateId == self.Def.tbMapSetting[1].nMapTemplateId
end

function DaMoCave:OnSyncDmgInfo(tbDmgInfo, nNpcTemplateId)
	self.tbDmgInfo = {}
	local szName = KNpc.GetNameByTemplateId(nNpcTemplateId)
	for i = 1, self.Def.nSyncDmgCount do
		if not tbDmgInfo[i] then
			break
		end
		table.insert(self.tbDmgInfo, tbDmgInfo[i])
	end
	self.szTargetName = szName
	self.nDmgTimeOut = GetTime() + 5
	self.tbDmgInfo.szTargetName = szName
	UiNotify.OnNotify(UiNotify.emNOTIFY_DMG_RANK_UPDATE, self.tbDmgInfo)
end

function DaMoCave:GetDmgInfo()
	if not self.tbDmgInfo or not next(self.tbDmgInfo) or GetTime() > (self.nDmgTimeOut or 0) then
		return nil
	end
	return self.tbDmgInfo
end

function DaMoCave:OnMapLoaded(nMapTemplateId)
	if self:IsDaMoCaveMap(nMapTemplateId) then
		RemoteServer.DaMoCaveC2ZCall("RequestSyncLeftTime")
	end
	if not self:IsFirstFloor(nMapTemplateId) then
		return
	end

	RemoteServer.DaMoCaveC2ZCall("OnClientEnterFirstFloor")
end

function DaMoCave:OnOpenMiniMap()
	if self:IsDaMoCaveMap(me.nMapTemplateId) and not self:IsFirstFloor(me.nMapTemplateId) then
		RemoteServer.DaMoCaveC2ZCall("RequestUpdateMiniMapInfo", self.nMiniMapVersion)
	end
end

function DaMoCave:OnSyncRoomInfo(nRoomIndex)
	self.nCurRoomIndex = nRoomIndex
	self.szMapName = string.format("达摩洞·外·%s", Lib:TransferDigit2CnNum(nRoomIndex or 1))
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_MAP_NAME, self.szMapName)

	local tbMapTextPosInfo = Map:GetMapTextPosInfo(self.Def.tbMapSetting[1].nMapTemplateId) or {}
	local nPrevRoomIndex, nNextRoomIndex = self:GetPrevNextRoomIndex(nRoomIndex or 1)
	for k, v in pairs(tbMapTextPosInfo) do
		if v.Index == "PrevRoom" then
			v.Text = string.format("达摩洞·外\n%s", Lib:TransferDigit2CnNum(nPrevRoomIndex))
		elseif v.Index == "NextRoom" then
			v.Text = string.format("达摩洞·外\n%s", Lib:TransferDigit2CnNum(nNextRoomIndex))
		end
	end
end

function DaMoCave:OnSyncMiniMapInfo(tbMiniMapInfo, nMiniMapVersion)
	self.nMiniMapVersion = nMiniMapVersion
	local tbMapTextPosInfo = Map:GetMapTextPosInfo(self.Def.tbMapSetting[2].nMapTemplateId) or {}
	for k, v in pairs(tbMapTextPosInfo) do
		local nIndex = tonumber(string.match(v.Index, "fuhuo(%d+)"))
		if tbMiniMapInfo[nIndex] then
			v.Text = tbMiniMapInfo[nIndex]
		end
	end
end

function DaMoCave:OnActivityEndClient()
	Map:LoadMapTextPosInfo(self.Def.tbMapSetting[1].nMapTemplateId)
	Map:LoadMapTextPosInfo(self.Def.tbMapSetting[2].nMapTemplateId)
end

function DaMoCave:OnStateActive(nState, nLeftTime)
	--Log("DaMoCave:OnStateActive", nState, nLeftTime)
	self.nState = nState
	self.nLeftTime = nLeftTime
	self:UpdateStateTips()
end

function DaMoCave:UpdateStateTips()
	if not self:IsDaMoCaveMap(me.nMapTemplateId) then
		return
	end
	local nFloor = self:IsFirstFloor(me.nMapTemplateId) and 1 or 2
	local szTips
	local nTipsState = self.nState
	local nShowLeftTime
	while true do
		if not self.Def.tbProcessSetting[nTipsState or 0] then
			break
		end
		szTips = self.Def.tbStateTips[nTipsState] and self.Def.tbStateTips[nTipsState][nFloor]
		if not szTips then
			nTipsState = nTipsState + 1
		else
			nShowLeftTime = self.nLeftTime + (self.Def.tbProcessSetting[nTipsState][1] - self.Def.tbProcessSetting[self.nState][1])
			break
		end
	end
	if not szTips then
		Ui:CloseWindow("HomeScreenFuben")
		return
	end
	if not Ui:WindowVisible("HomeScreenFuben") then
		Ui:OpenWindow("HomeScreenFuben", "DaMoCave")
	end
	me.tbFubenInfo = {nEndTime = GetTime() + nShowLeftTime, tbTargetInfo = {szTips}, szHelpKey = "DaMoCave"}
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE)
end

function DaMoCave:OnLeaveDaMoCave()
	Ui:CloseWindow("HomeScreenFuben")
end

function DaMoCave:RequestLeave()
	if self.bGoDownstairs then
		RemoteServer.DaMoCaveC2ZCall("RequestGoDownstairs")
	else
		RemoteServer.DaMoCaveC2ZCall("LeaveDaMoCave")
	end
end

function DaMoCave:UpdateDownstairsButton(bOpen)
	self.bGoDownstairs = bOpen
	self.szLeaveBtnName = bOpen and "进入" or "离开"
	Ui:OpenWindow("QYHLeavePanel", bOpen and "DaMoCave_GoDownstairs" or "DaMoCave", {BtnLeave = true})
end