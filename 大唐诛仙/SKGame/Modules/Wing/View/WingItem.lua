WingItem = BaseClass(LuaUI)

WingItem.CurSelectItem = nil
function WingItem:__init(...)
	self.URL = "ui://d3en6n1nigzg18";
	self:__property(...)
	self:Config()
end

function WingItem:SetProperty(...)
	
end

function WingItem:Config()
	
end

function WingItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Wing","WingItem");

	self.img = self.ui:GetChild("img")
	self.select = self.ui:GetChild("select")
	self.lock = self.ui:GetChild("lock")
	self.equipMark = self.ui:GetChild("equipMark")

	self.data = nil

	self:AddEvent()
	self:Reset()
end

function WingItem.Create(ui, ...)
	return WingItem.New(ui, "#", {...})
end

function WingItem:AddEvent()
	self.ui.onClick:Add(self.OnClickHandler, self)
end

function WingItem:RemoveEvent()
	self.ui.onClick:Remove(self.OnClickHandler, self)
end

function WingItem:Reset()
	self:UnSelect()
	self:UnEquip()
	self:UnLock()
end

function WingItem:OnClickHandler()
	if WingItem.CurSelectItem then
		WingItem.CurSelectItem:UnSelect()
	end
	self:Select()
end

function WingItem:Select()
	self.select.visible = true
	WingItem.CurSelectItem = self
	WingModel:GetInstance():DispatchEvent(WingConst.SelectWingItem, self.data)
end

function WingItem:UnSelect()
	self.select.visible = false
end

function WingItem:Lock()
	self.lock.visible = true
	self.img.alpha = 0.5
end

function WingItem:UnLock()
	self.lock.visible = false
	self.img.alpha = 1
end

function WingItem:Equip()
	self.equipMark.visible = true
end

function WingItem:UnEquip()
	self.equipMark.visible = false
end

function WingItem:Update(data)
	self.data = data
	if self.data then
		self.img.url = StringFormat("Icon/Goods/{0}", self.data.icon)

		self:SetVisible(true)
		self:UpdateState()

		if self.data.isNewActive then
			self:OnClickHandler()
		end
	else
		self:SetVisible(false)
	end
end

function WingItem:SetActiveSelect(wingId, activeIds)
	if self.data and wingId == self.data.wingId then
		self:Select()
		local isActive = false
		if activeIds and type(activeIds) == "table" and activeIds[wingId] then
			isActive = true
		end
		if not WingActivePanel.isOpen and not isActive then
			local wingActivePanel = WingActivePanel.New()
			wingActivePanel.activiteIcon.visible = true
			wingActivePanel:SetData(self.data)
			UIMgr.ShowCenterPopup(wingActivePanel)
		end
	end
end

function WingItem:UpdateState()
	if self.data then
		if WingModel:GetInstance():IsActive(self.data.wingId) then
			self:UnLock()
		else
			self:Lock()
		end

		if WingModel:GetInstance():IsPutOn(self.data.wingId) then
			self:Equip()
		else
			self:UnEquip()
		end
	end
end

function WingItem:__delete()
	self:RemoveEvent()

	self.data = nil
end