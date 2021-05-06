local CSysSettingCtrl = class("CSysSettingCtrl", CCtrlBase)
define.SysSetting = {
	Event = {
		PushChange = 1,
	}
}

function CSysSettingCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_IsWin = Utils.IsWin()
	self.m_LockTimer = nil
	self.m_PushSetting = {}
	self:AutoLockScreen()

	self.m_SystemSettings = {
		music_enabled                   = true,
		music_percentage                = 1,
		
		sound_effect_enabled            = true,
		sound_effect_percentage         = 1,
		
		dubbing_enabled                 = true,
		dubbing_percentage              = 0.70,

		zoomlens_enabled                = true,
		hideplayer_enabled 				= false,
	}
end

function CSysSettingCtrl.SetPushSetting(self, k, v)
	self.m_PushSetting[k] = v
	self:OnEvent(define.SysSetting.Event.PushChange, {k=k, v=v})
end

function CSysSettingCtrl.GetPushSetting(self, k)
	return self.m_PushSetting[k] or 0
end

function CSysSettingCtrl.GetSysSetting(self, k)
	return self.m_SystemSettings[k]
end

function CSysSettingCtrl.GetSysSettings(self)
	return self.m_SystemSettings
end

function CSysSettingCtrl.Update(self)
	if self.m_IsWin then
		if UnityEngine.Input.GetMouseButtonDown(0) then
			self:AutoLockScreen()
		end
	else
		if UnityEngine.Input.touchCount > 0 then
			self:AutoLockScreen()
		end
	end
end

function CSysSettingCtrl.IsLockScreen(self)
	return CLockScreenView:GetView()
end

function CSysSettingCtrl.AutoLockScreen(self)
	if self.m_LockTimer then
		Utils.DelTimer(self.m_LockTimer)
		self.m_LockTimer = nil
	end
	if data.globaldata then
		local interval = tonumber(data.globaldata.GLOBAL.lockscreen_interval.value)
		local function check()
			CLockScreenView:ShowView()
			self.m_LockTimer = nil
		end
		self.m_LockTimer = Utils.AddTimer(check, interval, interval)
	end
end 

function CSysSettingCtrl.SetSolveKaJiEnabled(self, bEnable)
	self.m_SolveKaJiEnabled = bEnable
end

function CSysSettingCtrl.GetSolveKaJiEnabled(self)
	return self.m_SolveKaJiEnabled
end

function CSysSettingCtrl.ReadLocalSettings(self)
	local accout = g_LoginCtrl:GetAccount()
	printc("读取系统设置本地数据，帐号为 ", accout)
	if accout then
		local tAll = IOTools.GetClientData("system_settings") or {}
		if tAll[accout] then
			printc(accout .. " 的系统设置本地数据不为 nil，使用本地数据")
			-- table.print(tAll)
			for k,v in pairs(self.m_SystemSettings) do
				if tAll[accout][k] == nil then
					tAll[accout][k] = v
				end
			end
			self.m_SystemSettings = tAll[accout]
		else
			printc(accout .. " 的系统设置本地数据为 nil，使用默认数据")
			tAll[accout] = self.m_SystemSettings
		end
	end
	--table.print(self.m_SystemSettings, "m_SystemSettings")
	--加载完要刷新一下设置
	self:RefreshAllSysSettings()
end

function CSysSettingCtrl.SaveLocalSettings(self, k, v)
	local tAccount = self.m_SystemSettings
	tAccount[k] = v
	local tAll = IOTools.GetClientData("system_settings") or {}
	if type(tAll) ~= "table" then 
		tAll = {}
	end
	local accout = g_LoginCtrl:GetAccount()
	tAll[accout] = tAccount
	IOTools.SetClientData("system_settings", tAll)
end

function CSysSettingCtrl.RefreshAllSysSettings(self)
	g_AudioCtrl:CheckAuidoAll()
end

function CSysSettingCtrl.IsMusicEnabled(self)
	return self.m_SystemSettings["music_enabled"]
end

function CSysSettingCtrl.GetMusicPercentage(self)
	return self.m_SystemSettings["music_percentage"]
end

function CSysSettingCtrl.IsSoundEffectEnabled(self)
	return self.m_SystemSettings["sound_effect_enabled"]
end

function CSysSettingCtrl.GetSoundEffectPercentage(self)
	return self.m_SystemSettings["sound_effect_percentage"]
end

function CSysSettingCtrl.IsDubbingEnabled(self)
	return self.m_SystemSettings["dubbing_enabled"]
end

function CSysSettingCtrl.GetDubbingPercentage(self)
	return self.m_SystemSettings["dubbing_percentage"]
end

function CSysSettingCtrl.GetZoomlensEnabled(self)
	return self.m_SystemSettings["zoomlens_enabled"]
end

function CSysSettingCtrl.GetHidePlayerEnabled(self)
	return self.m_SystemSettings["hideplayer_enabled"]
end

return CSysSettingCtrl