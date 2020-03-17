--[[
    Created by IntelliJ IDEA.
    NPC指引avatar
    User: Hongbin Yang
    Date: 2016/8/24
    Time: 16:13
   ]]

_G.NpcGuildAvatar = {}
setmetatable(NpcGuildAvatar, { __index = CAvatar })
local metaNpcGuildAvatar = { __index = NpcGuildAvatar }

NpcGuildAvatar.modelId = 80200112;
NpcGuildAvatar.scale = 1.5;
NpcGuildAvatar.bIsAttack = false;
NpcGuildAvatar.dwIdleAnimaID = nil;
NpcGuildAvatar.dwMoveAnimaID = nil;
function NpcGuildAvatar:Create()
	local look = t_model[self.modelId]
	if not look then
		return
	end
	local sklFile = look.skl
	local sknFile = look.skn
	local defAnima = look.san_idle
	local moveAnima = look.san_move
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

	local NpcGuildAvatar = CAvatar:new()
	NpcGuildAvatar:SetPart("Body", meshResource)
	NpcGuildAvatar:ChangeSkl(sklResource)
	self:SetCfgScale(self.scale);

	local defAnimaResource = Assets:GetNpcAnima(defAnima)
	if not defAnimaResource or defAnimaResource == "" then
		Error("Get Npc Anima Error", defAnima, lookId)
	else
		NpcGuildAvatar:SetIdleAction(defAnimaResource, true)
	end

	local moveAnimaResource = Assets:GetNpcAnima(moveAnima)
	if not moveAnimaResource or moveAnimaResource == "" then
		Error("Get Npc Anima Error", moveAnima, lookId)
	else
		NpcGuildAvatar:SetMoveAction(moveAnimaResource, false)
	end
	NpcGuildAvatar.pickFlag = enPickFlag.EPF_Null
	NpcGuildAvatar.modelId = modelId
	setmetatable(NpcGuildAvatar, metaNpcGuildAvatar)
	return NpcGuildAvatar
end

function NpcGuildAvatar:EnterMap(x, y)
	local currScene = CPlayerMap:GetSceneMap()
	self:EnterSceneMap(currScene,
		_Vector3.new(x, y, 0),
		0)
	self.objNode.dwType = enEntType.eEntType_Pet
end

function NpcGuildAvatar:OnEnterScene(objNode)
	objNode.dwType = enEntType.eEntType_Pet
end

function NpcGuildAvatar:ExitMap()
	self:ExitSceneMap()
	self:Destroy()
end

function NpcGuildAvatar:UpdatePos(dwInterval)

	self:SelfWantMoveto()
	if not self.moveInfo
			and not self.pathList
			and not self:IsMoveState() then
		self:StopMoveAction()
		self:SetAttackAction()
	end
	self:Update(dwInterval)
end

function NpcGuildAvatar:GetOwner()
	local player = CPlayerMap:GetPlayer(self.ownerId)
	return player
end

function NpcGuildAvatar:SelfWantMoveto()
	if self.moveInfo then
		local selfPos = self:GetPos()
		local pos = {}
		local pathList, ret = nil, nil
		pathList, ret = AreaPathFinder:GetPathLine(selfPos, self.moveInfo)
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

function NpcGuildAvatar:MoveToPathList(flag)
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

function NpcGuildAvatar:OtherWantMoveto()
	if self.moveInfo then
		local pos = {}
		pos.x = self.moveInfo.x + math.random(-15, 15)
		pos.y = self.moveInfo.y + math.random(-15, 15)
		self:MoveToPos(pos)
		self.moveInfo = nil
	end
end

function NpcGuildAvatar:MoveToPos(pos)
	if not pos then return; end
	local player = self:GetOwner()
	self:MoveTo(pos, function()
		self:StopMoveAction()
		self.moveState = false
	end, self.speed, nil, false, 50)
	self:ExecMoveAction()
end

function NpcGuildAvatar:DoMoveTo(pos, speed, isAttack)
	if isAttack then
		self.bIsAttack = isAttack;
	else
		self.bIsAttack = false;
	end
	local selfPos = self:GetPos()

	local player = self:GetOwner()
	self.speed = player:GetSpeed() * 0.65
	self.moveInfo = { x = pos.x, y = pos.y }
end

function NpcGuildAvatar:IsMoveState()
	return self.moveState
end

--切换战斗状态
function NpcGuildAvatar:SetAttackAction()

	if self.transform then
		self.transform:SetAttackAction(self, self.bIsAttack);
		return;
	end
	local look = t_model[self.modelId]
	if not look then
		return
	end
	local atkAnima = look.san_atk
	local defAnima = look.san_idle
	local moveAnima = look.san_move
	if self.bIsAttack then
		self:ExecAction(atkAnima, true)
	else
		self:SetIdleAction(defAnima, true)
		self:SetMoveAction(moveAnima)
	end
end


local ret2d = _Vector2.new()
local pos = _Vector3.new()
function NpcGuildAvatar:GetNamePos()
	local mePos = self:GetPos()
	if not mePos then
		return
	end

	local hight = 15 or 0
	pos.x = 0
	pos.y = 0
	pos.z = hight

	pos.x = mePos.x + pos.x
	pos.y = mePos.y + pos.y
	pos.z = mePos.z + pos.z
	_rd:projectPoint(pos.x, pos.y, pos.z, ret2d)
	return ret2d
end

local petplayerFont = _Font.new("SIMHEI", 11, 0, 1, true)
local petFont = _Font.new("SIMHEI", 11, 0, 1, true)
function NpcGuildAvatar:DrawNameBoard()
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
	local look = t_model[modelId]
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

function NpcGuildAvatar:IsSelf()
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