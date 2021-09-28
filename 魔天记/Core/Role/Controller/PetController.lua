require "Core.Role.Controller.RoleController";
require "Core.Role.ModelCreater.PetModelCreater";
require "Core.Info.PetInfo";
require "Core.Role.AI.PetAiController";

PetController = class("PetController", RoleController);

function PetController:New(data)
	self = {};
	setmetatable(self, {__index = PetController});
	self.state = RoleState.STAND;
	self.roleType = ControllerType.PET;
	self._master = nil;
	self:_Init(data);
	-- self:AddBuffs(data.buff)
	return self;
end

function PetController:_Init(data)
	self.id = data.id;
	if(data and data.__cname == "PetInfo") then
		self.info = data;
	else
		self.info = PetInfo:New(data, true);
	end
	self:_InitEntity(EntityNamePrefix.PET .. self.id);
	self:SetLayer(Layer.Monster);
	self:_LoadModel(PetModelCreater);
end


function PetController:StopAI()
	if(self._aiCtrl) then
		self._aiCtrl:Stop();
	end
end

function PetController:StartAI()	
	if(self._aiCtrl == nil) then
		self._aiCtrl = PetAiController:New(self)
	end
	self._aiCtrl:Start();	
    log("StartAI")
end

function PetController:SetActiveByGonfig()
	if(self._roleCreater) then
		self._roleCreater:SetActive(AutoFightManager.GetBaseSettingConfig().showPet and not self:GetIsHide())
	end
end

function PetController:GetIsHide()
	return self._master and self._master:IsPetHide() or false
end

function PetController:SetMaster(masterController)
	self._master = masterController;
end

function PetController:GetMaster()
	return self._master;
end

function PetController:_GetModern()
	return "Roles/Monsters", self.info.model_id;
end

function PetController:_DisposeHandler()
	if(self._master) then
		self._master:SetPet(nil);
		self._master = nil;
	end
end

function PetController:ChangeModel(id)
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

-- function PetController:SetTarget(target)
-- 	-- 有ai控制的才需要设置目标
-- 	if(self._aiCtrl) then
-- 		self.super.SetTarget(self, target)
-- 	end
-- end 