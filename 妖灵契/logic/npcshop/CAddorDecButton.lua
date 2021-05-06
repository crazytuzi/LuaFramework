local CAddorDecButton = class("CAddorDecButton", CButton)

function CAddorDecButton.ctor(self, cb)
	CButton.ctor(self, cb)
	self.m_RepeatValue = 0
	self.m_RepeatGrade = 1
	self.m_Value = 1
	self.m_ClickChange = 1
	self.m_RepeatDelta = 0.1
	self.m_RepeatStartCount = 5
	self.m_ChangeTable = {{0,1}}
	self:AddUIEvent("repeatpress", callback(self, "OnRepeatPress"))
end

--[[
data{
	Label:				对应的Label,
	LimitNum:			上/下限，
	ChangeTable:		{ {长按时间，增加值}, {长按时间，增加值} },如长按2秒后每次增加10，长按5秒后每次增加99：{{2,10},{5,99}}
	Callback:			长按过程回调
	OutRangeCallback:	长按超出范围时回调
}
{Label = , LimitNum = , RepeatDelta = , StartDelay = , ChangeTable = , Callback = , OutRangeCallback = }
]]--
function CAddorDecButton.SetData(self, data)
	self.m_Label = data.Label
	self.m_LimitNum = data.LimitNum
	if data.ChangeTable ~= nil then
		self.m_ChangeTable = data.ChangeTable
		self.m_ClickChange = (data.ChangeTable[1][2] > 0 and 1 or -1)
	end
	self.m_Callback = data.Callback
	self.m_OutRangeCallback = data.OutRangeCallback

	local function sortfunction(v1, v2)
		return v1[1] < v2[1]
	end
	table.sort(self.m_ChangeTable, sortfunction)

	for i = 1, #self.m_ChangeTable do
		self.m_ChangeTable[i][1] = self.m_ChangeTable[i][1] / self.m_RepeatDelta
	end

end

function CAddorDecButton.SetLimitNum(self, limitNum)
	self.m_LimitNum = limitNum
end

--startDelay:长按多少秒才开始执行Callback
function CAddorDecButton.SetStartDelay(self, startDelay)
	self.m_RepeatStartCount = startDelay / self.m_RepeatDelta
end

--设置点击增加的数值
function CAddorDecButton.SetClickChange(self, value)
	self.m_ClickChange = value
end

function CAddorDecButton.OnRepeatPress(self, ...)
	local bPress = select(2, ...)
	if self.m_RepeatValue == 0 then
		self.m_Value = tonumber(self.m_Label:GetText())
	end
	if bPress then
		self.m_RepeatValue = self.m_RepeatValue + 1
	else
		if self.m_RepeatValue > 0 and self.m_RepeatValue < self.m_RepeatStartCount then
			self:ChangeNum(self.m_ClickChange)
		end
		self.m_RepeatValue = 0
		self.m_RepeatGrade = 1
	end

	if self.m_RepeatValue >= self.m_RepeatStartCount then
		if self.m_RepeatGrade < #self.m_ChangeTable and self.m_RepeatValue > self.m_ChangeTable[self.m_RepeatGrade+1][1] then
			self.m_RepeatGrade = self.m_RepeatGrade + 1
		end
		self:ChangeNum(self.m_ChangeTable[self.m_RepeatGrade][2])
	end
end

function CAddorDecButton.ChangeNum(self, value)
	if self.m_LimitNum == nil or (value > 0 and self.m_Value < self.m_LimitNum) or (value < 0 and self.m_Value > self.m_LimitNum) then
		self.m_Value = self.m_Value + value
	end

	if self.m_LimitNum ~= nil and ((value > 0 and self.m_Value > self.m_LimitNum) or (value < 0 and self.m_Value < self.m_LimitNum)) then
		self.m_Value = self.m_LimitNum
		if self.m_OutRangeCallback ~= nil then
			self.m_OutRangeCallback()
		end
	else
		if self.m_Callback ~= nil then
			self.m_Callback(self.m_Value)
		end
	end
end

return CAddorDecButton