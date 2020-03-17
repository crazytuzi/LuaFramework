_G.classlist['TransformController'] = 'TransformController';
_G.TransformController = setmetatable({},{__index = IController});

TransformController.list = {};

function TransformController:HasTransform(id)
	local player = nil;
	for nid,model in pairs(self.list) do
		if nid == id then
			player = CharController:GetCharByCid(id);
			break;
		end
	end
	
	return player ~= nil;
end

function TransformController:SetTransform(id,model,immediately)
	if not TianShenConsts:IsModelTransform(model) then
		self:RemoveTransform(id,immediately);
		return;
	end
	
	local config = t_bianshenmodel[model];
	if config then
		self.list[id] = model;
		self:UpdateTransform(id,model,immediately);
		return true;
	else
		self:RemoveTransform(id,immediately);	
	end
end

function TransformController:RemoveTransform(id,immediately)
	local player = nil;
	for nid,model in pairs(self.list) do
		if nid == id then
			player = CharController:GetCharByCid(id);
			break;
		end
	end
	
	if not player then
		return;
	end
	
	self.list[id] = nil;
	player:SetTransformState(false,immediately);
	
end

function TransformController:UpdateTransform(id,model,immediately)
	local player = CharController:GetCharByCid(id);
	if not player then
		return;
	end
	local config = t_bianshenmodel[model];
	player:SetTransformState(config~=nil,immediately);
end

function TransformController:ClearAllTransform(filter)
	filter = filter or 0;
	for id,model in pairs(self.list) do
		if filter ~= id then
			self.list[id] = nil;
		end
	end
end

function TransformController:CreateTransform(avatar)
	local config = self:GetConfigByAvatar(avatar);
	if not config then
		return;
	end
	
	avatar:ChangeSkl(config.skl);
	local mat = _Matrix3D.new();
	local scale = config.model_scale;
	mat:setScaling(scale,scale, scale);
	avatar:GetSkl():adjustRoot(mat);
	avatar:SetPart('Body',config.skn);
end

function TransformController:SetAttackAction(avatar,attack)
	local config = self:GetConfigByAvatar(avatar);
	if not config then
		return;
	end
	
	local idleAnimaName = nil;
	local moveAnimaName = nil;
	
	if attack then
		idleAnimaName = config.san_battle;
		moveAnimaName = config.walk_idle;
	else
		idleAnimaName = config.follow_idle;
		moveAnimaName = config.walk_idle;
	end
	
	if avatar:IsInSpecialState() or StoryController:IsStorying() then
		avatar:SetIdleAction(idleAnimaName, false);
		avatar:SetMoveAction(moveAnimaName);
	else
		avatar:SetIdleAction(idleAnimaName, true);
        avatar:SetMoveAction(moveAnimaName);
    end	
end

function TransformController:PlayLeisureAction(avatar)
	local config = self:GetConfigByAvatar(avatar);
	if not config then
		return;
	end
end

function TransformController:PlayBirthAction(avatar)
	local config = self:GetConfigByAvatar(avatar);
	if not config then
		return;
	end
	avatar:ExecAction(config.bianshen_idle);
end

function TransformController:GetConfigByAvatar(avatar)
	if not avatar then
		return;
	end
	local model = self.list[avatar:GetRoleID()];
	if not model then
		return;
	end
	local config = t_bianshenmodel[model];
	return config;
end

function TransformController:OnChangeSceneMap()
	self:ClearAllTransform();
end





