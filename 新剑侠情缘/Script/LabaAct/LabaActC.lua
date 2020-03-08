local tbAct = Activity.LabaAct
tbAct.tbLabaData = tbAct.tbLabaData or {}
tbAct.tbAssistData = tbAct.tbAssistData or {}
tbAct.tbNeedAssistFriend = tbAct.tbNeedAssistFriend or {}
--[[
	local tbSaveData = self.tbLabaData
	tbSaveData.tbMaterial = {[nId] = nCount}   		-- 拥有材料
	tbSaveData.tbCommitMaterial = {[nId] = nCount}  -- 已经提交的材料
	tbSaveData.nComposeCount = 0 					-- 已经合成的次数
	tbSaveData.nComposeUpdateTime = nNowTime 		-- 合成次数更新时间
	tbSaveData.nExchangeCount = 0 					-- 已经交换的次数
	tbSaveData.nExchangeUpdateTime = nNowTime		-- 交换次数更新时间

	local tbData = self.tbAssistData
	tbData[dwID] = tbData[dwID] or {}
	tbData[dwID].szName = pStayInfo.szName
	tbData[dwID].tbLack = {{nId = nId, nHave = nHave}}

	self.tbNeedAssistFriend[nFriendId] = true
]]
local emPLAYER_STATE_NORMAL = 2 --正常在线状态
function tbAct:GetMaterialData()
	return self.tbLabaData
end

function tbAct:OnLogin()
	self.tbLabaData = {}
	self.tbAssistData = {}
	self.tbNeedAssistFriend = {}
end

function tbAct:RequestMaterialData()
	RemoteServer.LabaActClientCall("SynMaterialData")
end

function tbAct:OnSynMaterialData(tbData)
	self:FormatData(self.tbLabaData, tbData)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_LABA_ACT_MATERIAL_DATA)
end

function tbAct:GetNeedAssistFriendData()
	return self.tbNeedAssistFriend
end

function tbAct:RequestNeedAssistFriendData()
	RemoteServer.LabaActClientCall("SynAssistFriend")
end

function tbAct:OnSynNeedAssistFriend(tbData)
	self.tbNeedAssistFriend = tbData
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_LABA_ACT_FRIEND_DATA)
	Ui:CloseWindow("LabaFestivalPanel")
end

function tbAct:RequestPlayerAssistData(dwID, nId, nComposeCount)
	RemoteServer.LabaActClientCall("SynAssistData", dwID, nId, nComposeCount)
end

function tbAct:OnSynAssistData(tbData, dwID, nShowId, nComposeCount)
	self:FormatData(self.tbAssistData, tbData)
	if Ui:WindowVisible("LabaFestivalAssistPanel") == 1 then
		UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_LABA_ACT_ASSIST_DATA, self.tbAssistData[dwID], nShowId, nComposeCount)
	else
		Ui:OpenWindow("LabaFestivalAssistPanel", self.tbAssistData[dwID], nShowId, nComposeCount)
	end
	Ui:CloseWindow("LabaFestivalFriendPanel")
end

function tbAct:FormatData(tbCache, tbData)
	for k,v in pairs(tbData or {}) do
		tbCache[k] = v
	end
end

function tbAct:GetShowMaterial()
	local tbData = self:GetMaterialData()
	local tbMaterial = tbData.tbMaterial or {}
	local tbCommitMaterial = tbData.tbCommitMaterial or {}
	local nComposeCount = tbData.nComposeCount or 0
	local nComposeUpdateTime = tbData.nComposeUpdateTime or 0

	local bTodayFinish = nComposeCount >= self.nMaxComposeCount and (not Lib:IsDiffDay(self.nComposeReset, nComposeUpdateTime))
	local tbUncommitMaterial = {}
	if bTodayFinish then
		tbUncommitMaterial = self.tbMaterial
	else
		for nId, v in ipairs(self.tbMaterial) do
			local bCommit = (tbCommitMaterial[nId] or 0) >= self.nComposeNeed 
			if not bCommit then
				tbUncommitMaterial[nId] = v
			end
		end
	end
	local tbShowMaterial = {}
	for nId in pairs(tbUncommitMaterial) do
		table.insert(tbShowMaterial, {nId = nId})
	end
	Lib:SortTable(tbShowMaterial, function (a, b) return a.nId < b.nId end)
	return tbShowMaterial
end

function tbAct:GetAllFriend()
	local tbNeedAssistFriend = self:GetNeedAssistFriendData()
	local tbAllFriend = Lib:CopyTB(FriendShip:GetAllFriendData() or {})
	for i = #tbAllFriend, 1, -1 do
		if tbAllFriend[i].nState ~= emPLAYER_STATE_NORMAL then
			table.remove(tbAllFriend, i)
		end
	end
	for _, v in ipairs(tbAllFriend) do
		v.nNeedAssist = tbNeedAssistFriend[v.dwID] and 1 or 0
	end

	table.sort(tbAllFriend, function (a,b) 
			if a.nNeedAssist == b.nNeedAssist then
				return a.nImity > b.nImity
			end
			return a.nNeedAssist > b.nNeedAssist
		end)
	return tbAllFriend
end

function tbAct:GetCanExchangeMaterial()
	local tbMaterialData = tbAct:GetMaterialData()
	local tbMaterial = tbMaterialData.tbMaterial or {}
	local tbExchange = {}
	for nId, nHave in pairs(tbMaterial) do
		if nHave > 0 then
			table.insert(tbExchange, {nId = nId, nHave = nHave})
		end
	end
	return tbExchange, tbMaterialData.nExchangeCount
end

function tbAct:OnUseLabaMenu()
	Ui:OpenWindow("LabaFestivalPanel")
	Ui:CloseWindow("ItemBox")
end

function tbAct:OnDetail()
	Activity:OpenActUi("LabaAct")
end

-- 最新消息
local tbLabaAct = Activity:GetUiSetting("LabaAct")

tbLabaAct.nShowLevel = tbAct.nJoinLevel
tbLabaAct.szTitle    = "腊八节活动";

tbLabaAct.FuncContent = function (tbData)
        local tbTime1 = os.date("*t", tbData.nStartTime)
        local tbTime2 = os.date("*t", tbData.nEndTime)
        local szContent = [[
     腊八节腊八粥活动开始了！
     	活动期间每日活跃宝箱或每日礼包中可以找到[11adf6][url=openwnd:食材箱, ItemTips, "Item", nil, 7395][-]，食材箱打开后有机会获得不同食材。大侠们会在过程中发现[11adf6][url=openwnd:腊八粥食谱, ItemTips, "Item", nil, 7398][-]，根据食谱制作腊八粥。
     另外，[FFFE0D]1月13日[-]~[FFFE0D]1月16日[-]期间每天每晚[FFFE0D]19:30[-]~[FFFE0D]23:30[-]都能拿到奸商囤积粮食的线索，届时各大家族[FFFE0D]族长[-]或[FFFE0D]副族长[-]召集尽量多家族成员通过[FFFE0D]家族总管[-]指引进入奸商地窖中，打败奸商的走狗，夺得[11adf6][url=openwnd:食材箱, ItemTips, "Item", nil, 7395][-]，一并打开做成腊八粥送往[FFFE0D][url=npc:刘云, 91, 15][-]将军处。
     如大侠在过程中缺少某种食材，可以请亲密度[FFFE0D]10[-]级以上的好友帮自己提交；实在没有办法，去临安城找[FFFE0D][url=npc:刘云, 91, 15][-]将军，他可以帮忙周转
     每天最多制作[FFFE0D]2[-]份[11adf6][url=openwnd:腊八粥, ItemTips, "Item", nil, 7399][-]，活动期间最多完成[FFFE0D]10[-]次任务。
     大侠每赠送一份[11adf6][url=openwnd:腊八粥, ItemTips, "Item", nil, 7399][-]都会获得来自前线将士的回礼，提交满[FFFE0D]5[-]份或者[FFFE0D]10[-]份[11adf6][url=openwnd:腊八粥, ItemTips, "Item", nil, 7399][-]时还会获得额外奖励。
     	]]
        return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day,tbTime1.hour, tbTime2.month, tbTime2.day,tbTime2.hour, szContent)
end