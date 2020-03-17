_G.LS = {}
local metaLS = {__index = LS}

function LS:New(lsId, cid, x, y, faceto, nType)
	local lingShou = {}
	setmetatable(lingShou, metaLS)
	lingShou.lsId = lsId
	lingShou.cid = cid
	lingShou.x = x
	lingShou.y = y
	lingShou.__type = "lingShou"
	lingShou.faceto = faceto
	lingShou.battleState = false
	lingShou.leisureTime = GetCurTime() + 10000
	lingShou.randomLeisureTime = math.random(1, 3) * 1000
	lingShou.avatar = LSAvatar:New(lsId, cid, nType)
	lingShou.avatar:InitAvatar()
	return lingShou
end

function LS:Show()
	self.avatar:EnterMap(self.x, self.y, self.faceto)
	self.avatar:ExecIdleAction()
end

function LS:Delete()
	if self.avatar then
		self.avatar:ExitMap()
		self.avatar = nil
	end
	self = nil
end

function LS:StopMove(x, y, faceto)
	local currPos = self:GetPos()
	if not currPos then
		return
	end
	local vecPos = {x = x, y = y}
	self.avatar:StopMove(vecPos, faceto)
end

function LS:MoveTo(x, y)
	local speed = self:GetSpeed()
	local vecPos = {x = x, y = y}
	self.avatar:MoveTo(vecPos, function()
		self.avatar:StopMove()
	end, speed)
end

function LS:PlaySkill(skillId, targetCid, targetPos)
	self:GetAvatar():PlaySkill(skillId, targetCid, targetPos)
end

function LS:GetCid()
	return self.cid
end

function LS:GetPos()
	return self.avatar:GetPos()
end

function LS:GetDir()
	return self.avatar:GetDirValue()
end

function LS:GetAvatar()
	return self.avatar
end

function LS:UpdateSpeed(speed)
	self:SetSpeed(speed)
	self.avatar:UpdateSpeed(speed)
end

function LS:GetSpeed()
	return self.speed
end

function LS:SetSpeed(speed)
	self.speed = speed
end

function LS:Update(dwInterval)
	self:Leisure()
end

function LS:SetPos(x, y)
	local avatar = self.avatar
	if not avatar then
		return
	end
	avatar:SetPos({x = x, y = y, z = 0})
end

function LS:SetOwnerId(ownerId)
	local avatar = self.avatar
	if not avatar then
		return
	end
	avatar.ownerId = ownerId
	self:SetSkeletonShake()
end

function LS:SetSkeletonShake()
	local avatar = self:GetAvatar()
	if self.nType == 1 then
		if avatar.ownerId == MainPlayerController:GetRoleID() then 
			avatar.objSkeleton:ignoreShake(false)
		end
	end
end

function LS:Hide()
	local avatar = self.avatar
	if avatar and avatar.objNode and avatar.objNode.entity then
		avatar.objNode.visible = false			
	end
end

function LS:Leisure()
	local nowTime = GetCurTime()
	if not self:IsLeisureState() then
		self.leisureTime = nowTime
		self:StopLeisureAction()
	else
		if self.leisureTime 
			and nowTime - self.leisureTime > _G.LS_XIUXIAN_GAP + self.randomLeisureTime then
			self:DoLeisureAction()
			self.leisureTime = nowTime
		end
	end
end

function LS:IsMoveState()
	return self:GetAvatar().moveState
end

function LS:IsLeisureState()
	if not self:GetAvatar() then
		return false
	end
	if self:IsMoveState() then
		return false
	end
	if self:GetAvatar().skillPlaying then
		return
	end
	return true
end

function LS:DoLeisureAction()
	local actionFile = self:GetAvatar():GetLeisureAction()
	if actionFile and actionFile ~= "" then
		self.actionFile = actionFile
		self.avatar:DoAction(actionFile, false)
	end
end

function LS:StopLeisureAction()
	if self.actionFile and self.actionFile ~= "" then
		if self.avatar then
			self.avatar:DoStopAction(self.actionFile, false)
		end
	end
end

function LS:SetBattleState(battleState)
	self.battleState = battleState;
	self:GetAvatar():SetAttackAction(battleState);
end
