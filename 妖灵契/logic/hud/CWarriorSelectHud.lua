local CWarriorSelectHud = class("CWarriorSelectHud", CAsyncHud)

function CWarriorSelectHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/WarriorSelectHud.prefab", cb, true)
end

function CWarriorSelectHud.OnCreateHud(self)
	self.m_Widget = self:NewUI(1, CWidget)
	self.m_Widget:AddUIEvent("click", callback(self, "OnClick"))
	self.m_Widget:AddUIEvent("longpress", callback(self, "OnShowBuffDetail"))
end

function CWarriorSelectHud.SetWarrior(self, oWarrior)
	self.m_WarriorRef = weakref(oWarrior)
end

function CWarriorSelectHud.GetWarrior(self)
	return getrefobj(self.m_WarriorRef)
end

function CWarriorSelectHud.OnClick(self)
	local oWarrior = self:GetWarrior()
	if oWarrior then
		if oWarrior:IsOrderTarget() then
			oWarrior:AddBindObj("light")
			Utils.AddTimer(callback(oWarrior, "DelBindObj", "light"), 0, 0.3)
			g_WarOrderCtrl:SetTargetID(oWarrior.m_ID)
		end
	end
end

function CWarriorSelectHud.OnShowBuffDetail(self)
	local oWarrior = self:GetWarrior()
	if oWarrior then
		CWarTargetDetailView:ShowView(function(oView)
				oView:SetWarrior(oWarrior)
			end)
	end
end

return CWarriorSelectHud