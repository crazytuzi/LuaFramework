
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhaseEnrollingMorris = class("QTutorialPhaseEnrollingMorris", QTutorialPhase)

local QUIWidgetBattleTutorialDialogue = import("...ui.widgets.QUIWidgetBattleTutorialDialogue")
local QTimer = import("...utils.QTimer")
local QHitLog = import("...utils.QHitLog")
local QActor = import("...models.QActor")
local QBaseActorView = import("...views.QBaseActorView")
local QBaseEffectView = import("...views.QBaseEffectView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QTutorialStageEnrolling = import(".QTutorialStageEnrolling")

local entered = false
local checked = false
function QTutorialPhaseEnrollingMorris:start()
    self._hero = nil
        
    local dungeon = self._stage._battle._dungeonConfig
    if dungeon.monster_id ~= "wailing_caverns_22" then
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

    -- app.battle:performWithDelay(function()
    --     app.scene:pauseBattleAndDisplayDislog({"瑟芬斯特会召唤小怪，让我使用群体嘲讽帮你们拉怪！"}, {"ui/human_wrath.png"}, {"莫里斯"}, nil, nil)
    -- end, 1.5, nil, true)
    -- self:finished()
    -- do return end

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
                if hero:getTalentFunc() == "t" then
                    self._hero = hero
                    self._heroIndex = i

                    -- nzhang: unselect Morris, ugly code...
                    if ENABLE_AUTO_SELECT_HERO then
                        local views = app.scene:getHeroViews()
                        local view
                        for i = #views, 1, -1 do
                            view = views[i]
                            if view:getModel() ~= hero then
                                app.scene:uiSelectHero(view:getModel())
                                break
                            end
                        end
                    end
                end
            end
            if hero:getTalentFunc() == "health" then
                self._healer = hero
                self._healerIndex = i
            end
        end

        if self._hero then
            local view = app.scene:getActorViewFromModel(self._hero)
            view:setVisible(false)
            app.scene:hideHeroStatusView(self._heroIndex)
            app.grid:removeActor(self._hero)
            table.remove(heroes, self._heroIndex)
            app.battle._aiDirector:removeBehaviorTree(self._hero.behaviorNode)
            self._hero.behaviorNode = nil

            self._proxy = cc.EventProxy.new(self._stage._battle)
            self._proxy:addEventListener(self._stage._battle.END, handler(self, self._onBattleEnd))
        else
            self:finished()
        end
    end, 0)
end

function QTutorialPhaseEnrollingMorris:_hackAttack()
    self._hackedHeroes = {}
    local heroes = app.battle:getHeroes()
    local phase = self
    for _, hero in ipairs(heroes) do
        function hero:decreaseHp(hp)
            hp = math.ceil(self:getMaxHp() / 3)

            if (self:getHp() - hp) / self:getMaxHp() <= 0.2 then
                hp = math.ceil(self:getHp() - self:getMaxHp() * 0.1)
                -- 触发剧情
                if phase._healer then
                    phase:_unfoldPlot()
                else
                    phase:_unfoldPlot2()
                end
            end
            if hp > 0 then
                return QActor.decreaseHp(self, hp)
            else
                return self, hp, 0
            end
        end
        if hero:getTalentFunc() ~= "health" then
            hero.__hit = hero.hit
            function hero:hit(skill, attackee, split_number)
                local damage, tip, critical, hit_status = calcDamage(self, skill, attackee, split_number)
                if (attackee:getHp() - damage) / attackee:getMaxHp() > 0.1 or attackee == self then
                    hero.__hit(self, skill, attackee, split_number, {damage = damage, tip = tip, critical = critical, hit_status = hit_status})
                else
                    attackee:dispatchEvent({name = attackee.UNDER_ATTACK_EVENT, isTreat = false, tip = "闪避",
                        rawTip = {
                            isHero = attackee:getType() ~= ACTOR_TYPES.NPC, 
                            isDodge = true, 
                            isBlock = false, 
                            isCritical = false, 
                            isTreat = false, 
                            number = 0
                        }})
                end
            end
        end
        table.insert(self._hackedHeroes, hero)
    end

    function self._hero:onDragAttack(target)
        return
    end
    table.insert(self._hackedHeroes, self._hero)
end

function QTutorialPhaseEnrollingMorris:_dehackAttack()
    if self._hackedHeroes and #self._hackedHeroes > 0 then
        for _, hero in ipairs(self._hackedHeroes) do
            hero.decreaseHp = QActor.decreaseHp
            hero.hit = hero.__hit
            hero.onDragAttack = QActor.onDragAttack
        end
    end
end

function QTutorialPhaseEnrollingMorris:_unfoldPlot2()
    if not self._unfoldStarted then
        self._unfoldStarted = true
    else
        return
    end

    local view = app.scene:getActorViewFromModel(self._hero)
    app.scene:pauseBattleAndDisplayDislog({"小奥已经很努力在加血了，香肠再好，也挡不住这么多魂兽…", "这些魂兽攻击好高！小奥！快帮我加血！"}, {"icon/hero_card/art_aosika.png", "icon/hero_card/art_xiaowu.png"}, {QTutorialStageEnrolling.NAME_BLADEMASTER, QTutorialStageEnrolling.NAME_BLADEMASTER}, {QTutorialStageEnrolling.NAME_TITLE_BLADEMASTER, QTutorialStageEnrolling.NAME_TITLE_BLADEMASTER}, nil, function(is_skip)
        table.insert(app.battle:getHeroes(), self._hero)
        app.grid:addActor(self._hero)
        local oldpos = self._hero:getPosition()
        app.grid:moveActorTo(self._hero, {x = oldpos.x + 800, y = oldpos.y}, true)
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

        local proxy = cc.EventProxy.new(self._hero)
        proxy:addEventListener(self._hero.USE_MANUAL_SKILL_EVENT, function(event)
            proxy:removeAllEventListeners()
            app.battle:performWithDelay(function()
                self:_dehackAttack()
                self:finished()
            end, 1.8) 
        end)
                
        app.battle:performWithDelay(function()
            local skills = self._hero:getManualSkills()

            self._hero.behaviorNode = app.battle._aiDirector:createBehaviorTree(self._hero:getAIType(), self._hero)
            app.battle._aiDirector:addBehaviorTree(self._hero.behaviorNode)
            local end_callback = function()
                skill:_stopCd()
                app.scene:pauseBattleAndUseSkill(self._hero, skill)                
            end
            if is_skip ~= true then
                app.scene:pauseBattleAndDisplayDislog({"都退开！让本少爷来扛住这些魂兽的攻击！","只有防御系的魂师才最适合扛怪！"}, {"icon/hero_card/art_daimubai.png","icon/hero_card/art_daimubai.png"}, {QTutorialStageEnrolling.NAME_TAUREN,QTutorialStageEnrolling.NAME_TAUREN}, {QTutorialStageEnrolling.NAME_TITLE_TAUREN,QTutorialStageEnrolling.NAME_TITLE_TAUREN}, view:getModel(), end_callback)
            else
                end_callback()
            end
        end, 1.0)
    end)
end

function QTutorialPhaseEnrollingMorris:_unfoldPlot()
    if not self._unfoldStarted then
        self._unfoldStarted = true
        app.scene:pauseBattleAndDisplayDislog({"坚持住小舞！魂咒：老子有根大香肠！", "有点扛不住了么，小奥救我！"}, {"icon/hero_card/art_aosika.png", "icon/hero_card/art_xiaowu.png"}, {QTutorialStageEnrolling.NAME_BLOODELF, QTutorialStageEnrolling.NAME_BLADEMASTER}, {QTutorialStageEnrolling.NAME_TITLE_BLOODELF, QTutorialStageEnrolling.NAME_TITLE_BLADEMASTER}, nil, function(is_skip)
            local skills = self._healer:getManualSkills()
            local heal_skill = skills[next(skills)]
            self._stage._no_circleofhealing = true
            heal_skill:_stopCd()
            self._healer:attack(heal_skill)
            self._unfoldEnded = true
            self._skip_tutorial_1 = is_skip
        end)
    end
end

function QTutorialPhaseEnrollingMorris:_onBattleEnd()
    self._proxy:removeAllEventListeners()
    self:_dehackAttack()
end

function QTutorialPhaseEnrollingMorris:visit()
    if self._unfoldEnded and self._healer then
        local skill = self._healer:getCurrentSkill()
        if not skill or skill:getSkillType() ~= skill.MANUAL then
            self._unfoldEnded = nil
            local view = app.scene:getActorViewFromModel(self._hero)
            local end_callback_1 = function(is_skip)
                table.insert(app.battle:getHeroes(), self._hero)
                app.grid:addActor(self._hero)
                local oldpos = self._hero:getPosition()
                app.grid:moveActorTo(self._hero, {x = oldpos.x + 800, y = oldpos.y}, true)
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

                local proxy = cc.EventProxy.new(self._hero)
                proxy:addEventListener(self._hero.USE_MANUAL_SKILL_EVENT, function(event)
                    proxy:removeAllEventListeners()
                    app.battle:performWithDelay(function()
                        self:_dehackAttack()
                        -- checked = true
                        self._stage._no_circleofhealing = false
                        self:finished()
                    end, 1.8) 
                end)

                app.battle:performWithDelay(function()
                    local skills = self._hero:getManualSkills()

                    self._hero.behaviorNode = app.battle._aiDirector:createBehaviorTree(self._hero:getAIType(), self._hero)
                    app.battle._aiDirector:addBehaviorTree(self._hero.behaviorNode)
                    local end_callback = function()
                        skill:_stopCd()
                        app.scene:pauseBattleAndUseSkill(self._hero, skill)                
                    end
                    if is_skip ~= true then
                        app.scene:pauseBattleAndDisplayDislog({"小舞后退~白虎护身罩！扛怪还是需要专业的~"}, {"icon/hero_card/art_daimubai.png"}, {QTutorialStageEnrolling.NAME_TAUREN}, {QTutorialStageEnrolling.NAME_TITLE_TAUREN}, view:getModel(), end_callback)
                    else
                        end_callback()
                    end
                end, 1.0)
            end
            if self._skip_tutorial_1 ~= true then
                app.scene:pauseBattleAndDisplayDislog({"魂力枯竭了!小舞快跑！！！", "谁说近战就可以当防御魂师的！小奥，扛不住了，要死要死要死！！！"}, {"icon/hero_card/art_aosika.png", "icon/hero_card/art_xiaowu.png"}, {QTutorialStageEnrolling.NAME_BLOODELF, QTutorialStageEnrolling.NAME_BLADEMASTER}, {QTutorialStageEnrolling.NAME_TITLE_BLOODELF, QTutorialStageEnrolling.NAME_TITLE_BLADEMASTER}, nil, end_callback_1)
            else
                end_callback_1(true)
            end
        end
    end

    if type(app.battle:getCurrentWave()) ~= "number" or app.battle:getCurrentWave() ~= 1 or self._hacked or self._hero == nil then
        return
    end

    self:_hackAttack()
    self._hacked = true
end

return QTutorialPhaseEnrollingMorris
