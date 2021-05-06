local CLostBookFilterView = class("CLostBookFilterView", CViewBase)

CLostBookFilterView.LostData = {
	{
		name = "佚存进度",
		list = {"无指定", "高至低", "低至高"},
	},
	{
		name = "",
		list = {"无指定", "绘像已修", "名字已录", "绘像未修", "名字未录"},
	},
	{
		name = "佚文状态",
		list = {"无指定", "未解锁", "可解锁", "已解锁", "已解未阅", "已阅读"},
	},
	{
		name = "人物性别",
		list = {"无指定", "她", "他", "它"},
	},
}

CLostBookFilterView.PartnerData = {
	{
		name = "章节进度",
		list = {"无指定", "高至低", "低至高"},
	},
	{
		name = "伙伴品质",
		list = {"无指定", "传说", "精英"},
	},
	{
		name = "相遇状态",
		list = {"无指定", "未相遇", "已相遇", "相遇未阅", "已阅读"},
	},
	{
		name = "伙伴性别",
		list = {"无指定", "她", "他"},
	},
}

function CLostBookFilterView.ctor(self, cb)
	CViewBase.ctor(self, "UI/MapBook/LostBookFilterView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Dialog"
end

function CLostBookFilterView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Table = self:NewUI(2, CTable)
	self.m_ItemBox = self:NewUI(3, CBox)
	self.m_ResetBtn = self:NewUI(4, CButton)
	self.m_ConfirmBtn = self:NewUI(5, CButton)
	self:InitContent()
end

function CLostBookFilterView.InitContent(self)
	self.m_ItemBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ResetBtn:AddUIEvent("click", callback(self, "OnReset"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	--self:CreateTable()
end

function CLostBookFilterView.SetType(self, sType)
	self.m_Type = sType
	self:CreateTable()
end

function CLostBookFilterView.CreateTable(self)
	self.m_Table:Clear()
	local filterdata = nil
	if self.m_Type == "PartnerBook" then
		filterdata = CLostBookFilterView.PartnerData
	
	elseif self.m_Type == "LostBook" then
		filterdata = CLostBookFilterView.LostData
	end
	
	for _, tdata in ipairs(filterdata) do
		local box = self.m_ItemBox:Clone()
		box:SetActive(true)
		box.m_Label = box:NewUI(1, CLabel)
		box.m_Grid = box:NewUI(2, CGrid)
		box.m_Btn = box:NewUI(3, CButton)
		box.m_Btn:SetActive(false)
		box.m_Label:SetText(tdata["name"])
		box.m_Grid:Clear()
		for _, name in ipairs(tdata["list"]) do
			local btn = box.m_Btn:Clone()
			btn:SetGroup(box:GetInstanceID())
			btn:SetActive(true)
			btn:SetText(name)
			box.m_Grid:AddChild(btn)
			btn.m_Name = name
			if name == "无指定" then
				btn:SetSelected(true)
			end
		end
		box.m_Grid:Reposition()
		self.m_Table:AddChild(box)
	end
	self.m_Table:Reposition()
end

function CLostBookFilterView.SetLastList(self, keyList, callBack)
	keyList = keyList or {}
	for i, box in ipairs(self.m_Table:GetChildList()) do
		local name = keyList[i] or "无指定"
		for _, btn in ipairs(box.m_Grid:GetChildList()) do
			if btn.m_Name == name then
				btn:SetSelected(true)
				break
			end
		end
	end
	self.m_CallBack = callBack
end

function CLostBookFilterView.OnReset(self)
	for _, box in ipairs(self.m_Table:GetChildList()) do
		for _, btn in ipairs(box.m_Grid:GetChildList()) do
			if btn.m_Name == "无指定" then
				btn:SetSelected(true)
				break
			end
		end
	end
end

function CLostBookFilterView.OnConfirm(self)
	local list = {}
	for _, box in ipairs(self.m_Table:GetChildList()) do
		for _, btn in ipairs(box.m_Grid:GetChildList()) do
			if btn:GetSelected() then
				table.insert(list, btn.m_Name)
				break
			end
		end
	end
	if self.m_CallBack then
		self.m_CallBack(list)
	end
	self:OnClose()
end

return CLostBookFilterView