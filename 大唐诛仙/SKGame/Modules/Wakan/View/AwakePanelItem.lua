AwakePanelItem =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function AwakePanelItem:__init( ... )
	self.URL = "ui://jh3vd6rkuchh6";
	self:__property(...)
	self:Config()
end

-- Set self property
function AwakePanelItem:SetProperty( ... )
	
end

-- Logic Starting
function AwakePanelItem:Config()
	
end

-- Register UI classes to lua
function AwakePanelItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Wakan","AwakePanelItem");

	self.state = self.ui:GetController("state")
	self.n1 = self.ui:GetChild("n1")
	self.n2 = self.ui:GetChild("n2")
	self.limitLevel = self.ui:GetChild("limitLevel")
	self.desc = self.ui:GetChild("desc")
	self.activeLevel = self.ui:GetChild("activeLevel")
	self.noActiveLevel = self.ui:GetChild("noActiveLevel")

	self:UnActive()

	self.data = nil
end

function AwakePanelItem:Active()
	self.state.selectedIndex = 0
end

function AwakePanelItem:UnActive()
	self.state.selectedIndex = 1
end

function AwakePanelItem:FillData(data)
	self.activeLevel.text = data.segmentDes
	self.noActiveLevel.text = data.segmentDes

	self.limitLevel.text = StringFormat("注灵{0}级", data.needLevel)
	self.desc.text = data.attDescribe

	self.data = data
end

function AwakePanelItem:Update()
	local curAwakeLevel = WakanModel:GetInstance().awakeLevel
	if self.data.id <= curAwakeLevel then
		self:Active()
	end
end

-- Combining existing UI generates a class
function AwakePanelItem.Create( ui, ...)
	return AwakePanelItem.New(ui, "#", {...})
end

-- Dispose use AwakePanelItem obj:Destroy()
function AwakePanelItem:__delete()
	
	self.state = nil
	self.n1 = nil
	self.n2 = nil
	self.activeLevel = nil
	self.limitLevel = nil
	self.desc = nil
	self.noActiveLevel = nil
end