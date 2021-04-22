--[[
    Class name QSBUnLockSkill
    Create by julian 
    用来解锁触发的被动技能，被动技能如果需要加锁在会在触发的时候枷锁
--]]
local QSBAction = import(".QSBAction")
local QSBUnLockSkill = class("QSBUnLockSkill", QSBAction)

local QActor = import("...models.QActor")

function QSBUnLockSkill:_execute(dt)
    if self._options.skill_id then
        print("=====================QSBUnLockSkill:_execute", self._options.skill_id .. "locked_num" .. self._attacker:getType())
        local key = self._options.skill_id .. "locked_num" .. self._attacker:getType()
        local lockedNum = app.battle:getFromMap(key) or 0
        app.battle:setFromMap(key, lockedNum - 1)
    else
        self._skill:sumLockNum()
    end
    
    self:finished()
end

return QSBUnLockSkill
