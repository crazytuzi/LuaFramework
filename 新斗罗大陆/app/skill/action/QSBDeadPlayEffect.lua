--[[
	死亡动作专用
--]]

local QSBAction = import(".QSBAction")
local QSBDeadPlayEffect = class("QSBDeadPlayEffect", QSBAction)
local QBaseEffectView = import("...views.QBaseEffectView")
function QSBDeadPlayEffect:ctor( ... )
	QSBDeadPlayEffect.super.ctor(self,...)
end

function QSBDeadPlayEffect:_execute(dt)
	if self._isAnimationPlaying == true then
		return
	end

	if self._options.effect_id == nil or string.len(self._options.effect_id) == 0 then
		self:finished()
		return
	end

	local file = db:getEffectFileByID(self._options.effect_id)

	if not file then 
		self:finished() 
		return 
	end

	self._widgetActor = app.scene:getActorViewFromModel(self._attacker)
	self._effect = QBaseEffectView.new(file)

	if not self._effect or not self._widgetActor then
		self:finished()
		return
	end

	self._effect:setPositionActor(self._attacker)

	local isFlipWithActor = db:getEffectIsFlipWithActorByID(self._options.effect_id)
	if isFlipWithActor then
		local scale  = db:getEffectScaleByID(self._options.effect_id) or 1
		self._effect:getSkeletonView():setSkeletonScaleX((self._attacker:isFlipX() and -1 or 1 ) * scale)
		self._effect:getSkeletonView():setSkeletonScaleY(scale)
	end

	app.scene:addEffectViews(self._effect, {isFrontEffect = true})

	self._effect:afterAnimationComplete(handler(self, self._animationPlayEnd))

	self._effect:playAnimation(self._effect:getPlayAnimationName(), false)

	self._widgetActor:getSkeletonActor():setVisible(false)

	self._isAnimationPlaying = true
end

function QSBDeadPlayEffect:_animationPlayEnd()
	self:finished()
end


function QSBDeadPlayEffect:_onCancel()
	if self._effect then
		self._effect:stopAnimation()
	end
end

return QSBDeadPlayEffect
