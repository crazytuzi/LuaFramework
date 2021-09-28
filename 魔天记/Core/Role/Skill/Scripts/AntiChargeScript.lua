require "Core.Role.Skill.Scripts.AbsScript";
-- 反向冲锋脚本
AntiChargeScript = class("AntiChargeScript", AbsScript)

local sin = math.sin;
local cos = math.cos;

function AntiChargeScript:New(skillStage)
	self = { };
	setmetatable(self, { __index = AntiChargeScript });
	self:SetStage(skillStage);
	return self;
end

function AntiChargeScript:_Init(role, para)
	self._distance = tonumber(para[1]) / 100;
	self._speed = tonumber(para[2]) / 100;
	self._totalTime = tonumber(para[3]) / 1000;
	self._r =(role.transform.rotation.eulerAngles.y - 180) / 180 * math.pi;
	self:_InitTimer(0, -1);
	self:_OnTimerHandler();
end

function AntiChargeScript:_OnTimerHandler()
	if (self._totalTime <= 0) then
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
--				transform.position = MapTerrain.SampleTerrainPosition(pt);
			else
				self:Dispose();
			end
		else
			self:Dispose();
		end
	else
		self._totalTime = self._totalTime - Time.fixedDeltaTime;
	end
end