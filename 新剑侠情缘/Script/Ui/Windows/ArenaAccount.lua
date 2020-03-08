local tbUi = Ui:CreateClass("ArenaAccount");

--[[ 
	n VS n  = 
	{[My] = 位置0-3},
	{[Enemy] = 位置0-3},
]]
tbUi.tbSeq = 
{
	[1] = 
	{
		[1] = {
			[1] = {1},
			[2] = {2},
		},
		[2] = {
			[1] = {1},
			[2] = {1,2},
		},
		[3] = {
			[1] = {1},
			[2] = {0,1,2},
		},
		[4] = {
			[1] = {1},
			[2] = {0,1,2,3},
		},
	},
	[2] = 
	{
		[1] = {
			[1] = {1,2},
			[2] = {1},
		},
		[2] = {
			[1] = {1,2},
			[2] = {1,2},
		},
		[3] = {
			[1] = {1,2},
			[2] = {0,1,2},
		},
		[4] = {
			[1] = {1,2},
			[2] = {0,1,2,3},
		},
	},
	[3] = 
	{
		[1] = {
			[1] = {0,1,2},
			[2] = {1},
		},
		[2] = {
			[1] = {0,1,2},
			[2] = {1,2},
		},
		[3] = {
			[1] = {0,1,2},
			[2] = {1,2,3},
		},
		[4] = {
			[1] = {0,1,2},
			[2] = {0,1,2,3},
		},
	},
	[4] = 
	{
		[1] = {
			[1] = {0,1,2,3},
			[2] = {1},
		},
		[2] = {
			[1] = {0,1,2,3},
			[2] = {1,2},
		},
		[3] = {
			[1] = {0,1,2,3},
			[2] = {0,1,2},
		},
		[4] = {
			[1] = {0,1,2,3},
			[2] = {0,1,2,3},
		},
	},
}

tbUi.tbTitleLabel = 
{
	["QYHCross"] = {"胜率："}
}

function tbUi:OnOpen(nMyCamp, tbShowInfo, nWinCamp, tbParam)
	tbParam = tbParam or {}
	self.szKey = tbParam.szKey or "Default"
	local tbShowBtn = tbParam.tbShowBtn or {}
	self:OnClearAll()
	self:ShowBtn(tbShowBtn)
	local  bBalance = nWinCamp ~= nil;
	local  nWindowStayTime = 0;
	if bBalance then
		nWindowStayTime = tbParam.nStayTime or 3;
		if nMyCamp == nWinCamp then
   			self.pPanel:SetActive("Victory", true);
   			self.pPanel:SetActive("Failure", false);
   		else
   			self.pPanel:SetActive("Victory", false);
   			self.pPanel:SetActive("Failure", true);
		end
	else
		nWindowStayTime = 3;
		self.pPanel:SetActive("Victory", false);
   		self.pPanel:SetActive("Failure", false);
	end

	local nMyCount,nEnemyCount = self:GetMemberCount(nMyCamp,tbShowInfo)
	local tbSeqPos = self.tbSeq[nMyCount][nEnemyCount] or {}

	self.nTimeTimer = Timer:Register(nWindowStayTime * Env.GAME_FPS, self.onClose, self);

	for k,v in pairs(tbShowInfo) do
		local szCamp = "";
		local tbPos = {}
		if k==nMyCamp then
			szCamp = "My";
			tbPos = tbSeqPos[1] or {}
		else
			szCamp = "Enemy";
			tbPos = tbSeqPos[2] or {}
		end

		local nIndex = 1;

		for l,m in pairs(v) do
			local nPos = tbPos[nIndex] or 1
			self.pPanel:SetActive(szCamp ..tostring(nPos),true);
			self:SetInfoIndexAt(bBalance,m,szCamp,nPos);
			nIndex = nIndex + 1;
		end
	end
end

function tbUi:ShowBtn(ShowBtn)
	for _, szBtnName in ipairs(ShowBtn or {}) do
		self.pPanel:SetActive(szBtnName, true)
	end
end

function tbUi:GetMemberCount(nMyCamp,tbShowInfo)
	local nMyCount,nEnemyCount = 0,0
	for nCamp,tbInfo in pairs(tbShowInfo) do
	 	if nCamp == nMyCamp then
	 		nMyCount = #tbInfo
	 	else
	 		nEnemyCount = #tbInfo
	 	end
	 end
	 return nMyCount,nEnemyCount
end

function tbUi:SetInfoIndexAt(bBalance,tbInfo,szCamp,nIndex)
    if tbInfo.nHonorLevel > 0 then
		self.pPanel:SetActive(szCamp.."Rank"..tostring(nIndex),true);

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbInfo.nHonorLevel)
		self.pPanel:Sprite_Animation(szCamp.."Rank"..tostring(nIndex), ImgPrefix, Atlas);
		--self.pPanel:ChangePosition(szCamp.."Rank"..tostring(nIndex),-51,self.pPanel:GetPosition(szCamp.."Rank"..tostring(nIndex)).y);
	else
		self.pPanel:SetActive(szCamp.."Rank"..tostring(nIndex),false);
		--self.pPanel:ChangePosition(szCamp.."Rank"..tostring(nIndex),-81,self.pPanel:GetPosition(szCamp.."Rank"..tostring(nIndex)).y);
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
   		
   		local tbLabel = self.tbTitleLabel[self.szKey] or {}
   		local szFightTitleLabel = tbLabel[1] and tbLabel[1] or "战力："
		self.pPanel:Label_SetText(szCamp.."FightTitle"..tostring(nIndex), szFightTitleLabel);
		self.pPanel:Label_SetText(szCamp.."FightValue"..tostring(nIndex), tbInfo.nFightPower);
   		self.pPanel:SetActive(szCamp.."DmgValue"..tostring(nIndex), false);
   		self.pPanel:SetActive(szCamp.."DamageTitle"..tostring(nIndex), false);
   	end
end

function tbUi:OnClearAll()
   self.pPanel:SetActive("BtnContinue", false);
   self.pPanel:SetActive("Victory", false);
   self.pPanel:SetActive("Failure", false);
   for i=0,3 do
   		self.pPanel:SetActive("My" ..tostring(i),false);
   		self.pPanel:SetActive("Enemy" ..tostring(i),false);
   end
end

function tbUi:onClose()
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};


tbUi.tbOnClick.BtnClose = function (self)
	self:onClose();
end

tbUi.tbOnClick.BtnContinue = function (self)
	RemoteServer.QYHCrossClientCall("KeepTeam")
end
