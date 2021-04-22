--[[
    @number duration 倒计时多少秒后结束
    @number first_trigger_time 第一次触发时间
    @number interval 第一次触发后，每几秒触发一次
    @string damage_percent 攻击力百分比的伤害("2;3":PVP200%伤害，PVE300%伤害)
    @number convert_treat_percent 转化成治疗量的百分比(0.1:10%伤害转化成治疗)
    @number change_rage_value 怒气变化数值(-20:减少20)
    @number rage_increase_coefficient_final_value 怒气增加系数系数的最终值(-0.5:怒气增长速度减少50%)
    @string max_rage_enemy_buff_id buff结束时触发技能脚本，脚本里调用QSBChangeRageCofficient恢复怒气系数
    @number effect1_first_time 特效1第一次播放时间
    @number effect2_first_time 特效2第一次播放时间
    @number effect3_first_time 特效3第一次播放时间
    @string left_effect1_id 左边特效1的id
    @string left_effect2_id 左边特效2的id
    @string left_effect3_id 左边特效3的id
    @string right_effect1_id 右边特效1的id
    @string right_effect2_id 右边特效2的id
    @string right_effect3_id 右边特效3的id
    @table left_effect1_pos 左边特效1的pos {x = 1, y = 1}
    @table left_effect2_pos 左边特效2的pos {x = 1, y = 1}
    @table left_effect3_pos 左边特效3的pos {x = 1, y = 1}
    @table right_effect1_pos 右边特效1的pos {x = 1, y = 1}
    @table right_effect2_pos 右边特效2的pos {x = 1, y = 1}
    @table right_effect3_pos 右边特效3的pos {x = 1, y = 1}

    @usage {
    @usage   CLASS = "action.QSBTianShiShengJian",
    @usage   OPTIONS = {effect1_first_time = 4, effect2_first_time = 4.3, effect3_first_time = 4.6,
             left_effect1_id = "leftId1", left_effect2_id = "leftId2", left_effect3_id = "leftId3",
             right_effect1_id = "rightId1", right_effect2_id = "rightId2", right_effect3_id = "rightId3",
             duration = 180, first_trigger_time = 5, interval = 10, max_rage_enemy_buff_id = "buffid1", damage_percent = “2;3”, 
    @usage   convert_treat_percent = 0.1, change_rage_value = -20, rage_increase_coefficient_final_value = 0.5,},
    @usage },
--]]
local QSBAction = import(".QSBAction")
local QActor = import("...models.QActor")
local QSBTianShiShengJian  = class("lastTriggerTimeQSBTianShiShengJian", QSBAction)

function QSBTianShiShengJian:_execute(dt)
    if self:checkRunningSkill() == false then --为了魂师死亡后也执行此_execute,每个tick所有魂师都会执行此_execute，但是只能执行一个doAction
        return
    end
    local timeLeft = app.battle:getTimeLeft()
    local actorType = self._attacker:getType()
    if self._options.duration < app.battle:getDungeonDuration() - timeLeft then
        self:finished()
    else
        local lastTriggerTime = app.battle:getFromMap(actorType, "TIANSHISHENGJIAN_LAST_TRIGGER_TIME")--区分两遍都上了此神器的情况
        if not lastTriggerTime and self._options.first_trigger_time <= app.battle:getDungeonDuration() - timeLeft then
            --第一次触发
            self:doAction()
        elseif lastTriggerTime and self._options.interval <= lastTriggerTime - timeLeft then
            --第一次触发后间隔interval秒触发
            self:doAction()            
        end
        --播放特效      
        if actorType == ACTOR_TYPES.HERO or actorType == ACTOR_TYPES.HERO_NPC then
            self:playEffect("LEFT_EFFECT1_LAST_TIME", self._options.effect1_first_time, self._options.left_effect1_id, self._options.left_effect1_pos, true)
            self:playEffect("LEFT_EFFECT2_LAST_TIME", self._options.effect2_first_time, self._options.left_effect2_id, self._options.left_effect2_pos)
            self:playEffect("LEFT_EFFECT3_LAST_TIME", self._options.effect3_first_time, self._options.left_effect3_id, self._options.left_effect3_pos)
        else
            self:playEffect("RIGHT_EFFECT1_LAST_TIME", self._options.effect1_first_time, self._options.right_effect1_id, self._options.right_effect1_pos, true)
            self:playEffect("RIGHT_EFFECT2_LAST_TIME", self._options.effect2_first_time, self._options.right_effect2_id, self._options.right_effect2_pos)
            self:playEffect("RIGHT_EFFECT3_LAST_TIME", self._options.effect3_first_time, self._options.right_effect3_id, self._options.right_effect3_pos)
        end
    end
end

function QSBTianShiShengJian:checkRunningSkill()
    local sbDirector = app.battle:getFromMap("CURRENT_TIANSHISHENGJIAN_SBDIRECTOR")
    if sbDirector == nil or sbDirector:isSkillFinished() or sbDirector == self._director then
        app.battle:setFromMap(self._attacker:getType(),"CURRENT_TIANSHISHENGJIAN_SBDIRECTOR", self._director)
        return true
    else
        return false
    end
end

function QSBTianShiShengJian:doAction(dt)
    local enemies = app.battle:getMyEnemies(self._attacker, true)
    if next(enemies) == nil then    --可能敌人死光了，或者在进入下一波时出现enemies为空table的情况
        return
    end
    --伤害section
    local teammates = app.battle:getMyTeammates(self._attacker, true, true)
    table.sort(teammates, function(a, b)
        return a:getAttack(false) > b:getAttack(false)
    end)
    local maxAttackTeammate = teammates[1]
    local tab_damage_percent = string.split(self._options.damage_percent,";")
    local num_damage_percent = app.battle:isPVPMode() and tonumber(tab_damage_percent[1]) or tonumber(tab_damage_percent[2])
    self._skill:setDamagePercentFromScript(num_damage_percent)
    local totalDamage = 0
    for k,actor in ipairs(enemies) do
        local original_damage, damage = maxAttackTeammate:hit(self._skill, actor, nil)
        if not damage then
            damage = 0
        end
        totalDamage = totalDamage + damage
    end

    --治疗section
    local treatValue = totalDamage * self._options.convert_treat_percent
    table.sort(teammates, function(a, b)
        return a:getHp()/a:getMaxHp() < b:getHp()/b:getMaxHp()
    end)

    local tabTreatValue = {}    --每个actor治疗的血量
    for i = 1, #teammates, 1 do
        tabTreatValue[i] = 0
    end

    local function weightTreat(teammates, treatNum, treatValue, tabTreatValue) --在teammates中把treatNum个actor的血量抬到同一个百分比
        local addedMaxHp = 0
        for i = 1, treatNum do
            addedMaxHp = addedMaxHp + teammates[i]:getMaxHp()
        end
        for i = 1, treatNum do  --按血量权重分配treatValue
            tabTreatValue[i] = tabTreatValue[i] + (teammates[i]:getMaxHp() / addedMaxHp) * treatValue
        end
    end

    for i = 1, #teammates - 1, 1 do     --每次循环将血量最少的的一档(可能多个actor)和较高一档血量百分比填平
        local actorHpLow, actorHpHigh = teammates[i], teammates[i + 1]
        local treatHpPercent = actorHpHigh:getHp()/actorHpHigh:getMaxHp() - actorHpLow:getHp()/actorHpLow:getMaxHp()
        local treatHpValue = 0  --本次循环的治疗量
        for j =1, i, 1 do
            treatHpValue = treatHpValue + treatHpPercent * teammates[j]:getMaxHp()  --teammates[j]:本次循环受治疗的actor
        end
        if treatHpValue <= treatValue then --治疗量够
            for j =1, i, 1 do
                tabTreatValue[j] = tabTreatValue[j] + treatHpPercent * teammates[j]:getMaxHp()  --teammates[j]:本次循环受治疗的actor
            end
            treatValue = treatValue - treatHpValue
        else --治疗量不够
            weightTreat(teammates, i, treatValue, tabTreatValue)    --权重治疗
            treatValue = 0
            break
        end
    end
    if 0 < treatValue then --所有队友满血了，剩余治疗量权重治疗
        weightTreat(teammates, #teammates, treatValue, tabTreatValue)
    end
    for index, actor in ipairs(teammates) do
        local _, dHp = actor:increaseHp(tabTreatValue[index], self._attacker, self._skill)
        if dHp > 0 then
            actor:dispatchEvent({name = QActor.UNDER_ATTACK_EVENT, isTreat = true, isCritical = false, tip = "", rawTip = {
                isHero = actor:getType() == ACTOR_TYPES.HERO, 
                isCritical = false, 
                isTreat = true,
                number = dHp,
            }})
        end
    end

    --降低怒气section
    if self._options.change_rage_value then
        for k,actor in ipairs(enemies) do
            actor:changeRage(self._options.change_rage_value, nil, true)
        end
    end

    --降低怒气最高的actor怒气获取section
    local maxRageEnemy = nil
    if self._options.rage_increase_coefficient_final_value then
        table.sort(enemies, function(a, b)        
            return a:getRage() > b:getRage()
        end)
        maxRageEnemy = enemies[1]
        if maxRageEnemy:getPropertyValue("rage_increase_coefficient", "TIANSHISHENGJIAN_LAST_MAX_RAGE_ENEMY_ID") == nil then
            maxRageEnemy:insertPropertyValue("rage_increase_coefficient", "TIANSHISHENGJIAN_LAST_MAX_RAGE_ENEMY_ID", "+", self._options.rage_increase_coefficient_final_value)
        else
            maxRageEnemy:modifyPropertyValue("rage_increase_coefficient", "TIANSHISHENGJIAN_LAST_MAX_RAGE_ENEMY_ID", "+", self._options.rage_increase_coefficient_final_value)
        end
        app.battle:setFromMap("TIANSHISHENGJIAN_LAST_MAX_RAGE_ENEMY_ID", maxRageEnemy)--在QSBChangeRageCofficient中getMap,恢复rage_increase_coefficient的值
    end  

    --恢复怒气最高的actor怒气获取section:上一个配置的buff,buff结束时触发技能脚本，脚本里调用QSBChangeRageCofficient恢复
    if maxRageEnemy then
        maxRageEnemy:applyBuff(self._options.max_rage_enemy_buff_id, self._attacker, self._skill)
    end
    app.battle:setFromMap(self._attacker:getType(), "TIANSHISHENGJIAN_LAST_TRIGGER_TIME", app.battle:getTimeLeft())--区分两遍都上了此神器的情况
end

function QSBTianShiShengJian:playEffect(effectStoreName, firstPlayTime, effectId, pos, playGodArmAnimation)
    if not effectStoreName or not firstPlayTime or not effectId then
        return
    end
    local options = {}
    options.attacker = self._attacker
    options.attackee = nil
    options.targetPosition = clone(pos)
    options.scale_actor_face = nil
    options.ground_layer = nil
    options.front_layer = nil

    local timeLeft = app.battle:getTimeLeft()
    local lastTriggerTime = app.battle:getFromMap(effectStoreName) 
    if not lastTriggerTime and firstPlayTime <= app.battle:getDungeonDuration() - timeLeft then
        --第一次触发
        self._attacker:playSkillEffect(effectId, nil, options)
        app.battle:setFromMap(effectStoreName, app.battle:getTimeLeft())
        if playGodArmAnimation and not IsServerSide then
            app.scene:playGodArmAnimation(self._attacker, self._skill, true)
        end
    elseif lastTriggerTime and self._options.interval <= lastTriggerTime - timeLeft then
        --第一次触发后间隔interval秒触发
        self._attacker:playSkillEffect(effectId, nil, options)
        app.battle:setFromMap(effectStoreName, app.battle:getTimeLeft())
        if playGodArmAnimation and not IsServerSide then
            app.scene:playGodArmAnimation(self._attacker, self._skill, true)
        end   
    end

end

return QSBTianShiShengJian