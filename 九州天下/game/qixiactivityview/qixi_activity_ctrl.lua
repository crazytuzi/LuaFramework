require("game/qixiactivityview/qixi_activity_view")
require("game/qixiactivityview/qixi_activity_data")

QiXiActivityCtrl = QiXiActivityCtrl or BaseClass(BaseController)
function QiXiActivityCtrl:__init()
	if QiXiActivityCtrl.Instance then
		print_error("[QiXiActivityCtrl] Attemp to create a singleton twice !")
	end
	QiXiActivityCtrl.Instance = self

	self.data = QiXiActivityData.New()
	self.view = QiXiActivityView.New(ViewName.QiXiActivityView)

	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
end

function QiXiActivityCtrl:__delete()
	QiXiActivityCtrl.Instance = nil

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
end

function QiXiActivityCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAYuehuiDazuozhanInfo, "OnSCRAYuehuiDazuozhanInfo")
end

function QiXiActivityCtrl:OnSCRAYuehuiDazuozhanInfo(protocol)
	self.data:SetJuHuaSuanInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.QixiCombat)
end

function QiXiActivityCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UEHUI_DAZUOZHAN)
	if is_open then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UEHUI_DAZUOZHAN, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
end