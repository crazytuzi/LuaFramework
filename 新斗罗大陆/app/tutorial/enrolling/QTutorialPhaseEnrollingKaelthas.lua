
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhaseEnrollingKaelthas = class("QTutorialPhaseEnrollingKaelthas", QTutorialPhase)

local QUIWidgetBattleTutorialDialogue = import("...ui.widgets.QUIWidgetBattleTutorialDialogue")
local QTimer = import("...utils.QTimer")
local QActor = import("...models.QActor")
local QBaseActorView = import("...views.QBaseActorView")
local QBaseEffectView = import("...views.QBaseEffectView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBattleTutorialDialogue = import("...ui.widgets.QUIWidgetBattleTutorialDialogue")
local QUIWidgetTutorialHandTouch = import("...ui.widgets.QUIWidgetTutorialHandTouch")
local QTutorialStageEnrolling = import(".QTutorialStageEnrolling")

local entered = false
local checked = false
function QTutorialPhaseEnrollingKaelthas:start()
    self._hero = nil
        
    local dungeon = self._stage._battle._dungeonConfig
    if dungeon.monster_id ~= "wailing_caverns_3" then
        self:finished()
        return
    end

    if checked == true then
        self:finished()
        return
    end

    app.battle:getHeroes()
    local joinHeroes = remote.teamManager:getJoinHero(remote.teamManager.INSTANCE_TEAM)
    if (joinHeroes == nil or next(joinHeroes) == nil) then
        if entered == false then
            self:finished()
            return
        end
    end

    entered = true

    app.scene:setVisible(false)
    scheduler.performWithDelayGlobal(function()
        app.scene:setVisible(true)
        local heroes = app.battle:getHeroes()
        local joinHeroId = nil
        if joinHeroes ~= nil and next(joinHeroes) ~= nil then
            joinHeroId = joinHeroes[next(joinHeroes)]
        end
        for i, hero in ipairs(heroes) do
            if hero:getActorID() == joinHeroId then
                if hero:getTalentFunc() == "dps" and hero:isRanged() then
                    self._hero = hero
                    self._heroIndex = i
                    local view = app.scene:getActorViewFromModel(self._hero)
                    view:setVisible(false)
                    app.scene:hideHeroStatusView(i)
                    app.grid:removeActor(self._hero)
                    table.remove(heroes, i)
                    app.battle._aiDirector:removeBehaviorTree(self._hero.behaviorNode)
                    self._hero.behaviorNode = nil
                    self:_hackAttack()
                    function self._hero:attack() end -- 阻止释放技能

                    self._proxy = cc.EventProxy.new(self._stage._battle)
                    self._proxy:addEventListener(self._stage._battle.END, handler(self, self._onBattleEnd))
                    return
                end
            end
        end

        self:finished()
    end, 0)
end

function QTutorialPhaseEnrollingKaelthas:_hackAttack()
    self._hackedHeroes = {}
    local heroes = app.battle:getHeroes()
    for _, hero in ipairs(heroes) do
        function hero:decreaseHp(hp)
            if (self:getHp() - hp) / self:getMaxHp() <= 0.2 then
                hp = math.ceil(self:getHp() - self:getMaxHp() * 0.2)
            end
            if hp > 0 then
                return QActor.decreaseHp(self, hp)
            else
                return self, hp, 0
            end
        end
        table.insert(self._hackedHeroes, hero)
    end
end

function QTutorialPhaseEnrollingKaelthas:_hackAttack2()
    self._hackedHeroes = {}
    local heroes = app.battle:getHeroes()
    for _, hero in ipairs(heroes) do
        hero.__hit = hero.hit
        function hero:hit(skill, attackee, split_number)
            local damage, tip, critical, hit_status = calcDamage(self, skill, attackee, split_number)
            if (attackee:getHp() - damage) / attackee:getMaxHp() > 0.05 or attackee == self then
                hero.__hit(self, skill, attackee, split_number, {damage = damage, tip = tip, critical = critical, hit_status = hit_status})
            end
        end
        table.insert(self._hackedHeroes, hero)
    end
end

function QTutorialPhaseEnrollingKaelthas:_dehackAttack()
    if self._hackedHeroes and #self._hackedHeroes > 0 then
        for _, hero in ipairs(self._hackedHeroes) do
            hero.decreaseHp = QActor.decreaseHp
            hero.hit = hero.__hit
        end
    end
end

function QTutorialPhaseEnrollingKaelthas:_unfoldPlot()
    if not self._unfold then
        self._unfold = true
    else
        return
    end

    self:_hackAttack2()
    app.scene:pauseBattleAndDisplayDislog({"怪的血好多，我的心好慌！",}, {"ui/Blade_master.png",}, {QTutorialStageEnrolling.NAME_BLADEMASTER,}, {QTutorialStageEnrolling.NAME_TITLE_BLADEMASTER}, nil, function()
        local view = app.scene:getActorViewFromModel(self._hero)
        table.insert(app.battle:getHeroes(), self._hero)
        app.grid:addActor(self._hero)
        local oldpos = self._hero:getPosition()
        app.grid:moveActorTo(self._hero, {x = oldpos.x + 450, y = oldpos.y + 200}, true)
        app.scene:showHeroStatusView(self._heroIndex)

        local frontEffect, backEffect = QBaseEffectView.createEffectByID(global.hero_add_effect)
        local dummy = QStaticDatabase.sharedDatabase():getEffectDummyByID(global.hero_add_effect)
        local positionX, positionY = view:getPosition()
        frontEffect:setPosition(positionX, positionY - 1)
        app.scene:addEffectViews(frontEffect)
        
        frontEffect:setVisible(true)
        view:setVisible(true)
        -- play animation and sound
        frontEffect:playAnimation(frontEffect:getPlayAnimationName(), false)
        frontEffect:playSoundEffect(false)

        frontEffect:afterAnimationComplete(function()
            app.scene:removeEffectViews(frontEffect)
        end)
        view:runAction(CCFadeIn:create(0.8))
        self._hero:setDirection(QActor.DIRECTION_RIGHT)

        local skills = self._hero:getManualSkills()
        local skill = skills[next(skills)]
        skill:coolDown()
        skill:reduceCoolDownTime(skill._cd_time - 1.1)
        self._hero:setRage(self._hero:getRageTotal())

        app.battle:performWithDelay(function()
            self:_dehackAttack()
            function self._hero:attack() end -- 阻止释放技能

            self._hero.behaviorNode = app.battle._aiDirector:createBehaviorTree(self._hero:getAIType(), self._hero)
            app.battle._aiDirector:addBehaviorTree(self._hero.behaviorNode)
            self._hero:setTarget(self._enemy)

            app.scene:pauseBattleAndDisplayDislog({"别慌，我来助你，看我的烈焰打击！"}, {"ui/kaelthas.png"}, {QTutorialStageEnrolling.NAME_KAELTHAS}, {QTutorialStageEnrolling.NAME_TITLE_KAELTHAS}, view:getModel(), function()
                self._hero.attack = QActor.attack

                skill:_stopCd()
                app.scene:pauseBattleAndUseSkill(self._hero, skills[next(skills)], nil, function()
                    app.battle:performWithDelay(function()
                        app.scene:pauseBattleAndDisplayDislog({"这难道就是所谓的主角光环吗…哈哈哈…"}, {"ui/Blade_master.png"}, {QTutorialStageEnrolling.NAME_BLADEMASTER}, {QTutorialStageEnrolling.NAME_TITLE_BLADEMASTER}, view:getModel(), function()
                            checked = true
                            self:finished()
                        end)
                    end, 2.0)
                end)
            end)
        end, 1.0)
    end)
end

function QTutorialPhaseEnrollingKaelthas:_onBattleEnd()
    self._proxy:removeAllEventListeners()
    self:_dehackAttack()
end

function QTutorialPhaseEnrollingKaelthas:visit()
    if self._enemy ~= nil then
        return
    end

    local enemies = app.battle:getEnemies()
    for _, enemy in ipairs(enemies) do
        if not enemy:isDead() and enemy:getActorID() == 40485 then
            -- if self._enemy_skip == nil then
            --     self._enemy_skip = enemy
            -- elseif self._enemy_skip_2 == nil then
            --     self._enemy_skip_2 = enemy
            -- elseif self._enemy == nil and enemy ~= self._enemy_skip and enmey ~= self._enemy_skip_2 then
                self._enemy = enemy
                app.battle:performWithDelay(handler(self, self._unfoldPlot), 5)
            -- end
        end
    end
end

return QTutorialPhaseEnrollingKaelthas
