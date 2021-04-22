--[[
    Class name QSBManualMode
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBManualMode = class("QSBManualMode", QSBAction)

local QActor = import("...models.QActor")

function QSBManualMode:_execute(dt)
    if self._attacker == nil or self._attacker:isDead() then
        self:finished()
        return
    end

    if self:getOptions().enter == true then
        if self._attacker:getManualMode() ~= self._attacker.STAY then -- 这里应该把ATTACK模式也转入STAY模式，保证移动不会被打断
            app.battle.entered_actor[self._attacker] = self._attacker:getManualMode()
            self._attacker:setManualMode(self._attacker.STAY)
        end
    elseif self:getOptions().exit == true then
        if self._attacker:getManualMode() == self._attacker.STAY and app.battle.entered_actor[self._attacker] ~= nil then
            self._attacker:setManualMode(app.battle.entered_actor[self._attacker])
            app.battle.entered_actor[self._attacker] = nil
            
            self._attacker._debug_hitlog = true
        end
    end

    self:finished()
end

function QSBManualMode:_onCancel()
    self:_onRevert()
end

function QSBManualMode:_onRevert()
    if self._attacker:getManualMode() == self._attacker.STAY and app.battle.entered_actor[self._attacker] ~= nil then
        self._attacker:setManualMode(app.battle.entered_actor[self._attacker])
        app.battle.entered_actor[self._attacker] = nil
    end
end

return QSBManualMode