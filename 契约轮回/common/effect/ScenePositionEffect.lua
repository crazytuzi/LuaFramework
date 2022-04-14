--
-- @Author: LaoY
-- @Date:   2018-09-20 16:00:53
--
ScenePositionEffect = ScenePositionEffect or class("ScenePositionEffect",SceneEffect)
local ScenePositionEffect = ScenePositionEffect

function ScenePositionEffect:ctor(parent,abName,effect_type)
	EffectManager:GetInstance():AddSceneEffect(self.parent,self)
end

function ScenePositionEffect:dctor()
	-- EffectManager:GetInstance():RemoveSceneEffect(self.parent,self)
end