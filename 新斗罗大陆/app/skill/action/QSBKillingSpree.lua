--[[
    Class name QSBKillingSpree
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBKillingSpree = class("QSBKillingSpree", QSBAction)

local QBaseEffectView
if not IsServerSide then
	QBaseEffectView = import("...views.QBaseEffectView")
end

local SHUTTLE_FRAME_COUNT = 4

function QSBKillingSpree:ctor(director, attacker, target, skill, options)
    QSBKillingSpree.super.ctor(self, director, attacker, target, skill, options)
    self._first_target_pos = self._attacker:getTarget() and self._attacker:getTarget():getPosition()
end

function QSBKillingSpree:_execute(dt)
	if not self._done_select_target then
		self:_selectTarget()
		self._done_select_target = true
	elseif not self._done_teleport then
		self:_teleport()
		self._done_teleport = true
	elseif not self._done_shuttle then
		self._done_shuttle = self:_shuttle()
	else
		self:finished()
	end
end

function QSBKillingSpree:_shuttle()
	local actor = self._attacker
	local target = actor:getTarget()

	if not target then
		self:finished()
		return
	end

	if not self._shuttle_inited then
		-- 初始化，穿梭的起始帧
		self._shuttle_frame = 1
		-- 朝向初始化
		if math.xor(self._shuttle_distance > 0, actor:getDirection() == actor.DIRECTION_LEFT) then
			actor:_setFlipX()
		end
		actor:setDirection(self._options.direction)
		self._shuttle_inited = true
	end

	if self._shuttle_frame <= SHUTTLE_FRAME_COUNT then
		if not IsServerSide then
			-- 播放残影特效
			local createEffect = function(effectId)
				if effectId ~= nil and effectId ~= "" then
					local frontEffect, backEffect = QBaseEffectView.createEffectByID(effectId)
					local effect = frontEffect or backEffect
					effect:setActorView(app.scene:getActorViewFromModel(actor))
					effect:setPosition(actor:getPosition().x, actor:getPosition().y)
					local scale = (self._options.direction == actor.DIRECTION_LEFT) and 1 or -1
					local preScale = effect:getSkeletonView():getScaleX()
					effect:getSkeletonView():setScaleX(preScale * scale)
				    app.scene:addEffectViews(effect, {isFrontEffect = true})
			    	effect:playAnimation(effect:getPlayAnimationName(), false)
			        effect:afterAnimationComplete(function()
			            app.scene:removeEffectViews(effect)
			            effect = nil
			        end)
			        return effect
			    end
			end

			if self._shuttle_effect_back == nil then
				local effectId = self._options.afterimage_back_effect
				self._shuttle_effect_back = createEffect(effectId)
			end

			if self._shuttle_effect_front == nil then
				local effectId = self._options.afterimage_front_effect
				self._shuttle_effect_front = createEffect(effectId)
			end
		end
		-- 制造实际伤害
		if self._shuttle_frame == 2 then
			local target = self._attacker:getTarget() 
			if target and not target:isDead() then
				self._attacker:onHit(self._skill, target, nil, nil)
			end
		end
		-- 步进
		self._shuttle_frame = self._shuttle_frame + 1
		local position = clone(actor:getPosition())
		position.x = position.x + self._shuttle_distance / (SHUTTLE_FRAME_COUNT - 1)
		app.grid:moveActorTo(actor, position, true, true, true)
		return false
	else
		return true
	end
end

function QSBKillingSpree:_teleport()
	local in_range = self._options.in_range

	local actor = self._attacker
	local target = actor:getTarget()

	if not target then
		self:finished()
		return
	end

	local direction = self._options.direction or self._director._killing_spree_direction
	local pos = clone(target:getPosition())
	local end_pos = clone(target:getPosition())
    local distance = (actor:getRect().size.width + target:getRect().size.width) / 2
	if direction == "right" then
		pos.x = pos.x - distance
		end_pos.x = end_pos.x + distance
	else
		pos.x = pos.x + distance
		end_pos.x = end_pos.x - distance
	end
	local isOutOfRange, gridPos = app.grid:_toGridPos(end_pos.x, end_pos.y)
	if in_range and isOutOfRange then
		direction = direction == "left" and "right" or "left"
		if direction == "right" then
			pos.x = pos.x - distance * 2
			end_pos.x = end_pos.x + distance * 2
		else
			pos.x = pos.x + distance * 2
			end_pos.x = end_pos.x - distance * 2
		end
	end
	app.grid:setActorTo(actor, pos, true, true)
	self._shuttle_distance = (actor:getTarget():getPosition().x - actor:getPosition().x) * 2
	self._director._killing_spree_direction = direction == "left" and "right" or "left"
end

function QSBKillingSpree:_selectTarget()
	local actor = self._attacker

	if not self._options.always and actor:getTarget() then
		return
	end

	if self._options.original_target then
		local target = self._director:getTarget()
		if target and not target:isDead() then
			actor:setTarget(target)
			return
		end
	end

	local range_min = 0
	local range_max = 9999
	if self._options.range then
		local min = self._options.range.min
		if min then
			range_min = min
		end
		local max = self._options.range.max
		if max then
			range_max = max
		end
	end
	range_min = range_min * range_min * global.pixel_per_unit * global.pixel_per_unit
	range_max = range_max * range_max * global.pixel_per_unit * global.pixel_per_unit

	local target = actor:getTarget()

	local center = actor:getPosition()
	if self._options.center_as_target then
		if self._first_target_pos == nil then
			self:finished()
			return
		end
		center = self._first_target_pos
	end

	local enemies = app.battle:getMyEnemies(actor)
	local candidates = {}
	local target_as_candidate = nil
	local enemy_boss = nil
	for _, enemy in ipairs(enemies) do
        if not enemy:isDead() then
            local x = enemy:getPosition().x - center.x
            local y = enemy:getPosition().y - center.y
            local d = x * x + y * y * 4
            if d <= range_max and d >= range_min then
            	if enemy == target then
            		target_as_candidate = enemy
            	else
            		if app.battle:isInTutorial() and enemy:getActorID() == 50006 then
            			enemy_boss = enemy
            		else
	            		table.insert(candidates, enemy)
	            	end
            	end
            end
        end
	end

	if nil ~= enemy_boss then
		table.insert(candidates, enemy_boss)
	end

	if #candidates > 0 then
		actor:setTarget(candidates[app.random(1, #candidates)])
		-- actor:setTarget(candidates[1])
		if self._director:getTarget() == nil then
			self._director:setTarget(actor:getTarget())
		end
	elseif target_as_candidate then
	else
		if self._options.cancel_if_not_found then
			app.battle:performWithDelay(function()
				actor:_cancelCurrentSkill()
			end, 0)
		end
	end
end

function QSBKillingSpree:_onCancel()
	if self._options.reset_target_on_cancel then
		self._attacker:setTarget(self._director:getInitTarget())
    end
end

return QSBKillingSpree
