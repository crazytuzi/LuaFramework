--[[
    将人物从grid中移除
    人物将不能普攻和释放自动技能，但是ai释放中释放的技能会正常运行。
    @common
--]]
local QSBAction = import(".QSBAction")
local QSBRemoveFromGrid = class("QSBRemoveFromGrid", QSBAction)

function QSBRemoveFromGrid:ctor(director, attacker, target, skill, options)
    QSBRemoveFromGrid.super.ctor(self, director, attacker, target, skill, options) 

    self._executed = false
end

function QSBRemoveFromGrid:_execute(dt)
    local target = self._target or self._attacker:getTarget()
    if nil ~= target and not target:isDead() then
        app.grid:removeActor(target)
        self._executed = true

        self:finished()
    else
        self:finished()
    end
end

function QSBRemoveFromGrid:_onCancel()
    if self._executed then
        local target = self._target or self._attacker:getTarget()
        if nil ~= target and not target:isDead() then
            app.grid:addActor(target)
        end
    end
end

function QSBRemoveFromGrid:_onRevert()
    if self._executed then
        local target = self._target or self._attacker:getTarget()
        if nil ~= target and not target:isDead() then
            app.grid:addActor(target)
        end
    end
end

return QSBRemoveFromGrid
