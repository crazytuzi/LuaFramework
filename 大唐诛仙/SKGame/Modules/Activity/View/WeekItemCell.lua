WeekItemCell = BaseClass(LuaUI)

function WeekItemCell:__init(...)
	self.URL = "ui://oa3ahys9mfyie";
	self:__property(...)
	self:Config()
end

function WeekItemCell:SetProperty(...)
	
end

function WeekItemCell:Config()
	self.infoPanel = nil
end

function WeekItemCell:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Activity","WeekItemCell");

	self.select = self.ui:GetChild("select")
	self.name = self.ui:GetChild("name")

	self.data = nil

	self:AddEvent()
end

function WeekItemCell:AddEvent()
	self.ui.onClick:Add(function()
		if self.data == nil then return end
		if not self.infoPanel or not self.infoPanel.ui then
			self.infoPanel = WeekCellInfoPanel.New()
		end
		self.infoPanel:SetData(self.data)
		UIMgr.ShowPopup(self.infoPanel)
	end, self)
end

function WeekItemCell:RemoveEvent()

end

function WeekItemCell:SetView(bgVisible, data)
	self.select.visible = bgVisible	
	self.data = data
	if self.data then
		self.name.text = self.data.name		
	else
		self.name.text = ""		
	end	
end

function WeekItemCell.Create(ui, ...)
	return WeekItemCell.New(ui, "#", {...})
end

function WeekItemCell:__delete()
	self.data = nil
	if self.infoPanel then
		self.infoPanel:Destroy()
		self.infoPanel = nil
	end
	self:RemoveEvent()
end