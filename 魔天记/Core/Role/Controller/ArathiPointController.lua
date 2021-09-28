require "Core.Role.Controller.AbsController";
require "Core.Info.ArathiPointInfo";
require "Core.Role.Action.Portal.ArathiPointStandAction"
require "Core.Role.Action.Portal.ArathiPointInvalidAction"
require "Core.Role.ModelCreater.ArathiPointModelCreater"


ArathiPointController = class("ArathiPointController", AbsController);

function ArathiPointController:New(data)
    if (data) then
        self = { };
        setmetatable(self, { __index = ArathiPointController });
        self.state = RoleState.STAND;
        self.roleType = ControllerType.NORMAL;
        self:_Init(data);
        return self;
    end
    return nil;
end

function ArathiPointController:_Init(data)
    self.info = ArathiPointInfo:New(data);
    self.id = self.info.id .. "";
    if (self.info.type == 3 or self.info.type == 4) then
        self:_InitEntity(EntityNamePrefix.ARATHI .. self.id);
        self:SetLayer(Layer.Effect);
        if (self.info.type == 3 or (self.info.type == 4 and self.info.buff ~= 0)) then
            self:_LoadModel(ArathiPointModelCreater);
        end
    end
end

function ArathiPointController:_GetModern()
    return "Effect/ScenceEffect", "chuanSongMen";
end

function ArathiPointController:Stand()
    if (self.info.type == 3 or self.info.type == 4) then
        self:StopAction(3);        
        self:DoAction(ArathiPointStandAction:New());
    end
end

function ArathiPointController:Invalid()
    if (self.info.type == 3 or self.info.type == 4) then
        self:StopAction(3);
        self:DoAction(ArathiPointInvalidAction:New());
    end
end

function ArathiPointController:SetBuff(buff)
    if (self.info.type == 4) then
        self.info.buff = buff;
        if (self._roleCreater) then
            self._roleCreater:Dispose()
            self._roleCreater = nil;
        end
        if (self.info.buff ~= 0) then
            self:_LoadModel(ArathiPointModelCreater);
        end
        if (self:IsValid()) then
            self:Stand()
        else
            self:Invalid();
        end
    end
end

function ArathiPointController:SetPointCamp(camp)
    if self.info.camp ~= camp then
        self.info.camp = camp; 
        if (self._roleCreater) then
            self._roleCreater:Dispose()
            self._roleCreater = nil;
        end
        self:_LoadModel(ArathiPointModelCreater,camp);
    end
end

function ArathiPointController:IsValid()
    if (self.info.type == 4) then
        return self.info.buff ~= 0;
    end
    return true;
end