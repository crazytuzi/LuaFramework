----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_rush = i3k_class("i3k_ai_rush", BASE);
function i3k_ai_rush:ctor(entity)
	self._type = eAType_RUSH;
end

function i3k_ai_rush:IsValid()
	if not BASE.IsValid(self) then return false; end

	return self._entity._behavior:Test(eEBRush);
end

function i3k_ai_rush:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;

		if not entity._rushInfo then
			return false;
		end

		self._rushInfo = entity._rushInfo;
		self._validPos	= false;
		self._reachMiddle = false;
		local dir	= self._rushInfo.dir;
		local dist	= self._rushInfo.info.distance;

		for k = 1, 10 do
			local pos = i3k_vec3_add1(entity._curPos, i3k_vec3_mul2(dir, dist - (dist / 10) * (k - 1)));

			local paths = g_i3k_mmengine:FindPath(entity._curPosE, i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos)));
			if paths:size() > 0 then
				self._validPos	= true;
				self._deltaTime = 0;
				self._startPos	= entity._curPos;
				self._targetPos = i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(paths:front()));
				self._middlePos	= i3k_vec3_div2(i3k_vec3_add1(self._startPos, self._targetPos), 2);
				if self._rushInfo.type == 2 then
					self._middlePos.y = self._middlePos.y + self._rushInfo.height;
				end
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

function i3k_ai_rush:OnLeave()
	if BASE.OnLeave(self) then
		self._entity:OnStopRush();
		self._entity:SetPos(self._movePos, true);
		return true;
	end

	return false;
end

function i3k_ai_rush:OnUpdate(dTime)
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

function i3k_ai_rush:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) and self._validPos then
		if dTick > 0 then
			local entity = self._entity;

			-- 同步上一逻辑帧位置
			self:SetPos(self._movePos, true);

			self._deltaTime	= dTick * i3k_db_common.engine.tickStep;
			self._moveTime	= 0;
			self._moveEnd	= true;

			if i3k_vec3_len(i3k_vec3_sub1(self._startPos, self._targetPos)) > 5 then
				self._moveEnd = false;

				local fpos;
				if self._rushInfo.type == 1 then
					fpos = self:CalcMoveInfo1();
				elseif self._rushInfo.type == 2 then
					fpos = self:CalcMoveInfo2();
				else
					return false;
				end
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

function i3k_ai_rush:CalcMoveInfo1()
	local p1 = i3k_vec3_clone(self._startPos);
	local p2 = i3k_vec3_clone(self._targetPos);
	self._moveDir = i3k_vec3_normalize1(i3k_vec3_sub1(p2, p1));

	local speed	= self._rushInfo.info.velocity / 1000;
	self._movePos = i3k_vec3_2_int(i3k_vec3_add1(p1, i3k_vec3_mul2(self._moveDir, speed * self._deltaTime)));

	return p2;
end

function i3k_ai_rush:CalcMoveInfo2()
	local p1 = i3k_vec3_clone(self._startPos);
	local p2 = i3k_vec3_clone(self._targetPos);
	local p3 = i3k_vec3_clone(self._middlePos);

	local p4 = i3k_vec3_clone(p1);
	p4.y = 0;
	local p5 = i3k_vec3_clone(p3);
	p5.y = 0;

	if not self._reachMiddle then
		if i3k_vec3_len(i3k_vec3_sub1(p4, p5)) < 5 then
			self._reachMiddle = true;
		end
	end

	self._moveDir = i3k_vec3_normalize1(i3k_vec3_sub1(p3, p1));
	if self._reachMiddle then
		self._moveDir = i3k_vec3_normalize1(i3k_vec3_sub1(p2, p1));
	end

	local speed	= self._rushInfo.info.velocity / 1000;
	self._movePos = i3k_vec3_2_int(i3k_vec3_add1(p1, i3k_vec3_mul2(self._moveDir, speed * self._deltaTime)));

	if self._reachMiddle then
		return p2;
	end

	return p3;
end

function i3k_ai_rush:SetPos(pos, real)
	local entity = self._entity;
	if entity then
		entity:SetPos(pos, real);
	end

	if real then
		self._startPos = pos;
	end
end

function create_component(entity, priority)
	return i3k_ai_rush.new(entity, priority);
end

