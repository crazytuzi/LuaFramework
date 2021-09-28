AccordionCellItem = BaseClass(LuaUI)

AccordionCellItem.CellHeight = 42
AccordionCellItem.CellWidth = 178
function AccordionCellItem:__init(...)
	self.URL = "ui://0tyncec1sbfonij";
	self:__property(...)
	self:Config()
end

function AccordionCellItem:SetProperty(...)
	
end

function AccordionCellItem:Config()
end

function AccordionCellItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","AccordionCellItem")

	self.select = self.ui:GetChild("select")
	self.unSelect = self.ui:GetChild("unSelect")
	self.line = self.ui:GetChild("line")
	self.cellName = self.ui:GetChild("cellName")
	
	self.root = nil
	self:AddEvent()
	self:UnSelect()
end

function AccordionCellItem.Create(ui, ...)
	return AccordionCellItem.New(ui, "#", {...})
end

function AccordionCellItem:SetData(bigType, data, root)
	self.bigType = tonumber(bigType)
	self.data = data
	self.root = root
	self.smallType = tonumber(self.data[1])

	self.cellName.text = self.data[2]
end

function AccordionCellItem:AddEvent()
	self.ui.onClick:Add(self.OnClickHandler, self)
end

function AccordionCellItem:RemoveEvent()
	self.ui.onClick:Remove(self.OnClickHandler, self)
end

function AccordionCellItem:OnClickHandler()
	if self.root.selectItem then
		self.root.selectItem:UnSelect()
	end
	self.root.selectItem = self
	self.select.visible = true
	self.unSelect.visible = false
	self.cellName.color = newColorByString( "adc9e9" )
	
	if self.root and self.root.callBack then
		local data = {self.bigType, self.smallType}
		self.root.callBack(data)
	end

	self.root:UnTouchable()
	DelayCall(function() 
		if self.root then
			self.root:Touchable()
		end
	end, self.root.clickSamllInternal)
end

function AccordionCellItem:UnSelect()
	self.select.visible = false
	self.unSelect.visible = true
	self.cellName.color = newColorByString( "444d59" )
end

function AccordionCellItem:Select()
	self:OnClickHandler()
end

function AccordionCellItem:__delete()
	self:RemoveEvent()
	self.root = nil
end