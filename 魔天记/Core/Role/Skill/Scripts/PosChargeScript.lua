require "Core.Role.Skill.Scripts.AbsScript";
-- 定点冲锋脚本
PosChargeScript = class("AntiChargeScript", AbsScript)

local pi = math.pi;
local sin = math.sin;
local cos = math.cos;
local atan2 = math.atan2;

function PosChargeScript:New(skillStage)
    self = { };
    setmetatable(self, { __index = PosChargeScript });
    self:SetStage(skillStage);
    return self;
end

function PosChargeScript:_Init(role, para)
    self._speed = tonumber(para[1]) / 100;
    self._delay = tonumber(para[2]) / 1000;
    self._toPoint = self:_GetScenePosByID("" .. para[3]);
    if (self._toPoint ~= nil and self._role ~= nil and self._role.transform ~= nil and(not self._role:IsDie())) then
        local transform = self._role.transform;
        self._r = atan2(self._toPoint.x - transform.position.x, self._toPoint.z - transform.position.z);
        transform.rotation = Quaternion.Euler(0,(self._r * 180.0 / pi), 0);
    end
    self:_InitTimer(0, -1);
    -- self:_OnTimerHandler();
end

function PosChargeScript:_GetScenePosByID(id)
    local ScenePosCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SCENES_POS);
    local data = ScenePosCfg[id];
    if (data) then
        local pt = Vector3.New(tonumber(data.coordinate1[1]) / 100, tonumber(data.coordinate1[2]) / 100, 0);
        return MapTerrain.SampleTerrainPosition(pt);
    end
    return nil;
end

function PosChargeScript:_OnTimerHandler()
    if (self._toPoint) then
        if (self._delay <= 0) then
            local role = self._role;
            local transform = role.transform;
            local d = Vector3.Distance2(self._toPoint, transform.position);
            local speed = self._speed * FPSScale;
            if (d < speed) then
                Util.SetPos(transform, self._toPoint)
                --                transform.position = self._toPoint;
                self:Dispose();
            else
                local pt = transform.position;
                local r = self._r;
                pt.x = pt.x + sin(r) * speed;
                pt.z = pt.z + cos(r) * speed;
                if (GameSceneManager.mpaTerrain:IsWalkable(pt)) then
                    MapTerrain.SampleTerrainPositionAndSetPos(transform, pt)
                    --                    transform.position = MapTerrain.SampleTerrainPosition(pt);
                else
                    self:Dispose();
                end
            end
        else
            self._delay = self._delay - Time.fixedDeltaTime;
        end
    else
        self:Dispose();
    end
end