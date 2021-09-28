MiniMap =BaseClass(LuaUI)

function MiniMap:__init( ... )
	self.URL = "ui://0042gniteg11am"
	self:__property(...)
	self:Config()
end

function MiniMap:SetProperty( ... )
	
end

function MiniMap:Config()
	self.smallMap = SmallMap.Create(self.smallMap)
end

function MiniMap:Init()
	local info = SceneModel:GetInstance().info
	local name = info.name or ""
	self.MapName.text = StringFormat("{0}",name)
end

function MiniMap:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","MiniMap")

	self.bg = self.ui:GetChild("bg")
	self.bg2 = self.ui:GetChild("Bg2")
	self.MapName = self.ui:GetChild("MapName")
	self.smallMap = self.ui:GetChild("smallMap")
end

function MiniMap.Create( ui, ...)
	return MiniMap.New(ui, "#", {...})
end

function MiniMap:__delete()
	if self.smallMap then
		self.smallMap:Destroy()
		self.smallMap = nil
	end
	
	self.bg = nil
	self.bg2 = nil
	self.MapName = nil
end