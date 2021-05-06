local CReportView = class("CReportView", CViewBase)

function CReportView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Friend/ReportView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CReportView.OnCreateView(self)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_SelectBox = self:NewUI(3, CBox)
	self.m_ConfirmBtn = self:NewUI(4, CButton)
	self.m_CancelBtn = self:NewUI(5, CButton)
	self.m_Input = self:NewUI(6, CInput)
	self:InitContent()
end

function CReportView.InitContent(self)
	self.m_SelectBox:SetActive(false)
	self:InitGrid()
	self.m_SelectList = {}
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnReport"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CReportView.InitGrid(self)
	self.m_Grid:Clear()
	local list = {
		"诈骗行为", "言行不雅",
		"广告刷屏", "使用外挂",
		"名字违规", "其他行为",
	}
	for i, name in ipairs(list) do
		local box = self.m_SelectBox:Clone()
		box.m_Button = box:NewUI(1, CButton)
		box.m_SelBtn = box:NewUI(2, CButton)
		box.m_Button:SetText(name)
		box.m_SelBtn:SetText(name)
		box.m_Type = i
		box.m_Button:AddUIEvent("click", callback(self, "OnSelectType", box))
		box.m_SelBtn:AddUIEvent("click", callback(self, "OnCancelSelect", box))
		box:SetActive(true)
		self.m_Grid:AddChild(box)
	end
end

function CReportView.UpdatePlayer(self, iPid, sName)
	self.m_ID = iPid
	self.m_NameLabel:SetText(sName)
end

function CReportView.OnSelectType(self, box)
	if #self.m_SelectList >= 2 then
		g_NotifyCtrl:FloatMsg("最多选择2个举报原因")
		return
	end
	box.m_Button:SetActive(false)
	box.m_SelBtn:SetActive(true)
	if not table.index(self.m_SelectList, box.m_Type) then
		table.insert(self.m_SelectList, box.m_Type)
	end
end

function CReportView.OnCancelSelect(self, box)
	box.m_Button:SetActive(true)
	box.m_SelBtn:SetActive(false)
	local index = table.index(self.m_SelectList, box.m_Type)
	if index then
		table.remove(self.m_SelectList, index)
	end
end

function CReportView.OnReport(self)
	local list = {
		"诈骗行为", "言行不雅",
		"广告刷屏", "使用外挂",
		"名字违规", "其他行为",
	}
	local reasonList = {}
	for _, idx in ipairs(self.m_SelectList) do
		if list[idx] then
			table.insert(reasonList, list[idx])
		end
	end
	if #reasonList == 0 then
		g_NotifyCtrl:FloatMsg("请选择举报原因")
		return
	end
	if #reasonList == 1 and reasonList[1] == 6 and self.m_Input:GetText() == "" then
		g_NotifyCtrl:FloatMsg("举报其他行为时需说明举报原因")
		return
	end
	netchat.C2GSReportPlayer(self.m_ID,  table.concat(reasonList, ","), self.m_Input:GetText())
	self:OnClose()
end

return CReportView