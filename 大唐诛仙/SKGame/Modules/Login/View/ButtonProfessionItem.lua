ButtonProfessionItem =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function ButtonProfessionItem:__init( ... )
	self.URL = "ui://5gey1uxru2sk10";
	self:__property(...)
	self:Config()
end

-- Set self property
function ButtonProfessionItem:SetProperty(itemData)
	self.itemData = itemData or {}
end

-- Logic Starting
function ButtonProfessionItem:Config()
	
end

-- Register UI classes to lua
function ButtonProfessionItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("RoleCreateSelect","ButtonProfessionItem")
	self.button = self.ui:GetController("button")
	self.image_not_select = self.ui:GetChild("image_not_select")
	self.image_select = self.ui:GetChild("image_select")
	self.icon = self.ui:GetChild("icon")
	self.image_lock = self.ui:GetChild("image_lock")
	self.image_add = self.ui:GetChild("image_add")
	self.image_level_border = self.ui:GetChild("image_level_border")
	self.title = self.ui:GetChild("title")
end

-- Combining existing UI generates a class
function ButtonProfessionItem.Create( ui, ...)
	return ButtonProfessionItem.New(ui, "#", {...})
end

function ButtonProfessionItem:SetUI(panelType)
	if panelType ~= nil and self.itemData ~= nil and table.nums(self.itemData) > 0 then
		if panelType == LoginConst.ROLE_PANEL_TYPE.CREATE_ROLE then
			self.image_add.visible = false
			self.image_lock.visible = false
			self.icon.url = LoginConst.ROLE_PROFESSION_NOT_SELECTED_URL[self.itemData.career]
			self.icon.visible = true
			self.image_level_border.visible = false
			self.title.visible = false
		elseif panelType == LoginConst.ROLE_PANEL_TYPE.SELECT_ROLE then
			local isHas, hasRoleInfo = LoginModel:GetInstance():IsHasRole(self.itemData.career)
			if isHas == true then
				self.image_add.visible = false
				self.image_lock.visible = false
				self.icon.url = LoginConst.ROLE_PROFESSION_NOT_SELECTED_URL[self.itemData.career]
				self.icon.visible = true
				self.title.text =  LoginModel:GetInstance():GetRoleLev(self.itemData.career)
				self.title.visible = true
			else
				self.image_add.visible = true
				self.icon.visible = false
				self.title.visible = false
				self.image_lock.visible = false
				self.image_level_border.visible = false
			end
		else
			--print("======== panelType is unknown")
		end
	end
end

function ButtonProfessionItem:SetLockUI()
	self.image_add.visible = false
	self.icon.visible = false
	self.image_lock.visible = true
	self.image_level_border.visible = false
	self.title.visible = false
	self.ui.enabled = false
end

-- Dispose use ButtonProfessionItem obj:Destroy()
function ButtonProfessionItem:__delete()
	self.button = nil
	self.image_not_select = nil
	self.image_select = nil
	self.icon = nil
	self.image_lock = nil
	self.image_add = nil
	self.image_level_border = nil
	self.title = nil
end