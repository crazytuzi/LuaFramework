require "Core.Role.Action.MoveToAngleAction";

SendMoveToAngleAction = class("SendMoveToAngleAction", MoveToAngleAction)

function SendMoveToAngleAction:New(angle)
    -- log("SendMoveToAngleAction:New,angle=" .. angle);
    self = { };
    setmetatable(self, { __index = SendMoveToAngleAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    self:SetAngle(angle);
    -- self._isStand = false;
    return self;
end

function SendMoveToAngleAction:SetAngle(angle)
    -- log("SendMoveToAngleAction:SetAngle,angle=" .. angle);
    self._moveAngle = angle;
    self._r = angle * math.pi / 180;
    self._oriAngle = angle;
    self:_SetAngle(angle);
end

function SendMoveToAngleAction:_SetAngle(angle)
    if (self._angle ~= angle) then
        -- log("_SetAngle___" .. tostring(angle) .. "_____" .. tostring(self._angle))
        self._angle = angle;
        -- self._r = angle * math.pi / 180;
        local controller = self._controller;
        if (controller) then
            self:_CheckIsRunAction();
           -- controller.transform.rotation = Quaternion.Euler(0, angle, 0);
            Util.SetRotation(controller.transform, 0, angle, 0)
        end
        self:_OnStartCompleteHandler();
    end
end



function SendMoveToAngleAction:_OnStartCompleteHandler()
    local controller = self._controller
    if (controller) then
        -- log("_OnStartCompleteHandler" .. tostring(controller) .. "____" .. self._moveAngle)
        -- local rotation = controller.transform.rotation.eulerAngles
        local position = controller.transform.position;
        -- local data = Convert.PointToServer(position, self._angle);
        local data = Convert.PointToServer(position, self._moveAngle);
        SocketClientLua.Get_ins():SendMessage(CmdType.RoleMoveByAngle, data);
        self._isStand = false;

        -- controller:SetAlpha(0.5);
    end
end;

function SendMoveToAngleAction:_CheckCanMove(angle)
    local controller = self._controller;
    local transform = controller.transform;
    local pt = transform.position;
    local speed = controller:GetMoveSpeed() / 100 * 3;
    local r = angle * math.pi / 180;
    pt.x = pt.x + math.sin(r) * speed;
    pt.z = pt.z + math.cos(r) * speed;
    if (GameSceneManager.mpaTerrain:IsWalkable(pt)) then
        return true
    end
    return false;
end

function SendMoveToAngleAction:_Stand()
    local controller = self._controller;
    if (controller) then
        local rotation = controller.transform.rotation.eulerAngles
        local position = controller.transform.position;
        local data = Convert.PointToServer(position, rotation.y);
        data.t = self._roleServerType;
        data.id = controller.id;
        SocketClientLua.Get_ins():SendMessage(CmdType.RoleMoveEnd, data);
        self._isStand = true;
    end
end

function SendMoveToAngleAction:_OnMoveToAngleHandler()
    local controller = self._controller;
    --local aInfo = controller:GetAnimatorStateInfo();
    local isFight = controller:IsFightStatus();
    local transform = controller.transform;
    local pt = transform.position;
    local speed = controller:GetMoveSpeed() / 100 * FPSScale;
    local r = self._r;
    pt.x = pt.x + math.sin(r) * speed;
    pt.z = pt.z + math.cos(r) * speed;

    if (GameSceneManager.mpaTerrain:IsWalkRound(pt)) then
        if (self._roleIsFight ~= isFight) then
            self:_CheckIsRunAction();
            self._roleIsFight = isFight
        end
        MapTerrain.SampleTerrainPositionAndSetPos(transform, pt)
        --        transform.position = MapTerrain.SampleTerrainPosition(pt);

        if (self._angle ~= self._oriAngle) then
            self:SetAngle(self._oriAngle);
        end
    else
        local curAngle = math.round(self._angle)
        pt = transform.position

        -- 角度要发到后台用于同步 		
        local toAngel = GameSceneManager.mpaTerrain:GetCanMoveAngel(pt, curAngle, speed)
        if (curAngle == toAngel) then
            if (not self._isStand) then
                self:_Stand();
            end
        else
            self._moveAngle = toAngel;
            self:_SetAngle(curAngle);

            local r = toAngel * math.pi / 180;
            pt.x = pt.x + math.sin(r) * speed;
            pt.z = pt.z + math.cos(r) * speed;

            MapTerrain.SampleTerrainPositionAndSetPos(transform, pt)
            --            local to = MapTerrain.SampleTerrainPosition(pt)
            --            transform.position = to;

            self:_CheckIsRunAction();
        end
    end
end