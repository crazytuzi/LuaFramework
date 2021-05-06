local CDialogueEffect = class("CDialogueEffect", CEffect)

function CDialogueEffect.ctor(self, path, trans, layer, cached, cb)
	self.m_ParentTrans = trans
	CEffect.ctor(self, path, layer, cached, cb)
end

function CDialogueEffect.SetEnv(self, sEnv)
	-- local transform = MagicTools.GetParentByEnv(sEnv)
	-- if transform then
	-- 	self:SetParent(transform)
		-- self:SetLocalEulerAngles(Vector3.New(-45, -90, -90))
		-- self:SetLocalEulerAngles(Vector3.New(0, -45, 0))
	-- end
end

function CDialogueEffect.GetParentTransform(self)
	return self.m_ParentTrans
end

return CDialogueEffect