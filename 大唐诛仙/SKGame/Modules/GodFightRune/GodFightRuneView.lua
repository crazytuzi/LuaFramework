GodFightRuneView = BaseClass()

function GodFightRuneView:__init()
	self:Config()
	self:InitEvent()
	self:LayoutUI()
end

function GodFightRuneView:__delete()
	self.isInited = false
end

function GodFightRuneView:Config()
	self.model = GodFightRuneModel:GetInstance()
	self.godFightRunePanel = nil
end

function GodFightRuneView:InitEvent()

end

function GodFightRuneView:LayoutUI()
	if self.isInited then return end
	resMgr:AddUIAB("GodFightRune")
	self.isInited = true
end

function GodFightRuneView:OpenGodFightRunePanel()
	if (not self.godFightRunePanel) or (not self.godFightRunePanel.isInited) then
		self.godFightRunePanel = GodFightRunePanel.New()
	end
	if self.godFightRunePanel == nil then return end
	self.godFightRunePanel:Open()
end

