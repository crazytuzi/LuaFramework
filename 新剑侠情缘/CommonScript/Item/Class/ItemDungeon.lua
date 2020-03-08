--Require("CommonScript/Item/Class/CangBaoTu.lua")
local tbItem = Item:GetClass("ItemDungeon");
local tbCangBaoTu = Item:GetClass("CangBaoTu");
tbItem.PARAM_MAPID = 1;
tbItem.PARAM_POSX = 2;
tbItem.PARAM_POSY = 3;

tbItem.nProcessTime = 3 		 	-- 读条时间
tbItem.nItemId =10722  				-- 山河图道具id
tbItem.MIN_DISTANCE = 1000 			-- 使用山河图队友附近距离
tbItem.nMapTemplateIdFrist = 600 	-- 地宫第一层 地图id
tbItem.nMapTemplateIdBoss = 601 	-- 地宫二层 boss
tbItem.nMapTemplateIdSilver = 603 	-- 地宫二层 水晶

-- 房间随机概率，总概率为所有概率之和
tbItem.tbRandomMapRate = {
	[tbItem.nMapTemplateIdFrist] = 1000;
	[tbItem.nMapTemplateIdBoss] = 1000;
	[tbItem.nMapTemplateIdSilver] = 1000;
}

tbItem.nRandomMapTotalRate = 0
for _, nRate in pairs(tbItem.tbRandomMapRate) do
	tbItem.nRandomMapTotalRate = tbItem.nRandomMapTotalRate + nRate
end

function tbItem:OnUse(it)
	local nMapTemplateId, nPosX, nPosY = self:GetItemDungeonPos(it);
	local nItemType =  KItem.GetItemExtParam(it.dwTemplateId, 2);
	if not self:Islegal(nItemType, nMapTemplateId, nPosX, nPosY, me) then
		self:RandomPos(it, me);
		nMapTemplateId, nPosX, nPosY = self:GetItemDungeonPos(it);
	end
	local bRet, szMsg = self:CheckCanItemDungeon(me, it.dwId);
	if not bRet then
		-- 有时候道具intvalue 会同步失败，但是只能在手机重现 先临时这样处理掉这个BUG
		it.SetIntValue(self.PARAM_MAPID, nMapTemplateId);
		it.SetIntValue(self.PARAM_POSX, nPosX);
		it.SetIntValue(self.PARAM_POSY, nPosY);
		me.CallClientScript("Item:GetClass('ItemDungeon'):OnUseItem", it.dwId, nMapTemplateId, nPosX, nPosY);
		return;
	end
	self:UpdateHeadState(me, true, self.nProcessTime);
	GeneralProcess:StartProcessExt(me, self.nProcessTime * Env.GAME_FPS, true, 0, 0, "挖宝中", {self.OnEndProgress, self, it.dwId}, {self.OnBreakProgress, self, it.dwId});
end

function tbItem:RandomMap()
	local nHit = MathRandom(self.nRandomMapTotalRate)
	for nMapTId, nRate in pairs(self.tbRandomMapRate) do
		if nHit <= nRate then
			return nMapTId
		end
		nHit = nHit - nRate
	end
end

function tbItem:GetFloorLevel(tbPlayer)
	--下一层的类型决定
	local nMaxLevel = 0
	local fnExcute = function (pPlayer)
		if pPlayer.nLevel > nMaxLevel then
			nMaxLevel = pPlayer.nLevel;
		end
	end
	for _, pPlayer in ipairs(tbPlayer) do
		fnExcute(pPlayer)
	end
	--使用哪个事件等级的配置
	local nNextLevel = 0;
	local tbProb;
	for i, v in ipairs(Fuben.DungeonFubenMgr.tbScendLevelSetting) do
		nNextLevel = i
		tbProb = v.tbProb
		if nMaxLevel <= v.nLevelEnd then
			break;
		end
	end

	return nNextLevel
end

function tbItem:OnEndProgress(nItemId)
	local nPlayerId = me.dwID
	local bRet, szMsg, pItem, tbPlayer = self:CheckCanJoin(me, nItemId);
	if not bRet then
		me.CenterMsg(szMsg, true)
		return
	end
	local nMapTId = self:RandomMap()
	if not nMapTId then
		me.CenterMsg("地宫不见了？？")
		return
	end
	local nItemCount = pItem.nCount;
	local nConsumeCount = me.ConsumeItem(pItem, 1, Env.LogWay_ItemDungeon); -- 这里逻辑上比较危险，防止刷，所以不管成功失败，都扣除藏宝图，有问题了再补
	if nConsumeCount ~= 1 then
		Log("ItemDungeon ConsumeItem Fail", me.dwID, me.szName, nItemId, nConsumeCount);
		return 
	end
	
	local tbMemberId = {}
	for _, pMember in ipairs(tbPlayer) do
		local bRet = DegreeCtrl:ReduceDegree(pMember, "ItemDungeon", 1)
		if not bRet then
			pMember.CenterMsg("扣除可参与次数失败", true)
			Log("ItemDungeon AddDegree Fail", me.dwID, me.szName, nItemId, nConsumeCount);
		else
			tbMemberId[pMember.dwID] = true
		end
	end
	local function fnSucess(nMapId)
		for dwRoleId in pairs(tbMemberId) do
			local pPlayer = KPlayer.GetPlayerObjById(dwRoleId)
			if pPlayer then
				pPlayer.CallClientScript("Ui:CloseWindow", "QuickUseItem");
				pPlayer.SetEntryPoint();	
				pPlayer.SwitchMap(nMapId, 0, 0);
			else
				Log("ItemDungeon SwitchMap Offline", dwRoleId)
			end
		end
	end

	local function fnFailedCallback()
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if pPlayer then
			pPlayer.CenterMsg("创建副本失败，请稍后尝试！", true)
		end
	end
	local nFubenKind = 0
	if nMapTId == self.nMapTemplateIdBoss then
		nFubenKind = Fuben.DungeonFubenMgr.Kind_Boss
	elseif nMapTId == self.nMapTemplateIdSilver then
		nFubenKind = Fuben.DungeonFubenMgr.Kind_Silver
	end
	local nFunbenLevelIdx = self:GetFloorLevel(tbPlayer)
	local nPlayerNum = #tbPlayer
	local dwOwnerId = nPlayerId
	if self.nMapTemplateIdFrist == nMapTId then
		Fuben:ApplyFuben(nPlayerId, nMapTId, fnSucess, fnFailedCallback, nPlayerId, tbCangBaoTu.Floor1_ItemDungeon);
	else
		Fuben:ApplyFuben(nPlayerId, nMapTId, fnSucess, fnFailedCallback, nFubenKind, nFunbenLevelIdx, nPlayerNum, dwOwnerId, tbCangBaoTu.Floor1_ItemDungeon);
	end
	if nItemCount > 1 then
		self:RandomPos(pItem, me);
	end
	local nMapId, nX, nY = me.GetWorldPos();
	me.CallClientScript("Ui:PlayEffect", 9013, nX, nY, 0);
end

function tbItem:CheckDistance(pPlayer1, pPlayer2)
	local nMapId1, nX1, nY1 = pPlayer1.GetWorldPos()
    local nMapId2, nX2, nY2 = pPlayer2.GetWorldPos()
    local fDists = Lib:GetDistsSquare(nX1, nY1, nX2, nY2)
    if fDists > (self.MIN_DISTANCE * self.MIN_DISTANCE) or nMapId1 ~= nMapId2 then
        return false, "等所有队员到齐后再挖吧"
    end
    return true
end

function tbItem:CheckCanJoin(pPlayer, nItemId)
	local bRet, szMsg, pItem = self:CheckCanItemDungeon(pPlayer, nItemId);
	if not bRet then
		return false, szMsg
	end
	local nPlayerId = pPlayer.dwID
	local tbMember = {nPlayerId}
	local tbPlayer = {pPlayer}
	if pPlayer.dwTeamID > 0 then
		local tbTeam = TeamMgr:GetTeamById(pPlayer.dwTeamID);
		tbMember = tbTeam:GetMembers();
	end
	for _, nPlayerID in pairs(tbMember) do
		local pMember = KPlayer.GetPlayerObjById(nPlayerID);
		if not pMember then
			return false, "队友不在线，无法使用！"
		end
		local bMe = pPlayer.dwID == pMember.dwID and true or false
		local nItemDungeonCount = DegreeCtrl:GetDegree(pMember, "ItemDungeon")
		if nItemDungeonCount < 1 then
			return false, bMe and "您今日山河图地宫进入次数已达上限" or string.format("队友【%s】今日可进入山河图地宫次数不足", pMember.szName)
		end
		if not bMe then
			local bRet, szMsg = self:CheckDistance(pPlayer, pMember)
			if not bRet then
				return false, szMsg
			end
			table.insert(tbPlayer, pMember)
		end
	end
	
	return true, szMsg, pItem, tbPlayer
end

function tbItem:OnBreakProgress(nItemId)
	me.CallClientScript("Ui:OpenQuickUseItem", nItemId, "使  用");
	self:UpdateHeadState(me, false);
end

function tbItem:OnUseItem(nItemId, nMapId, nX, nY, szTypeName)
	local pItem = KItem.GetItemObj(nItemId);
	if not pItem then
		return;
	end
	local nMapTemplateId, nPosX, nPosY = self:GetItemDungeonPos(pItem);
	nMapTemplateId = nMapId or nMapTemplateId;
	nPosX = nX or nPosX;
	nPosY = nY or nPosY;

	local tbMapSetting = Map:GetMapSetting(nMapTemplateId);
	szTypeName = szTypeName or "地宫" 
	if TeamMgr:HasTeam() then
		local szLocaltion = string.format("地宫位于<%s(%d,%d)>正在前往", tbMapSetting.MapName, nPosX*Map.nShowPosScale, nPosY*Map.nShowPosScale);
		ChatMgr:SetChatLink(ChatMgr.LinkType.Position, {nMapTemplateId, nPosX, nPosY, nMapTemplateId});
		ChatMgr:SendMsg(ChatMgr.ChannelType.Team, szLocaltion);
	end

	local function fnOnArive()
		RemoteServer.UseItem(nItemId);
		Ui:CloseWindow("QuickUseItem");
	end
	
	AutoFight:ChangeState(AutoFight.OperationType.Manual);

	AutoPath:GotoAndCall(nMapTemplateId, nPosX, nPosY, fnOnArive);

	
	me.CenterMsg(string.format("地宫位于<%s(%s, %s)>正在前往", tbMapSetting.MapName, math.floor(nPosX * Map.nShowPosScale), math.floor(nPosY * Map.nShowPosScale)));
	Ui:CloseWindow("ItemTips")
	Ui:CloseWindow("ItemBox");
	Ui:CloseWindow("QuickUseItem");
	Ui:OpenQuickUseItem(nItemId, "使  用");
end

function tbItem:Islegal(nItemType, nMapTemplateId, nPosX, nPosY, pPlayer)
	if not tbCangBaoTu.tbAllPos[nItemType][nMapTemplateId] then
		if pPlayer.tbCangBatoTuInfo and pPlayer.tbCangBatoTuInfo[nItemType] then
			pPlayer.tbCangBatoTuInfo[nItemType] = nil
		end
		return false
	end

	if not tbCangBaoTu.tbAllPos[nItemType][nMapTemplateId].nLevel or tbCangBaoTu.tbAllPos[nItemType][nMapTemplateId].nLevel > pPlayer.nLevel then
		return false
	end

	for nIndex,tbPos in ipairs(tbCangBaoTu.tbAllPos[nItemType][nMapTemplateId]) do
        if tbPos[2] and tbPos[3] and tbPos[2] == nPosX and tbPos[3] == nPosY then
        	return true
        end
    end

    return false
end

function tbItem:CheckCanItemDungeon(pPlayer, nItemId)
	local pItem = KItem.GetItemObj(nItemId);
	if not pItem or pItem.szClass ~= "ItemDungeon" then
		return false, "咦，山河图呢！";
	end

	local nMapTemplateId, nPosX, nPosY = self:GetItemDungeonPos(pItem);
	local _, nX, nY = pPlayer.GetWorldPos();
	if pPlayer.nMapTemplateId ~= nMapTemplateId or math.abs(nPosX - nX) > 100 or math.abs(nPosY - nY) > 100 then
		return false, "此处没有地宫，换个地方试试吧！";
	end

	return true, "", pItem;
end

function tbItem:GetItemDungeonPos(pItem)
	local nMapTemplateId = pItem.GetIntValue(self.PARAM_MAPID);
	local nPosX = pItem.GetIntValue(self.PARAM_POSX);
	local nPosY = pItem.GetIntValue(self.PARAM_POSY);
	return nMapTemplateId, nPosX, nPosY;
end

function tbItem:RandomPos(pItem, pPlayer)
	local nItemType =  KItem.GetItemExtParam(pItem.dwTemplateId, 2);
	return self:RandomPosFromType(pItem, pPlayer, nItemType)
end

function tbItem:RandomPosFromType(pItem, pPlayer, nItemType)
	local nLevel = pPlayer and pPlayer.nLevel or tbCangBaoTu.tbLevel[nItemType].nMinLevel;
	-- 高级藏宝图等级不够打开界面的时候random
	nLevel = nLevel < tbCangBaoTu.tbLevel[nItemType].nMinLevel and tbCangBaoTu.tbLevel[nItemType].nMinLevel or nLevel

	local tbCurInfo = {tbUsedMap = {}};
	if pPlayer and pPlayer.tbItemDungeonInfo and pPlayer.tbItemDungeonInfo[nItemType] then
		tbCurInfo = pPlayer.tbItemDungeonInfo[nItemType]
	end

	local tbPosInfo = {};
	local nTotalCount = 0;
	if tbCurInfo.nMapTemplateId then
		tbPosInfo = {tbCangBaoTu.tbAllPos[nItemType][tbCurInfo.nMapTemplateId]};
		nTotalCount = #tbCangBaoTu.tbAllPos[nItemType][tbCurInfo.nMapTemplateId];
	else
		for nMapTemplateId, tbInfo in pairs(tbCangBaoTu.tbAllPos[nItemType]) do
			if not tbCurInfo.tbUsedMap[nMapTemplateId] and nLevel >= tbInfo.nLevel then
				table.insert(tbPosInfo, tbInfo);
				nTotalCount = nTotalCount + #tbInfo;
			end
		end
	end

	local nRandom = MathRandom(nTotalCount);
	local tbPos = nil;
	for _, tbInfo in pairs(tbPosInfo) do
		tbPos = tbInfo[nRandom];
		if tbPos then
			break;
		end
		
		nRandom = nRandom - #tbInfo;
	end

	if MODULE_GAMESERVER then
		pItem.SetIntValue(self.PARAM_MAPID, tbPos[1]);
		pItem.SetIntValue(self.PARAM_POSX, tbPos[2]);
		pItem.SetIntValue(self.PARAM_POSY, tbPos[3]);
	end
	print("RandomPos->", tbPos[1], tbPos[2], tbPos[3])
	return tbPos[1], tbPos[2], tbPos[3]
end

function tbItem:UpdateHeadState(pPlayer, bAdd, nWaBaoTime)
    local pNpc = pPlayer.GetNpc();
    if not pNpc then
    	return;
    end

    if bAdd then	
		pNpc.AddSkillState(Player.tbHeadStateBuff.nItemDungeon, 1, FightSkill.STATE_TIME_TYPE.state_time_normal, nWaBaoTime * Env.GAME_FPS, 0, 1);
	else
		pNpc.RemoveSkillState(Player.tbHeadStateBuff.nItemDungeon);	
	end

    pPlayer.CallClientScript("Player:UpdateHeadState", bAdd);	
end

function tbItem:OnNotifyItem(pPlayer, it, tbMsg)

	if not tbMsg then
		return
	end

	if not it.GetIntValue(self.PARAM_MAPID) == 0 then
		return
	end

	local nMapTemplateId = tbMsg.nMapTemplateId
	local nPosX = tbMsg.nPosX
	local nPosY = tbMsg.nPosY
	local nItemType = tbMsg.nItemType

	if not nItemType or not nMapTemplateId or not nPosX or not nPosY then
		return
	end

	if not tbCangBaoTu.tbAllPos[nItemType] or not tbCangBaoTu.tbAllPos[nItemType][nMapTemplateId] then
		return;
	end
		print("OnNotifyItem->",nMapTemplateId, nPosX, nPosY)
	if not self:Islegal(nItemType, nMapTemplateId, nPosX, nPosY, pPlayer) then
		self:RandomPos(it, pPlayer)
	else
		it.SetIntValue(self.PARAM_MAPID, nMapTemplateId);
		it.SetIntValue(self.PARAM_POSX, nPosX);
		it.SetIntValue(self.PARAM_POSY, nPosY);
	end
end

function tbItem:GetTip(it)
	if not it.dwId then
		return "";
	end

	local nItemType =  KItem.GetItemExtParam(it.dwTemplateId, 2);

	local nMapTemplateId,nPosX,nPosY = 0,0,0

	if it.GetIntValue(self.PARAM_MAPID) == 0 then
		nMapTemplateId,nPosX,nPosY = self:RandomPos(it, me)
		local tbMsg = 
		{
			nItemType = nItemType,
			nMapTemplateId = nMapTemplateId,
			nPosX = nPosX,
			nPosY = nPosY,
		}
		RemoteServer.NotifyItem(it.dwId, tbMsg)
	else
		nMapTemplateId, nPosX, nPosY = self:GetItemDungeonPos(it)
	end
	if not nMapTemplateId then
		Log("ItemDungeon GetTip nMapTemplateId is null!!",nMapTemplateId)
		return "";
	end
	local tbMapSetting = Map:GetMapSetting(nMapTemplateId);
	if not tbMapSetting then
		Log("ItemDungeon GetTip tbMapSetting is null!!")
		return "";
	end

	local szTip = string.format("地宫位于：%s(%s, %s)\n", tbMapSetting.MapName, math.floor(nPosX * Map.nShowPosScale), math.floor(nPosY * Map.nShowPosScale));
	
	return szTip
end

function tbItem:AuoUserItemDungeon(pPlayer)
	local tbItem = pPlayer.FindItemInBag("ItemDungeon")
	local pFindItem = tbItem and tbItem[1]
	if not pFindItem then
		return
	end
	self:RandomPos(pFindItem, pPlayer);
	pPlayer.CallClientScript("CangBaoTu:UseItemAfterLoadMap", pFindItem.dwId);
end