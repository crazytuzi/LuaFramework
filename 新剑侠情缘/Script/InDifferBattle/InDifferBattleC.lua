
function InDifferBattle:DoSignUp()
    local bRet, szMsg = self:CanSignUp(me)
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end
    RemoteServer.InDifferBattleSignUp();
end

function InDifferBattle:UnRegisterLevelEvent()
	if PlayerEvent.nRegisterIdOnLevelUp then
		PlayerEvent:UnRegisterGlobal("OnLevelUp", PlayerEvent.nRegisterIdOnLevelUp)
		PlayerEvent.nRegisterIdOnLevelUp = nil;
	end
end

function InDifferBattle:UnRegisterOnCloseToNpcEnent()
	if PlayerEvent.nRegisterIdOnCloseToNpc then
		PlayerEvent:UnRegisterGlobal("OnCloseToNpc", PlayerEvent.nRegisterIdOnCloseToNpc)
		PlayerEvent.nRegisterIdOnCloseToNpc = nil;
	end
end

function InDifferBattle:EnterFightMap(szBattleType, nState, nTime, tbFactions, tbChoosedFactions, tbTeamRoomInfo, tbServerPlayerInfo)
	Ui:ClearRedPointNotify("IndifferMapRed")
	self.tbTeamRoomInfo = tbTeamRoomInfo
	self.nSynClientDataVersion = 0;
	self.tbRoomNpcDmgInfo = {};
	self.nLastGetRoomNpcDmgInfo = 0;
	self.tbDeadTeamIds = {};
	self.tbTeamReportInfo = {};
	self.szBattleType = szBattleType
	self.tbServerPlayerInfo = tbServerPlayerInfo

	InDifferBattle:GetRooomPosSetting(self.szBattleType)
	local tbRoomIndex, tbSettingGroup = InDifferBattle:GetSettingTypeField(self.szBattleType, "tbRoomIndex") 
	self.tbSettingGroup = tbSettingGroup

	self:SetClientLeftTime(nState, nTime)

	if not self.bRegistNotofy then
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self.OnEnterNewMap, self)  --进新的非战场图， 正常离开或重连超时时
		UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveCurMap, self)  --离开战场图  返回登录时
		UiNotify:RegistNotify(UiNotify.emNOTIFY_SET_PLAYER_NAME, self.OnSetPlayerName, self)  --同步设置玩家名字时
		self.bRegistNotofy = true;
	end

	self.tbChoosedFactions = tbChoosedFactions --[dwRoleId] = nFaction ,0是未选择

	self.tbCanUseRoomIndex = Lib:CopyTB(tbRoomIndex)

	if self:IsJueDiVersion() then
		Ui:OpenWindow("DreamlandDangerInfoPanel")
	else
		Ui:OpenWindow("DreamlandInfoPanel")
	end
	if nState == 1 then
		self:UnRegisterOnCloseToNpcEnent()
		Ui:OpenWindow("DreamlandPanel", tbFactions) 
	end	

	InDifferBattle:UnRegisterLevelEvent()
	AutoFight:ChangeState(AutoFight.OperationType.Auto, true);
	self:UpdateClientNpcShow()
end

function InDifferBattle:OnSynChooseFactionInfo(tbChoosedFactions)
	self.tbChoosedFactions = tbChoosedFactions    --[dwRoleId] = nFaction

	UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_FACTION)
end


function InDifferBattle:OnEnterNewMap(nMapTemplateId)
	self:OnCloseBattleMap();
end

function InDifferBattle:OnLeaveCurMap(nMapTemplateId)
	self:OnCloseBattleMap();
end

function InDifferBattle:OnSetPlayerName(nNpcId)
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc then
		return
	end
	if pNpc.dwTeamID == TeamMgr:GetTeamId() then --自己的 npc teamId 被OnSyncClientPlayer清掉了
		return
	end
	pNpc.SetName("神秘人");
end

function InDifferBattle:ResetDefaultPlayerEventLevel()
	if not PlayerEvent.nRegisterIdOnLevelUp then
		PlayerEvent.nRegisterIdOnLevelUp= PlayerEvent:RegisterGlobal("OnLevelUp",     PlayerEvent.OnLevelUp, PlayerEvent);	
	end
	
end

function InDifferBattle:ResetDefaultPlayerEventCloseNpc()
	if not PlayerEvent.nRegisterIdOnCloseToNpc then
		PlayerEvent.nRegisterIdOnCloseToNpc= PlayerEvent:RegisterGlobal("OnCloseToNpc",     PlayerEvent.OnCloseToNpc, PlayerEvent);	
	end
end

function InDifferBattle:OnCloseBattleMap()
	self:ClearClinetNpc()
	ChatMgr:LeaveCurChatRoom()
	Ui:ChangeUiState(0, true)
	if self.bRegistNotofy then
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_ENTER, self)
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_MAP_LEAVE, self)
		UiNotify:UnRegistNotify(UiNotify.emNOTIFY_SET_PLAYER_NAME, self)
		self:ResetDefaultPlayerEventCloseNpc()
		self:ResetDefaultPlayerEventLevel()

		self.bRegistNotofy = nil;
	end

	Ui:CloseWindow("DreamlandInfoPanel")
	Ui:CloseWindow("ChatLargePanel")
	Ui:CloseWindow("DreamlandPanel") 
	Ui:CloseWindow("DreamlandGivePanel")
	Ui:CloseWindow("DreamlandDangerInfoPanel")
	Ui:CloseWindow("DreamlandDangerMapPanel")

	Operation:EnableWalking()

	if self.nTimerLeftTime then
		Timer:Close(self.nTimerLeftTime)
		self.nTimerLeftTime = nil;
	end

	self.nLeftTeamNum = nil;
	self.tbServerPlayerInfo = nil;
	self.tbDeadTeamIds = nil;
	self.nLastGetRoomNpcDmgInfo = nil;
	self.dwAliveMemberNpcId = nil;
	self.nSynClientDataVersion = nil;
	self.tbCurSingleNpcRoomIndex = nil;
	self.tbCanUseRoomIndex = nil;
	self.tbChoosedFactions = nil;
	self.tbTeamRoomInfo = nil;
	self.tbReadyCloseRoomIndex = nil;
	self.bMyIsDeath = nil;
	self.tbRoomNpcDmgInfo = nil;
	self.tbTeamReportInfo = nil;
	self.dwWinnerTeam = nil;
	self.tbTeamMemberInfos = nil;
	self.szBattleType = nil;
	self.tbSettingGroup = nil
	self.nCurFreshMonsterRooomIndex = nil;
end

function InDifferBattle:SetClientLeftTime(nState, nTime)
	if not self.tbSettingGroup then
		return
	end
	self.nState = nState
	if not nTime then
		nTime = self.tbSettingGroup.STATE_TRANS[self.nState].nSeconds
		--客户端一些切状态时候的操作
		Ui:CloseWindow("ChatLargePanel")
		Ui:CloseWindow("DreamlandPanel") 
		local tbCurTrans = self.tbSettingGroup.STATE_TRANS[nState]
		if tbCurTrans.szBeginNotify then
			Dialog:SendBlackBoardMsg(me, tbCurTrans.szBeginNotify)
			me.Msg(tbCurTrans.szBeginNotify)
		end
		if nState == 2 then
			Ui:OpenWindow("HomeScreenBattle")
		end
		if nState == 3 or nState == 5 or nState == 7 then
			Ui:SetRedPointNotify("IndifferMapRed")
		end
	end
	self.nLeftTime = nTime
	UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI)

	if self.nTimerLeftTime then
		Timer:Close(self.nTimerLeftTime)
	end
	self.nTimerLeftTime = Timer:Register(Env.GAME_FPS * 1, function ( )
		self.nLeftTime = self.nLeftTime - 1;
		if self.nLeftTime <= 0 then
			self.nState = self.nState + 1;
			UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI)
			local tbNextTrans = self.tbSettingGroup.STATE_TRANS[self.nState]
			if not tbNextTrans then
				self.nState = self.nState - 1;--这样ui显示不会变
				self.nTimerLeftTime = nil
				return false
			end
			self.nLeftTime = tbNextTrans.nSeconds
		end

		local tbActiveTransClient = self.tbSettingGroup.tbActiveTransClient
		if tbActiveTransClient then
			local tbTrans = tbActiveTransClient[self.nState]
			if tbTrans then
				local tbTransFunc = tbTrans[self.nLeftTime]
				if tbTransFunc then
					Lib:CallBack({ self[tbTransFunc.szFunc], self, unpack( tbTransFunc.tbParam )})
				end
			end	
		end

		return true
	end)
end

function InDifferBattle:OnBroatcastStartState( nState )
	if nState == 2 then --先简单写吧
		self:ResetDefaultPlayerEventCloseNpc()
	end
end

function InDifferBattle:SynRoomReadyCloseInfo(tbReadyCloseRoomIndex)
	self.tbReadyCloseRoomIndex = tbReadyCloseRoomIndex
	self:CheckNotSafeRoom()
end

function InDifferBattle:SynTeamRoomInfo(tbTeamRoomInfo, bStopMove)
	local nOldMyRoomIndex = self:GetMyRoomIndex()
	self.tbTeamRoomInfo = tbTeamRoomInfo
	
	if bStopMove then
		local fnCheckWhenSwithRooom = self.fnCheckWhenSwithRooom
		self.fnCheckWhenSwithRooom = nil;
		if fnCheckWhenSwithRooom then
			fnCheckWhenSwithRooom()
		else
			if not self:IsJueDiVersion() then
				AutoFight:StopGoto();
				AutoAI.SetTargetIndex(0);
				Operation:StopMoveNow()
			end
		end
	end
	
	if self.bMyIsDeath and self.dwAliveMemberNpcId then
		AutoFight:StartFollowTeammate(self.dwAliveMemberNpcId);
	end
	self:CheckNotSafeRoom() ;--先执行上面的 fnCheckWhenSwithRooom 更新下数据
	self.tbRoomNpcDmgInfo = {}; --换房间后本房间的npc伤害信息清掉,本来换了房间看别的npc也应该是重新请求的
	self:UpdateClientNpcShow(nOldMyRoomIndex)
end

function InDifferBattle:GetMyRoomIndex()
	local tbTeamRoomInfo = InDifferBattle.tbTeamRoomInfo or {}
	return tbTeamRoomInfo[me.dwID]
end

function InDifferBattle:AddClinetNpc(nTemplateId, x,y, nDir)
	if not self.tbAddClientNpcIds then
		self.tbAddClientNpcIds = {};
	end
	nDir = nDir or 64
	local pNpc = KNpc.Add(nTemplateId, 1, 0, me.nMapId, x, y, 0, nDir)
	if not pNpc then
		return
	end
	table.insert(self.tbAddClientNpcIds, pNpc.nId)
end

function InDifferBattle:ClearClinetNpc(tbIgoreDelNpc)
	if not self.tbAddClientNpcIds then
		return
	end
	tbIgoreDelNpc = tbIgoreDelNpc or {};
	local tbLeftNpcs = {};
	for i,v in ipairs(self.tbAddClientNpcIds) do
		if not tbIgoreDelNpc[v] then
			local pNpc = KNpc.GetById(v)
			if pNpc then
				pNpc.Delete()
			end
		else
			table.insert(tbLeftNpcs, v)
		end
		
	end
	self.tbAddClientNpcIds = tbLeftNpcs;
end

function InDifferBattle:UpdateClientNpcShow(nOldMyRoomIndex)
	if not self:IsJueDiVersion() then
		return
	end

	local nNowRoomIndex = self:GetMyRoomIndex()
	if nNowRoomIndex == nOldMyRoomIndex then
		return
	end

	local tbSettingGroup = self.tbSettingGroup
	local tbRoomIndex = tbSettingGroup.tbRoomIndex
	local tbRooomPosSetting = tbSettingGroup.tbRooomPosSetting
	local nRow,nCol = unpack(tbRoomIndex[nNowRoomIndex])
	local tbPosInfo = tbRooomPosSetting[nRow][nCol]
	local tbPosName = { "L", "R", "B","T" }

	local tbGateNpcDirection = tbSettingGroup.tbGateNpcDirection

	local tbReadyToAddNpc = {}
	local tbRowColModify = self.tbDefine.tbRowColModify
	local tbGateNpcGapDistance = tbSettingGroup.tbGateNpcGapDistance
	for _, szPosName in ipairs(tbPosName) do
		local x, y = unpack(tbPosInfo[szPosName]) 		
		--根据隔壁房间是否有瘴气决定npcId
		local tbModify = tbRowColModify[szPosName]
		local nRowM, nColM = unpack(tbModify)
		local nTarRoomIndex = InDifferBattle:GetRoomIndexByRowCol(self.szBattleType, nRow + nRowM, nCol + nColM)
		if nTarRoomIndex then
			local nTemplateId = tbSettingGroup.nSafeGateNpcId
			if not self.tbCanUseRoomIndex[nTarRoomIndex] or nTarRoomIndex == InDifferBattle.nCurFreshMonsterRooomIndex then
				nTemplateId = tbSettingGroup.nUnSafeGateNpcId
			end
			local tbGap = tbGateNpcGapDistance[szPosName]
			for _,v2 in ipairs(tbGap) do
				local xd,yd = unpack(v2)
				local xReal,yReal = x + xd, y + yd
				tbReadyToAddNpc[xReal] = tbReadyToAddNpc[xReal] or {};
				tbReadyToAddNpc[xReal][yReal] = {nTemplateId, tbGateNpcDirection[szPosName]}
			end
		end
	end

	local tbIgoreDelNpc = {};
	if self.tbAddClientNpcIds then
		for i,v in ipairs(self.tbAddClientNpcIds) do
			local pNpc = KNpc.GetById(v)
			if pNpc then
				local _,x,y = pNpc.GetWorldPos()
				if tbReadyToAddNpc[x] and tbReadyToAddNpc[x][y] and tbReadyToAddNpc[x][y][1] == pNpc.nTemplateId then
					tbIgoreDelNpc[v] = 1;
					tbReadyToAddNpc[x][y] = nil;
				end
			end
		end	
	end

	self:ClearClinetNpc(tbIgoreDelNpc)
	for x,v1 in pairs(tbReadyToAddNpc) do
		for y,v2 in pairs(v1) do
			local nTemplateId, nDir = unpack(v2)
			self:AddClinetNpc(nTemplateId, x,y, nDir)
		end
	end
end

function InDifferBattle:SynRoomOpenInfo(tbCanUseRoomIndex, nCurFreshMonsterRooomIndex)
	self.tbCanUseRoomIndex = tbCanUseRoomIndex
	self.nCurFreshMonsterRooomIndex = nCurFreshMonsterRooomIndex
	self:UpdateClientNpcShow();
	self:CheckNotSafeRoom()
	UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI, "room")
end

function InDifferBattle:SynSingleNpcRoomInfo(tbCurSingleNpcRoomIndex, nSynClientDataVersion)
	self.nSynClientDataVersion = nSynClientDataVersion;
	self.tbCurSingleNpcRoomIndex = tbCurSingleNpcRoomIndex
	UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI, "room")
end

function InDifferBattle:SynNpcDmgInfo(nRoomIndex, tbNpcDmgInfo)
	self.tbRoomNpcDmgInfo[nRoomIndex] = tbNpcDmgInfo;
	local tbRankList = self:GetRoomNpcDmgInfo(nRoomIndex)
	if  tbRankList then
		UiNotify.OnNotify(UiNotify.emNOTIFY_DMG_RANK_UPDATE, tbRankList)
	end
end

function InDifferBattle:GetRoomNpcDmgInfo(nRoomIndex)
	local tbNpcDmgInfo = self.tbRoomNpcDmgInfo[nRoomIndex]
	if not tbNpcDmgInfo then
		return
	end
	
	local tbRankList = {}
	local dwMyTeamId = TeamMgr:GetTeamId()
	for i,v in ipairs(tbNpcDmgInfo) do
		local szName = dwMyTeamId == v.nTeamId and "已方队伍" or "神秘人队伍"
		table.insert(tbRankList, {szName, v.nPercent * 100})
	end
	table.sort( tbRankList, function ( a, b )
		return a[2] > b[2]
	end )
	return tbRankList
end

function InDifferBattle:GetCurRoomNpcDmgInfo(nRoomIndex)
	local nNow = GetTime();
	if self.nLastGetRoomNpcDmgInfo + 5 <= nNow then
		return 
	end
	self.nLastGetRoomNpcDmgInfo = nNow
	return self:GetRoomNpcDmgInfo(nRoomIndex)
end

function InDifferBattle:OnGameDeath(dwAliveMemberNpcId)
	self.bMyIsDeath = true;
	
	Operation:DisableWalking()
	UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI)

	self.dwAliveMemberNpcId = dwAliveMemberNpcId
	if dwAliveMemberNpcId then
		AutoFight:StartFollowTeammate(dwAliveMemberNpcId);
	end
	self:OnMemberGameDeath(me.dwID)
	Ui:OpenWindow("DreamlandReportPanel")
end

function InDifferBattle:OnMemberGameDeath(dwMemberId)
	self.tbDeadTeamIds[dwMemberId] = 1;
	if not self.tbTeamMemberInfos then --有人死后就缓存下吧，因为死亡后玩家可以离开，还是把队伍信息保存在心魔里，这样可以查看战报
		self.tbTeamMemberInfos = {}
		local tbMembers = TeamMgr:GetTeamMember();
		for i,v in ipairs(tbMembers) do
			self.tbTeamMemberInfos[i] = v;
		end
	end

	local nDeadNum = 0;
	for k,v in pairs(self.tbDeadTeamIds) do
		nDeadNum = nDeadNum + 1
	end
	local nAllMember = 0
	for k,v in pairs(self.tbTeamRoomInfo) do
		nAllMember = nAllMember + 1
	end
	if nDeadNum >= nAllMember then
		Ui:OpenWindow("DreamlandReportPanel")
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE)
end

function InDifferBattle:IsPlayerDeath(dwRoleId)
	if not self.bRegistNotofy then
		return
	end
	return self.tbDeadTeamIds[dwRoleId] 
end

function InDifferBattle:IsInDangerRoom()
	if self:IsJueDiVersion() then
		local nMyRoomIndex = self.tbTeamRoomInfo[me.dwID]
		if not self.tbCanUseRoomIndex[nMyRoomIndex] or nMyRoomIndex == self.nCurFreshMonsterRooomIndex then
			return "ZhongDongJingGao"
		end
	else
		if self.tbReadyCloseRoomIndex and  self.tbReadyCloseRoomIndex[self.tbTeamRoomInfo[me.dwID]] then
			return "canxiejinggao"
		end
	end
end

function InDifferBattle:IsJueDiVersion()
	return self.szBattleType == "JueDi" or  (self.szBattleType and self.tbBattleTypeSetting[self.szBattleType].szPreferType == "JueDi") 
end

function InDifferBattle:CheckNotSafeRoom()
	local szWarnEffect = self:IsInDangerRoom()
	if szWarnEffect then
		UiNotify.OnNotify(UiNotify.emNOTIFY_CHANG_ROLE_WARN, szWarnEffect)
		if not self:IsJueDiVersion() then
			Dialog:SendBlackBoardMsg(me, string.format( self.nState == 7 and "此区域将在%d秒后坍塌，请前往1号区域" or "此区域将在%d秒后坍塌，请迅速离开", self.nLeftTime));
		end
	else
		UiNotify.OnNotify(UiNotify.emNOTIFY_CHANG_ROLE_WARN, false)
		
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI, "room")
end


function InDifferBattle:ShowRoomCloseEffect()
	if not self:IsInDangerRoom() then
		return
	end

	local nRoomIndex = self.tbTeamRoomInfo[me.dwID]
	local tbRooomPosSet = InDifferBattle:GetRooomPosSetByType(self.szBattleType)
	local nX, nY = unpack(tbRooomPosSet[nRoomIndex]["center"]) 
	me.GetNpc().CastSkill(self.tbDefine.nCloseRoomSkillId, 1, nX, nY)
end

function InDifferBattle:GetMemberRoomIndex(dwRoleId)
	local nRoomIndex = self.tbTeamRoomInfo[dwRoleId]
	if not nRoomIndex then
		nRoomIndex = self.tbTeamRoomInfo[0] --初始默认房间
	end
	return nRoomIndex or 0;
end

function InDifferBattle:OnGiveMoneySuc()
	me.CenterMsg("勾玉赠送成功")
	Ui:OpenWindow("DreamlandGivePanel")
end

function InDifferBattle:OnBuyShopWareSuc(tbCurSellWares, nNpcId )
	me.CenterMsg("购买成功")
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SHOP_WARE, tbCurSellWares, nNpcId)
end

function InDifferBattle:UpDateItemBagCount(tbServerPlayerInfo)
	self.tbServerPlayerInfo = tbServerPlayerInfo;
	me.CenterMsg("行囊替换成功")
	UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI, "ItemList")
end

function InDifferBattle:OnLevelUpItemSuc(szType, ...)
	local tbArgs =  {...}
	if szType == "Strengthen" then
		local tbEquipPos, nNextLevel, nIndex = unpack(tbArgs)
		for i, nEquipPos in ipairs(tbEquipPos) do
			Strengthen:OnResponse(true, nil, nEquipPos, nNextLevel)
		end
		local tbInfo = self.tbDefine.tbEnhanceScroll[nIndex] 
		local szMsg = string.format("%s成功强化至+%d", tbInfo.szDesc, nNextLevel) 
		Dialog:SendBlackBoardMsg(me, szMsg)
	elseif szType == "StrengthenAll" then
		local nNextLevel = unpack(tbArgs)
		for nEquipPos = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do
			Strengthen:OnResponse(true, nil, nEquipPos, nNextLevel)
		end
		Dialog:SendBlackBoardMsg(me, string.format("全身成功强化至+%d", nNextLevel))
	elseif szType == "HorseUpgrade" then
		local szMsg = "「乌云踏雪」成功进阶为「追影」"
		Dialog:SendBlackBoardMsg(me, szMsg)
	elseif szType == "BookUpgrade" then
		local nOldItem, nNewItemId = unpack(tbArgs)
		local tbItemBase1 = KItem.GetItemBaseProp(nOldItem)
		local tbItemBase2 = KItem.GetItemBaseProp(nNewItemId)
		local szMsg = string.format("「%s」成功进阶为「%s」", tbItemBase1.szName, tbItemBase2.szName)
		Dialog:SendBlackBoardMsg(me, szMsg)
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI, "DreamlandLevelUpPanel")
end

function InDifferBattle:DropBuff(nPosX, nPosY)
    local tbDropInfo = { tbUserDef = {{nObjID = -1, szTitle = ""}} }
    me.DropItemInPos(nPosX, nPosY, tbDropInfo)
end

function InDifferBattle:UseItem(nItemId)
	local pItem = me.GetItemInBag(nItemId)
	if not pItem then
		me.CenterMsg("道具不存在")
		return
	end
	if not self.bRegistNotofy then
		me.CenterMsg("已不在活动内")
		return
	end
	RemoteServer.InDifferBattleRequestInst("UseItem", nItemId);
end

function InDifferBattle:SellItem(nItemId)
	local pItem = me.GetItemInBag(nItemId)
	if not pItem then
		me.CenterMsg("道具不存在")
		return
	end
	if not self.bRegistNotofy then
		me.CenterMsg("已不在活动内")
		return
	end
	RemoteServer.InDifferBattleRequestInst("SellItem", nItemId);
end

function InDifferBattle:IsShowHomeScreenDmgBtn()
	local tbTeamRoomInfo = self.tbTeamRoomInfo
	if not tbTeamRoomInfo then
		return
	end
	local tbCurSingleNpcRoomIndex = self.tbCurSingleNpcRoomIndex
	if not tbCurSingleNpcRoomIndex then
		return
	end

	local nMyRoomIndex = tbTeamRoomInfo[me.dwID]
	for nRoomIndex, nNpcTemplateId in pairs(tbCurSingleNpcRoomIndex) do
		if nRoomIndex == nMyRoomIndex then
			local tbNpcInfo = self.tbSettingGroup.tbSingleRoomNpc[nNpcTemplateId]
			if tbNpcInfo and tbNpcInfo.szDropAwardList then
				return nRoomIndex, nNpcTemplateId;
			end
			return
		end
	end
end

function InDifferBattle:CheckOpenIsShowHomeScreenDmgBtn()
	local nRoomIndex, nNpcTemplateId = self:IsShowHomeScreenDmgBtn()
	if not nRoomIndex then
		return
	end

	local szName = KNpc.GetNameByTemplateId(nNpcTemplateId)
	local tbDmg = self:GetCurRoomNpcDmgInfo(nRoomIndex)
	local tbNpcInfo = self.tbSettingGroup.tbSingleRoomNpc[nNpcTemplateId]
	local szDmgUiTips = tbNpcInfo.bBoss and self.tbDefine.szDmgUiTipsBoss or InDifferBattle.tbDefine.szDmgUiTips
	Ui:OpenWindow("BossLeaderOutputPanel", "InDifferBattle", szName, szDmgUiTips, tbDmg)
end

function InDifferBattle:OnSynBattleScoreInfo(tbTeamReportInfo, dwWinnerTeam)
	self.tbTeamReportInfo = tbTeamReportInfo
	self.dwWinnerTeam = dwWinnerTeam
	UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI, "BattleScore")
end

function InDifferBattle:OnSynWinTeam(dwWinnerTeam)
	self.dwWinnerTeam = dwWinnerTeam
	Ui:OpenWindow("DreamlandReportPanel")
end

function InDifferBattle:IsDeathInBattle()
	if self.bRegistNotofy and self.bMyIsDeath then
		me.CenterMsg("当前状态不能操作")
		return true
	end
end

function InDifferBattle:GotoTeamateRoom(tbTeammate)
	local nRoomIndexMe = self.tbTeamRoomInfo[me.dwID]
	local nRoomIndexHim = self.tbTeamRoomInfo[tbTeammate.nPlayerID]
	if nRoomIndexMe == nRoomIndexHim then
		return
	end
	
	if self:IsJueDiVersion() then
		self:_StartAutoGotoRoom2(nRoomIndexHim, true)
	else
		self:_StartAutoGotoRoom(nRoomIndexHim, true)	
	end	

	return true
end

function InDifferBattle:_StartAutoGotoRoom2(nRoomIndex, bClear)
	self.fnCheckWhenSwithRooom = nil;
	local nRoomIndexMe = self.tbTeamRoomInfo[me.dwID]
	if nRoomIndexMe == nRoomIndex then --同房间
		return
	end

	if bClear then
		self.nAutoPathTarRoomIndex = nRoomIndex
	end
	
	local tbRoomIndex = self.tbSettingGroup.tbRoomIndex
	local rowMe, colMe = unpack(tbRoomIndex[nRoomIndexMe])
	local rowTar,colTar = unpack(tbRoomIndex[nRoomIndex])
	local rowNext, colNext = rowMe, colMe
	if rowTar ~= rowMe then
		local nAdd = math.floor(  (rowTar - rowMe) / math.abs(rowTar - rowMe)  )
		rowNext = rowMe + nAdd
	elseif colTar ~= colMe then
		local nAdd = math.floor(  (colTar - colMe) / math.abs(colTar - colMe)  )
		colNext = colMe + nAdd
	else
		return
	end



	self.fnCheckWhenSwithRooom = function ( )
		if self.tbTeamRoomInfo[me.dwID] ~= nRoomIndex then 
			self:_StartAutoGotoRoom2(nRoomIndex)
		else
			self.nAutoPathTarRoomIndex = nil;
		end
	end
	local tbRooomPosSet = InDifferBattle:GetRooomPosSetByType(InDifferBattle.szBattleType)
	local nTarRoomIndex = InDifferBattle:GetRoomIndexByRowCol(self.szBattleType, rowNext, colNext)
	local nPosX, nPosY =  unpack(tbRooomPosSet[nTarRoomIndex]["center"])  
	Operation:ClickMapIgnore(nPosX, nPosY, true);
end

--TODO 现在的寻路算法是不能针对6*6的
function InDifferBattle:_StartAutoGotoRoom(nRoomIndex, bClear)
	self.fnCheckWhenSwithRooom = nil;
	local nRoomIndexMe = self.tbTeamRoomInfo[me.dwID]
	if nRoomIndexMe == nRoomIndex then --同房间
		return
	end

	if not self.tbCanUseRoomIndex[nRoomIndex] then --不可到达
		return
	end
	local tbRoomIndex = self.tbSettingGroup.tbRoomIndex
	local xMe, yMe = unpack(tbRoomIndex[nRoomIndexMe])

	--已走过的格子会设上不能走防止来回走2个格子，第一次寻路时才传bClear
	if not self.tbAutoPathGrid or bClear then
		local tbGrird = {}
		for i=1,5 do
			tbGrird[i] = {}
		end
		for _nRoomIndex, v in pairs(self.tbCanUseRoomIndex) do
			local row, col = unpack(tbRoomIndex[_nRoomIndex])
			tbGrird[row][col] = 1;
		end
		self.tbAutoPathGrid = tbGrird;	
		self.nAutoPathTarRoomIndex = nRoomIndex
		self.tbMoveedPath = {}; --如果取的路径失败，则把除了首位置的都禁掉
		table.insert(self.tbMoveedPath, {xMe, yMe})		
	end
	

	local xTar, yTar = unpack(tbRoomIndex[nRoomIndex])
	local nMinusX, nMinusY = self:GetAutoPathTowradPos(xTar, yTar, xMe, yMe)
	if nMinusX then
		table.insert(self.tbMoveedPath, {xMe + nMinusX, yMe + nMinusY})
	else
		for i,v in ipairs(self.tbMoveedPath) do
			local row, col = unpack(v)
			self.tbAutoPathGrid[row][col] = 2;
		end
		nMinusX, nMinusY = self:GetAutoPathTowradPos(xTar, yTar, xMe, yMe)
	end
	assert(nMinusX)
	--走到目标房间的 门的npc位置处
	local szTarPosName;
	for k, v in pairs(self.tbDefine.tbGateDirectionModify) do
		local nRow, nCol = unpack(v) ; 
		if nMinusX == nRow and nMinusY == nCol then
			szTarPosName = k;
			break;
		end
	end
	local tbRooomPosSet = InDifferBattle:GetRooomPosSetByType(self.szBattleType)
	local nPosX,nPosY = unpack(tbRooomPosSet[nRoomIndexMe][szTarPosName])
	
	self.fnCheckWhenSwithRooom = function ( )
		if self.tbTeamRoomInfo[me.dwID] ~= nRoomIndex then 
			self:_StartAutoGotoRoom(nRoomIndex)
		else
			self.nAutoPathTarRoomIndex = nil;
		end
	end
	
	Operation:ClickMapIgnore(nPosX, nPosY, true);
end

function InDifferBattle:GetAutoPathTowradPos(xTar, yTar, xMe, yMe)
	local x = xTar - xMe
	local y = yTar - yMe
	if x ~= 0 then
		x = math.floor( math.abs(x) / x)
		local xTemp = xMe + x
		if self.tbAutoPathGrid[xTemp][yMe] then --目标是可移动的格子
			-- return x, 0
		else
			--目标不可移动，就 当前轴方向不移动，另一轴方向强制向中心33移动
			--还得设置当前格子已经不能走,这样不至于下次寻路的时候又走回去了
			self.tbAutoPathGrid[xMe][yMe] = nil;
			x = 0;
			if y == 0 then
				y = 3 - yMe
				y = math.floor( math.abs(y) / y)
				if not self.tbAutoPathGrid[xMe][yMe + y] then
					y = 0
				end	
			end
			
		end
	end
	if y ~= 0 then
		y = math.floor( math.abs(y) / y)
		local yTemp = yMe + y
		if self.tbAutoPathGrid[xMe][yTemp] then 
			-- return 0, y
		else
			self.tbAutoPathGrid[xMe][yMe] = nil;
			y = 0;
			if x == 0 then
				x = 3 - xMe
				x = math.floor( math.abs(x) / x)
				if not self.tbAutoPathGrid[xMe + x][yMe] then
					x = 0
				end	
			end
			
		end
	end


	--处理过目标是否可移动的情况，如果有非0 应该是可以直接向目标移动的
	if x ~= 0 and y ~= 0  then
		if self.tbAutoPathGrid[x +xMe][yMe] == 2 then
			return  0, y
		else
			return x, 0
		end
	end

	if x ~= 0 then
		return x, 0;
	elseif y ~= 0 then
		return 0, y;
	end
end


function InDifferBattle:GetItemBagContainCount()
	local nNowItemBagNpcId = InDifferBattle.tbServerPlayerInfo.nNowItemBagNpcId
	if not nNowItemBagNpcId then
		return 0;
	end
	local tbItemBagLNpcGridCount = InDifferBattle:GetSettingTypeField(self.szBattleType, "tbItemBagLNpcGridCount")
	if not tbItemBagLNpcGridCount then
		return 0;
	end
	local tbInfo = tbItemBagLNpcGridCount[nNowItemBagNpcId]
	if not tbInfo then
		return 0;
	end
	return tbInfo.nCount
end

function InDifferBattle:GetOnlySafeRoomIndex()
	if  InDifferBattle.tbReadyCloseRoomIndex  then
		local tbOnlySafeRoom = {};
		for k,v in pairs(InDifferBattle.tbCanUseRoomIndex) do
			if not InDifferBattle.tbReadyCloseRoomIndex[k] then
				table.insert(tbOnlySafeRoom, k)
			end
		end
		if #tbOnlySafeRoom > 0 and #tbOnlySafeRoom < 36 then
			return 	tbOnlySafeRoom
		end
	end
end

function InDifferBattle:UpdateLeftTeamNum( nLeftTeamNum )
	self.nLeftTeamNum = nLeftTeamNum
	UiNotify.OnNotify(UiNotify.emNOTIFY_INDIFFER_BATTLE_UI, "LeftTeamNum")
end

function InDifferBattle:CheckAfterChangeFaction()
	InDifferBattle:CheckNotSafeRoom()
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ACTION_MODE) --更新技能界面的打坐按钮
end

function InDifferBattle:GetCanSingupBattleType()
	--先简单写吧
	for i=#InDifferBattle.tbBattleTypeList,1,-1 do
		local szBattleType = InDifferBattle.tbBattleTypeList[i]
		local tbSetting = InDifferBattle.tbBattleTypeSetting[szBattleType]
		if tbSetting.szCalenddayKey and Calendar:IsActivityInOpenState(tbSetting.szCalenddayKey)  then
			return szBattleType
		end
	end
end

function InDifferBattle:CheckGatherItemBagCountClient(pNpc)
	return InDifferBattle:CheckGatherItemBagCount(me, pNpc.nTemplateId, self.tbServerPlayerInfo, true)
end

function InDifferBattle:CheckChangePlayerFactionFightByNpcClient(pNpc)
	local szName = pNpc.szName
	local szFaction = string.match(szName, "(.*)门派之力")
	if not szFaction then
		return
	end
	local nFaction = Faction:GetFactionIdByName(szFaction)
	if not nFaction then
		return
	end
	if nFaction == me.nFaction then
		return
	end
	return true
end

function InDifferBattle:CheckCanGatherEnhanceClient(pNpc)
	return InDifferBattle:CheckCanGatherEnhance(me, pNpc.nTemplateId, true)
end

function InDifferBattle:CheckGatherSkillBookClinet(pNpc)
	return InDifferBattle:CheckGatherSkillBook(me, pNpc.nTemplateId, true)
end

function InDifferBattle:CheckGatherHorseEquipClinet( pNpc )
	return 	InDifferBattle:CheckGatherHorseEquip(me, pNpc.nTemplateId, true)
end

function InDifferBattle:CheckCanUseTarNpc(pNpc)
	local tbNpcIdToCheckFuctionClient = InDifferBattle.tbBattleTypeSetting.JueDi.tbNpcIdToCheckFuctionClient
	local szFunc = tbNpcIdToCheckFuctionClient[pNpc.nTemplateId]
	if not szFunc then
		return true
	end
	local bRet,_,szConfirmMsg = self[szFunc](self, pNpc)
	if not bRet or szConfirmMsg then
		return
	end
	return  true
end

