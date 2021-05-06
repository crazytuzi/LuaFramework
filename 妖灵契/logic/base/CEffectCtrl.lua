local CEffectCtrl = class("CEffectCtrl")

function CEffectCtrl.ctor(self)
	self.m_Index = 0
	self.m_EffectRoot = nil
	self.m_EffectTrans = nil
	self.m_Effects = {}
end

function CEffectCtrl.CreateUIEffect(self, sType, oAttach, ...)
	local oEffect
	if sType == "RedDot" then
		oEffect = CUIEffectRedDot.New(oAttach, ...)
	elseif sType == "Rect" then
		oEffect = CUIEffectRect.New(oAttach, ...)
	elseif sType == "Finger" then
		oEffect = CUIEffectFinger.New(oAttach, ...)
	elseif sType == "Finger1" then
		oEffect = CUIEffectFinger1.New(oAttach, ...)
	elseif sType == "Finger2" then
		oEffect = CUIEffectFinger2.New(oAttach, ...)
	elseif sType == "Finger3" then
		oEffect = CUIEffectFinger3.New(oAttach, ...)
	elseif sType == "Finger4" then
		oEffect = CUIEffectFinger4.New(oAttach, ...)	
	elseif sType == "Guide" then
		oEffect = CUIEffectGuide.New(oAttach, ...)
	elseif sType == "Trail" then
		oEffect = CUIEffectTrail.New(oAttach, ...)
	elseif sType == "round" then
		oEffect = CUIEffectRound.New(oAttach, ...)
	elseif sType == "round2" then
		oEffect = CUIEffectRound2.New(oAttach, ...)
	elseif sType == "bordermove" then
		oEffect = CUIEffectBorderMove.New(oAttach, ...)		
	elseif sType == "circle" then
		oEffect = CUIEffectRotateCircle.New(oAttach, ...)		
	elseif sType == "fire" then
		oEffect = CUIEffectFire.New(oAttach, ...)			
	end
	return oEffect
end

function CEffectCtrl.GetEffectRoot(self)
	if not self.m_EffectRoot then
		self.m_EffectRoot = CObject.New(UnityEngine.GameObject.New("EffectRoot"))
	end
	return self.m_EffectRoot
end

function CEffectCtrl.GetIndex(self)
	self.m_Index = self.m_Index + 1
	return self.m_Index
end

function CEffectCtrl.AddEffect(self, oEffect)
	self.m_Effects[oEffect:GetInstanceID()] = oEffect
end

function CEffectCtrl.DelEffect(self, id)
	local oEffect = self.m_Effects[id]
	if oEffect then
		oEffect:Destroy()
		self.m_Effects[id] = nil 
	end

end

function CEffectCtrl.CreateEffectByPath(self, sPath, oAttach, ...)
	local oEffect = CUIEffectByPath.New(sPath, oAttach, ...)
	return oEffect
end

function CEffectCtrl.NewEffect(self, sPath, oNode, oAttach, v3LocalPos, v3Scale)
	local ref = weakref(oAttach)
	local function loadeffect(oClone, errcode)
		local obj = getrefobj(ref)
		if oClone and obj then
			local oEff = CObject.New(oClone)
			oEff:SetParent(oNode.m_Transform)
			local mPanel = oClone:GetMissingComponent(classtype.UIPanel)
			mPanel.uiEffectDrawCallCount = 1
			local mRenderQ = oClone:GetMissingComponent(classtype.UIEffectRenderQueue)
			oEff.m_RenderQComponent = mRenderQ
			mRenderQ.needClip = true
			mRenderQ.attachGameObject = obj.m_GameObject
			mRenderQ:RecaluatePanelDepth()
			if v3LocalPos then
				oEff:SetLocalPos(v3LocalPos)
			end
			if v3Scale then
				oEff:SetLocalScale(v3Scale)
			end
		end
	end
	g_ResCtrl:LoadCloneAsync(sPath, loadeffect)
end

return CEffectCtrl