local tbUi = Ui:CreateClass("TeamBattleAccount");

function tbUi:OnOpen(nMyTeamId, tbShowInfo,nWinTeamId)
	local  bBalance = nWinTeamId ~= nil;
	local  nWindowStayTime = 0;

	if bBalance then
		nWindowStayTime = 5;
		if nMyTeamId == nWinTeamId then
			self.pPanel:SetActive("Victory", true);
			self.pPanel:SetActive("Failure", false);
		else
			self.pPanel:SetActive("Victory", false);
			self.pPanel:SetActive("Failure", true);
		end
	else
		nWindowStayTime = 5;
		self.pPanel:SetActive("Victory", false);
		self.pPanel:SetActive("Failure", false);
	end

	self.nTimeTimer = Timer:Register(nWindowStayTime * Env.GAME_FPS, self.onClose, self);

	for i = 0, 2 do
		self.pPanel:SetActive("My" .. i, false);
		self.pPanel:SetActive("Enemy" .. i, false);
	end

	for nTeamId, v in pairs(tbShowInfo) do
		local nIndex = 0;
		local szCamp = nTeamId == nMyTeamId and "My" or "Enemy";
		for _, tbInfo in pairs(v) do
			self:SetInfoIndexAt(bBalance, tbInfo, szCamp, nIndex);
			self.pPanel:SetActive(szCamp .. nIndex, true);

			nIndex = nIndex + 1;
		end
	end
end


function tbUi:SetInfoIndexAt(bBalance,tbInfo,szCamp,nIndex)
	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbInfo.nHonorLevel)
	if ImgPrefix then
		self.pPanel:SetActive(szCamp.."Rank"..tostring(nIndex),true);
		self.pPanel:Sprite_Animation(szCamp.."Rank"..tostring(nIndex), ImgPrefix, Atlas);
	else
		self.pPanel:SetActive(szCamp.."Rank"..tostring(nIndex),false);
	end

	local nTmpBigFace = PlayerPortrait:CheckBigFaceId(tbInfo.nBigFace, tbInfo.nPortrait, tbInfo.nFaction, tbInfo.nSex);
	local szHead, szAtlas = PlayerPortrait:GetPortraitBigIcon(nTmpBigFace);
	self.pPanel:Sprite_SetSprite(szCamp.."Head"..tostring(nIndex), szHead, szAtlas);
	local szFactionIcon = Faction:GetIcon(tbInfo.nFaction);
	self.pPanel:Sprite_SetSprite(szCamp.."Faction"..tostring(nIndex),szFactionIcon);
	self.pPanel:Label_SetText(szCamp.."Level"..tostring(nIndex), tbInfo.nLevel.."级");
	self.pPanel:Label_SetText(szCamp.."Name"..tostring(nIndex), tbInfo.szName);
	if bBalance then
		self.pPanel:Label_SetText(szCamp.."FightTitle"..tostring(nIndex), "杀人数：");
		self.pPanel:Label_SetText(szCamp.."FightValue"..tostring(nIndex), tbInfo.nKillCount);
		self.pPanel:SetActive(szCamp.."DmgValue"..tostring(nIndex), true);
		self.pPanel:SetActive(szCamp.."DamageTitle"..tostring(nIndex), true);
		self.pPanel:Label_SetText(szCamp.."DmgValue"..tostring(nIndex), tbInfo.nDamage);
	else
		self.pPanel:Label_SetText(szCamp.."FightTitle"..tostring(nIndex), "战力：");
		self.pPanel:Label_SetText(szCamp.."FightValue"..tostring(nIndex), tbInfo.nFightPower);
		self.pPanel:SetActive(szCamp.."DmgValue"..tostring(nIndex), false);
		self.pPanel:SetActive(szCamp.."DamageTitle"..tostring(nIndex), false);
	end
end

function tbUi:onClose()
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};


tbUi.tbOnClick.BtnClose = function (self)
	self:onClose();
end
