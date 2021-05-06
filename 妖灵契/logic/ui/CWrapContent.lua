local CWrapContent = class("CWrapContent", CObject, CUIEventHandler)

function CWrapContent.ctor(self, obj)
	CObject.ctor(self, obj)
	CUIEventHandler.ctor(self, obj)
	self.m_UIWrapContent = self:GetComponent(classtype.UIWrapContent)
	self.m_UIScollView = self.m_UIWrapContent.scrollView
	self.m_UIWrapContent.maxIndex = 0
	self.m_DataList = {}
	self.m_CurDataIdx = 1
	self.m_RefreshFunc = nil
	self.m_ChildMap = {}
	self.m_ChildCnt = 0
	self.m_IsLoopRoll = nil
	self:AddUIEvent("UIWrapContentOnInitializeItem", callback(self, "OnInitializeItem"))
end

--public
function CWrapContent.SetCloneChild(self, oClone, init)
	self.m_ChildClone = oClone
	self.m_InitChildFunc = init
end

--public
function CWrapContent.SetRefreshFunc(self, func)
	self.m_RefreshFunc = func
end

--public
function CWrapContent.SetData(self, lData, bSort, bLoop)
	self.m_DataList = lData
	self.m_UIWrapContent.minIndex = -math.max(#lData-1, 1)
	local iNeed = self.m_UIWrapContent.reuqiredItemCnt - self.m_ChildCnt
	if iNeed > 0 then
		for i=1, iNeed do
			local oBox = self.m_ChildClone:Clone()
			self:AddChild(oBox)
		end
	end
	if iNeed > 0 or bSort then
		self.m_UIWrapContent:SortChilds()
	end
	--要等全部box都加完再设置，不然只显示一个box
	if bLoop then
		self.m_UIWrapContent.minIndex = 0
		self.m_IsLoopRoll = bLoop
	end
end

--private
function CWrapContent.Clear(self)
	self:SetData({})
	for _, v in pairs(self.m_ChildMap) do
		v:SetParent(nil)
		v:Destroy()
	end
	self.m_UIWrapContent:SortChilds()
	self.m_ChildMap = {}
	self.m_ChildCnt = 0
end
function CWrapContent.AddChild(self, oChild)
	oChild:SetParent(self.m_Transform, false)
	oChild = self.m_InitChildFunc(oChild)
	self.m_ChildMap[oChild.m_GameObject:GetInstanceID()] = oChild
	oChild:SetName("Box"..tostring(table.count(self.m_ChildMap)))
	self.m_ChildCnt = self.m_ChildCnt + 1
end

function CWrapContent.GetChildList(self)
	local list = {}
	for _, v in pairs(self.m_ChildMap) do
		table.insert(list, v)
	end
	return list
end

--private
function CWrapContent.OnInitializeItem(self, oWrapContent, gameObject, idx, realidx)
	local oBox = self.m_ChildMap[gameObject:GetInstanceID()]
	if oBox then
		local iDataIdx
		if self.m_IsLoopRoll then
			iDataIdx = (math.abs(realidx) % #self.m_DataList) + 1
		else
			iDataIdx = math.abs(realidx) + 1
		end
		local dData = self.m_DataList[iDataIdx]
		self:RefreshBox(oBox, iDataIdx, dData)
	end
end

function CWrapContent.RefreshBox(self, oBox, iDataIdx, dData)
	oBox.m_Index = iDataIdx
	if self.m_RefreshFunc then
		self.m_RefreshFunc(oBox, dData)
	end
end

function CWrapContent.MoveRelative(self, v)
	self.m_UIWrapContent:MoveRelative(v)
end

function CWrapContent.GetSize(self)
	if not self.m_UIWidget then
		self.m_UIWidget = self:GetMissingComponent(classtype.UIWidget)
	end
	return self.m_UIWidget.width, self.m_UIWidget.height
end

function CWrapContent.SetSize(self, iW, iH)
	if not self.m_UIWidget then
		self.m_UIWidget = self:GetMissingComponent(classtype.UIWidget)
	end
	self.m_UIWidget.width = iW
	self.m_UIWidget.height = iH
end

function CWrapContent.Refresh(self)
	if not self.m_DataList or not self.m_RefreshFunc then
		return
	end
	for k,v in pairs(self.m_ChildMap) do
		self.m_RefreshFunc(v, self.m_DataList[v.m_Index])
	end
end

return CWrapContent