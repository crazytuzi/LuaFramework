local CUIEffectTexture = class("CUIEffectTexture", CTexture)

function CUIEffectTexture.ctor(self, obj)
	CTexture.ctor(self, obj)
	self.m_EffectCamera = nil
end

function CUIEffectTexture.LoadEffect(self, sType, cb)
	if not self.m_EffectCamera then
		self.m_EffectCamera = g_CameraCtrl:GetUIEffectCamera()
		self.m_EffectCamera:SetOwner(self)
	end
	local oCam = g_CameraCtrl:GetUICamera()
	local o = self:GetMainTexture(oCam.m_Camera.aspect)
	self.m_EffectCamera:SetRenderTexture(o)
	self.m_EffectCamera:LoadEffect(sType, cb)
end

function CUIEffectTexture.Clear(self)
	-- if self.m_UIWidget.mainTexture then
	-- 	UnityEngine.RenderTexture.ReleaseTemporary(self.m_UIWidget.mainTexture)
	-- 	self:SetMainTexture(nil)
	-- end
	-- if self.m_ActorCamera then
	-- 	g_CameraCtrl:Recycle(self.m_ActorCamera)
	-- 	self.m_ActorCamera = nil
	-- end
end

function CUIEffectTexture.GetMainTexture(self, aspect)
	if not self.m_UIWidget.mainTexture then
		local w, h = self:GetSize()
		if aspect then
			local iTextureAspect = (w/h)
			if iTextureAspect ~= aspect then
				if iTextureAspect < aspect then
					w = h * aspect
				elseif iTextureAspect > aspect then
					h = w / aspect
				end
				self:SetSize(w, h)
			end
		end

		local o =  UnityEngine.RenderTexture.GetTemporary(w, h, 24)
		self.m_UIWidget.mainTexture = o
	end
	return self.m_UIWidget.mainTexture
end

return CUIEffectTexture
