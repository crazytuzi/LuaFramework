local CBloodHud = class("CBloodHud", CAsyncHud)

function CBloodHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/BloodHud.prefab", cb, false)
end

function CBloodHud.OnCreateHud(self)
	self.m_HPSlider = self:NewUI(1, CSlider)
	self.m_Sprite = self:NewUI(2, CSprite)
	self.m_Tumb = self:NewUI(3, CObject)
	self.m_TumbSprite = self:NewUI(4, CSprite)
	self.m_OriSpriteName = self.m_Sprite:GetSpriteName()
	self.m_TargetValue = 1
	self.m_CurrentValue = 1
	self.m_Time = nil
	self.m_FrontW = self.m_Sprite:GetWidth()
end

function CBloodHud.Recycle(self)
	self.m_Sprite:SetSpriteName(self.m_OriSpriteName)
	self:ChangeValue(1)
	if self.m_TimeID ~= nil then
		Utils.DelTimer(self.m_TimeID)
		self.m_TimeID = nil
	end
end

function CBloodHud.SetHP(self, percent)
	if self.m_TargetValue then
		self:ChangeValue(self.m_TargetValue)
	end
	self.m_Time = 0.2
	self.m_TargetValue = math.max(0, math.min(1, percent))
	self.m_Speed = (self.m_TargetValue - self.m_CurrentValue) / self.m_Time
	
	if self.m_TimeID == nil then
		self.m_TimeID = Utils.AddScaledTimer(callback(self, "UpdateValue"), 0, 0)
	end
end

function CBloodHud.UpdateValue(self, dt)
	local bUpdate = false
	if self.m_Time then
		local iNew = self.m_CurrentValue +  self.m_Speed * math.min(self.m_Time, dt)
		self:ChangeValue(iNew)
		self.m_Time = self.m_Time - dt
		bUpdate = (self.m_Time > 0)
	end

	if bUpdate then
		return true
	else
		self.m_Time = nil
		self.m_TargetValue = nil
		self.m_TimeID = nil
		return false
	end
	
end

function CBloodHud.ChangeValue(self, percent)
	self.m_CurrentValue = percent
	self.m_HPSlider:SetValue(percent)
	if percent < 0.3 then
		local iFill = math.lerp(0, 1, (percent-0.05)/0.3)
		self.m_TumbSprite:SetLocalScale(Vector3.New(iFill, 1, 1))
	else
		self.m_TumbSprite:SetLocalScale(Vector3.New(1, 1, 1))
	end
	self.m_Tumb:SetActive((percent<1) and (percent>0))
end

function CBloodHud.SetSprite(self, sName)
	self.m_Sprite:SetSpriteName(sName)
end

return CBloodHud