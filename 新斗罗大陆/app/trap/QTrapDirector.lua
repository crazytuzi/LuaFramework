
local QTrapDirector = class("QTrapDirector")
local QBaseEffectView
local QTouchEffectView
if not IsServerSide then
	QBaseEffectView = import("..views.QBaseEffectView")
	QTouchEffectView = import("..views.QTouchEffectView")
end
local QTrap = import("..models.QTrap")
local QSkill = import("..models.QSkill")

-- state
QTrapDirector.standby = 0
QTrapDirector.start = 1
QTrapDirector.execute = 2
QTrapDirector.finish = 3
QTrapDirector.complete = 4
QTrapDirector.canceled = 5

function QTrapDirector:ctor(trapId, position, actorType, actor, level, skill, isRune)
	assert(trapId ~= nil, "trap director should have a trap instance")
	assert(position ~= nil, "trap director must have a position to put it down")
	assert(actorType ~= nil, "shoud give a actor type to find damage target")

	self._trap = QTrap.new(trapId, position, actor, level, skill)
	self._actorType = actorType
	self._state = QTrapDirector.standby
	self._actor = actor
	self._isRune = isRune

	self._trapEventListener = cc.EventProxy.new(self._trap)
    self._trapEventListener:addEventListener(QTrap.TRIGGER, handler(self, self._onTrapTrigger))
    self._trigger_count = 0

    self._triggerDurationEffect = nil
    self._durationTriggered = false

	self:_start()
end

function QTrapDirector:getTrap()
	return self._trap
end

function QTrapDirector:isTragInfluenceActor(actor)
	if actor == nil then
		return false
	end

	if actor:isImmuneTrap(self._trap) then
		return false
	end

	if self._trap:getDamageTarget() == QTrap.ENEMY and actor:getType() == self._actorType then
		return false
	elseif self._trap:getDamageTarget() == QTrap.TEAMMATE and actor:getType() ~= self._actorType then
		return false
	end

    return self:_isActorInRange(actor)
end

function QTrapDirector:_isActorInRange(actor)
	local position = actor:getPosition()
	local shape = self._trap:getRangeShape()
	if shape == QTrap.SHAPE_CIRCLE then
		local radius = self._trap:getRange()
		local center = self._trap:getPosition()
	    local deltaX = position.x - center.x
	    local deltaY = (position.y - center.y) * self._trap:getYRatio()
	    local distance = deltaX * deltaX + deltaY * deltaY
	    if distance < radius * radius then
	        return true
	    end
	elseif shape == QTrap.SHAPE_RING then
		local radius = self._trap:getRange()
		local radius2 = self._trap:getRange2()
		local center = self._trap:getPosition()
	    local deltaX = position.x - center.x
	    local deltaY = (position.y - center.y) * self._trap:getYRatio()
	    local distance = deltaX * deltaX + deltaY * deltaY
	    if distance < radius * radius and distance > radius2 * radius2 then
	        return true
	    end
	elseif shape == QTrap.SHAPE_RECT then
		local width = self._trap:getRange()
		local height = self._trap:getRange2()
		local center = self._trap:getPosition()
		if math.abs(position.x - center.x) < width / 2 and math.abs(position.y - center.y) < height / 2 then
			return true
		end
	end
	return false
end

function QTrapDirector:_start()
	self._state = QTrapDirector.start
	self._trap:start()

	if not IsServerSide then
		local startEffectId = self._trap:getStartEffectId()
		local executeEffectId = self._trap:getExecuteEffectId()
		local areaEffectId = self._trap:getAreaEffectId()
		local finishEffectId = self._trap:getFinishEffectId()

		local actorView = app.scene:getActorViewFromModel(self._actor)

		-- create effect node from config file
		if startEffectId ~= nil then
			local frontEffect, backEffect = QBaseEffectView.createCombinedEffectByID(startEffectId)
			if frontEffect ~= nil then
				self._startEffect = frontEffect
			elseif backEffect ~= nil then
				self._startEffect = backEffect
			end
			if self._startEffect ~= nil then
				self._isStartEffectOnGround = db:getEffectIsLayOnTheGroundByID(startEffectId)
				if self._trap:isFlipWithActor() then
					local effect = self._startEffect
					effect:setSizeScaleX(self._trap:getTrapOwner():isFlipX() and -1 or 1, self._trap)
				end
				self._startEffect:setActorView(actorView)
			end
		end
			
		if executeEffectId ~= nil then
			local frontEffect, backEffect = QBaseEffectView.createCombinedEffectByID(executeEffectId, nil, self._isRune and QTouchEffectView or QBaseEffectView)
			if frontEffect ~= nil then
				self._executeEffect = frontEffect
			elseif backEffect ~= nil then
				self._executeEffect = backEffect
			end
			if self._executeEffect ~= nil then
				self._isExecuteEffectOnGround = db:getEffectIsLayOnTheGroundByID(executeEffectId)
				if self._isRune then
					self._executeEffect:setTouchEnabled(true)
					self._executeEffect:setModel(self._trap)
					self._executeEffect:addEventListener(QTouchEffectView.EVENT_TOUCH_END, handler(self, self._onClickRune))
				end
				if self._trap:isFlipWithActor() then
					local effect = self._executeEffect
					effect:setSizeScaleX(self._trap:getTrapOwner():isFlipX() and -1 or 1, self._trap)
				end
				self._executeEffect:setActorView(actorView)
			end
		end

		if areaEffectId ~= nil then
			local frontEffect, backEffect = QBaseEffectView.createCombinedEffectByID(areaEffectId)
			if frontEffect ~= nil then
				self._areaEffect = frontEffect
			elseif backEffect ~= nil then
				self._areaEffect = backEffect
			end
			if self._areaEffect ~= nil then
				self._isAreaEffectOnGround = db:getEffectIsLayOnTheGroundByID(areaEffectId)
				if self._trap:isFlipWithActor() then
					local effect = self._areaEffect
					effect:setSizeScaleX(self._trap:getTrapOwner():isFlipX() and -1 or 1, self._trap)
				end
				self._areaEffect:setActorView(actorView)
			end
		end

		if finishEffectId ~= nil then
			local frontEffect, backEffect = QBaseEffectView.createCombinedEffectByID(finishEffectId)
			if frontEffect ~= nil then
				self._finishEffect = frontEffect
			elseif backEffect ~= nil then
				self._finishEffect = backEffect
			end
			if self._finishEffect ~= nil then
				self._isFinishEffectOnGround = db:getEffectIsLayOnTheGroundByID(finishEffectId)
				if self._trap:isFlipWithActor() then
					local effect = self._finishEffect
					effect:setSizeScaleX(self._trap:getTrapOwner():isFlipX() and -1 or 1, self._trap)
				end
				self._finishEffect:setActorView(actorView)
			end
		end

		self:_retainEffect()

		-- play start effect
		if self._startEffect ~= nil then
			self._startEffect:setPosition(self._trap:getPosition().x, self._trap:getPosition().y)
	        app.scene:addEffectViews(self._startEffect, {isGroundEffect = self._isStartEffectOnGround})
	        self._startEffect:playAnimation(self._startEffect:getPlayAnimationName(), false)
	        self._startEffect:playSoundEffect(false)
	        self._startEffect:afterAnimationComplete(function()
	            app.scene:removeEffectViews(self._startEffect)
	            if self._state ~= QTrapDirector.canceled and self._trap:isEnded() ~= true then
	            	self:_playExecuteEffect()
	            end
	        end)
		else
			self:_playExecuteEffect()
		end

		if not IsServerSide and DISPLAY_TRAP_RANGE == true then
			local range = self._trap:getRange()
			local range2 = self._trap:getRange2()
			local center = self._trap:getPosition()
	        local shape = self._trap:getRangeShape()
	        if shape == QTrap.SHAPE_RECT then
		        local bottomLeft = ccp(center.x - range * 0.5, center.y - range2 * 0.5)
		        local topRight = ccp(center.x + range * 0.5, center.y + range2 * 0.5)
		        app.scene:displayRect(bottomLeft, topRight, self._trap:getDuration(), display.COLOR_MAGENTA_C4F)
	        else
	        	local rangeY = range / self._trap:getYRatio()
		        local bottomLeft = ccp(center.x - range, center.y - rangeY)
		        local topRight = ccp(center.x + range, center.y + rangeY)
		        app.scene:displayRect(bottomLeft, topRight, self._trap:getDuration(), display.COLOR_MAGENTA_C4F)
		        -- if range2 then
			       --  local bottomLeft = ccp(center.x - range2, center.y - range2 * 0.5)
			       --  local topRight = ccp(center.x + range2, center.y + range2 * 0.5)
			       --  app.scene:displayRect(bottomLeft, topRight, self._trap:getDuration(), display.COLOR_YELLOW_C4F)
		        -- end
		    end
		end
	end
	
	self._state = QTrapDirector.execute
end

function QTrapDirector:_playTriggerDurationEffect()
	local triggerDurationEffectId = self._trap:getTriggerDurationEffectId()
	local isTriggerDurationEffectBackGround = false
	if triggerDurationEffectId ~= nil then
		local frontEffect, backEffect = QBaseEffectView.createCombinedEffectByID(triggerDurationEffectId)
		if frontEffect ~= nil then
			self._triggerDurationEffect = frontEffect
		elseif backEffect ~= nil then
			self._triggerDurationEffect = backEffect
		end
		if self._triggerDurationEffect ~= nil then
			isTriggerDurationEffectBackGround = db:getEffectIsLayOnTheGroundByID(triggerDurationEffectId)
			if self._trap:isFlipWithActor() then
				local effect = self._triggerDurationEffect
				effect:setSizeScaleX(self._trap:getTrapOwner():isFlipX() and -1 or 1, self._trap)
			end
		end
	end

	if self._triggerDurationEffect ~= nil then
		self._triggerDurationEffect:retain()
	    self._triggerDurationEffect:setPosition(self._trap:getPosition().x, self._trap:getPosition().y + 1)
	    app.scene:addEffectViews(self._triggerDurationEffect, {isGroundEffect = isTriggerDurationEffectBackGround})
	    self._triggerDurationEffect:playAnimation(self._triggerDurationEffect:getPlayAnimationName(), true)
	    self._triggerDurationEffect:playSoundEffect(false)
	end

	self:setEffectVisible(false)
end

function QTrapDirector:_playTriggerDurationEndEffect()
	local effectId = self._trap:getTriggerDurationEndEffectId()
	local isEffectBackGround = false
	local effect = nil
	if effectId ~= nil then
		local frontEffect, backEffect = QBaseEffectView.createCombinedEffectByID(effectId)
		if frontEffect ~= nil then
			effect = frontEffect
		elseif backEffect ~= nil then
			effect = backEffect
		end
		if effect ~= nil then
			isEffectBackGround = db:getEffectIsLayOnTheGroundByID(effectId)
			if self._trap:isFlipWithActor() then
				effect:setSizeScaleX(self._trap:getTrapOwner():isFlipX() and -1 or 1, self._trap)
			end
		end
	end

	if effect ~= nil then
	    effect:setPosition(self._trap:getPosition().x, self._trap:getPosition().y + 1)
	    app.scene:addEffectViews(effect, {isGroundEffect = isTriggerDurationEffectBackGround})
	    effect:playAnimation(effect:getPlayAnimationName(), false)
	    effect:playSoundEffect(false)
        effect:afterAnimationComplete(function()
            app.scene:removeEffectViews(effect)
        end)
	end
end

function QTrapDirector:_releaseTriggerDurationEffect()
	if self._triggerDurationEffect ~= nil then
		self._triggerDurationEffect:stopAnimation()
		app.scene:removeEffectViews(self._triggerDurationEffect)
		self._triggerDurationEffect:release()
		self._triggerDurationEffect = nil
	end
	
	self:setEffectVisible(true)
end

function QTrapDirector:_playExecuteEffect()
	if self._executeEffect ~= nil then
		self._executeEffect:setPosition(self._trap:getPosition().x, self._trap:getPosition().y + 1)
	    app.scene:addEffectViews(self._executeEffect, {isGroundEffect = self._isExecuteEffectOnGround})
	    self._executeEffect:playAnimation(self._executeEffect:getPlayAnimationName(), true)
	    self._executeEffect:playSoundEffect(false)
	end

	if self._areaEffect ~= nil then
	    self._areaEffect:setPosition(self._trap:getPosition().x, self._trap:getPosition().y + 1)
	    app.scene:addEffectViews(self._areaEffect, {isGroundEffect = self._isAreaEffectOnGround})
	    self._areaEffect:playAnimation(self._areaEffect:getPlayAnimationName(), true)
	    self._areaEffect:playSoundEffect(false)
	end
end

function QTrapDirector:visit(dt)
	if self._state ~= QTrapDirector.execute then
		return
	end

	if self._isPaused then
		return
	end

	local triggerDurationTime = self._trap:getTriggerDurationTime()
	local triggerDurationPassTime = self._trap:getTriggerDurationPassTime()
	if not IsServerSide then
		self:_updateEffect()
		if triggerDurationTime ~= 0 then
			if triggerDurationPassTime ~= 0 and triggerDurationPassTime < triggerDurationTime then
				if nil == self._triggerDurationEffect then
					self:_playTriggerDurationEffect()
				end
			else
				self:_releaseTriggerDurationEffect()
				if triggerDurationPassTime == triggerDurationTime and not self._durationTriggered then
					self._durationTriggered = true
					self:_playTriggerDurationEndEffect()
					self._trap:setIsEnd()
				end
			end
		end
	else
		if triggerDurationTime ~= 0 then
			if not (triggerDurationPassTime ~= 0 and triggerDurationPassTime < triggerDurationTime) then
				if triggerDurationPassTime == triggerDurationTime and not self._durationTriggered then
					self._durationTriggered = true
					self._trap:setIsEnd()
				end
			end
		end
	end	
	self._trap:visit(dt)

	local trap_triggered = self:_updateTrigger(dt)

	if trap_triggered or self._trap:isEnded() == true then
		if not IsServerSide then
			-- stop and remove execute effect
			if self._executeEffect ~= nil then
				self._executeEffect:stopAnimation()
				app.scene:removeEffectViews(self._executeEffect)
				if self._isRune then
					self._executeEffect:removeAllEventListeners()
				end
			end
			if self._areaEffect ~= nil then
				self._areaEffect:stopAnimation()
				app.scene:removeEffectViews(self._areaEffect)
			end
			if self._startEffect ~= nil then
				self._startEffect:stopAnimation()
				app.scene:removeEffectViews(self._startEffect)
			end
		end

		self._state = QTrapDirector.finish

		if not IsServerSide then
			-- play finish effect
			if self._finishEffect ~= nil and not self._durationTriggered then
				self._finishEffect:setPosition(self._trap:getPosition().x, self._trap:getPosition().y)
		        app.scene:addEffectViews(self._finishEffect, {isGroundEffect = self._isFinishEffectOnGround})
		        self._finishEffect:playAnimation(self._finishEffect:getPlayAnimationName(), false)
		        self._finishEffect:playSoundEffect(false)
		        self._finishEffect:afterAnimationComplete(function()
		            app.scene:removeEffectViews(self._finishEffect)
		            self:_complete()
		        end)
			else
				self:_complete()
			end
		end

		local finishEffectId = self._trap:getFinishEffectId()
		if finishEffectId ~= nil then
			app.battle:performWithDelay(function ( ... )
				if self._trapEventListener ~= nil then
					self._trapEventListener:removeAllEventListeners()
					self._trapEventListener = nil
				end
				self._state = QTrapDirector.complete
			end, 0.5)
		else
			if self._trapEventListener ~= nil then
				self._trapEventListener:removeAllEventListeners()
				self._trapEventListener = nil
			end
			self._state = QTrapDirector.complete
		end
	end
end

function QTrapDirector:_complete()
	self:_releaseEffect()
end

function QTrapDirector:isExecute()
	return (self._state == QTrapDirector.execute)
end

function QTrapDirector:isCompleted()
	return (self._state == QTrapDirector.complete)
end

function QTrapDirector:cancel()
	local stateBefore = self._state
	self._state = QTrapDirector.canceled

	if not IsServerSide then
		if stateBefore == QTrapDirector.start and self._startEffect ~= nil then
			self._startEffect:stopAnimation()
		elseif stateBefore == QTrapDirector.execute then
			if self._executeEffect ~= nil then
				self._executeEffect:stopAnimation()
				app.scene:removeEffectViews(self._executeEffect)
				if self._isRune then
					self._executeEffect:removeAllEventListeners()
				end
			end
			if self._areaEffect ~= nil then
				self._areaEffect:stopAnimation()
				app.scene:removeEffectViews(self._areaEffect)
			end
			if self._startEffect ~= nil then
				self._startEffect:stopAnimation()
				app.scene:removeEffectViews(self._startEffect)
			end
		elseif stateBefore == QTrapDirector.finish and self._finishEffect ~= nil then
			self._finishEffect:stopAnimation()
		end

		self:_releaseEffect()
	end
end

function QTrapDirector:_retainEffect()
	if self._startEffect ~= nil then
		self._startEffect:retain()
	end
	
	if self._executeEffect ~= nil then
		self._executeEffect:retain()
	end

	if self._finishEffect ~= nil then
		self._finishEffect:retain()
	end

	if self._areaEffect ~= nil then
		self._areaEffect:retain()
	end
end

function QTrapDirector:_releaseEffect()
	if self._startEffect ~= nil then
		self._startEffect:release()
		self._startEffect = nil
	end
	
	if self._executeEffect ~= nil then
		self._executeEffect:release()
		self._executeEffect = nil
	end

	if self._finishEffect ~= nil then
		self._finishEffect:release()
		self._finishEffect = nil
	end

	if self._areaEffect ~= nil then
		self._areaEffect:release()
		self._areaEffect = nil
	end
	self:_releaseTriggerDurationEffect()
end


function QTrapDirector:_onTrapTrigger()
	local trap_finish = false
	if app.battle:hasWinOrLose() then
		return
	end

	if app.battle:isPausedBetweenWave() == true then
		return
	end

	if self._isPaused then
		return
	end
	
	local radius = self._trap:getRange()
	assert(radius > 0, "trap: " .. self._trap:getId() .. " range should large then 0")
	radius = radius * radius

	local actors = nil
	if self._trap:getDamageTarget() == QTrap.EVERYONE then
		actors = {}
		table.merge(actors, app.battle:getMyTeammates(self._actor))
		table.merge(actors, app.battle:getMyEnemies(self._actor))

	elseif self._trap:getDamageTarget() == QTrap.ENEMY then
		actors = app.battle:getMyEnemies(self._actor)

	elseif self._trap:getDamageTarget() == QTrap.TEAMMATE then
		actors = app.battle:getMyTeammates(self._actor, true)

	else
		assert(false, "trap: " .. self._trap:getId() .. "is for teammate or enemy or both of then, but current target type is " .. self._trap:getDamageType())
	end
	
	local targets = {}
	local center = self._trap:getPosition()
	local y_ratio = self._trap:getYRatio()
	for _, actor in ipairs(actors) do
		if not actor:isImmuneAoE() then
			if self:_isActorInRange(actor) then
		    	table.insert(targets, actor)
		    end
		end
	end

	local status_list = self._trap:getTriggerStatus()
	if status_list and #targets > 0 then
		local _targets = {}
		for k,target in ipairs(targets) do
			for _,status in ipairs(status_list) do
				if target:isUnderStatus(status) then
					table.insert(_targets,target)
					break
				end
			end
		end
		if #_targets == 0 then
			return
		end
		targets = _targets
	end

	if #targets > 0 then
		local addition_time = self._trap:getAdditionTime()
		if addition_time then
			self._trap:additionTime(addition_time)
		end
	end

	if self._trap:getDamageEachTime() > 0 or 0 < self._trap:getDamageTargetMaxHpPercent() then
		local damage = self._trap:getDamageEachTime()
		local absorb = 0
		local tip = ""
		local damageType = self._trap:getDamageType()
		for _, target in ipairs(targets) do
	        local immune_physical_damage = target:isImmunePhysicalDamage()
	        local immune_magic_damage = target:isImmuneMagicDamage()
	        local immuned = false
			if damageType == QTrap.TREAT then
				target:increaseHp(damage, self._actor, self._trap:getTrapOwnerSkill())
			elseif damageType == QTrap.ATTACK  then
				if immune_physical_damage and immune_magic_damage then
		            target:dispatchEvent({name = target.UNDER_ATTACK_EVENT, isTreat = false, tip = global.immune_magic, rawTip = {
		                isHero = target:getType() ~= ACTOR_TYPES.NPC,
		                isImmune = true}})
		            immuned = true
		        else
			    	local trapOwner = self._trap:getTrapOwner()
				    -- 海神岛伤害系数
				    damage = damage * app.battle:getDamageCoefficient()
				    -- pvp属性系数
				    if app.battle:isPVPMode() then
				    	local trapOwnerSkill = self._trap:getTrapOwnerSkill()
				    	if trapOwnerSkill:getDamageType() == trapOwnerSkill.PHYSICAL then
				    		damage = damage * math.max(1 + math.max(trapOwner:getPVPPhysicalAttackPercent() - target:getPVPPhysicalReducePercent(), -0.8), 0)
				    	elseif trapOwnerSkill:getDamageType() == trapOwnerSkill.MAGIC then
				    		damage = damage * math.max(1 + math.max(trapOwner:getPVPMagicAttackPercent() - target:getPVPMagicReducePercent(), -0.8), 0)
				    	end
				    end
				    -- 战斗模块伤害系数
				    damage = app.battle:addDamage(damage, trapOwner)
				    -- aoe属性系数
				    damage = damage * (1 + trapOwner:getAOEAttackPercent())
				    --根据目标最大血量获取伤害(不受其他系数影响)
				    if 0 < self._trap:getDamageTargetMaxHpPercent() then
        				damage = self._trap:getDamageTargetMaxHpPercent() * target:getMaxHp()
				    end
					if damage > 0 then
						if not target:isBoss() and not target:isEliteBoss() then
							self._actor:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_DAMAGE, target, damage, nil, nil, self)
						end
						local percent = 0
						
					    for _, tab in ipairs(target:getStrikeAgreementers()) do
					        if tab.percent and tab.actor then
					            percent = percent + tab.percent
					            if percent <= 1 then
					                tab.actor:dispatchEvent({name = target.DECREASEHP_EVENT, hp = damage * percent,
					        			attacker = self._actor,skill = self._trap:getTrapOwnerSkill(), no_render = nil})
					            else
					                percent = 1
					            end
					        end
					    end
					    damage = damage * self._trap:getDragonModifier()
					    _, damage, absorb = target:decreaseHp(damage * (1 - percent), self._actor, self._trap:getTrapOwnerSkill(), nil, true)
					    
			            -- 触发hit condition
			            target:triggerPassiveSkill(QSkill.TRIGGER_CONDITION_HIT, self._trap:getTrapOwner(), damage, nil, nil, self._trap)
					end
				end
			else
				assert(false, "Trap damage type is limit in attack and treat. But " .. self._trap:getId() .. "'s damage type is " .. damageType)
			end
			if not immuned then
		        if absorb > 0 then
		            tip = "吸收 "
	                target:dispatchEvent({name = target.UNDER_ATTACK_EVENT, isTreat = false, isCritical = false, tip = tip .. tostring(math.floor(absorb)),rawTip = {
	                    isHero = target:getType() ~= ACTOR_TYPES.NPC, 
	                    isDodge = false, 
	                    isBlock = false, 
	                    isCritical = false, 
	                    isTreat = false,
	                    isAbsorb = true, 
	                    number = absorb
	                }})
		            tip = ""
		        end
				target:dispatchEvent({name = target.UNDER_ATTACK_EVENT, isTreat = (damageType == QTrap.TREAT), tip = tostring(damage),
	                    rawTip = {
	                        isHero = target:getType() ~= ACTOR_TYPES.NPC, 
	                        isDodge = false, 
	                        isBlock = false, 
	                        isCritical = false, 
	                        isTreat = false, 
	                        number = damage
	                    }})
			end
		end
		if not trap_finish then
			self._trigger_count = self._trigger_count + 1
		end
		trap_finish = true
	end



	-- 触发ot skill, ot buff
	local owner_skill = self._trap:getTrapOwnerSkill()
	local default_level = owner_skill and owner_skill:getSkillLevel() or 1
	local skill_id = self._trap:getOTSkillID()
	if skill_id then
		local skill_id, level = q.parseIDAndLevel(skill_id, default_level)
		skill_id = tonumber(skill_id)
		if self._trap:isOtFromOwner() then
			targets = {}
			table.insert(targets, self._trap:getTrapOwner())
		end
		for _, actor in ipairs(targets) do
            local triggerSkill = actor._skills[skill_id]
            if triggerSkill == nil then
                triggerSkill = QSkill.new(skill_id, db:getSkillByID(skill_id), actor, level)
                triggerSkill:setEnhanceValue(self._trap:getEnhanceValue())
                triggerSkill:setIsTriggeredSkill(true)
                actor._skills[skill_id] = triggerSkill
            end
            triggerSkill:setDamager(self._trap:getTrapOwner())

            local behavior = nil
            if self._trap:getTriggerSkillAsCurrent() then
            	behavior = actor:attack(triggerSkill)
            else
				behavior = actor:triggerAttack(triggerSkill)
			end

			if self._trap:isTransmitPos() and behavior then
				behavior:setAddtionArguments({absolute_pos = self._trap:getPosition()})
			end

			if not trap_finish then
				self._trigger_count = self._trigger_count + 1
			end
			trap_finish = true
		end
	end
	local buff_id = self._trap:getOTBuffID()
	if buff_id ~= "" then
		--local buff_id, level = q.parseIDAndLevel(buff_id, default_level)
		for _, actor in ipairs(targets) do
			actor:applyBuff(buff_id, self._actor, owner_skill)
			if not trap_finish then
				self._trigger_count = self._trigger_count + 1
			end
			trap_finish = true
		end
	end
	if self._trap:isTriggerOnce() and self._trigger_count > 0 then
		self._trap:setIsEnd()
	end
end

function QTrapDirector:_updateTrigger(dt)
	local trap = self._trap
	local trigger_target = trap:getTriggerTarget()
	if not trigger_target or trigget_target == "" then
		return false
	end

	local triggered = false

	local radius = self._trap:getRange()
	assert(radius > 0, "trap: " .. self._trap:getId() .. " range should large then 0")
	radius = radius * radius

	local actors = nil
	if self._trap:getDamageTarget() == QTrap.EVERYONE then
		actors = {}
		table.merge(actors, app.battle:getMyTeammates(self._actor))
		table.merge(actors, app.battle:getMyEnemies(self._actor))

	elseif self._trap:getDamageTarget() == QTrap.ENEMY then
		actors = app.battle:getMyEnemies(self._actor)

	elseif self._trap:getDamageTarget() == QTrap.TEAMMATE then
		actors = app.battle:getMyTeammates(self._actor, true)

	else
		assert(false, "trap: " .. self._trap:getId() .. "is for teammate or enemy or both of then, but current target type is " .. self._trap:getDamageType())
	end
	
	local targets = {}
	local center = self._trap:getPosition()
	local y_ratio = self._trap:getYRatio()
	local trigger_actor = actor
	for _, actor in ipairs(actors) do
	    local pos = actor:getPosition()
	    local deltaX = pos.x - center.x
	    local deltaY = (pos.y - center.y) * y_ratio
	    local distance = deltaX * deltaX + deltaY * deltaY
	    if distance < radius then
	    	trigger_actor = actor
	    	break
	    end
	end

	if trigger_actor then
		local triggerDurationTime = self._trap:getTriggerDurationTime()
		local triggerDurationPassTime = self._trap:getTriggerDurationPassTime()
		if triggerDurationTime ~= 0 then
			if triggerDurationPassTime < triggerDurationTime then
				triggerDurationPassTime  = triggerDurationPassTime + dt
				if triggerDurationPassTime > triggerDurationTime then
					triggerDurationPassTime = triggerDurationTime
				end
				self._trap:setTriggerDurationPassTime(triggerDurationPassTime)
			end
			triggered = false
			return triggered
		end
	else
		self._trap:setTriggerDurationPassTime(0)
	end

	local overrideTrapId = self._trap:getOverrideTrapId()
	if not trap:IsTriggered() and trap:isEnded() and overrideTrapId and overrideTrapId ~= "" then
        local trap_id, level = q.parseIDAndLevel(overrideTrapId)
        local trapDirector = QTrapDirector.new(trap_id, self._trap:getPosition(),
        	self._trap:getTrapOwner():getType(), self._trap:getTrapOwner(), level)
        app.battle:addTrapDirector(trapDirector)

		triggered = true
		return triggered
	end

	if trigger_actor then
		-- 触发对象
		local trigger_actors = {trigger_actor}
		if trigger_target == QTrap.TEAMMATE then
			trigger_actors = app.battle:getMyTeammates(trigger_actor, true)
		elseif trigger_target == QTrap.ENEMY then
			trigger_actors = app.battle:getMyEnemies(trigger_actor)
		elseif trigger_target == QTrap.EVERYONE then
			trigger_actors = app.battle:getMyTeammates(trigger_actor, true)
			-- table.merge(actors, app.battle:getMyEnemies(trigger_actor))
		elseif tirgger_target == QTrap.SELF then

		end
		-- 触发Buff
		local buff_id = self._trap:getTriggerBuffID()
		if buff_id ~= "" then
			local buff_id, level = q.parseIDAndLevel(buff_id, 1, self._trap:getTrapOwnerSkill())
			for _, actor in ipairs(trigger_actors) do
				actor:applyBuff(buff_id)
			end
			local buff = trigger_actor:getBuffByID(buff_id)
			if buff and not IsServerSide then
				local triggerActorView = app.scene:getActorViewFromModel(trigger_actor)
				triggerActorView:showRuneTip(self._trap, buff, trigger_target == QTrap.TEAMMATE)
			end
			triggered = true
		end
		-- 触发技能
		local skill_id = self._trap:getTriggerSkillID()
		if skill_id then
			local skill_id, level = q.parseIDAndLevel(skill_id, 1, self._trap:getTrapOwnerSkill())
			skill_id = tonumber(skill_id)
			if self._trap:isOtFromOwner() then
				targets = {}
				table.insert(targets, self._trap:getTrapOwner())
			end
			for _, actor in ipairs(trigger_actors) do
                local triggerSkill = actor._skills[skill_id]
                if triggerSkill == nil then
                    triggerSkill = QSkill.new(skill_id, db:getSkillByID(skill_id), actor, level)
                	triggerSkill:setEnhanceValue(self._trap:getEnhanceValue())
                    triggerSkill:setIsTriggeredSkill(true)
                    actor._skills[skill_id] = triggerSkill
                end
                local behavior = nil
				if self._trap:getTriggerSkillAsCurrent() then
	            	behavior = actor:attack(triggerSkill)
	            else
					behavior = actor:triggerAttack(triggerSkill)
				end
				if self._trap:isTransmitPos() and behavior then
					behavior:setAddtionArguments({absolute_pos = self._trap:getPosition()})
				end
			end
			triggered = true
		end
    	-- 触发陷阱
    	local trap_id = self._trap:getTriggerTrapID()
    	if trap_id ~= "" then
	        local trap_id, level = q.parseIDAndLevel(trap_id)
	        local trapDirector = QTrapDirector.new(trap_id, self._trap:getPosition(), self._trap:getTrapOwner():getType(), self._trap:getTrapOwner(), level)
	        app.battle:addTrapDirector(trapDirector)
			triggered = true
	    end
    end

	return triggered
end

-- function QTrapDirector:_onClickRune()
-- 	if app.battle:isPaused() or app.battle:isPausedBetweenWave() then
-- 		return
-- 	end

-- 	if not self._isRune then
-- 		return
-- 	end

-- 	-- 找一个最近的魂师去吃符文
-- 	local heroes = app.battle:getHeroes()
-- 	local dist = 99999999
-- 	local candidate = nil
-- 	local trap_position = clone(self._trap:getPosition())
-- 	for _, hero in ipairs(heroes) do
-- 		if hero:canMove() and hero:CanControlMove() and hero:getMoveSpeed() > 0 then
-- 			local skill = hero:getCurrentSkill()
-- 			if not skill or skill:isAllowMoving() then
-- 				local dist2 = q.distOf2PointsSquare(hero:getPosition(), trap_position)
-- 				if dist2 < dist then
-- 					candidate = hero
-- 					dist = dist2
-- 				end
-- 			end
-- 		end
-- 	end
-- 	if candidate then
-- 		candidate:setManualMode(candidate.STAY)
-- 		app.grid:moveActorTo(candidate, trap_position)
-- 	end
-- end

local function _moveEffectPosition(effect, dx, dy)
	if effect then
		local x, y = effect:getPosition()
		effect:setPosition(ccp(x + dx, y + dy))
	end
end

function QTrapDirector:setPosition(new_pos)
	local trap = self._trap
	local old_pos = trap:getPosition()
	trap:setPosition(new_pos)

	if not IsServerSide then
		local dx, dy = new_pos.x - old_pos.x, new_pos.y - old_pos.y
		_moveEffectPosition(self._startEffect, dx, dy)
		_moveEffectPosition(self._executeEffect, dx, dy)
		_moveEffectPosition(self._areaEffect, dx, dy)
		_moveEffectPosition(self._finishEffect, dx, dy)
		if self._triggerDurationEffect then
			_moveEffectPosition(self._triggerDurationEffect, dx, dy)
		end
	end
end

function QTrapDirector:resume()
	self._isPaused = false
end

function QTrapDirector:pause()
	self._isPaused = true
end

function QTrapDirector:_updateEffect()
	local func = function(effect, scale)
		if effect then
	    	effect:getSkeletonView():setAnimationScale(scale)
		end
	end

	local scale = app.battle:isPausedBetweenWave() and 0 or 1
	func(self._startEffect, scale)
	func(self._executeEffect, scale)
	func(self._areaEffect, scale)
	func(self._finishEffect, scale)
	if self._triggerDurationEffect then
		func(self._triggerDurationEffect, scale)
	end
end

function QTrapDirector:setEffectVisible(b)
	if nil ~= self._startEffect then
		self._startEffect:setVisible(b)
	end
	if nil ~= self._executeEffect then
		self._executeEffect:setVisible(b)
	end
	if nil ~= self._areaEffect then
		self._areaEffect:setVisible(b)
	end
	if nil ~= self._finishEffect then
		self._finishEffect:setVisible(b)
	end
end

return QTrapDirector
