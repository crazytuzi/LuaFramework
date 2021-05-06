local CApplicationCtrl = class("CApplicationCtrl", CDelayCallBase)

function CApplicationCtrl.ctor(self)
	CDelayCallBase.ctor(self)
	self.m_GameSettingData = nil
	self.m_PayPause = false
end

function CApplicationCtrl.InitCtrl(self)
	-- C_api.GameEventHandler.Instance:SetApplicationFocusCallback(callback(self, "FocusCallback"))
	C_api.GameEventHandler.Instance:SetApplicationPauseCallback(callback(self, "PauseCallback"))
	self:CheckPhone()
end

function CApplicationCtrl.FocusCallback(self, bFocus)
	print("ApplicationFocusCallback:", bFocus)
end

function CApplicationCtrl.PauseCallback(self, bPause)
	print("ApplicationPauseCallback:", bPause)
	if bPause then
		self.m_PayPause = g_SdkCtrl:IsPaying()
		g_TimeCtrl:StopDelayCall("HeartTimeOut")
		self:StopDelayCall("NetTimeout")
	else
		if self.m_PayPause then
			g_NotifyCtrl:HideConnect()
			self.m_PayPause = false
		end
		UnityEngine.Time:SyncUTimeNextFrame()
		if g_LoginCtrl:HasLoginRole() then
			netother.C2GSQueryBack()
			self:DelayCall(3, "NetTimeout")
		end
		g_QQPluginCtrl:ResetQQGroupInfo()
	end
end

function CApplicationCtrl.NetTimeout(self)
	if g_LoginCtrl:HasLoginRole() then
		print("NetTimeout->从后台回来,网络超时")
		g_NetCtrl:AutoReconnect()
	end
end

function CApplicationCtrl.CheckPhone(self)
	if self:IsPhoneX() then
		self:PhoneXProcess()
	end
end

function CApplicationCtrl.IsPhoneX(self)
	local deviceModel = Utils.GetDeviceModel()
	if deviceModel:find("iPhone10,3") or deviceModel:find("iPhone10,6") then
		return true
	end
	return false
end

function CApplicationCtrl.PhoneXProcess(self)
	local w, h = 2436, 1125
	local maskw = 88
	g_ViewCtrl:SetScreenMask(maskw/2436)
end

function CApplicationCtrl.GetGameSettingData(self)
	if not self.m_GameSettingData then
		local text = C_api.Utils.GetGameSettingText()
		self.m_GameSettingData = decodejson(text)
	end
	return self.m_GameSettingData
end

return CApplicationCtrl