
local QModelBase = import("...models.QModelBase")
local QBattleVCRManager = class("QBattleVCRManager", QModelBase)

local QActor = import("...models.QActor")
local QSkill = import("...models.QSkill")
local QAIDirector = import("...ai.QAIDirector")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QFileCache = import("...utils.QFileCache")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QTutorialStageEnrolling = import("...tutorial.enrolling.QTutorialStageEnrolling")
local QBattleLog = import("...controllers.QBattleLog")
local QBattleVCR = import("...vcr.controllers.QBattleVCR")

function QBattleVCRManager:ctor()
    QBattleVCRManager.super.ctor(self)

    self._battleTime = 0
    self._timeGear = 1.0

    self._exceptActor = {}

    self._trapDirectors = {}
    self._bullets = {}
    self._lasers = {}

    self._bulletTimeReferenceCount = 0

    self._nextSchedulerHandletId = 1
    self._delaySchedulers = {}
end

function QBattleVCRManager:start()
    self._frameId = scheduler.scheduleUpdateGlobal(handler(self, QBattleVCRManager._onFrame))
    self._battleTimeId = scheduler.scheduleUpdateGlobal(handler(self, QBattleVCRManager._onBattleFrame))
end

function QBattleVCRManager:stop()
    if self._battleTimeId ~= nil then
        scheduler.unscheduleGlobal(self._battleTimeId)
        self._battleTimeId = nil
    end
end

function QBattleVCRManager:performWithDelay(func, delay, actor, pauseBetweenWave)
    if func == nil or delay < 0 then
        assert(false, "invalid args to call QBattleVCRManager:performWithDelay")
        return nil
    end

    local handlerId = self._nextSchedulerHandletId
    table.insert(self._delaySchedulers, {handlerId = handlerId, delay = delay, func = func, actor = actor, pauseBetweenWave = pauseBetweenWave})
    self._nextSchedulerHandletId = handlerId + 1
    return handlerId
end

function QBattleVCRManager:_handleSchedulerOnFrame(dt)
    if #self._delaySchedulers > 0 then
        for _, schedulerInfo in ipairs(self._delaySchedulers) do
            -- if not schedulerInfo.pauseBetweenWave or not self:isPausedBetweenWave() then
                schedulerInfo.delay = schedulerInfo.delay - dt
            -- end
            if schedulerInfo.delay < 0 then
                schedulerInfo.func()
            end
        end

        while true do
            local removeIndex = 0
            for i, schedulerInfo in ipairs(self._delaySchedulers) do
                if schedulerInfo.delay < 0 then
                    removeIndex = i
                    break
                end
            end
            if removeIndex ~= 0 then
                table.remove(self._delaySchedulers, removeIndex)
            else
                break
            end
        end
    end
end

function QBattleVCRManager:removePerformWithHandler(handlerId)
    if handlerId <= 0 then
        return
    end

    local index = 0
    for i, schedulerInfo in ipairs(self._delaySchedulers) do
        if schedulerInfo.handlerId == handlerId then
            index = i
            break
        end
    end

    if index > 0 then
        table.remove(self._delaySchedulers, index)
    end
end

function QBattleVCRManager:_onBattleFrame(dt)
    if self._paused == true then
        return
    end

    dt = dt * self:getTimeGear()
    
    self._battleTime = self._battleTime + dt

    self:_handleSchedulerOnFrame(dt)
end

function QBattleVCRManager:_onFrame(dt)
    if self._paused == true or self._ended == true then 
        return 
    end

    collectgarbage("step", 10)

    if self._bulletTimeReferenceCount == 0 then
        for _, trapDirector in ipairs(self._trapDirectors) do
            trapDirector:visit(dt)
        end
        for i, trapDirector in ipairs(self._trapDirectors) do
            if trapDirector:isCompleted() == true then
                table.remove(self._trapDirectors, i)
                break
            end
        end
    end

    if self._bulletTimeReferenceCount == 0 then
        for _, bullet in ipairs(self._bullets) do
            bullet:visit(dt)
        end
        for i, bullet in ipairs(self._bullets) do
            if bullet:isFinished() == true then
                table.remove(self._bullets, i)
                break
            end
        end
    end

    if self._bulletTimeReferenceCount == 0 then
        for _, laser in ipairs(self._lasers) do
            laser:visit(dt)
        end
        for i, laser in ipairs(self._lasers) do
            if laser:isFinished() == true then
                table.remove(self._lasers, i)
                break
            end
        end
    end
end

function QBattleVCRManager:addBullet(bullet)
    table.insert(self._bullets, bullet)
end

function QBattleVCRManager:addLaser(laser)
    table.insert(self._lasers, laser)
end

function QBattleVCRManager:getTime()
    return self._battleTime
end

function QBattleVCRManager:setTimeGear(time_gear)
	self._timeGear = time_gear
end

function QBattleVCRManager:getTimeGear()
	return self._timeGear
end

function QBattleVCRManager:isPVPMode()
    return false
end

function QBattleVCRManager:isInArena()
    return false
end

function QBattleVCRManager:isInSunwell()
    return false
end

return QBattleVCRManager