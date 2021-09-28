require "Core.Role.Controller.RoleController";
require "Core.Info.NpcInfo";
require "Core.Role.ModelCreater.NpcModelCreater"

NpcController = class("NpcController", RoleController);
NpcController.State =
{
	Fighting = 1,
	NotFight = 0,
	FinishFight = - 1,
	Hide = - 2,
}
function NpcController:New(id, asyncLoad)
	self = {};
	setmetatable(self, {__index = NpcController});
	self.state = RoleState.STAND;
	self.roleType = ControllerType.NPC;
	self.asyncLoad = asyncLoad
	self:_Init(id);
	return self;
end

function NpcController:_Init(id)
	self.id = id;
	self.info = NpcInfo:New(id);
	self:_InitEntity("npc_" .. id);
	self:SetLayer(Layer.NPC);
	--self:_LoadModel(NpcModelCreater);
end
--??????????
function NpcController:CheckLoadModel()
	if self._roleCreater or self._dispose then return end
	self:_LoadModel(NpcModelCreater)
end

function NpcController:_LoadModel(creater)
	local roleCreate = creater:New(self.info, self.transform, self.asyncLoad, function(val) self:_OnLoadModelSource(val) end)
	roleCreate.controller = self
	self._roleCreater = roleCreate
end

function NpcController:_GetModern()
	return "Roles/Monsters", self.info.model_id;
end

function NpcController:SetNpcState(state)
	
	self.info:SetNpcState(state)
	if(state == NpcController.State.Fighting) then
		if(self.stateEffect == nil) then
			self.stateEffect = Resourcer.Get("Effect/BuffEffect", "buff_atk_add")
			if(self._roleCreater:GetTop()) then
				self.stateEffect.transform:SetParent(self._roleCreater:GetTop())
				Util.SetLocalPos(self.stateEffect, 0, 0, 0)
				--                self.stateEffect.transform.localPosition = Vector3.zero
			end
		end
	else
		if(self.stateEffect) then
			Resourcer.Recycle(self.stateEffect)
			self.stateEffect = nil
		end
	end
end

function NpcController:GetNpcState()
	return self.info.GetNpcState()
end

function NpcController:_DisposeHandler()
	if(self.stateEffect) then
		Resourcer.Recycle(self.stateEffect)
		self.stateEffect = nil
	end
end

function NpcController:_OnLoadModelSource(model)
	if(self.stateEffect) then
		self.stateEffect.transform:SetParent(self._roleCreater:GetTop())
		Util.SetLocalPos(self.stateEffect, 0, 0, 0) 
	end
end 