WakanCostItemSelectPanel = BaseClass(LuaUI)

function WakanCostItemSelectPanel:__init(...)
	self.URL = "ui://jh3vd6rkrgh01r";
	self:__property(...)
	self:Config()
end

function WakanCostItemSelectPanel:SetProperty(...)

end

function WakanCostItemSelectPanel:Config()
	
end

function WakanCostItemSelectPanel:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Wakan","WakanCostItemSelectPanel");

	self.n1 = self.ui:GetChild("n1")
	self.list = self.ui:GetChild("list")

	self.ui.onClick:Add(self.OnBgClick, self)

	self.selectItem1 = nil
	self.selectItem2 = nil
	self.selectItem3 = nil

	self.costItemIds = WakanConst.WakanCostItemIds
	self.callBack = nil
	self.items = {}
end

function WakanCostItemSelectPanel.Create(ui, ...)
	return WakanCostItemSelectPanel.New(ui, "#", {...})
end

function WakanCostItemSelectPanel:OnBgClick()
	if self.callBack then
		self.callBack(0)
		self:SetVisible(false)
		self.callBack = nil
	end
end

function WakanCostItemSelectPanel:OnClickHandler(contex)
	if self.callBack then
		self.callBack(tonumber(contex.sender.name))
		self:SetVisible(false)
		self.callBack = nil
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end
end

function WakanCostItemSelectPanel:ShowSelect(callBack, selectItem1, selectItem2, selectItem3)
	self.selectItem1 = selectItem1
	self.selectItem2 = selectItem2
	self.selectItem3 = selectItem3

	self:Refresh()
	self:SetVisible(true)
	self.callBack = callBack
end

function WakanCostItemSelectPanel:Refresh()
	self.list:RemoveChildren()
	local showInfo = {}
	for i = 1, #self.costItemIds do
		local count = PkgModel:GetInstance():GetTotalByBid(self.costItemIds[i])
		for j = 1, 3 do
			if self["selectItem"..j] and self["selectItem"..j].itemId == self.costItemIds[i] then
				count = count - 1
			end
		end
		if count > 0 then
			local vo = {}
			vo.id = self.costItemIds[i]
			vo.count = count
			table.insert(showInfo, vo)
		end
	end
	SortTableByKey(showInfo, "id", true)

	for i = 1, #showInfo do
		local item = self:GetItemFromPool()
		item.ui.name = showInfo[i].id
		item:SetViewInPanel(showInfo[i].id, showInfo[i].count)
		self.list:AddChild(item.ui)
	end
end

function WakanCostItemSelectPanel:GetItemFromPool()
	for i = 1, #self.items do
		if self.items[i].ui.parent == nil then
			return self.items[i]
		end
	end
	local item = WakanCostItem.New()
	item.ui.onClick:Add(self.OnClickHandler, self)
	table.insert(self.items, item)
	return item
end

function WakanCostItemSelectPanel:DestroyPool()
	if self.items then
		for i = 1, #self.items do
			self.items[i]:Destroy()
		end
		self.items = nil
	end
end

function WakanCostItemSelectPanel:ClearContent()
	self.list:RemoveChildren()
end

function WakanCostItemSelectPanel:__delete()
	WakanCostItem.CurSelectItem = nil
	self.callBack = nil
	self:DestroyPool()
end