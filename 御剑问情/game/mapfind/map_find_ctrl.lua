require("game/mapfind/map_find_rush_view")
require("game/mapfind/map_find_reward_view")
require("game/mapfind/map_find_view")
require("game/mapfind/map_find_data")


RA_MAP_HUNT_OPERA_TYPE =
{
    RA_MAP_HUNT_OPERA_TYPE_ALL_INFO = 0,        --请求所有信息
    RA_MAP_HUNT_OPERA_TYPE_FLUSH = 1,               --请求刷新
    RA_MAP_HUNT_OPERA_TYPE_AUTO_FLUSH = 2,          --请求自动刷新
    RA_MAP_HUNT_OPERA_TYPE_HUNT = 3,                --寻宝
    RA_MAP_HUNT_OPERA_TYPE_FETCH_RETURN_REWARD = 4, --拿取返利奖励

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

    self.can_send = true 

    self.view = MapFindView.New(ViewName.MapFindView)
    self.data = MapFindData.New()
    self.reward_view = MapFindRewardView.New(ViewName.MapFindRewardView)
    self.rush_view = MapfindRushView.New(ViewName.MapfindRushView)

    self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.SendStart, self))
end

function MapFindCtrl:__delete()
    self.can_send = nil 

    if self.view ~= nil then
        self.view:DeleteMe()
        self.view = nil
    end

    if self.data ~= nil then
        self.data:DeleteMe()
        self.data = nil
    end

    if self.rush_view ~= nil then
        self.rush_view:DeleteMe()
        self.rush_view = nil
    end

    if self.reward_view ~= nil then
        self.reward_view:DeleteMe()
        self.reward_view = nil
    end

    if nil ~= self.delay_end_flush then
        GlobalTimerQuest:CancelQuest(self.delay_end_flush)
        self.delay_end_flush = nil
    end

    MapFindCtrl.Instance = nil
end

function MapFindCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCRAMapHuntAllInfo, "OnSCRAMapHuntAllInfo")
end

function MapFindCtrl:OnSCRAMapHuntAllInfo(protocol)
    self.can_send = true
    self.data:SetMapData(protocol)
    self.view:Flush()
    RemindManager.Instance:Fire(RemindName.MapFind)

    if nil ~= self.delay_end_flush then
        GlobalTimerQuest:CancelQuest(self.delay_end_flush)
        self.delay_end_flush = nil
    end
end

function MapFindCtrl:SendInfo(opera_type, param_1, param_2)
    if not self.can_send then
        return 
    end

    local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
    protocol.rand_activity_type = 2185 or 0
    protocol.opera_type = opera_type or 0
    protocol.param_1 = param_1 or 0
    protocol.param_2 = param_2 or 0
    protocol:EncodeAndSend()


    if nil ~= self.delay_end_flush then
        GlobalTimerQuest:CancelQuest(self.delay_end_flush)
        self.delay_end_flush = nil
    end

    if opera_type == RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_FLUSH then
        self.delay_end_flush = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.ResetState, self), 2)
    end

    self.can_send = false
end

function MapFindCtrl:EndRush()
    self.view.in_rush = false
    self.view.in_rush_value:SetValue(self.view.in_rush)
end

function MapFindCtrl:BeginRush()
    self.view.in_rush = true
    self.view.in_rush_value:SetValue(self.view.in_rush)
end

function MapFindCtrl:GetRush()
    return self.view.in_rush
end

function MapFindCtrl:SendStart()
    if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAP_HUNT) then
        return
    end
    self:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_ALL_INFO)
end

function MapFindCtrl:ClickIsStart()
    self:SendInfo(RA_MAP_HUNT_OPERA_TYPE.RA_MAP_HUNT_OPERA_TYPE_FLUSH)
end

function MapFindCtrl:ResetState()
    if self.data.is_find then
        self.data.is_find = false
    end
    self.can_send = true
    self:EndRush()
end