----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_auto_move").i3k_ai_auto_move;


------------------------------------------------------
i3k_ai_follow = i3k_class("i3k_ai_follow", BASE);
function i3k_ai_follow:ctor(entity)
	self._type = eAType_FOLLOW;
end

function i3k_ai_follow:CalcMovePos_Disable()
	local entity = self._entity;
	local p1 = i3k_vec3_clone(self._startPos);
	local p2 = i3k_vec3_clone(self._targetPos);

	local target = entity:GetFollowTarget();
	if target and not target:IsDead() then
		local p3 = i3k_vec3_clone(target._curPos);

		if i3k_vec3_dist_2d(p2, p3) >= 300 then
			self:StartMove();

			local rot_y = i3k_vec3_angle1(self._targetPos, p1, { x = 1, y = 0, z = 0 });
			entity:SetFaceDir(0, rot_y, 0);

			return true;
		end
	end

	if i3k_vec3_dist(p1, p2) <= 50 then
		self:SetPos(p2, true);

		local paths = entity._movePaths;
		if paths and #paths > 0 then
			self._targetPos = i3k_vec3_clone(paths[1]);

			local rot_y = i3k_vec3_angle1(self._targetPos, p1, { x = 1, y = 0, z = 0 });
			entity:SetFaceDir(0, rot_y, 0);

			table.remove(paths, 1);

			return true;
		end

		return false;
	end

	return true;
end

function i3k_ai_follow:StartMove_Disable()
	local entity = self._entity;

	self._valid = false;

	local target = entity:GetFollowTarget();
	if target then
		local posE = i3k_vec3_clone(target._curPosE);
		local posF = nil;

		--[[
		local findCnt = 0;
		while true do
			local dist1 = 1.5;
			local dist2 = 3;
			if entity._cfg.followdist3 then
				dist1 = entity._cfg.followdist3 * 0.8 / 2 / 100;
				dist2 = entity._cfg.followdist3 / 2 / 100;
			end

			local rnd_x = i3k_engine_get_rnd_f(dist1, dist2);

			local rnd_x_s = i3k_engine_get_rnd_u(0, 1);
			if rnd_x_s == 0 then
				rnd_x = rnd_x * -1;
			end

			local rnd_z = i3k_engine_get_rnd_f(dist1, dist2);

			local rnd_z_s = i3k_engine_get_rnd_u(0, 1);
			if rnd_z_s == 0 then
				rnd_z = rnd_z * -1;
			end

			local _pos = i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_vec3(posE.x + rnd_x, posE.y + 1, posE.z + rnd_z)));

			local paths = g_i3k_mmengine:FindPath(i3k_vec3_to_engine(i3k_engine_get_valid_pos(entity._curPosE)), i3k_vec3_to_engine(_pos));
			if paths:size() > 0 then
				posF = paths:front();

				break;
			end

			findCnt = findCnt + 1;
			if findCnt > 5 then
				break;
			end
		end
		]]

		local dist1 = 1.5;
		local dist2 = 3;
		if entity._cfg.followdist3 then
			dist1 = entity._cfg.followdist3 * 0.8 / 2 / 100;
			dist2 = entity._cfg.followdist3 / 2 / 100;
		end

		local rnd_x = i3k_engine_get_rnd_f(dist1, dist2);

		local rnd_x_s = i3k_engine_get_rnd_u(0, 1);
		if rnd_x_s == 0 then
			rnd_x = rnd_x * -1;
		end

		local rnd_z = i3k_engine_get_rnd_f(dist1, dist2);

		local rnd_z_s = i3k_engine_get_rnd_u(0, 1);
		if rnd_z_s == 0 then
			rnd_z = rnd_z * -1;
		end

		posF = i3k_engine_get_valid_pos(i3k_vec3_to_engine(i3k_vec3(posE.x + rnd_x, posE.y + 1, posE.z + rnd_z)));

		if posF then
			self._valid = true;

			local movePaths = { };
			table.insert(movePaths, i3k_world_pos_to_logic_pos(posF));

			entity:MovePaths(movePaths, true);

			self._deltaTime = 0;
			self._startPos	= entity._curPos;
			self._targetPos	= movePaths[1];
			self._movePaths	= entity._movePaths;
			self._moveTime	= 0;
			self._moveEnd	= true;
			self._movePos	= self._startPos;
			self._moveDir	= { x = 0, y = 0, z = 0 };

			local rot_y = i3k_vec3_angle1(self._targetPos, entity._curPos, { x = 1, y = 0, z = 0 });
			entity:SetFaceDir(0, rot_y, 0);

			return true;
		end
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_follow.new(entity, priority);
end

