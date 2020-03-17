
_G.MapScriptNodeAvatar = {}
setmetatable(MapScriptNodeAvatar, {__index = CAvatar})
local metaMapScriptNodeAvatar = {__index = MapScriptNodeAvatar}

function MapScriptNodeAvatar:Create(modelId)
	local mapScriptNodeAvatar = CAvatar:new()
	local look = t_model[modelId]
	if not look then
		return
	end
	local sklFile = look.skl
	local sknFile = look.skn
	local subSknFile = look.sub_skn
	local idleAnima = look.san_idle
	local defAnima = look.san_walk	
	local meshResource = Assets:GetNpcMesh(sknFile)
	if not meshResource or meshResource == "" then
		Error("Get Npc Mesh Error", sknFile, modelId)
		return
	end
	local sklResource = Assets:GetNpcSkl(sklFile)
	if not sklResource or sklResource == "" then
		Error("Get Npc Skl Error", sklFile, modelId)
		return
	end
	mapScriptNodeAvatar:AddSubMesh(subSknFile)
	mapScriptNodeAvatar:SetPart("Body", meshResource)
	mapScriptNodeAvatar:ChangeSkl(sklResource)

	local idleAnimaResource = Assets:GetNpcAnima(idleAnima)
	if not idleAnimaResource or idleAnimaResource == "" then
		Error("Get Npc Anima Error", idleAnima, modelId)
	else
		mapScriptNodeAvatar:SetIdleAction(idleAnimaResource, true)
	end

	local defAnimaResource = Assets:GetNpcAnima(defAnima)
	if not defAnimaResource or defAnimaResource == "" then
		Error("Get Npc Anima Error", defAnima, modelId)
	else
		mapScriptNodeAvatar:SetMoveAction(defAnimaResource, true)
	end
	setmetatable(mapScriptNodeAvatar, metaMapScriptNodeAvatar)
	return mapScriptNodeAvatar
end

local axis = _Vector3.new(0,0,1)
function MapScriptNodeAvatar:Init(configInfo)
	local avatar = MapScriptNodeAvatar:Create(configInfo.modelId)
	if not avatar then
		return
	end
	local x, y
	if configInfo.type == 1 then
		avatar.orbit = _Orbit.new()
		avatar:ExecMoveAction()
		x, y = configInfo.point[1].pos.x, configInfo.point[1].pos.x
	elseif configInfo.type == 2 then
		avatar.resttime = configInfo.resttime
		x, y = configInfo.point[1].x, configInfo.point[1].y
		avatar.RotateTime = 500
	elseif configInfo.type == 3 then
		avatar.range = configInfo.range
		avatar.resttime = configInfo.resttime
		x, y = configInfo.point.x, configInfo.point.y
		avatar.RotateTime = 500
	elseif configInfo.type == 4 then
		avatar.resttime = configInfo.resttime
		x, y = configInfo.point[1].x, configInfo.point[1].y
		avatar.RotateTime = 500
	end
	avatar.point = configInfo.point
	avatar.speed = configInfo.speed
	avatar.nodeType = configInfo.type
	avatar:EnterMap(x, y)
	avatar.objMesh.transform:mulScalingLeft(configInfo.scale, configInfo.scale, configInfo.scale)
	if configInfo.type == 4 then
		avatar.objMesh.transform:mulScalingLeft(1, -1, 1)
		avatar.objMesh.transform:mulRotationLeft(axis, math.pi)
	end
	return avatar
end

function MapScriptNodeAvatar:EnterMap(x, y)
    local currScene = CPlayerMap:GetSceneMap()
	self:EnterSceneMap(
		currScene,
		_Vector3.new(x, y, 0),
		0
	)
	self.objNode.dwType = enEntType.eEntType_Monster
	self.objNode.needRealShadow = false
end

function MapScriptNodeAvatar:OnEnterScene(objNode)
   objNode.dwType = enEntType.eEntType_Monster
end

function MapScriptNodeAvatar:ExitMap()
	self:ExitSceneMap()
	self:Destroy()
end

function MapScriptNodeAvatar:MoveToPathList()
	if not self:IsMoveState() and self:CheckRestTime() then
		self.currPointIndex = self.currPointIndex and self.currPointIndex + 1 or 1
		self.currPointIndex = (self.currPointIndex <= #self.point) and self.currPointIndex or 1
		local pos = self.point[self.currPointIndex]
		self:MoveToPos(pos)
	end
end

function MapScriptNodeAvatar:MoveToOrbit()
	if self.orbit.over == true then
		self.orbit:create(self.point)
	end
	self.orbit:update(self.speed)
	local pos = self:GetPos()
	self.objNode.transform:setTranslation(self.orbit.pos.x, self.orbit.pos.y, self.orbit.pos.z)
	self.objNode.transform:mulFaceToLeft(0, -1, 0, self.orbit.pos.x - pos.x, self.orbit.pos.y - pos.y, self.orbit.pos.z - pos.z)
end

function MapScriptNodeAvatar:MoveToRandomPos()
	if not self:IsMoveState() and self:CheckRestTime() then
		local pos = {}
		pos.x = self.point.x + math.random(-self.range, self.range)
		pos.y = self.point.y + math.random(-self.range, self.range)
		self:MoveToPos(pos)
	end
end

function MapScriptNodeAvatar:MoveToPos(pos)
	local speed = self.speed
	self:MoveTo(pos, function()
		if self.resttime >= 0 then
			self:StopMoveAction()
			self:SetRestTime()
		end
		self.moveState = false
	end, speed, nil, true)
	self:ExecMoveAction()
end

function MapScriptNodeAvatar:UpdatePos(dwInterval)
	if self.nodeType == 1 then
		self:MoveToOrbit(dwInterval)
	elseif self.nodeType == 2 then
		self:Update(dwInterval)
		self:MoveToPathList()
	elseif self.nodeType == 3 then
		self:Update(dwInterval)
		self:MoveToRandomPos()
	elseif self.nodeType == 4 then
		self:Update(dwInterval)
		self:MoveToPathList()
	end
end

function MapScriptNodeAvatar:IsMoveState()
	return self.moveState
end

function MapScriptNodeAvatar:SetRestTime()
	self.nextMoveTime = GetCurTime() + self.resttime
end

function MapScriptNodeAvatar:CheckRestTime()
	if self.resttime <= 0 then
		return true
	end
	if not self.nextMoveTime then
		return true
	end
	if self.nextMoveTime < GetCurTime() then
		return true
	end
	return false
end

function MapScriptNodeAvatar:IsDrawDecal()
	if self.nodeType == 1 then
		return false
	end
	return true
end