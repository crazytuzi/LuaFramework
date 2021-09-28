----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_shift = i3k_class("i3k_ai_shift", BASE);
function i3k_ai_shift:ctor(entity)
	self._type = eAType_SHIFT;
end

function i3k_ai_shift:IsValid()
	if not BASE.IsValid(self) then return false; end

	return self._entity._behavior:Test(eEBShift);
end

function i3k_ai_shift:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;

		if not entity._shiftInfo then
			return false;
		end

		if entity:IsPlayer() and entity:GetAgent() then
			entity:ReleaseAgent();
		end

		self._shiftInfo		= entity._shiftInfo;
		self._validPos		= false;
		self._reachMiddle	= false;

		if self._shiftInfo.endPos then
			self._validPos	= true;
			self._deltaTime = 0;
			self._startPos	= entity._curPosE;
			self._targetPos	= self._shiftInfo.endPos;
			self._middlePos	= i3k_vec3_div2(i3k_vec3_add1(self._startPos, self._targetPos), 2);
			self._middlePos.y = self._middlePos.y + (self._shiftInfo.height / 100);
			self._moveTime	= 0;
			self._moveEnd	= true;
			self._movePos	= self._startPos;
			self._moveDir	= { x = 0, y = 0, z = 0 };
		else
			local dir	= self._shiftInfo.dir;
			local dist	= self._shiftInfo.info.distance / 100;

			local pos = i3k_vec3_add1(entity._curPosE, i3k_vec3_mul2(dir, dist));

			local moveInfo = i3k_engine_trace_line_ex(entity._curPosE, pos);
			if moveInfo.valid then
				self._validPos	= true;
				self._deltaTime = 0;
				self._startPos	= entity._curPosE;
				self._targetPos = i3k_logic_pos_to_world_pos(moveInfo.path);

				self._middlePos	= i3k_vec3_div2(i3k_vec3_add1(self._startPos, self._targetPos), 2);
				self._middlePos.y = self._middlePos.y + (self._shiftInfo.height / 100);

				self._moveTime	= 0;
				self._moveEnd	= true;
				self._movePos	= self._startPos;
				self._moveDir	= { x = 0, y = 0, z = 0 };

				return true;
			end
		end
		
		return true;
	end

	return false;
end

function i3k_ai_shift:OnLeave()
	if BASE.OnLeave(self) then
		local entity = self._entity;
		if entity:IsPlayer() and not entity:GetAgent() then
			entity:CreateAgent();
		end
		entity:OnStopShift();
		--i3k_log("i3k_ai_shift:OnLeave():")
		return true;
	end

	return false;
end

function i3k_ai_shift:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) and self._validPos then
		if not self._moveEnd then
			self._moveTime = i3k_integer(self._moveTime + dTime * 1000);
			if self._moveTime >= self._deltaTime then
				self._moveEnd 	= true;
				self._moveTime 	= self._deltaTime;
			end

			local cp = i3k_vec3_2_int(i3k_vec3_lerp(self._startPos, self._movePos, self._moveTime / self._deltaTime));
			self:SetPos(cp, false);
		end

		return true;
	end

	return false;
end

function i3k_ai_shift:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) and self._validPos then
		if dTick > 0 then
			local entity = self._entity;

			-- 同步上一逻辑帧位置
			self:SetPos(self._movePos, true);

			self._deltaTime	= dTick * i3k_db_common.engine.tickStep;
			self._moveTime	= 0;
			self._moveEnd	= true;

			local speed = self._shiftInfo.info.velocity / 100 / i3k_db_common.engine.tickStep
			if i3k_vec3_len(i3k_vec3_sub1(self._startPos, self._targetPos)) > speed or not self._reachMiddle then
				self._moveEnd = false;
				
				local fpos = self:CalcMoveInfo2();

				-- move x dir
				if self._moveDir.x > 0 then
					if self._movePos.x > fpos.x then self._movePos.x = fpos.x; end
				else
					if self._movePos.x < fpos.x then self._movePos.x = fpos.x; end
				end

				-- move y dir
				if self._moveDir.y > 0 then
					if self._movePos.y > fpos.y then self._movePos.y = fpos.y; end
				else
					if self._movePos.y < fpos.y then self._movePos.y = fpos.y; end
				end

				-- move z dir
				if self._moveDir.z > 0 then
					if self._movePos.z > fpos.z then self._movePos.z = fpos.z; end
				else
					if self._movePos.z < fpos.z then self._movePos.z = fpos.z; end
				end
			else
				return false;
			end
		end

		return true;
	end

	return false;
end

function i3k_ai_shift:CalcMoveInfo1()
	local p1 = i3k_vec3_clone(self._startPos);
	local p2 = i3k_vec3_clone(self._targetPos);
	self._moveDir = i3k_vec3_normalize1(i3k_vec3_sub1(p2, p1));

	local speed	= self._shiftInfo.info.velocity / 1000;
	self._movePos = i3k_vec3_2_int(i3k_vec3_add1(p1, i3k_vec3_mul2(self._moveDir, speed * self._deltaTime)));

	return p2;
end

function i3k_ai_shift:CalcMoveInfo2()
	local p1 = self._startPos;
	local p2 = self._targetPos;
	local p3 = self._middlePos;

	local p4 = p1;
	local p5 = p3;

	if not self._reachMiddle then
		local speed = self._shiftInfo.info.velocity / 100 / i3k_db_common.engine.tickStep
		if i3k_vec3_len(i3k_vec3_sub1(p4, p5)) < speed then
			self._reachMiddle = true;
		end
	end

	self._moveDir = i3k_vec3_normalize1(i3k_vec3_sub1(p3, p1));
	if self._reachMiddle then
		self._moveDir = i3k_vec3_normalize1(i3k_vec3_sub1(p2, p1));
	end

	local speed	= self._shiftInfo.info.velocity / 100;
	self._movePos = i3k_vec3_2_int(i3k_vec3_add1(p1, i3k_vec3_mul2(self._moveDir, speed * self._deltaTime)));

	if self._reachMiddle then
		return p2;
	end

	return p3;
end

function i3k_ai_shift:SetPos(pos, real)
	local entity = self._entity;
	if entity then
		entity:UpdateWorldPos(i3k_vec3_to_engine(pos));
	end

	if real then
		self._startPos = pos;
	end
end

function create_component(entity, priority)
	return i3k_ai_shift.new(entity, priority);
end

