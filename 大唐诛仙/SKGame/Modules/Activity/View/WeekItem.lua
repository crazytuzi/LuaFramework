WeekItem = BaseClass(LuaUI)

function WeekItem:__init(...)
	self.URL = "ui://oa3ahys9mfyig";
	self:__property(...)
	self:Config()
end

function WeekItem:SetProperty(...)
	
end

function WeekItem:Config()
	
end

function WeekItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Activity","WeekItem");

	self.i0 = self.ui:GetChild("i0")
	self.i1 = self.ui:GetChild("i1")
	self.i7 = self.ui:GetChild("i7")
	self.i6 = self.ui:GetChild("i6")
	self.i5 = self.ui:GetChild("i5")
	self.i4 = self.ui:GetChild("i4")
	self.i3 = self.ui:GetChild("i3")
	self.i2 = self.ui:GetChild("i2")

	self.i1 = WeekItemCell.Create(self.i1)
	self.i7 = WeekItemCell.Create(self.i7)
	self.i6 = WeekItemCell.Create(self.i6)
	self.i5 = WeekItemCell.Create(self.i5)
	self.i4 = WeekItemCell.Create(self.i4)
	self.i3 = WeekItemCell.Create(self.i3)
	self.i2 = WeekItemCell.Create(self.i2)
end

function WeekItem.Create(ui, ...)
	return WeekItem.New(ui, "#", {...})
end

function WeekItem:Update(data, index)
	local showBg = index % 2 == 0

	self.i0:GetChild("select").visible = showBg
	self.i0:GetChild("name").text = TimeTool.GetHHSS(tonumber(data[0][1]), tonumber(data[0][2]))

	for i = 1, 7 do
		self["i"..i]:SetView(showBg, data[i])
	end
end

function WeekItem:__delete()
	destroyUI( self.i1.ui )
	destroyUI( self.i2.ui )
	destroyUI( self.i3.ui )
	destroyUI( self.i4.ui )
	destroyUI( self.i5.ui )
	destroyUI( self.i6.ui )
	destroyUI( self.i7.ui )
end