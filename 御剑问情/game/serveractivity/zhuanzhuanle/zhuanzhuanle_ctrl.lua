require("game/serveractivity/zhuanzhuanle/zhuanzhuanle_data")
require("game/serveractivity/zhuanzhuanle/zhuanzhuanle_view")

ZhuanZhuanLeCtrl= ZhuanZhuanLeCtrl or BaseClass(BaseController)

function ZhuanZhuanLeCtrl:__init()
	if ZhuanZhuanLeCtrl.Instance then
		print_error("[ZhuanZhuanLeCtrl]:Attempt to create singleton twice!")
	end
	ZhuanZhuanLeCtrl.Instance = self
	self.view = ZhuangZhuangLeView.New(ViewName.ZhuangZhuangLe)
	self.data = ZhuangZhuangLeData.New()
	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
end

function ZhuanZhuanLeCtrl:__delete()
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
	ZhuanZhuanLeCtrl.Instance = nil
end

function ZhuanZhuanLeCtrl:GetView()
	return self.view
end

function ZhuanZhuanLeCtrl:GetData()
	return self.data
end

function ZhuanZhuanLeCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCRAMoneyTreeInfo, "OnSCRAMoneyTreeInfo")
    self:RegisterProtocol(SCRAMoneyTreeChouResultInfo, "OnSCRAMoneyTreeChouResultInfo")
end

function ZhuanZhuanLeCtrl:OnSCRAMoneyTreeInfo(protocol)
	self.data:SetMoneyTreeInfo(protocol)
    self.data:SetZhuanZhuanLeInfo(protocol)
    if self.view:IsOpen() then 
    	self.view:Flush()
    end
    self.data:ZhuanZhaunLePoindRemind()
    RemindManager.Instance:Fire(RemindName.ZHUANZHUANLE)
end

function ZhuanZhuanLeCtrl:OnSCRAMoneyTreeChouResultInfo(protocol)
    self.data:SetMoneyTreeChouResultInfo(protocol)
    if self.view:IsOpen() then 
    	self.view:Flush()
    end
    self.data:ZhuanZhaunLePoindRemind()
    RemindManager.Instance:Fire(RemindName.ZHUANZHUANLE)
end

-- 免费抽奖次数
function ZhuanZhuanLeCtrl:OnDayTreeCount(day_count)
    self.data:SetFreeTime(day_count)
end

function ZhuanZhuanLeCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_LOTTERY_TREE)
	if is_open then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_LOTTERY_TREE, RA_CHONGZHI_MONEY_TREE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO)
    end
end


