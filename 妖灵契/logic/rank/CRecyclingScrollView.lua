local CRecyclingScrollView = class("CRecyclingScrollView", CScrollView)

function CRecyclingScrollView.ctor(self, ob)
	CScrollView.ctor(self, ob)
	self:InitContent()
end

function CRecyclingScrollView.InitContent(self)
	self.m_TempItemNum = 10
	self.m_HalfTempItemNum = math.ceil(self.m_TempItemNum / 2)
	self.m_CellArr = {}
	self.m_MinLocationSpace = 0
	self.m_CrossPageEvent = nil
	self.m_SetDataFunc = nil
	self.m_EventId = 1
	self.m_CurrentIndex = 0
	self.m_CanShowIndex = 0
	self.m_UIScrollView.momentumAmount = 50
end

function CRecyclingScrollView.Clear(self)
	--删除所有孩子，并重新生成
	for i,v in ipairs(self.m_CellArr) do
		self.m_CellArr[i]:Destroy()
	end
	self.m_CellArr = {}
	self.m_Update = false
end

function CRecyclingScrollView.SetData(self, scrollWidget, maxIndex, oBox, initFunc, setDataFunc)
	self.m_Data = {}
	self.m_SetRecord = {}
	self.m_SetDataFunc = setDataFunc
	self.m_MaxIndex = maxIndex
	self.m_ScrollWidget = scrollWidget
	for i = 1, maxIndex do
		self.m_Data[i] = true
	end

	if #self.m_CellArr == 0 then
		self.m_Width,self.m_Hight = self:GetSize()
		self.m_CellWidth,self.m_CellHeight = oBox:GetSize()
		self.m_CellBasePos = oBox:GetLocalPos() + Vector3.New(0, self.m_CellHeight, 0)
		self.m_ScrollViewBasePos = self:GetLocalPos()
		self.m_ShowingCellNum = math.ceil(self.m_Hight / self.m_CellHeight)
		if self.m_Hight % self.m_CellHeight ~= 0 then
			self.m_ShowingFix = self.m_CellHeight - (self.m_Hight % self.m_CellHeight)
		else
			self.m_ShowingFix = 0
		end
		self.m_ActualCellNum = self.m_ShowingCellNum + self.m_TempItemNum
		-- printc("m_Hight: " .. self.m_Hight)
		-- printc("m_CellHeight: " .. self.m_CellHeight)
		-- printc("m_CellBasePos: " .. self.m_CellBasePos.y)
		-- printc("m_ShowingCellNum: " .. self.m_ShowingCellNum)
		-- printc("m_ShowingFix: " .. self.m_ShowingFix)
		-- printc("m_ScrollViewBasePos: " .. self.m_ScrollViewBasePos.y)
		local oBoxParent = oBox:GetParent()
		for i= 1, self.m_ActualCellNum do
			self.m_CellArr[i] = oBox:Clone()
			initFunc(self.m_CellArr[i])
			self.m_CellArr[i]:SetParent(oBoxParent)
			if self.m_Data[i] and self.m_SetDataFunc ~= nil then
				self.m_SetDataFunc(self.m_CellArr[i], i)
			end
			self:SetPos(self.m_CellArr[i], i)
		end
		self.m_CurrentTopIndex = 1
		self.m_CurrentBottomIndex = self.m_ActualCellNum
		self.m_LastTopIndex = 1
		self.m_LastBottomIndex = self.m_ActualCellNum
		self.m_Update = true
		self.m_LastIndex = 1
		self.m_TimerId = Utils.AddTimer(callback(self, "OnUpdate"), 0.02, 0.1)
	else
		self:SetCellData(1,self.m_ActualCellNum)
		self:ResetPosition()
	end
	-- self.m_ScrollWidget:SetHeight(self.m_MaxIndex * self.m_CellHeight)
end

--标记可用区域
function CRecyclingScrollView.AddCanShowSpace(self, fromPos, toPos)
	for i = fromPos, toPos do
		self.m_Data[i] = true
	end
	if self.m_CanShowIndex < toPos then
		self.m_CanShowIndex = toPos
		-- self.m_ScrollWidget:SetHeight(self.m_MaxIndex * self.m_CellHeight)
	end
end

--设置最大序号
function CRecyclingScrollView.SetMaxIndex(self, max)
	self.m_MaxIndex = max
	-- self.m_ScrollWidget:SetHeight(self.m_MaxIndex * self.m_CellHeight)
end

--获取当前基准线下第一格的序号
function CRecyclingScrollView.GetBaseIndex(self)
	return math.ceil((self:GetLocalPos().y - self.m_ScrollViewBasePos.y)/self.m_CellHeight)
end

--通过序号获取对应的单元格
function CRecyclingScrollView.GetCellByIndex(self, index)
	local outIndex = index % self.m_ActualCellNum
	if outIndex == 0 then
		outIndex = self.m_ActualCellNum
	end
	return self.m_CellArr[outIndex]
end

--将单元格移动到指定位置
function CRecyclingScrollView.SetPos(self, cell, index)
	cell:SetLocalPos(self.m_CellBasePos - Vector3.New(0, index * self.m_CellHeight, 0))
end

--拖动位移检查
function CRecyclingScrollView.OnUpdate(self)
	if self.m_Update ~= true then
		return true
	end
	self.m_CurrentIndex = self:GetBaseIndex()
	self.m_CurrentTopIndex = self.m_CurrentIndex - self.m_HalfTempItemNum
	self.m_CurrentBottomIndex = self.m_CurrentTopIndex + self.m_ActualCellNum - 1
	--跨越检测
	if self.m_CurrentIndex > self.m_LastIndex then
		self:CheckCrossPage(self.m_CurrentBottomIndex)
	elseif self.m_CurrentIndex < self.m_LastIndex then
		self:CheckCrossPage(self.m_CurrentTopIndex)
	end
	--超越上下限修正
	if self.m_CurrentIndex <= 1 then
		self.m_CurrentIndex = 1
		self.m_CurrentTopIndex = self.m_CurrentIndex
		self.m_CurrentBottomIndex = self.m_CurrentIndex + self.m_ActualCellNum - self.m_HalfTempItemNum - 1
	elseif self.m_CurrentIndex > self.m_MaxIndex then
		self.m_CurrentIndex = self.m_MaxIndex - self.m_ShowingCellNum + 1
		self.m_CurrentTopIndex = self.m_CurrentIndex - self.m_HalfTempItemNum
		self.m_CurrentBottomIndex = self.m_MaxIndex
	end

	if self.m_CurrentIndex ~= self.m_LastIndex then
		self:SetCellData(self.m_CurrentTopIndex, self.m_CurrentBottomIndex)
	end
	return true
end

--设置单元数据
function CRecyclingScrollView.SetCellData(self, beginIndex, endIndex, isAddIndex, ppp)
	local min = beginIndex
	local max = endIndex
	if beginIndex > endIndex then
		min = endIndex
		max = beginIndex
	end
	-- local str = ""
	for i = min, max do
		if self.m_Data[i] then
			if i < self.m_LastTopIndex or i > self.m_LastBottomIndex or not self.m_SetRecord[i] then
				self.m_NeedSetCell = self:GetCellByIndex(i)
				self.m_SetRecord[i] = self.m_SetDataFunc(self.m_NeedSetCell, i)
				self:SetPos(self.m_NeedSetCell, i)
				-- str = str .. i .. " "
			end
		end
	end
	-- printc("设置了:" .. str)
	self.m_LastIndex = self.m_CurrentIndex
	self.m_LastTopIndex = self.m_CurrentTopIndex
	self.m_LastBottomIndex = self.m_CurrentBottomIndex
end

--跳转到指定项
function CRecyclingScrollView.SetLocation(self, index)
	self.m_Update = false
	if index > self.m_MaxIndex then
		return
	end
	--小于最小差异距离时，不跳转
	if math.abs(self.m_CurrentIndex - index) < self.m_MinLocationSpace then
		return
	end
	self:ResetPosition()
	self.m_CurrentIndex = index - self.m_ShowingCellNum
	if self.m_CurrentIndex < 1 then
		self.m_CurrentIndex = 1
		self.m_CurrentTopIndex = self.m_CurrentIndex
		self.m_CurrentBottomIndex = self.m_CurrentIndex + self.m_ActualCellNum - 1
	else
		self.m_CurrentTopIndex = self.m_CurrentIndex - self.m_HalfTempItemNum
		self.m_CurrentBottomIndex = self.m_CurrentIndex + self.m_ActualCellNum - self.m_HalfTempItemNum - 1
		-- printc(self.m_CurrentIndex)
		self:MoveRelative(Vector3.New(0, self.m_ShowingFix + self.m_CurrentIndex * self.m_CellHeight, 0))
	end
	self:SetCellData(self.m_CurrentTopIndex, self.m_CurrentBottomIndex)
	
	self.m_LastTopIndex = self.m_CurrentTopIndex
	self.m_LastBottomIndex = self.m_CurrentBottomIndex
	self.m_LastIndex = self.m_CurrentIndex
	self.m_Update = true
end

--[[每次滑动到一定坐标时回调
space			间隔
callbackFunc 	回调
]]
function CRecyclingScrollView.SetCrossPageEvent(self, space, callbackFunc)
	self.m_CrossPageEvent = {
		space = space,
		callbackFunc = callbackFunc,
		currentPage = 1,
		currentMax = space,
		currentMin = 1,
	}
end

--跨越检查
function CRecyclingScrollView.CheckCrossPage(self, index)
	if self.m_CrossPageEvent == nil or index < 1 or index > self.m_MaxIndex then
		return
	end
	if self.m_CrossPageEvent == nil or index < 1 then
		return
	end
	if index < self.m_CrossPageEvent.currentMin or index > self.m_CrossPageEvent.currentMax then
		self.m_CrossPageEvent.currentPage = math.ceil(index / self.m_CrossPageEvent.space)
		self.m_CrossPageEvent.currentMax = self.m_CrossPageEvent.currentPage * self.m_CrossPageEvent.space
		self.m_CrossPageEvent.currentMin = self.m_CrossPageEvent.currentMax - self.m_CrossPageEvent.space
		self.m_CrossPageEvent.callbackFunc(self.m_CrossPageEvent.currentPage)
	end
end

function CRecyclingScrollView.Close(self)
	self.m_Update = false
	if self.m_TimerId ~= nil then
		Utils.DelTimer(self.m_TimerId)
		self.m_TimerId = nil
	end
end

return CRecyclingScrollView