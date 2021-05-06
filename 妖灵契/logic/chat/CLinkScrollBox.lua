local CLinkScrollBox = class("CLinkScrollBox", CBox)

function CLinkScrollBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_PageLabel = self:NewUI(1, CLabel)
	self.m_PageList = {}
	for i = 1, 3 do
		local page = self:NewUI(1+i, CBox)
		self.m_PageList[i] = page
	end
	self.m_ClickBox = self:NewUI(6, CWidget)
	self.m_PageContainer = self:NewUI(7, CWidget)
	self.m_BoxFactoryFunc = nil
	self.m_CurPartIdx = 1
	self.m_Width = 660
	self:InitContent()
end

function CLinkScrollBox.InitContent(self)
	self.m_DataIdx = 1
	self.m_StartX = self.m_PageContainer:GetLocalPos().x
	self.m_PageLocalX = self.m_PageList[1]:GetLocalPos().x
	self.m_StartPageX = self.m_StartX + self.m_PageLocalX
	self.m_LeftPageX = self.m_StartPageX - self.m_Width
	self.m_RightPageX = self.m_StartPageX + self.m_Width
	self.m_ClickBox:AddUIEvent("drag", callback(self, "OnDrag"))
	self.m_ClickBox:AddUIEvent("dragend", callback(self, "OnDragEnd"))
end

function CLinkScrollBox.InitPage(self)
	for i = 1, 3 do
		local dData = self.m_DataSource[i]
		if dData then
			self.m_PageList[i]:SetActive(true)
			self.m_FactoryFunc(self.m_PageList[i], dData)
			self.m_PageList[i].m_DataIdx = i
		else
			self.m_PageList[i]:SetActive(false)
		end
	end
end

function CLinkScrollBox.SetFactoryFunc(self, func)
	self.m_FactoryFunc = func
end

function CLinkScrollBox.SetDataSource(self, f)
	self.m_DataSource = f
	self.m_MaxPage = #f
	local str = string.format("1/%d", self.m_MaxPage)
	self.m_PageLabel:SetText(str)
end


function CLinkScrollBox.SetWidth(self, iWidth)
	self.m_Width = iWidth
end

function CLinkScrollBox.OnDrag(self, obj, movedetla)
	local v = self.m_PageContainer:GetLocalPos()
	v.x = v.x + movedetla.x
	self.m_PageContainer:SetLocalPos(v)
end

function CLinkScrollBox.OnDragEnd(self, obj)
	local width = self.m_Width
	local v = self.m_PageContainer:GetLocalPos()
	local delta = (v.x - self.m_StartX) % width
	local leftidx = math.floor((v.x - self.m_StartX) / width)
	local idx = leftidx
	local lastidx = 1 - self.m_DataIdx
	if delta < width/2 then
		idx = leftidx
	else
		idx = leftidx + 1
	end
	idx = math.max(idx, lastidx - 1)
	idx = math.min(idx, lastidx + 1)
	if -idx < 0 then
		idx = 0
	end
	if -idx + 1 > self.m_MaxPage then
		idx = 1 - self.m_MaxPage
	end
	
	v.x = idx * width + self.m_StartX
	self.m_PageContainer:SetLocalPos(v)
	self.m_DataIdx = -idx + 1
	self:RefreshPageIdx()
	self:RefreshNext()
end

function CLinkScrollBox.RefreshNext(self)
	local width = self.m_Width
	for i = 1, 3 do
		local x = self.m_PageContainer:GetLocalPos().x + self.m_PageList[i]:GetLocalPos().x
		if x < self.m_LeftPageX then
			self:RefreshRight(i)
			return
		end
		if x > self.m_RightPageX then
			self:RefreshLeft(i)
			return
		end
	end
end

function CLinkScrollBox.RefreshLeft(self, i)
	local page = self.m_PageList[i]
	local v = page:GetLocalPos()
	v.x = v.x - 3*self.m_Width
	page:SetLocalPos(v)
	local dData = self.m_DataSource[self.m_DataIdx-1]
	if dData then
		page:SetActive(true)
		self.m_FactoryFunc(page, dData)
		page.m_DataIdx = i
	else
		page:SetActive(false)
	end
end

function CLinkScrollBox.RefreshRight(self, i)
	local page = self.m_PageList[i]
	local v = page:GetLocalPos()
	v.x = v.x + 3*self.m_Width
	page:SetLocalPos(v)
	local dData = self.m_DataSource[self.m_DataIdx+1]
	if dData then
		page:SetActive(true)
		self.m_FactoryFunc(page, dData)
		page.m_DataIdx = i
	else
		page:SetActive(false)
	end
end

function CLinkScrollBox.RefreshPageIdx(self)
	local str = string.format("%d/%d", self.m_DataIdx, self.m_MaxPage)
	self.m_PageLabel:SetText(str)
end

function CLinkScrollBox.RefreshPageContent(self, func)
	if func then
		for i = 1, 3 do
			if self.m_PageList[i].m_Init then
				func(self.m_PageList[i])
			end
		end
	end
end
return CLinkScrollBox