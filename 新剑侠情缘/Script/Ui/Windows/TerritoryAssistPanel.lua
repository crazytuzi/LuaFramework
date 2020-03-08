local tbUi = Ui:CreateClass("TerritoryAssistPanel");

function tbUi:OnOpen()
	local nMinHonorLevel = DomainBattle.tbCross:GetAidMinHonorLevel()
	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(nMinHonorLevel)
	self.pPanel:SetActive("ConditionTitle", ImgPrefix or false)
	if ImgPrefix then
		self.pPanel:Sprite_Animation("ConditionTitle", ImgPrefix, Atlas);
	end
	self:UpdateAidBrief()
end

function tbUi:UpdateAidBrief(nAidKinId, tbBriefInfo)
	if not nAidKinId then
		nAidKinId, tbBriefInfo = DomainBattle.tbCross:GetAidBriefInfo()
	end

	if not tbBriefInfo then
		return
	end

	local nKinId = me.dwKinId;
	local nTotalAidLimit = DomainBattle.tbCrossDef.nAidCount
	local nHonorLvl = me.nHonorLevel
	local nMinHonorLevel = DomainBattle.tbCross:GetAidMinHonorLevel()

	self.pPanel:SetActive("BtnAssistList", tbBriefInfo[nKinId] ~= nil)

	local tbKinList = {}
	for _, tbKinInfo in pairs( tbBriefInfo ) do
		table.insert(tbKinList, tbKinInfo)
	end

	local fnSetItem = function (itemObj, nIndex)
		local tbKinInfo = tbKinList[nIndex]
		itemObj.pPanel:Label_SetText("FamilyName", tbKinInfo.szKinName);
		itemObj.pPanel:Label_SetText("PalyerName", tbKinInfo.szMasterName);
		if tbKinInfo.nMasterHonorLvl > 0 then
			itemObj.pPanel:SetActive("PlayerTitle", true)
			local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbKinInfo.nMasterHonorLvl)
			itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		else
			itemObj.pPanel:SetActive("PlayerTitle", false)
		end

		itemObj.pPanel:Label_SetText("Number", string.format("%d/%d", nTotalAidLimit - tbKinInfo.nAidCount, nTotalAidLimit));

		if nAidKinId == tbKinInfo.nKinId then
			itemObj.pPanel:SetActive("BtnSignUp", false)
			itemObj.pPanel:SetActive("SignUp", true)
		else
			itemObj.pPanel:SetActive("BtnSignUp", true)
			itemObj.pPanel:SetActive("SignUp", false)
			itemObj.pPanel:Button_SetEnabled("BtnSignUp",
				nAidKinId == nil and DomainBattle.tbCross.bAidSignUp == true and
				(tbKinInfo.nAidCount < nTotalAidLimit) and
				nHonorLvl >= nMinHonorLevel and tbBriefInfo[nKinId] == nil);
		end

		itemObj.BtnSignUp.pPanel.OnTouchEvent = function ()
			if me.dwKinId > 0 then
				RemoteServer.CrossDomainAidSignUpReq(tbKinInfo.nKinId)
			else
				me.CenterMsg("没有家族，无法参加活动")
			end
		end
	end

	self.ScrollView:Update(#tbKinList, fnSetItem);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{UiNotify.emNOTIFY_SYNC_CROSS_DOMAIN_AID_BRIEF, self.UpdateAidBrief, self},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("TerritoryFamilyAssistPanel")
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:BtnAssistList()
	Ui:OpenWindow("TerritoryFamilyAssistPanel")
end