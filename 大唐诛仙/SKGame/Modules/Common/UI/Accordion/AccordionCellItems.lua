AccordionCellItems = BaseClass(LuaUI)

function AccordionCellItems:__init(...)
	self.URL = "ui://0tyncec1sbfonil";
	self:__property(...)
	self:Config()
end

function AccordionCellItems:SetProperty(...)
	
end

function AccordionCellItems:Config()
	
end

function AccordionCellItems:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","AccordionCellItems")
	self.state = self.ui:GetController("state")
	self.list = self.ui:GetChild("list")
	self.orginWidth = 178
	self.orginHeight = 0
	self.subItems = {}
end

function AccordionCellItems.Create(ui, ...)
	return AccordionCellItems.New(ui, "#", {...})
end

function AccordionCellItems:SetSelect(samellType)
	for i = 1, #self.subItems do
		if samellType and self.subItems[i].smallType == samellType then
			self.subItems[i]:Select()
			return true
		end
	end
	if #self.subItems ~= 0 then
		self.subItems[1]:Select()
	end
	return false
end

function AccordionCellItems:SetData(bigType, smallTypeData, root)
	local data = smallTypeData or {}
	local totalHeight = 0
	for i,v in ipairs(self.subItems) do
		v:Destroy()
	end
	self.subItems = {}
	
	for i = 1, #data do
		local item = AccordionCellItem.New()
		item:AddTo(self.list)
		item:SetData(bigType, data[i], root)
		totalHeight = totalHeight + AccordionCellItem.CellHeight
		table.insert(self.subItems, item)
	end
	self.orginHeight = totalHeight
	self.list.height = totalHeight
	self:SetSize(self.orginWidth, self.orginHeight, false)

	self.maxY = 0 
	self.minY = -totalHeight
	self.list.y = -totalHeight
end

function AccordionCellItems:Show(unNeedTween)
	self:SetVisible(true)
	if unNeedTween then
		self.list.y = self.maxY
	else
		local toY = self.maxY
		local posTweener = TweenUtils.TweenFloat(self.list.y, toY, 0.2, function(data)
				if not ToLuaIsNull(self.list) then
					self.list.y = data
				end
			end)
		TweenUtils.SetEase(posTweener, 21)
	end
end

function AccordionCellItems:Hide(unNeedTween)
	self:SetVisible(false)
	if unNeedTween then
		self.list.y = self.minY
	else
		local toY = self.minY
		local posTweener = TweenUtils.TweenFloat(self.list.y, toY, 0.2, function(data)
			if not ToLuaIsNull(self.list) then
				self.list.y = data
			end
		end)
		TweenUtils.SetEase(posTweener, 21)
	end
end

function AccordionCellItems:GetMyHeight()
	return self.orginHeight + self.list.y
end

function AccordionCellItems:__delete()
	for i = 1, #self.subItems do
		self.subItems[i]:Destroy()
	end
	self.subItems = nil
end