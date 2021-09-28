WingPanel_Left = BaseClass(LuaUI)

function WingPanel_Left:__init(...)
	self.URL = "ui://d3en6n1nigzg16";
	self:__property(...)
	self:Config()
end

function WingPanel_Left:SetProperty(...)
	
end

function WingPanel_Left:Config()
	
end

function WingPanel_Left:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Wing","WingPanel_Left");

	self.list = self.ui:GetChild("list")
	self.countInfo = self.ui:GetChild("countInfo")

	self.items = {}

	self:AddEvent()
end

function WingPanel_Left:SetActiveIds(activeIds)
	self.activeIds = activeIds
end

function WingPanel_Left.Create(ui, ...)
	return WingPanel_Left.New(ui, "#", {...})
end

function WingPanel_Left:AddEvent()
	self.readyHandler = WingModel:GetInstance():AddEventListener(WingConst.DataReadyOk, function () self:OnReadyHandler() end)
	self.updateHandler = WingModel:GetInstance():AddEventListener(WingConst.DataUpdateOk, function () self:OnUpdateHandler() end)
end

function WingPanel_Left:RemoveEvent()
	WingModel:GetInstance():RemoveEventListener(self.readyHandler)
	WingModel:GetInstance():RemoveEventListener(self.updateHandler)
end

function WingPanel_Left:OnUpdateHandler()
	for i = 1, #self.items do
		self.items[i]:Update()
	end
end

function WingPanel_Left:OnReadyHandler()
	self.list:RemoveChildrenToPool()
	local data = WingModel:GetInstance():GetWingData()
	local colCount = 3
	local rowCount = 0
	local integer, decimals = math.modf(#data / colCount)
	if #data % colCount == 0 then
		rowCount = integer
	else
		rowCount = integer + 1
	end

	local index = 1
	for i = 1, rowCount do
		local item = self.list:AddItemFromPool()
		item = WingItemGroup.Create(item)
		item:SetData(data[index], data[index + 1], data[index + 2])
		table.insert(self.items, item)
		index = index + 3
	end

	local model = WingModel:GetInstance()
	self.countInfo.text = model:GetActiveCount().."/"..model:GetTotalCount()
	self:SetSelect()
end

function WingPanel_Left:SetSelect()
	if WingModel.NewActive then
		for i = 1, #self.items do
			self.items[i]:SetSelect(WingModel.NewActive.wingId, self.activeIds)
		end
		--WingModel.NewActive = nil
	else
		if #self.items > 0 then
			self.items[1]:SetDefaultSelect()
		end
	end
end

function WingPanel_Left:__delete()
	self:RemoveEvent()
	if self.items then
		for i = 1, #self.items do
			self.items[i]:Destroy()
		end
	end
	self.items = nil
	WingModel.NewActive = nil        ---------------
	WingItem.CurSelectItem = nil

end