require("game/juhuasuan/juhuasuan_view")
require("game/juhuasuan/juhuasuan_data")

JuHuaSuanCtrl = JuHuaSuanCtrl or BaseClass(BaseController)
function JuHuaSuanCtrl:__init()
	if JuHuaSuanCtrl.Instance then
		print_error("[JuHuaSuanCtrl] Attemp to create a singleton twice !")
	end
	JuHuaSuanCtrl.Instance = self

	self.data = JuHuaSuanData.New()
	self.view = JuHuaSuanView.New(ViewName.JuHuaSuan)

	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.JuHuaSuan)
end

function JuHuaSuanCtrl:__delete()
	JuHuaSuanCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.main_view_complete then
    	GlobalEventSystem:UnBind(self.main_view_complete)
        self.main_view_complete = nil
    end
end

function JuHuaSuanCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAXianyuanTreasInfo, "OnRAXianyuanTreasInfo")
end

function JuHuaSuanCtrl:OnRAXianyuanTreasInfo(protocol)
	self.data:SetJuHuaSuanInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.JuHuaSuan)
end

function JuHuaSuanCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS)
	if is_open then
		-- 请求活动信息
	 	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS, XIANYUAN_TREAS_OPERA_TYPE.QUERY_INFO)
	end
end

function JuHuaSuanCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.JuHuaSuan then
		ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANYUAN_TREAS, num >0)
	end
end