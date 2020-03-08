
FriendRecall.tbRecalledPlayerList = FriendRecall.tbRecalledPlayerList or {}

-------------------client-------------------
function FriendRecall:OnLogin(bReconnect)
	if bReconnect then
		return
	end
	UiNotify:RegistNotify(UiNotify.emNOTIFY_PLAT_SHARE_RESULT, self.OnClientShareResult, self)
end

function FriendRecall:OnLogout()
	self.tbFriendCanRecallList = nil
	self.tbRecallAwardList = nil
	self.bRecalled = nil
	self.bHadList = nil
	self.tbRecalledPlayerList = {}
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_PLAT_SHARE_RESULT, self)
end

function FriendRecall:IsShowMainButton()

	if not self:IsInProcess() then
		return false
	end

	if not self:IsInShowMainIcon() then
		return false
	end

	if not self.bHadList and not self.bRecalled then
		return false
	end

	return true
end

function FriendRecall:IsShowButton()

	if not self:IsInProcess() then
		return false
	end

	return true
end

function FriendRecall:SyncCanRecallList(tbFriendCanRecallList, nHadList)
	self.tbFriendCanRecallList = tbFriendCanRecallList
	self.nLastReshRecallList = GetTime();
	self.bHadList = (nHadList == 1)
	
	UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_RECALL_LIST);
	UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_RECALL_BUTTON);
end

function FriendRecall:GetCanRecallList()
	if not self.tbFriendCanRecallList or ((self.nLastReshRecallList + self.Def.RESH_LIST_INTERVAL) < GetTime() )then
		RemoteServer.OnCallFriendRecall("SyncCanRecallList")
		return self.tbFriendCanRecallList or {}
	end

	return self.tbFriendCanRecallList
end

function FriendRecall:SyncRecallAwardList(tbRecallAwardList)
	self.tbRecallAwardList = tbRecallAwardList
	self.bRecalled = true
	UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_RECALL_BUTTON);
end

function FriendRecall:GetRecallAwardList()
	return self.tbRecallAwardList or {}
end

function FriendRecall:SyncRecallAwardPlayer(tbInfo)
	self.tbRecalledPlayerList[tbInfo[1]] = 
	{
		nType = tbInfo[2],
		szAccount = tbInfo[3],
	}
	UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_RECALL_LIST);
end

--获取自己发送的召回信息
function FriendRecall:GetRecalledList()
	local tbListInfo = Client:GetFlag("Act_FriendRecallList") or {}
	local nLastRecallMonth = tonumber(Client:GetFlag("Act_FriendRecallLastMonth")) or 0

	local nLocalMonth = Lib:GetLocalMonth();

	if nLocalMonth ~= nLastRecallMonth then
		tbListInfo = {};
		Client:SetFlag("Act_FriendRecallLastMonth", nLocalMonth)
		Client:SetFlag("Act_FriendRecallList", tbListInfo)
	end

	return tbListInfo
end

function FriendRecall:AddRecalled(nPlayerId, tbInfo)
	local tbList = self:GetRecalledList();
	tbList[nPlayerId] = tbInfo;
	Client:SetFlag("Act_FriendRecallList", tbList)
	UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_RECALL_COUNT);
	UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_RECALL_LIST);
	me.CenterMsg(XT("召回成功"));
end

function FriendRecall:DoClientRecall(tbInfo)
	if not self:IsInProcess() then
		return
	end

	if not self:RecordLastShare(tbInfo) then
		return
	end

	local szType = ""
	if Sdk:IsLoginByQQ() then
		szType = "QQ"
	elseif Sdk:IsLoginByWeixin() then
		szType = "WX"
	end

	self.tbLastShare.szShareType = szType

	local szTitle = self.RecallDesc[tbInfo.nType].szTitle
	local szDesc = self.RecallDesc[tbInfo.nType].szDesc

	Sdk:ShareUrl(szType, szTitle, szDesc)
end

function FriendRecall:DoServerRecall(tbInfo)
	if not self:IsInProcess() then
		return
	end

	if not self:RecordLastShare(tbInfo) then
		return
	end

	local szType = ""
	if Sdk:IsLoginByQQ() then
		szType = "QQ"
	elseif Sdk:IsLoginByWeixin() then
		szType = "WX"
	end

	self.tbLastShare.szShareType = szType

	RemoteServer.OnCallFriendRecall("DoServerRecall", tbInfo.szAccount, tbInfo.nType)
end

function FriendRecall:RecordLastShare(tbInfo)
	if self.tbLastShare then
		me.CenterMsg(XT("分享失败，请时候再试"));
		return false;
	end

	self.tbLastShare = tbInfo;

	self.tbLastShare.nTimerId = Timer:Register(Env.GAME_FPS * 30, function ()
		self.tbLastShare = nil
	end);

	return true;
end

function FriendRecall:OnClientShareResult(bSucc, szShareType)
	if not self:IsInProcess() then
		return
	end

	if not self.tbLastShare then
		return
	end

	--[[if self.tbLastShare.szShareType ~= szShareType then
		return
	end]]

	local tbLastShare = self.tbLastShare
	if tbLastShare.nTimerId then
		Timer:Close(tbLastShare.nTimerId)
	end

	self.tbLastShare = nil

	if not bSucc then
		return
	end

	self:AddRecalled(tbLastShare.nPlayerId, tbLastShare)

	me.CenterMsg(XT("分享成功"));
end

function FriendRecall:OnServerShareResult(bSucc)
	if not self:IsInProcess() then
		return
	end

	if not self.tbLastShare then
		return
	end

	local tbLastShare = self.tbLastShare
	self.tbLastShare = nil

	if not bSucc then
		return
	end

	self:AddRecalled(tbLastShare.nPlayerId, tbLastShare)

	me.CenterMsg(XT("分享成功"));
end
