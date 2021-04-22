-- 用于记录被攻击的详细情况。
-- 但是后来功能被改造过一下：一旦开始攻击，则将攻击方也放入hitlog，用于保持战斗的持续性。因此现在HitLog的功能变成一个仇恨列表而不是攻击记录。

local QHitLog = class("QHitLog")

QHitLog.NO_DAMAGE = 0 -- 由于HitLog也保存了攻击对象，因此可能出现治疗误认为自己被攻击了，所以需要在治疗的AI里面单独处理这种情况

local bymt = {
    __index = function(t, k)
        if k == "by" then
            local id = rawget(t, "actorId")
            return app.battle:getActorByUDID(id)
        end
        return rawget(t, k)
    end,
    __newindex = function(t, k, v)
        rawset(t, k, v)
    end
}

function QHitLog:ctor()
    self:clearAll()
end

function QHitLog:clearAll()
    self._hits = {}
end

function QHitLog:clearByActor(actor)
    local new_hits = {}

    for _, hit in ipairs(self._hits) do
        if hit.by ~= actor then
            table.insert(new_hits, hit)
        end
    end
    self._hits = new_hits
    if self._oldMaxHatred and self._oldMaxHatred.by == actor then
        self._oldMaxHatred = nil
    end
end

function QHitLog:addNewHit(by, damage, skillId, hatred)
    local actor = app.battle:getActorByUDID(by)
    if actor and (actor:isDead() or actor:isIdleSupport() or actor:isNeutral() or (actor:isGhost() and not actor:isAttackedGhost()) ) then
        return
    end

    local cur = app.battle:getTime()
    for i, hit in ipairs(self._hits) do
        if hit.by == actor then
            -- 如果这一次的damage为QHitLog.NO_DAMAGE，则维持上一次的damage，因为此次有可能未命中，设置为0可能导致后续的getEnemiesInPeriod判断错误
            if damage == QHitLog.NO_DAMAGE then
                damage = hit.damage
            end
   
            table.remove(self._hits, i)
            break
        end
    end

    -- add a new record at the head of the table
    local hit = {}
    setmetatable(hit, bymt)

    hit.time = app.battle:getTime()
    hit.actorId = by
    hit.damage = damage
    hit.skillId = skillId
    hit.hatred = hatred

    table.insert(self._hits, 1, hit)
end

function QHitLog:isEmpty()
    local cur = app.battle:getTime()
    local result = true
    for i, hit in ipairs(self._hits) do
        if cur - hit.time < global.hatred_period and hit.by:isDead() == false then
            result = false
            break
        end
    end
    return result
end

-- 返回在一定时间内攻击过自己的敌人
function QHitLog:getEnemiesInPeriod(seconds)
    local enemies = {}
    local cur = app.battle:getTime()
    for i, hit in ipairs(self._hits) do
        -- 由于攻击对象也加入了HitLog保持战斗的持续性，因此这里要判断哪些是真正的被击
        if hit.damage ~= QHitLog.NO_DAMAGE and cur - hit.time < seconds then
            table.insert(enemies, hit.by)
        end
    end
    return enemies
end

function QHitLog:getLatestHit()
    return self._hits[1]
end

local function hatredMax(list)
    local max = 0
    local r = nil
    local hatred = nil
    for _, item in ipairs(list) do
        hatred = item.hatred
        if hatred >= max then
            r = item
            max = hatred
        end
    end

    return r
end

function QHitLog:getMaxHatred()
    local oldMaxHatred = self._oldMaxHatred
    local oldMaxHatredOK = false

    local cur = app.battle:getTime()
    local actorHatred = {}

    -- calculate accumurated hatred in the limited period
    for i, hit in ipairs(self._hits) do
        if cur - hit.time < global.hatred_period and hit.by:isDead() == false then
            if oldMaxHatred and hit.by == oldMaxHatred.by then
                oldMaxHatredOK = true
            end
            table.insert(actorHatred, {
                by = hit.by,
                hatred = hit.hatred,
            })
        end
    end

    -- 老的仇恨目标已经超时，或者还没有决定过老的仇恨目标
    -- find the live actor with maximium hatred
    local max = hatredMax(actorHatred)
    if max ~= nil then
        if oldMaxHatredOK and oldMaxHatred.hatred >= max.hatred then
            max = oldMaxHatred
        end
        self._oldMaxHatred = max
        return max.by
    end
    return nil
end

function QHitLog:hasStoredHits()
    return self._stored_hits ~= nil
end

-- 储存当前的仇恨列表
function QHitLog:store()
    assert(self._stored_hits == nil, "hitLog is already store!!")
    self._stored_hits = clone(self._hits)
    self._stored_time = app.battle:getTime()
end

-- 恢复之前保存的仇恨列表
function QHitLog:restore()
    if self._stored_hits == nil then
        return
    end

    -- nzhang: 恢复仇恨列表的必要操作，要把时间差也考虑进去。不然的话因为10秒最大仇恨追溯期的存在，会使得恢复仇恨列表毫无意义。
    for _, hit in ipairs(self._stored_hits) do
        hit.time = hit.time + (app.battle:getTime() - self._stored_time)
    end

    self._stored_hits = nil
end

return QHitLog