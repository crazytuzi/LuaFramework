local tbUi = Ui:CreateClass("ReunionTaskPanel")
function tbUi:OnOpen()
	local tbFriendState = {}
	for nPlayerId, tbInfo in pairs(Reunion.tbMyData.tbRelation or {}) do
		local tbFriendInfo = FriendShip:GetFriendDataInfo(nPlayerId)
		local bOnline = tbFriendInfo and tbFriendInfo.nState == 2
		table.insert(tbFriendState, {nPlayerId, bOnline and 1 or 0})
	end
	self.pPanel:SetActive("Main", #tbFriendState > 0)
	if #tbFriendState == 0 then
		return
	end
	table.sort(tbFriendState, function (a, b)
		return a[2] > b[2]
	end)
	local tbFriend = {}
	for _, tbInfo in ipairs(tbFriendState) do
		table.insert(tbFriend, tbInfo[1])
	end

	self.nTab = self.nTab or 1
	self.nTab = math.min(self.nTab, #tbFriend)
	self.nCurFriend = tbFriend[self.nTab]
	self.tbState = {}

	for i = 1, Reunion.RELATION_COUNT do
		local tbFriendInfo = tbFriend[i] and FriendShip:GetFriendDataInfo(tbFriend[i])
		self.pPanel:SetActive("RecallItem" .. i, tbFriendInfo or false)
		if tbFriendInfo then
			local pPanel = self["RecallItem" .. i].pPanel
			self.tbState[i] = tbFriendInfo.nState == 2
			pPanel:Label_SetText("Name", tbFriendInfo.szName)
			pPanel:Label_SetText("OnLine", tbFriendInfo.nState == 2 and "状态：在线" or "状态：离线")
			pPanel:SetActive("PlayerTitle", tbFriendInfo.nHonorLevel > 0)
			if tbFriendInfo.nHonorLevel > 0 then
				local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbFriendInfo.nHonorLevel)
				pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas)
			end
			self["RecallItem" .. i]["BtnChat"].pPanel.OnTouchEvent = function ()
				local tbInfo = {
					dwRoleId  = tbFriendInfo.dwID,
					szName    = tbFriendInfo.szName,
					nPortrait = tbFriendInfo.nPortrait,
					nFaction  = tbFriendInfo.nFaction,
					nLevel    = tbFriendInfo.nLevel,
					dwKinId   = tbFriendInfo.nKinId,
				}
				ChatMgr:OpenPrivateWindow(tbInfo.dwRoleId, tbInfo)
			end

			local pItemPanel = self["RecallItem" .. i]["itemframe"].pPanel
			pItemPanel:Label_SetText("lbLevel", tbFriendInfo.nLevel)
			pItemPanel:Label_SetText("SpFaction", Faction:GetIcon(tbFriendInfo.nFaction))
			local szIcon, szAtlas = PlayerPortrait:GetPortraitIcon(tbFriendInfo.nPortrait)
			pItemPanel:Sprite_SetSprite("SpRoleHead", szIcon,szAtlas)
			self["RecallItem" .. i]["itemframe"].pPanel.OnTouchEvent = function ()
				FriendShip:OnChatClickRolePopup(tbFriendInfo.dwID, false)
			end
			pPanel.OnTouchEvent = function ()
				self.nTab = i
				self.nCurFriend = tbFriend[self.nTab]
				self:UpdateTask()
			end
		end
	end

	self.pPanel:SetActive("BtnRecallReport", Reunion.tbMyData.nMyType == Reunion.TYPE_BACK)
	self.pPanel:Label_SetText("TextRecall", Reunion.tbMyData.nMyType == Reunion.TYPE_BACK and "我的向导" or "我的召回")
	self:UpdateTask()
end

function tbUi:UpdateTask()
	local tbData = (Reunion.tbMyData.tbRelation or {})[self.nCurFriend]
	self.pPanel:SetActive("RecallCondition", tbData or false)

	if not tbData then
		return
	end

	for i = 1, Reunion.RELATION_COUNT do
		local szSprite = ""
		if i == self.nTab then
			szSprite = "BtnListThirdPress"
		elseif self.tbState[i] then
			szSprite = "BtnListThirdNormal"
		else
			szSprite = "BtnListThirdDisabled"
		end
		self["RecallItem" .. i].pPanel:Button_SetSprite("Main", szSprite)
	end

	local szTime = Lib:GetTimeStr3(tbData.nRelationTime)
	self.pPanel:Label_SetText("RecallTime", string.format("于%s结为重逢关系", szTime))
	self.pPanel:Label_SetText("EXP", Reunion.tbMyData.nMyType == Reunion.TYPE_GUIDE and "汇报后可得名望（道具）" or "汇报后可得经验")
	local tbComplete = tbData.tbComplete
	local tbActList  = {}
	local nComplete  = 0
	for szAct, tbInfo in pairs(Reunion.TARGET_ACT) do
		if Reunion:CheckTimeFrame(szAct, tbData.nRelationTime) then
			local nSort = 100 - tbInfo.nActId
			if tbComplete[tbInfo.nActId] then
				if not tbComplete[tbInfo.nActId][Reunion.COMPLETE_IDX_FLAG] then
					if tbComplete[tbInfo.nActId][Reunion.COMPLETE_IDX_COUNT] >= tbInfo.nCompleteCount then
						nSort = 1000000 + nSort
						nComplete = nComplete + 1
					else
						nSort = 10000 + nSort
					end
				else
					nComplete = nComplete + 1
				end
			else
				nSort = 10000 + nSort
			end
			table.insert(tbActList, {szAct, nSort})
		end
	end
	table.sort(tbActList, function (a, b)
		return a[2] > b[2]
	end)
	local fnUpdate = function (itemObj, nIdx)
		itemObj.pPanel:SetActive("Chuangong", nIdx == 1)
		itemObj.pPanel:SetActive("Exp", nIdx ~= 1)
		if nIdx == 1 then
			local nChuanGongTimes = 0
			if tbData.nChuanGongDay == Lib:GetLocalDay(GetTime() - Reunion.DAY_ZERO) then
				nChuanGongTimes = tbData.nChuanGongTimes
			end
			local bComplete = nChuanGongTimes >= Reunion.CHUANGONG_TIMES
			local szColor   = bComplete and "[00FF00]" or "[FFFFFF]"
			if not bComplete then
				itemObj.Chuangong.pPanel.OnTouchEvent = function ()
					local fnRequest = function ()
						RemoteServer.ReunionOnClientCall("ApplyChuanGong", self.nCurFriend)
					end
					if ChuangGong:CheckMap() then
						fnRequest()
					else
						ChuangGong:GoSafe(fnRequest)
						Ui:CloseWindow("SocialPanel")
					end
				end
			end
			itemObj.pPanel:Label_SetText("Task", szColor .. "每日传功")
			itemObj.pPanel:SetActive("TxtFinish", false)
			itemObj.pPanel:SetActive("Num", true)
			itemObj.pPanel:Label_SetText("Num", szColor .. string.format("%d/%d", nChuanGongTimes, Reunion.CHUANGONG_TIMES))
			return
		end
		local tbAct = Reunion.TARGET_ACT[tbActList[nIdx - 1][1]]
		local tbActComplete = tbComplete[tbAct.nActId] or {}
		local nCompleteCount = tbActComplete[Reunion.COMPLETE_IDX_COUNT] or 0
		local bComplete = tbActComplete[Reunion.COMPLETE_IDX_FLAG] or nCompleteCount >= tbAct.nCompleteCount
		itemObj.pPanel:SetActive("TxtFinish", tbActComplete[Reunion.COMPLETE_IDX_FLAG] or false)
		itemObj.pPanel:SetActive("Num", not tbActComplete[Reunion.COMPLETE_IDX_FLAG])
		local szColor = "[FFFFFF]"
		if tbActComplete[Reunion.COMPLETE_IDX_FLAG] then
			szColor = "[00FF00]"
		elseif nCompleteCount >= tbAct.nCompleteCount then
			szColor = "[FFFE0D]"
		end
		itemObj.pPanel:Label_SetText("TxtFinish", szColor .. "已汇报")
		if not tbActComplete[Reunion.COMPLETE_IDX_FLAG] then
			local nMaxCount = tbAct.nCompleteCount
			if tbAct.szAct == "ImperialTomb" then
				nCompleteCount = nCompleteCount/60
				nMaxCount = nMaxCount/60
			end
			local szComplete = nCompleteCount >= nMaxCount and "可汇报" or string.format("%d/%d", nCompleteCount, nMaxCount)
			itemObj.pPanel:Label_SetText("Num", szColor .. szComplete)
		end
		itemObj.pPanel:Label_SetText("Task", szColor .. tbAct.szDesc)
		local szAward = ""
		if Reunion.tbMyData.nMyType == Reunion.TYPE_GUIDE then
			if Lib:IsEmptyStr(tbAct.szGuiderExtAward) then
				szAward = tbAct.nGuiderRenown
			else
				local tbAward = Lib:GetAwardFromString(tbAct.szGuiderExtAward)
				szAward = table.concat(Lib:GetAwardDesCount2(tbAward))
			end
		else
			szAward = me.TrueChangeExp(tbAct.nBackerExp * me.GetBaseAwardExp())
		end
		itemObj.pPanel:Label_SetText("Exp", szColor .. szAward)
	end
	self.RecallScrollView:Update(#tbActList + 1, fnUpdate)
	
	local tbFriendInfo = FriendShip:GetFriendDataInfo(self.nCurFriend)
	self.pPanel:Label_SetText("RecallTarget", string.format("与[C8FF00]%s[-]的重逢目标：%d/%d（全完成称号：[aa62fc]再续前缘[-]）", tbFriendInfo.szName, nComplete, Reunion.TARGET_COUNT))

	local nEndTime = tbData.nRelationTime + Reunion.RELATION_TIME
	local szEnd = ""
	if Lib:GetLocalDay(nEndTime) == Lib:GetLocalDay() then
		nEndTime = Lib:GetTodaySec(nEndTime)
		szEnd = string.format("今天[C8FF00]%d点%d分[-]", math.floor(nEndTime/3600), math.floor(nEndTime%3600/60))
	else
		szEnd = (Lib:GetLocalDay(nEndTime) - Lib:GetLocalDay()) .. "天后"
	end
	self.pPanel:Label_SetText("RecallCondition", string.format("重逢关系将于[C8FF00]%s[-]结束", szEnd))
end

function tbUi:Report()
	if self.nCurFriend then
		RemoteServer.ReunionOnClientCall("Report", self.nCurFriend)
	end
end

tbUi.tbOnClick = {
	BtnRecallReport = function (self)
		self:Report()
	end
}