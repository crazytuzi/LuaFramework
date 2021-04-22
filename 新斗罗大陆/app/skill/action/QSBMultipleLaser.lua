--[[
    多条激光攻击，一条激光攻击目标，其他激光随机选择攻击目标
--]]
local QBullet = import("...models.QBullet")
local QSBAction = import(".QSBAction")
local QSBMultipleLaser = class("QSBMultipleLaser", QSBAction)

local QLaser = import("...models.QLaser")

function QSBMultipleLaser:ctor(director, attacker, target, skill, options)
    QSBMultipleLaser.super.ctor(self, director, attacker, target, skill, options)
    self._interval_time = self._options.interval_time or 0
    self._currentIndex = 1
    self._intrinsicIsCreated = false
end

function QSBMultipleLaser:_execute(dt)
	if self._options.effect_id == nil or self._options.count == nil or self._options.count < 1 then
		self:finished()
        return
	end

    if self._startTime == nil then
        self._startTime = app.battle:getTime()
        self._currentTime = self._startTime
        self._lastTriggerTime = self._startTime
    else
        self._currentTime = self._currentTime + dt
    end

    if not self._intrinsicIsCreated then
        local targets = {self._target}
        if self._options.is_bullet then
            self:createBullet(targets)
        else
            self:createLaser(targets)
        end
        self._intrinsicIsCreated = true
    end

    if self._currentTime - self._lastTriggerTime >= self._interval_time then
        if self._currentIndex <= self._options.count then
            local enemies = self:getCandidates()

            local index = app.random(1, #enemies)
            local targets = {enemies[index]}
            if self._options.is_bullet then
                if self._options.effect_other then
                    self._options.effect_id = self._options.effect_other[self._currentIndex]
                end
                self:createBullet(targets)
            else
                self:createLaser(targets)
            end
            table.remove(enemies, index)
            self._currentIndex = self._currentIndex + 1
        end
        self._lastTriggerTime = self._lastTriggerTime + self._interval_time
    end

    if self._currentIndex > self._options.count then
        self:finished()
    end
end

function QSBMultipleLaser:getCandidates()
    if self._candidates == nil or #self._candidates == 0 then
        self._candidates = {}
        local actor = self._attacker
        local target = self._target
        local enemies = app.battle:getMyEnemies(actor)
        for _, enemy in ipairs(enemies) do
            if not enemy:isDead() and not enemy:isSupport() and target ~= enemy then
                table.insert(self._candidates, enemy)
            end
        end
        -- 只有一个敌人的时候额外子弹也攻击这个敌人
        if #self._candidates == 0 then
            table.insert(self._candidates, target)
        end
    end

    return self._candidates
end

function QSBMultipleLaser:createLaser(targets)
    local laser = QLaser.new(self._attacker, targets, self._skill, self._options)
    app.battle:addLaser(laser)

    if app.battle._battleVCR then
        app.battle._battleVCR:_onLaserCreated(laser)
    end
end

function QSBMultipleLaser:createBullet(targets)
    local bullet = QBullet.new(self._attacker, targets, self._director, self._options)
    app.battle:addBullet(bullet)

    if app.battle._battleVCR then
        app.battle._battleVCR:_onBulletCreated(bullet)
    end
end

return QSBMultipleLaser