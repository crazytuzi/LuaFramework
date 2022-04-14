--
-- @Author: LaoY
-- @Date:   2018-09-20 16:17:21
--
SceneTargetEffect = SceneTargetEffect or class("SceneTargetEffect",SceneEffect)

function SceneTargetEffect:ctor(parent,abName,effect_type,cls,builtin_layer)
	self.builtin_layer = builtin_layer or self.builtin_layer
	EffectManager:GetInstance():AddSceneEffect(cls,self)
end

function SceneTargetEffect:dctor()
	-- EffectManager:GetInstance():RemoveSceneEffect(self.parent,self)
end