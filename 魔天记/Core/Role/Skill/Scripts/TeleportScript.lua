require "Core.Role.Skill.Scripts.AbsScript";
-- 冲锋到目标面前的可移动区域
TeleportScript = class("TeleportScript", AbsScript)

local pi = math.pi;
local sin = math.sin;
local cos = math.cos;

function TeleportScript:New(skillStage)
    self = { };
    setmetatable(self, { __index = TeleportScript });
    self:SetStage(skillStage);
    return self;
end

function TeleportScript:_Init(role, para)
    local target = role.target;
    local targetRadius = (role.info.radius + target.info.radius) / 100;
    self._d = Vector3.Distance2(role.transform.position, target.transform.position) - targetRadius;
    if (self._d > 0) then
        local pt = role.transform.position;
        local r = role.transform.rotation.eulerAngles.y / 180 * pi;
        pt.x = pt.x + sin(r) * d;
        pt.z = pt.z + cos(r) * d;
        MapTerrain.SampleTerrainPositionAndSetPos(role.transform, pt)

        -- 	role.transform.position = MapTerrain.SampleTerrainPosition(pt);
    end
    self:_InitTimer(0, -1);
    self:_OnTimerHandler();
end

function TeleportScript:_OnTimerHandler()
    self:Dispose();
end