
local tbUi = Ui:CreateClass("CampBattlePanel");

function tbUi:OnOpen()
	Battle:RequetCampTeamInfo()

	self:Update()
end

function tbUi:Update()
	if not Battle.nWinTeam then
		self.pPanel:SetActive("Failure", false)
		self.pPanel:SetActive("Victory", false)
	else
		self.pPanel:SetActive("Failure", Battle.nTeamIndex ~= Battle.nWinTeam)
		self.pPanel:SetActive("Victory", Battle.nTeamIndex == Battle.nWinTeam)
	end

	local tbPlayerInfos, tbAllBuildHpPercent = Player:GetServerSyncData("BattleCampTeamInfo")
	tbPlayerInfos = tbPlayerInfos or {}
	tbAllBuildHpPercent = tbAllBuildHpPercent or {};

	local tbTeams = {{},{}};
	for k,v in pairs(tbPlayerInfos) do
		v.dwID = k;
		table.insert( tbTeams[v.nTeamIndex] , v)
	end
	
	local tbUiPrefix = { "My", "Enemy" };
	for j=1,2 do
		local tbTeam = tbTeams[j]
		local szUiPrefix = tbUiPrefix[j]
		local nTotalKillNum = 0
		for i=1,6 do
			local tbInfo = tbTeam[i]
			if tbInfo then
				self.pPanel:SetActive(szUiPrefix .. (i - 1), true)
				self.pPanel:SetActive(string.format("%sLight%d", szUiPrefix, i-1), me.dwID == tbInfo.dwID)
				local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbInfo.nHonorLevel)
				local szUiHonor = string.format("%sRank%d",szUiPrefix, i-1)
			    if ImgPrefix then
			        self.pPanel:SetActive(szUiHonor, true)
			        self.pPanel:Sprite_Animation(szUiHonor, ImgPrefix, Atlas);            
			    else
			        self.pPanel:SetActive(szUiHonor, false)
			    end
			    self.pPanel:Label_SetText(string.format("%sName%d",szUiPrefix, i-1), tbInfo.szName)
			    self.pPanel:Label_SetText(string.format("%sFightValue%d",szUiPrefix, i-1), tbInfo.nKillCount)
			    nTotalKillNum = nTotalKillNum + tbInfo.nKillCount
			    self.pPanel:Label_SetText(string.format("%sLevel%d",szUiPrefix, i-1), tbInfo.nLevel .. "级")

				local nTmpBigFace = PlayerPortrait:CheckBigFaceId(tbInfo.nBigFace, tbInfo.nPortrait, tbInfo.nFaction, tbInfo.nSex)
		        local szBigIcon, szBigIconAtlas = PlayerPortrait:GetPortraitBigIcon(nTmpBigFace)
			    self.pPanel:Sprite_SetSprite(string.format("%sHead%d", szUiPrefix, i-1), szBigIcon, szBigIconAtlas)
			    local SpFaction = Faction:GetIcon(tbInfo.nFaction)
			    self.pPanel:Sprite_SetSprite(string.format("%sFaction%d", szUiPrefix, i-1), SpFaction)
			else
				self.pPanel:SetActive(szUiPrefix .. (i - 1), false)
			end
		end	
		self.pPanel:Label_SetText("KillTxt" .. j, nTotalKillNum)

		--建筑物的hp更新
		local tbHps = tbAllBuildHpPercent[j] or {};
		for i=1,3 do
			local nHpPercernt = math.floor( (tbHps[i] or 1) * 100 )	
			self.pPanel:SetActive(string.format("%sTowerMark%d",szUiPrefix, i), nHpPercernt == 0)
			local szOutPutLb = string.format("%sTowerOutPut%d",szUiPrefix, i);
			self.pPanel:Label_SetText(szOutPutLb, nHpPercernt .. "%");
			if nHpPercernt == 100 then
				self.pPanel:Label_SetColor(szOutPutLb, 200,255,0)
			else
				self.pPanel:Label_SetColor(szOutPutLb, 255,15,0)
			end
		end
	end

	
	
end

function tbUi:OnSyncData(szType)
	if szType == "BattleCampTeamInfo" then
		self:Update();
	end
end

function tbUi:OnClose()
end


tbUi.tbOnClick = {};


tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:RegisterEvent()
    return
    {
        { UiNotify.emNOTIFY_SYNC_DATA, self.OnSyncData, self},
    };
end
