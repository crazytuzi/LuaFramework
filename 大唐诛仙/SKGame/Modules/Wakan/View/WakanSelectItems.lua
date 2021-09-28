WakanSelectItems = BaseClass(LuaUI)

function WakanSelectItems:__init(...)
	self.URL = "ui://jh3vd6rknkol1k";
	self:__property(...)
	self:Config()
end

function WakanSelectItems:SetProperty(...)
	
end

function WakanSelectItems:Config()
	
end

function WakanSelectItems:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Wakan","WakanSelectItems");

	self.item1 = self.ui:GetChild("item1")
	self.item2 = self.ui:GetChild("item2")
	self.item3 = self.ui:GetChild("item3")
	self.item4 = self.ui:GetChild("item4")
	self.item5 = self.ui:GetChild("item5")
	self.item6 = self.ui:GetChild("item6")
	self.item7 = self.ui:GetChild("item7")
	self.item8 = self.ui:GetChild("item8")

	self.item1 = WakanSelectItem.Create(self.item1)
	self.item2 = WakanSelectItem.Create(self.item2)
	self.item3 = WakanSelectItem.Create(self.item3)
	self.item4 = WakanSelectItem.Create(self.item4)
	self.item5 = WakanSelectItem.Create(self.item5)
	self.item6 = WakanSelectItem.Create(self.item6)
	self.item7 = WakanSelectItem.Create(self.item7)
	self.item8 = WakanSelectItem.Create(self.item8)
end

function WakanSelectItems.Create(ui, ...)
	return WakanSelectItems.New(ui, "#", {...})
end

function WakanSelectItems:InitItems()
	local listData = WakanModel:GetInstance().wakanPartsData
	for i = 1, #listData do
		self["item"..i]:Update(listData[i][1])
	end
	self:DefaultSelect()
end

function WakanSelectItems:DefaultSelect()
	for i = 1, 8 do
		self["item"..i]:Reset()
	end

	self.item1:Select()
end

function WakanSelectItems:__delete()
	self.item1:Destroy()
	self.item2:Destroy()
	self.item3:Destroy()
	self.item4:Destroy()
	self.item5:Destroy()
	self.item6:Destroy()
	self.item7:Destroy()
	self.item8:Destroy()

	self.item1 = nil
	self.item2 = nil
	self.item3 = nil
	self.item4 = nil
	self.item5 = nil
	self.item6 = nil
	self.item7 = nil
	self.item8 = nil

	WakanSelectItem.CurSelectItem = nil
end