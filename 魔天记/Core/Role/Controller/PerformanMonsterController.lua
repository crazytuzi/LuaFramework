require "Core.Role.Controller.RoleController";
require "Core.Info.MonsterInfo";
require "Core.Role.ModelCreater.MonsterModelCreater"
require "Core.Role.Action.AppearAction"

PerformanMonsterController = class("PerformanMonsterController", RoleController);

function PerformanMonsterController:New(data)
	self = {};
	setmetatable(self, {__index = PerformanMonsterController});
	self.state = RoleState.STAND;
	self.roleType = ControllerType.PERFORMANCE;
	self:_Init(data);
	return self;
end

function PerformanMonsterController:_Init(data)
	self.id = data.id;
	self.info = MonsterInfo:New(data.kind);
	self:_InitEntity(EntityNamePrefix.PERFORMANCE .. self.id, self.info.model_rate);
	self:SetLayer(Layer.Monster);
	self:_LoadModel(MonsterModelCreater);
	
	local animator = self:GetAnimator()
	if(animator) then
		animator.cullingMode = UnityEngine.AnimatorCullingMode.IntToEnum(0)
	end
end

function PerformanMonsterController:_LoadModel(creater)
	local roleCreate = creater:New(self.info, self.transform, false)
	self._roleCreater = roleCreate
end



function PerformanMonsterController:_GetModern()
	return "Roles/Monsters", self.info.model_id;
end

function PerformanMonsterController:ClearRoleCreater()
	self._roleCreater = nil
end