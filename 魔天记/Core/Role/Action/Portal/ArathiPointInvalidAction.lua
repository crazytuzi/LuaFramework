require "Core.Role.Action.AbsAction";

ArathiPointInvalidAction = class("ArathiPointInvalidAction", AbsAction)

function ArathiPointInvalidAction:New()
    self = { };
    setmetatable(self, { __index = ArathiPointInvalidAction });
    self:Init();
    self.actionType = ActionType.BLOCK;
    self._isInArea = false;
    return self;
end

function ArathiPointInvalidAction:_OnStartHandler()
    local controller = self._controller;
    if (controller) then
        local transform = controller.transform;
        local pt = controller.info.position;
--        local tPoint = Vector3.New(pt.x, pt.y + 100000, pt.z);
        Util.SetPos(transform,pt.x, pt.y + 100000, pt.z)
--        transform.position = tPoint
    end
end