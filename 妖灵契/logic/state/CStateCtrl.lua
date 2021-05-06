local CStateCtrl = class("CStateCtrl", CCtrlBase)


define.State = {
	Event = {
		AddState = 1,
		RefreshState = 2,
		DelState = 3,
		RemoveState = 4,
	}
}

function CStateCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_StateData = {}
end

function CStateCtrl.InitState(self, stateList)
	local sidList = {}
	for _, stateInfo in ipairs(stateList) do
		self.m_StateData[stateInfo["state_id"]] = stateInfo
		table.insert(sidList, stateInfo["state_id"])
	end
	self:OnEvent(define.State.Event.AddState, sidList)
end

function CStateCtrl.AddState(self, stateInfo)
	self.m_StateData[stateInfo["state_id"]] = stateInfo
	g_MapCtrl:UpdateHero()
	self:OnEvent(define.State.Event.AddState, {stateInfo["state_id"]})
end

function CStateCtrl.RefreshState(self, stateInfo)
	self.m_StateData[stateInfo["state_id"]] = stateInfo
	g_MapCtrl:UpdateHero()
	self:OnEvent(define.State.Event.RefreshState, stateInfo["state_id"])
end

function CStateCtrl.RemoveState(self, iSid)
	self.m_StateData[iSid] = nil
	g_MapCtrl:UpdateHero()
	self:OnEvent(define.State.Event.RemoveState, iSid)
end

function CStateCtrl.GetState(self, iSid)
	return self.m_StateData[iSid]
end

return CStateCtrl