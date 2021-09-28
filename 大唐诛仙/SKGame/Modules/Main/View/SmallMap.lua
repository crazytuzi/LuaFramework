SmallMap = BaseClass(LuaUI)
function SmallMap:__init( ... )
	self.URL = "ui://0042gnit9l3beu"
	self:__property(...)
	self:Config()
	self:Start()
end
function SmallMap:SetProperty( ... )
end
function SmallMap:Config()
	self.worldModel = WorldMapModel:GetInstance()
	self.sceneModel=SceneModel:GetInstance()
	self.scale = 0.5
	self.mapScale = MapScalPanel.Create(self.mapScale)
	self.worldModel.playerPos = self.sceneModel:GetMainPlayerPos()
	self.mapScale:SetXY( 83+(self.worldModel.playerPos.x*10*self.scale) , 62-(self.worldModel.playerPos.z*10*self.scale))
end
function SmallMap:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","SmallMap")
	self.mapScale = self.ui:GetChild("mapScale")
	self.mask = self.ui:GetChild("mask")
	self.playerIcon = self.ui:GetChild("playerIcon")
end

function SmallMap:Start()
	RenderMgr.Add(function () self:Update() end, "SmallMapRender")
end

function SmallMap:Pause()
	RenderMgr.Realse("SmallMapRender")
end

function SmallMap:Update()
	self.worldModel.playerPos = self.sceneModel:GetMainPlayerPos()
	self.mapScale:SetXY( 83+(self.worldModel.playerPos.x*10*self.scale) , 62-(self.worldModel.playerPos.z*10*self.scale))

end

function SmallMap.Create( ui, ...)
	return SmallMap.New(ui, "#", {...})
end
function SmallMap:__delete()
	RenderMgr.Realse("SmallMapRender")
	if self.mapScale then
		self.mapScale:Destroy()
		self.mapScale = nil
	end
end