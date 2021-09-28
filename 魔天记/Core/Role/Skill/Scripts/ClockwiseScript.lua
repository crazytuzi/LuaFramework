require "Core.Role.Skill.Scripts.AbsScript";
-- 原地旋转脚本
ClockwiseScript = class("ClockwiseScript", AbsScript)

local pi = math.pi;
local sin = math.sin;
local cos = math.cos;

function ClockwiseScript:New(skillStage)
    self = { };
    setmetatable(self, { __index = ClockwiseScript });
    self:SetStage(skillStage);
    return self;
end

function ClockwiseScript:_Init(role, para)
    self._expressType = tonumber(para[6]);
    if (self._expressType == 1) then
        self._whirlType = tonumber(para[1]);
        self._offsetAngle = tonumber(para[2]) *(self._whirlType * -1);
        self._angle = tonumber(para[3]);
        self._step = tonumber(para[4]) / 30;
        self:_RefreshAngle(self._offsetAngle)
    end
    self:_InitTimer(0, -1);
    self:_OnTimerHandler();
end

function ClockwiseScript:_RefreshAngle(angle)
    local role = self._role;
    local effect = self._effect;
    role.transform:Rotate(0, angle, 0);
    if (effect ~= nil and effect.transform ~= nil and effect.transform.parent ~= role.transform) then
        local d = Vector3.Distance2(effect.transform.position, role.transform.position);
        local r = role.transform.rotation.eulerAngles.y * pi / 180;
        local pt = role.transform.position;
        pt.x = pt.x + sin(r) * d;
        pt.z = pt.z + cos(r) * d;
        pt.y = effect.transform.position.y;
        Util.SetPos(effect.transform, pt.x, pt.y, pt.z)

        -- 	effect.transform.position = pt;
        effect.transform:Rotate(0, angle, 0);
    end
end

function ClockwiseScript:_OnTimerHandler()
    if (self._expressType == 1) then
        if (self._angle > 0) then
            local step = self._step;
            if (step > self._angle) then
                step = self._angle;
            end
            self:_RefreshAngle(step * self._whirlType);
            self._angle = self._angle - step;
        else
            self:Dispose();
        end
    else
        self:Dispose();
    end
end