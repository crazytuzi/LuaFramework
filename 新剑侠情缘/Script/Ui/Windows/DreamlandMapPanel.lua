local tbUi = Ui:CreateClass("DreamlandMapPanel");

function tbUi:OnOpen()
	RemoteServer.InDifferBattleRequestInst("RequetMapInfo", InDifferBattle.nSynClientDataVersion);
	self:Update()	
	self.nTimer =  Timer:Register(7, self.Update, self)
end

function tbUi:Update()
	local tbRooomPosSetting = InDifferBattle:GetRooomPosSetting(InDifferBattle.szBattleType)
	local tbCanUseRoomIndex = InDifferBattle.tbCanUseRoomIndex or {}
	local tbCurSingleNpcRoomIndex = InDifferBattle.tbCurSingleNpcRoomIndex or {};
	for nRow=1,5 do
		for nCol=1,5 do
			local nRoomIndex = tbRooomPosSetting[nRow][nCol].Index
			self.pPanel:Label_SetText("Number".. nRow .. nCol, nRoomIndex)
			self.pPanel:SetActive("Icon" .. nRow .. nCol, false)
			self.pPanel:SetActive("PositionTeammate" .. nRow .. nCol, false)
			self.pPanel:SetActive("PositionMyself" .. nRow .. nCol, false)

			self.pPanel:SetActive(string.format("PositionTeammate%d%d_1", nRow, nCol), false)
			self.pPanel:SetActive(string.format("PositionTeammate%d%d_2", nRow, nCol), false)

			local bShowLimit = false;
			if not tbCanUseRoomIndex[nRoomIndex] then
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

	local tbTeamRoomInfo = InDifferBattle.tbTeamRoomInfo or {}
	local nMyRoomIndex = tbTeamRoomInfo[me.dwID]
	local tbRoomIndex = InDifferBattle:GetSettingTypeField(InDifferBattle.szBattleType, "tbRoomIndex")
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
	InDifferBattle:_StartAutoGotoRoom(nRoomIndex, true)
	self:Update()
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
};

for i=1,5 do
	for j=1,5 do
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
