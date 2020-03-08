local tbUi = Ui:CreateClass("MiniMap");

tbUi.tbOpenUiFunc = {
	["DomainBattle"] =
	{
		nInterval = 5;
		fnIsExc = function (self)
			return DomainBattle:GetMapLevel(self.nMapTemplateId)
		end;
		fnExc = function (self, bInterval)
			if not bInterval then
				return
			end
			-- self.pPanel:Label_SetText("MapName", "领地关系")
			RemoteServer.DomainBattleRequestMapInfo();
		end;

	};
	["BattleCamp"] =
	{
		nInterval = 5;
		fnIsExc = function (self)
			return self.nMapTemplateId == Battle.tbAllBattleSetting.BattleMoba.nMapTemplateId
		end;
		fnExc = function (self, bInterval)
			local tbData = Player:GetServerSyncData("BattleCampMapInfo")
			if tbData then
				self:OnSyncData("BattleCampMapInfo")
			end
			if not bInterval then
				return
			end
			RemoteServer.BattleClientRequest("RequestCampMapInfo");
		end;
	};
	["DomainCityInfo"] =
	{
		nInterval = 3600;
		fnIsExc = function (self)
			if GetTimeFrameState(DomainBattle.define.szOpenTimeFrame) == 1 then
				for i,v in ipairs(DomainBattle.define.tbMasterStatuePos) do
					if v[1] == self.nMapTemplateId then
						return true
					end
				end
			end
			return false
		end;
		fnExc = function (self, bInterval)
			if not bInterval then
				return
			end
			RemoteServer.DomainBattleRequestMainMapInfo();
		end;
	};
	["DomainBattleCross"] =
	{
		nInterval = 5;
		fnIsExc = function (self)
			return DomainBattle.tbCross:IsDomainMap(self.nMapTemplateId)
		end;
		fnExc = function (self, bInterval)
			if not bInterval then
				return
			end

			DomainBattle.tbCross:MiniMapInfoReq()
		end;

	};
	["CrossDomainCityInfo"] =
	{
		nInterval = 3600;
		fnIsExc = function (self)
			if GetTimeFrameState(DomainBattle.tbCrossDef.szOpenFrame) == 1 and
				self.nMapTemplateId == 15 then

				return true
			end
			return false
		end;
		fnExc = function (self, bInterval)
			if not bInterval then
				return
			end
			RemoteServer.CrossDomainCityMiniMapStatueReq();
		end;
	};
};

function tbUi:OnOpen(nMapTemplateId)
	local nPlayerMapTemplateId = me.nMapTemplateId
	self.nMapTemplateId = nMapTemplateId or nPlayerMapTemplateId;
	local tbMapSetting = Map:GetMapSetting(self.nMapTemplateId);

	local tbMiniMapSetting, szMiniMap, tbChildMapSetting = Map:GetMiniMapInfo(self.nMapTemplateId);

	self.bInFightMap = Map:IsFieldFightMap(self.nMapTemplateId) or Map:IsBossMap(nPlayerMapTemplateId) or ImperialTomb:IsTombMap(nPlayerMapTemplateId);
	self.bIsBattle   = Map:IsBattleMap(nPlayerMapTemplateId);
	self.nMaxBattleNpcCount = self.nMaxBattleNpcCount or 1;
	self.nMaxTextPosCount = self.nMaxTextPosCount or 1;
	self.nMaxRobberNpcCount = self.nMaxRobberNpcCount or 1;
	self.nMaxBonfireCount = self.nMaxBonfireCount or 1;
	self.nMaxAttackMeCount = self.nMaxAttackMeCount or 1;

	self.nLastTargetX = nil;
	self.nLastTargetY = nil;
	self.nLastShowOther = nil;
	self.nCameraDirAngle = tbMapSetting.CameraDirAngle;
	self.pPanel:ChangeRotate("Rotation", self.nCameraDirAngle);
	self.pPanel:ChangeRotate("Target", 0);
	self.tbMainMapSetting = tbMiniMapSetting;		-- 主地图
	self.tbChildMapSetting = tbChildMapSetting; 	-- 子地图集
	self.tbCurMapSetting = nil;						-- 当前所在地图配置
	if not self.tbChildMapSetting then
		self:SwitchMiniMap(self.tbMainMapSetting, szMiniMap);
	end
	self.nLastPosX = nil;
	self.nLastPosY = nil;
	self:CheckCurMap();
	self:UpdateNpcList();

	self.pPanel:SetActive("Target", false);
	self.pPanel:SetActive("Player", self.nMapTemplateId == nPlayerMapTemplateId);
	self.pPanel:SetActive("AttackMe", self.bInFightMap or self.bIsBattle);
	self.bWtfMap = Fuben.WhiteTigerFuben:IsMyMap() --白虎堂地图
	self.pPanel:SetActive("WtfEnemyParent", self.bWtfMap)
	self.tbAutoMiniShowText = {};
	-- self.pPanel:Label_SetText("MapName", "江湖地图")

	local nNow = GetTime()
	for k,v in pairs(self.tbOpenUiFunc) do
		if v.fnIsExc(self) then
			local bInterval = false
			if (self.nRequestTime  or 0) + v.nInterval < nNow then
				bInterval = true
				self.nRequestTime = nNow
			end
			v.fnExc(self, bInterval)
			break;
		end
	end

	if not self.nStatueMapId or self.nStatueMapId ~= me.nMapId then
		self.nStatueMapId = me.nMapId;
		RemoteServer.RequestMapStatueInfo(me.nMapId);
	end
	self:UpdateStatueShow();
	self.nTimer = Timer:Register(1, self.Update, self);
	self:Update();

	local bOpenHouse = House:CheckOpen(me);
	self.pPanel:SetActive("BtnHome", bOpenHouse);
	self.pPanel:Label_SetText("BtnHouseLabel", "进入家园");
	self.pPanel:SetActive("BtnGroup", false);

	if House:IsInHouseMap() then
		self.pPanel:Label_SetText("MapInformation", string.format("%s的家", House.szName));
	else
		self.pPanel:Label_SetText("MapInformation", Map:GetMapDesc(self.nMapTemplateId));
	end

	local szMiniMapDesc = Map:GetMiniMapDesc(self.nMapTemplateId);
	if Lib:IsEmptyStr(szMiniMapDesc) then
		self.pPanel:SetActive("BossName", false);
	else
		self.pPanel:SetActive("BossName", true);
		self.pPanel:Label_SetText("BossName", szMiniMapDesc);
	end
end

function tbUi:SetNpcListShowing(bShow)
	Client:SetFlag("MiniMapShowNpcList", bShow or false);
end

function tbUi:IsNpcListShowing()
	return Client:GetFlag("MiniMapShowNpcList");
end

function tbUi:UpdateNpcList()
	if self:IsNpcListShowing() then
		self.pPanel:SetActive("NpcList", true);
		self:InitNpcList();
	else
		self.pPanel:SetActive("NpcList", false);
	end

	self:UpdateMapPosition();
end

function tbUi:UpdateMapPosition()
	if self:IsNpcListShowing() then
		self.pPanel:ChangePosition("MapTexture", 169, 3, 0);
	else
		self.pPanel:ChangePosition("MapTexture", 0, 3, 0);
	end

	local tbMapPos = self.pPanel:GetPosition("MapTexture");
	self.nOffsetX = tbMapPos.x;
	self.nOffsetY = tbMapPos.y;
end

function tbUi:InitNpcList()
	local tbNpcs = Map:GetMapNpcInfo(self.nMapTemplateId) or {};

	local tbItems = {};
	for _, tbNpc in pairs(tbNpcs) do
		if tbNpc.CanAutoPath == 1 then
			local tbItem = {
					nIdx = tbNpc.Index,
					szName = tbNpc.NpcName,
					nNpcTemplateId = tbNpc.NpcTemplateId,
					nPosX = tbNpc.XPos,
					nPosY = tbNpc.YPos,
					nNearLength = tbNpc.WalkNearLength,
				};
			tbItem.szTitle, tbItem.nColorId = KNpc.GetTitleById(tbNpc.TitleID);
			table.insert(tbItems, tbItem);
		end
	end

	table.sort(tbItems, function (a, b)
		return a.nIdx < b.nIdx;
	end);

	local fnOnSelect = function (buttonObj)
		local data = tbItems[buttonObj.Index];
		-- 当前需求只能打开本地图的miniMap
		AutoPath:GotoAndCall(me.nMapId, data.nPosX, data.nPosY, function ()
			local nNpcId = AutoAI.GetNpcIdByTemplateId(data.nNpcTemplateId);
			if nNpcId then
				Ui:CloseWindow("WorldMap");
				Ui:CloseWindow("MiniMap");
				Operation.SimpleTap(nNpcId);
			end
		end, data.nNearLength);
	end

	local fnSetItem = function(itemObj, index)
		local data = tbItems[index];
		itemObj.pPanel:Label_SetText("Name", data.szTitle and data.szName or "");
		itemObj.pPanel:Label_SetText("NameCenter", data.szTitle and "" or data.szName);
		itemObj.pPanel:Label_SetText("Description", data.szTitle or "");
		itemObj.pPanel:Label_SetColorById("Description", data.nColorId or 1);
		itemObj.Index = index;
		itemObj.pPanel.OnTouchEvent = fnOnSelect;
	end

	self.ScrollView:Update(#tbItems, fnSetItem);
end

function tbUi:Update()
	local _, nX, nY = me.GetWorldPos();
	if self.nLastPosX ~= nX or self.nLastPosY ~= nY then
		self.nLastPosX = nX;
		self.nLastPosY = nY;

		self:CheckCurMap();
		self:ShowMySelf();
	end

	self:ShowOthers();
	self:ShowTarget();

	return true;
end

function tbUi:ShowOthers()
	local nNow = GetTime();
	if nNow == self.nLastShowOther then --一秒刷新一次
		return;
	end

	self.nLastShowOther = nNow;

	-- 篝火
	if me.nMapTemplateId == Kin.Def.nKinMapTemplateId or me.nMapTemplateId == Kin.Def.nKinNestMapTemplateId then
		self.pPanel:SetActive("Bonfire", true);
		local tbFirePos = Map:GetMiniMapPos("Bonfire");
		if self.nMaxBonfireCount < #tbFirePos then
			for i = self.nMaxBonfireCount + 1, #tbFirePos do
				self.pPanel:CreateWnd("Bonfire1", "Bonfire" .. i);
			end
			self.nMaxBonfireCount = #tbFirePos;
		end

		for i = 1, self.nMaxBonfireCount do
			if tbFirePos[i] then
				self:ShowPos("Bonfire" .. i, tbFirePos[i][1], tbFirePos[i][2]);
			else
				self.pPanel:SetActive("Bonfire" .. i, false);
			end
		end
	else
		self.pPanel:SetActive("Bonfire", false);
	end

	-- 战场
	local tbBattlePos = Battle:GetMapShowPos();
	self.pPanel:SetActive("Others", #tbBattlePos > 0);
	if #tbBattlePos > 0 then
		if self.nMaxBattleNpcCount < #tbBattlePos then
			for i = self.nMaxBattleNpcCount + 1, #tbBattlePos do
				self.pPanel:CreateWnd("Battle1", "Battle" .. i);
			end
			self.nMaxBattleNpcCount = #tbBattlePos;
		end

		for i = 1, self.nMaxBattleNpcCount do
			if tbBattlePos[i] then
				self:ShowPos("Battle" .. i, tbBattlePos[i].nX, tbBattlePos[i].nY);
			else
				self.pPanel:SetActive("Battle" .. i, false);
			end
		end
	end
	--boss位置
	if self.nBossX and self.nBossY then
		self.pPanel:SetActive("Boss", true)
		self:ShowPos("Boss1", self.nBossX, self.nBossY)
	else
		self.pPanel:SetActive("Boss", false)
	end

	-- 队伍
	if TeamMgr:HasTeam() then
		self.pPanel:SetActive("Team", true);
		local tbTeamMatesPos = TeamMgr:GetTeamMatesPos();
		for i = 1, TeamMgr.MAX_MEMBER_COUNT - 1 do
			if tbTeamMatesPos[i] then
				self:ShowPos("Team" .. i, tbTeamMatesPos[i][1], tbTeamMatesPos[i][2]);
			else
				self.pPanel:SetActive("Team" .. i, false);
			end
		end
	else
		self.pPanel:SetActive("Team", false);
	end

	-- 镖车
	local showEscortCar = false
	local nMapId,x,y = Kin:GetEscortCarPos()
	if nMapId==me.nMapTemplateId then
		self:ShowPos("EscortCar1", x, y)
		showEscortCar = true
	end
	self.pPanel:SetActive("EscortCar", showEscortCar)

	-- 游城
	local bShowTour = false
	local nMapId, x, y = Wedding:GetMapNpcPos()
	if nMapId and nMapId == me.nMapId then
		self:ShowPos("ChairCar1", x, y)
		bShowTour = true
	end
	self.pPanel:SetActive("ChairCar", bShowTour)

	-- 显示周围可攻击自己的玩家
	if self.bInFightMap or self.bWtfMap or self.bIsBattle  then
		local tbAttackMePos = me.GetNpc().GetAttckMePlayersInfo();
		local tbFilterPos = {};
		for i,v in ipairs(tbAttackMePos) do
			if not Map:IsInHideEnemyPos(me.nMapTemplateId, v.nX, v.nY) then
				table.insert(tbFilterPos, v)
			end
		end

		local szNodeName = self.bWtfMap and "WtfEnemy" or "AttackMe"
		if self.nMaxAttackMeCount < #tbFilterPos then
			for i = self.nMaxAttackMeCount + 1, #tbFilterPos do
				self.pPanel:CreateWnd(szNodeName .. "1", szNodeName .. i);
			end
			self.nMaxAttackMeCount = #tbFilterPos;
		end

		for i = 1, self.nMaxAttackMeCount do
			if tbFilterPos[i] then
				self:ShowPos(szNodeName .. i, tbFilterPos[i].nX, tbFilterPos[i].nY);
			else
				self.pPanel:SetActive(szNodeName .. i, false);
			end
		end
	end

	--显示文本标签
	local tbTextInfo = Map:GetMapTextPosInfo(me.nMapTemplateId)
	if tbTextInfo and next(tbTextInfo) then
		self.pPanel:SetActive("Texts", true)
		if self.nMaxTextPosCount < #tbTextInfo then
			for i = self.nMaxTextPosCount + 1, #tbTextInfo do
				self.pPanel:CreateWnd("Text1", "Text" .. i);
			end
			self.nMaxTextPosCount = #tbTextInfo;
		end

		for i = 1, self.nMaxTextPosCount do
			local tbInfo = tbTextInfo[i]
			if tbInfo and tbInfo.NotShow ~= 1 then
				self:ShowPos("Text" .. i, tbInfo.XPos, tbInfo.YPos);
				local szText = tbInfo.Text;
				if self.tbAutoMiniShowText[tbInfo.Index] then
					szText = self.tbAutoMiniShowText[tbInfo.Index];
				end

				self.pPanel:Label_SetText("Text" .. i, szText)
				self.pPanel:ChangeLocalRotate("Text" .. i,  - self.nCameraDirAngle);
				local nFontSize = tbInfo.FontSize == 0 and 14 or tbInfo.FontSize
				self.pPanel:Label_SetFontSize("Text" .. i, nFontSize)

				if not Lib:IsEmptyStr(tbInfo.Color) then
					self.pPanel:Label_SetColorByName("Text" .. i, tbInfo.Color)
				else
					self.pPanel:Label_SetColorByName("Text" .. i, "White")
				end
			else
				self.pPanel:SetActive("Text" .. i, false);
			end
		end

	else
		self.pPanel:SetActive("Texts", false)
	end

end

function tbUi:ShowMySelf()
	local _, nX, nY = me.GetWorldPos();
	self:ChangePosition("Player", nX, nY);
end

function tbUi:ChangePosition(szWndName, nX, nY)
	nX, nY = self:GetShowPosition(nX, nY);
	self.pPanel:ChangePosition(szWndName, nX, nY, 0);
end

function tbUi:GetShowPosition(nX, nY)
	nX, nY = Map:GetMapPos(nX, nY);
	nX = (nX - self.tbCurMapSetting.BeginPosX - self.tbCurMapSetting.SizeX / 2) * self.nMapScale;
	nY = (nY - self.tbCurMapSetting.BeginPosY - self.tbCurMapSetting.SizeY / 2) * self.nMapScale;
	return nX, nY;
end

function tbUi:ShowPos(szWndName, nX, nY)
	if self.tbChildMapSetting and not Map:IsInMap(nX, nY, self.tbCurMapSetting) then
		self.pPanel:SetActive(szWndName, false);
		return;
	end

	self:ChangePosition(szWndName, nX, nY);
	self.pPanel:SetActive(szWndName, true);
end

function tbUi:ShowTarget()
	local nFlagX, nFlagY = Operation:GetTargetPos();
	if nFlagX and (nFlagX ~= self.nLastTargetX or nFlagY ~= self.nLastTargetY) then
		self.nLastTargetX = nFlagX;
		self.nLastTargetY = nFlagY;
		self:ShowPos("Target", self.nLastTargetX, self.nLastTargetY);
	elseif self.nLastTargetX and not nFlagX then
		self.nLastTargetX = nil;
		self.nLastTargetY = nil;
		self.pPanel:SetActive("Target", false);
	end
end

function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer);
		self.nTimer = nil;
	end
	self:CloseBattleCampTimer()
end

function tbUi:OnScreenClick()
	self.pPanel:SetActive("BtnGroup", false);
end

function tbUi:GetAllHouse(pPlayer)
	local tbHouse = {};

	if House.bHasHouse then
		table.insert(tbHouse, { dwOwnerId = pPlayer.dwID, szName = "我的家园" });
	end

	local nLandlordId = pPlayer.GetUserValue(House.USERGROUP_LANDLORD, House.USERKEY_LANDLORD);
	if nLandlordId ~= 0 then
		table.insert(tbHouse, { dwOwnerId = nLandlordId, szName = "寄居家园" });
	end

	local nLoverId = Wedding:GetLover(pPlayer.dwID);
	if nLoverId and House.bLoverHasHouse then
		table.insert(tbHouse, { dwOwnerId = nLoverId, szName = "伴侣家园"});
	end

	return tbHouse;
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick.BtnHome(self)
	Guide.tbNotifyGuide:ClearNotifyGuide("BtnHome");

	local tbHouse = self:GetAllHouse(me);
	local bShow = #tbHouse > 1;
	self.pPanel:SetActive("BtnGroup", bShow);

	self.tbHouse = nil;
	if bShow then
		self.tbHouse = tbHouse;
		for i = 1, 3 do
			local szBtn = "Btn" .. i;
			self.pPanel:SetActive(szBtn, tbHouse[i] and true or false);
			if tbHouse[i] then
				self.pPanel:Label_SetText("Txt" .. i, tbHouse[i].szName);
			end
		end
		self.pPanel:ChangePosition("Container", 0, #tbHouse == 3 and 0 or -28, 0);
		return;
	end

	if tbHouse[1] then
		AutoFight:StopAll();
		RemoteServer.EnterHome(tbHouse[1].dwOwnerId);
	else
		me.MsgBox("你还没有家园，传闻[FFFE0D]颖宝宝[-]处可打探到相关信息。",
			{
				{"现在就去", function () Ui.HyperTextHandle:Handle("[url=npc:testtt,2279,10]", 0, 0); end},
				{"等会儿吧"}
			});
	end

	Ui:CloseWindow(self.UI_NAME);
end

for i = 1, 3 do
	tbUi.tbOnClick["Btn" .. i] = function (self)
		AutoFight:StopAll();
		Ui:CloseWindow(self.UI_NAME);

		if not self.tbHouse or not self.tbHouse[i] then
			me.CenterMsg("未知错误！请重试");
			return;
		end
		RemoteServer.EnterHome(self.tbHouse[i].dwOwnerId);
	end
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("MiniMap");
end

function tbUi.tbOnClick:BtnBack()
	self:SetNpcListShowing(false);
	self:UpdateNpcList();
end

function tbUi.tbOnClick:BtnCheck()
	self:SetNpcListShowing(true);
	self:UpdateNpcList();
end

function tbUi.tbOnClick:BtnWorldMap()
	if DomainBattle:GetMapLevel(me.nMapTemplateId) then --领土战
		Ui:OpenWindow("DomainMap")
		Ui:CloseWindow(self.UI_NAME)
		return
	end
	Ui:OpenWindow("WorldMap");
	Ui:CloseWindow("MiniMap");
end

function tbUi.tbOnClick:MapTexture(_, nPosX, nPosY)
	nPosX = nPosX - self.nOffsetX;
	nPosY = nPosY - self.nOffsetY;

	local nLen = math.sqrt(nPosX * nPosX + nPosY * nPosY);
	local nAngle = math.atan2(nPosX, nPosY) + self.nCameraDirAngle / 180 * math.pi;
	local nX = math.sin(nAngle) * nLen;
	local nY = math.cos(nAngle) * nLen;

	nPosX = (nX / self.nMapScale + self.tbCurMapSetting.SizeX / 2 + self.tbCurMapSetting.BeginPosX - self.tbMainMapSetting.BeginPosX);
	nPosY = (nY / self.nMapScale + self.tbCurMapSetting.SizeY / 2 + self.tbCurMapSetting.BeginPosY - self.tbMainMapSetting.BeginPosY);
	nPosX = math.max(math.min(self.tbMainMapSetting.SizeX, nPosX), 0) / Map.CELL_WIDTH;
	nPosY = math.max(math.min(self.tbMainMapSetting.SizeY, nPosY), 0) / Map.CELL_WIDTH;

	if self.nMapTemplateId ~= me.nMapTemplateId then
		AutoPath:GotoAndCall(self.nMapTemplateId, nPosX, nPosY);
		return;
	end

	AutoFight:StopAll();
	Operation:ClickMapIgnore(nPosX, nPosY, true);
end

function tbUi:OnSyncData(szType)
	if szType == "MiniStatue" then
		self:UpdateStatueShow();
	elseif szType == "BattleCampMapInfo" then
		local tbData = Player:GetServerSyncData("BattleCampMapInfo") or {};
		local tbMapShowInfo, nBossNpcId, nBossBornLeftTime, nX, nY = tbData.tbMapShowInfo, tbData.nNpcId, tbData.nLeftTime, tbData.nX, tbData.nY;
		self:OnSynMapTextPosInfo(tbMapShowInfo)
		self:OnSynBattleCampBossInfo(nBossNpcId, nBossBornLeftTime, nX, nY);
	end
end

function tbUi:OnSynMapTextPosInfo(tbMapTextPosInfo)
	local tbMapTextPosInfoOld = Map:GetMapTextPosInfo(me.nMapTemplateId)
	for i,v in ipairs(tbMapTextPosInfoOld) do
		local szNewName = tbMapTextPosInfo[v.Index]
		if szNewName then
			v.Text = szNewName ;
		elseif v.Index == "BossTime" then
			v.Text = ""; --先重置
		end
	end
end

function tbUi:CloseBattleCampTimer()
	if self.nTimerBattleCamp then
		Timer:Close(self.nTimerBattleCamp)
		self.nTimerBattleCamp = nil;
	end
	self.nBossX = nil;
	self.nBossY = nil;
end

function tbUi:OnSynBattleCampBossInfo(nBossNpcId, nBossBornLeftTime, nX, nY)
	self:CloseBattleCampTimer();
	if nBossBornLeftTime and nBossBornLeftTime > 0 then
		nBossBornLeftTime = nBossBornLeftTime + 1;
		local fnUpdate = function ()
			nBossBornLeftTime = nBossBornLeftTime - 1;
			local tbMapTextPosInfoOld = Map:GetMapTextPosInfo(me.nMapTemplateId)
			for i,v in ipairs(tbMapTextPosInfoOld) do
				if v.Index == "BossTime" then
					v.Text = nBossBornLeftTime > 0 and Lib:TimeDesc(nBossBornLeftTime) or "";
					break;
				end
			end

			if nBossBornLeftTime <= 0 then
				self.nTimerBattleCamp = nil;
				self.tbOpenUiFunc.BattleCamp.fnExc(self, true)
				return
			else
				return true
			end
		end
		fnUpdate()
		self.nTimerBattleCamp = Timer:Register(Env.GAME_FPS , fnUpdate)
	end
	if nBossNpcId and nX and nY then
		self.nBossX = nX;
		self.nBossY = nY;
	end
end

function tbUi:UpdateStatueShow()
    local tbStatueShow = Player:GetServerSyncData("MiniStatue");
	if not tbStatueShow then
		return;
	end

	if tbStatueShow.nMapId ~= me.nMapId then
		return;
	end

	self.tbAutoMiniShowText = self.tbAutoMiniShowText or {};
	for szType, szName in pairs(tbStatueShow.tbShow) do
		self.tbAutoMiniShowText[szType] = szName;
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{UiNotify.emNOTIFY_MAP_LEAVE, self.OnLeaveMap, self},
		{ UiNotify.emNOTIFY_SYNC_DATA, self.OnSyncData, self},
	};

	return tbRegEvent;
end

function tbUi:OnLeaveMap()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:CheckCurMap()
	if not self.tbChildMapSetting then
		return;
	end

	local _, nX, nY = me.GetWorldPos();
	if self.tbCurMapSetting then
		if Map:IsInMap(nX, nY, self.tbCurMapSetting) then
			return;
		end
	end

	for _, tbInfo in ipairs(self.tbChildMapSetting) do
		if self.tbCurMapSetting ~= tbInfo.tbSetting and Map:IsInMap(nX, nY, tbInfo.tbSetting) then
			self:SwitchMiniMap(tbInfo.tbSetting, tbInfo.szMiniMap);
			return;
		end
	end
end

function tbUi:SwitchMiniMap(tbMapSetting, szMiniMap)
	self.tbCurMapSetting = tbMapSetting;
	self.nMapScale = Map:GetMapOrgScale(szMiniMap);

	local szImgPath = "UI/Textures/MiniMap/" .. szMiniMap .. ".jpg";
	self.pPanel:Texture_SetTexture("MapTexture", szImgPath);
end
