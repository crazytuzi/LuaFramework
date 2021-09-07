require("game/serveractivity/lucky_turn_egg/lucky_turn_egg_data")
require("game/serveractivity/lucky_turn_egg/lucky_turn_egg_view")

LuckyTurnEggCtrl = LuckyTurnEggCtrl or BaseClass(BaseController)

function LuckyTurnEggCtrl:__init()
	if LuckyTurnEggCtrl.Instance then
		print_error("[LuckyTurnEggCtrl]:Attempt to create singleton twice!")
	end
	LuckyTurnEggCtrl.Instance = self
	self.view = LuckyTurnEggView.New(ViewName.LuckyTurnEggView)
	self.data = LuckyTurnEggData.New()
	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
end

function LuckyTurnEggCtrl:__delete()
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
	LuckyTurnEggCtrl.Instance = nil
end

function LuckyTurnEggCtrl:GetView()
	return self.view
end

function LuckyTurnEggCtrl:GetData()
	return self.data
end

function LuckyTurnEggCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCRAMoneyTreeInfoFour, "OnSCRAMoneyTreeInfo")
    self:RegisterProtocol(SCRAMoneyTreeChouResultInfoFour, "OnSCRAMoneyTreeChouResultInfo")
end

function LuckyTurnEggCtrl:OnSCRAMoneyTreeInfo(protocol)
	self.data:SetMoneyTreeInfo(protocol)
    self.data:SetZhuanZhuanLeInfo(protocol)
    if self.view:IsOpen() then
    	self.view:Flush()
    end
    self.data:ZhuanZhaunLePoindRemind()
    RemindManager.Instance:Fire(RemindName.LuckyTurnEgg)
end

function LuckyTurnEggCtrl:OnSCRAMoneyTreeChouResultInfo(protocol)
    self.data:SetMoneyTreeChouResultInfo(protocol)
    if self.view:IsOpen() then
    	self.view:Flush()
    end
    self.data:ZhuanZhaunLePoindRemind()
    RemindManager.Instance:Fire(RemindName.LuckyTurnEgg)
end

-- 免费抽奖次数
function LuckyTurnEggCtrl:OnDayTreeCount(day_count)
    self.data:SetFreeTime(day_count)
end

function LuckyTurnEggCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_4)
	if is_open then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_4, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO)
    end
end
