_G.classlist['CHorseAvatar'] = 'CHorseAvatar'
_G.CHorseAvatar = {}
CHorseAvatar.objName = 'CHorseAvatar'
setmetatable(CHorseAvatar, {__index = CPlayerAvatar})
local metaHorseAvatar = {__index = CHorseAvatar}

--对应的模型ID，骨骼ID，默认动画
function CHorseAvatar:new()
    print("horse ======== new()")
	local horse = CPlayerAvatar:new()
	horse.avtName = "horse"
    setmetatable(horse, metaHorseAvatar)
    return horse
end

function CHorseAvatar:Create(modelId, profId)
    self.modelId = modelId
    local mountConfig = t_mountmodel[modelId]
	local szSklFile = mountConfig.skl_scene
    local sknFile = mountConfig.skn_scene
    self:SetPart("Body", sknFile)
    self:ChangeSkl(szSklFile)
	
	local scale = mountConfig['scale_pro'..tostring(profId)] or 0;
	if scale == 0 then
		scale = mountConfig.scale;
	end	
	if scale > 0 then
		local mat = _Matrix3D.new();
		mat:setScaling(scale, scale, scale);
		self.objSkeleton:adjustRoot(mat);
	end
	
    self.objMesh.name ="horse"
    if profId then
        self.selfName = mountConfig["name_self"]
        self.otherName = mountConfig["name_other" .. profId]
    end
	self:SetAttackAction(self.bIsAttack)
	return true
end

function CHorseAvatar:GetModelID()
	return self.modelId
end

function CHorseAvatar:GetMoveMusic()
    local modelId = self.modelId
    local mountConfig = t_mountmodel[modelId]
    return mountConfig.sound_id
end

function CHorseAvatar:GetLevel()
    return self.Level
end

function CHorseAvatar:SetAttackAction(bIsAttack)
    self.bIsAttack = bIsAttack
    if self.bIsAttack then
		self.dwIdleAnimaID = RoleConfig.horse_attack_idle_san
		self.dwMoveAnimaID = RoleConfig.horse_attack_move_san
	else
		self.dwIdleAnimaID = RoleConfig.horse_idle_san
		self.dwMoveAnimaID = RoleConfig.horse_move_san
	end
	self:StartDefAction()
end

function CHorseAvatar:StartDefAction()
	local idleAnimaName = self:GetAnimaFile(RoleConfig.horse_san_map[self.dwIdleAnimaID])
	if not idleAnimaName then
        assert(false, self.dwIdleAnimaID)
	end
    local moveAnimaName = self:GetAnimaFile(RoleConfig.horse_san_map[self.dwMoveAnimaID])
	if not moveAnimaName then
        assert(false)
	end
    if self:IsInSpecialState() then
		self:SetIdleAction(idleAnimaName, false)
		self:SetMoveAction(moveAnimaName, false)
    else
        self:SetIdleAction(idleAnimaName, true)
        self:SetMoveAction(moveAnimaName, self.bMoveing)
    end
end

function CHorseAvatar:GetAnimaFile(sanId)
    assert(sanId, "sanId can't be null")
    local result = 0;
	local modelConfig = t_mountmodel[self.modelId]
    assert(modelConfig, "fuck no modelConfig", self.modelId)
    return modelConfig[sanId]
end

function CHorseAvatar:DoAction(szFile, isLoop, callBack)
	if szFile then
		self:ExecAction(szFile, isLoop, callBack)
	end
end