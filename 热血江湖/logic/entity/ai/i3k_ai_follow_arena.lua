----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_auto_move").i3k_ai_auto_move;


------------------------------------------------------
i3k_ai_follow_arena = i3k_class("i3k_ai_follow_arena", BASE);
function i3k_ai_follow_arena:ctor(entity)
	self._type = eAType_FOLLOW;
end

function i3k_ai_follow_arena:IsValid()
	if not BASE.IsValid(self) then return false; end

	local entity = self._entity;

	if entity._behavior:Test(eEBMove) then
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
	
	local function testDist(target)
		if not target then
			return false;
		end

		local dist = i3k_vec3_dist(entity._curPos, target._curPos)
		if entity._curSkill then
			if entity._curSkill._range+entity:GetRadius()+target:GetRadius() > dist then
				return false
			else
				return true
			end
		else
			return false
		end
	end
	
	return testDist(entity._target)
end

function i3k_ai_follow_arena:CalcMovePos()
	local entity = self._entity;
	local p1 = i3k_vec3_clone(self._startPos);
	local p2 = i3k_vec3_clone(self._targetPos);

	local tentity = entity._target;
	if not tentity then
		return false;
	end

	local p3 = i3k_vec3_clone(tentity._curPos);
	
	local ndist = i3k_vec3_dist_2d(p2, p3)
	if ndist >= 300 then
		self:StartMove();

		local rot_y = i3k_vec3_angle1(self._targetPos, p1, { x = 1, y = 0, z = 0 });
		entity:SetFaceDir(0, rot_y, 0);

		return true;
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

function i3k_ai_follow_arena:StartMove()
	local entity = self._entity;

	self._valid = false;

	local tentity = entity._target;
	if not tentity then
		return false;
	end
	
	local dist = i3k_vec3_dist(entity._curPos, tentity._curPos)
	
	if entity._curSkill and (entity._curSkill._range+(entity:GetRadius() + tentity:GetRadius()))>=dist then
		return true
	end
	local posE = i3k_vec3_clone(tentity._curPosE);
	local posF = nil;
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

		self._curTarPos	= i3k_vec3_clone(tentity._curPos);
		
		return true;
	end

	return false;
end


function create_component(entity, priority)
	return i3k_ai_follow_arena.new(entity, priority);
end

