----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_move_base").i3k_ai_move_base;
local MODULE = require("logic/entity/ai/i3k_ai_base");
local BASE1 = MODULE.i3k_ai_base;

------------------------------------------------------
i3k_ai_network_auto_move = i3k_class("i3k_ai_network_auto_move", BASE);
function i3k_ai_network_auto_move:ctor(entity)
	self._type = eAType_NETWORK_MOVE;
end

function i3k_ai_network_auto_move:IsValid()
	if not BASE1.IsValid(self) then return false; end

	local entity = self._entity;

	if entity:IsDead() then
		return false;
	end

	if entity._behavior:Test(eEBMove) then
		return true;
	end

	if entity._velocity then
		return true;
	end

	if entity:GetTargetPos() then
		return true;
	end

	return false;
end

function i3k_ai_network_auto_move:OnEnter()
	if BASE1.OnEnter(self) then
		local entity = self._entity;

		if not self:TryMove() then
			return false;
		end

		if self._type == eMoveByVelocity then
			self._deltaTime = 0;
			self._startPos	= entity._curPos;
			self._moveTime	= 0;
			self._moveEnd	= true;
			self._moveDir	= entity._velocity;
			self._movePos	= self._startPos;

			local r = i3k_vec3_angle2(self._moveDir, i3k_vec3(1, 0, 0));
			--entity:SetFaceDir(0, r, 0);

			return true;
		elseif self._type == eMoveByTarget then
			self._deltaTime = 0;
			self._startPos	= entity._curPos;
			self._targetPos	= entity:GetTargetPos();
			self._moveTime	= 0;
			self._moveEnd	= true;
			self._moveDir	= { x = 0, y = 0, z = 0 };
			self._movePos	= self._startPos;
			local rotation  = i3k_vec3_normalize1(i3k_vec3_sub1(self._targetPos, self._startPos));

			local r = i3k_vec3_angle2(i3k_vec3(rotation.x,rotation.y,rotation.z), i3k_vec3(1, 0, 0));
			--entity:SetFaceDir(0, r, 0);

			return true;
		end
	end

	return false;
end

function i3k_ai_network_auto_move:OnLeave()
	if BASE.OnLeave(self) then
		--self._entity:SetPos(self._targetPos, true);
		--i3k_log("i3k_ai_network_auto_move:Leave ");
		self._entity:StopMove();

		return true;
	end

	return false;
end

function i3k_ai_network_auto_move:OnUpdate(dTime)
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

function i3k_ai_network_auto_move:OnLogic(dTick)
	if not BASE.OnLogic(self, dTick) then return false; end

	if dTick > 0 then
		self:SetPos(self._movePos, true);

		if not self:TryMove() then
			return false;
		end

		if self._type == eMoveByVelocity then
			return self:MoveByVelocity(dTick);
		elseif self._type == eMoveByTarget then
			return self:MoveByTarget(dTick);
		end
	else
		return true;
	end

	return false;
end

function i3k_ai_network_auto_move:TryMove()
	local entity = self._entity;

	entity:TryMove();

	if entity._velocity then
		self._type	= eMoveByVelocity;

		return true;
	elseif entity:GetTargetPos() then
		self._type	= eMoveByTarget;

		return true;
	end

	return false;
end

function i3k_ai_network_auto_move:MoveByVelocity(dTick)
	local entity = self._entity;

	self._deltaTime	= dTick * i3k_db_common.engine.tickStep;
	self._moveTime	= 0;
	self._moveEnd	= false;
	if self._moveDir.x ~= entity._velocity.x or self._moveDir.z ~= entity._velocity.z then
		self._moveDir	= entity._velocity;

		local r = i3k_vec3_angle2(self._moveDir, i3k_vec3(1, 0, 0));
		--entity:SetFaceDir(0, r, 0);
	end
	
	local speed	= entity:GetPropertyValue(ePropID_speed) / 1000;
	if speed < 0.2 then
		return false;
	end

	self._movePos = i3k_vec3_2_int(i3k_vec3_add1(self._startPos, i3k_vec3_mul2(self._moveDir, speed * self._deltaTime)));

	return true;
end

function i3k_ai_network_auto_move:MoveByTarget(dTick)
	local entity = self._entity;

	local p1 = i3k_vec3_clone(self._startPos);
	local p2 = i3k_vec3_clone(entity:GetTargetPos());

	if p1.x ~= p2.x or p1.z ~=p2.z then 
		local rotation  = i3k_vec3_normalize1(i3k_vec3_sub1(p2,p1));
		local r = i3k_vec3_angle2(i3k_vec3(rotation.x,rotation.y,rotation.z), i3k_vec3(1, 0, 0));

		--entity:SetFaceDir(0, r, 0);
	end

	self._deltaTime	= dTick * i3k_db_common.engine.tickStep;
	self._moveTime	= 0;
	self._moveEnd	= true;
	self._moveDir	= i3k_vec3_normalize1(i3k_vec3_sub1(p2, p1));
	--i3k_log("MoveByTarget:entity"..self._entity._guid.."#"..entity:GetTargetPos().x.."#"..entity:GetTargetPos().y.."#"..entity:GetTargetPos().z.."|"..entity._curPos.x.."|"..entity._curPos.y.."|"..entity._curPos.z.."@@speed"..entity:GetPropertyValue(ePropID_speed))
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
		if not entity._preMove then
			entity:SetPos(entity:GetTargetPos(), true);
			entity:StopMove();

			return false;
		end

		if entity._startPos == entity._targetPos then
			entity:SetPos(entity:GetTargetPos(), true);
			entity:StopMove();

			return false;
		end
	end

	return true;
end

function i3k_ai_network_auto_move:SetPos(pos, real)
	local entity = self._entity;
	if entity then
		entity:SetPos(pos, real);
	end

	if real then
		self._startPos = pos;
	end
end

function create_component(entity, priority)
	return i3k_ai_network_auto_move.new(entity, priority);
end

