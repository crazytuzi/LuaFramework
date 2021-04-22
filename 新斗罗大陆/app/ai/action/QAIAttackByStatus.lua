
local QAIAction = import("..base.QAIAction")
local QAIAttackByStatus = class("QAIAttackByStatus", QAIAction)

--[==[
    这个脚本会通过判断对方是否有指定状态来选择目标
    参数:status 状态名 必填 不填会报错
    参数:is_team 是否从队友中找 默认为false
--]==]

function QAIAttackByStatus:ctor( options )
    QAIAttackByStatus.super.ctor(self, options)
    self:setDesc("如果对方拥有指定的状态后就强行攻击对方")
    self._is_find_actor = false
end

function QAIAttackByStatus:_execute(args)
    local actor = args.actor
    local is_team = self._options.is_team
    local status = self._options.status
    local targets
    if nil == status then
        assert(status,"invalid args, status is nil")
        self._is_find_actor = false
        return false
    end

    if nil == actor then
        assert(false, "invalid args, actor is nil.")
        self._is_find_actor = false
        return false
    end

    local target = actor:getTarget()

    if target and self._is_find_actor and target:isDead() == false and target:isUnderStatus(status) then
        return true --如果找到目标且目标没有死亡且目标扔处于激活状态下那就继续攻击 防止多次遍历
    end

    if is_team then
        targets = app.battle:getMyTeammates(actor,true)
    else
        targets = app.battle:getMyEnemies(actor)
    end

    if nil == targets then
        self._is_find_actor = false
        return false
    end

    for _,v in pairs(targets) do
        if v:isDead() == false and v:isUnderStatus(status) and v:isInBattleArea() then
            actor:setTarget(v)
            self._is_find_actor = true
            return true
        end
    end

    self._is_find_actor = false
    return false
end

return QAIAttackByStatus