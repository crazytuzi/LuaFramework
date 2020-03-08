local tbAct = Activity.AnniversaryJiYuAct or {}
local tbUi = Ui:CreateClass("FloatingWindowDisplay")
tbAct.tbQuickUseItemClass = {
	["AnniversaryJiYuActDrink"] = true,
	["KongmingLantern"]			= true,
}
function tbAct:GotoWriteJiYu()
	AutoPath:AutoPathToNpc(self.WRITE_JIYU_NPC_ID, self.tbWriteJiYuPos[1])
end

function tbAct:GotoSubmitMaterial()
	Ui:CloseWindow("ItemBox")
	Ui:CloseWindow("ItemTips")
	AutoPath:AutoPathToNpc(self.DRINK_ALTAR_NPC_ID, self.tbAltarPos[1], self.tbAltarPos[2], self.tbAltarPos[3])
end

function tbAct:GotoDrink(bNotSimpleTap)
	--领酒的时候需要寻路过去并点击NPC，喝酒的时候不需要点击NPC
	Ui:CloseWindow("ItemBox")
	Ui:CloseWindow("ItemTips")
	AutoPath:AutoPathToNpc(self.DRINK_ALTAR_NPC_ID, self.tbAltarPos[1], self.tbAltarPos[2], self.tbAltarPos[3], bNotSimpleTap)
end

function tbAct:GotoFlyLantern()
	Ui:CloseWindow("ItemBox")
	Ui:CloseWindow("ItemTips")
	AutoPath:AutoPathToNpc(self.DRINK_ALTAR_NPC_ID, self.tbAltarPos[1], self.tbAltarPos[2], self.tbAltarPos[3], false)
end

function tbAct:OnStartDrinkBanquet()
	--感叹号
	local tbMsgData = {}
	tbMsgData.szType = "AnniversaryJiYuAct"
	tbMsgData.nTimeOut = GetTime() + self.MSG_TIME_OUT
	Ui:SynNotifyMsg(tbMsgData)
	self:StartCheckCloseToNpc()

end

function tbAct:OnEndDrinkBanquet()
	self:StopCheckCloseToNpc()
end

function tbAct:StartCheckCloseToNpc(bReconnect)
	self.bInRange = false
	if not bReconnect then
		UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_ITEM, self.CheckHasCanQuickUseItem, self)
	end
	if self.nCheckTimer then
		Timer:Close(self.nCheckTimer)
		self.nCheckTimer = nil
	end
	if self.nStopTimer then
		Timer:Close(self.nStopTimer)
		self.nStopTimer = nil
	end
	self.nCheckTimer = Timer:Register(1 * Env.GAME_FPS, self.CheckCloseToNpc, self)
	local nNow = GetTime()
	local nEndTime = Lib:GetTodayZeroHour() + Lib:ParseTodayTime(self.tbActiveTime[2])
	self.nStopTimer = Timer:Register((nEndTime - nNow) * Env.GAME_FPS, self.StopCheckTimer, self)
end

function tbAct:CheckIsInRange()
	local nMapId = me.nMapId
	if nMapId ~= self.tbAltarPos[1] then
		return false
	end
	local pMeNpc = me.GetNpc()
	local nDrinkNpcId = AutoAI.GetNpcIdByTemplateId(self.DRINK_ALTAR_NPC_ID)
	if not nDrinkNpcId then
		return false
	end
	local pNpc = KNpc.GetById(nDrinkNpcId)
	if not pNpc then
		return false
	end
	if pMeNpc.GetDistance(nDrinkNpcId) > self.DISTANCE_RANGE then
		return false
	end
	return true
end

function tbAct:CheckCloseToNpc()
	local bInRange = self:CheckIsInRange()
	if bInRange ~= self.bInRange then 		--状态切换
		if bInRange then	--原来不在范围内，现在在范围内，打开窗口
			local tbItemId = self:GetQuickUseItemIdInBag()
			if next(tbItemId) then
				for _, tbItem in ipairs(tbItemId) do
					local nItemId = tbItem[1]
					local nCount = tbItem[2]
					for i = 1, nCount do
						table.insert(tbUi.tbShowQueue, nItemId)
					end
				end
				Ui:OpenWindow("FloatingWindowDisplay", tbItemId[1][1])
			end
		else				--原来在范围内，现在不在范围内，关闭窗口
			tbUi.tbShowQueue = {}
			Ui:CloseWindow("FloatingWindowDisplay")
		end
		self.bInRange = bInRange
	end
	return true
end

function tbAct:CheckHasCanQuickUseItem(nItemId, bNew, nNumber)
	if not Login.bEnterGame then
		return
	end
	if not self:CheckIsInRange() then
		return
	end
	local pItem = me.GetItemInBag(nItemId)
	if not pItem then
		return
	end
	if not self.tbQuickUseItemClass[pItem.szClass] then
		return
	end
	if bNew or nNumber ~= 0 then
		if nNumber <= 0 then --消耗了道具
			tbUi:HaveUse(nItemId)
		else 				 --增加了道具
			for i = 1, nNumber do
				table.insert(tbUi.tbShowQueue, nItemId)
			end
			Ui:OpenWindow("FloatingWindowDisplay", nItemId)
		end
	end
end

function tbAct:StopCheckCloseToNpc()
	if self.nCheckTimer then
		Timer:Close(self.nCheckTimer)
		self.nCheckTimer = nil
	end
	if self.nStopTimer then
		Timer:Close(self.nStopTimer)
		self.nStopTimer = nil
	end
	UiNotify:UnRegistNotify(Ui.emNOTIFY_SYNC_ITEM, self)
end

function tbAct:StopCheckTimer()
	if self.nCheckTimer then
		Timer:Close(self.nCheckTimer)
		self.nCheckTimer = nil
	end
	self.nStopTimer = nil
end

function tbAct:GetQuickUseItemIdInBag()
	local tbItemId = {}
	for szItemClass, _ in pairs(self.tbQuickUseItemClass) do
		local tbItems = me.FindItemInPlayer(szItemClass)
		if next(tbItems) then
			for _, pItem in ipairs(tbItems) do
				table.insert(tbItemId, {pItem.dwId, pItem.nCount})
			end
		end
	end
	return tbItemId
end


function tbAct:CommitJiYu(szJiYu, szOldJiYu)
	if szJiYu == szOldJiYu then
		me.CenterMsg("寄语内容没有发生修改")
		return
	end
	local bRet, szMsg = self:CheckJiYuLimit(szJiYu)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	RemoteServer.AnniversaryJiYuActClientCall("RequestChangeJiYu", szJiYu)
end

function tbAct:OnSyncMyData(tbData)
	self.tbMyData = tbData or {}
	self.tbPlayerData = {}
end

function tbAct:OnSetJiYu(tbData)
	local szMsg = "提交成功"
	if self.tbMyData and self.tbMyData.szJiYu then
		szMsg = "修改成功"
	end
	self.tbMyData = tbData or {}
	me.CenterMsg(szMsg)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_ANNIVERSARYJIYU_DATA)
end

function tbAct:OnBeThumbsUp(tbData)
	me.CenterMsg("有人给你的寄语点赞了哦", true)
	self.tbMyData = tbData or {}
end

function tbAct:ReadPlayerJiYu(nPlayerId)
	if nPlayerId == me.dwID then
		Ui:OpenWindow("AnniversaryJiYuWritePanel", nPlayerId)
		return
	end
	self.tbPlayerData = self.tbPlayerData or {}
	if self.tbPlayerData[nPlayerId] then
		if self.tbPlayerData[nPlayerId].nLastUpdateTime and GetTime() - self.tbPlayerData[nPlayerId].nLastUpdateTime <= 30 then
			--请求服务器刷新的间隔设为30秒，30秒内直接使用客户端缓存数据打开
			Ui:OpenWindow("AnniversaryJiYuWritePanel", nPlayerId)
			return
		end
	end
	RemoteServer.AnniversaryJiYuActClientCall("ReadPlayerJiYu", nPlayerId)
end

function tbAct:OnReadPlayerJiYu(nPlayerId, tbData)
	if not tbData or not next(tbData) or not tbData.szJiYu or Lib:IsEmptyStr(tbData.szJiYu) then
		me.CenterMsg("暂时不能查看该玩家的寄语")
		return
	end
	self.tbPlayerData[nPlayerId] = tbData
	self.tbPlayerData[nPlayerId].nLastUpdateTime = GetTime()
	Ui:OpenWindow("AnniversaryJiYuWritePanel", nPlayerId)
end

function tbAct:GetPlayerData(nPlayerId)
	if nPlayerId == me.dwID then
		self.tbMyData = self.tbMyData or {}
		return self.tbMyData
	end
	return self.tbPlayerData[nPlayerId]
end

function tbAct:OnThumbsUp(nGetId)
	local tbData = self:GetPlayerData(nGetId)
	if tbData then
		tbData.nScore = (tbData.nScore or 0) + self.SCORE_ADD
	end
	me.CenterMsg(string.format("点赞成功，愿力值增加%d点！", self.SCORE_ADD))
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_ANNIVERSARYJIYU_DATA)
end

function tbAct:GetFriendJiYuList()
	self.tbFriendJiYuList = self.tbFriendJiYuList or {}
	local nCD = #self.tbFriendJiYuList < 12 and 60 * 3 or 60 * 60 * 2 		--UI能显示的最大数目是12(没满3分钟更新一次，满了两小时更新一次)
	if not self.nRequestTime or GetTime() - self.nRequestTime >= nCD then
		self.nRequestTime = GetTime()
		RemoteServer.AnniversaryJiYuActClientCall("ReqFriendJiYuList")
	end
	return self.tbFriendJiYuList
end

function tbAct:OnSyncFriendJiYuList(tbList)
	self.tbFriendJiYuList = tbList
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_ANNIVERSARYJIYU_DATA, true)
end