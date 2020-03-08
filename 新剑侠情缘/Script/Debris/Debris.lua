
function Debris:DoRequestRobList(nItemId, nIndex)
	if not nItemId or not nIndex then
		return
	end
	local nNow = GetTime()
	if self.nAskRobListTime and nNow - self.nAskRobListTime <= 1 then
		return
	end
	RemoteServer.DebrisGetRobList(nItemId, nIndex)
	self.nAskRobListTime = nNow
end

function Debris:RefreshMainPanel()
	UiNotify.OnNotify(UiNotify.emNOTIFY_DEBRIS_UPDATE)
end

function Debris:SyncRobListData(tbResult, nItemId, nIndex)
	if Ui:WindowVisible("DebrisRobList") then --防止闪烁就不直接重打开窗口了
		UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_DEBRIS_ROB_DATA, tbResult, nItemId, nIndex)	
	else
		Ui:OpenWindow("DebrisRobList", tbResult, nItemId, nIndex)
	end
end

function Debris:OnGetCardAward(tbAward)
	UiNotify.OnNotify(UiNotify.emNOTIFY_ON_DEBRIS_CARD_AWARD, tbAward)
end

function Debris:OnGetDebrisMoreRobResult(tbFinalAward)
	Ui:OpenWindow("DebrisMoreRobResult", tbFinalAward)
	if tbFinalAward[#tbFinalAward][1] == "EquipDebris" then
		UiNotify.OnNotify(UiNotify.emNOTIFY_DEBRIS_UPDATE)	
	end
end

function Debris:GetMyAvoidRobLeftTime()
	local nBeginTime = me.GetUserValue(self.SAVE_GROUP, self.KEY_AVOID_BEGIN)
	local nDuraTime = me.GetUserValue(self.SAVE_GROUP, self.KEY_AVOID_DUR)
	if nBeginTime ~= 0 and nDuraTime ~= 0 then
		return self:GetAvoidRobLeftTime(nBeginTime, nDuraTime, GetTime())	
	else
		return 0;
	end
end

function Debris:OpenFlipCard(bSuccess, nItemId, nIndex, pRoleStay)
	if pRoleStay then
		self.tbDebrisRobNpcInfo = pRoleStay
	end
	assert(self.tbDebrisRobNpcInfo)

	local fnCallBack = function ()
		Ui:OpenWindow("DebrisFlipCard", bSuccess, nItemId, nIndex)
	end

	ViewRole:OpenWindowWithFaction("ViewFight", self.tbDebrisRobNpcInfo.nFaction, fnCallBack) 
	
end

