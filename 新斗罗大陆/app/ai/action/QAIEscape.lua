
local QAIAction = import("..base.QAIAction")
local QAIEscape = class("QAIEscape", QAIAction)

function QAIEscape:ctor( options )
    QAIEscape.super.ctor(self, options)
    self:setDesc("逃离打击")
end

function QAIEscape:_execute(args)
    if true then return false end -- 尝试停止使用这个AI

    local actor = args.actor

    local hit = actor:getHitLog():getLatestHit()
    if hit == nil then return false end

    if actor:isWalking() then return false end

    if app.battle:getTime() - hit.time > 0.2 or hit.by:isDead() or hit.damage == actor:getHitLog().NO_DAMAGE then
        -- 如果最近的一次打击发生在0.2秒之前，则不处理
        return false
    end

    local distance = self:getOptions().distance
    assert(distance ~= nil, "QAIEscape must config the option with the name 'distance'")

    distance = distance * global.pixel_per_unit

    -- 向远离敌人的方向移动
    local enemyPos = hit.by:getPosition()
    local myPos = actor:getPosition()

    -- 目标位置
    local targetPos = qccp(0, 0)
    local d = math.sqrt((enemyPos.x - myPos.x) * (enemyPos.x - myPos.x) + (enemyPos.y - myPos.y) * (enemyPos.y - myPos.y))
    if d < 0.1 then
        -- 如果靠的太近，则按照水平方向未来能移动最远的方向移动
        enemyPos = qccp(enemyPos.x, enemyPos.y) -- 复制，否则会修改actor的成员变量
        if enemyPos.x < BATTLE_SCREEN_WIDTH / 2 then
            enemyPos.x = -10
        else
            enemyPos.x = BATTLE_SCREEN_WIDTH + 10
        end
        d = math.sqrt((enemyPos.x - myPos.x) * (enemyPos.x - myPos.x) + (enemyPos.y - myPos.y) * (enemyPos.y - myPos.y))
        assert(d > 1)
    end

    targetPos.x = myPos.x + distance / d * (myPos.x - enemyPos.x)
    targetPos.y = myPos.y + distance / d * (myPos.y - enemyPos.y)

    -- 如果移动到目标位置后，依然无法躲避打击，则不移动
    local x = targetPos.x - enemyPos.x
    local y = targetPos.y - enemyPos.y
    local skill = hit.by:getTalentSkill() -- 只检查天赋技能
    local range = skill:getAttackDistance()
    if x * x + y * y < range * range then
        -- 无法逃避打击，不逃避
        return false
    end

    if targetPos.x < BATTLE_AREA.left then
        targetPos.x = enemyPos.x + distance
        targetPos.y = enemyPos.y + app.random(-global.pixel_per_unit * 2, global.pixel_per_unit * 2)
    end

    if targetPos.x > BATTLE_AREA.right then
        targetPos.x = enemyPos.x - distance
        targetPos.y = enemyPos.y + app.random(-global.pixel_per_unit * 2, global.pixel_per_unit * 2)
    end

    if targetPos.y < BATTLE_AREA.bottom then
        targetPos.y = enemyPos.y + distance
    end

    if targetPos.y > BATTLE_AREA.top then
        targetPos.y = enemyPos.y - distance
    end

    app.grid:moveActorTo(actor, targetPos)

    return true
end

return QAIEscape