local CFactoryPartScroll = class("CFactoryPartScroll", CBox)

function CFactoryPartScroll.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_DotGrid = self:NewUI(1, CGrid)
	self.m_DotClone = self:NewUI(2, CBox)
	self.m_PartGrid = self:NewUI(3, CGrid)
	self.m_PartClone = self:NewUI(4, CFactoryPart)
	self.m_ScrollView = self:NewUI(5, CScrollView)
	self.m_PartSize = {col=5, row=5}
	self.m_Capacity = 25
	self.m_BoxFactoryFunc = nil
	self.m_CurPartIdx = 1
	self.m_PartCnt = 1
	self:InitContent()
end

function CFactoryPartScroll.InitContent(self)
	self.m_DotClone:SetActive(false)
	self.m_PartClone:SetActive(false)
	self.m_ScrollView:InitCenterOnCompnent(self.m_PartGrid, callback(self, "OnCenter"))
end

function CFactoryPartScroll.OnCenter(self, oScrollView, gameObject)
	if gameObject == self.m_CurCenterObj then
		return
	end 
	local idx = self.m_PartGrid:GetChildIdx(gameObject.transform)

	-- for i, v in ipairs(self.m_PartGrid.m_TransformList) do
	-- 	print(i, v:GetInstanceID(), gameObject.transform:GetInstanceID())
	-- end
	self.m_CurPartIdx = idx
	self.m_CurCenterObj = gameObject
	self:RefreshDot()
end

function CFactoryPartScroll.RefreshDot(self)
	local oDot = self.m_DotGrid:GetChild(self.m_CurPartIdx)
	if oDot then
		oDot:SetSelected(true)
	end
	if self.m_RefreshDotCb then
		self.m_RefreshDotCb(self.m_CurPartIdx, self.m_PartCnt)
	end
end

function CFactoryPartScroll.SetPartSize(self, col, row)
	self.m_PartSize = {col=col, row=row}
	self.m_Capacity = self.m_PartSize.col *self.m_PartSize.row
end

function CFactoryPartScroll.SetFactoryFunc(self, func)
	self.m_BoxFactoryFunc = func
end

function CFactoryPartScroll.SetDataSource(self, f)
	self.m_DataSource = f
end

function CFactoryPartScroll.SetRefreshDotCb(self, cb)
	self.m_RefreshDotCb = cb
end

function CFactoryPartScroll.RefreshAll(self)
	self.m_PartGrid:Clear()
	self.m_DotGrid:Clear()
	self.m_AllData = self.m_DataSource() 
	self.m_CurPartIdx = 1
	local iAll = #self.m_AllData
	local iPartCnt = math.ceil(iAll/ self.m_Capacity)
	self.m_PartCnt = iPartCnt
	for i=1, iPartCnt do
		local oPart = self.m_PartClone:Clone()
		oPart:SetActive(true)
		oPart:SetSize(self.m_PartSize.col, self.m_PartSize.row)
		oPart:SetFactoryFunc(self.m_BoxFactoryFunc)
		local lBoxData = table.slice(self.m_AllData, (i-1)*self.m_Capacity+1, i*self.m_Capacity)
		oPart:SetData(lBoxData)
		self.m_PartGrid:AddChild(oPart)

		local oDot = self.m_DotClone:Clone()
		oDot:SetActive(true)
		oDot:SetGroup(self.m_DotGrid:GetInstanceID())
		self.m_DotGrid:AddChild(oDot)
	end
	self.m_PartGrid:Reposition()
	if #self.m_AllData > 0 then
		UITools.MoveToTarget(self.m_ScrollView, self.m_PartGrid:GetChild(self.m_CurPartIdx))
		self:RefreshDot()
	end
end

function CFactoryPartScroll.GetChildList(self)
	local list = {}
	for i, oPart in ipairs(self.m_PartGrid:GetChildList()) do
		for i, oBox in ipairs(oPart.m_Grid:GetChildList()) do
			table.insert(list, oBox)
		end
	end
	return list
end

function CFactoryPartScroll.OnCenterIndex(self, index, moveAction)
	if self.m_CurPartIdx == index then
		return
	end 
	local go = self.m_PartGrid:GetChild(index)
	if go then
		self:OnCenter(nil, go.m_GameObject)
	end
	--带切换动画
	if moveAction then
		self.m_ScrollView:CenterOn(self.m_PartGrid:GetChild(self.m_CurPartIdx).m_Transform)
	else
		UITools.MoveToTarget(self.m_ScrollView, self.m_PartGrid:GetChild(self.m_CurPartIdx))		
	end
end


return CFactoryPartScroll