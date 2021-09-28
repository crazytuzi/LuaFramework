ButtonRole =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function ButtonRole:__init( ... )
	self.URL = "ui://5gey1uxrx7u03h";
	self:__property(...)
	self:Config()
end

-- Set self property
function ButtonRole:SetProperty( ... )
	
end

-- Logic Starting
function ButtonRole:Config()
	self:InitData()
	self:InitConst()
end

-- Register UI classes to lua
function ButtonRole:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("RoleCreateSelect","ButtonRole")
	self.button = self.ui:GetController("button")
	self.img_bg_select = self.ui:GetChild("img_bg_select")
	self.img_bg_not_select = self.ui:GetChild("img_bg_not_select")
	self.loader_career_name = self.ui:GetChild("loader_career_name")
	self.loader_career_state = self.ui:GetChild("loader_career_state")
	self.label_role_name = self.ui:GetChild("label_role_name")
	self.img_bg_role_level = self.ui:GetChild("img_bg_role_level")
	self.label_role_level = self.ui:GetChild("label_role_level")
end

-- Combining existing UI generates a class
function ButtonRole.Create( ui, ...)
	return ButtonRole.New(ui, "#", {...})
end

function ButtonRole:InitData()
	self.roleData = {}
	self.isSelected = false
	self.panelType = LoginConst.ROLE_PANEL_TYPE.NONE
	self.isHas = false
	self.keyIndex = 7 
	self.careerNameNotSelectRGB = "#888F9C"
	self.careerNameSelectRGB = "#FAE8B1"
	self.lockCareerRGB = "#717B90"
end

function ButtonRole:InitConst()
	self.roleCareerNameURL = {}
	self.roleCareerNameURL[4] = UIPackage.GetItemURL("RoleCreateSelect" , "c10") --战士未选中
	self.roleCareerNameURL[1] = UIPackage.GetItemURL("RoleCreateSelect" , "c11") --战士选中
	self.roleCareerNameURL[5] = UIPackage.GetItemURL("RoleCreateSelect" , "c20") --法师未选中
	self.roleCareerNameURL[2] = UIPackage.GetItemURL("RoleCreateSelect" , "c21") --法师选中
	self.roleCareerNameURL[3] = UIPackage.GetItemURL("RoleCreateSelect" , "c31") --暗巫选中
	self.roleCareerNameURL[6] = UIPackage.GetItemURL("RoleCreateSelect" , "c30") --暗巫未选中

	self.roleCareerIconURL = {}
	self.roleCareerIconURL[1] = UIPackage.GetItemURL("RoleCreateSelect", "cl11") --战士选中
	self.roleCareerIconURL[2] = UIPackage.GetItemURL("RoleCreateSelect", "cl21") -- 法师选中
	self.roleCareerIconURL[3] = UIPackage.GetItemURL("RoleCreateSelect", "cl31") --暗巫选中
	self.roleCareerIconURL[4] = UIPackage.GetItemURL("RoleCreateSelect", "cl10") --战士未选中
	self.roleCareerIconURL[5] = UIPackage.GetItemURL("RoleCreateSelect", "cl20") --法师未选中
	self.roleCareerIconURL[6] = UIPackage.GetItemURL("RoleCreateSelect", "cl30") --暗巫未选中

	self.roleCareerIconURL[7] = UIPackage.GetItemURL("RoleCreateSelect", "7") --锁

	self.iconAddURL = UIPackage.GetItemURL("RoleCreateSelect", "加号(2)")
end

function ButtonRole:SetData(roleIndex, roleData, panelType, isHas)
	self.roleIndex = roleIndex or -1
	self.roleData = roleData or {}
	self.panelType = panelType or LoginConst.ROLE_PANEL_TYPE.NONE
	self.isHas = isHas or false
end

function ButtonRole:SetUI()
	if self.label_role_name ~= nil then
		if self.panelType == LoginConst.ROLE_PANEL_TYPE.CREATE_ROLE then
			self.label_role_name.text = ""
			self.label_role_level.text = ""
			self.label_role_name.visible = false
			self.img_bg_role_level.visible = false
			self.label_role_level.visible = false

			if self.isHas == false then
				self.label_role_name.text = string.format("[color=%s]%s[/color]", self.lockCareerRGB, "未开放")
				self.label_role_name.visible = true
				self.loader_career_state.url = self.roleCareerIconURL[#(self.roleCareerIconURL)]
				self.loader_career_name.url = ""
			else
				self.label_role_name.visible = false
				self.loader_career_name.url = self.roleCareerNameURL[self.roleData.career + 3] or ""
				self.loader_career_state.url = self.roleCareerIconURL[self.roleData.career + 3] or ""
			
			end

		elseif self.panelType == LoginConst.ROLE_PANEL_TYPE.SELECT_ROLE then
			if self.isHas == true then
				self.label_role_name.text = string.format("[color=%s]%s[/color]", self.careerNameNotSelectRGB ,LoginModel:GetInstance():GetRoleName(self.roleIndex or -1))
				self.loader_career_state.url = self.roleCareerIconURL[self.roleData.career + 3] or ""
				self.loader_career_name.url = ""
				self.img_bg_role_level.visible = true
				self.label_role_level.text = LoginModel:GetInstance():GetRoleLev(self.roleIndex or -1)
			else
				self.label_role_name.text = ""
				self.loader_career_name.url = ""
				self.loader_career_state.url = self.iconAddURL
				self.label_role_level.text = ""
				self.img_bg_role_level.visible = false
			end
		else

		end
	end
end

function ButtonRole:SetSelectedStateUI()
	if self.isHas == true then
		if self.panelType == LoginConst.ROLE_PANEL_TYPE.CREATE_ROLE then
			self.loader_career_name.url = self.roleCareerNameURL[self.roleData.career] or ""
			self.loader_career_state.url = self.roleCareerIconURL[self.roleData.career] or ""
		elseif self.panelType == LoginConst.ROLE_PANEL_TYPE.SELECT_ROLE then
			self.loader_career_state.url = self.roleCareerIconURL[self.roleData.career] or ""
			self.label_role_name.text = string.format("[color=%s]%s[/color]",self.careerNameSelectRGB ,LoginModel:GetInstance():GetRoleName(self.roleIndex or -1))
		else

		end
	end
end

function ButtonRole:SetUnSelectedStateUI()
	if self.isHas == true then
		if self.panelType == LoginConst.ROLE_PANEL_TYPE.CREATE_ROLE then
				self.loader_career_name.url = self.roleCareerNameURL[self.roleData.career + 3] or ""
				self.loader_career_state.url = self.roleCareerIconURL[self.roleData.career + 3] or ""
			elseif self.panelType == LoginConst.ROLE_PANEL_TYPE.SELECT_ROLE then
				self.loader_career_state.url = self.roleCareerIconURL[self.roleData.career + 3] or ""
				self.label_role_name.text = string.format("[color=%s]%s[/color]", self.careerNameNotSelectRGB ,LoginModel:GetInstance():GetRoleName(self.roleIndex or -1))
			else

		end
	end
end

function ButtonRole:SetButtonController(isSelected)
	if isSelected == true then
		self.button.selectedIndex = 1
	else
		self.button.selectedIndex = 0
	end
end

-- Dispose use ButtonRole obj:Destroy()
function ButtonRole:__delete()
	
	self.button = nil
	self.img_bg_select = nil
	self.img_bg_not_select = nil
	self.loader_career_name = nil
	self.loader_career_state = nil
	self.label_role_name = nil
	self.img_bg_role_level = nil
	self.label_role_level = nil
end