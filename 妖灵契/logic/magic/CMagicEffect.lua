local CMagicEffect = class("CMagicObj", CEffect)

function CMagicEffect.ctor(self, path, layer, cached, cb)
	CEffect.ctor(self, path, layer, cached, cb)
end

function CMagicEffect.SetEnv(self, sEnv)
	self.m_RunEnv = sEnv
	local transform = self:GetParentTransform(sEnv)
	if transform then
		self:SetParent(transform)
		-- self:SetLocalEulerAngles(Vector3.New(-45, -90, -90))
		-- self:SetLocalEulerAngles(Vector3.New(0, -45, 0))
	end
end

function CMagicEffect.GetParentTransform(self)
	if self.m_RunEnv == "war" then
		return g_WarCtrl:GetRoot().m_Transform
	elseif self.m_RunEnv == "createrole" then
		return g_CreateRoleCtrl:GetRoot().m_Transform
	end
end

return CMagicEffect