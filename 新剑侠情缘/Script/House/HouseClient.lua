
function House:OnAddMapFurniture(nId, tbInfo)
	if not self.tbMapFurniture then
		return
	end
	self.tbMapFurniture[nId] = tbInfo;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAP_FURNITURE);
end

function House:OnRemoveMapFurniture(nId)
	if not self.tbMapFurniture then
		return
	end
	self.tbMapFurniture[nId] = nil;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAP_FURNITURE);
end

function House:OnSyncSingleFurniture(nTemplateId, nCount)
	self.tbFurniture = self.tbFurniture or {};
	self.tbFurniture[nTemplateId] = nCount > 0 and nCount or nil;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_FURNITURE);
end

function House:OnSyncHouseWaiYi(tbHouseWaiYi)
	self.tbHouseWaiYi = tbHouseWaiYi;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_FURNITURE);
end

function House:OnSyncChangeWaiYi(nPosId, nWaiYiId)
	self.tbWaiYiSetting = self.tbWaiYiSetting or {};
	self.tbWaiYiSetting[nPosId] = nWaiYiId;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_FURNITURE);
end

function House:OnSyncFurniture(tbFurniture)
	self.tbFurniture = tbFurniture or {};
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_FURNITURE);
end

function House:OnSyncMagicBowl(nOwner, tbData)
	self.tbMagicBowl = self.tbMagicBowl or {}
	self.tbMagicBowl[nOwner] = tbData
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAGICBOWL)
	House:CheckMagicBowlPrayRedPoint()
	Ui:ClearRedPointNotify("FurnitureMake")
end

function House:OnSyncMapFurniture(nVersion, tbMapFurniture)
	if self.nSyncMapFurnitureVersion~=nVersion then
		self.tbMapFurniture = {}
		self.nSyncMapFurnitureVersion = nVersion
	end
	self.tbMapFurniture = self.tbMapFurniture or {}
	for nIdx, tbFurniture in pairs(tbMapFurniture) do
		self.tbMapFurniture[nIdx] = tbFurniture
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAP_FURNITURE);
end

function House:OnSyncHouseInfo(tbHouseInfo, tbLover)
	self.dwOwnerId = tbHouseInfo.dwOwnerId;
	self.szName = tbHouseInfo.szName;
	self.nHouseLevel = tbHouseInfo.nLevel;
	self.nHouseMapId = tbHouseInfo.nMapId;
	self.tbRoomer = tbHouseInfo.tbRoomer or {};
	self.tbAccessInfo = tbHouseInfo.tbAccess or {};
	self.nStartLeveupTime = tbHouseInfo.nStartLeveupTime;
	self.tbHouseWaiYi = tbHouseInfo.tbHouseWaiYi;
	self.tbWaiYiSetting = tbHouseInfo.tbWaiYiSetting;
	self.tbTimeLimit = tbHouseInfo.tbTimeLimit
	self.tbLover = tbLover;

	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_HOUSE_INFO);

	if self.bDecorationMode and not self:HasDecorationAccess(me) then
		me.CenterMsg("大侠现在没有装修权限了！");
		self:ExitDecorationMode();
	end
end

function House:OnSyncMakeFurniture(nFurnitureItemId, bResult)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_MAKE_FURNITURE, nFurnitureItemId, bResult);
	self:CheckSetFurnitureMakeRedPoint()
end

function House:OnSetAccess(nType, bAccess)
	self.tbAccessInfo = self.tbAccessInfo or {};
	self.tbAccessInfo[nType] = bAccess;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_HOUSE_ACCESS, nType, bAccess);
end

function House:OnStartLevelUp(nStartLeveupTime)
	self.nStartLeveupTime = nStartLeveupTime;
	UiNotify.OnNotify(UiNotify.emNOTIFY_HOUSE_LEVELUP);
end

function House:OnSyncSwitchPlace()
	WeatherMgr:OnSyncSwitchPlace();
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_SWITCH_PLACE);
end

function House:OnSyncRoomers(tbRoomer, tbLover)
	self.tbRoomer = tbRoomer or {};
	self.tbLover = tbLover;

	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_HOUSE_INFO);
end

function House:GetComfortableShowInfo()
	local tbAllInfo = {};
	for _, tbInfo in pairs(self.tbMapFurniture or {}) do
		local tbFurniture = self:GetFurnitureInfo(tbInfo.nTemplateId);
		tbAllInfo[tbFurniture.nType] = tbAllInfo[tbFurniture.nType] or {};
		table.insert(tbAllInfo[tbFurniture.nType], {tbInfo.nTemplateId, tbFurniture.nComfortValue});
	end

	for _, tbInfo in pairs(tbAllInfo) do
		table.sort(tbInfo, function (a, b)
			if a[2] ~= b[2] then
				return a[2] > b[2];
			end
			return a[1] > b[1];
		end)
	end

	local nTotalValue = self:GetLevelComfort(self.nHouseLevel);
	local nMaxCount = #Furniture.tbNormalFurniture;
	for i = 1, nMaxCount do
		local nAddCount = self.tbComfortValueLimit[self.nHouseLevel or 1][i] or 0;
		if nAddCount > 0 then
			for i, tb in ipairs(tbAllInfo[i] or {}) do
				if i > nAddCount then
					break
				end
				nTotalValue = nTotalValue + tb[2]
			end
		else
			tbAllInfo[i] = nil;
		end
	end

	return nTotalValue, tbAllInfo;
end

function House:EnterDecorationMode()
	if not self:HasDecorationAccess(me) then
		return;
	end

	House:ChangeCameraSetting(unpack(House.tbDecorationModelCameraSetting));

	self.bDecorationMode = true;
	Ui:CloseWindow("PlantStatePanel");
	Ui:CloseWindow("MagicBowlHarvestPanel")
	Ui:SetAllUiVisable(false);
	Ui:OpenWindow("HouseDecorationPanel");

	RemoteServer.OnStartDecorationState();

	for _, tbRepInfo in pairs(Decoration.tbClientDecoration or {}) do
		local tbMainSeatInfo = House.tbMainSeatInfo[me.nMapTemplateId] or {-1};
		local tbTemplate = Decoration.tbAllTemplate[tbRepInfo.nTemplateId];
		local pRep = Ui.Effect.GetObjRepresent(tbRepInfo.nRepId);
		if tbRepInfo.nTemplateId ~= tbMainSeatInfo[1] and tbTemplate and pRep then
			pRep:SetColliderLogicSize(tbTemplate.nWidth * Decoration.CELL_LOGIC_WIDTH, tbTemplate.nHeight, tbTemplate.nLength * Decoration.CELL_LOGIC_HEIGHT);
			pRep:SetMapColliderActive(false);
		end
	end
end

function House:ExitDecorationMode()
	if not self.bDecorationMode then
		return;
	end

	self.bDecorationMode = false;

	House:ChangeCameraSetting(unpack(House.tbNormalCameraSetting));

	Ui:CloseWindow("HouseDecorationPanel");
	Ui:SetAllUiVisable(true);
	HousePlant:ShowPlantTip();
	if self.nMagicBowlRepId then
		Ui:OpenWindow("MagicBowlHarvestPanel", self.nMagicBowlRepId)
	end

	for _, tbRepInfo in pairs(Decoration.tbClientDecoration or {}) do
		local tbTemplate = Decoration.tbAllTemplate[tbRepInfo.nTemplateId];
		local pRep = Ui.Effect.GetObjRepresent(tbRepInfo.nRepId);
		if tbTemplate and pRep then
			if tbRepInfo.bCanOperation then
				pRep:SetColliderLogicSize(tbTemplate.nWidth * Decoration.CELL_LOGIC_WIDTH, tbTemplate.nHeight, tbTemplate.nLength * Decoration.CELL_LOGIC_HEIGHT);
			else
				pRep:SetColliderLogicSize(1, 1, 1);
			end
			pRep:SetMapColliderActive(true);
		end
	end
end

function House:ChangeCameraSetting(nDistance, nLookDownAngle)
	if self.tbCameraSetting then
		return;
	end

	local m, x, y = me.GetWorldPos();
	Ui.CameraMgr.MoveCameraToPositionWhithRotation(0.5, x, y, nDistance - Ui.CameraMgr.s_fCameraDistance, 1.0, nLookDownAngle);
	self.tbCameraSetting = {nDistance, nLookDownAngle};
end

function House:OnPlayCameraAnimationFinish()
	if not self.tbCameraSetting then
		return;
	end

	Ui.CameraMgr.ChangeCameraSetting(self.tbCameraSetting[1], self.tbCameraSetting[2], Ui.CameraMgr.s_fCameraFieldOfView);
	Ui.CameraMgr.LeaveCameraAnimationState();
	self.tbCameraSetting = nil;
end

function House:TipsLevelup()
	me.MsgBox("家园已升级完成，请前往[FFFE0D]颖宝宝[-]处确认。", {{"现在就去", function ()
		Ui.HyperTextHandle:Handle("[url=npc:testtt,2279,10]", 0, 0);
	end}, {"等会儿吧"}})
end

function House:OnLeaveMap(nMapTemplateId)
	if not nMapTemplateId or not Map:IsHouseMap(nMapTemplateId) then
		return;
	end

	if House:IsNormalHouse(nMapTemplateId) then
		Ui:CloseWindow("HouseCameraPanel");
		Ui:CloseWindow("HouseSharePanel");
		self:OnRemoveParrot()

		self.tbCameraSetting = nil;
	end

	if Ui:WindowVisible("TopButton") then
		local tbUi = Ui("TopButton");
		if tbUi.BtnTopFoldState then
			tbUi.tbOnClick.BtnTopFold(tbUi);
		end
	end

	self.tbPeach:OnLeaveHouse();
end

function House:OnConnectLost()
	if not me or not me.nMapTemplateId or not House:IsNormalHouse(me.nMapTemplateId) then
		return;
	end

	self.bDecorationMode = false;
	Ui:CloseWindow("HouseCameraPanel");
	Ui:CloseWindow("HouseSharePanel");
	Ui:CloseWindow("HouseDecorationPanel");
	if PlayerEvent.bLogin then
		Ui:ChangeUiState(Ui.STATE_DEFAULT, true);
		Ui.CameraMgr.ChangeCameraSetting(House.tbNormalCameraSetting[1], House.tbNormalCameraSetting[2], Ui.CameraMgr.s_fCameraFieldOfView);
		Ui.CameraMgr.LeaveCameraAnimationState();
	end

	self.tbCameraSetting = nil;
end

function House:OnSyncHasHouse(bHasHouse)
	self.bHasHouse = bHasHouse;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_HAS_HOUSE);
end

function House:OnCheckIn(dwOwnerId)
	Ui:RemoveNotifyMsg("HouseInvite");
	UiNotify.OnNotify(UiNotify.emNOTIFY_ROOMER_CHECKIN, dwOwnerId);
end

function House:OnCheckOut(dwOwnerId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_ROOMER_CHECKOUT, dwOwnerId);
end

function House:OnLogin(bIsReconnect)
	if bIsReconnect then
		if Ui:WindowVisible("TopButton") == 1 then
			Ui("TopButton"):RefreshHouseButton();
		end
	end
	self:UpdateMagicBowlData(me.dwID)
end

function House:OnMuseStart()
	Ui:OpenWindow("ProgressBarPanel", "Muse");
end

function House:OnMuseEnd(nLevel)
	Ui:CloseWindow("ProgressBarPanel");

	if nLevel then
		Ui:OpenWindow("VitalityEffectPanel", nLevel);
	end

	self:CheckMuseRedPoint();
end

function House:OnSyncHouesFriendList(tbFriendList)
	House.tbFriendList = {};
	for _, tbInfo in ipairs(tbFriendList) do
		local nImity = FriendShip:GetImity(me.dwID, tbInfo.dwPlayerId);
		if nImity then
			table.insert(House.tbFriendList, { dwPlayerId = tbInfo.dwPlayerId, nImity = nImity, bCanInvite = tbInfo.bCanInvite });
		end
	end

	table.sort(House.tbFriendList, function (a, b)
		if a.bCanInvite == b.bCanInvite then
			return a.nImity > b.nImity;
		else
			return a.bCanInvite;
		end
	end)

	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_HOUSE_FRIEND_LIST);
end

function House:GotoMuse()
	if House.bHasHouse then
		RemoteServer.TryMuse();
	else
		me.MsgBox("你还没有家园，传闻[FFFE0D]颖宝宝[-]处可打探到相关信息。",
		{
			{"现在就去", function () Ui.HyperTextHandle:Handle("[url=npc:testtt,2279,10]", 0, 0); end},
			{"等会儿吧"}
		});
	end
end

function House:GotoOwnHouse()
	Ui:CloseWindow("StrongerPanel");
	Ui:CloseWindow("HonorLevelPanel");

	if House.bHasHouse then
		RemoteServer.GoMyHome();
	else
		me.MsgBox("你还没有家园，传闻[FFFE0D]颖宝宝[-]处可打探到相关信息。",
		{
			{"现在就去", function () Ui.HyperTextHandle:Handle("[url=npc:testtt,2279,10]", 0, 0);  end},
			{"等会儿吧"}
		});
	end
end

function House:CheckMuseRedPoint()
	local bOpened = House:IsMuseOpened(me)
	local nTimes = DegreeCtrl:GetDegree(me, "Muse");
	if not bOpened or nTimes <= 0 then
		Ui:ClearRedPointNotify("Muse");
	else
		Ui:SetRedPointNotify("Muse");
	end
end

function House:CheckMagicBowlPrayRedPoint()
	local bHasAttr = false
	local tbMagicBowlData = House:GetMagicBowlData(me.dwID)
	if tbMagicBowlData and tbMagicBowlData.tbNewAttrs then
		bHasAttr = #tbMagicBowlData.tbNewAttrs > 0
	end

	local bOpened = Furniture.MagicBowl:IsOpened(me)
	local nLeftMagicBowlFree = self:MagicBowlGetPrayFreeCounts(me.dwID)
	if not bOpened or not bHasAttr or nLeftMagicBowlFree<=0 then
		Ui:ClearRedPointNotify("Pray")
	else
		Ui:SetRedPointNotify("Pray")
	end
end

function House:OnEnterMap(nMapTemplateId)
	if not nMapTemplateId or not House:IsNormalHouse(nMapTemplateId) then
		return;
	end

	Ui:CloseWindow("SocialPanel");
	Ui:CloseWindow("RankBoardPanel");
	Ui:CloseWindow("HonorLevelPanel");
end

function House:OnMapLoaded(nMapTemplateId)
	--@_@
    --Furniture.Cook:OnMapLoaded(nMapTemplateId)
	if not nMapTemplateId or not Map:IsHouseMap(nMapTemplateId) then
		return;
	end

	if House:IsNormalHouse(nMapTemplateId) then
		if House.dwOwnerId and House.dwOwnerId ~= me.dwID then
			me.SendBlackBoardMsg(string.format("进入了「%s」的家", House.szName or ""));
		end
	else
		local szMapName = Map:GetMapName(nMapTemplateId);
		me.SendBlackBoardMsg(string.format("进入了「%s」", szMapName or ""));
	end
	self:CheckSetFurnitureMakeRedPoint()
end

function House:CanMakeMagicBowl()
	return self:CheckCanMakeFurniture(me, 7694)
end

function House:CheckSetFurnitureMakeRedPoint()
	if House:IsInOwnHouse(me) and self:CanMakeMagicBowl() then
		Ui:SetRedPointNotify("FurnitureMake")
	else
		Ui:ClearRedPointNotify("FurnitureMake")
	end
end

function House:GotoKinDinnerParty(nMapId, nX, nY)
	AutoPath:GotoAndCall(nMapId, nX, nY, function()
		local nCount, tbItems = me.GetItemCountInBags(KinDinnerParty.Def.nPartyTokenId)
	    if nCount <= 0 then
	        return
	    end
	    Ui:OpenQuickUseItem(tbItems[1].dwId, "使 用")
	end)
end

function House:AutoMuse(nMapId, nX, nY)
	AutoPath:GotoAndCall(nMapId, nX, nY, function ()
		RemoteServer.TryMuse();
	end);
end

function House:OnSyncExtComfortLevel(nExtComfortLevel, nExtComfortOwnerId)
	self.nExtComfortLevel = nExtComfortLevel;
	self.nExtComfortOwnerId = nExtComfortOwnerId;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_EXT_COMFORTLEVEL);
end

function House:OnSyncLoverHouse(bHasHouse)
	self.bLoverHasHouse = bHasHouse;
end

function House:UpdateMagicBowlData(nOwner)
	self.tbMagicBowl = self.tbMagicBowl or {}
	local nVersion = (self.tbMagicBowl[nOwner] or {}).nVersion or 0
	RemoteServer.MagicBowlReq("UpdateData", nOwner, nVersion)
end

function House:GetMagicBowlData(nOwner)
	return (self.tbMagicBowl or {})[nOwner]
end

function House:MagicBowlPray()
	RemoteServer.MagicBowlReq("Pray")
end

function House:MagicBowlUpgrade(nId, tbMaterials)
	RemoteServer.MagicBowlReq("Upgrade", nId, tbMaterials or {})
	return true
end

function House:MagicBowlInscription()
	RemoteServer.MagicBowlReq("MakeInscription")
end

function House:MagicBowlInsStartStage(tbMaterials)
	RemoteServer.MagicBowlReq("InscriptionStartStage", tbMaterials or {})
	return true
end

function House:MagicBowlInsHarvest()
	RemoteServer.MagicBowlReq("InscriptionHarvest")
end

function House:MagicBowlConfirmPrayResult(bChooseNew)
	RemoteServer.MagicBowlReq("ConfirmPrayResult", bChooseNew)
end

local tbEquipClass = Item:GetClass("equip")
function House:MagicBowlGetAttrDesc(nSaveData)
	local nGrpId, nAttribLevel 	= Item.tbRefinement:SaveDataToAttrib(nSaveData);
	local tbAttr = {
		nExternAttribGrp = nGrpId,
		nAttribLevel = nAttribLevel,
	}

	local tbMA, _, szAttrib = Item.tbRefinement:GetAttribMA(tbAttr, Item.ITEM_INSCRIPTION)
    local szDesc = FightSkill:GetMagicDesc(szAttrib, tbMA)
    return szDesc, nAttribLevel
end

function House:MagicBowlGetAttrs()
	local tbNewAttrs = (self:GetMagicBowlData(me.dwID) or {}).tbNewAttrs
	if not tbNewAttrs then
		self:UpdateMagicBowlData(me.dwID)
		return
	end

	local tbRet = {}
	for _, nSaveData in ipairs(tbNewAttrs) do
		local nGrpId, nAttribLevel 	= Item.tbRefinement:SaveDataToAttrib(nSaveData);
		table.insert(tbRet, {
			nExternAttribGrp = nGrpId,
			nAttribLevel 	= nAttribLevel,
			nSaveData 		= nSaveData,
		})
	end
	return tbRet
end

function House:MagicBowlRefinementReq(nItemId, nSrcPos, nTargetPos)
	RemoteServer.MagicBowlReq("Refinement", nItemId, nSrcPos, nTargetPos)
end

function House:MagicBowlApplyAttrib(nGrpId, nLvl)
	me.ApplyExternAttrib(nGrpId, nLvl)
end

function House:MagicBowlOnRefinementResult(bRet, szMsg)
	if Ui:WindowVisible("MagicBowlRefinementPanel") == 1 then
		Ui("MagicBowlRefinementPanel"):OnRespond(bRet, szMsg);
	end
end

function House:OnMagicBowlUpgrade(nOldLevel, nNewLevel, nFurnitureId)
	if Ui:WindowVisible("MagicBowlPanel")==1 then
		Ui("MagicBowlPanel"):OnUpgrade(nFurnitureId)
	end
	me.CenterMsg("升级成功")
end

function House:MagicBowlAutoHarvest(nMapId, nX, nY)
	Ui:CloseWindow("MagicBowlPanel")
	Ui:CloseWindow("MagicBowlSelectMaterialPanel")

	AutoPath:GotoAndCall(nMapId, nX, nY, function ()
		Ui:OpenWindow("MagicBowlPanel");
	end, 100);
end

function House:MagicBowlOnCreateRepresent(nRepId)
	self.nMagicBowlRepId = nRepId
	Ui:CloseWindow("MagicBowlHarvestPanel")
	if not House.bDecorationMode then
		Ui:OpenWindow("MagicBowlHarvestPanel", nRepId)
	end
end

function House:MagicBowlGetPrayFreeCounts(nOwner)
	local nLeftFree, nTotalFree = 0, 0
	for _, tb in ipairs(Furniture.MagicBowl.Def.tbPrayCosts) do
		local nTime, nCost = unpack(tb)
		if nCost<=0 then
			nTotalFree = nTime
		else
			break
		end
	end

	local tbData = self:GetMagicBowlData(nOwner)
	if tbData then
		nLeftFree = nTotalFree
		local bNewDay = Lib:IsDiffDay(Furniture.MagicBowl.Def.nNewDayTime, GetTime(), tbData.tbPray.nLastUpdate)
		if not bNewDay and tbData.tbPray.nTimes>0 then
			nLeftFree = math.max(0, nTotalFree-tbData.tbPray.nTimes)
		end
	end
	return nLeftFree, nTotalFree
end

function House:GetFurnitureCountColor(nCurCount, nValidCount)
	if nCurCount > nValidCount then
		return "FF0000"
	elseif nCurCount == nValidCount then
		return "00FF00"
	end
	return "FFFFFF"
end

function House:OnMagicBowlMaterialResult(bEnough)
	local szUiName = "MagicBowlSelectMaterialPanel"
	if bEnough then
		Ui:CloseWindow(szUiName)
		return
	end

	if Ui:WindowVisible(szUiName) == 1 then
		Ui(szUiName):Refresh()
	end
end

function House:IsInHouseMap(  )
	if Player:IsInCrossServer() then
		return false
	end
	if House.nHouseMapId and me.nMapId == House.nHouseMapId then
		return true
	end
	return false
end

function House:OnDeleteDecoration(nRepId)
	if self.nParrotRepId == nRepId then
		self:OnRemoveParrot()
	end
end

function House:OnRemoveParrot()
	if self.nParrotTimer then
		Timer:Close(self.nParrotTimer)
		self.nParrotTimer = nil
	end
	if self.nParrotHiddenNpcId then
		local pNpc = KNpc.GetById(self.nParrotHiddenNpcId or 0)
		if pNpc then
			pNpc.Delete()
		end
		self.nParrotHiddenNpcId = nil
	end
	self.nParrotRepId = nil
end

function House:OnParrotUpdate(nOwner, tbData)
	self.tbParrot = {
		nOwner = nOwner,
		tbData = tbData,
	}
	UiNotify.OnNotify(UiNotify.emNOTIFY_HOUSE_PARROT_UPDATE)
end

function House:OnParrotCreated(tbRepInfo)
	local pNpc = KNpc.Add(self.nParrotHiddenNpcTempId, 1, 0, 0, tbRepInfo.nX, tbRepInfo.nY, 0, 0)
	if not pNpc then
		return
	end
	pNpc.bHide = true
	self.nParrotRepId = tbRepInfo.nRepId
	self.nParrotHiddenNpcId = pNpc.nId

	if self.nParrotTimer then
		Timer:Close(self.nParrotTimer)
		self.nParrotTimer = nil
	end
	self.nParrotTimer = Timer:Register(Env.GAME_FPS * House.nParrotTalkInterval, self.ParrotTalk, self)
	self:ParrotTalk()
end

function House:ParrotTalk()
	if not self.tbParrot then
		return true
	end

	local pNpc = KNpc.GetById(self.nParrotHiddenNpcId or 0)
	if not pNpc then
		return false
	end

	local szTalk, nDeadline = nil, nil
	for i = 1, 3 do
		self.nParrotTalkIdx = (self.nParrotTalkIdx or 0) % #House.tbParrotDefaultTalks + 1
		szTalk, nDeadline = unpack(self.tbParrot.tbData.tbTalks[self.nParrotTalkIdx] or {})
		if not szTalk or nDeadline <= GetTime() then
			szTalk = self.tbParrotDefaultTalks[self.nParrotTalkIdx]
		end
		if not Lib:IsEmptyStr(szTalk) then
			break
		end
	end
	if Lib:IsEmptyStr(szTalk) then
		return false
	end

	pNpc.BubbleTalk(szTalk, "5")
	return true;
end

function House:CanOpenPhotoState()
	if self.nHouseLevel >= self.nOpenPhotoStateMinLevel then
		return true;
	else
		return false;
	end
end