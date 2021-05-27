require("scripts/game/map/map_data")
require("scripts/game/map/map_view")

-- 地图
MapCtrl = MapCtrl or BaseClass(BaseController)

function MapCtrl:__init()
	if MapCtrl.Instance then
		ErrorLog("[MapCtrl] attempt to create singleton twice!")
		return
	end
	MapCtrl.Instance = self

	self.map_data = MapData.New()
	self.map_view = MapView.New(ViewDef.Map)

	self:RegisterProtocol(SCDoorConfig, "OnDoorConfig")
	self:RegisterProtocol(SCNpcConfig, "OnNpcConfig")
end

function MapCtrl:__delete()
	if nil ~= self.map_view then
		self.map_view:DeleteMe()
		self.map_view = nil
	end
	
	MapCtrl.Instance = nil
end

function MapCtrl:OnDoorConfig(protocol)
	self.map_data:SetDoorInfo(protocol.door_scene_count, protocol.door_scene_list)
end

function MapCtrl:OnNpcConfig(protocol)
	self.map_data:SetNpcList(protocol.scene_id, protocol.npc_list)
	self.map_view:Flush(0, MapViewCheckKey.Npc, {scene_id = protocol.scene_id})
end

