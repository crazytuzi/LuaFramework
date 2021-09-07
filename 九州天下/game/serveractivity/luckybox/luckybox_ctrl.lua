require("game/serveractivity/luckybox/luckybox_data")
require("game/serveractivity/luckybox/luckybox_view")

LuckyBoxCtrl= LuckyBoxCtrl or BaseClass(BaseController)

function LuckyBoxCtrl:__init()
	if LuckyBoxCtrl.Instance then
		print_error("[LuckyBoxCtrl]:Attempt to create singleton twice!")
	end
	LuckyBoxCtrl.Instance = self
	self.view = LuckyBoxView.New(ViewName.LuckyBoxView)
	self.data = LuckyBoxData.New()
	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
end

function LuckyBoxCtrl:__delete()
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
	LuckyBoxCtrl.Instance = nil
end

function LuckyBoxCtrl:GetView()
	return self.view
end

function LuckyBoxCtrl:GetData()
	return self.data
end

function LuckyBoxCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCRAMoneyTreeInfoThree, "OnSCRAMoneyTreeInfo1")
    self:RegisterProtocol(SCRAMoneyTreeChouResultInfoThree, "OnSCRAMoneyTreeChouResultInfo")
end

function LuckyBoxCtrl:OnSCRAMoneyTreeInfo1(protocol)
	self.data:SetMoneyTreeInfo(protocol)
    self.data:SetZhuanZhuanLeInfo(protocol)
    if self.view:IsOpen() then
    	self.view:Flush()
    end
    self.data:ZhuanZhaunLePoindRemind()
    RemindManager.Instance:Fire(RemindName.LuckyBox)
end

function LuckyBoxCtrl:OnSCRAMoneyTreeChouResultInfo(protocol)
    self.data:SetMoneyTreeChouResultInfo(protocol)
    if self.view:IsOpen() then
    	self.view:Flush()
    end
    self.data:ZhuanZhaunLePoindRemind()
    RemindManager.Instance:Fire(RemindName.LuckyBox)
end

-- 免费抽奖次数
function LuckyBoxCtrl:OnDayTreeCount(day_count)
    self.data:SetFreeTime(day_count)
end

function LuckyBoxCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_LOTTERY_TREE)
	if is_open then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO)
    end
end
