require "Core.Role.Controller.RoleController";
require "Core.Role.ModelCreater.PetModelCreater";
require "Core.Role.Action.SendCmd.SendMoveToAction"
require "Core.Role.Action.SendCmd.SendMoveToTargetAction"
require "Core.Role.AI.PetAiController";
require "Core.Info.PetInfo";

HeroPetController = class("HeroPetController", RoleController);

function HeroPetController:New(info)
	self = {};
	setmetatable(self, {__index = HeroPetController});
	self.state = RoleState.STAND;
	self.roleType = ControllerType.HEORPET;
	self:_Init(info);
	self._master = nil;
	return self;
end

function HeroPetController:_Init(info)
	self.id = info.id;
	self.info = info;
	self:_InitEntity(EntityNamePrefix.HEORPET .. self.id);
	self:SetLayer(Layer.Monster);
	self:_LoadModel(PetModelCreater);
	-- 移到外部调用
	-- self:SetActiveByGonfig()
	self._aiCtrl = PetAiController:New(self);
end

function HeroPetController:SetActiveByGonfig()
	if(self._roleCreater) then
		self._roleCreater:SetActive(AutoFightManager.GetBaseSettingConfig().showPet and not self:GetIsHide())
	end
end

function HeroPetController:GetIsHide()
	return self._master and self._master:IsPetHide() or false
end


function HeroPetController:StartAI()
	if(self._aiCtrl) then 
		self._aiCtrl:Start();
	end 
end

function HeroPetController:StopAI()
	if(self._aiCtrl) then
		self._aiCtrl:Stop();
	end
end

function HeroPetController:SetMaster(masterController)
	self._master = masterController;
end

function HeroPetController:GetMaster()
	return self._master;
end

function HeroPetController:Pause()
	if(self._aiCtrl) then
		self._aiCtrl:Pause()
	end
	AbsController.Pause(self);
end


function HeroPetController:Resume()
	if(self._aiCtrl) then
		self._aiCtrl:Resume()
	end
	AbsController.Resume(self);
end

function HeroPetController:_GetModern()
	return "Roles/Monsters", self.info.model_id;
end

function HeroPetController:MoveTo(pt, map)
	if(not self:IsDie()) then
		self:StopAction(3);
		self:DoAction(SendMoveToAction:New(pt, map))
	end
end

function HeroPetController:MoveToTarget(target, blRandom, distance)
	if(not self:IsDie()) then
		self:StopAction(3);
		self:DoAction(SendMoveToTargetAction:New(target, blRandom, distance))
	end
end
 
-- 待机
function HeroPetController:Stand(position, angle)
	if(not self:IsDie()) then
		self:StopAction(3);
		self:DoAction(SendStandAction:New(position, angle));
	end
end

function HeroPetController:_DisposeHandler()
	if(self._aiCtrl) then
		self._aiCtrl:Stop()
		self._aiCtrl = nil;
	end
	if(self._master) then
		self._master:SetPet(nil);
		self._master = nil;
	end
end

function HeroPetController:UpdatePetRank(data)
	if(self.info) then
		self.info:UpdateRank(data.star)
	end
end

function HeroPetController:ChangeModel(id)
	self.info:UpdatePetFasionInfo(id)
	if self._roleCreater then
		self._roleCreater:Dispose();
		self._roleCreater = nil;
	end
	
	if(self.namePanel) then
		self:_DisposeNamePanel()
	end
	
	self:_LoadModel(PetModelCreater);
	RoleNamePanel.Add(self);
end 