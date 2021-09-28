require "Core.Role.Action.RoleAction";

HurtAction = class("HurtAction", RoleAction)

function HurtAction:New()
    self = { };
    setmetatable(self, { __index = HurtAction });
    self:Init();
    self.actionType = ActionType.NORMAL;
    self._actName = "hurt";
    return self;
end

function HurtAction:_OnStartHandler()
    if (self._controller) then
        self._controller.state = RoleState.HURT;  
    end
end
