local SceneMgr = luanet.import_type("SceneMgr");

Map.nUnLoadResourceTime = 1800;
local tbMapEnterBlackBoardMsg =
{
	[409] = "你已进入PK地图，自动开启家族模式";
	[1030] = "你已进入PK地图，自动开启家族模式";
	[1031] = "你已进入PK地图，自动开启家族模式";
	[1032] = "你已进入PK地图，自动开启家族模式";
	[1033] = "你已进入PK地图，自动开启家族模式";
	[1034] = "你已进入PK地图，自动开启家族模式";
	[1035] = "你已进入PK地图，自动开启家族模式";
}

--野外地图。有安全区的那种
Map.tbFieldFightMap = {
	[400] = true,
	[401] = true,
	[402] = true,
	[403] = true,
	[404] = true,
	[405] = true,
	[406] = true,
	[407] = true,
	[408] = true,
	[409] = true,
	[410] = true,
	[411] = true,
	[412] = true,
	[413] = true,
	[414] = true,
	[415] = true,
	[416] = true,
	[417] = true,
	[418] = true,
	[419] = true,
	[420] = true,
}

Map.tbNeedRepairSceneCamera =
{
	[150] = true,
	[473] = true,
};

function Map:LoadMapInfoC()
    self.tbMapRepresentInfo = {};
    local tbFileData = Lib:LoadTabFile("Setting/Map/MapRepresent.tab", {MapID = 1, RimPow = 1, RimBright = 1});
    for _, tbInfo in pairs(tbFileData) do
    	local tbMapRepInfo = {};
    	tbMapRepInfo.fRimPow = tbInfo.RimPow or 1.0;
    	tbMapRepInfo.fRimBright = tbInfo.RimBright or 1.0;
    	tbMapRepInfo.tbEnvColor = {1.0, 1.0, 1.0, 1.0};
    	tbMapRepInfo.tbRimColor = {1.0, 1.0, 1.0, 1.0};
    	tbMapRepInfo.tbRimDir = {1.0, 1.0, 1.0, 1.0};
    	local tbResult = {};
    	if not Lib:IsEmptyStr(tbInfo.EnvColor) then
    		tbResult = Lib:AnalyzeParamStr(tbInfo.EnvColor);
    		tbMapRepInfo.tbEnvColor = tbResult[1];
    		for k, v in ipairs(tbMapRepInfo.tbEnvColor) do
    			tbMapRepInfo.tbEnvColor[k] = v / 255;
    		end
    	end

    	if not Lib:IsEmptyStr(tbInfo.RimColor) then
    		tbResult = Lib:AnalyzeParamStr(tbInfo.RimColor);
    		tbMapRepInfo.tbRimColor = tbResult[1];

    		for k, v in ipairs(tbMapRepInfo.tbRimColor) do
    			tbMapRepInfo.tbRimColor[k] = v / 255;
    		end
    	end

    	if not Lib:IsEmptyStr(tbInfo.RimDir) then
    		tbResult = Lib:AnalyzeParamStr(tbInfo.RimDir);
    		tbMapRepInfo.tbRimDir = tbResult[1];
    	end

    	self.tbMapRepresentInfo[tbInfo.MapID] = tbMapRepInfo;
    end

end
Map:LoadMapInfoC();

function Map:GetMapRepInfo(nMapID)
    return self.tbMapRepresentInfo[nMapID] or self.tbMapRepresentInfo[-1];
end

function Map:UpdateMapRepEnv(nTemplateID)
    local tbRepInfo = self:GetMapRepInfo(nTemplateID);
    if not tbRepInfo then
    	return;
    end

    local tbEffect = Ui.Effect;
    if not self.bInitMapRepEnv then
    	tbEffect.Env_SetCanShader("FTGame/CharacterColourHighX");
    	tbEffect.Env_SetCanShader("FTGame/CharacterColourNormalX");

    	self.bInitMapRepEnv = true;
    end

    tbEffect.Env_SetEnvColor(tbRepInfo.tbEnvColor[1] or 1.0, tbRepInfo.tbEnvColor[2] or 1.0, tbRepInfo.tbEnvColor[3] or 1.0, tbRepInfo.tbEnvColor[4] or 1.0);
    tbEffect.Env_SetRimColor(tbRepInfo.tbRimColor[1] or 1.0, tbRepInfo.tbRimColor[2] or 1.0, tbRepInfo.tbRimColor[3] or 1.0, tbRepInfo.tbRimColor[4] or 1.0);
    tbEffect.Env_SetRimDir(tbRepInfo.tbRimDir[1] or 1.0, tbRepInfo.tbRimDir[2] or 1.0, tbRepInfo.tbRimDir[3] or 1.0, tbRepInfo.tbRimDir[4] or 1.0);
    tbEffect.Env_SetRimPowBright(tbRepInfo.fRimPow or 1.0, tbRepInfo.fRimBright or 1.0);
    tbEffect.Env_UpdateAllNpcRep();

    Log("Map UpdateMapRepEnv", nTemplateID);
end

function Map:OnEnter(nTemplateID, nMapID, nIsLocal)
	self.nMapId = nMapID;
	self.bLoading = true;
    self.tbTrapCChangeCameraParam = nil
	if not PlayerEvent.bLogin then
		PlayerEvent.tbMapOnEnterParam = {nTemplateID, nMapID, nIsLocal};
		return;
	end

	AutoPath:OnEnterMap(nTemplateID, nMapID, nIsLocal);

	Task:OnEnter(nTemplateID);

	local nState, bHide = Map:GetMapUiState(nTemplateID);
	Ui:ChangeUiState(nState, bHide);

	UiNotify.OnNotify(UiNotify.emNOTIFY_MAP_ENTER, nTemplateID, nMapID);

	if nIsLocal == 1 then
		Fuben:OnEnter(nTemplateID, nMapID);
		AsyncBattle:OnEnterMap(nTemplateID);
		ActionMode:OnEnterMap(me, nTemplateID);
	end

	Player:UpdateHeadState();
	ClientNpc:OnEnterMap(nTemplateID);
	NewInformation:OnEnterMap()

	if self.nUnLoadResourceTimer then
		Timer:Close(self.nUnLoadResourceTimer);
		self.nUnLoadResourceTimer = nil;
	end

	self.nUnLoadResourceTimer = Timer:Register(Env.GAME_FPS * self.nUnLoadResourceTime, self.UnLoadResource, self);

	ArenaBattle:OnMapEnter(nTemplateID)

	Kin.Snowman:OnEnterMap(nTemplateID)
	Kin.NYSnowman:OnEnterMap(nTemplateID)

	AutoFight:OnEnterMap(nTemplateID);

	Lib:CallBack({House.OnEnterMap, House, nTemplateID});

	Lib:CallBack({JingMai.OnClientEnterMap, JingMai});
	Lib:CallBack({Map.UpdateMapRepEnv, Map, nTemplateID});
	Lib:CallBack({Operation.OnEnterMap, Operation, nTemplateID});
	Lib:CallBack({ZhenFa.CheckRedpoint, ZhenFa});
	Lib:CallBack({QunYingHuiCross.OnEnterMap, QunYingHuiCross, nTemplateID});
	Lib:CallBack({Pandora.OnEnterMap, Pandora, nTemplateID, nMapID, nIsLocal});
	Log("Client Map:OnEnter......>>>", me.dwID, nMapID, me.nAlone, nTemplateID, nIsLocal);
end

Map.tbSTOP_PEEK_REASON =
{
	"对方网络异常，远程观战终止",
	"对方离开了地图，远程观战终止",
	"您的网络异常，远程观战终止",
	"您切换了地图，远程观战终止",
}

function Map:OnEnterPeek(nTemplateID, nMapID, nPeekNpcId, nReason)
	Ui:CloseWindow("SocialPanel");
	local fnOnLeavePeeking = function (nReason)
		Ui.CameraMgr.ResetMainCamera(true);
		BindCameraToNpc(0, 0);
		Ui:ChangeUiState(0, true);
		Ui:CloseWindow("QYHLeftInfo");
		local pNpc = me.GetNpc()
		if pNpc then
			pNpc.SetHideNpc(0)
		end
		if self.tbSTOP_PEEK_REASON[nReason] then
			Ui:OpenWindow("MessageBox", self.tbSTOP_PEEK_REASON[nReason], {}, {"知道了"});
		end
	end
	local pNpc = me.GetNpc()
	if nPeekNpcId ~= pNpc.nId then
		self.fnOnPeekingLoadMapEnd = function ()
			local pNpc = me.GetNpc()
			Ui.CameraMgr.ResetMainCamera(true);
			BindCameraToNpc(nPeekNpcId, 0);
			Ui:ChangeUiState(Ui.STATE_ASYNC_BATTLE);
			Ui:OpenWindow("QYHLeftInfo", "PeekPlayer", {});
			if pNpc then
				pNpc.SetHideNpc(1)
			end
			Map.fnOnPeekingEnd = fnOnLeavePeeking
		end
		if me.nMapTemplateId == nTemplateID then	-- 同地图，不会执行加载
			Lib:CallBack({self.fnOnPeekingLoadMapEnd})
			self.fnOnPeekingLoadMapEnd = nil;
		end
	else
		fnOnLeavePeeking(nReason)
		Map.fnOnPeekingEnd = nil;
	end
end

function Map:UnLoadResource()
	if not PlayerEvent.bLogin then
		self.nUnLoadResourceTimer = nil;
		return;
	end

	Log("Map:UnLoadResource.................");
	Ui.ResourceLoader.UnLoadResource();
	return true;
end

function Map:OnLeave(nTemplateID, nMapID)
	if self.bLeaveClearShowRep then
		Ui.Effect.ClearShowRepNpc();
        Ui.Effect.ClearVisibleRepNpc();
		self.bLeaveClearShowRep = nil;
		Log("Map LeaveClearShowRep");
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_MAP_LEAVE, nTemplateID, nMapID);

	if IsAlone() == 1 then
		SetGameWorldScale(1);
		AsyncBattle:OnLeaveMap(nTemplateID);
	end

	Sdk:GsdkEnd();

	ArenaBattle:OnMapLeave(nTemplateID)

	Kin.Snowman:OnLeaveMap(nTemplateID)
	Kin.NYSnowman:OnLeaveMap(nTemplateID)

	BiWuZhaoQin:OnClientMapLeave(nTemplateID)

	Lib:CallBack({House.OnLeaveMap, House, nTemplateID});
	Lib:CallBack({WeatherMgr.OnLeaveMap, WeatherMgr, nTemplateID});
	HousePlant:OnLeaveMap(nTemplateID);
	Lib:CallBack({QunYingHuiCross.OnLeaveMap, QunYingHuiCross, nTemplateID});
	Lib:CallBack({Toy.OnLeaveMap, Toy, nTemplateID})
	Lib:CallBack({Activity.MaterialCollectAct.OnLeaveMap, Activity.MaterialCollectAct, nTemplateID})
	--@_@ 不支持
	--Lib:CallBack({Operation.QuiteAssistUiState, Operation})
	--Lib:CallBack({Furniture.Cook.OnLeaveMap, Furniture.Cook, nTemplateID})
	-- TODO：由于换不了包，先这样修复同个场景进两次找不到摄像机的问题
	if Map.tbNeedRepairSceneCamera[nTemplateID] then
		Ui.CameraMgr.SetSceneCameraActive(true);
	end
	Ui:CloseWindow("RankBattleResult")
	Log("Map:OnLeave", nTemplateID, nMapID);
end

function Map:OnEnterSameTemplateIdMap(nTemplateID, nMapID, nIsLocal)
	Timer:Register(2, function ()
		Ui:SetForbiddenOperation(false);
		Ui:SetAllUiVisable(true);
		SetGameWorldScale(1.0);
		Operation:SetGuidingJoyStick(false);
		Ui:ShowAllRepresentObj(true);

		Map:OnEnter(nTemplateID, nMapID, IsAlone() == 0 and 1 or 0);

		Timer:Register(1, function ()
			Map:OnMapLoaded(nTemplateID);
		end);
	end)
end

function Map:OnLostConnect()
	if self.fnOnPeekingEnd then
		self.fnOnPeekingEnd(3)
		self.fnOnPeekingEnd = nil;
	end
end

function Map:OnDestroy(nTemplateID, nMapID, nIsLocal)
	if nIsLocal == 1 then
		Fuben:OnDestroyMap(nMapID);
	end

	if self.tbAllMapWaiYiInfo and self.tbAllMapWaiYiInfo[nMapID] then
		self.tbAllMapWaiYiInfo[nMapID] = nil;
	end

	Ui:CloseWindow("CalendarPanel");
	Operation:OnDestroyMap();
	Map:StopMapSound();
	Map:CheckCloseUi(self.tbOnLeaveCloseUi, nMapID);

	Ui:ClearCanLoadResPath();
	Lib:CallBack({Map.ClearAllObjRep, Map});
	Lib:CallBack({Decoration.OnMapDestroy, Decoration, nTemplateID, nMapID});
    Ui.CameraMgr.StopCameraCrossRoate();
	Log("Client Map:OnDestroy......", me.dwID, nMapID, nTemplateID);
end

function Map:UpdateMapLoaded(nMapTemplateID)
    Ui:SetSceneSoundScale(100);
	Ui:SetDialogueSoundScale(Npc.nDialogSoundScale);
	local nSoundScale = 100;
	if nMapTemplateID > 0 then
		nSoundScale = Map:GetEffectSoundVolume(nMapTemplateID);
		if nSoundScale <= 0 then
			nSoundScale = 100;
		end
	end
	Ui:SetEffectSoundScale(nSoundScale);
end

function Map:ClearAllObjRep()
    if not Ui.Effect then
    	return;
    end

    Ui.Effect.ClearAllObjRepresent();
end

function Map:UpdateCamera(nMapTemplateID)
	local tbSetting = self:GetCameraSettings(nMapTemplateID)
	if not tbSetting then return end

	Ui.CameraMgr.ChangeCameraSetting(tbSetting.nDistance, tbSetting.nLookDownAngle, tbSetting.nFov)
end



function Map:OnMapLoaded(nMapTemplateID)
	self.bLoading = false;

	Lib:CallBack({WeatherMgr.OnMapLoaded, WeatherMgr, nMapTemplateID});

	self:UpdateCamera(nMapTemplateID)
	Map:UpdateMapLoaded(nMapTemplateID);
	if nMapTemplateID == 0 then --角色创建地图
		Login:OnMapLoaded();
		Ui:UpateUseRes();
		return;
	end

	AsyncBattle:OnLoadMapEnd(nMapTemplateID);
	UiNotify.OnNotify(UiNotify.emNOTIFY_MAP_LOADED, nMapTemplateID);

	Fuben:OnMapLoaded(nMapTemplateID);
	Client:DoSetPlayerDir();
	Partner.PartnerTalk:OnMapLoaded();
	-- 现在有可能地图加载之前就播放了，需要先停掉再播要不然会没声音
	Map:RestartPlayMapSound()
	--Map:PlayMapSound(nMapTemplateID);
	Task:OnMapLoaded();
	me.OnEvent("OnMapLoaded", nMapTemplateID);

	if me and me.nMapId then
		Map:CheckCloseUi(self.tbOnLoadCloseUi, me.nMapId);
		self:ProcessWaiYi(me.nMapId, nMapTemplateID);
	end

	if tbMapEnterBlackBoardMsg[nMapTemplateID] then
		me.SendBlackBoardMsg(tbMapEnterBlackBoardMsg[nMapTemplateID]);
	end

	Player:FlyChar()
	Fuben.WhiteTigerFuben:OnMapLoaded(nMapTemplateID)
	Fuben.KinTrainMgr:OnMapLoaded(nMapTemplateID)
	SeriesFuben:OnMapLoaded(nMapTemplateID)

	Sdk:GsdkStart()
	Ui:UpdateLoadShowUI(nMapTemplateID);

	Ui:GetClass("HomeScreenTip"):OnMapLoaded(nMapTemplateID);
	Lib:CallBack({Map.DoCacheCmd, Map});

	Lib:CallBack({Decoration.OnMapLoaded, Decoration});
	Lib:CallBack({House.OnMapLoaded, House, nMapTemplateID});
	Lib:CallBack({Calendar.OnMapLoaded, Calendar, nMapTemplateID})
	Lib:CallBack({Wedding.OnMapLoaded, Wedding, nMapTemplateID});
	AutoPath:OnMapLoaded(nMapTemplateID);

	if self.fnOnPeekingLoadMapEnd then
		Lib:CallBack({self.fnOnPeekingLoadMapEnd})
		self.fnOnPeekingLoadMapEnd = nil;
	end
	Lib:CallBack({Operation.OnMapLoadedFinish, Operation, nMapTemplateID});
    Lib:CallBack({CameraAnimation.OnMapLoaded, CameraAnimation, nMapTemplateID});
    Lib:CallBack({WuLinDaShi.OnMapLoaded, WuLinDaShi, nMapTemplateID});

    Lib:CallBack({Activity.ThirdAnniversaryCelebration.OnMapLoaded, Activity.ThirdAnniversaryCelebration, nMapTemplateID});
	Lib:CallBack({Pandora.OnMapLoaded, Pandora, nMapTemplateID});
	Lib:CallBack({BossLeader.DaMoCave.OnMapLoaded, BossLeader.DaMoCave, nMapTemplateID})

	if self.bFirstLogin then
		Lib:CallBack({OnHook.OnFirstMapLoaded, OnHook});
		self.bFirstLogin = false;
	end

	Log("Client Map:OnMapLoaded ...", nMapTemplateID);
end

function Map:OnLogin()
	self.bFirstLogin = true;
end

function Map:ProcessWaiYi(nMapId, nMapTemplateID)
	if not self.tbMapWaiYiSetting[nMapTemplateID] or not self.nCurrentWaiYiMapId or self.nCurrentWaiYiMapId ~= nMapId then
		return;
	end

	local tbWaiYiInfo = self.tbCurrentMapWaiYi or {}
	for nPosType, tbWaiYi in pairs(self.tbMapWaiYiSetting[nMapTemplateID]) do
		local tbInfo = tbWaiYi[tbWaiYiInfo[nPosType] or 0];
		for szPath, tbW in pairs(tbInfo or {}) do
			for nIdx, szMaterial in pairs(tbW) do
				Ui.SceneMgr_CS.SetObjMaterials(szPath, nIdx, szMaterial);
			end
		end
	end
end

function Map:OnSyncSetWaiYiInfo(nMapId, nPosType, nWaiYiId)
	if nMapId == self.nCurrentWaiYiMapId then
		self.tbCurrentMapWaiYi[nPosType] = nWaiYiId;
	end

	if nMapId ~= me.nMapId then
		return;
	end

	local tbPosType = self.tbMapWaiYiSetting[me.nMapTemplateId][nPosType];
	if not tbPosType then
		return;
	end

	local tbInfo = tbPosType[nWaiYiId or 0];

	for szPath, tbW in pairs(tbInfo) do
		for nIdx, szMaterial in pairs(tbW) do
			Ui.SceneMgr_CS.SetObjMaterials(szPath, nIdx, szMaterial);
		end

	end
end

function Map:OnSyncAllWaiYiInfo(nMapId, tbWaiYiInfo)
	self.nCurrentWaiYiMapId = nMapId;
	self.tbCurrentMapWaiYi = tbWaiYiInfo;

	if nMapId == me.nMapId then
		self:ProcessWaiYi(nMapId, me.nMapTemplateId);
	end
end

function Map:OnPlayerTrap(nMapTemplateID, nMapID, szTrapName, nIsLocal)
	if not Toy:IsFree() then
		return
	end
	if nIsLocal == 1 then
		Fuben:OnPlayerTrap(nMapID, szTrapName);
		--Log(string.format("OnPlayerTrap nMapTemplateID = %s, nMapID = %s, szTrapName = %s, nIsLocal = %s", nMapTemplateID, nMapID, szTrapName, nIsLocal));
	end
	Task:OnPlayerTrap(nMapTemplateID, szTrapName);
	Lib:CallBack({Map.OnTrapEventC, Map, nMapTemplateID, szTrapName});
	Lib:CallBack({WeatherMgr.OnPlayerTrap, WeatherMgr, nMapTemplateID, szTrapName});
	Lib:CallBack({ChatMgr.ChatEquipBQ.OnPlayerTrapC, ChatMgr.ChatEquipBQ, nMapTemplateID, szTrapName});
	--Lib:CallBack({Furniture.Cook.OnPlayerTrap, Furniture.Cook, nMapTemplateID, szTrapName})
end

function Map:OnNpcTrap(nMapTemplateID, nMapID, szTrapName, nIsLocal)

end

function Map:OnPlayerGrassEvent(nMapTID, nMapID, nGrassId, nOldGrassId, nIsLocal)
	if nMapTID == 3003 then
		local pRepresent = Ui.Effect.GetNpcRepresent(me.GetNpc().nId)
		if pRepresent then
			pRepresent:SetGrassState(0)
		end
	end
	print("Map:OnPlayerGrassEvent", nMapTID, nMapID, nGrassId, nOldGrassId, nIsLocal)
end

function Map:OnNpcGrassEvent(nMapTID, nMapID, nGrassId, nOldGrassId, nIsLocal)
	if nMapTID == 3003 then
		local pRepresent = Ui.Effect.GetNpcRepresent(him.nId)
		if pRepresent then
			pRepresent:SetGrassState(0)
		end
	end
	print("Map:OnNpcGrassEvent", nMapTID, nMapID, nGrassId, nOldGrassId, nIsLocal)
end

local tbMiniMapNpcPositions = {};

function Map:OnSyncNpcsPos(szType, tbPos)
	tbMiniMapNpcPositions[szType] = tbPos;
end

function Map:GetMiniMapPos(szType)
	return tbMiniMapNpcPositions[szType] or {};
end

Map.tbPlaySceneSound = Map.tbPlaySceneSound or {};
function Map:PlayMapSound(nTemplateMapID)
	local tbSound = Map:GetExtraSoundId(nTemplateMapID) or self:GetSoundID(nTemplateMapID);
	for _, nSoundID in pairs(tbSound) do
		if nSoundID and nSoundID > 0 then
			self:PlaySceneSound(nSoundID);
		end
	end
end

function Map:StopMapSound(nDuration)
	nDuration = nDuration  or 1500;
	for nSoundID, _ in pairs(self.tbPlaySceneSound) do
		Ui:StopSceneSound(nSoundID, nDuration);
	end

	self.tbPlaySceneSound = {};
end

function Map:PlaySceneSound(nSoundID)
	if self.tbPlaySceneSound[nSoundID] then
		return;
	end

    Ui:PlaySceneSound(nSoundID);
    self.tbPlaySceneSound[nSoundID] = 1;
end

function Map:PlaySceneOneSound(nSoundID)
    self:StopMapSound(1);
    self:PlaySceneSound(nSoundID);
end

function Map:RestartPlayMapSound()
    self:StopMapSound(1);
    self:PlayMapSound(me.nMapTemplateId);
end

function Map:SetCloseUiOnLoad(nMapId, szUiName)
	self.tbOnLoadCloseUi = self.tbOnLoadCloseUi or {};
	self.tbOnLoadCloseUi[szUiName] = nMapId;
end

function Map:SetCloseUiOnLeave(nMapId, szUiName)
	self.tbOnLeaveCloseUi = self.tbOnLeaveCloseUi or {};
	self.tbOnLeaveCloseUi[szUiName] = nMapId;
end

function Map:CheckCloseUi(tbCloseInfo, nMapId)
	if not tbCloseInfo then
		return;
	end

	tbCloseInfo = tbCloseInfo or {};
	local tbInfo = {};
	for szUiName, nMd in pairs(tbCloseInfo) do
		if nMapId == nMd then
			Ui:CloseWindow(szUiName);
			table.insert(tbInfo, szUiName);
		end
	end

	for _, szUiName in pairs(tbInfo) do
		tbCloseInfo[szUiName] = nil;
	end
end

function Map:OnSynAllRolePos(tbPosList)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYN_MAP_ALL_POS, tbPosList)
end

function Map:SwitchMap(nMapId, nMapTemplateId)
	assert(type(nMapId) == "number");
	RemoteServer.OnMapRequest("SwitchMap", nMapId, nMapTemplateId);
end

function Map:GetTransmitPath(nMapTemplateId, nMapId, nX, nY, nParam)
	if ImperialTomb:IsTombMap(nMapTemplateId) then
		return ImperialTomb:GetTransmitPath(nMapTemplateId, nMapId, nX, nY, nParam)
	end
end

Map.tbCustomAutoFightRadius = {
}
for i,v in ipairs(Fuben.KeyQuestFuben.DEFINE.FIGHT_MAP_ID) do
	Map.tbCustomAutoFightRadius[v] = 600
end
function Map:GetAutoFightRadius(nMapTemplateId, nMapId)
	if ImperialTomb:IsTombMap(nMapTemplateId) then
		return ImperialTomb:GetAutoFightRadius(nMapTemplateId, nMapId)
	else
		return Map.tbCustomAutoFightRadius[nMapTemplateId]
	end
end

function Map:DoCmdWhenMapLoadFinish(nMapId, ...)
	if not self.bLoading and self.nMapId and nMapId == self.nMapId then
		me.CallClientScript(...);
		return;
	end

	self.tbCacheCmd = self.tbCacheCmd or {};
	self.tbCacheCmd[nMapId] = self.tbCacheCmd[nMapId] or {};
	table.insert(self.tbCacheCmd[nMapId], {...});
end

function Map:DoCacheCmd()
	if not self.nMapId or not self.tbCacheCmd then
		return;
	end

	local tbCacheCmd = self.tbCacheCmd[self.nMapId] or {};
	self.tbCacheCmd = {};
	for _, tbCmd in pairs(tbCacheCmd) do
		me.CallClientScript(unpack(tbCmd));
	end
end

function Map:IsMapOnLoading()
	return self.bLoading;
end

function Map:LoadMapTrapC()
    self.tbSettingTrapEventC = {};
    local tbFileData = Lib:LoadTabFile("Setting/Map/MapTrapEventC.tab", {MapTID = 1});
    for _, tbInfo in ipairs(tbFileData) do
    	local tbTrapCInfo = {};
    	tbTrapCInfo.szType = tbInfo.Type;
    	tbTrapCInfo.tbParam = Lib:AnalyzeParamStrOne(tbInfo.Param);
    	self.tbSettingTrapEventC[tbInfo.MapTID] = self.tbSettingTrapEventC[tbInfo.MapTID] or {};
    	self.tbSettingTrapEventC[tbInfo.MapTID][tbInfo.TrapName] = self.tbSettingTrapEventC[tbInfo.MapTID][tbInfo.TrapName] or {};
    	table.insert(self.tbSettingTrapEventC[tbInfo.MapTID][tbInfo.TrapName], tbTrapCInfo);
    end
end

Map:LoadMapTrapC();

function Map:GetMapTrapEventC(nMapTemplateID, szTrapName)
    local tbMapInfo = self.tbSettingTrapEventC[nMapTemplateID];
    if not tbMapInfo then
    	return;
    end

    return tbMapInfo[szTrapName];
end

function Map:OnTrapEventC(nMapTemplateID, szTrapName)
    local tbAllEvent = self:GetMapTrapEventC(nMapTemplateID, szTrapName);
    if not tbAllEvent then
    	return;
    end

    local pPlayerNpc = me.GetNpc();
    if not pPlayerNpc then
        return;
    end

    for _, tbEvent in ipairs(tbAllEvent) do
    	local fnCallBack = self["OnTrapC"..tbEvent.szType];
    	if fnCallBack then
            if not tbEvent.tbParam.NotCanSkill or pPlayerNpc.CanChangeDoing(Npc.Doing.skill) == 1 then
    		   fnCallBack(self, tbEvent.tbParam);
            end
    	end
    end
end

function Map:OnTrapCChangeCamera(tbParam)
    local funCallBack = function ()
        local nCameraDis = tbParam.CameraDis or 0;
        if nCameraDis ~= 0 then
            Ui.CameraMgr.StopCameraCrossRoate();
            Ui.CameraMgr.ChangeCameraDistance(nCameraDis);
        end

        local nRoateSpeed = tbParam.RoateSpeed or 0;
        if nRoateSpeed ~= 0 then
            Ui.CameraMgr.CreateCameraCrossRoate(tbParam.XRoate or 0, tbParam.YRoate or 0, tbParam.ZRoate or 0, nRoateSpeed);
            if self.nCrossRoateTimer then
                Timer:Close(self.nCrossRoateTimer);
                self.nCrossRoateTimer = nil;
            end

            self.nCrossRoateTimer = Timer:Register(60, function ()
                Map.nCrossRoateTimer = nil;
                Ui.CameraMgr.StopCameraCrossRoate();
            end)
        end
        self.tbTrapCChangeCameraParam = tbParam
    end

    local nDelayTime = tbParam.DelayTime or 0;
    if nDelayTime > 0 then
        Timer:Register(nDelayTime, funCallBack)
        return;
    end

    funCallBack();
end

function Map:OnTrapCSceneObjActive(tbParam)
    Ui.Effect.SetActivedChildObjActive(tbParam.Name, tbParam.Active == 1);
end

function Map:GetMapPos(nX, nY)
	return nX * Map.CELL_WIDTH + SceneMgr.s_vCurMapInfo.x, nY * Map.CELL_WIDTH + SceneMgr.s_vCurMapInfo.z;
end

-- 检查是否在地图配置内
function Map:IsInMap(nX, nY, tbMapSetting)
	nX, nY = Map:GetMapPos(nX, nY);

	if nX < tbMapSetting.BeginPosX or nX > tbMapSetting.BeginPosX + tbMapSetting.SizeX then
		return false;
	end

	if nY < tbMapSetting.BeginPosY or nY > tbMapSetting.BeginPosY + tbMapSetting.SizeY then
		return false;
	end

	return true;
end


function Map:LoadHideEnemyPos(  )
	local tbHideEnemyPos = {};
	self.tbHideEnemyPos = tbHideEnemyPos
	--遍历全部点可能有效率问题，所以取这个地图设置里最大的 Radids  作为 Regin 的边长， 先找到 玩家根据此计算出的 region 编号，再取包裹其的9个region 变量看是否有满足条件的点即可
	--在此点为中心，指定区域范围内的可攻击敌人不会在小地图上显示红点
	local tbFile = LoadTabFile("Setting/Map/HideEnemyPos.tab", "dddd", nil, {"MapId", "PosX", "PosY", "Raduis"});
	for i,v in ipairs(tbFile) do
		tbHideEnemyPos[v.MapId] = tbHideEnemyPos[v.MapId] or {};
		table.insert(tbHideEnemyPos[v.MapId], { Raduis = v.Raduis, Pos = { v.PosX, v.PosY } })
	end
end

Map:LoadHideEnemyPos()

function Map:IsInHideEnemyPos( nMapId, x, y )
	local tbHideEnemyPos = self.tbHideEnemyPos[nMapId]
	if not tbHideEnemyPos then
		return
	end
	if self.nLastProcessHideEnemyPosMapId ~= nMapId then
		self.nLastProcessHideEnemyPosMapId = nMapId
		local tbProcessHideEnemyPos = {}
		self.tbProcessHideEnemyPos =  tbProcessHideEnemyPos

		table.sort( tbHideEnemyPos, function (a, b)
			return a.Raduis > b.Raduis
		end )
		local nMaxRadius = tbHideEnemyPos[1].Raduis
		self.nHideEnemyRegion = nMaxRadius
		--将所有点转化为对应  ReginX, ReginY 为key 设置的 集合里
		for i,v in ipairs(tbHideEnemyPos) do
			local rX = math.floor(v.Pos[1] / nMaxRadius)
			local rY = math.floor(v.Pos[2] / nMaxRadius)
			tbProcessHideEnemyPos[rX] = tbProcessHideEnemyPos[rX] or {}
			tbProcessHideEnemyPos[rX][rY] = tbProcessHideEnemyPos[rX][rY] or {};
			table.insert(tbProcessHideEnemyPos[rX][rY], v)
		end
	end

	local tbProcessHideEnemyPos = self.tbProcessHideEnemyPos
	local rXTaget = math.floor(x / self.nHideEnemyRegion)
	local rYTaget = math.floor(y / self.nHideEnemyRegion)
	for i=-1,1 do
		local rX = rXTaget + i
		if tbProcessHideEnemyPos[rX] then
			for j=-1,1 do
				local rY = rYTaget + j
				if tbProcessHideEnemyPos[rX][rY] then
					for _,v2 in ipairs(tbProcessHideEnemyPos[rX][rY]) do
						local nHideX, nHideY = unpack(v2.Pos)
						if Lib:GetDistsSquare(x, y, nHideX, nHideY) <= v2.Raduis * v2.Raduis then
							return true
						end
					end
				end
			end
		end
	end
end

function Map:OnSynMiniMapInfo(tbSynInfo) --[nIndex] = "Name"
	local tbMapTextPosInfo = Map:GetMapTextPosInfo(me.nMapTemplateId)
	for i,v in ipairs(tbMapTextPosInfo) do
		local szNewName = tbSynInfo[v.Index]
		if szNewName then
			v.Text = szNewName ;
		end
	end
end
