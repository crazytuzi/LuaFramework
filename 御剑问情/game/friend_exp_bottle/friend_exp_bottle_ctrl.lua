require("game/friend_exp_bottle/friend_exp_bottle_data")
require("game/friend_exp_bottle/friend_exp_bottle_view")

FRIENDEXPBOTTLE_OPER = {
    GetExp = 0, 
    NeedFriend = 1, 
    RequireFlush = 2, 
}
FriendExpBottleCtrl = FriendExpBottleCtrl or BaseClass(BaseController)

function FriendExpBottleCtrl:__init()
    if FriendExpBottleCtrl.Instance then
        print_error("[FriendExpBottleCtrl]:Attempt to create singleton twice!")
    end
    FriendExpBottleCtrl.Instance = self

    self.view = FriendExpBottleView.New(ViewName.FriendExpBottleView)
    self.data = FriendExpBottleData.New()

    self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
    self:RegisterAllProtocols()
end

function FriendExpBottleCtrl:__delete()
    self:RemoveDelayTime()
    if self.view then
        self.view:DeleteMe()
        self.view = nil
    end

    if self.data then
        self.data:DeleteMe()
        self.data = nil
    end

    if self.main_view_complete then
        GlobalEventSystem:UnBind(self.main_view_complete)
        self.main_view_complete = nil
    end
    FriendExpBottleCtrl.Instance = nil
end

function FriendExpBottleCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCFriendExpBottleAddExp, "OnExpBottleAddExp") -- 接收玩家现在的经验
end

-- type  为0 领取经验 为1 征集好友
function FriendExpBottleCtrl:SendOper(type)
    local protocol = ProtocolPool.Instance:GetProtocol(CSFriendExpBottleOP)
    protocol.type = type
    protocol:EncodeAndSend()
end

function FriendExpBottleCtrl:OnExpBottleAddExp(protocol)
    self.data:FlushCurExp(protocol)
    RemindManager.Instance:Fire(RemindName.FriendExpBottleView)
    ViewManager.Instance:FlushView(ViewName.FriendExpBottleView)
end

function FriendExpBottleCtrl:MianUIOpenComlete()
    self:RemoveDelayTime()
    self.timer_quest = GlobalTimerQuest:AddDelayTimer(function()
         RemindManager.Instance:Fire(RemindName.FriendExpBottleView)
    end, 5)
end

function FriendExpBottleCtrl:RemoveDelayTime()
    if self.timer_quest then
        GlobalTimerQuest:CancelQuest(self.timer_quest)
        self.timer_quest = nil
    end
end
