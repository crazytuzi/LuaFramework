_G.CollectionAvatar = {}
setmetatable(CollectionAvatar, {__index = CAvatar})
local metaCollectionAvatar = {__index = CollectionAvatar}

function CollectionAvatar:NewCollectionAvatar(id, cid)
	local collectionAvatar = CAvatar:new()
	collectionAvatar.avtName = "collectionAvatar"
	collectionAvatar.cid = cid
	collectionAvatar.id = id
	setmetatable(collectionAvatar, metaCollectionAvatar)
	return collectionAvatar
end

function CollectionAvatar:InitAvatar(lrLookId)
	local configId = self.id
	local cfg = t_collection[configId]
	if not cfg then
		Error("don't exist this npc  configId" .. configId)
		return
	end
	
	local modelList = nil
	if cfg.profmodelId and cfg.profmodelId ~= "" then
		modelList = split(cfg.profmodelId, ",")
	end
	
	local lookId = 0
	if modelList and #modelList == 4 then
		local dwProf = MainPlayerModel.humanDetailInfo.eaProf
		lookId = tonumber(modelList[dwProf])
	else
		lookId = cfg.modelId
	end
	
	if lrLookId then lookId = lrLookId end
	self.modelId = lookId
	local look = _G.t_model[lookId]
	if not look then
		Error("don't exist this collection lookid", lookId)
		return
	end
	local sklFile = look.skl
	local sknFile = look.skn
	local defAnima = look.san_idle
	local moveAction = look.san_move

	local meshResource = Assets:GetNpcMesh(sknFile)
	if not meshResource or meshResource == "" then
		Error("Get Collection Mesh Error", sknFile, lookId)
		return
	end
	local sklResource = Assets:GetNpcSkl(sklFile)
	if not sklResource or sklResource == "" then
		Error("Get Collection Skl Error", sklFile, lookId)
		return
	end
	self:SetPart("Body", meshResource)
	self:ChangeSkl(sklResource)

	local defAnimaResource = Assets:GetNpcAnima(defAnima)
	if not defAnimaResource or defAnimaResource == "" then
		Error("Get Collection Anima Error", defAnima, lookId)
	else
		self:SetIdleAction(defAnimaResource, true)
	end

	local moveActionResource = Assets:GetNpcAnima(moveAction)
	if moveActionResource and moveActionResource ~= "" then
		self:SetMoveAction(moveActionResource)
	end

	self.dwSklFile = sklFile
	self.dwSknFile = sknFile
	self.dwDefAnima = defAnima

	local scale = cfg.scale or 1
	self:SetCfgScale(scale)
end

function CollectionAvatar:EnterMap(x, y, faceto)
    local currScene = CPlayerMap:GetSceneMap()
	self:EnterSceneMap(
		currScene,
		_Vector3.new(x, y, 0),
		faceto
	)
	self.objNode.dwType = enEntType.eEntType_Collection
end

function CollectionAvatar:OnEnterScene(objNode)
   objNode.dwType = enEntType.eEntType_Collection
end

function CollectionAvatar:ExitMap()
	self:ExitSceneMap()
	self:Destroy()
end

function CollectionAvatar:MoveAvatar(x, y)
    self:SetPos(_Vector3.new(x, y, 0))
end

function CollectionAvatar:DoAction(animaID, isLoop, callBack)
	local szFile = CResource:GetNpcAnima(animaID)
	if szFile then
		self:ExecAction(szFile, isLoop, callBack)
	end
end

function CollectionAvatar:DoStopAction(animaID)
	 local szFile = CResource:GetNpcAnima(animaID)
	if szFile then
		self:StopAction(szFile)
	end
end

function CollectionAvatar:SetHighLightState(lState)
	self.blState = lState
end

function CollectionAvatar:OnUpdate(e)

end
