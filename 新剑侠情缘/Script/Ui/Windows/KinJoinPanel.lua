local tbUi = Ui:CreateClass("KinJoinPanel");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_KIN_DATA, self.Update, self },
		{ UiNotify.emNOTIFY_VOICE_PLAY_START, self.OnVoiceStart},
		{ UiNotify.emNOTIFY_VOICE_PLAY_END, self.OnVoiceEnd},
	};

	return tbRegEvent;
end

function tbUi:OnOpen()
	if me.nLevel < Kin.Def.nLevelLimite then
		me.CenterMsg(string.format("等级达到%d级后开放家族", Kin.Def.nLevelLimite));
		return 0;
	end

	self.tbApplied = Kin:GetData("tbKinApplied") or {};
	Kin:CacheData("tbKinApplied", self.tbApplied);

	self.nCurKinId = nil;
	self.tbVoice = nil
	Kin:UpdateJoinKinsData(1);
	self.pPanel:Label_SetText("Content", "");
	self.pPanel:SetActive("VoiceNode", false)
	self:Update("JoinKins");

	local bNoKin = not Kin:HasKin();
	self.pPanel:SetActive("BtnApply", bNoKin);
	self.pPanel:SetActive("BtnCreatFamily", bNoKin);
	self.pPanel:Label_SetText("Title", bNoKin and "加入家族" or "家族列表")

	if Ui:GetRedPointState("NG_KinJoin") then
		self.pPanel:Label_SetText("Name", Guide.ZHAOLIYING_NAME);
		self.pPanel:SetActive("GuideTips", true);
	else
		self.pPanel:SetActive("GuideTips", false);
	end

	local tbUserSet = Ui:GetPlayerSetting();
	self.pPanel:Button_SetCheck("BtnVoice", tbUserSet.bMuteGuideVoice);
end

function tbUi:Update(szType, tbKinsInfo, nPage, nMaxPage)
	if szType ~= "JoinKins" then
		return;
	end

	self.tbKinsInfo = tbKinsInfo or self.tbKinsInfo or {};
	self.nMaxPage = math.max(1, nMaxPage or self.nMaxPage or 1)
	self.nPage = nPage or self.nPage or 1;
	self.pPanel:Label_SetText("Pages", string.format("%d/%d", self.nPage, self.nMaxPage));

	local fnSelect = function (btnObj)
		self:PlayVoiceAni("VoiceBig4")
		self.pPanel:Label_SetText("Content", btnObj.tbItemData.szDeclaration);
		self.nCurKinId = btnObj.tbItemData.nKinId
		self.tbVoice = btnObj.tbItemData.tbVoice	

		local bHasVoice = self:HasVoice()
		local voiceSize = {x = 0, y = 0}
		self.pPanel:SetActive("VoiceNode", bHasVoice)
		if bHasVoice then
			self.pPanel:Label_SetText("TxtVoiceTime", Lib:TimeDesc4(math.floor(self.tbVoice[3] / 1000)))

			local speakerSize = self.pPanel:Sprite_GetSize("Speaker")
			local voiceTimeSize = self.pPanel:Label_GetPrintSize("TxtVoiceTime")
			voiceSize.y = math.max(speakerSize.y, voiceTimeSize.y)
		end

		local msgPos = self.pPanel:GetPosition("Content");
		self.pPanel:ChangePosition("Content", msgPos.x, -voiceSize.y - 10)
	end

	local bNoKin = not Kin:HasKin();
	for nIndex = 1, 7 do
		local itemObj = self["FamilyJoinItem" .. nIndex];
		local tbItemData = self.tbKinsInfo[nIndex];
		if tbItemData then
			itemObj.pPanel:SetActive("Main", true);
			itemObj.pPanel:Label_SetText("FamilyName", tbItemData.szName);
			itemObj.pPanel:Label_SetText("FamilyLeadName", tbItemData.szMasterName);
			local nVipLevel = tbItemData.nVipLevel
			if not nVipLevel or  nVipLevel == 0 then
				itemObj.pPanel:SetActive("VIP", false)
			else
				itemObj.pPanel:SetActive("VIP", true)
				itemObj.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
			end
			itemObj.pPanel:Label_SetText("Level", tbItemData.nLevel);
			itemObj.pPanel:Label_SetText("Number", tbItemData.nMemberCount .. "/" .. tbItemData.nMaxMemberCount);
			itemObj.pPanel:SetActive("Applied", self.tbApplied[tbItemData.nKinId] and bNoKin or false);
			local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbItemData.nHonorLevel)
			if ImgPrefix then
				itemObj.pPanel:SetActive("PlayerTitle", true);
				itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
			else
				itemObj.pPanel:SetActive("PlayerTitle", false);
			end

			itemObj.tbItemData = tbItemData;
			itemObj.pPanel.OnTouchEvent = fnSelect;

			if not self.nCurKinId and nIndex == 1 then
				fnSelect(itemObj);
			end
			itemObj.pPanel:Toggle_SetChecked("Main", tbItemData.nKinId == self.nCurKinId);
		else
			itemObj.pPanel:SetActive("Main", false);
		end
	end

	self.nKinCount = #self.tbKinsInfo;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("KinJoinPanel");
end

function tbUi.tbOnClick:BtnPanel()
	Guide.tbNotifyGuide:ClearNotifyGuide("KinJoin");
	self.pPanel:SetActive("GuideTips", false);
end

function tbUi.tbOnClick:BtnCreatFamily()
	Ui:OpenWindow("KinCreatePanel");
end

function tbUi.tbOnClick:BtnApply()
	if not self.nCurKinId then
		me.CenterMsg("请选择家族");
		return;
	end

	Ui:OpenWindow("KinApplyMsgPanel", self.nCurKinId)
end

function tbUi.tbOnClick:BtnLeft()
	local nPage = math.max(1, self.nPage - 1);
	if nPage == self.nPage then
		return;
	end

	Kin:UpdateJoinKinsData(nPage);
end

function tbUi.tbOnClick:BtnRight()
	local nPage = math.min(self.nMaxPage, self.nPage + 1);
	if nPage == self.nPage then
		return;
	end

	Kin:UpdateJoinKinsData(nPage);
end

function tbUi.tbOnClick:BtnVoice()
	ChatMgr:OnSwitchNpcGuideVoice()
end

function tbUi.tbOnClick:BackgroundSecond_01()
	if not self:HasVoice() then
		return
	end
	ChatMgr:PlayVoice(ChatMgr.nChannelKinDecl, self.tbVoice[1], self.tbVoice[2])
end

function tbUi:OnApplied(nKinId)
	self.tbApplied[nKinId] = true
	self:Update("JoinKins")
end

function tbUi:HasVoice()
	return #(self.tbVoice or {}) >= 2 and self.tbVoice[3] > 0 and GetTime() - self.tbVoice[4] < 24 * 3600
end

function tbUi:OnVoiceStart(uFileIdHigh, uFileIdLow, szApolloVoiceId)
	if not self:HasVoice() then
		return
	end
	if uFileIdHigh ~= self.tbVoice[1] or uFileIdLow ~= self.tbVoice[2] then
		return
	end
	self:PlayVoiceAni("VoiceBig")
end

function tbUi:OnVoiceEnd(uFileIdHigh, uFileIdLow, szApolloVoiceId)
	if not self:HasVoice() then
		return
	end
	if uFileIdHigh ~= self.tbVoice[1] or uFileIdLow ~= self.tbVoice[2] then
		return
	end
	self:PlayVoiceAni("VoiceBig4")
end

function tbUi:PlayVoiceAni(szAni)
	self.pPanel:Sprite_Animation("Speaker", szAni, nil, 4)
end