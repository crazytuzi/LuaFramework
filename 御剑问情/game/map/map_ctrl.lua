require("game/map/map_view")
require("game/map/map_data")

MapCtrl = MapCtrl or BaseClass(BaseController)

function MapCtrl:__init()
	if MapCtrl.Instance ~= nil then
		print_error("[MapCtrl] attempt to create singleton twice!")
		return
	end
	MapCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = MapView.New(ViewName.Map)
	self.data = MapData.New()
end

function MapCtrl:RegisterAllProtocols()

end

function MapCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	MapCtrl.Instance = nil
end

function MapCtrl:CloseLocalLineButton()
	if self.view.local_view then
		self.view.local_view:CloseLineButton()
	end
end

function MapCtrl:FlushLocalMap()
	if self.view then
		self.view:FlushLocalMap()
	end
end