local tbUi = Ui:CreateClass("KinApplyCustomMsgPanel")

tbUi.tbOnClick =
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnApply = function(self)
		self:Confirm()
	end,

	BtnDelete = function(self)
		self.tbVoiceInfo = nil
		self.pPanel:Input_SetText("MessageTxt", "")
		self:UpdateVoiceIcon()
	end,
}

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_VOICE_PLAY_START, self.OnVoiceStart},
		{ UiNotify.emNOTIFY_VOICE_PLAY_END, self.OnVoiceEnd},
	};

	return tbRegEvent;
end

function tbUi:OnOpen(nKinId)
	self.nKinId = nKinId
	self:InitBtnVoiceInput()
	self:UpdateVoiceIcon()
end

function tbUi:UpdateVoiceIcon()
	local bHasVoice = self:HasVoice()
	self.pPanel:SetActive("VoiceNode", bHasVoice)
	self:PlayVoiceAni("VoiceBig4")

	local voiceSize = {x = 0, y = 0}
	if bHasVoice then
		self.pPanel:SetActive("TxtVoiceTime", false)

		local speakerSize = self.pPanel:Sprite_GetSize("Speaker")
		voiceSize.x = speakerSize.x
		voiceSize.y = speakerSize.y
	end

	local msgPos = self.pPanel:GetPosition("MessageTxt");
	self.pPanel:ChangePosition("MessageTxt", voiceSize.x - 180, msgPos.y)
end

function tbUi:InitBtnVoiceInput()
	local fnCallback = function (szMsg,uFileIdHigh,uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
		if szMsg ~= "" then
			self.pPanel:Input_SetText("MessageTxt", szMsg)
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

	local nVoiceTime = ChatMgr:GetMaxVoiceTime(ChatMgr.nChannelKinApply)
	self.pPanel:FlyCom_Init("Sprite", fnCallback, fnCheckVoiceSend, nVoiceTime);
end

function tbUi:Confirm()
	local szMsg = self.pPanel:Input_GetText("MessageTxt")
	if not Kin:CheckBeforeApply(self.nKinId, szMsg) then
		return
	end

	local function fnApply()
		local tbVoice = nil
		if self.tbVoiceInfo then
			tbVoice = {self.tbVoiceInfo.nHigh, self.tbVoiceInfo.nLow, self.tbVoiceInfo.nVoiceTime, GetTime()}
		end
		if Kin:ApplyKin(self.nKinId, szMsg, tbVoice) then
			if Ui:WindowVisible("KinJoinPanel")==1 then
				Ui("KinJoinPanel"):OnApplied(self.nKinId)
			end
		end
		Ui:CloseWindow(self.UI_NAME)
	end

	if self.tbVoiceInfo then
		if ChatMgr:CheckVoiceSendEnable() and ChatMgr:IsValidVoiceMsg(0, self.tbVoiceInfo.nHigh, self.tbVoiceInfo.nLow, self.tbVoiceInfo.szFilePath) then
			local voiceData, dataLen = Lib:ReadFileBinary(self.tbVoiceInfo.szFilePath)
			if voiceData and dataLen > 0 then
				FileServer:SendVoiceFile(self.tbVoiceInfo.nHigh, self.tbVoiceInfo.nLow, voiceData, function (bRet)
					if not bRet then
						self.tbVoiceInfo = nil
					else
						fnApply()
					end
				end,
				false)
			end
		else
			self.tbVoiceInfo = nil
		end
	else
		fnApply()
	end
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