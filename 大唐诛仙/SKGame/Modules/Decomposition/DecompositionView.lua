DecompositionView =BaseClass()

function DecompositionView:__init()
	self:Config()
end

function DecompositionView:__delete()
	if self.decompositionUI then
		self.decompositionUI:Destroy()
		self.decompositionUI = nil
	end
end

function DecompositionView:Config()
	self:InitData()
	self:Layout()
end

function DecompositionView:InitData()
	self.decompositionUI = nil
end

function DecompositionView:Layout()
	if self.isInited then return end
	resMgr:AddUIAB("Decomposition")
	self.isInited = true
end

function DecompositionView:GetDecompositionUI()
	if TableIsEmpty(self.decompositionUI) then
		self.decompositionUI = DecompositionUI.New()
	end
	return self.decompositionUI or {}
end

