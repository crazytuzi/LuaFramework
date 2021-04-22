--[[
    将人物加到grid中管理
    必须和QSBSRemoveFromGrid配合使用
    @common
--]]
local QSBAction = import(".QSBAction")
local QSBAddToGrid = class("QSBSRemoveFromGrid", QSBAction)

function QSBAddToGrid:ctor(director, attacker, target, skill, options)
    QSBAddToGrid.super.ctor(self, director, attacker, target, skill, options) 

    self._executed = false
end

function QSBAddToGrid:_execute(dt)
    local target = self._target or self._attacker:getTarget()
    if nil ~= target and not target:isDead() then
        app.grid:addActor(target)
        self._executed = true

        self:finished()
    else
        self:finished()
    end
end

function QSBAddToGrid:_onCancel()
    if self._executed then
        local target = self._target or self._attacker:getTarget()
        if nil ~= target and not target:isDead() then
            app.grid:removeActor(target)
        end
    end
end

function QSBAddToGrid:_onRevert()
    if self._executed then
        local target = self._target or self._attacker:getTarget()
        if nil ~= target and not target:isDead() then
            app.grid:removeActor(target)
        end
    end
end

return QSBAddToGrid
