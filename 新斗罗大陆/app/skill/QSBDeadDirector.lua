--[[
    Class name QSBDeadDirector
    do dead behavior
--]]    

local QSBDeadDirector = class("QSBDeadDirector")

local QSBNode = import(".QSBNode")
local QFileCache = import("..utils.QFileCache")

function QSBDeadDirector:ctor(actor, name)
    self._attacker = actor
    self._target = actor

    self._skillBehavior = self:createSkillBehaviorByName(name)
    self._isSkillFinished = false
end

function QSBDeadDirector:isFinished()
    return self._isSkillFinished
end

function QSBDeadDirector:createSkillBehaviorByName(name)
    local config = QFileCache.sharedFileCache():getSkillConfigByName(name)
    return self:_createSkillBehaviorNode(config)
end

function QSBDeadDirector:_createSkillBehaviorNode(config)
    if config == nil or type(config) ~= "table" then
        return nil
    end

    local skillClass = QFileCache.sharedFileCache():getSkillClassByName(config.CLASS)
    local options = clone(config.OPTIONS)
    local node = skillClass.new(self, self._attacker, self._target, self._skill, options)

    local args = config.ARGS
    if args ~= nil then
        for k, v in pairs(args) do
            local child = self:_createSkillBehaviorNode(v)
            if child ~= nil then
                node:addChild(child)
            end
        end
    end

    return node
end

function QSBDeadDirector:visit(dt)
    if self._isSkillFinished == true then
        return
    end

    if self._skillBehavior:getState() == QSBNode.STATE_FINISHED then
        self._isSkillFinished = true
    elseif self._skillBehavior:getState() == QSBNode.STATE_EXECUTING then
        self._skillBehavior:visit(dt)
    elseif self._skillBehavior:getState() == QSBNode.STATE_WAIT_START then
        self._skillBehavior:start()
        self._skillBehavior:visit(0)
    end
end

return QSBDeadDirector
