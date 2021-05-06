local CCountDownBox = class("CCountDownBox", CBox)

function CCountDownBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NumberBgSprite = self:NewUI(1, CSprite)
	self.m_NumberGrid = self:NewUI(2, CGrid)
	self.m_NumberSprite = self:NewUI(3, CSprite)
	self.m_NumberBgTween = self.m_NumberBgSprite:GetComponent(classtype.TweenAlpha)
	self.m_NumberGrid:SetActive(false)
	self.m_NumberSprite:SetActive(false)

	self.m_NumberSpriteArr = {}
	self.m_CurrentValue = 0
	self.m_EndValue = 0
	self.m_Space = 1
	self.m_Delay = 1
	self.m_AddValue = 1
	self.m_TimerID = nil
	self.m_TimeUPCallback = nil
	self.m_TickFunc = nil
	self.m_GetSpriteNameFunc = nil
end

--开始倒计时
--[[
startValue 起始值
endValue   结束值
addValue   增量
space      时间间隔
delay      开始倒数的延迟
]]
function CCountDownBox.BeginCountDown(self, startValue, endValue, addValue, space, delay)
	self.m_CurrentValue = startValue or self.m_CurrentValue
	self.m_EndValue = endValue or self.m_EndValue
	self.m_Space = space or self.m_Space
	self.m_Delay = delay or self.m_Delay
	if addValue then
		self.m_AddValue = addValue
	else
		self.m_AddValue = self.m_CurrentValue >= self.m_EndValue and -1 or 1
	end
	self:UpdateTimeSprite(self.m_CurrentValue)
	if self.m_TickFunc then
		self.m_TickFunc(self.m_CurrentValue)
	end
	if self.m_CurrentValue ~= self.m_EndValue then
		if self.m_TimerID ~= nil then
			Utils.DelTimer(self.m_TimerID)
		end
		self.m_TimerID = Utils.AddTimer(callback(self, "CountDown"), self.m_Space, self.m_Delay)
	else
		self:OnTimeUP()
	end
end

function CCountDownBox.SetTickFunc(self, func)
	self.m_TickFunc = func
end

function CCountDownBox.CountDown(self)
	self.m_CurrentValue = self.m_CurrentValue + self.m_AddValue
	if self.m_TickFunc then
		self.m_TickFunc(self.m_CurrentValue)
	end
	self:UpdateTimeSprite(self.m_CurrentValue)
	if (self.m_AddValue > 0 and self.m_CurrentValue > self.m_EndValue) 
		or (self.m_AddValue < 0 and self.m_CurrentValue < self.m_EndValue) then
			self:OnTimeUP()
		return false
	end
	return true
end

--倒计时结束回调
function CCountDownBox.SetTimeUPCallBack(self, callbackFunc)
	self.m_TimeUPCallback = callbackFunc
end

function CCountDownBox.OnTimeUP(self)
	self:UpdateTimeSprite(0)
	self:DelTimer()
	if self.m_TimeUPCallback ~= nil then
		self.m_TimeUPCallback()
	end
end

function CCountDownBox.DelTimer(self)
	if self.m_TimerID ~= nil then
		Utils.DelTimer(self.m_TimerID)
		self.m_TimerID = nil
	end
end

function CCountDownBox.UpdateTimeSprite(self, iValue)
	self.m_NumberGrid:SetActive(true)
	self.m_NumberBgSprite:SetActive(true)

	if self.m_LastUpdateTime == iValue then
		return
	end
	self.m_LastUpdateTime = iValue
	if iValue < 5 then
		self.m_NumberBgTween.enabled = true
	else
		self.m_NumberBgTween.enabled = false
		self.m_NumberBgSprite:SetColor(Color.white)
	end
	local sList = self:GetNumList(iValue)
	for i,v in ipairs(sList) do
		if self.m_NumberSpriteArr[i] == nil then
			self.m_NumberSpriteArr[i] = self.m_NumberSprite:Clone()
			self.m_NumberGrid:AddChild(self.m_NumberSpriteArr[i])
		end
		self.m_NumberSpriteArr[i]:SetSpriteName(self:GetSpriteName(v))
		self.m_NumberSpriteArr[i]:SetActive(true)
	end
	local startCount = #sList + 1
	for i = startCount, #self.m_NumberSpriteArr do
		self.m_NumberSpriteArr[i]:SetActive(false)
	end
	self.m_NumberGrid:Reposition()
end

function CCountDownBox.GetSpriteName(self, sValue)
	if self.m_GetSpriteNameFunc ~= nil then
		return self.m_GetSpriteNameFunc(sValue)
	end
	return sValue
end

function CCountDownBox.GetNumList(self, iValue)
	local sList = {}
	local str = tostring(iValue)
	local len = string.len(str)
	for i = 1, len do
		table.insert(sList, string.sub(str, i, i))
	end
	return sList
end

return CCountDownBox
