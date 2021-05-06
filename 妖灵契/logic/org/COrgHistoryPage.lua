local COrgHistoryPage = class("COrgHistoryPage", CPageBase)

function COrgHistoryPage.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function COrgHistoryPage.OnInitPage(self)
	self.m_NodeTable = self:NewUI(1, CTable)
	self.m_InfoBox = self:NewUI(2, CBox)
	self.m_DateBox = self:NewUI(3, CBox)
	self:InitContent()
end

function COrgHistoryPage.InitContent(self)
	self.m_InfoBoxArr = {}
	self.m_DateBoxArr = {}
end

function COrgHistoryPage.SetData(self)
	self.m_Data = g_OrgCtrl:GetLogInfo()
	self:ResetGrid()

	local infoBoxCount = 0
	local dateBoxCount = 0
	for k,dateInfo in ipairs(self.m_Data) do
		dateBoxCount = dateBoxCount + 1
		if self.m_DateBoxArr[dateBoxCount] == nil then
			self.m_DateBoxArr[dateBoxCount] = self:CreateDateBox()
		end
		self.m_DateBoxArr[dateBoxCount]:SetActive(true)
		self.m_DateBoxArr[dateBoxCount]:SetData(dateInfo.date)
		self.m_NodeTable:AddChild(self.m_DateBoxArr[dateBoxCount])
		for i,logInfo in ipairs(dateInfo.infoList) do
			infoBoxCount = infoBoxCount + 1
			if self.m_InfoBoxArr[infoBoxCount] == nil then
				self.m_InfoBoxArr[infoBoxCount] = self:CreateInfoBox()
			end
			self.m_InfoBoxArr[infoBoxCount]:SetActive(true)
			self.m_InfoBoxArr[infoBoxCount]:SetData(logInfo)
			self.m_NodeTable:AddChild(self.m_InfoBoxArr[infoBoxCount])
		end
	end

	self.m_InfoBox:SetActive(false)
	self.m_DateBox:SetActive(false)
	self.m_NodeTable:Reposition()
end

function COrgHistoryPage.ResetGrid(self)
	self.m_InfoBoxArr = {}
	self.m_DateBoxArr = {}
	self.m_NodeTable:Clear()
	-- for k,v in pairs(self.m_InfoBoxArr) do
	-- 	v.m_Transform:SetParent(nil)
	-- 	v:SetActive(false)
	-- end
	-- for k,v in pairs(self.m_DateBoxArr) do
	-- 	v.m_Transform:SetParent(nil)
	-- 	v:SetActive(false)
	-- end
end

function COrgHistoryPage.CreateInfoBox(self)
	local oInfoBox = self.m_InfoBox:Clone()
	oInfoBox.m_TimeLabel = oInfoBox:NewUI(1, CLabel)
	oInfoBox.m_PosLabel = oInfoBox:NewUI(2, CLabel)
	oInfoBox.m_ContentLabel = oInfoBox:NewUI(3, CLabel)
	function oInfoBox.SetData(self, oData)
		local timeStr = os.date("%H:%M", oData.time)
		oInfoBox.m_TimeLabel:SetText(timeStr)
		if oData.position == 0 then
			oInfoBox.m_PosLabel:SetText("[系统]")
		else
			oInfoBox.m_PosLabel:SetText(string.format("[%s]", g_OrgCtrl:GetPosition(oData.position).pos))
		end
		oInfoBox.m_ContentLabel:SetText(oData.text)
	end
	return oInfoBox
end

function COrgHistoryPage.CreateDateBox(self)
	local oDateBox = self.m_DateBox:Clone()
	oDateBox.m_Label = oDateBox:NewUI(1, CLabel)
	function oDateBox.SetData(self, oData)
		oDateBox.m_Label:SetText(oData)
	end
	return oDateBox
end

return COrgHistoryPage