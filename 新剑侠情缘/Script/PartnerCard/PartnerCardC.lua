PartnerCard.tbCardSendData = PartnerCard.tbCardSendData or {} 	-- 门客赠送礼物次数数据
PartnerCard.tbCardHouseData = PartnerCard.tbCardHouseData or {} -- 入住家园门客数据
PartnerCard.tbCardHouseNpcInfo = PartnerCard.tbCardHouseNpcInfo or {} -- 入住家园门客Npc数据
PartnerCard.tbCardVisitNpcTalkInfo = PartnerCard.tbCardVisitNpcTalkInfo or {} -- 入住家园门客Npc数据
PartnerCard.tbDeviCardInfo = PartnerCard.tbDeviCardInfo or {} 			-- 玩家门客入魔数据
PartnerCard.tbNewCard = PartnerCard.tbNewCard or {} 					-- 新获得门客数据
PartnerCard.tbTaskData = PartnerCard.tbTaskData or {} 					-- 任务数据
PartnerCard.tbAcType = PartnerCard.tbAcType or {} 						-- 派遣类型
PartnerCard.tbComposeData = PartnerCard.tbComposeData or {} 			-- 合成数据
--[[
	PartnerCard.tbCardHouseNpcInfo ={[nCardId] = {nNpcId = 0, bShow = true}}
]]
PartnerCard.nCardPosShowLevel = 100

 local tbPartnerCardPickAct = Activity:GetUiSetting("PartnerCardPickAct")

 tbPartnerCardPickAct.nShowLevel = 1
 tbPartnerCardPickAct.szTitle    = "门客招募专场";
 tbPartnerCardPickAct.nBottomAnchor = -50;

 tbPartnerCardPickAct.FuncContent = function (tbData)
         local tbTime1 = os.date("*t", tbData.nStartTime)
         local tbTime2 = os.date("*t", tbData.nEndTime + 1)
         local szContent = "\n      为庆祝门客系统或新的门客位开启，门客系统或新的门客位开启的三天内，每天[FFFE0D]前5次[-]元宝十连抽，为门客专场。\n      活动过后，同伴和门客均有概率产出，产出门客的概率会降低。\n      机不可失，抓紧时间去招募心仪的门客吧。"
         return string.format("活动时间：[c8ff00]%d年%d月%d日%d点-%d月%d日%d点[-]\n%s", tbTime1.year, tbTime1.month, tbTime1.day,tbTime1.hour, tbTime2.month, tbTime2.day,tbTime2.hour, szContent)
 end

function PartnerCard:UpdatePlayerAttributeC()
	PartnerCard:UpdatePlayerAttribute(me)
end

function PartnerCard:GetCardSendTimes(pPlayer, nCardId)
	return PartnerCard.tbCardSendData[nCardId] or 0
end

function PartnerCard:GetCardRemainTimes(nCardId)
	return PartnerCard:GetMaxSendTimes() - PartnerCard:GetCardSendTimes(me, nCardId)
end

function PartnerCard:GetHouseCardData()
	return PartnerCard.tbCardHouseData
end

function PartnerCard:RequestCardGiftData()
	RemoteServer.PartnerCardOnClientCall("SynCardGiftData")
end

function PartnerCard:SendGift(nCardId, nItemId, nCount)
	RemoteServer.PartnerCardOnClientCall("SendGift", nCardId, nItemId, nCount)
end

function PartnerCard:OnSynCardGiftData(tbCardTimes)
	PartnerCard.tbCardSendData = tbCardTimes
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_GIFT_DATA_FINISH);
end

function PartnerCard:OnCardUpGrade()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_UP_GRADE, nil, nil, true)
	PartnerCard:CheckPartnerCardPanelRedPoint()
end

-- 必须上阵满了并且新卡的质量等级在所上阵的门客中不是最低的
function PartnerCard:CheckIsAddNew(nCardId)
	local nQualityLevel = PartnerCard:GetQualityByCardId(nCardId)
	local _, _, _, tbCanUsePos = PartnerCard:GetShowCardPos(me)
	for k,v in pairs(tbCanUsePos) do
		if not next(v) then
			tbCanUsePos[k] = nil
		end
	end
	if next(tbCanUsePos) then
		return true
	end
	local tbCard = self:GetPartnerOnPosCard(me)
	for _, v in pairs(tbCard) do
		for _, j in pairs(v) do
			local nId = j.nCardId
			local nQuality = PartnerCard:GetQualityByCardId(nId)
			if nQualityLevel <= nQuality then
				return true
			end
		end
	end
	return false
end

function PartnerCard:OnAddCard(nCardId, bNotShow)
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_ADD)
	if PartnerCard:CheckIsAddNew(nCardId) then
		PartnerCard.tbNewCard[nCardId] = true
		PartnerCard:CheckPartnerCardPanelRedPoint()
	end
	if not bNotShow then
		Ui:OpenWindow("CompanionShow", nil, 3, nCardId)
	end
end

function PartnerCard:CheckIsNewCard(nCardId)
	return PartnerCard.tbNewCard[nCardId]
end

function PartnerCard:RemoveNewCardFlag(nCardId)
	PartnerCard.tbNewCard[nCardId] = nil
end

function PartnerCard:CheckPartnerCardPanelRedPoint()
	local bShow
	local tbOwnCard = PartnerCard:GetSortOwnPartnerCard()
	for _, v in ipairs(tbOwnCard) do
		local bNew = PartnerCard:CheckIsNewCard(v.nCardId)
		if bNew then
			bShow = true
			break
		end
	end
	if bShow or PartnerCard:CheckRedPoint() then
		Ui:SetRedPointNotify("PartnerCardPanel")
	else
		Ui:ClearRedPointNotify("PartnerCardPanel");
	end
end

function PartnerCard:CheckOpenGuide()
	local nShowOpenGuide = Client:GetFlag("PartnerCardOpenGuide") or 0
	if nShowOpenGuide ~= 1 and self:IsOpen() then
		return true
	end
	return false
end

function PartnerCard:CheckBtnActGuide()
	local nShowGuide = Client:GetFlag("PartnerCardActGuide") or 0
	if nShowGuide ~= 1 and self:IsOpen() then
		return true
	end
	return false
end

function PartnerCard:OnSynCardHouseData(tbData)
	for k, v in pairs(tbData or {}) do
		if type(v) == "string" and v == "nil" then
			self.tbCardHouseData[k] = nil
		else
			self.tbCardHouseData[k] = v
		end
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_SYN_HOUSE_CARD)
end

function PartnerCard:OnGetActAward()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_ACT_AWARD)
end

function PartnerCard:OnActAwardCanGet()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_ACT_AWARD)
end

function PartnerCard:OnEndDecil(nOwnPlayerId, nCardId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_DEVIL_END, nOwnPlayerId, nCardId)
end

function PartnerCard:OnSynDevilCardInfo(tbData)
	PartnerCard.tbDeviCardInfo = tbData
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_SSYN_DEVIL, tbData.nOwnPlayerId, tbData.nCardId)
end

-- 门客心魔操作信息改变
function PartnerCard:OnDevilMsgChange(nOwnPlayerId, nCardId, tbMsg)
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_DEVIL_MSG_CHANGE, nOwnPlayerId, nCardId, tbMsg)
end

-- 门客心魔生命值改变
function PartnerCard:OnDeviLifeChange(nOwnPlayerId, nCardId, nLife)
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_DEVIL_LIFE_CHANGE, nOwnPlayerId, nCardId, nLife)
end

function PartnerCard:GetDevilCardInfo()
	return PartnerCard.tbDeviCardInfo or {}
end

function PartnerCard:OnLiveHouse(nCardId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_UP_GRADE)
end

function PartnerCard:OnLeaveHouse(nCardId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_UP_GRADE)
end

function PartnerCard:OnSynHouseLiveNpcInfo(tbNpcInfo)
	for nCardId, v in pairs(tbNpcInfo or {}) do
		-- 上次说话时间
		local nTalkTime = PartnerCard.tbCardHouseNpcInfo[v.nNpcId] and PartnerCard.tbCardHouseNpcInfo[v.nNpcId].nTalkTime or 0
		PartnerCard.tbCardHouseNpcInfo[v.nNpcId] = {}
		PartnerCard.tbCardHouseNpcInfo[v.nNpcId].nTalkTime = nTalkTime or 0
		PartnerCard.tbCardHouseNpcInfo[v.nNpcId].nCardId = nCardId
		PartnerCard.tbCardHouseNpcInfo[v.nNpcId].bShow = v.bShow
	end
end

function PartnerCard:OnSynHouseVisitNpcInfo(tbPlayerVisit)
	for nVisitId, v in pairs(tbPlayerVisit or {}) do
		for nCardId, j in pairs(v) do
			-- 上次说话时间
			local nTalkTime = PartnerCard.tbCardVisitNpcTalkInfo[j.nNpcId] and PartnerCard.tbCardVisitNpcTalkInfo[j.nNpcId].nTalkTime or 0
			PartnerCard.tbCardVisitNpcTalkInfo[j.nNpcId] = {}
			PartnerCard.tbCardVisitNpcTalkInfo[j.nNpcId].nTalkTime = nTalkTime or 0
			PartnerCard.tbCardVisitNpcTalkInfo[j.nNpcId].nCardId = nCardId or 0
			PartnerCard.tbCardVisitNpcTalkInfo[j.nNpcId].szBubble = j.szBubble
			PartnerCard.tbCardVisitNpcTalkInfo[j.nNpcId].bShow = true 			-- 拜访npc不能隐藏，默认显示
		end
	end
end

function PartnerCard:OnHouseMapEnter()
	self:CloseHouseTalkTimer()
	self:StartHouseTalkTimer()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_ACT_AWARD)
end

function PartnerCard:OnHouseMapLeave()
	self:CloseHouseTalkTimer()
	Ui:CloseWindow("PartnerCardActivityPanel")
end

function PartnerCard:OnHouseMapLogin()
	self:CloseHouseTalkTimer()
	self:StartHouseTalkTimer()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_ACT_AWARD)
end

function PartnerCard:OnAnswerVisitQuestion(bRight, nCardId)
	local tbCardInfo = self:GetCardInfo(nCardId) or {}
	Ui:CloseWindow("PartnerCardQuestionPanel")
	local nDialogId = bRight and PartnerCard.nVisitAnswerRightDialogId or PartnerCard.nVisitAnswerWrongDialogId
	Ui:TryPlaySitutionalDialog(nDialogId, nil, nil, tbCardInfo.nNpcTempleteId)
end

function PartnerCard:StartHouseTalkTimer()
	self.nHouseTalkTimer = Timer:Register(Env.GAME_FPS * PartnerCard.HOUSE_NPC_TALK_INTERVAL, self.DoHouseNpcTalk, self)
end

-- 优先最久没说话的的
function PartnerCard:FilterHouseTalkNpc(tbHouseNpcInfo)
	local tbFilterInfo = {}
	for nNpcId, v in pairs(tbHouseNpcInfo or {}) do
		local pNpc = KNpc.GetById(nNpcId or 0)
		if v.bShow and pNpc then
			table.insert(tbFilterInfo, {nNpcId = nNpcId, nCardId = v.nCardId, pNpc = pNpc, nTalkTime = v.nTalkTime or 0, szBubble = v.szBubble})
		end
	end
	if #tbFilterInfo > 1 then
		table.sort(tbFilterInfo, function(a,b) return a.nTalkTime < b.nTalkTime end)
	end
	return tbFilterInfo
end

function PartnerCard:DoHouseNpcTalk()
	for _, v in ipairs({ {bVisit = true}, {bVisit = false} }) do
		local tbHouseNpcInfo = v.bVisit and PartnerCard.tbCardVisitNpcTalkInfo or PartnerCard.tbCardHouseNpcInfo
		local tbFilterInfo = self:FilterHouseTalkNpc(tbHouseNpcInfo)
		local tbNpcInfo = tbFilterInfo[1]
		if tbNpcInfo then
			local tbBubbleMsg = PartnerCard:GetHouseTalk(tbNpcInfo.nCardId, v.bVisit)
			local szBubbleMsg = (not Lib:IsEmptyStr(tbNpcInfo.szBubble)) and tbNpcInfo.szBubble or (tbBubbleMsg and tbBubbleMsg[MathRandom(#tbBubbleMsg)])
			tbNpcInfo.pNpc.BubbleTalk(szBubbleMsg or PartnerCard.DEFAULT_TALK, PartnerCard.HOUSE_NPC_TALK_TIME)
			if tbHouseNpcInfo[tbNpcInfo.nNpcId] then
				tbHouseNpcInfo[tbNpcInfo.nNpcId].nTalkTime = GetTime()
			end
		end
	end
	
	return true
end

function PartnerCard:CloseHouseTalkTimer()
	if self.nHouseTalkTimer then
		Timer:Close(self.nHouseTalkTimer)
		self.nHouseTalkTimer = nil
	end
end

function PartnerCard:OnUnlockCardPos()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_POS_UNLOCK)
end

function PartnerCard:OnUpPos()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_UP_POS)
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER)
end

function PartnerCard:OnDownPos()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_DWON_POS)
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER)
end

function PartnerCard:GetLiveHouseCard()
	local tbCard = {}
	for nCardId, v in pairs(self.tbCardHouseData) do
		local tbCardInfo = self:GetCardInfo(nCardId)
		if tbCardInfo then
			local tbCardData = Lib:CopyTB(v)
			tbCardData.nCardId = nCardId
			tbCardData.nPartnerTempleteId = tbCardInfo.nPartnerTempleteId
			tbCardData.nLevel = self:GetCardSaveInfo(me, nCardId, PartnerCard.nLevelIdxStep)
			table.insert(tbCard, tbCardData)
		end
	end
	if #tbCard > 1 then
		table.sort(tbCard, function (a,b) return a.nCardId < b.nCardId end)
	end
	return tbCard
end

function PartnerCard:GetSortOwnPartnerCard()
	local tbOwnCard = PartnerCard:GetAllOwnCard(me)
	for i=1, #tbOwnCard do
		local tbCard = tbOwnCard[i]
		tbCard.nSort = 0
		if PartnerCard.tbCardHouseData[tbCard.nCardId] then
			tbCard.nSort = tbCard.nSort + 10000000
		elseif tbCard.nPos > 0 then
			tbCard.nSort = tbCard.nSort + 1000000
		elseif PartnerCard:CheckIsNewCard(tbCard.nCardId) then
			tbCard.nSort = tbCard.nSort + 10000
		end
	end
	Lib:SortTable(tbOwnCard, function (a, b) 
		if a.nSort == b.nSort then
			return a.nFightPower > b.nFightPower
		end
		return a.nSort > b.nSort
	 end)
	
	return tbOwnCard
end

function PartnerCard:GetCanDimissCard()
	local tbOwnCard = self:GetSortOwnPartnerCard(me)
	for i = #tbOwnCard, 1, -1 do
		local bRet = PartnerCard:CanDismissCard(me, tbOwnCard[i].nCardId)
		if not bRet then
			table.remove(tbOwnCard, i)
		end
	end
	return tbOwnCard
end

function PartnerCard:GetArraySortOwnPartnerCard()
	local tbOwnCard = PartnerCard:GetAllOwnCard(me)
	if #tbOwnCard > 1 then
		table.sort(tbOwnCard, function (a, b) 
				local nA, nB, nC, nD = 0, 0, 0, 0
				if a.nPos > 0 then
					nA = nA + 1
				end
				if b.nPos > 0 then
					nB = nB + 1
				end
				if nA == nB then
					if PartnerCard.tbCardHouseData[a.nCardId] then
						nC = nC + 1
					end
					if PartnerCard.tbCardHouseData[b.nCardId] then
						nD = nD + 1
					end
					if nC == nD then
						local nANew = PartnerCard:CheckIsNewCard(a.nCardId) and 1 or 0
						local nBNew = PartnerCard:CheckIsNewCard(b.nCardId) and 1 or 0
						if nANew == nBNew then
							return a.nFightPower > b.nFightPower
						end
						return nANew > nBNew
					end
					return nC > nD
				end
				return nA > nB
			end )
	end
	return tbOwnCard
end

function PartnerCard:GetCardPosRefCardInfo(tbCard)
	local tbCardPos2CardInfo = {}
	for _, v in ipairs(tbCard) do
		if v.nPos > 0 then
			tbCardPos2CardInfo[v.nPos] = v
		end
	end
	return tbCardPos2CardInfo
end

-- 返回配置的第一个道具(显示用)
function PartnerCard:GetAddCardCostItem(nCardId)
	local nItemId 
	local nCount
	local tbCost = PartnerCard:GetAddCardCost(nCardId) or {}
	for _, v in ipairs(tbCost) do
		if v[1] == "item" or v[1] == "Item" then
			nItemId = v[2]
			nCount = v[3]
			break
		end
	end
	return nItemId, nCount
end

function PartnerCard:OnAddCardVisitState()
	Ui:CloseWindow("PartnerCardQuestionPanel")
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_ADD_STATE)
end

function PartnerCard:OnAddCardTripState()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_ADD_STATE)
end

function PartnerCard:OnAddCardMuseState()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_ADD_STATE)
end

function PartnerCard:OnCureDevil(nCureCount, nCureOk)
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_DEVIL_COUNT_CHANGE, nCureCount, nCureOk)
end

function PartnerCard:DoBubbleTalk(nNpcId, szMsg, szTime)
	local pNpc = KNpc.GetById(nNpcId)
	if pNpc then
		pNpc.BubbleTalk(szMsg, szTime)
	end
end

function PartnerCard:OnTripMapNpcDialogEnd(nCardId, nNpcId)
	RemoteServer.PartnerCardOnClientCall("GetTripMapAward", nCardId, nNpcId)
end

function PartnerCard:PlayTripMapNpcDialog(nDialogId, nCardId, nNpcId)
	Ui:TryPlaySitutionalDialog(nDialogId, nil, {self.OnTripMapNpcDialogEnd, self, nCardId, nNpcId})
end

-- 套装属性描述信息
function PartnerCard:GetSuitAttribDesInfo(tbAttribInfo, nCardNamePerLineCount, pPlayerAsync, nPartnerPos, bNotLightCardName)
	local tbAllAttrib = {};
	local nAttribLine = 0
	for _, tbInfo in ipairs(tbAttribInfo) do
		local nAttributeID, nLevel, nSuitIdx = unpack(tbInfo);
		local nActiveCardNum = self:GetSuitActiveCardNum(nSuitIdx, pPlayerAsync, nPartnerPos)
		local nSuitCardNum = #(self.tbSuitCardCombine[nSuitIdx] or {})
		local szSuitName = self.tbCardSuitName[nSuitIdx] or ""
		szSuitName = szSuitName .. string.format("(%d/%d)", nActiveCardNum, nSuitCardNum)
		local tbSuitInfo = {}
		tbSuitInfo.nSuitIdx = nSuitIdx
		tbSuitInfo.szSuitName = szSuitName
		tbSuitInfo.szCardName, tbSuitInfo.tbCardName = self:GetSuitCardName(nSuitIdx, nCardNamePerLineCount, pPlayerAsync, nPartnerPos, bNotLightCardName)
		local tbAttrib = KItem.GetExternAttrib(nAttributeID, nLevel);
		local tbSeqAttrib = {}
		for nSeq, tbMagic in pairs(tbAttrib or {}) do
			local tbInfo = {}
			tbInfo.nSeq = nSeq
			tbInfo.tbMagic = tbMagic
			table.insert(tbSeqAttrib, tbInfo)
		end
		if #tbSeqAttrib > 1 then
			table.sort(tbSeqAttrib, function (a,b) return a.nSeq < b.nSeq end )
		end
		local szDesc = ""
		local tbSuitSetting = self.tbCardSuit[nSuitIdx] or {}
		for nNeedActiveNumIdx, v in ipairs(tbSeqAttrib) do
			local nActiveNum = tbSuitSetting[nNeedActiveNumIdx] and tbSuitSetting[nNeedActiveNumIdx].nActiveNum
			nActiveNum = nActiveNum or 0
			local tbMagic = v.tbMagic
			local szMagicName = tbMagic.szAttribName
			local tbValue = tbMagic.tbValue
			local szInfo, nRow = FightSkill:GetMagicDesc(szMagicName, tbValue);
			if nRow and nRow > 0 then
				szInfo = string.gsub(szInfo, "%+%-", "%+");
				szInfo = string.format("(%s)%s", nActiveNum, szInfo)
				if nActiveCardNum >= nActiveNum then
					szInfo = string.format("[3FF200]%s[-]", szInfo)
				else
					szInfo = string.format("[B4B4B4]%s[-]", szInfo)
				end
				szDesc = szDesc .. szInfo .. "\n";
				nAttribLine = nAttribLine + 1
			end
		end
		tbSuitInfo.szAttribDes = szDesc
		table.insert(tbAllAttrib, tbSuitInfo)
	end
	if #tbAllAttrib > 1 then
		table.sort(tbAllAttrib, function(a,b) return a.nSuitIdx < b.nSuitIdx end)
	end
	return tbAllAttrib, nAttribLine
end

-- 返回同伴位中套装激活最大数量的门客（同伴位1激活3个，同伴位2激活1个，则返回3个）
function PartnerCard:GetSuitActiveCardNum(nSuitIdx, pPlayerAsync, nPartnerPos)
	local tbNum = {}
	local tbCard = self.tbSuitCardCombine[nSuitIdx] or {}
	for _, nCardId in ipairs(tbCard) do
		local nCardPos
		if pPlayerAsync then
			nCardPos = PartnerCard:IsCardUpPosByAsynData(pPlayerAsync, nCardId)
		else
 			nCardPos = PartnerCard:IsCardUpPos(me, nCardId)
		end
		if nCardPos then 
			local nPPos = PartnerCard:GetPartnerPosByCardPos(nCardPos)
			local bActive = (not nPartnerPos or nPartnerPos == nPPos)
			if bActive then
				tbNum[nPPos] = (tbNum[nPPos] or 0) + 1
			end
		end
	end
	local tbSeqNum = {}
	for _, nNum in pairs(tbNum) do
		table.insert(tbSeqNum, {nNum = nNum})
	end
	Lib:SortTable(tbSeqNum, function(a, b) return a.nNum > b.nNum end)
	local nActiveNum = tbSeqNum[1] and tbSeqNum[1].nNum
	return nActiveNum or 0
end

function PartnerCard:GetSuitCardName(nSuitIdx, nPerLineCount, pPlayerAsync, nPartnerPos, bNotLight)
	local tbCardName = {}
	local szSuitCardName = ""
	local tbCard = self.tbSuitCardCombine[nSuitIdx] or {}
	for _, nCardId in ipairs(tbCard) do
		local tbCardInfo = self:GetCardInfo(nCardId) or {}
		local nCardPos
		if pPlayerAsync then
			nCardPos = PartnerCard:IsCardUpPosByAsynData(pPlayerAsync, nCardId)
		else
			nCardPos = PartnerCard:IsCardUpPos(me, nCardId)
		end
		local szCardName = tbCardInfo.szName or ""
		local bActive = false
		if not bNotLight and nCardPos then
			local nPPos = PartnerCard:GetPartnerPosByCardPos(nCardPos)
			bActive = not nPartnerPos or nPPos == nPartnerPos
		end
		szCardName = bActive and string.format("[3FF200]%s[-]", szCardName) or string.format("[B4B4B4]%s[-]", szCardName)
		table.insert(tbCardName, {szCardName = szCardName, nValue = bUpPos and 1 or 0})
	end
	if #tbCardName > 1 then
		table.sort(tbCardName, function (a, b) return a.nValue > b.nValue end )
	end
	for nIdx, v in ipairs(tbCardName) do
		szSuitCardName = szSuitCardName ..v.szCardName
		if nIdx ~= #tbCardName then
			szSuitCardName = szSuitCardName .."   "
			if nPerLineCount then
				if nIdx % nPerLineCount == 0 then
					szSuitCardName = szSuitCardName .."\n"
				end
			end
		end 
	end
	return szSuitCardName, tbCardName
end

-- 额外属性描述
function PartnerCard:GetAttribDesc(tbAttrib)
	local nLine = 0;
	local szDesc = "";
	local tbDesc = {}
	local tbAttribDesc = {}
	local tbSeqAttrib = PartnerCard:FormatAttribSeq(tbAttrib)
	for _, tbInfo in ipairs(tbSeqAttrib) do
		local szType = tbInfo.szType
		local tbValue = tbInfo.tbValue
		local szInfo, nRow = FightSkill:GetMagicDesc(szType, tbValue);
		if nRow and nRow > 0 then
			szInfo = string.gsub(szInfo, "%+%-", "%+");
			szDesc = szDesc .. szInfo .. "\n";
			nLine = nLine + 1;
			table.insert(tbDesc, szInfo)
			tbAttribDesc[szType] = szInfo
		end
	end
	return szDesc, nLine, tbDesc, tbAttribDesc;
end

-- 技能属性描述
function PartnerCard:GetSkillAttribDesc(tbAttrib, szDevide, bDetail)
	local nLine = 0;
	local szDesc = "";
	local tbDesc = {}
	local tbSkill = {}
	local tbUniqSkill = {}
	local tbFlag = {}
	for _, v in ipairs(tbAttrib) do
		local nSkillLevel = v[2]
		local nCardId = v[3]
		local tbUniqueSkill = PartnerCard:GetUniqSkillIdByCardId(nCardId) or {}
		for _, nId in ipairs(tbUniqueSkill) do
			local nOldLevel = tbUniqSkill[nId] or 0
			print(nId, nOldLevel, nSkillLevel)
			tbUniqSkill[nId] = math.max(nOldLevel, nSkillLevel)
		end
	end
	for _, v in ipairs(tbAttrib) do
		local nSkillId = v[1]
		local nSkillLevel = v[2]
		local nCardId = v[3]
		local bNotActive = false
		local nOldSkillLevel = tbSkill[nSkillId]
		if nOldSkillLevel and nSkillLevel < nOldSkillLevel then
			bNotActive = true
		end

		local szCardName = (self:GetCardInfo(nCardId) or {}).szName or ""
		local szSkillDes = self.tbCardSkillDes[nSkillId] or ""
		local tbUniqueSkill = PartnerCard:GetUniqSkillIdByCardId(nCardId) or {}
		for nIndex, nId in ipairs(tbUniqueSkill) do
			local bNotActiveUni = false
			local nMaxSkillLevel = tbUniqSkill[nId] 
			if tbFlag[nId] or (nMaxSkillLevel and nSkillLevel < nMaxSkillLevel) then
				bNotActiveUni = true
			else
				tbFlag[nId] = true
			end
			local szUniqSkillDes = self.tbCardSkillDes[nId] or ""
			local szLine = nIndex == 1 and " | " or " "
			if bDetail then
				szLine = ""
			end
			-- 属性变暗
			if bNotActive or bNotActiveUni then
				szUniqSkillDes = string.format("[B4B4B4]%s[-]", szUniqSkillDes)
			end
			szSkillDes = string.format("%s%s%s", szSkillDes, szLine, szUniqSkillDes) 
			tbUniqSkill[nId] = nSkillLevel
		end
		szSkillDes = string.gsub(szSkillDes, "%%s", szDevide or "\n")
		if bNotActive then
			szSkillDes = string.format("[B4B4B4]%s[-]", szSkillDes)
		end
		table.insert(tbDesc, {szCardName = szCardName, szSkillDes = szSkillDes})
		if not Lib:IsEmptyStr(szSkillDes) then
			szDesc = szDesc ..szSkillDes .. "\n"
			nLine = nLine + 1
		end
		tbSkill[nSkillId] = nSkillLevel
	end
	return szDesc, nLine, tbDesc;
end

function PartnerCard:CheckPartnerGralleryGuide()
	if PartnerCard:IsOpen() then
		Guide:StartGuideById(PartnerCard.nPartnerGralleryGuideId, false, false, true)
	end
end

function PartnerCard:CheckPartnerCardGuide()
	local tbOwnCard = PartnerCard:GetSortOwnPartnerCard()
	if PartnerCard:IsOpen() and next(tbOwnCard) then
		return Guide:StartGuideById(PartnerCard.nPartnerCardGuideId, false, false, true)
	end
	return false
end

function PartnerCard:OnLogin()
	--PartnerCard.tbCardHouseData = {}
	me.tbPartnerCardPosRP = {}
	PartnerCard:CheckRedPoint()
end

function PartnerCard.OnLogout()
	PartnerCard.tbCardHouseData = {}
end

function PartnerCard:OnGoPos(nMapId, nNpcId, nPosX, nPosY)
	local fnEndWalk = function ()
		Operation.SimpleTap(nNpcId);
	end
	AutoPath:GotoAndCall(nMapId, nPosX, nPosY, fnEndWalk);
	Ui:CloseWindow("PartnerCardActivityPanel")
end

function PartnerCard:GoHousePos(nMapId, nPosX, nPosY)
	AutoPath:GotoAndCall(nMapId, nPosX, nPosY);
end

function PartnerCard:OnSynTaskData(tbData)
	PartnerCard.tbTaskData = tbData
end

function PartnerCard:GetTaskCardData()
	return PartnerCard.tbTaskData or {}
end

function PartnerCard:OnSynActData()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_SYN_ACT_DATA)
end

function PartnerCard:OnDimissCard(nCardId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_DISMISS_CARD, nCardId)
	PartnerCard:CheckPartnerCardPanelRedPoint()
end

function PartnerCard:OnDimissCardBatch()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_DISMISS_CARD)
end

function PartnerCard:OnSynActType(tbData)
	PartnerCard.tbAcType = tbData or {}
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_SYN_ACT_DATA)
end

function PartnerCard:GetRandomActTypeData()
	return PartnerCard.tbAcType
end

function PartnerCard:OnSynPickData(nPickCount)
	PartnerCard.nTenGoldPickCount = nPickCount
	UiNotify.OnNotify(UiNotify.emNOTIFY_PARTNER_CARD_SYN_PICK_DATA)
end

function PartnerCard:SortOnPosCard(tbOnPosCard)
	local tbOnPosCardInfo = PartnerCard:GetOnPosCardInfo(me)
	local _, tbActiveSuitCard = PartnerCard:GetOnPosActiveSuitAttrib(tbOnPosCardInfo)
	local tbSortCard = {}
	local tbCardSuitRef = {} 						--	所有已激活套装属性的门客
	for _, v in pairs(tbActiveSuitCard) do
		for nSuitIdx, tbCard in pairs(v) do
			for _, nCardId in ipairs(tbCard) do
				tbCardSuitRef[nCardId] = nSuitIdx
			end
		end
	end
	for nPartnerPos, v in ipairs(tbOnPosCard) do
		tbSortCard[nPartnerPos] = v
		for nIdx, j in pairs(v) do
			local nSuitIdx = tbCardSuitRef[j.nCardId] or 0
			tbSortCard[nPartnerPos][nIdx] = j
			tbSortCard[nPartnerPos][nIdx].nSuitIdx = nSuitIdx
		end
	end

	for _, v in pairs(tbSortCard) do
		Lib:SortTable(v, function (a, b) 
			if a.nSuitIdx == b.nSuitIdx then
				return a.nCardId < b.nCardId
			end
			return a.nSuitIdx > b.nSuitIdx 
		end)
	end
	return tbSortCard
end

function PartnerCard:SortUnLockPos(tbUnlock, nPartnerPos)
	local tbPosInfo = me.GetPartnerPosInfo()
	local nPartnerId = tbPosInfo[nPartnerPos];
	local tbPartner = me.GetPartnerInfo(nPartnerId) or {}
	local nPartnerTempleteId = tbPartner.nTemplateId or 0

	--local tbSortUnLock = {}
	local nSkillCardIndex
	for nIdx, nCardPos in ipairs(tbUnlock) do
		local tbCard = self:IsPosHaveCard(me, nCardPos)
		if tbCard then
			local nCardId = tbCard.nCardId or 0
			local tbCardInfo = self:GetCardInfo(nCardId)
			if tbCardInfo and tbCardInfo.nPartnerTempleteId == nPartnerTempleteId then
				nSkillCardIndex = nIdx
			end
		end
	end
	-- 激活护主技能优先在第一位
	if nSkillCardIndex then
		local nFirstCardPos = tbUnlock[1]
		tbUnlock[1] = tbUnlock[nSkillCardIndex]
		tbUnlock[nSkillCardIndex] = nFirstCardPos
	end
	local tbOnPosCardInfo = PartnerCard:GetOnPosCardInfo(me)
	local _, tbActiveSuitCard = PartnerCard:GetOnPosActiveSuitAttrib(tbOnPosCardInfo)
	local tbCardSuitRef = {} 						--	所有已激活套装属性的门客
	local tbActiveSuitRef = {}
	for _, v in pairs(tbActiveSuitCard) do
		for nSuitIdx, tbCard in pairs(v) do
			for _, nCardId in ipairs(tbCard) do
				tbCardSuitRef[nCardId] = nSuitIdx
				tbActiveSuitRef[nSuitIdx] = true
			end
		end
	end
	-- 第一个不移动。每轮找一个同组合属性
	for nIdx = 1, #tbUnlock do
		local nCurPos = tbUnlock[nIdx]
		local tbCurCard = self:IsPosHaveCard(me, nCurPos)
		if tbCurCard then
			local nCurSuitIdx = tbCardSuitRef[tbCurCard.nCardId]
			for nCompareIdx = nIdx + 1, #tbUnlock do
				local nComparePos = tbUnlock[nCompareIdx]
				local tbCompareCard = self:IsPosHaveCard(me, nComparePos)
				if tbCompareCard then
					local nCompareSuitIdx = tbCardSuitRef[tbCompareCard.nCardId]
					if nCurSuitIdx and nCompareSuitIdx and nCurSuitIdx == nCompareSuitIdx then
						-- 找到同组合的门客放在当前门客的下一个门客位
						local nFianlIdx = nIdx + 1
						local nFinalCardPos = tbUnlock[nFianlIdx]
						tbUnlock[nFianlIdx] = nComparePos
						tbUnlock[nCompareIdx] = nFinalCardPos
						break
					end
				end
			end
		end
		for i,nCardPos in ipairs(tbUnlock) do
			local tbCard = self:IsPosHaveCard(me, nCardPos)
			local szName 
			if tbCard then
				local nCardId = tbCard.nCardId or 0
				local tbCardInfo = self:GetCardInfo(nCardId)
				szName = tbCardInfo.szName
			end
		end
	end
	return tbUnlock, tbCardSuitRef, tbActiveSuitRef
end

function PartnerCard:GetTaskFinshCount()
	local tbTaskData = PartnerCard:GetTaskCardData()
	local tbTaskId = tbTaskData.tbTaskId or {}
	local nUpdateTime = tbTaskData.nUpdateTime or 0
	local nFinishCount = tbTaskData.nFinishTaskIdx or 0
	if not next(tbTaskId) then
		return 0
	end
	if nFinishCount >= #tbTaskId then
		local nUpdateDay = Lib:GetLocalDay(nUpdateTime)
		local nNowDay = Lib:GetLocalDay()
		if nUpdateDay ~= nNowDay then
			nFinishCount = 0 
		end
	end
	return nFinishCount
end

function PartnerCard:IsCompleteTask()
	return PartnerCard:GetTaskFinshCount() == PartnerCard.nAcceptTaskCount
end

function PartnerCard:GetTaskDegreeInfo()
	local nFinishCount = self:GetTaskFinshCount()
	return string.format("次数：%d/%d", math.max(PartnerCard.nAcceptTaskCount - nFinishCount, 0), PartnerCard.nAcceptTaskCount)
end

function PartnerCard:OnFinishTask()
	AutoFight:Stop()
	RemoteServer.GoMyHome();
end

function PartnerCard:GetShowCardAttribDesc(nCardId)
	local nLine = 0
	local tbAttrib = PartnerCard:GetShowCardAttrib(me, nCardId)
	local szSkillAttrib, nSkillAttribLine = PartnerCard:GetSkillAttribDesc(tbAttrib.tbPartnerSkill, nil, true)
	nSkillAttribLine = nSkillAttribLine + 2
	local szPlayerAttrib, nPlayerAttribLine = PartnerCard:GetAttribDesc(PartnerCard:GetAttribInfo(tbAttrib.tbPlayerAttrib))
	nPlayerAttribLine = nPlayerAttribLine + 2
	local tbSuitDesInfo, nSuitAttribLine = PartnerCard:GetSuitAttribDesInfo(tbAttrib.tbSuitAttrib, nil, nil, nil, true)
	nSuitAttribLine = nSuitAttribLine + 2
	local szSuitDes = ""
	for _, v in ipairs(tbSuitDesInfo) do
		szSuitDes = szSuitDes ..string.format("[11ADF6][%s][-]", v.szSuitName) .."\n"
		szSuitDes = szSuitDes .. v.szCardName .."\n"
		szSuitDes = szSuitDes .. v.szAttribDes .."\n"
		nSuitAttribLine = nSuitAttribLine + 3 					-- 加上组合名字1行，组合门客名字1行和一行换行
	end
	nLine = nLine + nPlayerAttribLine + nSuitAttribLine
	szSuitDes = Lib:IsEmptyStr(szSuitDes) and "[B4B4B4]无[-]" or szSuitDes
	local tbAttribDesc = {}
	tbAttribDesc.nLine = nLine
	tbAttribDesc.szSkillAttrib = szSkillAttrib
	tbAttribDesc.szPlayerAttrib = szPlayerAttrib
	tbAttribDesc.szSuitDes = szSuitDes
	return tbAttribDesc
end

function PartnerCard:OnSynComposeData(tbData)
	PartnerCard.tbComposeData = tbData
end

function PartnerCard:GetComposeData()
	return PartnerCard.tbComposeData
end

function PartnerCard:OnGoComposeCard()
	-- 防止被自动开启托管的黑条提示顶掉
	Timer:Register(Env.GAME_FPS, function() 
			Dialog:SendBlackBoardMsg(me, "请找一个合适的位置开始布阵")
		end )
	Ui:CloseWindow("ItemBox")
	Ui:CloseWindow("PartnerCardComposePanel")
end

function PartnerCard:OnApplyComposeCard()
	Ui:CloseWindow("ItemBox")
	Ui:CloseWindow("PartnerCardComposePanel")
end

function PartnerCard:OnFinishComposeCard()
	Ui:CloseWindow("PartnerCardComposePanel")
end

-- 只要同伴位下的所有门客位都开放了并且都没上阵门客则显示红点
function PartnerCard:CheckNewOpenRedPoint(nPartnerPos)
	me.tbPartnerCardPosRP = me.tbPartnerCardPosRP or {}
	if me.tbPartnerCardPosRP[nPartnerPos] then
		return false
	end
	local tbCardPos = self.tbPartnerCardPos[nPartnerPos]
	if not tbCardPos then 
		return false
	end
	local bHadPosOpen = false
	for _, v in ipairs(tbCardPos) do
		local nCardPos = v.nCardPos or 0
		if PartnerCard:IsCardPosUnlock(me, nCardPos) then
			bHadPosOpen = true
			break
		end
	end
	local bAllNotPos = true
	for _, v in ipairs(tbCardPos) do
		local nCardPos = v.nCardPos or 0
		if PartnerCard:IsCardPosUnlock(me, nCardPos) and PartnerCard:IsPosHaveCard(me, nCardPos) then
			bAllNotPos = false
			break
		end
	end
	return bHadPosOpen and bAllNotPos
end

function PartnerCard:CheckRedPoint()
	if not PartnerCard:IsOpen() then
		return
	end
	if me.nLevel < self.nCardPosShowLevel then
		return
	end
	local bRet
	for nPartnerPos = 1, Partner.MAX_PARTNER_POS_COUNT do
		local szPonitKey = "TabRedPoint" ..nPartnerPos
		if PartnerCard:CheckNewOpenRedPoint(nPartnerPos) then
			bRet = true
			Ui:SetRedPointNotify(szPonitKey)
		else
			Ui:ClearRedPointNotify(szPonitKey)
		end
	end
	return bRet
end

function PartnerCard:OnSynLaterCardPosInfo(tbLaterCardPosInfo)
	self.tbLaterCardPosInfo = tbLaterCardPosInfo
end

function PartnerCard:OnLevelUp()
	PartnerCard:CheckRedPoint()
end