

function Player:ChangePkResult(bRet, nPeaceCD)
	print("ChangePkResult", bRet, nPeaceCD)
	me.nPeaceCD = nPeaceCD
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_PK_MODE)
end

function Player:OnFightSkillLevelUp(...)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SKILL_LEVELUP, ...)
end

function Player:OnChangeMoney(...)
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_MONEY, ...)
	--Sdk:OnChangeMoney(...);
end

function Player:SetActiveRunTimeData(szActiveName, tbData)
	self.szActiveName = szActiveName;
	self.tbActiveData = tbData;
	UiNotify.OnNotify(UiNotify.emNOTIFY_ACTIVE_RUNTIME_DATA, szActiveName);
end

function Player:GetActiveRunTimeData()
	return self.szActiveName, self.tbActiveData;
end

--服务端不要用这个接口 频繁调用有性能问题 服务端有特殊的接口用
function Player:GetPlayerMaxLeve()
	return TimeFrame:GetMaxLevel();
end

function Player:UpdateHeadState()
	local pNpc = me.GetNpc();
	if not pNpc then
		return;
	end

	for _, nStateID in pairs(Player.tbHeadStateBuff) do
		if nStateID ~= Player.tbHeadStateBuff.nWaBaoID then
			pNpc.RemoveSkillState(nStateID);
		end
	end

	local tbWaBao = pNpc.GetSkillState(Player.tbHeadStateBuff.nWaBaoID);
	if tbWaBao and tbWaBao.nEndFrame ~= 0 then
		return;
	end

	local nAddStateBuff = 0;
	if AutoFight:IsFollowTeammate() then
		nAddStateBuff = Player.tbHeadStateBuff.nFollowFightID;
	elseif pNpc.nShapeShiftNpcTID == 0 and AutoFight:IsAuto() and me.nFightMode == 1 then
		nAddStateBuff = Player.tbHeadStateBuff.nAutoFightID;
	elseif me.bStartAutoPath then
		nAddStateBuff = Player.tbHeadStateBuff.nAutoPathID;
	end

	if nAddStateBuff > 0 then
		pNpc.AddSkillState(nAddStateBuff, 1, FightSkill.STATE_TIME_TYPE.state_time_normal, Player.HEAD_STATE_TIME, 1, 1);
	end
end

function Player:RemoteServer_Safe(szFunction, ...)
	self.nCallId = (self.nCallId or 0) + 1;
	self.tbSaveCallCache = self.tbSaveCallCache or {}
	table.insert(self.tbSaveCallCache,
	{
		nCallId = self.nCallId,
		szFunction = szFunction,
		tbArg = {...}
	})
	RemoteServer.CallServerSafe(self.nCallId, szFunction, ...)
end

function Player:OnSafeCallRespond(nCallId)
	for nIdx, tbInfo in ipairs(self.tbSaveCallCache) do
		if self.tbSaveCallCache[nIdx].nCallId == nCallId then
			table.remove(self.tbSaveCallCache, nIdx)
			return;
		end
	end
end

function Player:OnLogin_SafeCall(nReconnect)
	if nReconnect == 0 then
		self.tbSaveCallCache = {};
		RemoteServer.ResetCallSafe();
		return;
	else
		for nIdx, tbCall in ipairs(self.tbSaveCallCache or {}) do
			Log("Reconnect ReSend", tbCall.nCallId, tbCall.szFunction)
			RemoteServer.CallServerSafe(tbCall.nCallId, tbCall.szFunction, unpack(tbCall.tbArg))
		end
	end
end

function Player:CheckCanOptEquipPos( nEquipPos )
    return true
end

function Player:ClientUnUseEquip( nEquipPos )
	local pCurEquip = me.GetEquipByPos(nEquipPos)
	if not pCurEquip then
		return
	end
	if not self:CheckCanOptEquipPos(nEquipPos) then
		return
	end

	RemoteServer.UnuseEquip(nEquipPos)
end
function Player:UseEquip(nItemId)
	local pItem = KItem.GetItemObj(nItemId)
	if not pItem then
		return false;
	end

	if pItem.nUseLevel > me.nLevel then
		me.CenterMsg("等级不足，无法装备")
		return false;
	end

	local szClassName = pItem.szClass
	local tbClass = Item.tbClass[szClassName]
	if tbClass and tbClass.OnClientUse then
		local nRetCode = tbClass:OnClientUse(pItem)
		if nRetCode and nRetCode > 0 then
			return
		end
	end
	if not self:CheckCanOptEquipPos(pItem.nEquipPos) then
		return
	end

	RemoteServer.UseEquip(nItemId);
	return true;
end

Player.tbServerSyncData = Player.tbServerSyncData or {};
function Player:ServerSyncData(szType, ...)
	Player.tbServerSyncData[szType] = {...};
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_DATA, szType);
end

function Player:GetServerSyncData(szType)
	local tbInfo = Player.tbServerSyncData[szType];
	if not tbInfo then
		return;
	end

	return unpack(tbInfo);
end

function Player:OnPkExcerciseRequest(szRequestName, nRequestId)
	local fnCallback = function (bResult)
		RemoteServer.PkExcerciseRespond(nRequestId, bResult);
	end
	me.MsgBox(string.format("「%s」请求与您切磋，您是否同意？", szRequestName),
		{
			{"同意", fnCallback, true},
			{"拒绝", fnCallback, false}
		});
end

function Player:OnPkExcerciseState(nState, varValue)
	if nState == self.PK_EXCERCISE_READY then
		Ui:OpenWindow("ReadyGo");
	elseif nState == self.PK_EXCERCISE_GO then
		me.GetNpc().nExcerciseId = varValue;
		local pNpc = KNpc.GetById(varValue);
		if pNpc then
			pNpc.nExcerciseId = me.GetNpc().nId;
		end
	elseif nState == self.PK_EXCERCISE_END then
		if varValue then
			me.CenterMsg(varValue)
		end
		local nExcerciseId = me.GetNpc().nExcerciseId;
		me.GetNpc().nExcerciseId = 0
		local pNpc = KNpc.GetById(nExcerciseId);
		if pNpc then
			pNpc.nExcerciseId = 0;
		end
	end
end

Player.bLevelUpCache = false
function Player:FlyChar(nNewLevel)
	if Map:GetMapType(me.nMapTemplateId) == Map.emMap_Fuben and Kin.Def.nKinMapTemplateId ~= me.nMapTemplateId then
		if nNewLevel then
			self.bLevelUpCache = true
		end
		return
	end

	if not self.bLevelUpCache and not nNewLevel then
		return
	end

	local nMapId, nX, nY = me.GetWorldPos()
	Ui:PlayEffect(9120, nX, nY, 0)
	Ui:OpenWindow("LevelUpPopup", "shengji")

	Timer:Register(Env.GAME_FPS, function ()
		local tbOldAtt  = KPlayer.GetLevelFactionPotency(me.nFaction, me.nLevel - 1)
		local tbNewAtt  = KPlayer.GetLevelFactionPotency(me.nFaction, me.nLevel)
		local tbAttName = { [9] = "Vitality", [10] = "Strength", [11] = "Dexterity", [12] = "Energy" }
		for nType, szName in pairs(tbAttName) do
			local szAttKey = "n" .. szName
			local nAddition = tbNewAtt[szAttKey] - tbOldAtt[szAttKey]
			Timer:Register(Env.GAME_FPS * (nType - 9) * 0.5 + 1, function ()
				me.GetNpc().DoFlyChar(nType, nAddition)
			end)
		end
	end)

	self.bLevelUpCache = false
end

function Player:SynForceOpenTimeFrame(tbTimeFrameForceOpen)
	self.tbTimeFrameForceOpen = tbTimeFrameForceOpen
end

function Player:OnMoneyDebtCost(szType, nCount)
	local szMoneyName = Shop:GetMoneyName(szType) or XT("未知")
	local szMsg = string.format(XT("你自动偿还了%d的%s欠款"), nCount, szMoneyName)
	me.CenterMsg(szMsg)
	me.Msg(szMsg)
	Player:CheckMoneyDebtBuff()
	Player:CheckPrisonState();
end

function Player:OnMoneyDebtAdd(szType, nCount)
	local szMoneyName = Shop:GetMoneyName(szType) or XT("未知")
	local szMsg = string.format(XT("%s余额不足，你欠款剩余%d"), szMoneyName, nCount)
	me.CenterMsg(szMsg)
	me.Msg(szMsg)
	Player:CheckMoneyDebtBuff()
end

function Player:CheckMoneyDebtBuff()
	local pNpc = me.GetNpc();
	if not pNpc then
		return
	end

	local bBuff = false
	for szType,_ in pairs(Shop.tbMoney) do
		if me.GetMoneyDebt(szType) > 0 then
			bBuff = true;
			break;
		end
	end

	if bBuff then
		pNpc.AddSkillState(Shop.MONEY_DEBT_BUFF, 1, 3, 2000000000, 1, 1);
	else
		pNpc.RemoveSkillState(Shop.MONEY_DEBT_BUFF)
	end
end

function Player:GetMoneyDebtDesc()
	local szMsg = "";
	for szType,_ in pairs(Shop.tbMoney) do
		local nDebt = me.GetMoneyDebt(szType)
		if nDebt > 0 then
			local szMoneyName = Shop:GetMoneyName(szType) or XT("未知")
			szMsg = szMsg .. "\n" .. string.format("[FFFE0D]%s[-]欠款[00ff00]%d[-]", szMoneyName, nDebt)
		end
	end
	return szMsg;
end

function Player:CheckPrisonState()
	if me.GetMoneyDebt("Gold") <= 0 and me.IsInPrison() then
		me.CenterMsg("恭喜大侠还清欠款，可以离开此地了！", true);
	end
end

function Player:SendServerIdentity(nServerIdentity)
	self.nServerIdentity = nServerIdentity;
	Log("Player SendServerIdentity", self.nServerIdentity);
end

function Player:UpdateAllPetTime()
	me.nFocusAllPetTime = GetTime();
	if Ui:WindowVisible("HomeScreenBattle") == 1 then
		Ui("HomeScreenBattle"):UpdateFocusAllPet();
	end
end

function Player:OnPlayerPosChange()
	Lib:CallBack({Wedding.BreakEatFood, Wedding});
end

function Player:SetHeadUi(bShow)
	local npcRep = Ui.Effect.GetNpcRepresent(me.GetNpc().nId);
	if npcRep then
		npcRep:ShowHeadUI(bShow)
	end
end

function Player:GetMyRoleId()
	return me.nLocalServerPlayerId or me.dwID
end

function Player:IsInCrossServer( )
	return me.dwID ~= me.nLocalServerPlayerId
end

function Player:SetAllHeadUi(bHide)
	local bShow = not bHide
	Ui.UiManager.m_HeadUiPanel.gameObject:SetActive(bShow);
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_HEAD_UI, bShow)
end


