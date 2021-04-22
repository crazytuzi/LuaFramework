local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhaseDungeon14 = class("QTutorialPhaseDungeon14", QTutorialPhase)
local QActor = import("...models.QActor")
local QSkill = import("...models.QSkill")

function QTutorialPhaseDungeon14:start()
	if remote.instance:checkIsPassByDungeonId(app.battle._dungeonConfig.id) then
		self:finished()
        return
    end
	self._trigger_tutorial = false
	self._total_delay = 0
	self._actors = {}
	local phase = self
	for k,enemy in ipairs(app.battle:getEnemies()) do
		self._actors[enemy:getActorID()] = enemy
		if enemy:getActorID() == 3086 then
			self._boss = enemy
		end
	end

	for i,hero in pairs(app.battle:getHeroes()) do
		self._actors[hero:getActorID()] = hero
	end

	if self._actors[3086] == nil or self._actors[1001] == nil or self._actors[1002] == nil then
		self:finished()
		return
	end

	self._boss.decreaseHp = function (self, hp)
		if (self:getHp() - hp) / self:getMaxHp() <= 0.1 then
			phase._trigger_tutorial = true
	        hp = math.ceil(self:getHp() - self:getMaxHp() * 0.1)
	    end
	    if hp > 0 then
	        return QActor.decreaseHp(self, hp)
	    else
	        return self, hp, 0
	    end
	end
end

local function resetDecreaseHp(actor)
	actor.decreaseHp = function(actor, hp)
		return self, hp, 0
	end
end

local function disableAllSkill(hero)
	for id,skill in pairs(hero._skills) do
		skill.isReady = function(skill) return false end
	end
end

function QTutorialPhaseDungeon14:visit()
	if self._trigger_tutorial ~= true or self._visited == true then return end
	self._visited = true
	--取消所有动作 清空目标 禁用AI 禁止普攻
	for i,hero in pairs(app.battle:getHeroes()) do
		hero:cancelAllSkills()
		hero:removeAllBuff()
		hero:forbidNormalAttack()
		hero:stopDoing()
		hero:setTarget(nil)
		resetDecreaseHp(hero)
		disableAllSkill(hero)
	end
	self._boss:cancelAllSkills()
	self._boss:removeAllBuff()
	self._boss:setTarget(nil)
	self._boss:forbidNormalAttack()
	self._boss:stopDoing()
	disableAllSkill(self._boss)
	app.battle._aiDirector:pause()
	--禁止操作
	app.scene._touchController:setSelectActorView(nil)
    app.scene._touchController:disableTouchEvent()
    app.scene._dragController:disableDragLine(true)
    for _, view in ipairs(app.scene._heroViews) do
    	view:hideHpView()
        view:setEnableTouchEvent(false)
    end
    for _, view in ipairs(app.scene._enemyViews) do
    	view:hideHpView()
    	view:setEnableTouchEvent(false)
    end

    -- self._actors[1002].onAttackFinished = function (actor, ...)
				-- 					    	QActor.onAttackFinished(actor, ...)
				-- 					    	actor:setTarget(nil)
				-- 					    end

    --停掉时间
    app.battle:setTimePauseInStoryLine(true)
    self:performWithDelay(function ()
    	self._actors[3086]:setTarget(self._actors[1002])
    end, 0.5)
    self:actorUseSkill(3086, 51326, self._total_delay + 0.2)
    --放技能
    self:performWithDelay(function()
    	self._actors[1002]:setTarget(self._actors[3086])
    	self._actors[3086]:setTarget(self._actors[1002])
    end, self._total_delay + 2)

	self:performWithDelay(function() self._actors[1001]:applyBuff("3S_stun")  end, self._total_delay + 22/30) 	

	self:performWithDelay(function()
    	self._actors[1002]:setDirection(QActor.DIRECTION_RIGHT)
    end, self._total_delay + 3/30 + 0.3, true)
    
	self:performWithDelay(function()
    	self._actors[1002]:playSkillEffect("shanxian_gg_3", nil, {})
    end, self._total_delay + 3/30 + 0.41)

    self:performWithDelay(function()
    	app.grid:moveActorTo(self._actors[1002], {x = display.cx - 320, y = display.cy + 50}, true, false, true)
    	self._actors[1002]:setDirection(QActor.DIRECTION_RIGHT)
    end, self._total_delay + 0.09)
    -- self:performWithDelay(function()
    -- 	self._actors[1002]:playSkillAnimation({"attack12"})
    -- end, self._total_delay + 19/30)
    
    self:actorUseSkill(1002, 51327, self._total_delay + 0.4)


    -- self:actorUseSkill(3086, 51328, self._total_delay + 5)
    self:performWithDelay(function() self:finished() app.battle:_onWin({isAllEnemyDead = true}) end, self._total_delay + 1.6)
    
end

function QTutorialPhaseDungeon14:actorUseSkill(actorID, skillId, delay)
	local actor = self._actors[actorID]
	if actor == nil then return end
	if actor._skills[skillId] == nil then
		actor._skills[skillId] = QSkill.new(skillId, {}, actor)
	end
	self._total_delay = math.max(self._total_delay, delay)
	app.battle:performWithDelay(function()
		actor:attack(actor._skills[skillId])
	end, delay)
end

function QTutorialPhaseDungeon14:performWithDelay(func, delay, not_calc_delay)
	if not not_calc_delay then
		self._total_delay = math.max(self._total_delay, delay)
	end
	app.battle:performWithDelay(func, delay)
end

function QTutorialPhaseDungeon14:_onBattleEnd()
	self:finished()
end

return QTutorialPhaseDungeon14