
local nBoxNpcId  = 208 ---宝箱 NpcId


local tbMapStepSetting = MapExplore.tbMapStepSetting

function MapExplore:CheckTimes()
	local nDegree = DegreeCtrl:GetDegree(me, "MapExplore")
	if nDegree <= 0 then
		me.BuyTimes("MapExplore", 5)
		return
	end
	return true
end

function MapExplore:Begin( nMapTemplateId, nStep )
	self.nMapTemplateId = nMapTemplateId
	self.nStep = nStep
	self.bCanMove = false
	self.nSerCallBackCalledTime = nil;
	self.nRequestTime = 0
	self.bMapLoaded = false
	
	self.nMapLoadCallBack = PlayerEvent:Register(me, "OnMapLoaded", self.OnMapLoaded, self); --在uinotify后面
	Ui:OpenWindow("ExplorationFubenPanel", self:GetMapGetItems(nMapTemplateId))
end

function MapExplore:GetMapGetItems(nMapTemplateId)
	if self.nLastnMapTemplateId and self.nLastnMapTemplateId == nMapTemplateId then
		self.tbLastGetItems = self.tbLastGetItems or {}
		self.nTotalCoin = self.nTotalCoin or 0;
	else
		self.tbLastGetItems = {}
		self.nTotalCoin = 0
		self.nLastnMapTemplateId = nMapTemplateId
	end
	return self.tbLastGetItems
end

function MapExplore:OnMapLoaded(nMapTemplateId)
	self.bMapLoaded = true
	MapExplore.bCanMove = true
	if nMapTemplateId ~= MapExplore.nMapTemplateId then
		me.OnEvent("StopAutoPath") 
		MapExplore:RequestLeave()
		self:CloseExplore()
		return
	end
	MapExplore:CheckLeave() --因为最后一步从遇敌战斗回到探索界面时有可能这样

	OpenAllDynamicObstacle(nMapTemplateId)

	if MapExplore.nStep == 0 then
		local tbStepInfo =  tbMapStepSetting[nMapTemplateId][1]
		me.GetNpc().SetDir(tbStepInfo[3])
	end
	
	Ui:ChangeUiState(Ui.STATE_MAPEXPLORE, true)
	AutoFight:Stop() --自动战斗下自动寻路不会触发寻路回调  打开	HomeScreenBattle时会重置成上次的自动战斗状态	

	local npcRep = Ui.Effect.GetNpcRepresent(me.GetNpc().nId);
	if npcRep then
		npcRep:ShowHeadUI(false)
	end
end

function MapExplore:CloseExplore()
	self.nMapTemplateId = nil
	self.nStep = nil
	Ui:CloseWindow("ExplorationFubenPanel")
	if self.nMapLoadCallBack then
		PlayerEvent:UnRegister(me, "OnMapLoaded", self.nMapLoadCallBack);
		self.nMapLoadCallBack = nil;
	end
end

function MapExplore:OnWalkEnd()
	self.nStep = self.nStep + 1
	self.tbMapStepInfo[self.nMapTemplateId] = self.nStep 
	
	RemoteServer.MapExploreWalkEnd(self.nMapTemplateId)
end

function MapExplore:OnServerWalkEnd(nKind, ...)
	self.nSerCallBackCalledTime = GetTime()
	
	if nKind == MapExplore.KIND_ENNEMY then
		local tbRoleInfo = select(1, ...)
		if not tbRoleInfo then
			UiNotify.OnNotify(UiNotify.emNOTIFY_MAP_EXPLORE_PANEL, "OnEndFindNothing")
			self:CheckLeave();
		else
			Ui:OpenWindow("MeetEnemyPanel", tbRoleInfo)
		end
	elseif nKind == MapExplore.KIND_ITEM then
		UiNotify.OnNotify(UiNotify.emNOTIFY_MAP_EXPLORE_PANEL, "PlayerAniGetItem", ...)
		self:CheckLeave();
	elseif nKind == MapExplore.KIND_COIN then
		UiNotify.OnNotify(UiNotify.emNOTIFY_MAP_EXPLORE_PANEL, "PlayerAniGetCoin", ...)
		self:CheckLeave();
	end
end


function MapExplore:OnFindEnemy(tbEnemyInfo, nStep)
	if not tbEnemyInfo then --防止一个空的宝箱
		self:OnFindAward()
		return
	end
	local nSex = Player:Faction2Sex(tbEnemyInfo.nFaction, tbEnemyInfo.nSex);
	local tbInitInfo = KPlayer.GetPlayerInitInfo(tbEnemyInfo.nFaction, nSex)
	local tbNextPos = tbMapStepSetting[self.nMapTemplateId][nStep + 1]
	local _, _, nX, nY, nDir = unpack(tbNextPos)
	local nDir = nDir + 32 
	if nDir > 63 then
		nDir = nDir - 63;
	end
	local pNpc = KNpc.Add(tbInitInfo.nNpcTemplateId, 1, 0, 0, nX, nY,  0, nDir)
	assert(pNpc)

	local tbNpcTInfo = KNpc.GetNpcTemplateInfo(tbInitInfo.nNpcTemplateId);
	local nResId = tbNpcTInfo.nNpcResID or 0

	pNpc.ChangeFeature(nResId, Npc.NpcResPartsDef.npc_part_body, tbInitInfo.nBodyResId);
 	pNpc.ChangeFeature(nResId, Npc.NpcResPartsDef.npc_part_weapon, tbInitInfo.nWeaponResId);
 	pNpc.ChangeFeature(nResId, Npc.NpcResPartsDef.npc_part_head, tbInitInfo.nHeadResId);
	
	pNpc.SetAiActive(0)
	pNpc.szName = tbEnemyInfo.szName
	pNpc.nCamp = 2
	pNpc.nStep = nStep
	if tbEnemyInfo.szKinName then
		pNpc.szKinTitle = tbEnemyInfo.szKinName
	end
	self.nBoxNpcId = pNpc.nId;
end

--发现道具或者银两时。 在下个地点放个宝箱npc --是在开始走时
function MapExplore:OnFindAward(nStep)
	local tbNextPos = tbMapStepSetting[self.nMapTemplateId][nStep + 1]
	local _, _, nX, nY, nDir = unpack(tbNextPos)  
	local pNpc = KNpc.Add(nBoxNpcId, 1, -1, 0, nX, nY, 0, nDir);
	assert(pNpc)
	-- pNpc.AddSkillState(nBoxSkillEffect, 1, 0, 999)
	self.nBoxNpcId = pNpc.nId;
	pNpc.nStep = nStep
end



function MapExplore:GetMapStepInfo()
	local nToDay = Lib:GetLocalDay(GetTime() - 3600 * 4)
	if not self.nLastUpdateDay or self.nLastUpdateDay ~= nToDay then
		self:RequestData()
		self.nLastUpdateDay = nToDay
	elseif self.tbMapStepInfo then
		return true
	end
end


function MapExplore:ResponseUpdateMapExplore(tbMapStepInfo, tbResetInfo)
	self.tbMapStepInfo = tbMapStepInfo -- [nMapTemplateId] = nStep
	self.tbResetInfo = tbResetInfo
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_SECTION_PANEL, "UpdateMapExplore")
end

function MapExplore:CheckLeave()
	if self.nStep == self.MAX_STEP then
		MapExplore:ReadyToLeave();
	end
end

function MapExplore:ReadyToLeave()
	local nTime = 5
	local bOpened = false
	self.nTimer = Timer:Register(Env.GAME_FPS * 1, function ()
		if self.bCanMove and not bOpened then
			Ui:OpenWindow("AutoLeaveTip", nTime)
			bOpened = true
		end
		nTime = nTime - 1
		if nTime < 0 then
			self.nTimer = nil
			MapExplore:DoLeave()
			return
		else
			return true
		end
	end)
end

function MapExplore:DoLeave()
	RemoteServer.MapExploreWalkLeave();
	self.nLastnMapTemplateId = nil;
end

function MapExplore:RequestLeave()
	if not self.bCanMove then
		return
	end
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil
	end

	local fnYes = function ()
		Ui:CloseWindow("AutoLeaveTip")
		MapExplore:DoLeave()
	end
	if DegreeCtrl:GetDegree(me, "MapExplore") > 0 and self.nStep and self.nStep >= 1 and self.nStep < self.MAX_STEP then
		me.MsgBox("你还有当前副本的探索次数，请问确定离开吗？", { {"确定", fnYes  }, {"取消"}} );
	else
		fnYes();
	end
end

function MapExplore:ClearData()
	self.tbMapStepInfo = nil;
	self.tbResetInfo = {};
	self.nLastUpdateDay = nil;
end

function MapExplore:RequestData()
	RemoteServer.RequestUpdateMapExplore();
	MapExplore.tbMapStepInfo = {}
	MapExplore.tbResetInfo = {};
end

function MapExplore:ClentRequeestReset(nMapTemplateId)
	local fnYes = function ()
		if me.GetMoney("Gold") < self.RESET_COST then
			Ui:OpenWindow("CommonShop", "Recharge", "Recharge")
			return
		end
		RemoteServer.MapExploreReset(nMapTemplateId)
	end

	Ui:OpenWindow("MessageBox",
	  string.format("您是否要花费 [FFFE0D]%d元宝[-] 来重置当前地图的探索进度？", self.RESET_COST),
	 { {fnYes},{} }, 
	 {"确定", "取消"});
	
end

local fnOnCLoseMapAttackCallBack = function ()
	me.Revive()
	Ui:CloseWindow("QYHbattleInfo")

	RemoteServer.ReEnterExplore()
end

function MapExplore:OnClientAttackResult(nResult, tbRoleInfo, nMinusHate, nRobCoin)
	Ui:OpenWindow("WantedAccountS", nResult == 1,  tbRoleInfo, nMinusHate, {"Coin", nRobCoin, szKindName = "巧遇目标"}, true, fnOnCLoseMapAttackCallBack)
end