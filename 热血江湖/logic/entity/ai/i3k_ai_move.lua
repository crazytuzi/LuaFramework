----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_move_base").i3k_ai_move_base;


------------------------------------------------------
i3k_ai_move = i3k_class("i3k_ai_move", BASE);
function i3k_ai_move:ctor(entity)
	self._type		= eAType_MOVE;
	self._syncTick	= 0;
	self._prePos	= i3k_vec3();
	self._curPos 	= nil;
	self._checkTick	= 0;
end

function i3k_ai_move:IsValid()
	if not BASE.IsValid(self) then return false; end

	local entity = self._entity;
	if not entity:GetAgent() then
		return false;
	end

	if entity:GetEntityType() == eET_Player and entity._DigStatus == 2 then
		return false;
	end

	if entity._target and not entity._target:IsPlayer() then
		if entity._target._behavior:Test(eEBInvisible) then
			return false;
		end
	end

	if entity._target and not entity._target:IsDead() then
		return true;
	end

	if entity._behavior:Test(eEBMove) then
		return true;
	end

	if entity._velocity then
		return true;
	end

	if entity._targetPos then
		return true;
	end

	if entity._fearPos then
		return true;
	end

	return false;
end

function i3k_ai_move:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;

		if entity._target then
			entity:Follow(entity._target, false);
		end

		self._moveTime	=  0;
		self._moveFrame	= -1;
		self._syncTick	= 0;
		self._checkTick	= 0;
		self._prePos	= entity._curPosE;
		self._curPos 	= self._prePos

		self._valid = self:TryMove();
		if self._valid then
			self._startPos	= entity._curPosE;
			self._moveDir	= i3k_vec3_normalize1(i3k_vec3_sub1(self._targetPos, self._startPos));
			if self._syncRpc then
				self._syncTick = 0;

				-- send cmd
				local args = { pos = i3k_vec3_2_int(entity._curPos), target = i3k_world_pos_to_logic_pos(self._targetPos), speed = self._speed, rotation = self._moveDir };
				local isCanSend = i3k_role_move_scope(args.pos, args.target, args.speed);
				if self._entityType ~= eET_Ghost and isCanSend then
					i3k_sbean.sync_map_move(entity, args);
				end
			end

			return true;
		end
	end

	return false;
end

function i3k_ai_move:OnLeave()
	if BASE.OnLeave(self) then
		local entity = self._entity;

		if self._valid then
			local state = g_i3k_game_context:GetMoveState()
			if not state then
				local isCanSend = i3k_role_stop_move_scope(entity._curPos);
				if self._syncRpc and self._entityType ~= eET_Ghost and isCanSend then
					i3k_sbean.sync_map_stopmove(entity, entity._curPos);
				end
			end
		end
		entity:StopMove();

		return true;
	end

	return false;
end

function i3k_ai_move:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		local entity = self._entity;

		self:TryMove();

		if self._startMove then
			if entity:IsPathPending() then
				--g_i3k_game_handler:UpdatePathEngine(dTime);

				if entity:CalcMoveInfo() then
					self._startMove = true;
					self._moveTime	= 0;
					self._moveFrame	= 0;
					self._speed		= i3k_world_val_to_logic_val(entity._motionData.mSpeed);
					self._targetPos = entity._motionData.mPaths[entity._motionData.mTicks];

					self._startPos	= entity._curPosE;
					self._moveDir	= i3k_vec3_normalize1(i3k_vec3_sub1(self._targetPos, self._startPos));

					local dir = entity._motionData:GetFaceDir(0);
					entity:SetFaceDir(dir.x, dir.y, dir.z);
				end
			else
				self._moveTime = self._moveTime + dTime;
			end

			if not entity:IsPathPending() then
				local pos = self:CalcMovePos(0);
				if pos then
					self:SetPos(pos);
				end
			end
		end

		return true;
	end

	return false;
end

function i3k_ai_move:OnLogic(dTick)
	if not BASE.OnLogic(self, dTick) then return false; end

	local entity = self._entity;

	if not self._startMove then return false; end
	if dTick > 0 then
		if self._syncRpc then
			self._syncTick = self._syncTick + dTick * i3k_engine_get_tick_step();
			if self._syncTick > g_syncTick then
				self._syncTick = 0;

				-- send cmd
				local args = { pos = i3k_vec3_2_int(entity._curPos), target = i3k_world_pos_to_logic_pos(self._targetPos), speed = self._speed, rotation = self._moveDir };
				local isCanSend = i3k_role_move_scope(args.pos, args.target, args.speed);
				if self._entityType ~= eET_Ghost and isCanSend then
					i3k_sbean.sync_map_move(entity, args)
				end
			end
		end
	end

	return true;
end

function i3k_ai_move:TryMove()
	local entity = self._entity;

	if entity:TryMove() then
		if entity._motionData then
			self._moveTime	= 0;
			self._moveFrame	= 0;
			self._speed		= i3k_world_val_to_logic_val(entity._motionData.mSpeed);
			self._targetPos = entity._motionData.mPaths[entity._motionData.mTicks];

			self._startPos	= entity._curPosE;
			self._moveDir	= i3k_vec3_normalize1(i3k_vec3_sub1(self._targetPos, self._startPos));

			local dir = entity._motionData:GetFaceDir(0);
			entity:SetFaceDir(dir.x, dir.y, dir.z);
		end
	end
	self._startMove = entity:IsValidMotionFrame(self._moveFrame);

	return self._startMove;
end

function i3k_ai_move:CalcMovePos(depth)
	local entity = self._entity;

	if entity._motionData then
		local curFrame = entity._motionData:GetFrame(self._moveTime);
		local changed = curFrame ~= self._moveFrame;

		self._moveFrame = curFrame;

		if entity._motionData:IsValidFrame(self._moveFrame) then
			if changed then
				local dir = entity._motionData:GetFaceDir(curFrame);
				entity:SetFaceDir(dir.x, dir.y, dir.z);
			end

			return entity._motionData:GetPosition(self._moveFrame, self._moveTime);
		else
			if depth > 1 then
				return nil;
			end

			local deltaTime = entity._motionData:GetDeltaTime(self._moveTime);

			if entity:CalcMoveInfo() then
				self._startMove = true;
				self._moveTime	= deltaTime;
				self._moveFrame	= 0;
				self._speed		= i3k_world_val_to_logic_val(entity._motionData.mSpeed);
				self._targetPos = entity._motionData.mPaths[entity._motionData.mTicks];

				self._startPos	= entity._curPosE;
				self._moveDir	= i3k_vec3_normalize1(i3k_vec3_sub1(self._targetPos, self._startPos));

				local dir = entity._motionData:GetFaceDir(0);
				entity:SetFaceDir(dir.x, dir.y, dir.z);

				return self:CalcMovePos(depth + 1);
			end

			return nil;
		end
	end

	return nil;
end

function i3k_ai_move:SetPos(pos)
	self._curPos = pos;

	local entity = self._entity;
	if entity then
		entity:UpdateWorldPos(pos);
	end
end

function create_component(entity, priority)
	return i3k_ai_move.new(entity, priority);
end
