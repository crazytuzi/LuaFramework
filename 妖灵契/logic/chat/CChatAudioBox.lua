local CChatAudioBox = class("CChatAudioBox", CBox)

function CChatAudioBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSpr = self:NewUI(1, CSprite)
	self.m_MsgLabel = self:NewUI(2, CLabel)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_AudioSpr = self:NewUI(4, CSprite)
	self.m_ClickBox = self:NewUI(5, CSprite)
	self.m_TimeLable = self:NewUI(6, CLabel)
	self.m_GradeLabel = self:NewUI(7, CLabel, false)
	self.m_AudioSpr:SetSpriteName("#500_02")
	self.m_AudioSpr:PauseSpriteAnimation()
	self.m_Msg = nil
	
	g_SpeechCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

end

function CChatAudioBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventData ~= self.m_AudioKey then
		return
	end
	
	if oCtrl.m_EventID == define.Chat.Event.PlayAudio then
		self.m_AudioSpr:SetSpriteName("#500_00")
		self.m_AudioSpr:StartSpriteAnimation()
	
	elseif oCtrl.m_EventID == define.Chat.Event.EndPlayAudio then
		self.m_AudioSpr:SetSpriteName("#500_02")
		self.m_AudioSpr:PauseSpriteAnimation()
	end
end

function CChatAudioBox.SetMsg(self, oMsg)
	local dLink = oMsg:GetAudioLink()
	local sText = oMsg:GetText()
	self.m_MsgLabel:SetRichText(dLink["sTranslate"])
	
	self.m_ID = oMsg:GetRoleInfo("pid")
	self.m_AudioKey = dLink["sKey"]
	
	local iTime = 10
	if dLink["iTime"] then
		iTime = tonumber(dLink["iTime"])
	end
	self.m_NameLabel:SetText(oMsg:GetName())
	self.m_TimeLable:SetText(string.format("%d″", iTime))
	local iGrade = oMsg:GetRoleInfo("grade")
	if iGrade and self.m_GradeLabel then
		self.m_GradeLabel:SetText(tostring(iGrade))
	elseif self.m_GradeLabel then
		self.m_GradeLabel:SetText("")
	end
	self.m_IconSpr:SpriteAvatar(oMsg:GetShape())
	
	self.m_IconSpr:AddUIEvent("click", callback(self, "OnAvatar"))
	self.m_ClickBox:AddUIEvent("click", callback(self, "PlayAudio", dLink["sKey"]))

	local _, h = self.m_MsgLabel:GetSize()
	local cw, ch = self:GetSize()
	self:SetSize(cw, ch+math.max(h-26, 0))
	self.m_Msg = oMsg
end

function CChatAudioBox.OnAvatar(self)
	if self.m_ID ~= g_AttrCtrl.pid then
		netplayer.C2GSGetPlayerInfo(self.m_ID, define.PlayerInfo.Style.Default)
	end
end

function CChatAudioBox.PlayAudio(self, sKey)
	g_SpeechCtrl:PlayWithKey(sKey)
end

return CChatAudioBox