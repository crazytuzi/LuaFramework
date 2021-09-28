require "Core.Role.Controller.PuppetController";
require "Core.Role.AI.PetAiController";

HeroPuppetController = class("HeroPuppetController", PuppetController);

function HeroPuppetController:New(data)
    self = { };
    setmetatable(self, { __index = HeroPuppetController });
    self.state = RoleState.STAND;
    self.roleType = ControllerType.HEROPUPPET;
    self:_Init(data);
    self:AddBuffs(data.buff);
    self._aiCtrl = PetAiController:New(self);
    return self;
end

-- function HeroPuppetController:StartAI()
--     if (self._aiCtrl) then
--         self._aiCtrl:Start();
--     end
-- end


function HeroPuppetController:Pause()
    if (self._aiCtrl) then
        self._aiCtrl:Pause()
    end
    AbsController.Pause(self);
end


function HeroPuppetController:Resume()
    if (self._aiCtrl) then
        self._aiCtrl:Resume()
    end
    AbsController.Resume(self);
end

function HeroPuppetController:MoveTo(pt, map)
    if (not self:IsDie()) then
        self:StopAction(3);
        self:DoAction(SendMoveToAction:New(pt, map))
    end
end

function HeroPuppetController:MoveToTarget(target,blRandom,distance)
    if (not self:IsDie()) then
        self:StopAction(3);
        self:DoAction(SendMoveToTargetAction:New(target,blRandom,distance))
    end
end
 
-- 待机
function HeroPuppetController:Stand(position, angle)
    if (not self:IsDie()) then
        self:StopAction(3);
        self:DoAction(SendStandAction:New(position, angle));
    end
end

function HeroPuppetController:_DisposeHandler()    
    if (self._aiCtrl) then
        self._aiCtrl:Stop()
        self._aiCtrl = nil;
    end
	if (self._master) then
		self._master:SetPuppet(nil);
		self._master = nil;
	end
end