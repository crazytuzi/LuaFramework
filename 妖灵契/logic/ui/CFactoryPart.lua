local CFactoryPart = class("CFactoryPart", CBox)

function CFactoryPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_BoxClone = self:NewUI(2, CBox)
	self:InitContent()
	self.m_CreateIdx = 1
	self.m_BoxDataList = {}
	self.m_CreateTimer = Utils.AddTimer(callback(self, "FrameCreate"), 0, 0)
end

function CFactoryPart.InitContent(self)
	self.m_BoxClone:SetActive(false)
end

function CFactoryPart.SetSize(self, col, row)
	self.m_Col = col
	self.m_Row = row
	self.m_Grid:SetMaxPerLine(col)
end

function CFactoryPart.SetFactoryFunc(self, f)
	self.m_FactoryFunc = f
end

function CFactoryPart.SetData(self, lBoxData)
	self.m_BoxDataList = lBoxData
	self.m_CreateIdx = 1
	self.m_Grid:Clear()
	-- self:RefeshGrid()
end

function CFactoryPart.FrameCreate(self)
	if self.m_CreateIdx <= #self.m_BoxDataList then
		local dInfo = self.m_BoxDataList[self.m_CreateIdx]
		local oBox = self.m_FactoryFunc(self.m_BoxClone, dInfo)
		if oBox then
			self.m_Grid:AddChild(oBox)
			self.m_Grid:Reposition()
		end
		self.m_CreateIdx = self.m_CreateIdx + 1
	end
	return true
end

function CFactoryPart.RefeshGrid(self)
	for i= 1, self.m_Col * self.m_Row do
		local dInfo = self.m_BoxDataList[i]
		local oBox = self.m_FactoryFunc(self.m_BoxClone, dInfo)
		if oBox then
			self.m_Grid:AddChild(oBox)
		end
	end
end



return CFactoryPart