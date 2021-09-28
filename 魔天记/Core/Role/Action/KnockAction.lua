require "Core.Role.Action.RoleAction";

KnockAction = class("KnockAction", RoleAction)

function KnockAction:New(id, pt, blShake)
    self = { };
    setmetatable(self, { __index = KnockAction });
    self:Init();
    self.actionType = ActionType.BLOCK;
    self._knockInfo = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_KNOCKBACK)[id];
    if (self._knockInfo) then
        self._toPoint = pt;
        self._totalTime = self._knockInfo.duration / 1000;
        self._distance = self._knockInfo.dist_fast / 100;
        self._speed = self._knockInfo.speed / 100;
    end
    return self;
end

function KnockAction:_OnStartHandler()
    local controller = self._controller;
    if (controller and self._knockInfo) then
        controller.state = RoleState.HURT;
        controller:Play(self._knockInfo.hit_anim);
        if (GameSceneManager.mpaTerrain:IsWalkable(self._toPoint)) then
            self._distance = Vector3.Distance2(controller.transform.position, self._toPoint);
        else
            self._distance = 0;
        end
        -- self._r =(controller.transform.rotation.eulerAngles.y + 180) / 180.0 * math.pi;
        self._r = math.atan2(self._toPoint.x - controller.transform.position.x, self._toPoint.z - controller.transform.position.z);
        --[[
        if (self._knockInfo.shock > 0) then
            MainCameraController.GetInstance():Shake(self._knockInfo.shock);
        end
		]]
        self:_InitTimer(0, -1);
    else
        self:Finish();
    end
end

function KnockAction:_OnTimerHandler()
    local controller = self._controller;
    if (controller) then
        if (self._totalTime > 0) then
            self._totalTime = self._totalTime - Time.fixedDeltaTime;

            if (self._speed > 0 and self._distance > 0) then
                local pt = controller.transform.position;
                -- local speed = self._speed *(Time.fixedDeltaTime * 1000);
                local speed = self._speed * FPSScale;
                if (self._distance < speed) then
                    speed = self._distance
                end
                pt = Vector3.New(pt.x, pt.y, pt.z);
                pt.x = pt.x + math.sin(self._r) * speed;
                pt.z = pt.z + math.cos(self._r) * speed;
                self._distance = self._distance - speed;
                if (GameSceneManager.mpaTerrain:IsWalkable(pt)) then
                    MapTerrain.SampleTerrainPositionAndSetPos(controller.gameObject, pt)
                    --                    controller.transform.position = MapTerrain.SampleTerrainPosition(pt);
                else
                    self._distance = 0;
                end
            end

--            if (self._knockInfo.hit_anim2 ~= "") then
--                local aInfo = controller:GetAnimatorStateInfo();
--                if (aInfo and aInfo:IsName(self._knockInfo.hit_anim) and aInfo.normalizedTime >= 1) then
--                    controller:Play(self._knockInfo.hit_anim2);
--                end
--            end
            --Warning(tostring(self._knockInfo.hit_anim) .. '___' .. tostring(controller:AnimIsName(self._knockInfo.hit_anim))
--                 .. '__'  .. tostring(controller:AnimNormalizedTime())
--                 )
            if self._roleServerType ~= 1 and controller:AnimNormalizedTime() >= 0.96 then
                if self._knockInfo.hit_anim2 ~= "" and controller:IsName(self._knockInfo.hit_anim) then
                    controller:Play(self._knockInfo.hit_anim2);
                else
                    controller:Play(self:_GetStandActionName())
                    --Warning(tostring(self:_GetStandActionName())..tostring(controller:AnimIsName(self:_GetStandActionName())))
                end
            end
        else
            self:Finish();
        end
    else
        self:Finish();
    end
end