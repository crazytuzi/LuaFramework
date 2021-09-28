----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_move_base").i3k_ai_move_base;

local g_i3k_check_angle = math.cos((15 / 180) * math.pi);

------------------------------------------------------
i3k_ai_auto_move = i3k_class("i3k_ai_auto_move", BASE);
function i3k_ai_auto_move:ctor(entity)
	self._type = eAType_AUTO_MOVE;
	self._valid = false;
end

function i3k_ai_auto_move:IsValid()
	if not BASE.IsValid(self) then return false; end
	
	local entity = self._entity;

	if entity._behavior:Test(eEBMove) then
		if entity:GetEntityType() == eET_Pet and entity._taskHoster then
			if i3k_vec3_dist(entity._curPos, entity._hoster._curPos) > 1000 then
				return false
			end
		end
		return true;
	end

	if entity._behavior:Test(eEBRetreat) then
		if i3k_vec3_dist(entity._curPos, entity._birthPos) > 10 then
			return true;
		end
	end

	if entity._movePaths and #entity._movePaths > 0 then
		return true;
	end

	if entity:GetFollowTarget() then
		return true;
	end
	if entity._findPathData and entity._findPathData.endPos then
		return true
	end

	return false;
end

function i3k_ai_auto_move:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;

		if self._syncRpc then
			self._syncTick = 500; -- first tick need sync
		end

		return self:StartMove();
	end

	return false;
end

function i3k_ai_auto_move:OnLeave()
	if BASE.OnLeave(self) then
		if self._movePos and self._valid then
			if self._entity and self._entity:GetEntityType() == eET_Mercenary then
				if math.abs(self._movePos.x - self._entity._curPos.x) < 50 then
					self:SetPos(self._movePos, true);
				end
			else
				self:SetPos(self._movePos, true);
			end
		end
		self._valid = false;

		local entity = self._entity
		self._entity:StopMove();
		
		if self._syncRpc then
			if entity:GetEntityType() == eET_Mercenary or entity:GetEntityType() == eET_Player or entity:GetEntityType() == eET_Car then
				local logic = i3k_game_get_logic();
				if logic then
					if entity:GetEntityType() == eET_Car then
						local world = i3k_game_get_world()
						local entityCar = world._entities[eGroupType_O]["i3k_escort_car|"..g_i3k_game_context:GetRoleId()];
						if entityCar then
							local args = { pos = entity._curPos, rotation = entity._orientation };
							i3k_sbean.sync_escortcar_stopmove(entity, args)
						end
					else
						local isCanSend = i3k_role_stop_move_scope(entity._curPos);
						if isCanSend then
							i3k_sbean.sync_map_stopmove(entity, entity._curPos);
						end
					end
				end
			end
		end

		return true;
	end

	return false;
end

function i3k_ai_auto_move:OnUpdate(dTime)
	if not BASE.OnUpdate(self, dTime) then return false; end

	if not self._valid then return false; end

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

function i3k_ai_auto_move:CalcMovePos()
	local entity = self._entity;
	local p1 = i3k_vec3_clone(self._startPos);
	local p2 = i3k_vec3_clone(self._endPos);
	local p3 = i3k_vec3_clone(self._targetPos);

	local target = entity:GetFollowTarget();
	if target and not target:IsDead() then
		local p4 = target._curPos;

		-- 目标移动
		if i3k_vec3_dist(p2, p4) >= 200 then
			self:StartMove();

			return true;
		end
	end

	if i3k_vec3_dist(p1, p3) <= 10 then
		self:SetPos(p3, true);

		local paths = entity._movePaths;
		if #paths > 0 then
			table.remove(paths, 1);

			if paths and #paths > 0 then
				self._targetPos = i3k_vec3_clone(paths[1]);

				local rot_y = i3k_vec3_angle1(self._targetPos, p1, { x = 1, y = 0, z = 0 });
				entity:SetFaceDir(0, rot_y, 0);

				return true;
			end
		end

		return false;
	end

	return true;
end

function i3k_ai_auto_move:OnLogic(dTick)
	if not BASE.OnLogic(self, dTick) then return false; end

	if not self._valid then return false; end

	if dTick > 0 then
		local entity = self._entity;

		-- 同步上一逻辑帧位置
		if self._entity and self._entity:GetEntityType() == eET_Mercenary then
			if math.abs(self._movePos.x - self._entity._curPos.x) < 50 then
				self:SetPos(self._movePos, true);
			end
		else
			self:SetPos(self._movePos, true);
		end

		if not self:CalcMovePos() then
			entity:StopMove();

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

			if self._syncRpc then
				self._syncTick = self._syncTick + dTick * i3k_engine_get_tick_step();
				if self._syncTick > g_syncTick * 5 then
					self._syncTick = 0;

					local speed	= entity:GetPropertyValue(ePropID_speed);

					local logic = i3k_game_get_logic();
					if logic then
						if entity:GetEntityType() == eET_Car then
							local args = { pos = entity._curPos, target = self._targetPos, speed = speed, rotation = entity._orientation };
							local dist = i3k_vec3_len(i3k_vec3_sub1(p1, p2));
							if dist < i3k_db_escort.escort_args.distance then
								i3k_sbean.sync_escortcar_move(entity, args)
							end
						else
							local args = { pos = entity._curPos, target = self._targetPos, speed = speed, rotation = entity._orientation };
							local isCanSend = i3k_role_move_scope(args.pos, args.target, args.speed);
							if isCanSend then
								i3k_sbean.sync_map_move(entity, args)
							end
						end
					end
				end
			end
		else
			entity:StopMove();

			return false;
		end
	end

	return true;
end

function i3k_ai_auto_move:SetPos(pos, real)
	if not self._valid then return; end

	pos.y =  i3k_world_pos_to_logic_pos(i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos)))).y;

	local entity = self._entity;
	if entity then
		entity:SetPos(pos, real);
	end

	if real then
		self._startPos = pos;
	end
end

function i3k_ai_auto_move:StartMove()
	local entity = self._entity;

	local movePaths = { };

	self._valid = true;

	if entity._behavior:Test(eEBRetreat) then
		local movePaths = { };
		table.insert(movePaths, entity._birthPos);

		entity:MovePaths(movePaths, true);

		self._deltaTime = 0;
		self._startPos	= entity._curPos;
		self._targetPos	= entity._birthPos;
		self._endPos	= entity._birthPos;
		self._moveTime	= 0;
		self._moveEnd	= true;
		self._movePos	= self._startPos;
		self._moveDir	= { x = 0, y = 0, z = 0 };

		local rot_y = i3k_vec3_angle1(self._targetPos, entity._curPos, { x = 1, y = 0, z = 0 });
		entity:SetFaceDir(0, rot_y, 0);

		return true;
	end

	local target = entity:GetFollowTarget();
	local posE
	if target then
		posE = i3k_vec3_clone(target._curPosE);
	elseif entity._findPathData and entity._findPathData.endPos then
		posE = entity._findPathData.endPos
	end
	if posE then
		local dirP = nil;
		local posP = nil;

		local findCnt = 0;
		while true do
			local rnd_x = i3k_engine_get_rnd_f(-1, 1);
			local rnd_z = i3k_engine_get_rnd_f(-1, 1);

			local _pos = i3k_vec3_clone(posE);
				_pos.x = posE.x + rnd_x;
				_pos.y = posE.y + 1;
				_pos.z = posE.z + rnd_z;
			_pos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(_pos));

			local paths = g_i3k_mmengine:FindPath(entity._curPosE, i3k_vec3_to_engine(_pos));
			if paths:size() > 0 then
				for k = paths:size(), 1, -1 do
					local pos = i3k_world_pos_to_logic_pos(paths[k - 1]);

					if not dirP then
						table.insert(movePaths, pos);
					else
						local dirN = i3k_vec3_sub1(pos, posP);

						local angle1 = i3k_vec3_dot_xz(dirN, dirP);
						if math.abs(angle1) < g_i3k_check_angle then
							table.insert(movePaths, pos);
						end
					end

					if posP then
						dirP = i3k_vec3_sub1(pos, posP);
					else
						dirP = i3k_vec3_sub1(pos, entity._curPos);
					end
					posP = pos;
				end

				break;
			end

			findCnt = findCnt + 1;
			if findCnt > 5 then
				break;
			end
		end

		if #movePaths > 0 then
			entity:MovePaths(movePaths, true);

			self._deltaTime = 0;
			self._startPos	= entity._curPos;
			self._targetPos	= movePaths[1];
			self._endPos	= movePaths[#movePaths];
			self._moveTime	= 0;
			self._moveEnd	= true;
			self._movePos	= self._startPos;
			self._moveDir	= { x = 0, y = 0, z = 0 };

			local rot_y = i3k_vec3_angle1(self._targetPos, entity._curPos, { x = 1, y = 0, z = 0 });
			entity:SetFaceDir(0, rot_y, 0);

			return true;
		end
	end

	self._deltaTime	= 0;
	self._startPos	= entity._curPos;
	self._targetPos = self._startPos;
	self._endPos	= self._startPos;
	self._moveTime	= 0;
	self._moveEnd	= true;
	self._movePos	= self._startPos;
	self._moveDir	= { x = 0, y = 0, z = 0 };

	return true;
end

function create_component(entity, priority)
	return i3k_ai_auto_move.new(entity, priority);
end

