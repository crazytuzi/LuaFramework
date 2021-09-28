require "Core.Role.Controller.PlayerController";
require "Core.Role.AI.HireAIController";

HirePlayerController = class("HirePlayerController", PlayerController);

function HirePlayerController:New(data)
    self = { };
    setmetatable(self, { __index = HirePlayerController });
    self.state = RoleState.STAND;
    self.roleType = ControllerType.HIRE;
    self._guards = {}
    self:_Init(data);
    self:AddBuffs(data.buff)
    self._aiCtrl = HireAIController:New(self);
    return self;
end

function HirePlayerController:_Init(data)
    self.id = data.id;
    self.info = HeroInfo:New(data);
    if (data.dress and data.dress.m ~= 0) then
        self._isRideHide = true
    end
    self:_InitEntity(EntityNamePrefix.HIRE .. self.id);
    self:SetLayer(Layer.Player);
    self:_LoadModel(RoleModelCreater);
    self._isFight = false;
    -- self:SetRideTimer()
    if (self.info.hp == 0) then
        self:Die()
    end
end

function HirePlayerController:SetMaster(masterController)
    self._master = masterController;
    self:SetMainControl(true);
end

function HirePlayerController:GetMaster()
    return self._master;
end

function HirePlayerController:SetMainControl(val)
    self.isMainControl = val;
end

function HirePlayerController:StartAI()
    if (self._aiCtrl) then
        self._aiCtrl:Start();
    end
end

function HirePlayerController:StopAI()
    if (self._aiCtrl) then
        self._aiCtrl:Stop();
    end
end

function HirePlayerController:Pause()
    if (self._aiCtrl) then
        self._aiCtrl:Pause()
    end
    AbsController.Pause(self);
end


function HirePlayerController:Resume()
    if (self._aiCtrl) then
        self._aiCtrl:Resume()
    end
    AbsController.Resume(self);
end

function HirePlayerController:_DisposeHandler()    
    if (self._aiCtrl) then
        self._aiCtrl:Stop()
        self._aiCtrl = nil;
    end    
    self:StopFightStatusTimer();
    if (self._master) then
		self._master:RemoveHire(self);
		self._master = nil;
	end
end