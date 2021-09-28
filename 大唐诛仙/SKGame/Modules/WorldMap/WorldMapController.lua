WorldMapController = BaseClass(LuaController)

require "SKGame/Modules/WorldMap/WorldMapModel"
require "SKGame/Modules/WorldMap/WorldMapView"
require "SKGame/Modules/WorldMap/WorldMapConst"
require "SKGame/Modules/WorldMap/view/WorldMapPanel"
require "SKGame/Modules/WorldMap/view/SecondMapPanel"
require "SKGame/Modules/WorldMap/view/PlayerIcon"
require "SKGame/Modules/WorldMap/view/MapBg"
require "SKGame/Modules/WorldMap/view/MapBtn"

function WorldMapController:__init()
	self:Config()
	self:InitEvent()
end

function WorldMapController:InitEvent()
	
end

function WorldMapController:Config()
	self.model = WorldMapModel:GetInstance()
	self.view = WorldMapView.New()
end

function WorldMapController:Open(ind)
	if self.view == nil then 
		self.view = WorldMapView.New()
	end
	if self.view == nil then return end 
	self.view:Open(ind)
end

function WorldMapController:RemoveEvent()
	
end

function WorldMapController:GetInstance()
	if WorldMapController.inst == nil then
		WorldMapController.inst = WorldMapController.New()
	end
	return WorldMapController.inst
end

function WorldMapController:__delete()
	self:RemoveEvent()
	
	if self.model then
		self.model:Destroy()
	end
	self.model = nil

	if self.view then
		self.view:Destroy()
	end
	self.view = nil

	WorldMapController.inst = nil
end