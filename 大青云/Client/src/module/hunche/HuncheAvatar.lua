_G.HuncheAvatar = {}
setmetatable(HuncheAvatar, {__index = CAvatar})
local metaHuncheAvatar = {__index = HuncheAvatar}

function HuncheAvatar:New(id, cid)
	local avatar = CAvatar:new()
	avatar.avtName = "huncheavatar"
	avatar.cid = cid
	avatar.id = id
	setmetatable(avatar, metaHuncheAvatar)
	return avatar
end

function HuncheAvatar:InitAvatar()
	local look = self:GetModel()
	if not look then
		Error("don't exist this hunche lookid", self.id)
		return
	end

	local sklFile = look.skl
	local sknFile = look.skn
	local defAnima = look.san_idle
	local moveAction = look.san_move
	
	local meshResource = Assets:GetNpcMesh(sknFile)
	if not meshResource or meshResource == "" then
		Error("Get hunche Mesh Error", sknFile, lookId)
		return
	end

	local sklResource = Assets:GetNpcSkl(sklFile)
	if not sklResource or sklResource == "" then
		Error("Get hunche Skl Error", sklFile, lookId)
		return
	end

	self:SetPart("Body", meshResource)
	self:ChangeSkl(sklResource)
	
	local defAnimaResource = Assets:GetNpcAnima(defAnima)
	if defAnimaResource or defAnimaResource == "" then
		self:SetIdleAction(defAnimaResource, true)
	end

	local moveActionResource = Assets:GetNpcAnima(moveAction)
	if moveActionResource and moveActionResource ~= "" then
		self:SetMoveAction(moveActionResource)
	end
end

function HuncheAvatar:GetConfig()
	return t_patrol[self.id]
end

function HuncheAvatar:GetModel()
	local config = self:GetConfig()
	if not config then
		return
	end
	local modelId = config.modelid
	if not modelId then
		return
	end
	return t_model[modelId]
end

function HuncheAvatar:EnterMap(x, y, faceto)
    local currScene = CPlayerMap:GetSceneMap()
	self:EnterSceneMap(
		currScene,
		_Vector3.new(x, y, 0),
		faceto
	)
	self.objNode.dwType = enEntType.eEntType_Patrol

	self:AddMan()
	self:AddWoman()
end

function HuncheAvatar:OnEnterScene(objNode)
   objNode.dwType = enEntType.eEntType_Patrol
end

function HuncheAvatar:ExitMap()
	self:ExitSceneMap()
	self:Destroy()
	self.nanAvatar = nil
	self.nvAvatar = nil
end

function HuncheAvatar:AddMan()
	local config = self:GetConfig()
	local look = t_model[config.prof2] or t_model[config.prof3]
	if not look then
		return
	end
	local avatar = CAvatar:new()
	local skl = look.skl
	local skn = look.skn
	local san = look.san_idle
    avatar:SetPart("Body", skn)
    avatar:ChangeSkl(skl)
    avatar:ExecAction(san, true)
    local boneMat = self:GetSkl():getBone("nan")
	avatar.objMesh.transform = boneMat
    self.objMesh:addSubMesh(avatar.objMesh)
    self.nanAvatar = avatar

    self:PlayerPfxOnSkeleton("jiehun_renzuluoli_baoxifu_2.pfx")

end

function HuncheAvatar:AddWoman()
	local config = self:GetConfig()
	local look = t_model[config.prof1] or t_model[config.prof4]
	if not look then
		return
	end
	local avatar = CAvatar:new()
	local skl = look.skl
	local skn = look.skn
	local san = look.san_idle
    avatar:SetPart("Body", skn)
    avatar:ChangeSkl(skl)
    avatar:ExecAction(san, true)
    local boneMat = self:GetSkl():getBone("nv")
	avatar.objMesh.transform = boneMat
    self.objMesh:addSubMesh(avatar.objMesh)
    self.nvAvatar = avatar
end