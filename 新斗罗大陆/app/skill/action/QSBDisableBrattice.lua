--[[
    关闭亚索的风墙(hosaki 面对疾风吧 So lei ya gai duo)
    @common
    by wanghai
--]]
local QSBAction = import(".QSBAction")
local QSBDisableBrattice = class("QSBDisableBrattice", QSBAction)

function QSBDisableBrattice:_execute(dt)
    -- local enemies = app.battle:getAllMyEnemies(self._attacker)
    -- for _, actor in ipairs(enemies) do
    --     actor:disableIgnoreHurtArgs()
    -- end

    app.grid:disableBrattice()

    self:finished()
end

return QSBDisableBrattice