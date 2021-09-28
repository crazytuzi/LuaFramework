CompositionView =BaseClass()

function CompositionView:__init()
	self:Layout()
end

function CompositionView:__delete()
	self:DestroyView()
	self.isInited = false
end

function CompositionView:Layout()
	if self.isInited then return end
	resMgr:AddUIAB("Composition")
	self.isInited = true
end

function CompositionView:GetCompositionUI()
	if TableIsEmpty(self.compositionUI) then
		self.compositionUI = CompositionUI.New()
	end
	return self.compositionUI or {}
end

function CompositionView:DestroyView()
	if self.compositionUI then
		self.compositionUI:Destroy()
		self.compositionUI = nil
	end
	self.isInited = false
end

