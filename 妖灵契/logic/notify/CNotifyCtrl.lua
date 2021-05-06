local CNotifyCtrl = class("CNotifyCtrl")

function CNotifyCtrl.ctor(self)
	self.m_AniSwitchTimer = nil
end

function CNotifyCtrl.FloatMsg(self, text)
	local oView = CNotifyView:GetView()
	if oView then
		oView:FloatMsg(text)
	end
end

function CNotifyCtrl.HintMsg(self, text)
	local oView = CNotifyView:GetView()
	if oView then
		oView:ShowHint(text)
	end
end

--装备属性变化提示飘字
function CNotifyCtrl.FloatMsgAttrChange(self, text, args)
	local oView = CNotifyView:GetView()
	if oView then
		return oView:FloatMsgAttrChange(text, args)
	end
end

function CNotifyCtrl.ShowProgress(self, cb, text, waitTime, cancelcb)
	local oView = CNotifyView:GetView()
	if oView then
		oView:ShowProgress(cb, text, waitTime, cancelcb)
	end
end

function CNotifyCtrl.ShowInviteOrgInfo(self)
	local oView = CNotifyView:GetView()
	if oView then
		oView:ShowInviteOrgInfo()
	end
end

function CNotifyCtrl.ShowLongPressAni(self, pos, time)
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		oNotifyView:ShowLongPressAni(pos, time)
	end
end

function CNotifyCtrl.HideLongPressAni(self)
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		oNotifyView:HideLongPressAni()
	end
end

function CNotifyCtrl.ShowConnect(self, sTips, iDelay)
	self:DestroyConnectTimer()
	local delayTime = iDelay or 0
	if delayTime > 0 then
		self.m_TimerID = Utils.AddTimer(callback(self, "OnShowConnect", sTips), 0, delayTime)
	else
		self:OnShowConnect(sTips)
	end
end

function CNotifyCtrl.HideConnect(self)
	self:DestroyConnectTimer()
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		oNotifyView:SetConnect(false)
	end
end

function CNotifyCtrl.DestroyConnectTimer(self)
	if self.m_TimerID then
		Utils.DelTimer(self.m_TimerID)
		self.m_TimerID = nil
	end
end

function CNotifyCtrl.OnShowConnect(self, sTips)
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		oNotifyView:SetConnect(true, sTips)
	end
end

function CNotifyCtrl.ResetCtrl(self)
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		oNotifyView:Clear()
	end
	if self.m_AniSwitchTimer then
		Utils.DelTimer(self.m_AniSwitchTimer)
		self.m_AniSwitchTimer = nil
	end
end

function CNotifyCtrl.ClearFloat(self)
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		oNotifyView:ClearFloat()
	end
end

function CNotifyCtrl.ShowAniSwitchBlackBg(self, time, bFadeIn)
	time = time or 0
	bFadeIn = bFadeIn or false
	if self.m_AniSwitchTimer then
		Utils.DelTimer(self.m_AniSwitchTimer)
		self.m_AniSwitchTimer = nil
	end
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		oNotifyView.m_AniSwitchBox:SetAniSwichBgActive(true, bFadeIn)
		if time ~= 0 then
			self.m_AniSwitchTimer = Utils.AddTimer(callback(self, "AniSwitchFadeOut", 1), 0, time)
		end
	end
end

function CNotifyCtrl.ShowAniSwitchTextureBg(self, path, time, bFadeIn)
	time = time or 0
	bFadeIn = bFadeIn or false
	if self.m_AniSwitchTimer then
		Utils.DelTimer(self.m_AniSwitchTimer)
		self.m_AniSwitchTimer = nil
	end	
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		oNotifyView.m_AniSwitchBox:SetAniSwichTextrueActive(path, bFadeIn)
		if time ~= 0 then
			self.m_AniSwitchTimer = Utils.AddTimer(callback(self, "AniSwitchFadeOut", 2), 0, time)
		end		
	end
end

function CNotifyCtrl.CloseAniSwitchBox(self)
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		oNotifyView.m_AniSwitchBox:ResetAniSwitchBox()
	end
end

function CNotifyCtrl.AniSwitchFadeOut(self, mode)
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		if mode == 1 then
			oNotifyView.m_AniSwitchBox:SetAniSwichBgFadeOut()
		elseif mode == 2 then
			oNotifyView.m_AniSwitchBox:SetAniSwichTextrueFadeOut()
		else
			oNotifyView.m_AniSwitchBox:ResetAniSwitchBox()
		end
	end
end

function CNotifyCtrl.CloseAniSwitchBox(self)
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		oNotifyView.m_AniSwitchBox:ResetAniSwitchBox()
	end
end

function CNotifyCtrl.GetUIScreenEffectRoot(self)
	local oRoot = nil
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		oRoot = oNotifyView.m_UIScreenEffectRoot
	end
	return oRoot
end

function CNotifyCtrl.HideView(self, bHide)
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		oNotifyView:SetActive(not bHide)
	end
end

function CNotifyCtrl.ShowPowerChange(self, from, to)
	local oNotifyView = CNotifyView:GetView()
	if oNotifyView then
		oNotifyView.m_PowerChangeBox:ShowPowerChange(from, to)
	end
end

return CNotifyCtrl