require "Core.Role.Controller.AbsController";
require "Core.Info.PortalInfo";
require "Core.Role.Action.Portal.PortalStandAction"
require "Core.Role.ModelCreater.PortalModelCreater"

PortalController = class("PortalController", AbsController);

function PortalController:New(data)
    if (data) then
        self = { };
        setmetatable(self, { __index = PortalController });
        self.state = RoleState.STAND;
        self.roleType = ControllerType.NORMAL;
        self:_Init(data);
        return self;
    end
    return nil;
end

function PortalController:_Init(data)
    self.info = PortalInfo:New(data);
    self.id = self.info.id .. "";
    self:_InitEntity(EntityNamePrefix.NORMAL .. self.id);
    self:SetLayer(Layer.Effect);
end
function PortalController:CheckLoadModel()
    if self._roleCreater or self._dispose then return end
    self:_LoadModel(PortalModelCreater)
end

function PortalController:_GetModern()
    return "Effect/ScenceEffect", "chuanSongMen";
end

function PortalController:Stand()
    if (self:_CanDoAction()) then
        self:DoAction(PortalStandAction:New());
    end
end