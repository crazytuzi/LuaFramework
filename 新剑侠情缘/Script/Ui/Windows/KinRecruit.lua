local tbUi = Ui:CreateClass("KinRecruit");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_KIN_DATA, self.UpdateData, self },
		{ UiNotify.emNOTIFY_VOICE_PLAY_START, self.OnVoiceStart},
		{ UiNotify.emNOTIFY_VOICE_PLAY_END, self.OnVoiceEnd},
	};

	return tbRegEvent;
end

function tbUi:OnOpen()
	Kin:UpdateRecruitSetting();
	self:UpdateData("RecruitSetting");
	self:InitBtnVoiceInput()
	self:UpdateVoiceIcon()
end

function tbUi:UpdateVoiceIcon()
	self:PlayVoiceAni("VoiceBig4")
	local bHasVoice = self:HasVoice()
	local voiceSize = {x = 0, y = 0}
	self.pPanel:SetActive("VoiceNode", bHasVoice)
	if bHasVoice then
		self.pPanel:Label_SetText("TxtVoiceTime", Lib:TimeDesc4(math.floor(self.tbVoiceInfo.nVoiceTime / 1000)))

		local speakerSize = self.pPanel:Sprite_GetSize("Speaker")
		local voiceTimeSize = self.pPanel:Label_GetPrintSize("TxtVoiceTime")
		voiceSize.x = speakerSize.x + voiceTimeSize.x
		voiceSize.y = math.max(speakerSize.y, voiceTimeSize.y)
	end

	local msgPos = self.pPanel:GetPosition("TxtFamilyDeclare");
	self.pPanel:ChangePosition("TxtFamilyDeclare", msgPos.x, -voiceSize.y + 93)
end

function tbUi:InitBtnVoiceInput()
	local fnCallback = function (szMsg,uFileIdHigh,uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
		if szMsg ~= "" then
			self.pPanel:Input_SetText("TxtFamilyDeclare", szMsg)
		end
		self.tbVoiceInfo = {
			nHigh = uFileIdHigh,
			nLow = uFileIdLow,
			szFilePath = strFilePath,
			nVoiceTime = nVoiceTime,
		}
		self:UpdateVoiceIcon()
	end

	local fnCheckVoiceSend = function ()
		return true
	end

	local nVoiceTime = ChatMgr:GetMaxVoiceTime(ChatMgr.nChannelKinDecl)
	self.pPanel:FlyCom_Init("BtnVoice", fnCallback, fnCheckVoiceSend, nVoiceTime);
end

function tbUi:UpdateData(szType)
	if szType ~= "RecruitSetting" then
		return;
	end

	local tbRecruitSetting = Kin:GetRecruitSetting() or {};
	self.pPanel:Input_SetText("TxtFamilyDeclare", tbRecruitSetting.szAddDeclare or "");
	if tbRecruitSetting.tbVoice and GetTime() - tbRecruitSetting.tbVoice[4] < 24 * 3600 then
		self.tbVoiceInfo = {
			nHigh = tbRecruitSetting.tbVoice[1],
			nLow = tbRecruitSetting.tbVoice[2],
			nVoiceTime = tbRecruitSetting.tbVoice[3],
		}
		self:UpdateVoiceIcon()
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnSaveChange()
	local szDeclare = self.pPanel:Input_GetText("TxtFamilyDeclare");
	local tbRecruitSetting = Kin:GetRecruitSetting();

	szDeclare = ReplaceLimitWords(szDeclare) or szDeclare;
	if Lib:Utf8Len(szDeclare) > Kin.Def.nMaxAddDeclareLength then
		me.CenterMsg("家族宣言超过最大长度:" .. Kin.Def.nMaxAddDeclareLength);
		return false;
	end
	szDeclare = ChatMgr:Filter4CharString(szDeclare);

	if szDeclare == tbRecruitSetting.szAddDeclare then
		me.CenterMsg("宣言没有改动")
		return false
	end

	local function fnDoChange()
		tbRecruitSetting.szAddDeclare = szDeclare;
		local tbVoice = nil
		if self.tbVoiceInfo then
			tbVoice = {self.tbVoiceInfo.nHigh, self.tbVoiceInfo.nLow, self.tbVoiceInfo.nVoiceTime, GetTime()}
		end
		Kin:ChangeAddDeclare(szDeclare, tbVoice);
		Ui:CloseWindow("KinRecruit");
	end

	if self.tbVoiceInfo then
		if ChatMgr:CheckVoiceSendEnable() and ChatMgr:IsValidVoiceMsg(0, self.tbVoiceInfo.nHigh, self.tbVoiceInfo.nLow, self.tbVoiceInfo.szFilePath) then
			local voiceData, dataLen = Lib:ReadFileBinary(self.tbVoiceInfo.szFilePath)
			if voiceData and dataLen > 0 then
				FileServer:SendVoiceFile(self.tbVoiceInfo.nHigh, self.tbVoiceInfo.nLow, voiceData, function (bRet)
					if not bRet then
						self.tbVoiceInfo = nil
					else
						fnDoChange()
					end
				end,
				false)
			end
		else
			self.tbVoiceInfo = nil
		end
	else
		fnDoChange()
	end
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("KinRecruit");
end

function tbUi.tbOnClick:Speaker()
	if not self:HasVoice() then
		return
	end
	ChatMgr:PlayVoice(ChatMgr.nChannelKinDecl, self.tbVoiceInfo.nHigh, self.tbVoiceInfo.nLow)
end

function tbUi:HasVoice()
	return not not self.tbVoiceInfo
end

function tbUi:OnVoiceStart(uFileIdHigh, uFileIdLow)
	if not self:HasVoice() then
		return
	end
	if uFileIdHigh ~= self.tbVoiceInfo.nHigh or uFileIdLow ~= self.tbVoiceInfo.nLow then
		return
	end
	self:PlayVoiceAni("VoiceBig")
end

function tbUi:OnVoiceEnd(uFileIdHigh, uFileIdLow)
	if not self:HasVoice() then
		return
	end
	if uFileIdHigh ~= self.tbVoiceInfo.nHigh or uFileIdLow ~= self.tbVoiceInfo.nLow then
		return
	end
	self:PlayVoiceAni("VoiceBig4")
end

function tbUi:PlayVoiceAni(szAni)
	self.pPanel:Sprite_Animation("Speaker", szAni, nil, 4)
end