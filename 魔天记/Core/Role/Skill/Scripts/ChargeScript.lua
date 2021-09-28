require "Core.Role.Skill.Scripts.AbsScript";
-- 冲锋脚本
ChargeScript = class("ChargeScript", AbsScript)

local pi = math.pi;
local sin = math.sin;
local cos = math.cos;

function ChargeScript:New(skillStage)
	self = { };
	setmetatable(self, { __index = ChargeScript });
	self:SetStage(skillStage);
	return self;
end

function ChargeScript:_Init(role, para)
	self._distance = tonumber(para[1]) / 100;
	self._speed = tonumber(para[2]) / 100;
	self._delayTime = tonumber(para[3]) / 1000;
	self._r = role.transform.rotation.eulerAngles.y / 180 * pi;
	self:_InitTimer(0, -1);
	self:_OnTimerHandler();
end

function ChargeScript:_OnTimerHandler()
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

--				transform.position = MapTerrain.SampleTerrainPosition(pt);
			else
				self:Dispose();
			end
		else
			self:Dispose();
		end
	else
		self._delayTime = self._delayTime - Time.fixedDeltaTime;
	end
end