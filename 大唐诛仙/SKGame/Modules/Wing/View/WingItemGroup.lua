WingItemGroup = BaseClass(LuaUI)

function WingItemGroup:__init(...)
	self.URL = "ui://d3en6n1nigzg19";
	self:__property(...)
	self:Config()
end

function WingItemGroup:SetProperty(...)
	
end

function WingItemGroup:Config()
	
end

function WingItemGroup:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Wing","WingItemGroup");

	self.item1 = self.ui:GetChild("item1")
	self.item2 = self.ui:GetChild("item2")
	self.item3 = self.ui:GetChild("item3")

	self.item1 = WingItem.Create(self.item1)
	self.item2 = WingItem.Create(self.item2)
	self.item3 = WingItem.Create(self.item3)
end

function WingItemGroup.Create(ui, ...)
	return WingItemGroup.New(ui, "#", {...})
end

function WingItemGroup:SetData(data1, data2, data3)
	self.item1:Update(data1)
	self.item2:Update(data2)
	self.item3:Update(data3)
end

function WingItemGroup:Update()
	self.item1:UpdateState()
	self.item2:UpdateState()
	self.item3:UpdateState()
end

function WingItemGroup:SetSelect(wingId, activeIds)
	for i = 1, 3 do
		self["item"..i]:SetActiveSelect(wingId, activeIds)
	end
end

function WingItemGroup:SetDefaultSelect()
	self.item1:Select()
end

function WingItemGroup:__delete()
	self.item1:Destroy()
	self.item2:Destroy()
	self.item3:Destroy()

	self.item1 = nil
	self.item2 = nil
	self.item3 = nil
end