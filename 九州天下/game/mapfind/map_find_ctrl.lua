require("game/mapfind/map_find_rush_view")
require("game/mapfind/map_find_reward_view")
require("game/mapfind/map_find_view")
require("game/mapfind/map_find_data")


RA_MAP_HUNT_OPERA_TYPE =
{
	RA_MAP_HUNT_OPERA_TYPE_ALL_INFO = 0,				--请求所有信息
	RA_MAP_HUNT_OPERA_TYPE_FLUSH = 1,					--请求刷新
	RA_MAP_HUNT_OPERA_TYPE_AUTO_FLUSH = 2,				--请求自动刷新
	RA_MAP_HUNT_OPERA_TYPE_HUNT = 3, 					--寻宝
	RA_MAP_HUNT_OPERA_TYPE_FETCH_RETURN_REWARD = 4,		--拿取返利奖励

	RA_MAP_HUNT_OPERA_TYPE_MAX = 5,
}

MapFindCtrl = MapFindCtrl or BaseClass(BaseController)

function MapFindCtrl:__init()
	if MapFindCtrl.Instance ~= nil then
		print_error("[MapFindCtrl] attempt to create singleton twice!")
		return
	end
	MapFindCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = MapFindView.New(ViewName.MapFindView)
	self.data = MapFindData.New()
	self.reward_view = MapFindRewardView.New(ViewName.MapFindRewardView)
	self.rush_view = MapfindRushView.New(ViewName.MapfindRushView)

end

function MapFindCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	MapFindCtrl.Instance = nil
end

function MapFindCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAMapHuntAllInfo, "OnSCRAMapHuntAllInfo")
end

function MapFindCtrl:OnSCRAMapHuntAllInfo(protocol)
	self.data:SetMapData(protocol)
	self.view:Flush()
end

function MapFindCtrl:SendInfo(opera_type, param_1, param_2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol.rand_activity_type = 2185 or 0
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end

function MapFindCtrl:EndRush()
	self.view.in_rush = false
end

function MapFindCtrl:BeginRush(  )
	self.view.in_rush = true
end

function MapFindCtrl:GetRush()
	return self.view.in_rush
end