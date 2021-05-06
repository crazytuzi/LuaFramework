local CUIEffectFinger1 = class("CUIEffectFinger1", CObject)

function CUIEffectFinger1.ctor(self, oAttach, size, pos)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	self.m_Args = {size=size, pos=pos}
	g_ResCtrl:LoadCloneAsync("UI/UIEffect/finger1.prefab", callback(self, "OnEffLoad"), false)
end

function CUIEffectFinger1.OnEffLoad(self, oClone, path)
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff = CWidget.New(oClone)
		local iSize
		if self.m_Args.size then
			iSize = self.m_Args.size
			self.m_Eff:SetSize(iSize, iSize)
		end
		self.m_Eff:SetParent(self.m_Transform)
		local pos 
		if self.m_Args.pos then
			pos = self.m_Args.pos
		else
			pos = Vector2.zero
		end
		UITools.NearTarget(oAttach, self.m_Eff, enum.UIAnchor.Side.Bottom, pos)
		local depth = UITools.CalculateNextDepth(oAttach.m_GameObject)
		self.m_Eff:SetDepth(depth)
		UITools.SetSubWidgetDepthDeep(self.m_Eff)
	end
end

return CUIEffectFinger1