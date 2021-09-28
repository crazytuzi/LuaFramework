require "Core.Role.Skill.Effects.AbsEffect";

FlyEffect = class("FlyEffect", AbsEffect)

local pi = math.pi;
local sin = math.sin;
local cos = math.cos;
local atan2 = math.atan2;
local abs = math.abs;
local min = math.min;
local max = math.max;


function FlyEffect:New(skill, stage, caster, target)
    self = { };
    setmetatable(self, { __index = FlyEffect });
    if (self:_Init(skill, stage, caster, target)) then
        self:BindTarget(caster);
        self._radian = 0;
        self._radianStep = 0;
        self._speed = self.info.range[1] / 100 * 1.5;
        self._distance =(skill.distance - self.effectInfo.z) / 100;
        self._originPt = self.transform.position;
        local roleR = caster.transform.rotation.eulerAngles.y / 180 * pi;
        self._toPoint = Vector3.New();
        self._toPoint.x = self._originPt.x + sin(roleR) * self._distance;
        self._toPoint.z = self._originPt.z + cos(roleR) * self._distance;
        self._toPoint.y = self._originPt.y;
        return self;
    end
    --Warning(">>> skill:" .. skill.id .. "(" .. skill.name .. ") stage:" .. stage .. "(" .. self.info.key .. ") effect_id:" .. self.info.effect_id .. "，在skill_effect.lua没找到对应的特效配置")
    return nil;
end

function FlyEffect:SetRadian(radian)
    self._radian = radian / 180 * pi;
    self._radianStep = abs(self._radian /((self._distance / 2) / self._speed));
end

function FlyEffect:_OnTimerHandler(delay)
    local transform = self.transform;
    if (transform) then
        local speed = self._speed * FPSScale;
        if (self.target and self.target.transform) then
            self._toPoint = self.target.transform.position;
        end

        local d1 = Vector3.Distance2(transform.position, self._originPt);

        if (d1 < self._distance) then
            local d2 = Vector3.Distance2(transform.position, self._toPoint);
            if (d2 < speed * 1.1) then
                if (self.target and self.target.transform) then
                    -- self:_OnHitHandler();
                    self:Dispose();
                else
                    -- self:_OnOutHandler();
                    self:Dispose();
                end
            else
                local r = atan2(self._toPoint.x - transform.position.x, self._toPoint.z - transform.position.z);
                local pt = transform.position
                if (self._radian > 0) then
                    self._radian = max(self._radian - self._radianStep, 0);
                elseif (self._radian < 0) then
                    self._radian = min(self._radian + self._radianStep, 0);
                end
                r = r + self._radian;
                pt.x = pt.x + sin(r) * speed;
                pt.z = pt.z + cos(r) * speed;
                Util.SetPos(transform, pt.x, pt.y, pt.z)
--                transform.position = pt;
                transform.rotation = Quaternion.Euler(0,(r * 180.0 / pi), 0);
            end
        else
            self:Dispose();
            -- self:_OnOutHandler();
        end
    else
        self:Dispose();
    end
end