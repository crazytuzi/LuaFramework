-- @Author: wanghai
-- @Date:   2020-04-10 18:28:12
-- @Last Modified by:   wanghai
-- @Last Modified time: 2020-04-10 19:13:54

local QSBAction = import(".QSBAction")
local QSBSummonMonstersInSoulTower = class("QSBSummonMonstersInSoulTower", QSBAction)

function QSBSummonMonstersInSoulTower:_execute(dt)

    app.battle:summonMonstersInSoulTower(self._attacker, self._skill, self:getOptions().attacker_level and self._attacker:getLevel())

    self:finished()
end

return QSBSummonMonstersInSoulTower