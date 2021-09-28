
WingCostPropItem = BaseClass(LuaUI)

WingCostPropItem.CurSelectItem = nil
function WingCostPropItem:__init(...)
	self.URL = "ui://d3en6n1n5v991j";
	self:__property(...)
	self:Config()
end

function WingCostPropItem:SetProperty(...)
	
end

function WingCostPropItem:Config()
	
end

function WingCostPropItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Wing","WingCostPropItem");

	self.select = self.ui:GetController("select")
	
	self.icon = PkgCell.New(self.ui)
	self.icon:SetXY(1, 1)	
	self.icon:OpenTips(true, nil, true)

	self.itemId = nil

	self:AddEvent()
	self:UnSelect()
end

function WingCostPropItem.Create(ui, ...)
	return WingCostPropItem.New(ui, "#", {...})
end

function WingCostPropItem:AddEvent()
	self.ui.onClick:Add(self.OnClickHandler, self)

	self.handler = GlobalDispatcher:AddEventListener(EventName.BAG_CHANGE, function ()
		self:UpdateCount()
	end)
end

function WingCostPropItem:RemoveEvent()
	self.ui.onClick:Remove(self.OnClickHandler, self)

	GlobalDispatcher:RemoveEventListener(self.handler)
end

function WingCostPropItem:OnClickHandler()
	if WingCostPropItem.CurSelectItem then
		WingCostPropItem.CurSelectItem:UnSelect()
	end
	self:Select()
end

function WingCostPropItem:Select()
	self.select.selectedIndex = 0
	WingModel:GetInstance().isUp = 1
	WingCostPropItem.CurSelectItem = self
	WingModel:GetInstance():DispatchEvent(WingConst.SelectWingCostItem, self.itemId)
end

function WingCostPropItem:UnSelect()
	self.select.selectedIndex = 1
end

function WingCostPropItem:SetData(itemId)
	self.itemId = itemId

	self:Update()
end

function WingCostPropItem:Update()
	local cfg = GoodsVo.GetItemCfg(self.itemId)
	if cfg then
		self.icon:SetDataByCfg(2, cfg.icon, PkgModel:GetInstance():GetTotalByBid(self.itemId), 0)
		if PkgModel:GetInstance():GetTotalByBid(self.itemId) == 0 then
			self.icon:SetNum2("[color=#ff0000]0[/color]")
		end
		if PkgModel:GetInstance():GetTotalByBid(self.itemId) == 1 then
			self.icon:SetNum2("[color=#e6e6e6]1[/color]")
		end
	end
end

function WingCostPropItem:UpdateCount()
	local cfg = GoodsVo.GetItemCfg(self.itemId)
	if cfg then
		self.icon:SetDataByCfg(2, cfg.icon, PkgModel:GetInstance():GetTotalByBid(self.itemId), 0)
	end
	if PkgModel:GetInstance():GetTotalByBid(self.itemId) == 0 then
		self.icon:SetNum2("[color=#ff0000]0[/color]")
	else 
		self.icon:SetNum2("[color=#e6e6e6]"..PkgModel:GetInstance():GetTotalByBid(self.itemId).."[/color]")
	end
end

function WingCostPropItem:__delete()
	self:RemoveEvent()
	self.icon:Destroy()
	self.icon = nil
	self.itemId = nil
end