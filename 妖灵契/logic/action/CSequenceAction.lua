local CSequenceAction = class("CSequenceAction")

function CSequenceAction.ctor(self, TargetList, endCb)
	self.m_TargetList = TargetList
	self.m_EndCb = endCb
	self.m_Idx = 0
end

function CSequenceAction.StartActions(self)
	self:CheckNextAction()
end

function CSequenceAction.StopActions(self)
	if self.m_TargetList and next(self.m_TargetList) then
		for i, v in ipairs(self.m_TargetList) do
			g_ActionCtrl:DelAction(v)
		end
	end
end

function CSequenceAction.CheckNextAction(self)
	self.m_Idx = self.m_Idx + 1
	local oTarget = self.m_TargetList[self.m_Idx]
	if oTarget then
		g_ActionCtrl:AddAction(oTarget)
		if self.m_TargetList[self.m_Idx + 1] then
			oTarget:SetEndCallback(callback(self, "CheckNextAction"))
		else
			oTarget:SetEndCallback(callback(self, "StopActions"))
			if self.m_EndCb then
				self.m_EndCb()
			end
		end		
	end
end

return CSequenceAction