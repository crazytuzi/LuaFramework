CompositionUI = BaseClass(LuaUI)
function CompositionUI:__init(...)
	self.URL = "ui://qr7fvjxixy1x3";
	self:__property(...)
	self:Config()
end

function CompositionUI:SetProperty(...)
	
end

function CompositionUI:Config()
	self:InitUI()
end

function CompositionUI:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Composition","CompositionUI");
	self.uiLeft = self.ui:GetChild("uiLeft")
	self.uiRight = self.ui:GetChild("uiRight")
	self.uiLeft = CompositionUILeft.Create(self.uiLeft)
	self.uiRight = CompositionUIRight.Create(self.uiRight)
	
	self.imgTips = self.ui:GetChild("imgTips")
	self.labelTips = self.ui:GetChild("labelTips")

end

function CompositionUI.Create(ui, ...)
	return CompositionUI.New(ui, "#", {...})
end

function CompositionUI:__delete()
	if self.uiLeft then
		self.uiLeft:Destroy()
		self.uiLeft = nil
	end
	if self.uiRight then
		self.uiRight:Destroy()
		self.uiRight = nil
	end
end

function CompositionUI:InitUI()

end

function CompositionUI:Update()
	-- local compositionBid = PkgModel:GetInstance():GetSelectGoodsBid()
	-- if compositionBid and CompositionModel:GetInstance():IsCanComposition(compositionBid) then
	-- 	self.uiLeft:SetSelectById(compositionBid)
	-- end

	--选中第一个页签的第一个物品
	local compositionData = CompositionModel:GetInstance():GetFirstItemDataByType(1)
	if not TableIsEmpty(compositionData) then
		local compositionBid = compositionData.id or 0
		if compositionBid then
			if self.uiLeft and self.uiLeft:GetSelectedFlag() == false then
				self.uiLeft:SetSelectById(compositionBid)
			end
		end
	end
end