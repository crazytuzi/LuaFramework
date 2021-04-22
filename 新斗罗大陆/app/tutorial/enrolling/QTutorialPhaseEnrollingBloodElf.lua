
local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhaseEnrollingBloodElf = class("QTutorialPhaseEnrollingBloodElf", QTutorialPhase)

local QUIWidgetBattleTutorialDialogue = import("...ui.widgets.QUIWidgetBattleTutorialDialogue")
local QTimer = import("...utils.QTimer")
local QActor = import("...models.QActor")
local QSkill = import("...models.QSkill")
local QBaseActorView = import("...views.QBaseActorView")
local QBaseEffectView = import("...views.QBaseEffectView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QTutorialStageEnrolling = import(".QTutorialStageEnrolling")

local entered = false
local checked = false
function QTutorialPhaseEnrollingBloodElf:start()
    self._hero = nil
    self._stage._battle._heroes = {}
    self._stage._battle._dungeonConfig.heroModels = nil
        
    local dungeon = self._stage._battle._dungeonConfig
    if dungeon.monster_id ~= "wailing_caverns_9" then
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
                if hero:getTalentFunc() == "health" then
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

                    self._proxy = cc.EventProxy.new(self._stage._battle)
                    self._proxy:addEventListener(self._stage._battle.END, handler(self, self._onBattleEnd))

                    -- nzhang: unselect Lylia, ugly code...
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

                    -- 关闭莉莉娅的低血量引导，否则会与本引导冲突
                    self._stage:disableCircleOfHealingTutorial()

                    -- 合体技能off
                    for _, bm in ipairs(heroes) do
                        if bm:getSuperSkillID() and bm:getDeputyActorIDs()[hero:getActorID()] then
                            local views = app.scene:getHeroStatusViews()
                            for _, statusView in ipairs(views) do
                                if statusView:getHero() == bm then
                                    self._bmStatusView = statusView
                                    statusView:setHetiVisible(false)
                                end
                            end
                            self._bmSuperSkillID = bm:getSuperSkillID()
                            bm:setSuperSkillID(nil)
                            self._bmDeputyActorIDs = bm:getDeputyActorIDs()
                            bm:setDeputyActorIDs(nil)
                            self._bmAdditionalManualSkillDamagePercent = bm:getAdditionalManualSkillDamagePercent()
                            bm:setAdditionalManualSkillDamagePercent(0)
                            self._bmManualSkill = bm:getFirstManualSkill()
                            local skill_id = QStaticDatabase:sharedDatabase():getSkillSlotConfigByActor(bm:getActorID()).slot_3
                            bm:setFirstManualSkill(QSkill.new(skill_id, QStaticDatabase:sharedDatabase():getSkillByID(skill_id), bm, self._bmManualSkill:getSkillLevel()))
                            self._bm = bm
                            break
                        end
                    end

                    return
                end
            end
        end

        self:finished()
    end, 0)
end

function QTutorialPhaseEnrollingBloodElf:_hackAttack()
    if self._hero and #app.battle:getHeroes() > 0 then
        for _, hero in ipairs(app.battle:getHeroes()) do
            if hero ~= self._hero then
                local phase = self
                function hero:decreaseHp(hp)
                    if type(app.battle:getCurrentWave()) ~= "number" or app.battle:getCurrentWave() ~= 3 then
                        return QActor.decreaseHp(self, hp)
                    end

                    hp = math.ceil(self:getMaxHp() / 5)

                    if (self:getHp() - hp) / self:getMaxHp() <= 0.5 then
                        hp = math.ceil(self:getHp() - self:getMaxHp() / 2)
                        -- 触发剧情
                        phase:_unfoldPlot()
                    end
                    -- scheduler.performWithDelayGlobal(function()
                    --   phase:_unfoldPlot()
                    -- end, 5)
                    if hp > 0 then
                        return QActor.decreaseHp(self, hp)
                    else
                        return self, hp, 0
                    end
                end
                hero.__hit = hero.hit
                function hero:hit(skill, attackee, split_number)
                    if type(app.battle:getCurrentWave()) ~= "number" or app.battle:getCurrentWave() ~= 3 then
                        return hero.__hit(self, skill, attackee, split_number)
                    end

                    local damage, tip, critical, hit_status = calcDamage(self, skill, attackee, split_number)
                    if (attackee:getHp() - damage) / attackee:getMaxHp() > 0.5 or attackee == self then
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
        end
    end
end

function QTutorialPhaseEnrollingBloodElf:_dehackAttack()
    if self._hero and #app.battle:getHeroes() > 0 then
        for _, hero in ipairs(app.battle:getHeroes()) do
            if hero ~= self._hero then
                hero.decreaseHp = QActor.decreaseHp
                hero.hit = hero.__hit
            end
        end
    end
end

function QTutorialPhaseEnrollingBloodElf:_unfoldPlot()
    if not self._unfold then
        self._unfold = true
    else
        return
    end

    app.battle:performWithDelay(function()
        local view = app.scene:getActorViewFromModel(self._hero)
        app.scene:pauseBattleAndDisplayDislog({"糟糕，这些魂师的攻击太强了，小舞快要顶不住了！"}, {"icon/hero_card/art_xiaowu.png"}, {QTutorialStageEnrolling.NAME_BLADEMASTER}, {QTutorialStageEnrolling.NAME_TITLE_BLADEMASTER}, nil, function(is_skip)
            table.insert(app.battle:getHeroes(), self._hero)
            app.grid:addActor(self._hero)
            local oldpos = self._hero:getPosition()
            view:setEnableTouchEvent(true)
            app.grid:moveActorTo(self._hero, {x = oldpos.x + 325, y = oldpos.y}, true)
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
            function self._hero:attack( ... )
            end

            -- 合体技能on
            if self._bm then
                local bm = self._bm
                self._bmStatusView:setHetiVisible(true)
                bm:setSuperSkillID(self._bmSuperSkillID)
                bm:setDeputyActorIDs(self._bmDeputyActorIDs)
                bm:setAdditionalManualSkillDamagePercent(self._bmAdditionalManualSkillDamagePercent)
                bm:setFirstManualSkill(self._bmManualSkill)
            end

            app.battle:performWithDelay(function()
                -- 低概率遇到战斗的最后一帧，需要防止crash
                if app.battle._aiDirector == nil then
                    self:finished()
                    return
                end

                self:_dehackAttack()

                self._hero.behaviorNode = app.battle._aiDirector:createBehaviorTree(self._hero:getAIType(), self._hero)
                app.battle._aiDirector:addBehaviorTree(self._hero.behaviorNode)

                local sentences = {}
                local imageFiles = {}
                local names = {}
                local titleNames = {}
                -- table.insert(sentences, "人帅就是没办法！请叫我无敌剑圣~哈哈")
                table.insert(sentences,1, "我的香肠包你满意！")
                table.insert(sentences,1, "老子有根大香肠！")
                -- table.insert(imageFiles, "ui/Blade_master.png")
                table.insert(imageFiles, "icon/hero_card/art_aosika.png")
                table.insert(imageFiles, "icon/hero_card/art_aosika.png")
                -- table.insert(names, "剑圣")
                table.insert(names, QTutorialStageEnrolling.NAME_BLOODELF)
                table.insert(names, QTutorialStageEnrolling.NAME_BLOODELF)
                table.insert(titleNames, QTutorialStageEnrolling.NAME_TITLE_BLOODELF)
                table.insert(titleNames, QTutorialStageEnrolling.NAME_TITLE_BLOODELF)

                local end_call_back = function()
                    local skill = skills[next(skills)]
                    skill:_stopCd()
                    self._hero.attack = QActor.attack
                    app.scene:pauseBattleAndUseSkill(self._hero, skill)                
                    local proxy = cc.EventProxy.new(self._hero)
                    proxy:addEventListener(self._hero.USE_MANUAL_SKILL_EVENT, function(event)
                        -- if event.skill ~= skill then return end
                        proxy:removeAllEventListeners()
                        app.battle:performWithDelay(function()
                            self:finished()
                        end, 1.8) 
                    end)
                end
                if is_skip ~= true then
                    app.scene:pauseBattleAndDisplayDislog(sentences, imageFiles, names, titleNames, view:getModel(), end_call_back)
                else
                    end_call_back()
                end
            end, 1.0)
        end)
    end, 2)
end

function QTutorialPhaseEnrollingBloodElf:_onBattleEnd()
    self._proxy:removeAllEventListeners()
    self:_dehackAttack()
end

function QTutorialPhaseEnrollingBloodElf:visit()

end

return QTutorialPhaseEnrollingBloodElf
