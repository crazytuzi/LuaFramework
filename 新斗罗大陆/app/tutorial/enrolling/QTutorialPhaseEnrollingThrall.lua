local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhaseEnrollingThrall = class("QTutorialPhaseEnrollingThrall", QTutorialPhase)

local QUIWidgetBattleTutorialDialogue = import("...ui.widgets.QUIWidgetBattleTutorialDialogue")
local QTimer = import("...utils.QTimer")
local QActor = import("...models.QActor")
local QBaseActorView = import("...views.QBaseActorView")
local QBaseEffectView = import("...views.QBaseEffectView")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QTutorialPhaseEnrollingThrall:start()
	local dungeon = app.battle._dungeonConfig
	if dungeon.monster_id == "wailing_caverns_12" then
    	self._eventProxy = cc.EventProxy.new(app.battle)
    	self._eventProxy:addEventListener(app.battle.WAVE_STARTED, function(event)
    		if event.wave == 2 then
				self:_hackAttack()
    			self._eventProxy:removeAllEventListeners()

                self._proxy = cc.EventProxy.new(self._stage._battle)
                self._proxy:addEventListener(self._stage._battle.END, handler(self, self._onBattleEnd))
			end
    	end)
	else
		self:finished()
	end
end

function QTutorialPhaseEnrollingThrall:_hackAttack()
    self._hackedHeroes = {}
	local heroes = app.battle:getHeroes()
	for _, hero in ipairs(heroes) do
		if hero:getTalentFunc() ~= "health" then
	        local phase = self
	        function hero:decreaseHp(hp)
	            -- hp = math.ceil(self:getMaxHp() / 10)

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
end

function QTutorialPhaseEnrollingThrall:_hackAttack2()
    self._hackedHeroes = {}
	local heroes = app.battle:getHeroes()
	for _, hero in ipairs(heroes) do
		if hero:getTalentFunc() ~= "health" then
	        local phase = self
        	hero.__hit = hero.hit
	        function hero:hit(skill, attackee, split_number)
	        	if app.battle:getCurrentWave() ~= 2 then
	                hero.__hit(self, skill, attackee, split_number)
	        	else
		            local damage, tip, critical, hit_status = calcDamage(self, skill, attackee, split_number)
		            if (attackee:getHp() - damage) / attackee:getMaxHp() > 0.05 or attackee == self then
                		hero.__hit(self, skill, attackee, split_number, {damage = damage, tip = tip, critical = critical, hit_status = hit_status})
		            end
	        	end
	        end
        	table.insert(self._hackedHeroes, hero)
    	end
    end
end

function QTutorialPhaseEnrollingThrall:_dehackAttack()
    if self._hackedHeroes and #self._hackedHeroes > 0 then
        for _, hero in ipairs(self._hackedHeroes) do
            hero.decreaseHp = QActor.decreaseHp
		    hero.hit = hero.__hit
        end
    end
end

function QTutorialPhaseEnrollingThrall:visit()
	if type(app.battle:getCurrentWave()) ~= "number" or app.battle:getCurrentWave() ~= 2 then
		return
	end

	local enemies = app.battle:getEnemies()
	for _, enemy in ipairs(enemies) do
		if not enemy:isDead() and app.battle:isBoss(enemy) then
			if (enemy:getHp() / enemy:getMaxHp() < 0.45) then
				self:_unfoldPlot()
			end
		end
	end
end

function QTutorialPhaseEnrollingThrall:_unfoldPlot()
    if not self._unfold then
        self._unfold = true
    else
        return
    end

    self:_hackAttack2()
    app.battle:performWithDelay(function()
	    app.scene:pauseBattleAndDisplayDislog({"我已经用双手双脚滚键盘了！", "快要扛不住了！速度dps掉！\\nrush！rush！",}, {"ui/kaelthas.png", "ui/Blade_master.png",}, {"逐日者", "剑圣"},{"逐日者", "剑圣"},nil, function()
	    	-- 萨尔进场
	    	local heroes = app.battle:getHeroes()
	    	ghost_actor = app.battle:summonGhosts(41583, heroes[1], 600, {x = 250, y = 300})
	    	self._ghost_actor = ghost_actor
	    	for _, ghost in ipairs(app.battle._heroGhosts) do
	    		if ghost.actor == ghost_actor then
	    			app.battle._aiDirector:removeBehaviorTree(ghost.ai)
	    		end
	    	end

	    	local view = app.scene:getActorViewFromModel(ghost_actor)
	        local frontEffect, backEffect = QBaseEffectView.createEffectByID(global.hero_add_effect)
	        local dummy = QStaticDatabase.sharedDatabase():getEffectDummyByID(global.hero_add_effect)
	        local positionX, positionY = view:getPosition()
	        frontEffect:setPosition(positionX, positionY - 1)
	        app.scene:addEffectViews(frontEffect)
	        frontEffect:setVisible(true)
	        view:setVisible(true)
	        frontEffect:playAnimation(frontEffect:getPlayAnimationName(), false)
	        frontEffect:playSoundEffect(false)
	        frontEffect:afterAnimationComplete(function()
	            app.scene:removeEffectViews(frontEffect)
	        end)
	        view:runAction(CCFadeIn:create(0.8))
	        ghost_actor:setDirection(QActor.DIRECTION_RIGHT)

	        app.battle:performWithDelay(function()
	            app.scene:pauseBattleAndDisplayDislog({"让我来引领你们走向胜利！"}, {"ui/Thrall.png"}, {"萨尔"}, {"萨尔"},nil, function()
	            	if app.battle._aiDirector == nil then
	            		self:finished()
	            		return
	            	end
			    	for _, ghost in ipairs(app.battle._heroGhosts) do
			    		if ghost.actor == ghost_actor then
			    			app.battle._aiDirector:addBehaviorTree(ghost.ai)
			    		end
			    	end
	                ghost_actor.attack(ghost_actor:getSkillWithId(201501))
	                app.battle:performWithDelay(function()
	            		self:_dehackAttack()
	                	app.scene:getActorViewFromModel(ghost_actor):setVisible(false)
						app.scene:getActorViewFromModel(ghost_actor):getSkeletonActor():setVisible(false)
	                	ghost_actor:suicide()
                		app.battle:dispatchEvent({name = app.battle.NPC_CLEANUP, npc = ghost_actor, is_hero = true})
                		self._ghost_actor = nil
	                end, 1.5)
	                self:finished()
	            end)
	        end, 1.5)
	    end)
    end, 1.5)
end

function QTutorialPhaseEnrollingThrall:_onBattleEnd()
    self._proxy:removeAllEventListeners()
    self:_dehackAttack()
    local ghost_actor = self._ghost_actor
    if ghost_actor then
		app.scene:getActorViewFromModel(ghost_actor):setVisible(false)
		app.scene:getActorViewFromModel(ghost_actor):getSkeletonActor():setVisible(false)
		ghost_actor:suicide()
		app.battle:dispatchEvent({name = app.battle.NPC_CLEANUP, npc = ghost_actor, is_hero = true})
	end
end

return QTutorialPhaseEnrollingThrall
