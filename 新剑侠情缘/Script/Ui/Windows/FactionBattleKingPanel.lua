local tbNewInfoUi = Ui:CreateClass("NewInfo_FactionBattle")
function tbNewInfoUi:OnOpen(tbData)
    self.pPanel:SetActive("NewKingTitle", tbData or false)
    self.pPanel:SetActive("Number", false)
    self.pPanel:SetActive("ScrollViewFactionItem", tbData or false)
    self.pPanel:SetActive("BtnFactionShowOff", false);

    if not tbData then
        return
    end

    self:Update(tbData)
end

tbNewInfoUi.tbOnClick = tbNewInfoUi.tbOnClick or {};
function tbNewInfoUi.tbOnClick:BtnFactionShowOff()
    Ui:OpenWindow("MainShowOffPanel", "Faction");
end

local function GetInfo(idx, tbData)
	local info = tbData and tbData[idx] or FactionBattle.tbWinnerInfo[idx]
	if info then
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(info.nHonorLevel)
		local nTmpBigFace = PlayerPortrait:CheckBigFaceId(info.nBigFace, info.nPortrait, info.nFaction, info.nSex)
		local headIcon,headAtlas = PlayerPortrait:GetPortraitBigIcon(nTmpBigFace)
		if info.nPlayerId<=0 then
			headIcon = nil
			headAtlas = nil
		end
		return {
			faction = Faction:GetName(info.nFaction),
			familyName = info.szKinName,
			fightName = info.nFightPower,
			playerName = info.szName,
			playerTitle = ImgPrefix,
			playerTitleAtlas = Atlas,
			spRoleHead = headIcon,
			roleHeadAtlas = headAtlas,
			spFaction = Faction:GetIcon(info.nFaction),
			level = info.nLevel,
			nPlayerId = info.nPlayerId,
			szServerName = (info.nOrgServerId and info.nOrgServerId>0) and Sdk:GetServerDesc(info.nOrgServerId) or "",
		}
	end
end

function tbNewInfoUi:UpdateList(tbNewInfo, bCross)
	local bIAmWinner = false;
	local tbSorted = {}
	for i=1,Faction.MAX_FACTION_COUNT do
		if tbNewInfo then
			if tbNewInfo[2][i] then
				table.insert(tbSorted, tbNewInfo[2][i])
				if tbNewInfo[2][i].nPlayerId == me.dwID then
					bIAmWinner = true;
				end
			end
		else
			if FactionBattle.tbWinnerInfo[i] then
				table.insert(tbSorted, FactionBattle.tbWinnerInfo[i])
				if FactionBattle.tbWinnerInfo[i].nPlayerId == me.dwID then
					bIAmWinner = true;
				end
			end
		end
	end

	self.pPanel:SetActive("BtnFactionShowOff", bIAmWinner);

	local function fnSetItem(obj, i)
		for idx=1,2 do
			local info = GetInfo((i-1)*2+idx, tbSorted)
			local factionInfoName = string.format("FactionInfo%d", idx)
			local factionInfoPanel = obj[factionInfoName]
			obj.pPanel:SetActive(factionInfoName, info)
			if info then
				factionInfoPanel.pPanel:Label_SetText("Faction", info.faction)
				factionInfoPanel.pPanel:Label_SetText("TxtFamilyName", info.familyName)
				factionInfoPanel.pPanel:Label_SetText("TxtFightName", info.fightName)
				factionInfoPanel.pPanel:Label_SetText("TxtPlayerName", info.playerName)
				factionInfoPanel.pPanel:Label_SetText("AreaNum", info.szServerName)

				local nameOffsetX = 0
				if info.playerTitle then
					factionInfoPanel.pPanel:Sprite_Animation("PlayerTitle", info.playerTitle, info.playerTitleAtlas)
					nameOffsetX = 35
				else
					nameOffsetX = -22
				end
				local titlePos = factionInfoPanel.pPanel:GetPosition("PlayerTitle")
				factionInfoPanel.pPanel:ChangePosition("TxtPlayerName", titlePos.x+nameOffsetX, titlePos.y-3)

				factionInfoPanel.pPanel:SetActive("PlayerTitle", info.playerTitle)
				if info.spRoleHead then
					factionInfoPanel.pPanel:Sprite_SetSprite("Role", info.spRoleHead, info.roleHeadAtlas)
					factionInfoPanel.pPanel:SetActive("Role", true)
				else
					factionInfoPanel.pPanel:SetActive("Role", false)
				end
				factionInfoPanel.pPanel:Sprite_SetSprite("FactionIcon", info.spFaction)
				factionInfoPanel.pPanel:Label_SetText("TxtLevel", info.level)
				factionInfoPanel["BtnCheck"].nPlayerId = info.nPlayerId
				local fnOnClick = function (itemObj)
					ViewRole:OpenWindow("ViewRolePanel", itemObj.nPlayerId);
				end
				factionInfoPanel["BtnCheck"].pPanel.OnTouchEvent = fnOnClick
				factionInfoPanel.BtnCheck.pPanel:SetActive("Main", not bCross)

			end
		end
	end

	local rows = math.ceil(#tbSorted/2)
	self.ScrollViewFactionItem:Update(rows, fnSetItem)
end

tbNewInfoUi.tbBgTextures = {
	default = "NewKingBg",
	[FactionBattle.CROSS_TYPE.MONTH] = "NewKingBg2",
	[FactionBattle.CROSS_TYPE.SEASON] = "NewKingBg3",
}

function tbNewInfoUi:Update(tbNewInfo)
    local nCrossType = tbNewInfo[3]

    local szBg = string.format("UI/Textures/%s.png", self.tbBgTextures[nCrossType] or self.tbBgTextures.default)
    self.pPanel:Texture_SetTexture("NewKingTitle", szBg)

	if not nCrossType then
		local nSession = tbNewInfo and tbNewInfo[1] or FactionBattle.nSession
		self.pPanel:Label_SetText("Number", Lib:Transfer4LenDigit2CnNum(nSession))
		self.pPanel:SetActive("Number", true)
	end

	self:UpdateList(tbNewInfo, not not nCrossType)
end
