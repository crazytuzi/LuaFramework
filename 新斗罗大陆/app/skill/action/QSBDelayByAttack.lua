--[[
    Class name QSBDelayByAttack
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBDelayByAttack = class("QSBDelayByAttack", QSBAction)

function QSBDelayByAttack:_execute(dt)
	if self._isExecuting == true then
		return
	end

    local coefficient = self._attacker:getMaxHasteCoefficient()
    if self:isAffectedByHaste() == false then
        coefficient = 1
    end
	
    local displayId = self._attacker:getDisplayID()
    local characterDisplay = db:getCharacterDisplayByID(displayId)
    local animationName = self._options.animation or self._skill:getActorAttackAnimation()
    -- if string.len(animationName) == 0 then
    --     self:finished()
    --     return
    -- end
    local delayFrame = characterDisplay[animationName] or HIT_DELAY_FRAME
    local delay = delayFrame / SPINE_RUNTIME_FRAME * (1 / coefficient)
    delay = math.max(delay, 0)
	self._delayHandle = app.battle:performWithDelay(function()
        self:finished()
    end, delay, self._attacker)

    self._isExecuting = true
end

function QSBDelayByAttack:_onCancel()
    if self._delayHandle ~= nil then
        app.battle:removePerformWithHandler(self._delayHandle)
    end
end

return QSBDelayByAttack