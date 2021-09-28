StyleItem = BaseClass(LuaUI)

StyleItem.CurSelectItem = nil
function StyleItem:__init(...)
	self.URL = "ui://jqof8qcoeieka";
	self:__property(...)
	self:Config()
end

function StyleItem:SetProperty(...)
	
end

function StyleItem:Config()
	
end

function StyleItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Style","StyleItem");

	self.n1 = self.ui:GetChild("n1")
	self.bg = self.ui:GetChild("bg")
	self.selectBg = self.ui:GetChild("selectBg")
	self.name = self.ui:GetChild("name")
	self.n5 = self.ui:GetChild("n5")
	self.power = self.ui:GetChild("power")
	self.equipMark = self.ui:GetChild("equipMark")
	self.n8 = self.ui:GetChild("n8")
	self.img = self.ui:GetChild("img")
	self.lock = self.ui:GetChild("lock")
	self.selectHight = self.ui:GetChild("selectHight")

	self.data = nil

	self:AddEvent()
	self:Reset()
end

function StyleItem.Create(ui, ...)
	return StyleItem.New(ui, "#", {...})
end

function StyleItem:AddEvent()
	self.ui.onClick:Add(self.OnClickHandler, self)
end

function StyleItem:RemoveEvent()
	self.ui.onClick:Remove(self.OnClickHandler, self)
end

function StyleItem:Reset()
	self:UnSelect()
	self:UnEquip()
	self:UnLock()
end

function StyleItem:OnClickHandler()
	self:Select()
end

function StyleItem:Select()
	if StyleItem.CurSelectItem then
		StyleItem.CurSelectItem:UnSelect()
	end
	self.selectBg.visible = true
	self.selectHight.visible = true
	StyleItem.CurSelectItem = self
	StyleModel:GetInstance():DispatchEvent(StyleConst.SelectStyleItem, self.data)
end

function StyleItem:UnSelect()
	self.selectBg.visible = false
	self.selectHight.visible = false
end

function StyleItem:Lock()
	self.lock.visible = true
	self.img.alpha = 0.5
end

function StyleItem:UnLock()
	self.lock.visible = false
	self.img.alpha = 1
end

function StyleItem:Equip()
	self.equipMark.visible = true
end

function StyleItem:UnEquip()
	self.equipMark.visible = false
end

function StyleItem:Update(data)
	self:Reset()

	self.data = data
	self.name.text = self.data.name
	self.img.url = StringFormat("Icon/Goods/{0}", self.data.icon)
	self.power.text = CalculateScore(self.data.baseProperty)
	self:UpdateState()
end

function StyleItem:UpdateState()
	if StyleModel:GetInstance():IsActive(self.data.fashionId) then
		self:UnLock()
	else
		self:Lock()
	end

	if StyleModel:GetInstance():IsPutOn(self.data.fashionId) then
		self:Equip()
	else
		self:UnEquip()
	end
end

function StyleItem:__delete()
	self:RemoveEvent()

	self.data = nil
end