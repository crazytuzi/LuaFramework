--[[
    Class name QSBOnMarked
    Create by wanghai
--]]
local QSBAction = import(".QSBAction")
local QSBOnMarked = class("QSBOnMarked", QSBAction)

local QActor = import("...models.QActor")

function QSBOnMarked:_execute(dt)
    local actor = self._attacker
    if not actor or actor:isDead() then
        self:finished()
        return
    end

    local enemies = app.battle:getMyEnemies(actor)
    if self._options.on then
        for _, enemy in ipairs(enemies) do
            if not enemy:isHealth() then
                if not enemy:isLockTarget() then
                    enemy:setTarget(actor)
                    enemy:lockTarget()
                end
            end
        end
        actor:onMarked()
    elseif self._options.off then
        for _, enemy in ipairs(enemies) do
            if not enemy:isHealth() then
                enemy:unlockTarget()
                enemy:setTarget(nil)
            end
        end
        actor:onUnMarked()
    end

    self:finished()
end

function QSBOnMarked:_onCancel()
    self:_onRevert()
end

function QSBOnMarked:_onRevert()
    if self._options.on then
        local enemies = app.battle:getMyEnemies(actor)
        for _, enemy in ipairs(enemies) do
            if not enemy:isHealth() then
                enemy:unlockTarget()
                enemy:setTarget(nil)
            end
        end
        self._attacker:onUnMarked()
    end
end

return QSBOnMarked
