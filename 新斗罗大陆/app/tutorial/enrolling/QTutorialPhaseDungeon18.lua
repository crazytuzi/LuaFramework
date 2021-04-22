local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhaseDungeon18 = class("QTutorialPhaseDungeon18", QTutorialPhase)
local QActor = import("...models.QActor")
local QSkill = import("...models.QSkill")

function QTutorialPhaseDungeon18:start()
	if remote.instance:checkIsPassByDungeonId(app.battle._dungeonConfig.id) then
		self:finished()
        return
    end
	self._trigger_tutorial = false
	self._total_delay = 0
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

function QTutorialPhaseDungeon18:checkHasBoss()
	if self._boss then
		return true
	end
	self._actors = {}
	local phase = self
	for k,enemy in ipairs(app.battle:getEnemies()) do
		self._actors[enemy:getActorID()] = enemy
		if enemy:getActorID() == 3037 then
			self._boss = enemy
		end
	end

	for i,hero in pairs(app.battle:getHeroes()) do
		self._actors[hero:getActorID()] = hero
	end

	if self._actors[3037] then
		if self._actors[1002] == nil then
			self:finished()
			return false
		end
	else
		return false
	end

	self._boss.decreaseHp = function (self, hp, ...)
		hp = hp * 0.87
		if (self:getHp() - hp) / self:getMaxHp() <= 0.08 then
			phase._trigger_tutorial = true
	        hp = math.ceil(self:getHp() - self:getMaxHp() * 0.08)
	    end
	    if hp > 0 then
	        return QActor.decreaseHp(self, hp, ...)
	    else
	        return self, hp, 0
	    end
	end

	self._actors[1002].decreaseHp = function(self, hp, ...)
		if (self:getHp() - hp) / self:getMaxHp() <= 0.01 then
			phase._trigger_tutorial = true
	        hp = math.ceil(self:getHp() - self:getMaxHp() * 0.01)
	    end
	    if hp > 0 then
	        return QActor.decreaseHp(self, hp, ...)
	    else
	        return self, hp, 0
	    end
	end

	return true
end

function QTutorialPhaseDungeon18:visit()
	if self:checkHasBoss() == false then
		return
	end
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
		hero:forbidMove()
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

    --停掉时间
    app.battle:setTimePauseInStoryLine(true)

    --放技能
    self:performWithDelay(function()  
    					self._boss:setTarget(self._actors[1002])
    					self._boss:setDirection(QActor.DIRECTION_LEFT)
    					self._actors[1002]:setDirection(QActor.DIRECTION_RIGHT)
    					self._actors[1002]:setTarget(self._boss)
    					if self._actors[1001] then
    						self._actors[1001]:setDirection(QActor.DIRECTION_RIGHT)
    					end
    				end, 0)

    -- self._actors[1002].onAttackFinished = function (actor, ...)
				-- 					    	QActor.onAttackFinished(actor, ...)
				-- 					    	actor:setTarget(nil)
				-- 					    end

 
    self:actorUseSkill(3037, 51331, self._total_delay + 0.1)
   	self:performWithDelay(function()
	   		if self._actors[1001] then
		   		self._actors[1001]:setDirection(QActor.DIRECTION_LEFT)
		   	end
   		end,self._total_delay + 6.8)
    if self._actors[1001] then
    	self:actorUseSkill(1001, 51333, self._total_delay - 5.6)
    	self:performWithDelay(function() self._actors[1001]:cancelAllSkills() self._actors[1001]:setDirection(QActor.DIRECTION_RIGHT) end, self._total_delay -5)
    else
    	self:performWithDelay(function() 
    		for id,actor in pairs(self._actors) do
	    		if id ~= 1002 and id ~= 3037 and actor:isDead() == false then
	    			app.grid:moveActorTo(actor, {x = 300, y = 360}, true, false, true)
	    			actor:stopDoing()
	    			actor:setTarget(nil)
	    			actor:playSkillEffect("chuxian_lanse", nil, {})
	    			actor:setDirection(QActor.DIRECTION_RIGHT)
	    		end
    		end
    	end, self._total_delay - 5.2)
    	self:performWithDelay(function() end, self._total_delay + 0.52)
    end

    self:actorUseSkill(1002, 51332, self._total_delay - 6)
    self:performWithDelay(function()
    		self._boss:playSkillAnimation({"attack15"})
    	end,self._total_delay - 3.8)

    self:performWithDelay(function() self:finished() app.battle:_onWin({isAllEnemyDead = true}) end, self._total_delay - 5.3)
    
end

function QTutorialPhaseDungeon18:actorUseSkill(actorID, skillId, delay)
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

function QTutorialPhaseDungeon18:performWithDelay(func, delay, not_calc_delay)
	if not not_calc_delay then
		self._total_delay = math.max(self._total_delay, delay)
	end
	app.battle:performWithDelay(func, delay)
end

function QTutorialPhaseDungeon18:_onBattleEnd()
	self:finished()
end

return QTutorialPhaseDungeon18