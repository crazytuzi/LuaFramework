local DangerEffectLayer = class("DangerEffectLayer", function() return cc.LayerColor:create(cc.c4b(255, 0, 0, 0)) end)

function DangerEffectLayer:ctor()

	log("[DangerEffectLayer:ctor]")

	self.percent1 = 0.3
	self.percent2 = 0.2
	self.alpha1 = 30
	self.alpha2 = 30
	self.state = 0
	self:reset()

end

function DangerEffectLayer:EffectUpdate()

	log("[DangerEffectLayer:EffectUpdate]")

	local percent = 0.1
	if percent < self.percent2 then
		if self.state == 1 then
			self:reset()
		end
		if self:getNumberOfRunningActions() == 0 then
			local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1, self.alpha1), cc.FadeTo:create(1, 0), 
				cc.CallFunc:create(function() end)))
			self:runAction(action)
			self.state = 2
		end
	elseif percent < self.percent1 then
		if self.state == 2 then
			self:reset()
		end
		if self:getNumberOfRunningActions() == 0 then
			local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, self.alpha2), cc.FadeTo:create(0.5, 0), 
				cc.CallFunc:create(function() end)))
			self:runAction(action)
			self.state = 1
		end
	else
		self:setOpacity(0)
		self:stopAllActions()
	end

end

function DangerEffectLayer:reset()
	self.state = 0
	self:setOpacity(0)
	self:stopAllActions()
end

return DangerEffectLayer
