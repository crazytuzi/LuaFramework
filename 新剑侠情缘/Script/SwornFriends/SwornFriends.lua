function SwornFriends:AutoPathToNpc(nNpcId, nMapId)
    local nPosX, nPosY = AutoPath:GetNpcPos(nNpcId, nMapId)
    local fnCallback = function ()
        local nId = AutoAI.GetNpcIdByTemplateId(nNpcId)
        if nId then
            Operation.SimpleTap(nId)
        end
    end
    AutoPath:GotoAndCall(nMapId, nPosX, nPosY, fnCallback, Npc.DIALOG_DISTANCE)
end

function SwornFriends:OnPushToClient(szType, tbValue, xValue, bConnected)
	if szType=="connectids" then
		self.tbConnectIds = tbValue
		self.szMainTitle = xValue
		self.bConnected = bConnected
	elseif szType=="connected" then
		self:PlayConnectAnimation(tbValue)
	else
		Log("[x] SwornFriends:OnPushToClient, unknown", tostring(szType))
	end
end

function SwornFriends:PlayConnectAnimation(tbNames)
	local szNames = table.concat(tbNames, "、")
	Ui:OpenWindow("SwornFriendsConnectPanel", szNames, function()
		--do nothing
	end, true)
end

function SwornFriends:IsConnected(nOtherId)
	return Lib:IsInArray(self.tbConnectIds or {}, nOtherId)
end

function SwornFriends:DisconnectDlg()
	local fnAgree = function ()
		RemoteServer.ReqSwornFriends("DisconnectReq")
	end

	local tbNames = {}
	for _, nId in ipairs(self.tbConnectIds or {}) do
		local tbRoleInfo = FriendShip:GetFriendDataInfo(nId)
		if tbRoleInfo then
			table.insert(tbNames, tbRoleInfo.szName)
		end
	end

	local szMsg = next(tbNames) and string.format("确定要结束与[FFFE0D]%s[-]的结拜关系吗？", table.concat(tbNames, "、")) or "确定要结束结拜关系吗？"
	Ui:OpenWindow("MessageBox",
		szMsg,
		{{fnAgree}, {}}, {"确定", "取消"})
end

function SwornFriends:CanDelFriend(nId)
	return not self:IsConnected(nId)
end

function SwornFriends:CheckMainTitle(szHead, szTail)
	szHead = Lib:StrTrim(szHead)
	szTail = Lib:StrTrim(szTail)
	if szHead=="" or szTail=="" then
		return false, "请填写称号"
	end

	local nHeadLen = Lib:Utf8Len(szHead)
	local nTailLen = Lib:Utf8Len(szTail)
	if nHeadLen>self.Def.nTitleHeadMax or nHeadLen<self.Def.nTitleHeadMin or nTailLen>self.Def.nTitleTailMax or nTailLen<self.Def.nTitleTailMin then
		return false, string.format("前缀%d-%d字符，后缀%d~%d字符", self.Def.nTitleHeadMin, self.Def.nTitleHeadMax, self.Def.nTitleTailMin, self.Def.nTitleTailMax)
	end

	if not CheckNameAvailable(szHead) or not CheckNameAvailable(szTail) then
		return false, "含有非法字符，请修改后重试"
	end

	if ReplaceLimitWords(szHead) or ReplaceLimitWords(szTail) then
	  	return false, "含有敏感字符，请修改后重试"
	end
	return true, szHead, szTail
end

function SwornFriends:ConnectReq(szHead, szTail)
	local bOk = false
	bOk, szHead, szTail = self:CheckMainTitle(szHead, szTail)
	if not bOk then
		return false, szHead
	end
	RemoteServer.ReqSwornFriends("ConnectReq", {szHead, szTail})
	return true
end

function SwornFriends:ChangePersonalTitleReq(szTitle, bConsumeItem)
	szTitle = Lib:StrTrim(szTitle)
	if szTitle=="" then
		return false, "请填写称号"
	end

	local nLen = Lib:Utf8Len(szTitle)
	if nLen>self.Def.nPersonalTitleMax or nLen<self.Def.nPersonalTitleMin then
		return false, string.format("个人称号%d-%d字符", self.Def.nPersonalTitleMin, self.Def.nPersonalTitleMax)
	end

	if not CheckNameAvailable(szTitle) then
		return false, "含有非法字符，请修改后重试"
	end

	if ReplaceLimitWords(szTitle) then
		return false, "含有敏感字符，请修改后重试"
	end

	RemoteServer.ReqSwornFriends("ChangePersonalTitle", szTitle, bConsumeItem)
	return true
end

function SwornFriends:_ShowChangeTitleQuickUse()
	local nItemId = nil
	local tbItems = me.FindItemInBag(self.Def.nPersonalTitleItemId)
	if tbItems and #tbItems>0 then
		for _,pItem in ipairs(tbItems) do
			nItemId = pItem.dwId
			break
		end
	end
	if nItemId then
		Ui:OpenQuickUseItem(nItemId)
	end
end

function SwornFriends:OnFinishConnection()
	Ui:OpenWindow("SwornFriendsConnected")
	Ui:ShowOthers()

	local tbAward = {
		{"item", SwornFriends.Def.nPersonalTitleItemId, 1},
	}
	Ui:OpenAwardUi(tbAward, 0, true)

	self:_ShowChangeTitleQuickUse()
end