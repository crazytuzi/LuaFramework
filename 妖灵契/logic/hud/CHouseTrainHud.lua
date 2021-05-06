local CHouseTrainHud = class("CHouseTrainHud", CAsyncHud)

function CHouseTrainHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/HouseTrainHud.prefab", cb, true)
end

function CHouseTrainHud.OnCreateHud(self)
	self.m_Slider = self:NewUI(1, CSlider)
	self.m_FinishMark = self:NewUI(2, CSprite)
	self.m_Time = nil
	-- self.m_ElapsedTime = 0
	self.m_Left = 0
end

function CHouseTrainHud.SetTrainTime(self, iTime, iLeftTime, bFinish)
	self.m_Time = iTime
	self.m_Left = iLeftTime
	-- self.m_ElapsedTime = 0
	if not self.m_Timer then
		self.m_Timer = Utils.AddTimer(callback(self, "RefreshTime"), 0.5, 0)
	end
	self.m_Slider:SetActive(not bFinish)
	self.m_FinishMark:SetActive(bFinish)
end

function CHouseTrainHud.RefreshTime(self, dt)
	self.m_Left = self.m_Left - dt
	if self.m_Left < 0 then
		self.m_Timer = nil
		self.m_Slider:SetSliderText("0时0分0秒")
		return false
	end
	local per = (self.m_Time - self.m_Left) / self.m_Time
	self.m_Slider:SetValue(per)
	local t = g_TimeCtrl:GetTimeInfo(self.m_Left)
	local sText = string.format("%s时%s分%s秒", t.hour, t.min, t.sec)
	self.m_Slider:SetSliderText(sText)
	return true
end

return CHouseTrainHud