------------------------------------------------------
module(..., package.seeall)

local require = require

require("logic/entity/i3k_entity");
local BASE = i3k_entity;


------------------------------------------------------
i3k_obstacle = i3k_class("i3k_obstacle", BASE);
function i3k_obstacle:ctor(guid)
	self._cfg = nil;
end

function i3k_obstacle:Create(pos, dir, otype, args)
	self._dir	= i3k_vec3_to_engine(i3k_vec3((dir[1] / 180) * math.pi, ((360 - (dir[2] - 90)) / 180) * math.pi , (dir[3] / 180) * math.pi));
	self._type	= otype;
	self._args	= args;

	self:SetPos(i3k_world_pos_to_logic_pos(pos));

	return BASE.Create(self, -1);
end

function i3k_obstacle:Release()
	self:Close();

	BASE.Release(self);
end

function i3k_obstacle:Close()
	if self._obstacleID then
		g_i3k_mmengine:RmvDynObstacle(self._obstacleID);

		self._obstacleID = nil;
	end
end

function i3k_obstacle:CanMove()
	return false;
end

function i3k_obstacle:SetPos(pos)
	--BASE.SetPos(self, _pos);
	self._curPos = pos;
	self._curPosE = i3k_vec3_to_engine(i3k_logic_pos_to_world_pos(pos));

	if self._obstacleID then
		g_i3k_mmengine:RmvDynObstacle(self._obstacleID);
	end

	if self._type == 1 then
		self._obstacleID = g_i3k_mmengine:AddDynObstacle(self._curPosE, self._args[1] * 0.5, self._args[2] * 0.5);
	elseif self._type == 2 then
		self._obstacleID = g_i3k_mmengine:AddDynObstacle(self._curPosE, self._args[1] * 0.5, self._args[2] * 0.5, self._args[3], self._dir);
		--self._obstacleID = g_i3k_mmengine:AddDynObstacle(self._curPosE, 12, 2, 15, self._dir);
	end
end

function i3k_obstacle:OnUpdate(dTime)
end

function i3k_obstacle:OnLogic(dTick)
end
