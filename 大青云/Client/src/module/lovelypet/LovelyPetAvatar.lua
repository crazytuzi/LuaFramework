_G.LovelyPetAvatar = {}
setmetatable(LovelyPetAvatar, {__index = CAvatar})
local metaLovelyPetAvatar = {__index = LovelyPetAvatar}

function LovelyPetAvatar:Create(modelId)
	local look = t_petmodel[modelId]
	if not look then
		return
	end
	local sklFile = look.skl
	local sknFile = look.skn
	local defAnima = look.follow_idle
	local moveAnima = look.walk_idle
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

	local lovelyPetAvatar = CAvatar:new()
	lovelyPetAvatar:SetPart("Body", meshResource)
	lovelyPetAvatar:ChangeSkl(sklResource)

	local defAnimaResource = Assets:GetNpcAnima(defAnima)
	if not defAnimaResource or defAnimaResource == "" then
		Error("Get Npc Anima Error", defAnima, lookId)
	else
		lovelyPetAvatar:SetIdleAction(defAnimaResource, true)
	end

	local moveAnimaResource = Assets:GetNpcAnima(moveAnima)
	if not moveAnimaResource or moveAnimaResource == "" then
		Error("Get Npc Anima Error", moveAnima, lookId)
	else
		lovelyPetAvatar:SetMoveAction(moveAnimaResource, false)
	end
	lovelyPetAvatar.pickFlag = enPickFlag.EPF_Null
	lovelyPetAvatar.modelId = modelId
	setmetatable(lovelyPetAvatar, metaLovelyPetAvatar)
	return lovelyPetAvatar
end

function LovelyPetAvatar:EnterMap(x, y)
    local currScene = CPlayerMap:GetSceneMap()
	self:EnterSceneMap(
		currScene,
		_Vector3.new(x, y, 0),
		0
	)
	self.objNode.dwType = enEntType.eEntType_Pet
end

function LovelyPetAvatar:OnEnterScene(objNode)
   objNode.dwType = enEntType.eEntType_Pet
end

function LovelyPetAvatar:ExitMap()
	self:ExitSceneMap()
	self:Destroy()
end

local dis = _Vector3.new()
function LovelyPetAvatar:UpdatePos(dwInterval)
	self:DrawNameBoard()

	if not self:IsMoveState() then
		if not self.leisureTime then
			self.leisureTime = GetCurTime()
		end
	else
		self.leisureTime = nil
	end
	self:Leisure()
	if not self.mwDiff then
		self.mwDiff = _Vector3.new()
	end
	local player = self:GetOwner()
	local pos = player:GetPos()
	local selfPos = self:GetPos()
	if not pos then
		return
	end
	if not selfPos then
		return
	end
	_Vector3.sub(pos, selfPos, self.mwDiff)
	self.mwDiff.z = 0
	local dis = self.mwDiff:magnitude()
	if dis > 25 then
		local player = self:GetOwner()
		if player:IsSelf() then
			self:SelfWantMoveto()
		else
			self:OtherWantMoveto()
		end
		local player = self:GetOwner()
		if not player:IsMoveState() 
			and not self.moveInfo
			and not self.pathList
			and not self:IsMoveState() then
			self:DoStopMove()
		end
	end
	if dis > 150 then
		local x = pos.x + math.random(15, 20) * (math.random(-1, 1) > 0 and 1 or -1)
		local y = pos.y + math.random(15, 20) * (math.random(-1, 1) > 0 and 1 or -1)
		self:SetPos({x = x, y = y})
	end
	self:Update(dwInterval)
end

function LovelyPetAvatar:Leisure()
	if not self.leisureTime then
		return
	end
	local nowTime = GetCurTime()
	if nowTime - self.leisureTime < 5000 then
		return
	end
	self.leisureTime = nowTime
	if math.random(-1, 1) > 0 then
		local player = self:GetOwner()
		local playerPos = player:GetPos()
		if not self.speed then
			self.speed = player:GetSpeed()
		end
		local pos = {}
		pos.x = playerPos.x + math.random(15, 20) * (math.random(-1, 1) > 0 and 1 or -1)
		pos.y = playerPos.y + math.random(15, 20) * (math.random(-1, 1) > 0 and 1 or -1)
		self:MoveToPos(pos)
	else
		local modelId = self.modelId
		local look = t_petmodel[modelId]
		if not look then
			return
		end
		local animaFile = nil
		local animas = {look.san_idle, look.san_idle_1, look.san_idle_2, look.san_idle_3}
		animaFile = animas[math.random(#animas)];

		if animaFile and animaFile ~= "" then
			self:ExecAction(animaFile, false)
		end
	end
end

function LovelyPetAvatar:GetOwner()
	local player = CPlayerMap:GetPlayer(self.ownerId)
	return player
end

function LovelyPetAvatar:SelfWantMoveto()
	if self.moveInfo then
		local dis = math.random(15, 20)
		local selfPos = self:GetPos()
		local pos = {}
		local pathList, ret = nil, nil
		if CPlayerControl.lstPathLine 
			and CPlayerControl.dwCurLineIndex < #CPlayerControl.lstPathLine then
			pos.x = self.moveInfo.x
			pos.y = self.moveInfo.y
			pathList, ret = AreaPathFinder:GetPathLine(selfPos, pos)
		else
			local dir = GetDirTwoPoint(selfPos, self.moveInfo) - (math.pi / 4) * (math.random(-1, 1) > 0 and 1 or -1)
			for i = 0, 3 do
				dir = dir + i * (math.pi / 2)
				local temp = dir
				if temp < 0 then
		        	temp = 2 * math.pi + temp
		    	end
				if temp > 2 * math.pi then
					temp = temp - 2 * math.pi
				end
				pos.x = self.moveInfo.x + dis * math.sin(temp)
				pos.y = self.moveInfo.y - dis * math.cos(temp)
				pathList, ret = AreaPathFinder:GetPathLine(selfPos, pos)
				if ret and pathList and #pathList > 1 then
					break
				end
			end
		end
		if ret and pathList and #pathList > 1 then
			self.pathList = pathList
			table.remove(self.pathList, 1)
			self:MoveToPathList(true)
		else
			self.pathList = nil
			self:MoveToPos(pos)
		end
	else
		self:MoveToPathList()
	end
	self.moveInfo = nil
end

function LovelyPetAvatar:MoveToPathList(flag)
	if not self:IsMoveState() or flag then
		if self.pathList and #self.pathList >= 1 then
			local pos = self.pathList[1]
			self:MoveToPos(pos)
			table.remove(self.pathList, 1)
			if #self.pathList == 0 then
				self.pathList = nil
			end
		end
	end
end

function LovelyPetAvatar:OtherWantMoveto()
	if self.moveInfo then
		local pos = {}
		pos.x = self.moveInfo.x + math.random(-15, 15)
		pos.y = self.moveInfo.y + math.random(-15, 15)
		self:MoveToPos(pos)
		self.moveInfo = nil
	end
end

function LovelyPetAvatar:MoveToPos(pos)
	local speed = self.speed * 0.6
	self:MoveTo(pos, function()
		self:StopMoveAction()
		self.moveState = false
	end, speed, nil, true)
	self:ExecMoveAction()
end

function LovelyPetAvatar:DoMoveTo(pos, speed)
	self.speed = speed
	self.moveInfo = {x = pos.x, y = pos.y}
end

function LovelyPetAvatar:DoStopMove()
	local player = self:GetOwner()
	local pos = player:GetPos()
	local speed = 0
	if self.speed then
		speed = self.speed
	else
		speed = player:GetSpeed()
	end
	self:DoMoveTo(pos, speed)
end

function LovelyPetAvatar:IsMoveState()
	return self.moveState
end

local ret2d = _Vector2.new()
local pos = _Vector3.new()
function LovelyPetAvatar:GetNamePos()
    local mePos = self:GetPos()
	if not mePos then
		return
	end

	local modelId = self.modelId
	local look = t_petmodel[modelId]
	if not look then
		return
	end

	local hight = look.namehight or 0
    pos.x = 0
    pos.y = 0
    pos.z = hight

    pos.x = mePos.x + pos.x
    pos.y = mePos.y + pos.y
    pos.z = mePos.z + pos.z
    _rd:projectPoint( pos.x, pos.y, pos.z, ret2d)
	return ret2d
end

local petplayerFont = _Font.new("SIMHEI", 11, 0, 1, true)
local petFont = _Font.new("SIMHEI", 11, 0, 1, true)
function LovelyPetAvatar:DrawNameBoard()
	if not self.objNode then
		return
	end
	if not self.objNode.visible then
		return
	end
	if not self.objMesh then
		return
	end
	
	local player = self:GetOwner()
	if not player then
		return
	end

	if not player:IsShowName() then
		return
	end

	local playerName = player.playerInfo[enAttrType.eaName]
	if not playerName then
		return
	end
	if playerName == "" then
		return
	end

	local modelId = self.modelId
	local look = t_petmodel[modelId]
	if not look then
		return
	end
	local name = look.name
	if not name then
		return
	end
	if name == "" then
		return
	end

	if RenderConfig.batch == true then
		_rd.batchId = 1
	end

	local cfg = CUICardConfig[999]
	local pos2d = self:GetNamePos()

	if self:IsSelf() then
		petplayerFont.edgeColor = cfg.petplayer_name_edgecolor
		petplayerFont.textColor = cfg.petplayer_name_textcolor
	else
		petplayerFont.edgeColor = cfg.petotherplayer_name_edgecolor
		petplayerFont.textColor = cfg.petotherplayer_name_textcolor
	end
	playerName = "<" .. playerName .. ">"
    petplayerFont:drawText(pos2d.x, pos2d.y,
        pos2d.x, pos2d.y, playerName, _Font.hCenter + _Font.vTop)
	
    pos2d.x, pos2d.y = pos2d.x, pos2d.y - 20

	petFont.edgeColor = cfg.pet_name_edgecolor
	petFont.textColor = cfg.pet_name_textcolor
	petFont:drawText(pos2d.x, pos2d.y,
	        pos2d.x, pos2d.y, name, _Font.hCenter + _Font.vTop)

	if RenderConfig.batch == true then
		_rd.batchId = 0
	end
end

function LovelyPetAvatar:IsSelf()
	local player = self:GetOwner()
	if not player then
		return false
	end
	if player:IsSelf() then
		return true
	else
		return false
	end
end