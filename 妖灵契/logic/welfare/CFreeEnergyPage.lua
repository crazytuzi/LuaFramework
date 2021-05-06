local CFreeEnergyPage = class("CFreeEnergyPage", CPageBase)

function CFreeEnergyPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CFreeEnergyPage.OnInitPage(self)
	self.m_GetEnergySpr = self:NewUI(1, CSprite)
	self.m_FreeEnergyLabel = self:NewUI(2, CLabel)

	self.m_TweenScale = self.m_GetEnergySpr:GetComponent(classtype.TweenScale)
	self.m_TweenScale.enabled = false
	self:InitContent()
end

function CFreeEnergyPage.InitContent(self)
	self.m_GetEnergySpr:AddUIEvent("click", callback(self, "OnGetEnergy"))
	self.m_FreeEnergyLabel:SetText(data.globaldata.GLOBAL.freeenergy_value.value)
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvnet"))

	self:Refresh()
end

function CFreeEnergyPage.OnWelfareEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnFreeEnergyZhongwu or
		oCtrl.m_EventID == define.Welfare.Event.OnFreeEnergyWanshang or
		oCtrl.m_EventID == define.Welfare.Event.OnFreeEnergyClose then
		self:Refresh()
	end
end

function CFreeEnergyPage.OnGetEnergy(self, obj)
	local idx
	if g_WelfareCtrl:IsZhongWuCanGet() then
		idx = 1
	elseif g_WelfareCtrl:IsWanshangCanGet() then
		idx = 2
	end
	if idx then
		nethuodong.C2GSReceiveEnergy(idx)
	end
end

function CFreeEnergyPage.Refresh(self)
	local bCanGet = g_WelfareCtrl:IsZhongWuCanGet() or g_WelfareCtrl:IsWanshangCanGet()
	self.m_TweenScale.enabled = bCanGet
	self.m_GetEnergySpr:SetGrey(not bCanGet)
	if not bCanGet then
		self.m_GetEnergySpr:SetLocalScale(Vector3.one)
	end
end

return CFreeEnergyPage