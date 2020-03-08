Activity.CollectAndRobClue = Activity.CollectAndRobClue or {}
local tbAct = Activity.CollectAndRobClue
local tbItem = Item:GetClass("CollectAndRobClue");

function tbAct:OnModifyClueCount(nItemId, nAddOrReduceCount, nLogReason, nLogReazon2, tbDebrisData)
	self.tbCacheRecord = self.tbCacheRecord or {};
	table.insert(self.tbCacheRecord, {
		nItemId = nItemId;
		nCount = nAddOrReduceCount;
		nLogReason = nLogReason;
		nLogReazon2 = nLogReazon2;
		})

	Player.tbServerSyncData["ActClueRobMyDebris"] = {tbDebrisData}; 

	if not self.nTimerOnModifyClueCount then
		self.nTimerOnModifyClueCount =  Timer:Register(2, function ()
			self.nTimerOnModifyClueCount = nil

			self:OnDelayModify()
		end)
	end
end

local fnGetWithType = function (nItemId, nCount, nLogReason, nLogReazon2)
	nCount = math.abs(nCount)
	nLogReazon2 = nLogReazon2 or ""
	local tbItemBase = KItem.GetItemBaseProp(nItemId)
	local szDescFormat = tbAct.tbLogWayDesc[nLogReason] or "%s获得了%s:%d"
	return string.format(szDescFormat, nLogReazon2, tbItemBase.szName)
end

local fnGetWithManyItems = function (tbItems, nLogReason, nLogReazon2)
	local szItems = ""
	nLogReazon2 = nLogReazon2 or ""
	for i,v in ipairs(tbItems) do
		local nItemId, nCount = unpack(v)
		local tbItemBase = KItem.GetItemBaseProp(nItemId)
		if szItems == "" then
			szItems = string.format("%s[11adf6]%s[-]%s", szItems, tbItemBase.szName, nCount == 1 and "" or "*" .. nCount)
		else
			szItems = string.format("%s、[11adf6]%s[-]%s", szItems, tbItemBase.szName, nCount == 1 and "" or "*" .. nCount)
		end
	end
	local szDescFormat = tbAct.tbLogWayDesc[nLogReason]
	return string.format(szDescFormat, nLogReazon2, szItems)
end

function tbAct:OnDelayModify()
	local tbCacheRecord = self.tbCacheRecord
	if not tbCacheRecord then
		return
	end
	self.tbCacheRecord = nil 
	--合并一样的获取途径的Reason
	local tbCombieReason = {
		[tbAct.LogWayType_OpenBox] = {};
		[tbAct.LogWayType_AttackNpc] = {};
	}
	local tbOthrer = {}
	for i, v in ipairs(tbCacheRecord) do
		local tbCom = tbCombieReason[v.nLogReason] 
		if tbCom then
			table.insert(tbCom, v)
		else
			table.insert(tbOthrer, v)
		end
	end

	for nLogReason, v in pairs(tbCombieReason) do
		if next(v) then
			local tbItems = {}
			local nLogReazon2;
			for i2,v2 in ipairs(v) do
				table.insert(tbItems, { v2.nItemId, v2.nCount })
				nLogReazon2 = v2.nLogReazon2
			end
			table.insert(tbOthrer, { tbItems = tbItems, nLogReason = nLogReason, nLogReazon2 = nLogReazon2  })
		end
	end

	local tbFlow = Client:GetUserInfo("CollectAndRobClueFlow")

	for i, v in ipairs(tbOthrer) do
		local szMsg;
		if v.nLogReason == tbAct.LogWayType_AttackNpc  or v.nLogReason == tbAct.LogWayType_DialogNpc then 
			v.nLogReazon2 = KNpc.GetNameByTemplateId(v.nLogReazon2)
		elseif v.nLogReason == tbAct.LogWayType_Combine then
			v.nItemId = v.nLogReazon2
			v.nLogReazon2 = "";
			v.nCount = 1;
		elseif v.nLogReason == Env.LogWay_ChooseItem then
			local tbOpenItemBase = KItem.GetItemBaseProp(v.nLogReazon2)
			v.nLogReazon2 = tbOpenItemBase.szName
		end
		
		if v.nLogReason == tbAct.LogWayType_OpenBox or v.nLogReason == tbAct.LogWayType_AttackNpc then
			 szMsg = fnGetWithManyItems(v.tbItems, v.nLogReason, v.nLogReazon2)
		else
			 szMsg = fnGetWithType(v.nItemId, v.nCount, v.nLogReason, v.nLogReazon2)
		end
		table.insert(tbFlow, szMsg)
	end

	if #tbFlow > self.MAX_CLUE_MSG_COUNT then
		table.remove(tbFlow, 1)
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_DATA, "ActClueRobMyDebris");
	Client:SaveUserInfo()
end

function tbAct:GetMyItemListData()
	local tbMyItemList = Player:GetServerSyncData("ActClueRobMyItem")
	if not tbMyItemList then
		Player.tbServerSyncData["ActClueRobMyItem"] = { {} }; --防止多次请求
		RemoteServer.DoRequesActCollectAndRobClue("GetMyItemData")
		tbMyItemList = {};
	end
	local tbMyDebrisList = Player:GetServerSyncData("ActClueRobMyDebris") or {}
	return tbMyDebrisList, tbMyItemList
end

function tbAct:DelOneRoleTarget(dwRoleId, szData, szMsg)
	if szMsg then
		me.CenterMsg(szMsg)
	end

	local tbRobList = Player:GetServerSyncData(szData) 
	if not tbRobList then
		return
	end
	for i,v in ipairs(tbRobList) do
		if v == dwRoleId then
			table.remove(tbRobList, i)
			break;
		end
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_DATA, szData);
end

function tbAct:GetRobList(bManuRequest)
	local tbRobList, tbStrangersInfo = Player:GetServerSyncData("ActClueRobList") 
	local nNow = GetTime() 
	local bRequest = false;
	if not tbRobList  or not self.nLastRequestRobListTime or (bManuRequest and nNow - self.nLastRequestRobListTime >= tbAct.RequestRobListInterval)  then
		bRequest = true
		Player.tbServerSyncData["ActClueRobList"] = { {} }; 
		self.nLastRequestRobListTime = nNow
		RemoteServer.DoRequesActCollectAndRobClue("GetRobList")
	end
	tbRobList = tbRobList or {}
	tbStrangersInfo = tbStrangersInfo or {}
	return tbRobList, tbStrangersInfo, bRequest
end

function tbAct:GetFriendList(bManuRequest)
	local tbRobList, tbStrangersInfo = Player:GetServerSyncData("ActClueSendList") 
	local nNow = GetTime()
	local bRequest = false;
	if not tbRobList  or not self.nLastRequestSendListTime or (bManuRequest and nNow - self.nLastRequestSendListTime >= tbAct.RequestRobListInterval) then
		bRequest = true;
		Player.tbServerSyncData["ActClueSendList"] = { {} }; 
		self.nLastRequestSendListTime = nNow
		RemoteServer.DoRequesActCollectAndRobClue("GetSendList")
	end
	tbRobList = tbRobList or {}
	tbStrangersInfo = tbStrangersInfo or {}
	return tbRobList, tbStrangersInfo, bRequest
end



function tbAct:RobHim(dwRoleId)
	RemoteServer.DoRequesActCollectAndRobClue("Robhim", dwRoleId)
end

function tbAct:SendHim(dwRoleId, nItemId)
	local nTarItemId = tbItem:GetDerbisCombieTarId(nItemId)
	if not nTarItemId then
		me.CenterMsg("请先选中碎片")
		return
	end
	local tbMyItemList = Player:GetServerSyncData("ActClueRobMyDebris")
	if not tbMyItemList or not tbMyItemList[nItemId] or tbMyItemList[nItemId] == 0 then
		me.CenterMsg("您还没有该碎片")
		return
	end

	RemoteServer.DoRequesActCollectAndRobClue("SendHim", dwRoleId, nItemId)
end

--开打界面时调用
function tbAct:GetMyInfo()
	local tbInfo = Player:GetServerSyncData("ActClueRobMyInfo") 
	if not tbInfo then
		RemoteServer.DoRequesActCollectAndRobClue("RequestMyInfo")
		tbInfo = { nLastRobTime = 0, nRobCount = 0, nCountRobed = 0, nLastSendTime = 0, nSendCount = 0, nGetSendCount = 0, nLastGetDay = 0 }
	else
		local nRefreshDay = Lib:GetLocalDay(GetTime() - self.RefreshTime)
		if Lib:GetLocalDay(tbInfo.nLastRobTime - self.RefreshTime) ~= nRefreshDay then
			tbInfo.nRobCount = 0;
		end
		if Lib:GetLocalDay(tbInfo.nLastSendTime - self.RefreshTime) ~= nRefreshDay then
			tbInfo.nSendCount = 0;
		end
		if tbInfo.nLastGetDay ~= nRefreshDay then
			tbInfo.nGetSendCount = 0;
		end
		
	end
	return tbInfo	
end

function tbAct:GetItemCount(nItemId)
	local tbMyDebrisList, tbMyItemList = self:GetMyItemListData();
	local nCount = tbMyDebrisList[nItemId]
	if nCount then
		return nCount
	end
	nCount = tbMyItemList[nItemId] or 0
	return nCount 
end

function tbAct:TryRefreshRobList()
	local tbList, _, bRequest = self:GetRobList(true)
	if not  bRequest then
		me.CenterMsg("您刷新过快，请稍后再试")
	end
end

function tbAct:TryRefreshSendList()
	local tbList, _, bRequest = self:GetFriendList(true)
	if not bRequest then
		me.CenterMsg("您刷新过快，请稍后再试")
	end
end