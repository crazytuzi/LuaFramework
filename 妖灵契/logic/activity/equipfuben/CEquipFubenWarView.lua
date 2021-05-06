local CEquipFubenWarView = class("CEquipFubenWarView", CViewBase)

function CEquipFubenWarView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/equipfuben/EquipFubenWarView.prefab", cb)
	self.m_DepthType = "Menu"
end

function CEquipFubenWarView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_LT = self:NewUI(2, CWidget)
	self.m_TimeLabel = self:NewUI(3, CLabel)
	self.m_Timer = nil
	self.m_IsOVerTime = false

	self:InitContent()

end

function CEquipFubenWarView.InitContent(self)

	UITools.ResizeToRootSize(self.m_Container)

	g_EquipFubenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEquipFubenEvent"))

	local time = g_EquipFubenCtrl:GetDoingTimeStr()
	if time ~= "" then
		self.m_TimeLabel:SetActive(true)
		self.m_TimeLabel:SetText(string.format("副本时间:%s",time))

		if self.m_Timer ~= nil then
			Utils.DelTimer(self.m_Timer)
			self.m_Timer = nil
		end		
		local function timetUpdate()
			local time = g_EquipFubenCtrl:GetDoingTimeStr()
			if time ~= "" then
				self.m_TimeLabel:SetText(string.format("副本时间:%s",time))
			end			
			if self.m_IsOVerTime == false then
				if g_EquipFubenCtrl:IsOverTime() then
					self.m_IsOVerTime = true
					self.m_TimeLabel:SetColor(Color.New( 255/255, 104/255, 104/255, 255/255))
				else
					self.m_TimeLabel:SetColor(Color.New( 255/255, 233/255, 180/255, 255/255))
				end
			end
			return true
		end
		self.m_Timer = Utils.AddTimer(timetUpdate, 1, 0)
	else
		self.m_TimeLabel:SetActive(false)
	end
end

function CEquipFubenWarView.OnCtrlEquipFubenEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EquipFb.Event.CompleteFB then
		if self.m_Timer ~= nil then
			Utils.DelTimer(self.m_Timer)
			self.m_Timer = nil
		end
		local t = g_EquipFubenCtrl.m_PassFubenInfo
		if t and next(t) and t.useTime then			
			self.m_TimeLabel:SetText(string.format("副本时间:%s",g_EquipFubenCtrl:ConverTimeString(t.useTime)))	
		end		
	end
end

function CEquipFubenWarView.Destroy(self)
	if self.m_Timer ~= nil then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end	
	CViewBase.Destroy(self)
end

return CEquipFubenWarView