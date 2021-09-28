require "Core.Role.Action.AbsAction";

LockAction = class("LockAction", AbsAction)

function LockAction:New(position, angle)
    self = { };
    setmetatable(self, { __index = LockAction });
    self:Init();
    self.actionType = ActionType.BLOCK; 
    return self;
end