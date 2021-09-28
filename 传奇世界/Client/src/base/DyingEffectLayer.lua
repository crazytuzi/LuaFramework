local DyingEffectLayer = class("DyingEffectLayer", function() return cc.LayerColor:create(cc.c4b(255, 0, 0, 0)) end)

function DyingEffectLayer:ctor()
	log("DyingEffectLayer:ctor")
	self.percent1 = 0.3
	self.percent2 = 0.2
	self.alpha1 = 50
	self.alpha2 = 30
	self.state = 0
	self:reset()
end

function DyingEffectLayer:check()
	-- log("DyingEffectLayer:check")
	if not G_ROLE_MAIN then
		return
	end

	local percent = G_ROLE_MAIN:getHP() / G_ROLE_MAIN.base_data.mhp
	if percent < self.percent2 and percent > 0 then
		if self.state == 1 then
			self:reset()
		end
		if self:getNumberOfRunningActions() == 0 then
			local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1, self.alpha1), cc.FadeTo:create(1, 0), 
				cc.CallFunc:create(function() if G_ROLE_MAIN:getHP() / G_ROLE_MAIN.base_data.mhp >= self.percent1 then self:reset() end end)))
			self:setVisible(true)
			self:runAction(action)
			self.state = 2
		end
	elseif percent < self.percent1 and percent > 0 then
		if self.state == 2 then
			self:reset()
		end
		if self:getNumberOfRunningActions() == 0 then
			local action = cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, self.alpha2), cc.FadeTo:create(0.5, 0), 
				cc.CallFunc:create(function() if G_ROLE_MAIN:getHP() / G_ROLE_MAIN.base_data.mhp >= self.percent1 then self:reset() end end)))
			self:setVisible(true)
			self:runAction(action)
			self.state = 1
		end
	else
		self:setOpacity(0)
		self:setVisible(false)
		self:stopAllActions()
	end
end

function DyingEffectLayer:reset()
	self.state = 0
	self:setOpacity(0)
	self:setVisible(false)
	self:stopAllActions()
end

return DyingEffectLayer