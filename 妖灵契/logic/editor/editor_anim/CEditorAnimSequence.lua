local CEditorAnimSequence = class("CEditorAnimSequence", CBox)

function CEditorAnimSequence.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_AddBtn = self:NewUI(1, CButton)
	self.m_DelBtn = self:NewUI(2, CButton)
	self.m_TotalFrameLabel = self:NewUI(3, CLabel)
	self.m_BoxTable = self:NewUI(4, CTable)
	self.m_BoxClone = self:NewUI(5, CEditorAnimBox)
	self.m_AddBtn:AddUIEvent("click", callback(self, "OnAdd"))
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnDel"))
	
	self.m_BoxClone:SetActive(false)
	self.m_SelectBox = nil
	self.m_TotalFrame = 0
end

function CEditorAnimSequence.OnAdd(self)
	local data, idx
	if self.m_SelectBox then
		idx = self.m_SelectBox.m_Index + 1
		data = self.m_SelectBox:GetData()
	end
	self:AddBox(data, idx)
end

function CEditorAnimSequence.Clear(self)
	self.m_BoxTable:Clear()
	self.m_SelectBox = nil
	self:RefreshTotalFrame()
end

function CEditorAnimSequence.AddBox(self, dData, idx)
	local oBox = self.m_BoxClone:Clone()
	oBox:SetActive(true)
	oBox:InitContent()
	oBox:SetGroup(self:GetInstanceID())
	oBox:SetIndex(self.m_BoxTable:GetCount()+1)
	oBox:AddUIEvent("click", callback(self, "OnSelectBox"))
	if dData then
		oBox:Refresh(dData)
	else
		oBox:SetDefalut()
	end
	oBox:SetChangeCallback(callback(self, "RefreshTotalFrame"))
	self.m_BoxTable:AddChild(oBox)
		self.m_BoxTable:AddChild(oBox)
	if idx then
		oBox:SetSiblingIndex(idx)
	end
	self:RefreshTotalFrame()
end

function CEditorAnimSequence.RefreshTotalFrame(self)
	self.m_TotalFrame = 0
	for i, oBox in ipairs(self.m_BoxTable:GetChildList()) do
		self.m_TotalFrame = self.m_TotalFrame + oBox:GetDuration()
		oBox:SetIndex(i)
	end
	self.m_TotalFrameLabel:SetText("总帧数"..tostring(self.m_TotalFrame))
	if self.m_FrameCallback then
		self.m_FrameCallback()
	end
end

function CEditorAnimSequence.OnSelectBox(self, oBox)
	oBox:SetSelected(true)
	self.m_SelectBox = oBox
end

function CEditorAnimSequence.OnDel(self)
	if self.m_SelectBox then
		self.m_BoxTable:RemoveChild(self.m_SelectBox)
		self:RefreshTotalFrame()
	end
end

function CEditorAnimSequence.GetSequence(self)
	local list ={}
	for i, oBox in ipairs(self.m_BoxTable:GetChildList()) do
		table.insert(list, oBox:GetData())
	end
	return list
end

function CEditorAnimSequence.Refresh(self, list)
	self.m_BoxTable:Clear()
	for i, v in ipairs(list) do
		self:AddBox(v)
	end
	self:RefreshTotalFrame()
end

function CEditorAnimSequence.SetFrameRefreshCB(self, cb)
	self.m_FrameCallback = cb
end

return CEditorAnimSequence