local tbUi = Ui:CreateClass("TerritoryCrossBattlefieldPanel");

function tbUi:OnOpen()
	self.pPanel:Label_SetText("FamilyName", string.format("家族:%s", DomainBattle.tbCross:GetSelfKinName()) );
	self.pPanel:Label_SetText("ResidualTime", string.format("战争剩余时间:%s", Lib:TimeDesc(DomainBattle.tbCross:GetTotalLeftTime())));

	if self.bActiveKingTab == nil then
		self.bActiveKingTab = false
	end

	if self.bActivePlayerTab == nil then
		self.bActivePlayerTab = false
	end

	self:UpdateOuterOccupyInfo()
	self:UpdateKingTranferRightInfo()
	self:UpdateKingTranferCountInfo()
	self:UpdateKingOccupyInfo()

	self.pPanel:SetActive("RuleAscription1", self.bActiveKingTab)
	self.pPanel:SetActive("RuleAscription2", not self.bActiveKingTab)
	self.pPanel:Toggle_SetChecked("BtnRoyal", self.bActiveKingTab);
	self.pPanel:Toggle_SetChecked("BtnSuburb", not self.bActiveKingTab);

	self.pPanel:SetActive("CurrentTerritory", self.bActiveKingTab)
	self.pPanel:SetActive("BtnChange", self.bActiveKingTab)

	self:UpdateTopKin()
	self:UpdateTopPlayer()

	RemoteServer.CrossDomainSelfReq()
	self:UpdateSelfInfo()

	self.pPanel:SetActive("Rank", self.bActivePlayerTab)
	self.pPanel:SetActive("FamilyRank", not self.bActivePlayerTab)
	self.pPanel:Toggle_SetChecked("BtnPersonal", self.bActivePlayerTab);
	self.pPanel:Toggle_SetChecked("BtnFamily", not self.bActivePlayerTab);

	if not self.nTimerId then
		local function _ShowTime()
			self.pPanel:Label_SetText("ResidualTime", string.format("战争剩余时间:%s", Lib:TimeDesc(DomainBattle.tbCross:GetTotalLeftTime())));
			return true
		end

		self.nTimerId = Timer:Register(Env.GAME_FPS, _ShowTime)
	end

	RemoteServer.CrossDomainKingCampInfoReq()
	local nCampIndex, bCanChangeCamp = DomainBattle.tbCross:GetKingCampInfo()
	self:UpdateKingCampInfo(nCampIndex, bCanChangeCamp)

	--结束后才显示领奖按钮
	self.pPanel:SetActive("BtnAward", DomainBattle.tbCross.nState > 4)
end

function tbUi:UpdateOuterOccupyInfo(tbOccupyList)
	tbOccupyList = tbOccupyList or DomainBattle.tbCross:GetOuterOccupyInfo()
	local nIndex = 0;
	for i = 0, 2 do
		self.pPanel:SetActive("LongZhu1" .. i, false)
		self.pPanel:SetActive("Family1" .. i, false)
	end

	for szNpcName, szKinName in pairs( tbOccupyList ) do
		self.pPanel:SetActive("LongZhu1" .. nIndex, true)
		self.pPanel:SetActive("Family1" .. nIndex, true)
		self.pPanel:Label_SetText("LongZhu1" .. nIndex, szNpcName);
		self.pPanel:Label_SetText("Family1" .. nIndex, szKinName);
		nIndex = nIndex + 1;
	end
end

function tbUi:UpdateKingTranferRightInfo(tbRightList)
	tbRightList = tbRightList or DomainBattle.tbCross:GetKingTransferRightInfo()

	for i = 1, 2 do
		self.pPanel:SetActive("FamilyQualifications" .. i, false)
	end

	local nIndex = 1;
	for _, tbKinInfo in pairs( tbRightList ) do
		self.pPanel:SetActive("FamilyQualifications" .. nIndex, true)
		self.pPanel:Label_SetText("FamilyQualifications" .. nIndex, tbKinInfo[2]);
		nIndex = nIndex + 1;
	end
end

function tbUi:UpdateKingTranferCountInfo(nCount)
	nCount = nCount or DomainBattle.tbCross:GetKingTransferCountInfo()
	self.pPanel:Label_SetText("FamilyNum", string.format("%d/%d",
				nCount, DomainBattle.tbCrossDef.nMaxKingPlayer));
end

function tbUi:UpdateKingOccupyInfo(tbKingOccupyList)
	tbKingOccupyList = tbKingOccupyList or DomainBattle.tbCross:GetKingOccupyInfo()

	for i = 1, 9 do
		self.pPanel:SetActive("LongZhu" .. i, false)
		self.pPanel:SetActive("Family" .. i, false)
	end

	local nIndex = 2;
	for szNpcName, szKinName in pairs( tbKingOccupyList ) do
		local szNpcCtrl
		local szKinCtrl
		if szNpcName == "王座"then
			szNpcCtrl = "LongZhu1"
			szKinCtrl = "Family1"
		else
			szNpcCtrl = "LongZhu" .. nIndex
			szKinCtrl = "Family" .. nIndex
			nIndex = nIndex + 1;
		end

		self.pPanel:SetActive(szNpcCtrl, true)
		self.pPanel:SetActive(szKinCtrl, true)
		self.pPanel:Label_SetText(szNpcCtrl, szNpcName);
		self.pPanel:Label_SetText(szKinCtrl, szKinName);
	end
end

function tbUi:UpdateTopKin(tbTopKinList)
	tbTopKinList = tbTopKinList or DomainBattle.tbCross:GetTopKinInfo()
	for i = 1, 10 do
		local tbKinInfo = tbTopKinList[i]
		if tbKinInfo then
			self.pPanel:SetActive("FamilyRankItem" .. i, true)
			self.pPanel:Label_SetText("FamilyName" .. i, tbKinInfo.szName);
			self.pPanel:Label_SetText("LeaderName" .. i, tbKinInfo.szMasterName);
			self.pPanel:Label_SetText("Rule" .. i, tostring(tbKinInfo.nScore));
		else
			self.pPanel:SetActive("FamilyRankItem" .. i, false)
		end
	end
end

function tbUi:UpdateTopPlayer(tbTopPlayerList)
	tbTopPlayerList = tbTopPlayerList or DomainBattle.tbCross:GetTopPlayerInfo()
	for i = 1, 10 do
		local tbPlayerInfo = tbTopPlayerList[i]
		if tbPlayerInfo then
			self.pPanel:SetActive("RankItem" .. i, true)
			self.pPanel:Label_SetText("RoleName" .. i, tbPlayerInfo.szName);
			self.pPanel:Label_SetText("Integral" .. i, tostring(tbPlayerInfo.nScore));
			self.pPanel:Label_SetText("KillNumber" .. i, tostring(tbPlayerInfo.nKillCount));
			self.pPanel:SetActive("Assist" .. i, tbPlayerInfo.bAid);
		else
			self.pPanel:SetActive("RankItem" .. i, false)
		end
	end
end

function tbUi:UpdateSelfInfo(tbPlayerInfo, tbKinInfo)
	if tbPlayerInfo then
		self.pPanel:SetActive("RankItem11", true)
		self.pPanel:Label_SetText("Number11", tostring(tbPlayerInfo.nRank));
		self.pPanel:Label_SetText("RoleName11", tbPlayerInfo.szName);
		self.pPanel:Label_SetText("Integral11", tostring(tbPlayerInfo.nScore));
		self.pPanel:Label_SetText("KillNumber11", tostring(tbPlayerInfo.nKillCount));
		self.pPanel:SetActive("Assist11", tbPlayerInfo.bAid);
	else
		self.pPanel:SetActive("RankItem11", false)
	end

	if tbKinInfo then
		self.pPanel:SetActive("FamilyRankItem11", true)
		self.pPanel:Label_SetText("FamilyName11", tbKinInfo.szName);
		self.pPanel:Label_SetText("LeaderName11", tbKinInfo.szMasterName);
		self.pPanel:Label_SetText("Rule11", tostring(tbKinInfo.nScore));
	else
		self.pPanel:SetActive("FamilyRankItem11", false)
	end
end

function tbUi:UpdateKingCampInfo(nCampIndex, bCanChangeCamp)
	nCampIndex = nCampIndex or 1
	self.pPanel:Label_SetText("CurrentTerritory", string.format("营地%s", Lib:Transfer4LenDigit2CnNum(nCampIndex)));
	self.pPanel:Button_SetEnabled("BtnChange", bCanChangeCamp)
end

function tbUi:OnClose()
	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_KING_TRANSFER_COUNT, self.UpdateKingTranferCountInfo, self},
		{UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_KING_TRANSFER_RIGHT, self.UpdateKingTranferRightInfo, self},
		{UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_OUTER_OCCUPY_INFO, self.UpdateOuterOccupyInfo, self},
		{UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_KING_OCCUPY_INFO, self.UpdateKingOccupyInfo, self},
		{UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_TOP_KIN_INFO, self.UpdateTopKin, self},
		{UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_TOP_PLAYER_INFO, self.UpdateTopPlayer, self},
		{UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_SELF_INFO, self.UpdateSelfInfo, self},
		{UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_CAMP_INFO, self.UpdateKingCampInfo, self},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("TerritoryFamilyAssistPanel")
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:BtnSuburb()
	self.bActiveKingTab = false
	self.pPanel:SetActive("RuleAscription1", false)
	self.pPanel:SetActive("RuleAscription2", true)

	self.pPanel:SetActive("CurrentTerritory", false)
	self.pPanel:SetActive("BtnChange", false)
	self:UpdateOuterOccupyInfo()
end

function tbUi.tbOnClick:BtnRoyal()
	self.bActiveKingTab = true
	self.pPanel:SetActive("RuleAscription1", true)
	self.pPanel:SetActive("RuleAscription2", false)

	self.pPanel:SetActive("CurrentTerritory", true)
	self.pPanel:SetActive("BtnChange", true)
	self:UpdateKingOccupyInfo()
end

function tbUi.tbOnClick:BtnFamily()
	self.bActivePlayerTab = false
	self.pPanel:SetActive("Rank", false)
	self.pPanel:SetActive("FamilyRank", true)
	self:UpdateTopKin()
end

function tbUi.tbOnClick:BtnPersonal()
	self.bActivePlayerTab = true
	self.pPanel:SetActive("Rank", true)
	self.pPanel:SetActive("FamilyRank", false)
	self:UpdateTopPlayer()
end

function tbUi.tbOnClick:BtnChange()
	Ui:OpenWindow("TerritoryChangePanel")
end

function tbUi.tbOnClick:BtnAward()
	Ui:OpenWindow("ChatLargePanel", ChatMgr.nChannelMail);
	Ui:CloseWindow(self.UI_NAME)
end

