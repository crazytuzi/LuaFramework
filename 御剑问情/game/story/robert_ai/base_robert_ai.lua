BaseRobertAi = BaseRobertAi or BaseClass()

function BaseRobertAi:__init(robert)
	self.robert = robert
	self.atk_target = nil
end

function BaseRobertAi:__delete()
	self.robert = nil
	self.atk_target = nil
end

function BaseRobertAi:SetAtkTarget(atk_target)
	self.atk_target = atk_target
end

function BaseRobertAi:GetAtkTarget()
	return self.atk_target
end

function BaseRobertAi:Update(now_time, elapse_time)
	if nil == self.atk_target then
		return
	end

	if self.robert:IsDead() or self.atk_target:IsDead() then
		self.atk_target = nil
		return
	end

	if self.robert:IsSkillReading() then
		return
	end

	if not self:IsInAttackRange(self.atk_target, self.robert:GetAtkRange()) then
		self:MoveToTarget(self.atk_target, self.robert:GetAtkRange() - 2)
		return
	end

	self.robert:DoAttackObj(self.atk_target)
end

function BaseRobertAi:MoveToTarget(atk_target, distance)
	if self.robert:IsAtkPlaying() or self.robert:IsDead() then
		return
	end

	local p1x, p1y = self.robert:GetLogicPos()
	local p2x, p2y = atk_target:GetLogicPos()

	local distance = math.max(GameMath.GetDistance(p1x, p1y, p2x, p2y, true) - distance, 0)

	if distance > 0 then
		local p1 = u3d.vec2(p1x, p1y)
		local p2 = u3d.vec2(p2x, p2y)
		
		local delta_pos = u3d.v2Sub(p2, p1)
		local move_dir = u3d.v2Normalize(delta_pos)
		move_dir = u3d.v2Mul(move_dir, distance)

		if 0 == move_dir.x and 0 == move_dir.y then
			return
		end

		self.robert:DoMove(p1x + move_dir.x, p1y + move_dir.y)
	end
end

function BaseRobertAi:IsInAttackRange(atk_target, atk_range)
	if nil == atk_target then
		return false
	end

	local p1x, p1y = self.robert:GetLogicPos()
	local p2x, p2y = atk_target:GetLogicPos()

	return GameMath.GetDistance(p1x, p1y, p2x, p2y, false) <= atk_range * atk_range
end

