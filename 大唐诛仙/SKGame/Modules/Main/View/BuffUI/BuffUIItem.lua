BuffUIItem =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function BuffUIItem:__init( ... )
	self.URL = "ui://0042gnitfx79el";
	self:__property(...)
	self:Config()
end

-- Set self property
function BuffUIItem:SetProperty( ... )
	
end

-- Logic Starting
function BuffUIItem:Config()
	
end

-- Register UI classes to lua
function BuffUIItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main", "BuffUIItem");

	self.icon = self.ui:GetChildAt(0)
	self.title = self.ui:GetChildAt(1)

	self.title.text = ""
end

function BuffUIItem:InitView( vo , cfgData)
	self.vo = vo
	self.cfgData = cfgData
	self.lifeTime = (self.vo.endTime - TimeTool.GetCurTime()) * 0.001
	self.icon.url = "Icon/Buff/"..self.cfgData.bufficonID

	if self.vo.endTime == -1 then
		self.title.visible = false
	else
		self.title.visible = true
	end
end

function BuffUIItem:UpdateVo(vo , cfgData)
	self.vo = vo
	self.cfgData = cfgData
	self.lifeTime = (self.vo.endTime - TimeTool.GetCurTime()) * 0.001
end

function BuffUIItem:Update()
	if self.cfgData then
		self.lifeTime = self.lifeTime - Time.deltaTime
		self.lifeTime = self.lifeTime <= 0 and 0 or self.lifeTime
		if self.lifeTime < 60 then
			self.title.text = Mathf.Ceil(self.lifeTime)
		else
			self.title.text = ""
		end
	end
end

-- Combining existing UI generates a class
function BuffUIItem.Create( ui, ...)
	return BuffUIItem.New(ui, "#", {...})
end

-- Dispose use BuffUIItem obj:Destroy()
function BuffUIItem:__delete()
	self.vo = nil
	self.icon = nil
	self.title = nil
	self.cfgData = nil
end
