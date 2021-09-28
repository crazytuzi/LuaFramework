require "Core.Role.Skill.Scripts.AbsScript";
-- 飞弹脚本
StraybulletScript = class("StraybulletScript", AbsScript)

function StraybulletScript:New(skillStage)
	self = { };
	setmetatable(self, { __index = StraybulletScript });
	self:SetStage(skillStage);
	return self;
end

function StraybulletScript:_Init(role, para)
	local amount = tonumber(para[1]);
	local angle = tonumber(para[2]);
	local r = angle;
	local s = 1;
	for i = 1, amount do
		local eff = self._stage:InitEffect();
		if (eff) then
			eff:SetRadian(r * s);
		end
		if (i % 2 == 0) then
			r = r + angle;
		end
		s = s * -1;
	end
	self:_InitTimer(0, -1);
end

function StraybulletScript:_OnTimerHandler()
	self:Dispose();
end