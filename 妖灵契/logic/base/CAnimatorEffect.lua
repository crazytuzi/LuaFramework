local CAnimatorEffect = class("CAnimatorEffect", CEffect)

function CAnimatorEffect.ctor(self, path, layer,cached, cb)
	CEffect.ctor(self, path, layer, cached, cb)
	self.m_Animator = nil
	self.m_AnimObj = nil
	self.m_FrameSyncHandler = nil
end

function CAnimatorEffect.OnEffLoadExt(self)
	local comp = self.m_Eff:GetComponent(classtype.DataContainer)
	if comp then
		local replaceAnimObj = comp.gameObjectValue
		if replaceAnimObj then
			replaceAnimObj:SetActive(false)
			if Utils.IsExist(self.m_AnimObj) then
				self.m_FrameSyncHandler:SetTarget(replaceAnimObj)
				Utils.AddScaledTimer(function() 
						if Utils.IsExist(self.m_AnimObj) then
							self.m_FrameSyncHandler:SetTarget(nil)
						end
					end, 0, comp.floatValue)
			end
		end
	end
	self.m_Animator = self.m_Eff:GetComponent(classtype.Animator)
end

function CAnimatorEffect.AnimObj(self, obj)
	self.m_AnimObj = obj
	if obj then
		self.m_FrameSyncHandler = obj:GetMissingComponent(classtype.FrameSyncHandler)
	end
end

function CAnimatorEffect.Destroy(self)
	CEffect.Destroy(self)
	self.m_AnimObj = nil
	if self.m_FrameSyncHandler then
		self.m_FrameSyncHandler:SetTarget(nil)
		self.m_FrameSyncHandler = nil
	end
	self.m_Animator = nil
end

return CAnimatorEffect