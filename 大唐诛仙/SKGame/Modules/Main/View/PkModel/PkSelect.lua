PkSelect =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function PkSelect:__init( ... )
	self.URL = "ui://0042gnitnv56dc";
	self:__property(...)
	self:Config()
end

-- Set self property
function PkSelect:SetProperty( ... )
	
end

-- Logic Starting
function PkSelect:Config()
	
end

-- Register UI classes to lua
function PkSelect:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","PkSelect")

	self.c1 = self.ui:GetController("c1")
	self.content = self.ui:GetChild("content")
	self.mask = self.ui:GetChild("mask")

	self.content = PkContent.Create(self.content)

	self._isShowing = false
end

function PkSelect:ToggleShow()
	if _isShowing then
		self:SetTouchable(false)
		self.c1.selectedIndex = 1
		_isShowing = false
	else
		self:SetTouchable(true)
		self.content.visible = true
		self.c1.selectedIndex = 0
		_isShowing = true
	end
end

function PkSelect:Hide()
	self:SetTouchable(false)
	self.content.visible = false
	self.c1.selectedIndex = 1
	_isShowing = false
end

-- Combining existing UI generates a class
function PkSelect.Create( ui, ...)
	return PkSelect.New(ui, "#", {...})
end

-- Dispose use PkSelect obj:Destroy()
function PkSelect:__delete()
	self.content:Destroy()

	self.c1 = nil
	self.content = nil
	self.mask = nil
end