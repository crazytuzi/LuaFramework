local CMiscSelectView = class("CMiscSelectView", CViewBase)

function CMiscSelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Misc/MiscSelectView.prefab", cb)
	self.m_DepthType = "Notify"
	self.m_ExtendClose = "Balck"
end

function CMiscSelectView.OnCreateView(self)
	self.m_CloseBtn =  self:NewUI(1, CButton)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_SelItemBox = self:NewUI(3, CBox)
	self.m_ConfirmBtn = self:NewUI(4, CButton)
	self.m_SearchInput = self:NewUI(5, CInput)
	self.m_CancelSearchBtn = self:NewUI(6, CButton)
	self.m_ScrollView = self:NewUI(7, CScrollView)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self.m_SelItemBox:SetActive(false)
	self.m_SelList= nil
	self.m_SelFunc = nil
	self.m_WrapFunc = nil
	self.m_SelValue = ""
	if Utils.IsEditor() then
		self.m_SearchInput:SetFocus(true)
	end
	self.m_SearchInput:AddUIEvent("change", callback(self, "OnSearch"))
	self.m_CancelSearchBtn:AddUIEvent("click", callback(self, "OnCancelSearch"))
end

function CMiscSelectView.OnCancelSearch(self)
	self.m_SearchInput:SetText("")
end

function CMiscSelectView.OnSearch(self)
	self:RefreshGrid()
end

function CMiscSelectView.SetData(self, list, selFunc, wrapFunc)
	self.m_SelList= list
	self.m_SelFunc = selFunc
	self.m_WrapFunc = wrapFunc
	self:RefreshGrid(list)
end

function CMiscSelectView.RefreshGrid(self, list)
	self.m_Grid:Clear() 
	local sMatch = self.m_SearchInput:GetText()
	if sMatch == "" then
		sMatch = nil
	end
	for i, v in ipairs(self.m_SelList) do
		local sWrap = v
		if self.m_WrapFunc then
			sWrap = self.m_WrapFunc(v)
		end
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

function CMiscSelectView.OnClick(self, oBtn)
	oBtn:SetSelected(true)
	if self.m_SelValue == oBtn.m_OriValue then
		self:OnConfirm(oBtn)
	else
		self.m_SelValue = oBtn.m_OriValue
	end
end

function CMiscSelectView.OnConfirm(self, oBtn)
	if self.m_SelValue ~= nil then
		self.m_SelFunc(self.m_SelValue)
		self:CloseView()
	end
end


return CMiscSelectView