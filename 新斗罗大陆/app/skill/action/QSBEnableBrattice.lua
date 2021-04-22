--[[
    开启亚索的风墙(hosaki 面对疾风吧 So lei ya gai duo)
    @common
    by wanghai
--]]
local QSBAction = import(".QSBAction")
local QSBEnableBrattice = class("QSBEnableBrattice", QSBAction)

function QSBEnableBrattice:_execute(dt)

    local ignoreArgs = {}
    if self._options.bratticePosX then
        ignoreArgs.bratticePosX = self._options.bratticePosX
    else
        ignoreArgs.bratticePosX = BATTLE_AREA.left + BATTLE_AREA.width * 0.5
    end
    if self._options.ignoreDirect then
        ignoreArgs.ignoreDirect = self._options.ignoreDirect
    else
        ignoreArgs.ignoreDirect = -1
    end
    ignoreArgs.type = self._attacker:getType()

    -- local enemies = app.battle:getAllMyEnemies(self._attacker)
    -- table.mergeForArray(enemies,app.battle:getMyEnemiesSupportHero(self._attacker))
    -- for _, actor in ipairs(enemies) do
    --     actor:enableIgnoreHurtArgs(ignoreArgs)
    -- end
    app.grid:enableBrattice(ignoreArgs)

    self:finished()
end

function QSBEnableBrattice:_onRevert()
    -- local enemies = app.battle:getAllMyEnemies(self._attacker)
    -- for _, actor in ipairs(enemies) do
    --     actor:disableIgnoreHurtArgs()
    -- end
    app.grid:disableBrattice()
end

function QSBEnableBrattice:_onCancel()
    -- local enemies = app.battle:getAllMyEnemies(self._attacker)
    -- for _, actor in ipairs(enemies) do
    --     actor:disableIgnoreHurtArgs()
    -- end
    app.grid:disableBrattice()
end

return QSBEnableBrattice