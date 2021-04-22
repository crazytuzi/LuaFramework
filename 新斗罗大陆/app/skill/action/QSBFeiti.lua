--[[
    Class name QSBFeiti
    Create by julian 
--]]

local QSBAction = import(".QSBAction")
local QSBFeiti = class("QSBFeiti", QSBAction)

local TOTAL_FRAME = 10

function QSBFeiti:ctor(director, attacker, target, skill, options)
	QSBFeiti.super.ctor(self, director, attacker, target, skill, options)

	local actor = self._attacker
	local target = self._target
	local skill = self._skill
	local director = self._director

	if not IsServerSide then
		local actorView = app.scene:getActorViewFromModel(actor)
		self._bodyPosition = actorView:getBonePosition("dummy_body")
	end
	self._actorPosition = clone(actor:getPosition())
	self._dragPosition = app.grid:_toScreenPos(app.grid:_findBestPositionByTargetDirectline(actor, target))
end

function QSBFeiti:_execute(dt)
	local actor = self._attacker
	local target = self._target
	local skill = self._skill
	local director = self._director
	local isFlipX = self._isFlipX
	local rotation = self._rotation
	local dragPosition = self._dragPosition
	local originalPosition = self._actorPosition
	local currentFrame = self._currentFrame

	if not currentFrame then
		currentFrame = 0
	end

	if not IsServerSide then
		local actorView = app.scene:getActorViewFromModel(actor)
		if not rotation then
			local currentPosition = clone(actor:getPosition())
			local bodyPosition = {x = currentPosition.x, y = currentPosition.y + actorView:getBonePosition("dummy_body").y - self._bodyPosition.y}
			rotation = math.atan2(dragPosition.y - bodyPosition.y, dragPosition.x - bodyPosition.x)
			rotation = -rotation / math.pi * 180
			isFlipX = dragPosition.x < bodyPosition.x
			rotation = isFlipX and (180 - rotation) or rotation
			self._rotation = rotation
			self._isFlipX = isFlipX
		end

		if currentFrame == 0 then
			-- 初始化各个特效
			-- 龙头
			actor:playSkillEffect("kick_1_3", nil, {rotation = rotation, isFlipX = isFlipX})
			-- 龙身
			actor:playSkillEffect("kick_1_1", nil, {rotation = rotation, isFlipX = isFlipX})
			-- 冲击
			local bonePosition = actorView:getBonePosition("dummy_body")
			local targetPosition = clone(actor:getPosition())
			targetPosition.x = targetPosition.x + bonePosition.x
			targetPosition.y = targetPosition.y + bonePosition.y
			actor:playSkillEffect("kick_1_2", nil, {rotation = rotation, front_layer = true, targetPosition = targetPosition})
		end
	end

	if currentFrame <= TOTAL_FRAME then
		-- 移动
		local percent = (currentFrame / TOTAL_FRAME)
		local position = {x = math.sampler(originalPosition.x, dragPosition.x, percent), y = math.sampler(originalPosition.y, dragPosition.y, percent)}
		app.grid:moveActorTo(actor, position, false, true, true)
        actor:setActorPosition(position)
	else
		self:finished()
	end

	self._currentFrame = currentFrame + 1
end

return QSBFeiti