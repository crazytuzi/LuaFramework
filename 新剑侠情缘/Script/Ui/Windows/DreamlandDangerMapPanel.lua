local tbUi = Ui:CreateClass("DreamlandDangerMapPanel");

function tbUi:OnOpen()
	--todo 图标背景图的修改

	RemoteServer.InDifferBattleRequestInst("RequetMapInfo", InDifferBattle.nSynClientDataVersion);
	self:Update()	
	self.nTimer =  Timer:Register(7, self.Update, self)
end

function tbUi:Update()
	local tbRooomPosSetting = InDifferBattle:GetRooomPosSetting(InDifferBattle.szBattleType)
	local tbCanUseRoomIndex = InDifferBattle.tbCanUseRoomIndex or {}
	local tbCurSingleNpcRoomIndex = InDifferBattle.tbCurSingleNpcRoomIndex or {};
	for nRow=1,6 do
		for nCol=1,6 do
			local nRoomIndex = tbRooomPosSetting[nRow][nCol].Index
			self.pPanel:Label_SetText("Number".. nRow .. nCol, nRoomIndex)
			self.pPanel:SetActive("Icon" .. nRow .. nCol, false)
			self.pPanel:SetActive("PositionTeammate" .. nRow .. nCol, false)
			self.pPanel:SetActive("PositionMyself" .. nRow .. nCol, false)

			self.pPanel:SetActive(string.format("PositionTeammate%d%d_1", nRow, nCol), false)
			self.pPanel:SetActive(string.format("PositionTeammate%d%d_2", nRow, nCol), false)

			local bShowLimit = false;
			if not tbCanUseRoomIndex[nRoomIndex] or nRoomIndex == InDifferBattle.nCurFreshMonsterRooomIndex then
				bShowLimit = true
			end
			self.pPanel:SetActive("Limite" .. nRow .. nCol,  bShowLimit)
			self.pPanel:Label_SetText("Name" .. nRow .. nCol, "")
			if nRoomIndex == InDifferBattle.nAutoPathTarRoomIndex and Operation:GetTargetPos() then
				self.pPanel:SetActive("Light" .. nRow .. nCol, true) 	
				self.pPanel:SetActive("Flag" .. nRow .. nCol, true) 	
			else
				self.pPanel:SetActive("Light" .. nRow .. nCol, false) 	
			end
		end
	end
	local tbRoomIndex = InDifferBattle:GetSettingTypeField(InDifferBattle.szBattleType, "tbRoomIndex")

	--显示出仅有的安全区
	local tbOnlySafeRoom = InDifferBattle:GetOnlySafeRoomIndex()
	if tbOnlySafeRoom then
		self.pPanel:SetActive("SafetyZone", true)
		--找出左上角的，和右下角的 --
		local tbX = {};
		local tbY = {}
		local nMinRow,nMinCol,nMaxRow,nMaxCol = 999,999,0,0
		for _, nRoomIndex in ipairs(tbOnlySafeRoom) do
			local nRow, nCol = unpack(tbRoomIndex[nRoomIndex]) 		
			if nRow < nMinRow then
				nMinRow = nRow
			end
			if nRow > nMaxRow then
				nMaxRow = nRow
			end
			if nCol < nMinCol then
				nMinCol = nCol
			end
			if nCol > nMaxCol then
				nMaxCol = nCol
			end
		end
		local nGrid = nMaxRow - nMinRow + 1;
		local tbGridTopLeftPos 	 = 	self.pPanel:GetPosition("Item" .. nMinRow .. nMinCol )
		local tbGridBtomRightPos = 	self.pPanel:GetPosition("Item" .. nMaxRow .. nMaxCol )
		local x = (tbGridTopLeftPos.x + tbGridBtomRightPos.x) / 2
		local y = (tbGridTopLeftPos.y + tbGridBtomRightPos.y) / 2

		local width = nGrid == 1 and (100) or (tbGridBtomRightPos.x - tbGridTopLeftPos.x) / (nGrid - 1) * nGrid
		local height = nGrid == 1 and (100) or (tbGridTopLeftPos.y - tbGridBtomRightPos.y  ) / (nGrid - 1) * nGrid
		self.pPanel:ChangePosition("SafetyZone", x, y)
		self.pPanel:Widget_SetSize("SafetyZone", width, height)
	else
		self.pPanel:SetActive("SafetyZone", false)	
	end

	local tbTeamRoomInfo = InDifferBattle.tbTeamRoomInfo or {}
	local nMyRoomIndex = InDifferBattle:GetMyRoomIndex()
	
	local nRow, nCol = unpack(tbRoomIndex[nMyRoomIndex]) 
	self.pPanel:SetActive("PositionMyself" .. nRow .. nCol, true)
	local bSameOtherRoom = {};
	local tbMembers = TeamMgr:GetTeamMember();
	for i, v in ipairs(tbMembers) do
		local nRoomIndex = tbTeamRoomInfo[v.nPlayerID]
		if nRoomIndex and nRoomIndex ~= nMyRoomIndex then
			table.insert(bSameOtherRoom, {nRoomIndex, i})
		end
	end
	if #bSameOtherRoom == 2 and  bSameOtherRoom[1][1] == bSameOtherRoom[2][1] then
		local nRoomIndex = bSameOtherRoom[1][1]
		local nRow, nCol = unpack(tbRoomIndex[nRoomIndex]) 
		local SpFaction = Faction:GetIcon(tbMembers[1].nFaction)
		self.pPanel:Sprite_SetSprite(string.format("PositionTeammate%d%d_1", nRow, nCol),  SpFaction);
		self.pPanel:SetActive(string.format("PositionTeammate%d%d_1", nRow, nCol), true)

		local SpFaction = Faction:GetIcon(tbMembers[2].nFaction)
		self.pPanel:Sprite_SetSprite(string.format("PositionTeammate%d%d_2", nRow, nCol),  SpFaction);
		self.pPanel:SetActive(string.format("PositionTeammate%d%d_2", nRow, nCol), true)
	else
		for i,tbInfo in ipairs(bSameOtherRoom) do
			local nRoomIndex, nIndex = unpack(tbInfo)
			local v = tbMembers[nIndex]
			local nRow, nCol = unpack(tbRoomIndex[nRoomIndex]) 
			self.pPanel:SetActive("PositionTeammate" .. nRow .. nCol, true)
			local SpFaction = Faction:GetIcon(v.nFaction)
			self.pPanel:Sprite_SetSprite("PositionTeammate" .. nRow .. nCol,  SpFaction);
		end
	end

	---右上角的npc标识
	local tbCurSingleNpcRoomIndex = InDifferBattle.tbCurSingleNpcRoomIndex or {};
	local tbSingleRoomNpc = InDifferBattle:GetSettingTypeField(InDifferBattle.szBattleType, "tbSingleRoomNpc")
	for nRoomIndex, nNpcTemplateId in pairs(tbCurSingleNpcRoomIndex) do
		local tbNpcInfo = tbSingleRoomNpc[nNpcTemplateId]
		local nRow, nCol = unpack(tbRoomIndex[nRoomIndex]) 
		self.pPanel:SetActive("Icon" .. nRow .. nCol, true)
		self.pPanel:Sprite_SetSprite("Icon" .. nRow .. nCol, tbNpcInfo.szIcon);
		self.pPanel:Label_SetText("Name" .. nRow .. nCol, tbNpcInfo.szName)
	end
	return true
end

function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
end

function tbUi:OnClickItem(nRow, nCol)
	local nRoomIndex = InDifferBattle:GetRoomIndexByRowCol(InDifferBattle.szBattleType, nRow, nCol) 
	InDifferBattle:_StartAutoGotoRoom2(nRoomIndex, true)

	self:Update()
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
};

for i=1,6 do
	for j=1,6 do
		tbUi.tbOnClick["Item" .. i .. j] = function (self)
			self:OnClickItem(i,j)
		end
	end
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_INDIFFER_BATTLE_UI,   self.Update},
    };

    return tbRegEvent;
end
