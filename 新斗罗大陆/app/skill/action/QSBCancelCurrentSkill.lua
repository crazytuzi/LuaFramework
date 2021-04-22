-- @Author: wanghai
-- @Date:   2020-07-31 15:07:03
-- @Last Modified by:   wanghai
-- @Last Modified time: 2020-07-31 15:09:13


local QSBAction = import(".QSBAction")
local QSBCancelCurrentSkill = class("QSBCancelCurrentSkill", QSBAction)

function QSBCancelCurrentSkill:_execute(dt)
    local actor = self._attacker
    self._attacker:_cancelCurrentSkill()
    self:finished()
end

return QSBCancelCurrentSkill
