local CEffect = class("CEffect", CObject)

function CEffect.ctor(self, path, layer, cached, cb)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_Layer = layer
	self.m_Callback = cb
	self.m_Eff = nil
	self.m_Path = path
	self.m_Cached = cached
	self.m_TilingInfo = nil
	self.m_RotateNode = nil
	self.m_MainTexOriScale = {}
	g_ResCtrl:LoadCloneAsync(path, callback(self, "OnEffLoad"), false)
	if Utils.IsEditor() then
		self:SetName(path.."_"..g_EffectCtrl:GetIndex())
	end
	self:SetParent(self:GetParentTransform())
	self.m_CtorTime = g_TimeCtrl:GetTimeMS()
	self.m_RefAttach = nil
end

function CEffect.SetRotateNode(self, node)
	node:SetName("rotate_node")
	local v = self:GetEulerAngles()
	node:SetEulerAngles(v)
	node:SetParent(self:GetParent(), true)
	self:SetParent(node.m_Transform, true)
	self.m_RotateNode = node
end

function CEffect.GetRotateNode(self)
	return self.m_RotateNode
end

function CEffect.SetAttachUI(self, oAttach)
	self.m_RefAttach = weakref(oAttach)
	self:SetParent(UITools.GetUIRootObj(false):GetTransform())
	local pos = oAttach:GetPos()
	self:SetPos(pos)
end

function CEffect.GetParentTransform(self)
	return g_EffectCtrl:GetEffectRoot().m_Transform
end

function CEffect.OnEffLoadExt(self)

end

function CEffect.OnEffLoad(self, oClone, sPath)
	if oClone then
		self.m_LoadTime = g_TimeCtrl:GetTimeMS() - self.m_CtorTime
		self.m_Eff = CObject.New(oClone)
		self.m_Eff:SetParent(self.m_Transform, false)
		self.m_Eff:SetCacheKey(sPath)
		if self.m_Layer then
			CObject.SetLayerDeep(self, self.m_Layer)
		end
		self:ProcessUI()
		self:ProcessTiling()
		self.m_Eff:SetActive(true)
		self:OnEffLoadExt()
		if self.m_Callback then
			self.m_Callback(self)
			self.m_Callback = nil
		end
		return true
	else
		return false
	end
end

function CEffect.ProcessUI(self)
	local oAttach = getrefobj(self.m_RefAttach)
	if oAttach then
		local mPanel = self.m_Eff:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = self.m_Eff:GetMissingComponent(classtype.UIEffectRenderQueue)
		self.m_Eff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject
	end
end

function CEffect.SetTiling(self, iSize, iTime, sEaseType)
	self.m_TilingInfo = {size=iSize, time=iTime, ease_type=sEaseType}
	self:ProcessTiling()
end

function CEffect.ProcessTiling(self)
	if self.m_Eff and self.m_TilingInfo then
		local lMats = Utils.GetMaterials({self.m_GameObject})
		for i, oMat in pairs(lMats) do
			local vOri = self.m_MainTexOriScale[oMat] or oMat:GetTextureScale("_MainTex")
			self.m_MainTexOriScale[oMat] = vOri
			DOTween.DOKill(oMat, false)
			if self.m_TilingInfo.time > 0 then
				local iEnd = vOri.x * self.m_TilingInfo.size
				local iSec = self.m_LoadTime*0.001
				oMat:SetTextureScale("_MainTex", Vector2.New(iEnd*iSec/self.m_TilingInfo.time, vOri.y))
				local tween = DOTween.DOTiling(oMat, Vector2.New(iEnd, vOri.y), self.m_TilingInfo.time-iSec)
				local sEaseType = self.m_TilingInfo.ease_type or "Linear"
				DOTween.SetEase(tween, enum.DOTween.Ease[sEaseType])
			else
				oMat:SetTextureScale("_MainTex", Vector2.New(vOri.x * self.m_TilingInfo.size, vOri.y))
			end
		end
		self.m_TilingInfo = nil
	end
end

function CEffect.SetLayer(self, layer)
	self.m_Layer = layer
	if self.m_Layer then
		CObject.SetLayerDeep(self, self.m_Layer)
	end
end

function CEffect.Destroy(self)
	if Utils.IsExist(self.m_Eff) then
		if self.m_Cached then
			for oMat, v in pairs(self.m_MainTexOriScale) do
				oMat:SetTextureScale("_MainTex", v)
			end
			self.m_Eff:SetLocalPos(Vector3.zero)
			self.m_Eff:SetLocalEulerAngles(Vector3.zero)
			self.m_Eff:SetActive(false)
			g_ResCtrl:PutCloneInCache(self.m_Eff:GetCacheKey(), self.m_Eff.m_GameObject)
		else
			self.m_Eff:Destroy()
		end
	end
	self.m_Eff = nil
	self.m_TilingInfo = nil

	if self.m_RotateNode then
		self.m_RotateNode:Destroy()
		self.m_RotateNode = nil
	end
	CObject.Destroy(self)
end

function CEffect.AutoDestroy(self, iSec)
	if self.m_AutoDestroyTimer then
		Utils.DelTimer(self.m_AutoDestroyTimer)
		self.m_AutoDestroyTimer = nil
	end
	self.m_AutoDestroyTimer = Utils.AddTimer(callback(g_EffectCtrl, "DelEffect", self:GetInstanceID()), 0, iSec)
	g_EffectCtrl:AddEffect(self)
end

return CEffect