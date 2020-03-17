_G.classlist['NpcAvatar'] = 'NpcAvatar'
_G.NpcAvatar = {}
NpcAvatar.objName = 'NpcAvatar'
setmetatable(NpcAvatar, {__index = CAvatar})
local metaNpcAvatar = {__index = NpcAvatar}

function NpcAvatar:NewNpcAvatar(npcId, cid)
	local npcAvatar = CAvatar:new()
	npcAvatar.avtName = "npcAvatar"
	npcAvatar.cid = cid
	npcAvatar.npcId = npcId
	setmetatable(npcAvatar, metaNpcAvatar)
	return npcAvatar
end

function NpcAvatar:InitAvatar()

	local npcId = self.npcId
	local cfgNpc = t_npc[npcId]
	if not cfgNpc then
		Error("don't exist this npc  npcId", npcId)
		return
	end
	local lookId = cfgNpc.look
	local scale = cfgNpc.scale or 1
	local look = _G.t_model[lookId]
	if not look then
		Error("don't exist this npc lookid", lookId)
		return
	end

	local sklFile = look.skl
	local sknFile = look.skn
	local subSknFile = look.sub_skn
	local defAnima = look.san_idle
	local moveAction = look.san_move or look.san_idle
	
	local meshResource = Assets:GetNpcMesh(sknFile)
	if not meshResource or meshResource == "" then
		Error("Get Npc Mesh Error", sknFile, lookId)
		return
	end
	local sklResource = Assets:GetNpcSkl(sklFile)
	if not sklResource or sklResource == "" then
		Error("Get Npc Skl Error", sklFile, lookId)
		return
	end

	self:AddSubMesh(subSknFile)
	self:SetPart("Body", meshResource)
	self:ChangeSkl(sklResource)
	
	local defAnimaResource = Assets:GetNpcAnima(defAnima)
	if not defAnimaResource or defAnimaResource == "" then
		Error("Get Npc Anima Error", defAnima, lookId)
	else
		self:SetIdleAction(defAnimaResource, true)
	end
	local moveActionResource = Assets:GetNpcAnima(moveAction)
	if moveActionResource and moveActionResource ~= "" then
		self:SetMoveAction(moveActionResource)
	end
	
	self.dwNpcID = npcId
	self.dwSklFile = sklFile
	self.dwSknFile = sknFile
	self.dwDefAnima = defAnima
	self:SetCfgScale(scale)
end

function NpcAvatar:EnterMap(x, y, faceto, offsetZ)
    local currScene = CPlayerMap:GetSceneMap()
	local offZ = offsetZ or 0
	self:EnterSceneMap(
		currScene,
		_Vector3.new(x, y, offZ),
		faceto
	)
	self.objNode.dwType = enEntType.eEntType_Npc
	self.objNode.pickFlag = t_npc[self.npcId].open_dialog and enPickFlag.EPF_Role or nil;
end

function NpcAvatar:OnEnterScene(objNode)
	objNode.dwType = enEntType.eEntType_Npc
	objNode.pickFlag = t_npc[self.npcId].open_dialog and enPickFlag.EPF_Role or nil;
end

function NpcAvatar:ExitMap()
	self:ExitSceneMap()
	self:Destroy()
end
local newPos = _Vector3.new()
function NpcAvatar:MoveAvatar(x, y)
	newPos.x = x; newPos.y = y
    self:SetPos(newPos)
end

function NpcAvatar:DoAction(animaID, isLoop, callBack)
	local szFile = Assets:GetNpcAnima(animaID)
	if szFile then
		self:ExecAction(szFile, isLoop, callBack)
	end
end

function NpcAvatar:DoStopAction(animaID)
	 local szFile = Assets:GetNpcAnima(animaID)
	if szFile then
		self:StopAction(szFile)
	end
end

function NpcAvatar:SetHighLightState(lState)
	self.blState = lState
end

function NpcAvatar:OnUpdate(e)

end
