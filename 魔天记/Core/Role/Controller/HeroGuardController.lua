require "Core.Role.Controller.HeroPuppetController";
require "Core.Role.AI.GuardAiController";
require "Core.Role.ModelCreater.GuardModelCreater"

HeroGuardController = class("HeroGuardController", HeroPuppetController);

function HeroGuardController:New(data)
    self = { };
    setmetatable(self, { __index = HeroGuardController });
    self.state = RoleState.STAND;
    self.roleType = ControllerType.HEROGUARD;
    self:_Init(data);
    self:AddBuffs(data.buff);
    self._aiCtrl = GuardAiController:New(self);
    self._site = 1;
    return self;
end

function HeroGuardController:_Init(data)
    self.id = data.id;
    self.info = MonsterInfo:New(data.kind, data.level);
    self:_InitEntity(EntityNamePrefix.HEROGUARD .. self.id, self.info.model_rate);
    self:SetLayer(Layer.Monster);
    self:_LoadModel(GuardModelCreater);
    --self:SetAutoDisappear(data.rt);
end

function HeroGuardController:SetSite(site)
    self._site = site;
end

function HeroGuardController:GetSite()
    return self._site;
end

function HeroGuardController:_DisposeHandler()    
    if (self._aiCtrl) then
        self._aiCtrl:Stop()
        self._aiCtrl = nil;
    end
	if (self._master) then
		self._master:RemoveGuard(self);
		self._master = nil;
	end
end