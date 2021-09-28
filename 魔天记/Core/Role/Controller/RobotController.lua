require "Core.Role.Controller.PlayerController";

require "Core.Role.ModelCreater.RoleModelCreater"
require "Core.Role.ModelCreater.HeroModelCreater"

RobotController = class("RobotController", PlayerController);

function RobotController:New(data)
    self = { };
    setmetatable(self, { __index = RobotController });
    self.state = RoleState.STAND;
    self.roleType = ControllerType.ROBOT;
    self:_Init(data);
    self:AddBuffs(data.buff)
    return self;
end