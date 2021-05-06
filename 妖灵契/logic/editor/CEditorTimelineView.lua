local CEditorTimelineView = class("CEditorTimelineView", CViewBase)

function CEditorTimelineView.ctor(self, cb)
	CViewBase.ctor(self, "UI/_Editor/EditorTimelineView.prefab", cb)
end

function CEditorTimelineView.OnCreateView(self)
	self.m_WhiteSpr = self:NewUI(1, CSprite)
	self.m_RulerGrid = self:NewUI(2, CGrid)
	self.m_RulerSizeBg = self:NewUI(3, CSprite)
	self.m_ValueLabel = self:NewUI(4, CLabel)

	self.m_TimeLineBox = self:NewUI(5, CEditorTimelineBox)
	self.m_TimeLineTable = self:NewUI(6, CTable)
	self.m_CloseBtn = self:NewUI(7, CButton)
	self.m_Slider = self:NewUI(8, CSlider)
	self.m_SliderLabel = self:NewUI(9, CLabel)
	self.m_ConfirmBtn =self:NewUI(10, CButton)
	self.m_WhiteSpr:SetActive(false)
	self.m_ValueLabel:SetActive(false)
	self.m_TimeLineBox:SetActive(false)
	self.m_MaxTime = 1
	-- self:SetTimelineData(2, {
	-- 	{begin_time = 1,
	-- 	length_time = 0.5,
	-- 	desc = "测试描述",},
	-- 	{begin_time = 0.5,
	-- 	length_time = 0.8,
	-- 	desc = "测试描述",},
	-- })
	self.m_Slider:AddUIEvent("change", callback(self, "RefreshSliderLabel"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
end

function CEditorTimelineView.OnConfirm(self)
	local list = self.m_TimeLineTable:GetChildList()
	local len = #list
	for i, oBox in ipairs(list) do
		oBox:RefreshValue(i==len)
	end
end

function CEditorTimelineView.RefreshSliderLabel(self)
	local iVal = self.m_Slider:GetValue() * (self.m_MaxTime+0.1)
	self.m_SliderLabel:SetText(string.format("%.2f", iVal))
end

function CEditorTimelineView.SetTimelineData(self, iMaxTime, lTimeData)
	self.m_MaxTime = iMaxTime
	self.m_Data = lTimeData
	self:RefreshMaxTime()
	self:RefreshDataTable()
	self:RefreshSliderLabel()
end

function CEditorTimelineView.RefreshMaxTime(self)
	local w, h =self.m_RulerSizeBg:GetSize()
	local iCnt = 0
	local iFactor = 10
	self.m_RulerGrid:Clear()
	for iCur=0, (self.m_MaxTime+0.1)*iFactor, iFactor*0.1 do
		local oLine = self.m_WhiteSpr:Clone()
		oLine:SetActive(true)
		local oLabel
		if iCur % iFactor == 0 then
			oLine:SetLocalScale(Vector3.New(1, 1.6, 1))
			oLabel = self.m_ValueLabel:Clone()
		elseif iCur % (iFactor*0.5) == 0 then
			oLine:SetLocalScale(Vector3.New(1, 1.3, 1))
			oLabel = self.m_ValueLabel:Clone()
		end
		if oLabel then
			oLabel:SetActive(true)
			oLabel:SetText(tostring(iCur/iFactor))
			oLabel:SetParent(oLine.m_Transform)
			oLabel:SetLocalPos(Vector3.New(0, -10, 0))
		end
		iCnt = iCnt + 1
		self.m_RulerGrid:AddChild(oLine)
	end
	self.m_RulerGrid.m_UIGrid.cellWidth = w / (iCnt-1)
	self.m_RulerGrid:Reposition()
end

function CEditorTimelineView.RefreshDataTable(self)
	self.m_TimeLineTable:Clear()
	local w, h =self.m_RulerSizeBg:GetSize()
	local iWidthPerSec = self.m_RulerGrid.m_UIGrid.cellWidth * 10
	

	for i, dData in ipairs(self.m_Data) do
		local oBox = self.m_TimeLineBox:Clone()
		oBox:SetActive(true)
		oBox:SetWidthPerSec(iWidthPerSec)
		oBox:SetData(dData)
		self.m_TimeLineTable:AddChild(oBox)
	end
end

return CEditorTimelineView