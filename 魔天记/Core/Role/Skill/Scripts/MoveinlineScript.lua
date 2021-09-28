require "Core.Role.Skill.Scripts.AbsScript";
-- 直线位移
MoveinlineScript = class("MoveinlineScript", AbsScript)

local pi = math.pi;
local sin = math.sin;
local cos = math.cos;

function MoveinlineScript:New(skillStage)
	self = { };
	setmetatable(self, { __index = MoveinlineScript });
	self:SetStage(skillStage);
	return self;
end

function MoveinlineScript:_Init(role, para)
	self._distance = tonumber(para[1]) / 100;
	self._totalTime = tonumber(para[2]) / 1000;
	self._speed = self._distance / (self._totalTime / 0.03333);
	self._r = role.transform.rotation.eulerAngles.y / 180 * pi;
	self:_InitTimer(0, -1);
	self:_OnTimerHandler();
end

function MoveinlineScript:_OnTimerHandler()
	if (self._distance > 0) then
		local role = self._role;
		local speed = self._speed * FPSScale;
		if (self._distance > speed) then
			self._distance = self._distance - speed;
		else
			speed = self._distance;
			self._distance = 0;
		end
		local transform = role.transform;
		local pt = transform.position;
		local r = self._r;
		pt.x = pt.x + sin(r) * speed;
		pt.z = pt.z + cos(r) * speed;
		if (GameSceneManager.mpaTerrain:IsWalkable(pt)) then
                MapTerrain.SampleTerrainPositionAndSetPos(transform, pt)

--			transform.position = MapTerrain.SampleTerrainPosition(pt);
		else
			self:Dispose();
		end
	else
		self:Dispose();
	end
end