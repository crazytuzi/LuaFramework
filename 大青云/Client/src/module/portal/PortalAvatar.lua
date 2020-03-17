_G.PortalAvatar = {}
setmetatable(PortalAvatar, {__index = CAvatar})
local metaPortalAvatar = {__index = PortalAvatar}

function PortalAvatar:NewPortalAvatar(id, cid)
	local avatar = CAvatar:new()
	avatar.cid = cid
	avatar.id = id
	setmetatable(avatar, metaPortalAvatar)
	return avatar
end

function PortalAvatar:InitAvatar()
	local id = self.id
	local cfg = t_portal[id]
	if not cfg then
		Error("don't exist this portal === id ", id)
		return
	end
	local modelId = cfg.modelId
	local look = t_model[modelId]
	if not look then
		Error("don't exist this portal === lookid ", modelId)
		return
	end

	local sklFile = look.skl
	local sknFile = look.skn
	self:SetPart("Body", sknFile)
	self:ChangeSkl(sklFile)
end

function PortalAvatar:EnterMap(x, y)
    local currScene = CPlayerMap:GetSceneMap()
	self:EnterSceneMap(
		currScene,
		_Vector3.new(x, y, 0),
		0
	)
	self.objNode.dwType = enEntType.eEntType_Portal
end

function PortalAvatar:OnEnterScene(objNode)
   objNode.dwType = enEntType.eEntType_Portal
end

function PortalAvatar:ExitMap()
	self:ExitSceneMap()
	self:Destroy()
end