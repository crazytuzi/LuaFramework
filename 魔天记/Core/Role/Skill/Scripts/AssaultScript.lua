require "Core.Role.Skill.Scripts.AbsScript";
-- 冲锋脚本
AssaultScript = class("AssaultScript", AbsScript)

local pi = math.pi;
local sin = math.sin;
local cos = math.cos;

function AssaultScript:New(skillStage)
	self = { };
	setmetatable(self, { __index = AssaultScript });
	self:SetStage(skillStage);
	return self;
end

function AssaultScript:_Init(role, para)
	local target = role.target;
	if (target ~= nil and(not target:IsDie())) then
		self._distance = Vector3.Distance2(role.transform.position, target.transform.position) - (tonumber(para[2]) + role.info.radius + target.info.radius) / 100;
	else
		self._distance = tonumber(para[1]) / 100;
	end
    if (self._distance > 0) then
	    self._speed = tonumber(para[3]) / 100;
	    self._delayTime = tonumber(para[4]) / 1000;
	    self._totalTime = tonumber(para[5]) / 1000;
	    self._r = role.transform.rotation.eulerAngles.y / 180 * pi;
	    self:_InitTimer(0, -1);
	    self:_OnTimerHandler();
    else
        self:Dispose();
    end
end

function AssaultScript:_OnTimerHandler()
	if (self._totalTime > 0) then
		if (self._delayTime <= 0) then
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
                MapTerrain.SampleTerrainPositionAndSetPos(transform,pt)

--					transform.position = MapTerrain.SampleTerrainPosition(pt);
				else
					self:Dispose();
				end
			else
				self:Dispose();
			end
		else
			self._delayTime = self._delayTime - Time.fixedDeltaTime;
		end
		self._totalTime = self._totalTime - Time.fixedDeltaTime;
	else
		self:Dispose();
	end
end