local CPushSettingView = class("CPushSettingView", CViewBase)

function CPushSettingView.ctor(self, cb)
	CViewBase.ctor(self, "UI/SystemSettings/PushSettingView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
end

function CPushSettingView.OnCreateView(self)
	self.m_Boxes = {}
	self:CreateSetBox(1, "push", "partner_travel")
	self:CreateSetBox(2, "vibrate", "trapmine_vibrate_mb")
	self:CreateSetBox(3, "vibrate", "trapmine_vibrate_tm")
	self:CreateSetBox(4, "push", "energy")
	g_SysSettingCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CPushSettingView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SysSetting.Event.PushChange then
		local dData = oCtrl.m_EventData
		local oBox = self.m_Boxes[dData.k]
		if oBox then
			oBox.m_SelSprite:SetActive(dData.v>0)
		end
	end
end

function CPushSettingView.CreateSetBox(self, idx, type, key)
	local oBox = self:NewUI(idx, CBox)
	oBox.m_Btn = oBox:NewUI(1, CButton)
	oBox.m_SelSprite = oBox:NewUI(2, CSprite)
	local bSel = false
	if type == "push" then
		oBox:AddUIEvent("click", callback(self, "OnPushSetting", key))
		bSel = (g_SysSettingCtrl:GetPushSetting(key) > 0)
	else
		oBox:AddUIEvent("click", callback(self, "OnLocalSetting", key))
		bSel = (g_SysSettingCtrl:GetSysSetting(key) == true)
	end
	oBox.m_SelSprite:SetActive(bSel)
	self.m_Boxes[key] = oBox
end

function CPushSettingView.OnLocalSetting(self, sKey, oBox)
	local bSel = not oBox.m_SelSprite:GetActive()
	oBox.m_SelSprite:SetActive(bSel)
	g_SysSettingCtrl:SaveLocalSettings(sKey, bSel)

end

function CPushSettingView.OnPushSetting(self, sKey, oBox)
	local bSel = not oBox.m_SelSprite:GetActive()
	netplayer.C2GSGamePushSetting(sKey, bSel and 1 or 0)
end

return CPushSettingView