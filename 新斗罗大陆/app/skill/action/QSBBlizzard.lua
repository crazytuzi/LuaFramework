--[[
    Class name QSBBlizzard
    Create by julian 
    deprecated on Apr.11,2016
--]]

local QSBAction = import(".QSBAction")
local QSBBlizzard = class("QSBBlizzard", QSBAction)

local QBaseEffectView = import("...views.QBaseEffectView")
local QSkill = import("...models.QSkill")

local positions = {{0, 0}, {-177.19, 65.31}, {-305.8, -82.58}, {237.54, -82.58}, {-463.46, 26.82}, {355.05, 26.82}, {-86.62, -102.84}, {164.6, 30.88}}
local startFrame = {0, 5, 10, 15, 15, 20, 25, 25}

function QSBBlizzard:_execute(dt)
	if self._options.effect_id == nil or self._skill:getRangeType() ~= QSkill.MULTIPLE then
		self:finished()
		return
	end

	if self._startTime == nil then
		self._startTime = app.battle:getTime()
		self._positions = clone(positions)
		self._startFrame = clone(startFrame)

		local size = self._target:getCoreRect().size
        self._deltaX = app.random(math.floor(size.width * 0.8)) - size.width * 0.8 * 0.5
        self._deltaY = app.random(math.floor(size.height * 0.8)) - size.height * 0.8 * 0.5
	end
	self._currentTime = app.battle:getTime()

	if self._currentTime - self._startTime >= self._startFrame[1] / 30 then
		local targetPosition = self._director:getTargetPosition()
		self:_addEffectToScene(self._positions[1][1] * 0.5 + targetPosition.x + self._deltaX, self._positions[1][2] * 0.5 + targetPosition.y + self._deltaY)
		table.remove(self._positions, 1)
		table.remove(self._startFrame, 1)
	end

	if #self._startFrame == 0 then
		self:finished()
	end
end

function QSBBlizzard:_addEffectToScene(x, y)
	if x == nil or y == nil then
		return
	end

	local effectId = self._options.effect_id

	local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectId)
	local effect = frontEffect or backEffect
	if effect == nil then
		return
	end
    effect:setPosition(x, y)
    app.scene:addEffectViews(effect)
    
    -- play animation and sound
    effect:playAnimation(effect:getPlayAnimationName(), false)
    effect:playSoundEffect(false)

    effect:afterAnimationComplete(function()
        app.scene:removeEffectViews(effect)
    end)

end

return QSBBlizzard
