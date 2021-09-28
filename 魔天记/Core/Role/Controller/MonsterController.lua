require "Core.Role.Controller.RoleController";
require "Core.Info.MonsterInfo";
require "Core.Role.ModelCreater.MonsterModelCreater"

MonsterController = class("MonsterController", RoleController);

function MonsterController:New(data, isAppear)
	self = {};
	setmetatable(self, {__index = MonsterController});
	self.state = RoleState.STAND;
	self.roleType = ControllerType.MONSTER;
	self.isAppear = isAppear
	self:_Init(data);
	self:AddBuffs(data.buff)
	return self;
end

function MonsterController:_Init(data)
	self.id = data.id;
	self.info = MonsterInfo:New(data.kind, data.level);
	self:_InitEntity(EntityNamePrefix.MONSTER .. self.id, self.info.model_rate);
	self:SetLayer(Layer.Monster);
	self.info.hp = data.hp or 0;
	local creater
	if(GameSceneManager.map) then
		creater = GameSceneManager.map:GetMonsterCreater(data.id)
	end
	
	if(creater) then
		self._roleCreater = creater
		self._roleCreater:Reset(self.info, self.transform, self._roleCreater._role)
	else
		self:_LoadModel(MonsterModelCreater);
	end
	if(data.subj) then
		self.vested = data.subj;
	end
	if(data.rt) then
		self:SetAutoDisappear(data.rt);
	end
	
	-- if(self.isAppear) then
	-- 	local animator = self:GetAnimator()
	-- 	animator.cullingMode = UnityEngine.AnimatorCullingMode.IntToEnum(0)
	-- end
end

function MonsterController:_GetModern()
	return "Roles/Monsters", self.info.model_id;
end

function MonsterController:_OnLoadModelSourceOtherSetting()
	if(self.isAppear) then
		self:SetAnimatorCullingMode(UnityEngine.AnimatorCullingMode.IntToEnum(0))
	end	
end 