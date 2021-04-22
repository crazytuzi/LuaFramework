--[[
	设置魂师到某个固定的像素位置
	@common
--]]
local QSBAction = import(".QSBAction")
local QSBSetActorToPos = class("QSBSetActorToPos", QSBAction)

local QActor = import("...models.QActor")

local QBaseEffectView
if not IsServerSide then
    QBaseEffectView = import("...views.QBaseEffectView")
end

local math_min = math.min

function QSBSetActorToPos:ctor(director, attacker, target, skill, options)
    QSBSetActorToPos.super.ctor(self, director, attacker, target, skill, options)
    self._speed = self._options.speed or 200
    self._pos = self._options.pos
    self._actorPos = attacker:getPosition()
    local distance = q.distOf2Points(self._actorPos, self._pos)
    self._time = distance / self._speed

    if not IsServerSide then
    	local actorView = app.scene:getActorViewFromModel(self._attacker)
    	self._effect = QBaseEffectView.createEffectByID(self._options.effectId)
    	self._effect:setPosition(self._actorPos.x, self._actorPos.y)
    	self._effect:playAnimation(self._effect:getPlayAnimationName(), true)

    	function self._effect:getActorView()
    		return actorView
    	end

        self._effect:retain()
        app.scene:addEffectViews(self._effect, {isFrontEffect = true})
    end
end

function QSBSetActorToPos:_execute(dt)
	if nil == self._passTime then
		self._passTime = 0
	end
	self._passTime = self._passTime + dt
	self._passTime = math_min(self._passTime, self._time)

	if not IsServerSide then
		local percent = self._passTime / self._time
		local newx = math.round(self._actorPos.x * (1 - percent) + self._pos.x * percent)
		local newy = math.round(self._actorPos.y * (1 - percent) + self._pos.y * percent)
		self._effect:setPosition(newx, newy)
	end

	if self._passTime >= self._time then
		app.grid:setActorTo(self._attacker, self._pos, true)
		self:finished()
		return
	end
end

function QSBSetActorToPos:finished()
    QSBSetActorToPos.super.finished(self)
    if not IsServerSide then
        app.scene:removeEffectViews(self._effect)
    end
end

return QSBSetActorToPos
