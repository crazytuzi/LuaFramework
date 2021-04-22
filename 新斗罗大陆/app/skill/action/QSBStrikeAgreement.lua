--[[
    Class name QSBStrikeAgreement
    Create by wanghai
--]]
local QSBAction = import(".QSBAction")
local QSBStrikeAgreement = class("QSBStrikeAgreement", QSBAction)

local QActor = import("...models.QActor")

function QSBStrikeAgreement:_execute(dt)
    local target = self._options.strike_agreementee
    if nil == target or target:isDead() then
        self:finished()
        return
    end
    if not self._attacker:isTeammate(target) then
        self:finished()
        return
    end
    local hpPercent = self._attacker:getHp() / self._attacker:getMaxHp()
    if hpPercent < self._options.hp_threshold then
        self:finished()
        return
    end

    target:addStrikeAgreementers(self._attacker, self._options.percent)

    local handler = self._attacker:addEventListener(QActor.DECREASEHP_EVENT, handler(self._attacker, self._attacker.onDecreasHp))
    self._director:setStrikeAgreementHandler(handler)
    local delayHandler = app.battle:performWithDelay(function()
        self:_cancel()
        self._director:setStrikeAgreementHandler(nil)
        end, self._options.time)
    self._director:setStrikeAgreementDelayHandler(delayHandler)

    self:finished()
end

function QSBStrikeAgreement:_onCancel()
    self:_onRevert()
end

function QSBStrikeAgreement:_onRevert()
    self:_cancel()
    app.battle:removePerformWithHandler(self._director:getStrikeAgreementDelayHandler())
    self._director:setStrikeAgreementDelayHandler(nil)
end

function QSBStrikeAgreement:_cancel()
    local target = self._options.strike_agreementee
    target:removeStrikeAgreementers(self._attacker)
    
    self._attacker:removeEventListener(self._director:getStrikeAgreementHandler())
    self._director:setStrikeAgreementHandler(nil)
end

return QSBStrikeAgreement