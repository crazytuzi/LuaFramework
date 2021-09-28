ButtonDecompositionTick = BaseClass(LuaUI)
function ButtonDecompositionTick:__init(...)
	self.URL = "ui://q13jjk9jfue1r";
	self:__property(...)
	self:Config()
end

function ButtonDecompositionTick:SetProperty(...)
	
end

function ButtonDecompositionTick:Config()
	self:InitData()
	self:InitUI()
end

function ButtonDecompositionTick:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Decomposition","ButtonDecompositionTick");

	self.button = self.ui:GetController("button")
	self.n1 = self.ui:GetChild("n1")
	self.n2 = self.ui:GetChild("n2")
	self.n3 = self.ui:GetChild("n3")
	self.n4 = self.ui:GetChild("n4")
	self.title = self.ui:GetChild("title")
	self.icon = self.ui:GetChild("icon")
	self.gou = self.ui:GetChild("gou")
end

function ButtonDecompositionTick.Create(ui, ...)
	return ButtonDecompositionTick.New(ui, "#", {...})
end

function ButtonDecompositionTick:__delete()
end

function ButtonDecompositionTick:SetIconVisible()
	self.isTick = not self.isTick
	self.gou.visible = self.isTick
end

function ButtonDecompositionTick:InitData()
	self.isTick = false
end

function ButtonDecompositionTick:InitUI()
	self.gou.visible = self.isTick
end

function ButtonDecompositionTick:GetTickState()
	return self.isTick
end