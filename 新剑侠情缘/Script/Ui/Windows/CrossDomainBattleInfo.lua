local tbUi = Ui:CreateClass("CrossDomainBattleInfo");

function tbUi:OnOpen()
	RemoteServer.CrossDomainSelfReq()
	self:UpdateKingTranferRightInfo()

	self:UpdateTopKin()

	self:UpdateSelfInfo()

	if not self.nTimerId then
		local function _Refresh()
			RemoteServer.CrossDomainSelfReq()
			self:UpdateKingTranferRightInfo()
			self:UpdateTopKin()
			return true
		end

		self.nTimerId = Timer:Register(Env.GAME_FPS*20, _Refresh)
	end

end

function tbUi:UpdateTopKin(tbTopKinList, bUpdateSelf)
	tbTopKinList = tbTopKinList or DomainBattle.tbCross:GetTopKinInfo()
	local bHaveFirst = false
	local bHaveSelf = false
	for nRank, tbKinInfo in ipairs( tbTopKinList ) do
		if nRank == 1 and tbKinInfo then
			self.pPanel:SetActive("RankItem1", true)
			self.pPanel:Label_SetText("RoleName1", tbKinInfo.szShortName);
			self.pPanel:Label_SetText("RulingPower1", tostring(tbKinInfo.nScore));
			bHaveFirst = true
		elseif nRank > 1 and tbKinInfo.nKinId == me.dwKinId then
			bHaveSelf = true
			self:UpdateSelfInfo(nil, tbKinInfo)
		end
	end

	if not bHaveFirst then
		self.pPanel:SetActive("RankItem1", false)
	end

	if bUpdateSelf and not bHaveSelf then
		self.pPanel:SetActive("RankItem2", false)
	end
end

function tbUi:UpdateSelfInfo(_, tbKinInfo)
	if tbKinInfo then
		self.pPanel:SetActive("RankItem2", true)
		self.pPanel:Label_SetText("RoleName2", tbKinInfo.szShortName);
		self.pPanel:Label_SetText("RulingPower2", tostring(tbKinInfo.nScore));

		if tbKinInfo.nRank > 3 then
			self.pPanel:SetActive("RankIcon2", false)
			self.pPanel:SetActive("RankNum2", true)
			self.pPanel:Label_SetText("RankNum2", tostring(tbKinInfo.nRank));
		else
			self.pPanel:SetActive("RankIcon2", true)
			self.pPanel:SetActive("RankNum2", false)
			self.pPanel:Sprite_SetSprite("RankIcon2", "Rank_top" .. tbKinInfo.nRank)
		end
	else
		self:UpdateTopKin(nil, true)
	end
end

function tbUi:UpdateKingTranferRightInfo(tbRightList)
	tbRightList = tbRightList or DomainBattle.tbCross:GetKingTransferRightInfo()
	local nKinId = me.dwKinId
	local bHaveRight = false
	local bSelfAid,_,_ = DomainBattle.tbCross:GetSelfInfo()
	for _, tbKinInfo in pairs( tbRightList ) do
		if tbKinInfo[1] == nKinId then
			bHaveRight = true
			break;
		end
	end
	self.pPanel:SetActive("BtnRoyalCity", not bSelfAid and bHaveRight and DomainBattle.tbCross.nState <= 4 and
						 DomainBattle.tbCross:IsOuterMap(me.nMapTemplateId))
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
		{UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_KING_TRANSFER_RIGHT, self.UpdateKingTranferRightInfo, self},
		{UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_TOP_KIN_INFO, self.UpdateTopKin, self},
		{UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_SELF_INFO, self.UpdateSelfInfo, self},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnRoyalCity()
	me.SendBlackBoardMsg("正在前往临安王城…");
	AutoPath:GotoAndCall(me.nMapId, 18692, 11131);
end
