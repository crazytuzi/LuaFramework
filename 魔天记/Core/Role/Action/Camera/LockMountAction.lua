--[[
   载具锁定摄像机动作
]]

require "Core.Role.Action.AbsAction";
require "Core.Role.Controller.HeroController"

LockMountAction = class("LockMountAction", AbsAction)

function LockMountAction:New(mountController)
    self = { };
    setmetatable(self, { __index = LockMountAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    self.mountController = mountController;
    return self;
end

function LockMountAction:_OnStartHandler()
    if (self._controller) then
        self._target = HeroController.GetInstance();
        self:_InitTimer(0, -1);
    end

    self.mountAct = self.mountController.mountAct;
end

function LockMountAction:_OnTimerHandler()
    if (self._target) then
        local transform = self._controller.transform;
        local target = self._target.transform.position

        if self.mountAct ~= nil then
            local cinfo = self.mountAct:GetCamerInfo();
            if cinfo ~= nil then
                Util.SetPos(transform, target.x + cinfo.x, target.y + cinfo.y, target.z + cinfo.z)
                --                transform.position = Vector3.New(target.x+cinfo.x, target.y +cinfo.y, target.z+cinfo.z);
                transform.rotation.eulerAngles = Vector3.New(cinfo.rx, cinfo.ry, cinfo.rz);

            end

        else
            Util.SetPos(transform, target.x, target.y + cameraOffsetY, target.z)

            --            transform.position = Vector3.New(target.x, target.y + cameraOffsetY, target.z);
            --transform.rotation = Quaternion.Euler(cameraAngle, cameraLensRotation, 0);
            Util.SetRotation(transform, cameraAngle, cameraLensRotation, 0)
        end

        transform:Translate(Vector3.back * cameraDistance);


    end
end

function LockMountAction:_OnStopHandler()
    self.mountController = nil;
    self.mountAct = nil;
    self._controller = nil;
end