--[[
    Class name QSBShuttle
    Create by julian 
--]]
local QSBAction = import(".QSBAction")
local QSBShuttle = class("QSBShuttle", QSBAction)

local QBaseEffectView
if not IsServerSide then
	QBaseEffectView = import("...views.QBaseEffectView")
end

local _SHUTTLE_FRAME_COUNT = 3
local _SHUTTLE_SHADE_COUNT = 2
local _SHUTTLE_SHADE_INTERVAL_FRAME = 1
local PI = 3.1415926

local SHUTTLE_FRAME_COUNT
local SHUTTLE_SHADE_COUNT
local SHUTTLE_SHADE_INTERVAL_FRAME

function QSBShuttle:_restoreParams()
	local options = self:getOptions()
	SHUTTLE_FRAME_COUNT = options.shuttle_frame_count or _SHUTTLE_FRAME_COUNT
	SHUTTLE_SHADE_COUNT = options.shuttle_shade_count or _SHUTTLE_SHADE_COUNT
	SHUTTLE_SHADE_INTERVAL_FRAME = options.shuttle_shade_interval_frame or _SHUTTLE_SHADE_INTERVAL_FRAME
end

function QSBShuttle:_createPoseEffect(actor, effect_id)
	if effect_id then
		local frontEffect, backEffect = QBaseEffectView.createEffectByID(effect_id)
		local effect = frontEffect or backEffect
		effect:setPosition(actor:getPosition().x, actor:getPosition().y)
		effect:getSkeletonView():setScaleX(math.xor((self._shuttle_distance_x < 0), self._options.is_flip_x) and 1 or -1)
		local rotation = self._options.rotation
		if rotation then
			effect:setRotation(effect:getSkeletonView():getScaleX() == 1 and rotation or -rotation)
		end
		return effect
	elseif actor then
		local node = display.newNode()
		local actorView = app.scene:getActorViewFromModel(actor)
        actorView:setScissorRects(
            CCRect(0, 0, 0, 0),
            CCRect(0, 0, 0, 0),
            CCRect(0, 0, 0, 0),
            CCRect(0, 0, 0, 0)
        )
		actorView:setScissorEnabled(true)
        local tex = tolua.cast(actorView:getSkeletonActor():getRenderTextureSprite(), "CCSprite"):getTexture()
        local rail = CCSprite:createWithTexture(tex)
		rail:setScaleX(math.xor((self._shuttle_distance_x < 0), self._options.is_flip_x) and 1 or -1)
        rail:setRotation(180)
        node:addChild(rail)
        node:setPosition(actor:getPosition().x, actor:getPosition().y)
		node:setScaleX(math.xor((self._shuttle_distance_x < 0), self._options.is_flip_x) and 1 or -1)
		local rotation = self._options.rotation
		if rotation then
			node:setRotation(node:getScaleX() == 1 and rotation or -rotation)
		end
		-- no animation at all
		function node:playAnimation() end
		function node:stopAnimation() end

        return node
	end
end

function QSBShuttle:_execute(dt)
	self:_restoreParams()

	if not self._done_select_target then
		self:_selectTarget()
		self._done_select_target = true
	elseif not self._done_teleport then
		if self:getOptions().pos then
			self:_teleport2(self:getOptions().pos)
		else
			self:_teleport()
		end
		self._done_teleport = true
	elseif not self._done_shuttle then
		self._done_shuttle = self:_shuttle()
	else
		self:finished()
	end
end

function QSBShuttle:_shuttle()
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
		if self._options.pos then
			if math.abs(self._shuttle_distance_x) >= 5 and math.xor(self._shuttle_distance_x > 0, actor:isFlipX()) then
				actor:_setFlipX()
			end
		else
			if math.xor(self._shuttle_distance_x > 0, actor:getDirection() == actor.DIRECTION_LEFT) then
				actor:_setFlipX()
			end
		end
		self._shuttle_inited = true
		-- 初始化pose特效
		if not IsServerSide then
			local effect = self:_createPoseEffect(actor, self._options.effect_id)
		    app.scene:addEffectViews(effect, {isFrontEffect = false})
	    	effect:playAnimation(effect:getPlayAnimationName(), true)
	    	self._shuttle_effect = effect
	    	self._shuttle_shade_effects = {}
	    end
    else
		self._shuttle_frame = self._shuttle_frame + 1
	end

	if self._shuttle_frame <= (self._options.last_one and SHUTTLE_FRAME_COUNT * 3 or SHUTTLE_FRAME_COUNT) + SHUTTLE_SHADE_COUNT * SHUTTLE_SHADE_INTERVAL_FRAME then
		-- 初始化拖影特效
		local position = clone(actor:getPosition())
		local t = (self._shuttle_frame) / ((self._options.last_one and SHUTTLE_FRAME_COUNT * 3 or SHUTTLE_FRAME_COUNT))
		t = math.min(t, 1)
		t = t^(4.0)
		position.x = self._shuttle_start_x + self._shuttle_distance_x * t
		position.y = self._shuttle_start_y + self._shuttle_distance_y * t
		app.grid:moveActorTo(actor, position, true, true, true)
		if not IsServerSide then
			local shuttle_shade_effects = self._shuttle_shade_effects
			while #shuttle_shade_effects < SHUTTLE_SHADE_COUNT do
				if self._shuttle_frame == 1 + (#shuttle_shade_effects + 1) * SHUTTLE_SHADE_INTERVAL_FRAME then
					local effect = self:_createPoseEffect(actor, self._options.effect_id)
					effect:setPositionY(effect:getPositionY() + 0.5)
				    app.scene:addEffectViews(effect, {isFrontEffect = false})
			    	effect:playAnimation(effect:getPlayAnimationName(), true)
			    	makeNodeOpacity(effect, 128)
			    	table.insert(shuttle_shade_effects, effect)
				else
					break
				end
			end
			self._shuttle_effect:setPosition(position.x, position.y)
			for index, effect in ipairs(shuttle_shade_effects) do
				local position = clone(actor:getPosition())
				local t = (self._shuttle_frame - index * SHUTTLE_SHADE_INTERVAL_FRAME) / ((self._options.last_one and SHUTTLE_FRAME_COUNT * 3 or SHUTTLE_FRAME_COUNT))
				t = math.min(t, 1)
				t = t^(4.0)
				position.x = self._shuttle_start_x + self._shuttle_distance_x * t
				position.y = self._shuttle_start_y + self._shuttle_distance_y * t + 0.5
				effect:setPosition(position.x, position.y)
			end
		end
		return false
	else
		self:_clearEffects()
		return true
	end
end

function QSBShuttle:_teleport2(teleport_pos)
	local actor = self._attacker
	local pos = actor:getPosition()
	self._shuttle_start_x = pos.x
	self._shuttle_start_y = pos.y
	self._shuttle_distance_x = teleport_pos.x - pos.x
	self._shuttle_distance_y = teleport_pos.y - pos.y
	if math.abs(self._shuttle_distance_x) < 5 and math.abs(self._shuttle_distance_y) < 5 then
		self:finished()
		return
	end
end

function QSBShuttle:_teleport()
	local in_range = self._options.in_range

	local actor = self._attacker
	local target = actor:getTarget()

	if not target then
		self:finished()
		return
	end

	local director = self._director
	if self._director._killing_spree_direction == nil then
		if self._options.front_to_back then
			self._director._killing_spree_direction = target:isFlipX() and "left" or "right"
		else
			self._director._killing_spree_direction = (actor:getPosition().x < target:getPosition().x) and "right" or "left"
		end
	end

	local direction = self._director._killing_spree_direction
	local pos = clone(target:getPosition())
	local end_pos = clone(target:getPosition())
    local distance = (actor:getRect().size.width + target:getRect().size.width) / 2 * 1.5
	if direction == "right" then
		pos.x = pos.x - distance
		end_pos.x = end_pos.x + distance
	else
		pos.x = pos.x + distance
		end_pos.x = end_pos.x - distance
	end
	local rotation = self._options.rotation
	if rotation then
		pos.y = pos.y + math.tan(rotation / 180 * PI) * distance
		end_pos.y = end_pos.y - math.tan(rotation / 180 * PI) * distance

		self._effect_rotation = rotation
	end
	local isOutOfRange, gridPos = app.grid:_toGridPos(end_pos.x, end_pos.y)
	app.grid:setActorTo(actor, pos, true, true)
	self._shuttle_start_x = pos.x
	self._shuttle_start_y = pos.y
	self._shuttle_distance_x = (actor:getTarget():getPosition().x - actor:getPosition().x) * 2
	self._shuttle_distance_y = (actor:getTarget():getPosition().y - actor:getPosition().y) * 2
	if self._options.switch_direction then
		self._director._killing_spree_direction = self._director._killing_spree_direction == "left" and "right" or "left"
	end
end

function QSBShuttle:_selectTarget()
	local actor = self._attacker

	if self._options.original_target then
		local target = self._director:getTarget()
		if target and not target:isDead() then
			actor:setTarget(target)
			return
		end
	end

	if not self._options.always and (actor:getTarget() and not actor:getTarget():isDead()) then
		return
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
	local enemies = app.battle:getMyEnemies(actor)
	local candidates = {}
	local target_as_candidate = nil
	for _, enemy in ipairs(enemies) do
        if not enemy:isDead() then
            local x = enemy:getPosition().x - actor:getPosition().x
            local y = enemy:getPosition().y - actor:getPosition().y
            local d = x * x + y * y * 4
            if d <= range_max and d >= range_min then
            	if enemy == target then
            		target_as_candidate = enemy
            	else
            		table.insert(candidates, enemy)
            	end
            end
        end
	end

	if #candidates > 0 then
		actor:setTarget(candidates[app.random(1, #candidates)])
		if self._director:getTarget() == nil then
			self._director:setTarget(actor:getTarget())
		end
	elseif target_as_candidate then
	else
		if self._options.cancel_if_not_found then
			self:finished({exit = true})
		end
	end
end

function QSBShuttle:_onCancel()
	self:_clearEffects()
end

function QSBShuttle:_onRevert()
	self:_clearEffects()
end

function QSBShuttle:finished()
	self:_clearEffects()
	if self:getOptions().pos then
		self._attacker:_verifyFlip()
	end

	QSBShuttle.super.finished(self)
end

function QSBShuttle:_clearEffects()
	if not IsServerSide then
		if self._shuttle_effect then
			self._shuttle_effect:stopAnimation()
			self._shuttle_effect:setVisible(false)
			app.scene:removeEffectViews(self._shuttle_effect)
			for index, effect in ipairs(self._shuttle_shade_effects) do
				effect:stopAnimation()
				effect:setVisible(false)
				app.scene:removeEffectViews(effect)
			end
			self._shuttle_effect = nil
			self._shuttle_shade_effects = {}
		end
	end
end

return QSBShuttle
