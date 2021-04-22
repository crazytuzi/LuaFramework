
--[[--

“NPC”类

从“角色”类继承，增加了经验值等属性

]]

local QNpcModel = import("...models.QNpcModel")
local QVCRNpcModel = class("QVCRNpcModel", QNpcModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QFileCache = import("...utils.QFileCache")
local QActor = import("...models.QActor")

QVCRNpcModel.schema = clone(QNpcModel.schema)

function QVCRNpcModel:ctor(id, udid, events, callbacks, additional_skills, dead_skill)
    QVCRNpcModel.super.ctor(self, id, events, callbacks, additional_skills, dead_skill)

    self:set("udid", udid)

    self._maxhp = 0
    self._isDead = false
end

function QVCRNpcModel:setActorPosition(pos)
    local lastPositionX = self._position.x
    self._position = pos
    self:dispatchEvent({name = QActor.SET_POSITION_EVENT, position = self._position})
end

function QVCRNpcModel:setMaxHp(maxhp)
    self._maxhp = maxhp
end

function QVCRNpcModel:getMaxHp()
    return self._maxhp
end

function QVCRNpcModel:setIsDead(isDead)
    self._isDead = isDead
end

function QVCRNpcModel:isDead()
    return self._isDead
end

return QVCRNpcModel
