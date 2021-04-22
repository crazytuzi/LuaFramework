--[[
    冲锋技能第一阶段
--]]

local QSBAction = import(".QSBAction")
local QSBMoveToTarget = class("QSBMoveToTarget", QSBAction)

local MOVE_TIMEOUT = 0.7 -- 多少秒以后依然没有移动认为超时，该动作结束

function QSBMoveToTarget:_execute(dt)
	if self._target == nil then
		self:finished()
		return
	end

	if self._attacker:getTarget() ~= self._target then
        -- 过程中可能target挂了，此刻attacker中的target会被设置为nil
		self:finished()
        return
	end

	-- self._options.effect_id = "maidiwen_jufeng_2"
	-- self._options.effect_interval = 200

	if self._wp == nil then
		self._wp = {x = self._attacker:getPosition().x, y = self._attacker:getPosition().y}
	end

	if self:getOptions().is_position and self._first == nil then
		local actor = self._attacker
		local target = self._target
	--	app.grid:moveActorTo(actor, target:getPosition(), false)
		app.grid:moveActorToTarget(actor, target, false, not self._options.is_range)
    	self._first = true
    	self._attacker:lockDrag()
	end

	if self._attacker:isWalking() then
	    --当对象开始移动后，记录一个标志位
		self._moveStarted = true
		local curPos = self._attacker:getPosition()
		if self:getOptions().effect_id and self:getOptions().effect_interval then
			local effect_id = self:getOptions().effect_id
			local effect_interval = self:getOptions().effect_interval
			if q.distOf2PointsSquareWithYCoefficient(self._wp, curPos, 2) >= (effect_interval * effect_interval) then
				local options = {}
				options.attacker = self._attacker
				options.attackee = self._attackee
				options.targetPosition = clone(curPos)
				options.scale_actor_face = self._options.scale_actor_face
				options.ground_layer = true
				self._attacker:playSkillEffect(effect_id, nil, options)
				self._wp = {x = curPos.x, y = curPos.y}
			end
		end
	else
	    -- 如果此刻对象没有移动，则判断是否移动过，如果是，则停止冲锋
	    if self._moveStarted == true then
	        self:finished()
        elseif self._moveWaitFrom == nil then 
            -- 如果始终没有移动，则超时后停止冲锋
            self._moveWaitFrom = app.battle:getTime()
        elseif app.battle:getTime() - self._moveWaitFrom >= MOVE_TIMEOUT then
            self:finished()
        end
   end

end

function QSBMoveToTarget:_onCancel()
	if self._first == true then
		self._attacker:unlockDrag()
	end
end

function QSBMoveToTarget:finished()
	QSBMoveToTarget.super.finished(self)

	if self._first == true then
		self._attacker:unlockDrag()
	end
end

return QSBMoveToTarget
