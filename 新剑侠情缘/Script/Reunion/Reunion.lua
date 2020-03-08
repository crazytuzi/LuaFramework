Reunion.tbCacheFriendReservedPlace = Reunion.tbCacheFriendReservedPlace or {}
function Reunion:OpenFindUi(bNoRequest)
	if self:GetReservedPlace() <= 0 then
		me.CenterMsg("向导数量已满")
		return
	end

	local tbAllFriend  = FriendShip:GetAllFriendData()
	local tbFriendList = {}
	local tbNoData     = {}
	for _, tbInfo in pairs(tbAllFriend) do
		if tbInfo.nState == 2 and
			FriendShip:GetImityLevel(tbInfo.nImity) >= self.IMITY_LEVEL and
			tbInfo.nLevel >= me.nLevel + self.PLAYERLEVEL and 
			tbInfo.nVipLevel >= self.VIP_LEVEL and
			(not self.tbMyData.tbRelation or not self.tbMyData.tbRelation[tbInfo.dwID]) then
			if self.tbCacheFriendReservedPlace[tbInfo.dwID] then
				if self.tbCacheFriendReservedPlace[tbInfo.dwID] > 0 then
					table.insert(tbFriendList, tbInfo.dwID)
				end
			else
				table.insert(tbNoData, tbInfo.dwID)
			end
		end
	end
	if not bNoRequest then
		RemoteServer.ReunionOnClientCall("GetReservedPlace", tbNoData)
	else
		Ui:OpenWindow("ReunionFindGuiderPanel", tbFriendList)
	end
end

function Reunion:GetReservedPlaceRsp(tbReservedPlace)
	for nPlayerId, nPlaces in pairs(tbReservedPlace) do
		Reunion.tbCacheFriendReservedPlace[nPlayerId] = nPlaces
	end
	Reunion:OpenFindUi(true)
end

function Reunion:GetReservedPlace()
	if self.tbMyData.nMyType == self.TYPE_GUIDE then
		return 0
	end

	self.tbMyData.tbRelation = self.tbMyData.tbRelation or {}
	return self.RELATION_COUNT - Lib:CountTB(self.tbMyData.tbRelation)
end

function Reunion:OnLogin(tbMyData, nActCount)
	self.tbMyData = tbMyData
	self:OnSyncRelationActState(nActCount)
	self:StartCheckTimeoutTimer()
end

function Reunion:OnLogout()
	if self.nCheckTimeOutTimer then
		Timer:Close(self.nCheckTimeOutTimer)
		self.nCheckTimeOutTimer = nil
	end
	self.tbCacheFriendReservedPlace = {}
	self.tbMyData = nil
end

function Reunion:StartCheckTimeoutTimer(nTimeOut)
	if self.tbMyData.nMyType ~= self.TYPE_BACK and self.tbMyData.nMyType ~= self.TYPE_GUIDE then
		return
	end
	if not self.tbMyData.tbRelation or not next(self.tbMyData.tbRelation) then
		return
	end
	if self.nCheckTimeOutTimer then
		return
	end
	local nTime = math.huge
	if nTimeOut then
		nTime = nTimeOut - GetTime()
	else
		for _, tbInfo in pairs(self.tbMyData.tbRelation) do
			nTime = math.min(nTime, tbInfo.nRelationTime + self.RELATION_TIME)
		end
		nTime = nTime - GetTime()
	end
	self.nCheckTimeOutTimer = Timer:Register(nTime * Env.GAME_FPS, Reunion.CheckGuideTimeout, Reunion)
end

function Reunion:CheckGuideTimeout()
	self.nCheckTimeOutTimer = nil
	if self.tbMyData.nMyType ~= self.TYPE_BACK and self.tbMyData.nMyType ~= self.TYPE_GUIDE then
		return
	end
	if not self.tbMyData.tbRelation or not next(self.tbMyData.tbRelation) then
		return
	end
	local nTime = math.huge
	local bHaveTimeout
	for _, tbInfo in pairs(self.tbMyData.tbRelation) do
		if GetTime() >= tbInfo.nRelationTime + self.RELATION_TIME then
			bHaveTimeout = true
		end
		nTime = math.min(nTime, tbInfo.nRelationTime + self.RELATION_TIME)
	end
	if bHaveTimeout then
		RemoteServer.ReunionOnClientCall("CheckGuideTimeout", nPlayerId)
	end
	if nTime > GetTime() then
		self.nCheckTimeOutTimer = Timer:Register((nTime - GetTime()) * Env.GAME_FPS, Reunion.CheckGuideTimeout, Reunion)
	end
end

function Reunion:OnRelationTimeout(tbList)
	if not self.tbMyData or not self.tbMyData.tbRelation then
		return
	end
	for _, nPlayerId in pairs(tbList) do
		self.tbMyData.tbRelation[nPlayerId] = nil
	end
	if Lib:CountTB(self.tbMyData.tbRelation) == 0 then
		self.tbMyData.nMyType = nil
	end
	--如果关系结束时玩家还在重逢页面会导致显示异常或者报错，这里统一关掉
	Ui:CloseWindow("SocialPanel")
end

function Reunion:OnSyncRelationActState(nActCount)
	self.nRelationActCount = nActCount
end

function Reunion:CheckCanFindGuider()
	if self.nRelationActCount <= 0 then
		return false, "活动未开启"
	end
	if not RegressionPrivilege:IsInPrivilegeTime(me) then
		return false, "不是回流玩家"
	end

	if self.tbMyData.nMyType == self.TYPE_GUIDE then
		return false, "还是向导身份"
	end
	self.tbMyData.tbRelation = self.tbMyData.tbRelation or {}
	if Lib:CountTB(self.tbMyData.tbRelation) >= self.RELATION_COUNT then
		return false, "向导数量已满"
	end
	return true
end

function Reunion:TryApply(nPlayerId)
	local bRet, szMsg = self:CheckCanFindGuider()
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	if self.tbMyData.tbRelation and self.tbMyData.tbRelation[nPlayerId] then
		me.CenterMsg("已是你向导")
		return
	end
	RemoteServer.ReunionOnClientCall("ApplyGuider", nPlayerId)
end

function Reunion:OnApplyGuider(nApplyer, szName)
	local tbMsgData = {szType = "ApplyReunion", nTimeOut = GetTime() + 300, nApplyPlayer = nApplyer, szApplyName = szName}
	Ui:SynNotifyMsg(tbMsgData)
end

function Reunion:OnCreateRelation(nFriend, nType)
	self.tbMyData.tbRelation          = self.tbMyData.tbRelation or {}
	self.tbMyData.tbRelation[nFriend] = 	{
		nRelationTime   = GetTime(),
		nChuanGongDay   = 0,
		nChuanGongTimes = 0,
		tbComplete      = {},
	}
	self.tbMyData.nMyType = nType
	self:StartCheckTimeoutTimer(GetTime() + self.RELATION_COUNT)
	me.CenterMsg("重逢关系已建立，请点击社交按钮查看")
end

function Reunion:OnChuanGongTimesChange(nRelation, nDay, nTimes)
	self.tbMyData.tbRelation = self.tbMyData.tbRelation or {}
	if not self.tbMyData.tbRelation[nRelation] then
		return
	end
	self.tbMyData.tbRelation[nRelation].nChuanGongDay = nDay
	self.tbMyData.tbRelation[nRelation].nChuanGongTimes = nTimes
	UiNotify.OnNotify(UiNotify.emNOTIFY_REUNION_DATA_UPDATE)
end

function Reunion:OnCompleteAct(nActId, nCount, tbGuider)
	self.tbMyData.tbRelation = self.tbMyData.tbRelation or {}
	for nRelationer, tbInfo in pairs(self.tbMyData.tbRelation) do
		if tbGuider[nRelationer] then
			if not tbInfo.tbComplete[nActId] then
				tbInfo.tbComplete[nActId] = {[Reunion.COMPLETE_IDX_COUNT] = 0, [Reunion.COMPLETE_IDX_FLAG] = false}
			end
			tbInfo.tbComplete[nActId][Reunion.COMPLETE_IDX_COUNT] = tbInfo.tbComplete[nActId][Reunion.COMPLETE_IDX_COUNT] + nCount
		end
	end
end

function Reunion:OnBackerCompleteAct(nBacker, nActId, nCount)
	self.tbMyData.tbRelation = self.tbMyData.tbRelation or {}
	if not self.tbMyData.tbRelation[nBacker] then
		return
	end
	if not self.tbMyData.tbRelation[nBacker].tbComplete[nActId] then
		self.tbMyData.tbRelation[nBacker].tbComplete[nActId] = {[Reunion.COMPLETE_IDX_COUNT] = 0, [Reunion.COMPLETE_IDX_FLAG] = false}
	end
	self.tbMyData.tbRelation[nBacker].tbComplete[nActId][Reunion.COMPLETE_IDX_COUNT] = self.tbMyData.tbRelation[nBacker].tbComplete[nActId][Reunion.COMPLETE_IDX_COUNT] + nCount
end

function Reunion:ReportRsp(nGuider)
	self.tbMyData.tbRelation = self.tbMyData.tbRelation or {}
	if not self.tbMyData.tbRelation[nGuider] or not self.tbMyData.tbRelation[nGuider].tbComplete then
		return
	end
	for nActId, tbInfo in pairs(self.tbMyData.tbRelation[nGuider].tbComplete) do
		local tbAct = Reunion:GetTargetInfo(nActId)
		if tbInfo[Reunion.COMPLETE_IDX_COUNT] >= tbAct.nCompleteCount then
			tbInfo[Reunion.COMPLETE_IDX_FLAG] = true
		end
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_REUNION_DATA_UPDATE)
	me.CenterMsg("任务汇报成功", true)
end

function Reunion:OnReportRsp(nBacker, tbAct, szName)
	Ui:OpenWindow("StudentReportPanel", nBacker, szName, tbAct, "Reunion")

	if not self.tbMyData then
		return
	end
	self.tbMyData.tbRelation = self.tbMyData.tbRelation or {}
	if not self.tbMyData.tbRelation[nBacker] or not self.tbMyData.tbRelation[nBacker].tbComplete then
		return
	end
	for _, nActId in pairs(tbAct) do
		if self.tbMyData.tbRelation[nBacker].tbComplete[nActId] then
			self.tbMyData.tbRelation[nBacker].tbComplete[nActId][Reunion.COMPLETE_IDX_FLAG] = true
		end
	end
end

function Reunion:IsShowButton()
	local nMyType = (self.tbMyData or {}).nMyType
	return nMyType == self.TYPE_GUIDE or nMyType == self.TYPE_BACK
end

function Reunion:IsRelation(nPlayerId)
	self.tbMyData.tbRelation = self.tbMyData.tbRelation or {}
	return self.tbMyData.tbRelation[nPlayerId] and true or false
end