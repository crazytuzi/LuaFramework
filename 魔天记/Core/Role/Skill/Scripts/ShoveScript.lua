require "Core.Role.Skill.Scripts.AbsScript";
-- 冲锋挤压
ShoveScript = class("ShoveScript", AbsScript)

local pi = math.pi;
local sin = math.sin;
local cos = math.cos;
local atan2 = math.atan2;
local tabInsert = table.insert;

function ShoveScript:New(skillStage)
    self = { };
    setmetatable(self, { __index = ShoveScript });
    self:SetStage(skillStage);
    return self;
end

function ShoveScript:_Init(role, para)
    local stage = self._stage;
    local info = stage.info;
    self._RectW = tonumber(info.range[1]) / 100;
    self._RectH = tonumber(info.range[2]) / 100;
    self._distance = tonumber(para[1]) / 100;
    self._tDistance = tonumber(para[2]) / 100;
    self._speed = tonumber(para[3]) / 100;
    self._time = tonumber(para[4]) / 1000;
    self._r = role.transform.rotation.eulerAngles.y / 180 * math.pi;
    self:_InitTimer(0, -1);
    self:_OnTimerHandler();
end

function ShoveScript:_SwitchTargets(pt, w, h, roles)
    local role = self._role;
    local roleR = role.transform.rotation.eulerAngles.y;
    local minX = pt.x - w / 2;
    local maxX = pt.x + w / 2;
    local minZ = pt.z;
    local maxZ = pt.z + h;
    local targets = { };
    for i, v in pairs(roles) do
        local tPt = v.transform.position;
        local d = Vector3.Distance2(pt, tPt);
        local r = atan2(tPt.x - pt.x, tPt.z - pt.z) - self._r;
        tPt.x = pt.x + sin(r) * d;
        tPt.z = pt.z + cos(r) * d;
        if (tPt.x >= minX and tPt.x <= maxX and tPt.z >= minZ and tPt.z <= maxZ) then
            tabInsert(targets, v);
        end
    end
    return targets
end

function ShoveScript:_OnTimerHandler()
    local map = GameSceneManager.map;
    if (self._distance > 0 and map) then
        local role = self._role;
        local transform = role.transform;
        local pt = transform.position;
        local targets = self:_SwitchTargets(pt, self._RectW, self._RectH, map:GetHostileTargets(role.info.camp, role.info.pkType));
        local speed = self._speed * FPSScale;
        if (self._distance > speed) then
            self._distance = self._distance - speed;
        else
            speed = self._distance;
            self._distance = 0;
        end
        local r = self._r;
        pt.x = pt.x + sin(r) * speed;
        pt.z = pt.z + cos(r) * speed;
        for i, v in pairs(targets) do
            local vt = v.transform;
            local vpt = vt.position;
            local vrr = atan2(vpt.x - pt.x, vpt.z - pt.z);
            local vrd = Vector3.Distance2(vpt, pt);
            local vd = cos(vrr - r) * vrd - (self._tDistance + v.info.radius/100);
            if (vd <= 0.5) then
                if (v.info.is_back ~= false) then
                    vpt.x = vpt.x + sin(r + pi) * vd;
                    vpt.z = vpt.z + cos(r + pi) * vd;
                    vt.rotation = Quaternion.Euler(0,((r + pi) * 180.0 / pi), 0);
                    if (GameSceneManager.mpaTerrain:IsWalkable(vpt)) then
                        MapTerrain.SampleTerrainPositionAndSetPos(vt, vpt)
                        -- 					vt.position = MapTerrain.SampleTerrainPosition(vpt);
                    end
                else
                    self:Dispose();
                end
            end
        end
        if (GameSceneManager.mpaTerrain:IsWalkable(pt)) then
                        MapTerrain.SampleTerrainPositionAndSetPos(transform, pt)

--            transform.position = MapTerrain.SampleTerrainPosition(pt);
        else
            self:Dispose();
        end
    else
        self:Dispose();
    end
end