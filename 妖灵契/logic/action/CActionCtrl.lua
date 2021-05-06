local CActionCtrl = class("CActionCtrl")
--Dotween不支持的封装在Action
function CActionCtrl.ctor(self)
	self.m_Actions = {}
	self.m_ActionIDList = {}
	self.m_LateActionIDList = {}
	self.m_TargetActions = {}
	self.m_ActionIdx = 0
end

function CActionCtrl.GetNewID(self)
	self.m_ActionIdx = self.m_ActionIdx + 1
	return self.m_ActionIdx
end

function CActionCtrl.SetTargetAction(self, oTarget, iActionID, flag)
	if oTarget then
		local intanceid = oTarget:GetInstanceID()
		if not self.m_TargetActions[intanceid] then
			self.m_TargetActions[intanceid] = {}
		end
		self.m_TargetActions[intanceid][iActionID] = flag
	end
end

function CActionCtrl.AddAction(self, oAction, iDelay)
	self.m_Actions[oAction.m_ID] = {action=oAction, delay=iDelay or 0}
	if oAction.m_LateUpdate then
		table.insert(self.m_LateActionIDList, oAction.m_ID)
	else
		table.insert(self.m_ActionIDList, oAction.m_ID)
	end
	self:SetTargetAction(oAction:GetTarget(), oAction.m_ID, true)
end

function CActionCtrl.DelAction(self, oAction)
	self:SetTargetAction(oAction:GetTarget(), oAction.m_ID, nil)
	self.m_Actions[oAction.m_ID] = nil 
	if oAction.m_LateUpdate then
		local idx = table.index(self.m_LateActionIDList, oAction.m_ID)
		if idx then
			table.remove(self.m_LateActionIDList, idx)
		end
	else
		local idx = table.index(self.m_ActionIDList, oAction.m_ID)
		if idx then
			table.remove(self.m_ActionIDList, idx)
		end
	end
end

function CActionCtrl.UpdateList(self, list, dt)
	if not next(list) then
		return
	end
	local lDelete = {}
	for idx, id in ipairs(list) do
		local dAction = self.m_Actions[id]
		if dAction.delay > 0 then
			dAction.delay = dAction.delay - dt
		else
			local oAction = dAction.action
			if oAction.m_ElapseTime >= oAction.m_TotalTime then
				table.insert(lDelete, idx)
			elseif oAction:IsStop() then
				table.insert(lDelete, idx)
			end
			xxpcall(oAction.Excute, oAction, dt)
		end
	end
	local iLen = #lDelete
	if iLen > 0 then
		for i=iLen, 1, -1 do
			local idx = lDelete[i]
			local id = list[idx]
			if id then
				local dAction = self.m_Actions[id]
				if dAction.action and dAction.action.m_EndCallback then
					xxpcall(dAction.action.m_EndCallback)
				end
				self.m_Actions[id] = nil
				table.remove(list, idx)
			end
		end
	end
end

function CActionCtrl.Update(self, dt)
	self:UpdateList(self.m_ActionIDList, dt)
end

function CActionCtrl.LateUpdate(self, dt)
	self:UpdateList(self.m_LateActionIDList, dt)
end

function CActionCtrl.StopTarget(self, oTarget, cls)
	local ids = self.m_TargetActions[oTarget:GetInstanceID()]
	if ids then
		for id, _ in pairs(ids) do
			local dAction = self.m_Actions[id]
			if dAction and (not cls or (cls == dAction.action.classtype))then
				self:DelAction(dAction.action)
			end
		end
		self.m_TargetActions[oTarget:GetInstanceID()] = nil
	end
end

return CActionCtrl