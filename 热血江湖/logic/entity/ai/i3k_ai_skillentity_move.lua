----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_move_base").i3k_ai_move_base;
local AIBASE = require("logic/entity/ai/i3k_ai_move_base").i3k_ai_move_base;
local MODULE = require("logic/entity/ai/i3k_ai_base");
local BASE1 = MODULE.i3k_ai_base;

------------------------------------------------------
i3k_ai_skillentity_move = i3k_class("i3k_ai_skillentity_move", BASE);
function i3k_ai_skillentity_move:ctor(entity)
	self._type = eAType_SKILLENTITY_MOVE;
end

function i3k_ai_skillentity_move:IsValid()
	if not BASE1.IsValid(self) then return false; end

	local entity = self._entity;

	if entity._movePaths and #entity._movePaths > 0 then
		return true;
	end

	if entity:GetFollowTarget() then
		local target = entity:GetFollowTarget();
		if target then
			local dist = i3k_vec3_dist(entity._curPos, target._curPos)
			if dist < 300 then
				return false;
			end
		end
		return true;
	end
	
	return false;
end

function i3k_ai_skillentity_move:OnEnter()
	if BASE1.OnEnter(self) then
		local entity = self._entity;

		if self._syncRpc then
			self._syncTick = 500; -- first tick need sync
		end

		return self:StartMove();
	end

	return false;
end

function i3k_ai_skillentity_move:OnLeave()
	if BASE.OnLeave(self) then
		self:SetPos(self._movePos, true);

		local entity = self._entity
		--self._entity:StopMove();

		return true;
	end

	return false;
end

function i3k_ai_skillentity_move:OnUpdate(dTime)
	if not BASE.OnUpdate(self, dTime) then return false; end

	if not self._moveEnd then
		self._moveTime = i3k_integer(self._moveTime + dTime * 1000);
		if self._moveTime >= self._deltaTime then
			self._moveEnd 	= true;
			self._moveTime 	= self._deltaTime;
		end

		local cp = i3k_vec3_2_int(i3k_vec3_lerp(self._startPos, self._movePos, self._moveTime / self._deltaTime));
		self:SetPos(cp, false);
	end
end

function i3k_ai_skillentity_move:CalcMovePos()
	local entity = self._entity;

	local p1 = i3k_vec3_clone(self._startPos);
	local p2 = i3k_vec3_clone(self._targetPos);

	local target = entity:GetFollowTarget();
	if target and not target:IsDead() then
		local p3 = i3k_vec3_clone(target._curPos);

		if i3k_vec3_dist(p2, p3) >= 200 then
			self:StartMove();

			local rot_y = i3k_vec3_angle1(self._targetPos, p1, { x = 1, y = 0, z = 0 });
			--entity:StartTurnTo({ x = 0, y = rot_y, z = 0 });

			return true;
		end
	end

	if i3k_vec3_dist(p1, p2) <= 50 then
		self:SetPos(p2, true);

		local paths = entity._movePaths;
		if paths and #paths > 0 then
			self._targetPos = i3k_vec3_clone(paths[1]);

			local rot_y = i3k_vec3_angle1(self._targetPos, p1, { x = 1, y = 0, z = 0 });
			--entity:StartTurnTo({ x = 0, y = rot_y, z = 0 });

			table.remove(paths, 1);

			return true;
		end

		return false;
	end

	return true;
end

function i3k_ai_skillentity_move:OnLogic(dTick)
	if not BASE.OnLogic(self, dTick) then return false; end

	local entity = self._entity;
	local target = entity:GetFollowTarget();
	if target then
		local dist = i3k_vec3_dist(entity._curPos, target._curPos)
		if dist < 300 then
			return false;
		end
	end
	self:SetPos(self._movePos, true);
	--i3k_log("setpos1:"..self._movePos.x.."|"..self._movePos.z)
	if not self:CalcMovePos() then
		--entity:StopMove();

		return false;
	end

	local p1 = i3k_vec3_clone(self._startPos);
	local p2 = i3k_vec3_clone(self._targetPos);

	self._deltaTime	= dTick * i3k_db_common.engine.tickStep;
	self._moveTime	= 0;
	self._moveEnd	= true;
	self._moveDir	= i3k_vec3_normalize1(i3k_vec3_sub1(p2, p1));

	if i3k_vec3_len(i3k_vec3_sub1(p1, p2)) > 5 then
		self._moveEnd = false;

		local speed	= entity:GetPropertyValue(ePropID_speed) / 1000;
		self._movePos = i3k_vec3_2_int(i3k_vec3_add1(p1, i3k_vec3_mul2(self._moveDir, speed * self._deltaTime)));

		-- move x dir
		if self._moveDir.x > 0 then
			if self._movePos.x > p2.x then self._movePos.x = p2.x; end
		else
			if self._movePos.x < p2.x then self._movePos.x = p2.x; end
		end

		-- move y dir
		if self._moveDir.y > 0 then
			if self._movePos.y > p2.y then self._movePos.y = p2.y; end
		else
			if self._movePos.y < p2.y then self._movePos.y = p2.y; end
		end

		-- move z dir
		if self._moveDir.z > 0 then
			if self._movePos.z > p2.z then self._movePos.z = p2.z; end
		else
			if self._movePos.z < p2.z then self._movePos.z = p2.z; end
		end
	else
		--entity:StopMove();

		return false;
	end

	return true;
end

function i3k_ai_skillentity_move:SetPos(pos, real)
	local entity = self._entity;
	if entity then
		entity:SetPos(pos, real);
	end

	if real then
		self._startPos = pos;
	end
end

function i3k_ai_skillentity_move:StartMove()
	local entity = self._entity;

	local target = entity:GetFollowTarget();
	if target then
		local posE = i3k_vec3_clone(target._curPosE);

		local findCnt = 0;
		while true do
			local _pos = i3k_vec3_clone(posE);
				_pos.x = posE.x  ;
				_pos.y = posE.y + 1;
				_pos.z = posE.z ;
			_pos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(_pos));

			local paths = g_i3k_mmengine:FindPath(entity._curPosE, i3k_vec3_to_engine(_pos));
			if paths:size() > 0 then
				posE = paths:front();

				break;
			end

			findCnt = findCnt + 1;
			if findCnt > 5 then
				break;
			end
		end

		local movePaths = { };
		table.insert(movePaths, i3k_world_pos_to_logic_pos(posE));

		entity:MovePaths(movePaths, true);

		self._deltaTime = 0;
		self._startPos	= entity._curPos;
		self._targetPos	= i3k_world_pos_to_logic_pos(posE);
		self._movePaths	= entity._movePaths;
		self._moveTime	= 0;
		self._moveEnd	= true;
		self._movePos	= self._startPos;
		self._moveDir	= { x = 0, y = 0, z = 0 };

		--local rot_y = i3k_vec3_angle1(self._targetPos, entity._curPos, { x = 1, y = 0, z = 0 });
		--entity:StartTurnTo({ x = 0, y = rot_y, z = 0 });

		return true;
	end

	self._deltaTime	= 0;
	self._startPos	= entity._curPos;
	self._targetPos = self._startPos;
	self._movePaths = entity._movePaths;
	self._moveTime	= 0;
	self._moveEnd	= true;
	self._movePos	= self._startPos;
	self._moveDir	= { x = 0, y = 0, z = 0 };

	return true;
end

function create_component(entity, priority)
	return i3k_ai_skillentity_move.new(entity, priority);
end

