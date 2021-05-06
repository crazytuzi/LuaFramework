local CChainEffectExt = class("CChainEffectExt", CEffect)

function CChainEffectExt.ctor(self, path, layer, cached, cb)
	CEffect.ctor(self, path, layer, cached, cb)
	self.m_Handler = self:GetMissingComponent(classtype.ChainEffect)
end


function CChainEffectExt.SetBeginObj(self, beginTrans)
	self.m_Handler.beginObj = beginTrans.gameObject
end

function CChainEffectExt.SetEndObj(self, endTrans)
	self.m_Handler.endObj = endTrans.gameObject
end

return CChainEffectExt