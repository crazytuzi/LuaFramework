local CEditorDialogueSelectView = class("CEditorDialogueSelectView", CViewBase)

function CEditorDialogueSelectView.ctor(self, cb)	
	CViewBase.ctor(self, "UI/_Editor/EditorDialogueNpcAni/EditorDialogueSelectView.prefab", cb)
	self.m_ExtendClose = "Balck"
end

function CEditorDialogueSelectView.OnCreateView(self)
	self.m_CloseBtn =  self:NewUI(1, CButton)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_SelItemBox = self:NewUI(3, CBox)
	self.m_ConfirmBtn = self:NewUI(4, CButton)
	self.m_SearchInput = self:NewUI(5, CInput)
	self.m_CancelSearchBtn = self:NewUI(6, CButton)
	self.m_ScrollView = self:NewUI(7, CScrollView)
	self.m_NewBtn = self:NewUI(8, CButton)
	self.m_TitleLabel = self:NewUI(9, CLabel)
	self.m_ConfirmMidBtn = self:NewUI(10, CButton)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self.m_ConfirmMidBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self.m_NewBtn:AddUIEvent("click", callback(self, "OnNewFile"))
	self.m_SelItemBox:SetActive(false)
	self.m_SelList= nil
	self.m_SelFunc = nil
	self.m_SelValue = ""
	if Utils.IsEditor() then
		self.m_SearchInput:SetFocus(true)
	end
	self.m_SearchInput:AddUIEvent("change", callback(self, "OnSearch"))
	self.m_CancelSearchBtn:AddUIEvent("click", callback(self, "OnCancelSearch"))
end

function CEditorDialogueSelectView.OnCancelSearch(self)
	self.m_SearchInput:SetText("")
end

function CEditorDialogueSelectView.OnSearch(self)
	self:RefreshGrid()
end

function CEditorDialogueSelectView.SetData(self, list, selFunc, title)
	self.m_SelList= list
	self.m_SelFunc = selFunc

	self.m_CancelSearchBtn:SetActive(false)
	self.m_SearchInput:SetActive(false)
	self.m_ConfirmBtn:SetActive(false)
	self.m_NewBtn:SetActive(false)
	self.m_TitleLabel:SetActive(false)
	self.m_ConfirmMidBtn:SetActive(false)
	if title then
		self.m_TitleLabel:SetText(title)
		self.m_TitleLabel:SetActive(true)
		self.m_ConfirmMidBtn:SetActive(true)		
		self.m_CancelSearchBtn:SetActive(true)
		self.m_SearchInput:SetActive(true)
	else
		self.m_CancelSearchBtn:SetActive(true)
		self.m_SearchInput:SetActive(true)
		self.m_ConfirmBtn:SetActive(true)
		self.m_NewBtn:SetActive(true)
	end

	self:RefreshGrid(list)
end

function CEditorDialogueSelectView.RefreshGrid(self, list)
	self.m_Grid:Clear() 
	local sMatch = self.m_SearchInput:GetText()
	if sMatch == "" then
		sMatch = nil
	end
	for i, v in ipairs(self.m_SelList) do
		local sWrap = v
		if not sMatch or string.find(sWrap, sMatch) then
			local oBox = self.m_SelItemBox:Clone()
			oBox:SetActive(true)
			local oBtn = oBox:NewUI(1, CButton, false)
			oBtn:SetGroup(self:GetInstanceID())
			oBtn.m_OriValue = v
			
			oBtn:SetText(sWrap)
			oBtn:AddUIEvent("click", callback(self, "OnClick"))
			oBox.m_Btn = oBtn
			self.m_Grid:AddChild(oBox)
			if not self.m_SelValue then
				self:OnClick(oBtn)
			end
		end
	end
	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CEditorDialogueSelectView.OnClick(self, oBtn)
	oBtn:SetSelected(true)
	if self.m_SelValue == oBtn.m_OriValue then
		self:OnConfirm(oBtn)
	else
		self.m_SelValue = oBtn.m_OriValue
	end
end

function CEditorDialogueSelectView.OnNewFile(self)
	local nid = tonumber(self.m_SearchInput:GetText())
	if not nid then
		g_NotifyCtrl:FloatMsg("请输入数字id,创建文件")
		return
	end
	if self.m_SelValue ~= nil then
		self.m_SelFunc(string.format("_%d", nid))
		self:CloseView()
	end
end

function CEditorDialogueSelectView.OnConfirm(self, oBtn)
	if self.m_SelValue ~= nil then
		if self.m_SelValue ~= "" then
			self.m_SelFunc(self.m_SelValue)
		end		
		self:CloseView()	
	end
end

return CEditorDialogueSelectView