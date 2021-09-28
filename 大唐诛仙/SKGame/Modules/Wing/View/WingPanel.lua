WingPanel = BaseClass(LuaUI)

function WingPanel:__init(...)
	self.URL = "ui://d3en6n1nwjp82";
	self:__property(...)
	self:Config()
end

function WingPanel:SetProperty(...)
	local tab = {...}
	self.activeIds = tab[1]
end

function WingPanel:Config()
	
end

function WingPanel:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Wing","WingPanel");

	self.bg = self.ui:GetChild("bg")
	self.left = self.ui:GetChild("left")
	self.right = self.ui:GetChild("right")

	self.right = WingPanel_Right.Create(self.right)
	self.left = WingPanel_Left.Create(self.left)
	self.left:SetActiveIds(self.activeIds)
end

function WingPanel.Create(ui, ...)
	return WingPanel.New(ui, "#", {...})
end

function WingPanel:Update()
		
end

function WingPanel:__delete()
	if self.left then
		self.left:Destroy()
		self.left = nil
		self.right:Destroy()
		self.right = nil
	end
end