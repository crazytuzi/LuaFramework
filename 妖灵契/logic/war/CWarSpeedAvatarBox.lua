local CWarSpeedAvatarBox = class("CWarSpeedAvatarBox", CBox)

CWarSpeedAvatarBox.ACT = 1
CWarSpeedAvatarBox.WAIT = 2
CWarSpeedAvatarBox.DONE = 3

function CWarSpeedAvatarBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_AvatarSpr = self:NewUI(1, CSprite)
	self.m_TypeSpr = self:NewUI(2, CSprite)
	self.m_PosObj = self:NewUI(3, CObject)
	self.m_EffectObj = self:NewUI(4, CObject)
	self.m_IgnoreCheckEffect = false
	self.m_State = self.WAIT
	self.m_Wid = nil
	self.m_Speed = 0
	self.m_ShowCircle = false
	self.m_ShiftDone = false
end

function CWarSpeedAvatarBox.SetState(self, iState)
	if self.m_State == iState then
		return
	end
	self:SetShiftDone(false)
	self.m_State = iState
	self:CheckColor()
	self:Refresh()
end

function CWarSpeedAvatarBox.CheckColor(self)
	local oWarrior = g_WarCtrl:GetWarrior(self.m_Wid)
	if oWarrior and oWarrior:IsAlive() then
		local bDone = (self.m_State == self.DONE) and true or false
		self.m_AvatarSpr:SetGrey(bDone)
		self.m_TypeSpr:SetGrey(bDone)
		self:SetGrey(bDone)
	else
		local c = Color.New(0.3, 0.3, 0.3, 1)
		self.m_AvatarSpr:SetColor(c)
		self.m_TypeSpr:SetColor(c)
		self:SetColor(c)
	end
end

function CWarSpeedAvatarBox.SetShowCircle(self, b)
	if self.m_ShowCircle == b then
		return
	end
	self.m_ShowCircle = b
	self:Refresh()
end

function CWarSpeedAvatarBox.Refresh(self)
	self:StopDelayCall("Refresh")
	local oWarrior = g_WarCtrl:GetWarrior(self.m_Wid)
	local bAlly = oWarrior and oWarrior:IsAlly()
	local scaleX, scalseAvatarX = 1, 1
	local poxTypeX, posAvatarX, posObjX = 0, 0, 0
	local sprname = ""
	local sizeAvatar = 45
	local bTween = false
	if self:IsAct() or self.m_ShowCircle then
		sizeAvatar = 52
		if self:IsAct() then
			bTween = true
		end
		if bAlly then
			sprname = "pic_yuan_yf"
		else
			sprname = "pic_yuan_df"
			scaleX, scalseAvatarX = -1, -1
		end
	else
		if bAlly then
			sprname = "pic_jtyuan_yf"
			poxTypeX, posAvatarX, posObjX = 0, -0.8, -15
		else
			poxTypeX, posAvatarX, posObjX = 0, -2.8, 15
			sprname = "pic_jtyuan_df"
			scaleX, scalseAvatarX = -1, -1
		end
	end
	if bTween then
		self.m_EffectObj:UITweenPlay()
		self.m_EffectObj:SetActive(true)
	else
		self.m_EffectObj:UITweenStop()
		self.m_EffectObj:SetActive(false)
	end
	self.m_TypeSpr:SetSpriteName(sprname)
	-- printerror(sprname, self:IsAct())
	self.m_PosObj:SetLocalScale(Vector3.New(scaleX, 1, 1))
	self.m_AvatarSpr:SetSize(sizeAvatar, sizeAvatar)
	self.m_PosObj:SetLocalPosX(posObjX)
	self.m_TypeSpr:SetLocalPosX(poxTypeX)
	self.m_AvatarSpr:SetLocalPosX(posAvatarX)
	local iScale = self.m_ShowCircle and 0.9 or 1
	self:SetLocalScale(Vector3.one * iScale)
end

function CWarSpeedAvatarBox.SetWid(self, wid)
	if self.m_Wid == wid then
		return
	end
	self.m_Wid = wid
	if wid then
		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if oWarrior then
			self.m_AvatarSpr:SpriteAvatarCircle(oWarrior:GetShape())
			self.m_Speed = oWarrior:GetSpeed()
			self.m_CampPos = oWarrior.m_CampPos
			self.m_State = nil
			self:SetState(self.WAIT)
			self:SetName(tostring(wid))
		end
	end
end

function CWarSpeedAvatarBox.SetShape(self, iShape)
	self.m_AvatarSpr:SpriteAvatarCircle(iShape)
end

function CWarSpeedAvatarBox.SetDepth(self, iIdx, iAll)
	local i = CWarSpeedControlBox.OverlayIdx + 1
	if iIdx == i then
		self.m_AvatarSpr:SetDepth(1)
		self.m_TypeSpr:SetDepth(0)
	else
		if iIdx > i then
			local dp = -(iIdx-i)
			self.m_AvatarSpr:SetDepth(dp)
			self.m_TypeSpr:SetDepth(dp-iAll)
		else
			local dp = iIdx+1
			self.m_TypeSpr:SetDepth(dp)
			self.m_AvatarSpr:SetDepth(dp+iAll)
		end
	end
end

function CWarSpeedAvatarBox.IsAct(self)
	return self.m_State == self.ACT
end

function CWarSpeedAvatarBox.IsWait(self)
	return self.m_State == self.WAIT
end

function CWarSpeedAvatarBox.IsDone(self)
	return self.m_State == self.DONE
end

function CWarSpeedAvatarBox.SetShiftDone(self, b)
	self.m_ShiftDone = b
end

function CWarSpeedAvatarBox.IsShiftDone(self)
	return (self.m_ShiftDone ~= nil)
end

return CWarSpeedAvatarBox