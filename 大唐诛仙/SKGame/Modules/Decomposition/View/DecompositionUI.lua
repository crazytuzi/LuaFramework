DecompositionUI = BaseClass(LuaUI)
function DecompositionUI:__init()
	local ui = UIPackage.CreateObject("Decomposition","DecompositionUI")
	self.ui = ui
	self.uiLeft = ui:GetChild("uiLeft")
	self.uiLeft = DecompositionUILeft.Create(self.uiLeft, DecompositionConst.Decomposition)
	self.uiRight = ui:GetChild("uiRight")
	self.uiRight = DecompositionUIRight.Create(self.uiRight, DecompositionConst.Decomposition)
	self.imgTips = ui:GetChild("imgTips")
	self.labelTips = ui:GetChild("labelTips")

	self.model = DecompositionModel:GetInstance()
	self.uiLeft:SetUI()
	self.isInitUI = true

	self:InitEvent()
end

function DecompositionUI:HandleClose() --清除特效
	if self.uiRight then
		self.uiRight:HandleClose()
	end
end
function DecompositionUI:__delete()
	if self.uiLeft then
		self.uiLeft:Destroy()
		self.uiLeft = nil
	end
	if self.uiRight then
		self.uiRight:Destroy()
		self.uiRight = nil
	end
	self.model:RemoveEventListener(self.handler0)
end

function DecompositionUI:Update()
	if self.isInitUI == true then
		if self.uiLeft then
			self.uiLeft:CleanSelectCellUIAndData()
		end
		if self.uiRight then
			self.uiRight:CleanSelectCellUIAndData()
			self.uiRight:CleanAllEffect()
			self.uiRight:SetDefaultTips()
			self.uiRight:EnableBtnDecomposition()
		end
	end
end

function DecompositionUI:InitEvent()
	self.handler0 = self.model:AddEventListener(DecompositionConst.UpdateItems, function ()
		if self.uiLeft then
			self.uiLeft:UpdateUI()
		end
	end)
end