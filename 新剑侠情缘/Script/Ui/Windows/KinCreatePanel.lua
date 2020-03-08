local tbUi = Ui:CreateClass("KinCreatePanel");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_VOICE_PLAY_START, self.OnVoiceStart},
		{ UiNotify.emNOTIFY_VOICE_PLAY_END, self.OnVoiceEnd},
	};

	return tbRegEvent;
end

function tbUi:OnOpen()
	self.pPanel:Label_SetText("TxtCreateCost", Kin.Def.nCreationCost);
    self.pPanel:Toggle_SetChecked("Neutral", false);
    self.pPanel:Toggle_SetChecked("Song", false);
    self.pPanel:Toggle_SetChecked("Jing", false);
    self.nSelectCamp = nil;

    local szAddDeclare = self.pPanel:Input_GetText("FamilyDeclaration");
	if not szAddDeclare or szAddDeclare == "" then
		self.pPanel:Input_SetText("FamilyDeclaration", "风雨历程，你我相伴。四海之内皆兄弟，欢迎加入我们家族！")
	end

	self.pPanel:UIInput_SetCharLimit("FamilyName", Kin.Def.nMaxKinNameLength);
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
		voiceSize.y = math.max(speakerSize.y, voiceTimeSize.y)
	end

	local msgPos = self.pPanel:GetPosition("FamilyDeclaration");
	self.pPanel:ChangePosition("FamilyDeclaration", msgPos.x, -voiceSize.y + 80)
end

function tbUi:InitBtnVoiceInput()
	local fnCallback = function (szMsg,uFileIdHigh,uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
		if szMsg ~= "" then
			self.pPanel:Input_SetText("FamilyDeclaration", szMsg)
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

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnCancel()
	Ui:CloseWindow("KinCreatePanel");
end

function tbUi.tbOnClick:BtnTip()
	me.CenterMsg("Create Kin Tips");
end

function tbUi.tbOnClick:Song()
    self.nSelectCamp = Npc.CampTypeDef.camp_type_song;
end

function tbUi.tbOnClick:Jing()
    self.nSelectCamp = Npc.CampTypeDef.camp_type_jin;
end

function tbUi.tbOnClick:Neutral()
    self.nSelectCamp = Npc.CampTypeDef.camp_type_neutrality;
end

function tbUi.tbOnClick:BtnConfirm()
	if self.bUploadingVoice then
		me.CenterMsg("正在上传语音，请稍候")
		return
	end
	local szKinName = self.pPanel:Input_GetText("FamilyName");
	local szAddDeclare = self.pPanel:Input_GetText("FamilyDeclaration");
	if not szAddDeclare or szAddDeclare == "" then
		szAddDeclare = "风雨历程，你我相伴。四海之内皆兄弟，欢迎加入我们家族！"
	end

	if self.tbVoiceInfo then
		if ChatMgr:CheckVoiceSendEnable() and ChatMgr:IsValidVoiceMsg(0, self.tbVoiceInfo.nHigh, self.tbVoiceInfo.nLow, self.tbVoiceInfo.szFilePath) then
			local voiceData, dataLen = Lib:ReadFileBinary(self.tbVoiceInfo.szFilePath)
			if voiceData and dataLen > 0 then
				me.CenterMsg("正在上传语音，请稍候")
				self.bUploadingVoice = true
				FileServer:SendVoiceFile(self.tbVoiceInfo.nHigh, self.tbVoiceInfo.nLow, voiceData, function (bRet)
					self.bUploadingVoice = false
					if not bRet then
						me.CenterMsg("上传语音失败")
						self.tbVoiceInfo = nil
						Kin:Create(szKinName, szAddDeclare, nil, self.nSelectCamp)
					else
						Kin:Create(szKinName, szAddDeclare, {self.tbVoiceInfo.nHigh, self.tbVoiceInfo.nLow, self.tbVoiceInfo.nVoiceTime, GetTime()}, self.nSelectCamp)
					end
				end,
				false)
			end
		else
			self.tbVoiceInfo = nil
		end
	else
		Kin:Create(szKinName, szAddDeclare, nil, self.nSelectCamp);
	end
end

function tbUi.tbOnClick:BtnEmpty()
	self.tbVoiceInfo = nil
	self.pPanel:Input_SetText("FamilyDeclaration", "")
	self:UpdateVoiceIcon()
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