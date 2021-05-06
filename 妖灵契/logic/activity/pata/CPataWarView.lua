local CPataWarView = class("CPataWarView", CViewBase)

function CPataWarView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/pata/PataWarView.prefab", cb)
end

function CPataWarView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_LT = self:NewUI(2, CWidget)
	self.m_FloorLabel = self:NewUI(3, CLabel)

	self:InitContent()
end

function CPataWarView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)	
	g_PataCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlPataEvent"))
end

function CPataWarView.SetFloor(self, floor)
	self.m_FloorLabel:SetActive(true)
	self.m_FloorLabel:SetText(string.format("第%d层", floor))
end

function CPataWarView.OnCtrlPataEvent(self, oCtrl)
	if oCtrl.m_EventID == define.PaTa.Event.UpdataWarFloor then		
		self:SetFloor(g_PataCtrl:GetWarFloor())
	end
end

return CPataWarView