require("game/serveractivity/dashe_tian_xia/dashe_tian_xia_data")
require("game/serveractivity/dashe_tian_xia/dashe_tian_xia_view")

DaSheTianXiaCtrl= DaSheTianXiaCtrl or BaseClass(BaseController)

function DaSheTianXiaCtrl:__init()
	if DaSheTianXiaCtrl.Instance then
		print_error("[DaSheTianXiaCtrl]:Attempt to create singleton twice!")
	end
	DaSheTianXiaCtrl.Instance = self
	self.view = DaSheTianXiaView.New(ViewName.DaSheTianXiaView)
	self.data = DaSheTianXiaData.New()
	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
end

function DaSheTianXiaCtrl:__delete()
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
	DaSheTianXiaCtrl.Instance = nil
end

function DaSheTianXiaCtrl:GetView()
	return self.view
end

function DaSheTianXiaCtrl:GetData()
	return self.data
end

function DaSheTianXiaCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCRAMoneyTreeFiveInfo, "OnSCRAMoneyTreeFiveInfo")
    self:RegisterProtocol(SCRAMoneyTreeFiveChouResultInfo, "OnSCRAMoneyTreeFiveChouResultInfo")
end

function DaSheTianXiaCtrl:OnSCRAMoneyTreeFiveInfo(protocol)
	self.data:SetMoneyTreeInfo(protocol)
    self.data:SetZhuanZhuanLeInfo(protocol)
    if self.view:IsOpen() then
    	self.view:Flush()
    end
    self.data:ZhuanZhaunLePoindRemind()
    RemindManager.Instance:Fire(RemindName.DASHE_TIAN_XIA)
end

function DaSheTianXiaCtrl:OnSCRAMoneyTreeFiveChouResultInfo(protocol)
    self.data:SetMoneyTreeChouResultInfo(protocol)
    if self.view:IsOpen() then
    	self.view:Flush()
    end
    self.data:ZhuanZhaunLePoindRemind()
    RemindManager.Instance:Fire(RemindName.DASHE_TIAN_XIA)
end

-- 免费抽奖次数
function DaSheTianXiaCtrl:OnDayTreeCount(day_count)
    self.data:SetFreeTime(day_count)
end

function DaSheTianXiaCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_5)
	if is_open then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_5, RA_CHONGZHI_MONEY_TREE_FIVE_OPERA_TYPE.RA_MONEY_TREE_OPERA_TYPE_QUERY_INFO)
    end
end
