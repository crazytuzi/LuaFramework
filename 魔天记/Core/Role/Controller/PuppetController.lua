require "Core.Role.Controller.MonsterController";
require "Core.Info.MonsterInfo";
require "Core.Role.ModelCreater.MonsterModelCreater"
require "Core.Role.AI.PetAiController";

PuppetController = class("PuppetController", MonsterController);

function PuppetController:New(data)
	self = {};
	setmetatable(self, {__index = PuppetController});
	self.state = RoleState.STAND;
	self.roleType = ControllerType.PUPPET;
	self:_Init(data);
	self:AddBuffs(data.buff)
	return self;
end

function PuppetController:_Init(data)
	self.id = data.id;
	self.info = MonsterInfo:New(data.kind, data.level);
	self:_InitEntity(EntityNamePrefix.PUPPET .. self.id, self.info.model_rate);
	self:SetLayer(Layer.Monster);
	self:_LoadModel(MonsterModelCreater);
	self:SetAutoDisappear(data.rt);
end

function PuppetController:SetMaster(masterController)
	self._master = masterController;
	if(self.info and masterController) then
		self.info.camp = masterController.info.camp
	end
end

function PuppetController:GetMaster()
	return self._master;
end

function PuppetController:SetActiveByGonfig()
	if(self._roleCreater) then
		self._roleCreater:SetActive(AutoFightManager.GetBaseSettingConfig().showPet and not self:GetIsHide())
	end
end

function PuppetController:GetIsHide()
	return self._master and self._master:IsPetHide() or false
end

function PuppetController:_DisposeHandler()
	if(self._master) then
		self._master:SetPuppet(nil);
		self._master = nil;
	end
end


function PuppetController:StopAI()
	if(self._aiCtrl) then
		self._aiCtrl:Stop();
	end
end


function PuppetController:StartAI()
	if(self._aiCtrl == nil) then
		self._aiCtrl = PetAiController:New(self)
	end
	self._aiCtrl:Start();	
end

-- function PuppetController:SetTarget(target)
-- 	-- 有ai控制的才需要设置目标
-- 	if(self._aiCtrl) then
-- 		self.super.SetTarget(self, target)
-- 	end
-- end 