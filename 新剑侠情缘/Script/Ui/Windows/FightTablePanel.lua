local tbUi = Ui:CreateClass("FightTablePanel");

tbUi.tbSetting = 
{
	["BiWuZhaoQin"] = {
		fnGetData = function ()
			return BiWuZhaoQin:GetFinalData()
		end,
	},
}

tbUi.tbChampionUi = {"Player","PlayerImformation","FactionIcon"}

function tbUi:OnOpen(szType)
	
	local tbSetting = self.tbSetting[szType]
	if not tbSetting or not tbSetting.fnGetData then
		return
	end
	self.tbData = tbSetting.fnGetData()
	self:ClearAll()
	if not self.tbData or not next(self.tbData) then
		return
	end
	self:Refresh()
end

function tbUi:Refresh()
	self:ClearAll()
	for nIndex,tbInfo in pairs(self.tbData) do
		for nPos,tbPlayerInfo in ipairs(tbInfo) do
			local szTeam = string.format("Team%d_%d",nIndex,nPos)
			 if self[szTeam] and next(tbPlayerInfo) then
		 		self[szTeam].pPanel:SetActive("Main",true)
				if szTeam == "Team4_1" then
					local nFaction = tbPlayerInfo.nFaction or 1
					local szName = tbPlayerInfo.szName or "未知"
					local nLevel = tbPlayerInfo.nLevel or 0
					local nFightPower = tbPlayerInfo.nFightPower or 0
					local nHonorLevel = tbPlayerInfo.nHonorLevel or 0
					local nPortrait = tbPlayerInfo.nPortrait or -1
					local nBigFace = tbPlayerInfo.nBigFace
					local nSex = tbPlayerInfo.nSex
					local szKinName = tbPlayerInfo.szKinName or "-"
					self[szTeam].pPanel:Label_SetText("PlayerName",szName)
					local SpFaction = Faction:GetIcon(nFaction)
					self[szTeam].pPanel:Sprite_SetSprite("FactionIcon",  SpFaction);
					self[szTeam].pPanel:Label_SetText("PlayerLevel", "等级：" ..nLevel);
					self[szTeam].pPanel:SetActive("PlayerTitle", nHonorLevel > 0);

					local ImgPrefix, Atlas = Player:GetHonorImgPrefix(nHonorLevel)
					self[szTeam].pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
					self[szTeam].pPanel:Label_SetText("PlayerFighting", "战力：" ..nFightPower);
					local nTmpBigFace = PlayerPortrait:CheckBigFaceId(nBigFace, nPortrait, nFaction, nSex);
					if nTmpBigFace ~= 0 then
						local szBigIcon, szBigIconAtlas = PlayerPortrait:GetPortraitBigIcon(nTmpBigFace)
  						self[szTeam].pPanel:Sprite_SetSprite("Player", szBigIcon, szBigIconAtlas)
  					end
				else
					self[szTeam].pPanel:Label_SetText("TeamName",tbPlayerInfo.szName or "")
				end
			end
		end
	end
end

function tbUi:ClearAll()
	for nIndex = 1,4 do
		for nPos = 1,8 do
			local szTeam = string.format("Team%d_%d",nIndex,nPos)
			if self[szTeam] then
				if szTeam == "Team4_1" then
					local bHaveChampion = self.tbData and self.tbData[4] and next(self.tbData[4])
					for _,szUiName in pairs(self.tbChampionUi) do
						self[szTeam].pPanel:SetActive(szUiName,bHaveChampion)
					end
					self[szTeam].pPanel:SetActive("ComingSoon",not bHaveChampion)
				else
					self[szTeam].pPanel:Label_SetText("TeamName","")
					self[szTeam].pPanel:SetActive("Main",false)
				end
			end
		end
	end
end

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end
}