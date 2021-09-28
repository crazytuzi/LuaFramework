require("game/competition_activity/competition_activity_view")
require("game/competition_activity/competition_tips_view")
require("game/competition_activity/competition_activity_data")

CompetitionActivityCtrl = CompetitionActivityCtrl or BaseClass(BaseController)
function CompetitionActivityCtrl:__init()
	if CompetitionActivityCtrl.Instance ~= nil then
		print_error("[CompetitionActivityCtrl] attempt to create singleton twice!")
		return
	end

	CompetitionActivityCtrl.Instance = self
	self:RegisterAllProtocols()

	self.view = CompetitionActivityView.New(ViewName.CompetitionActivity)
	self.reward_view = CompetitionTips.New(ViewName.CompetitionTips)
	self.data = CompetitionActivityData.New()

	self.pass_day = GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind(self.MainuiOpenCreate, self))
	self.mainui_open_comlete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))
end

function CompetitionActivityCtrl:__delete()
	CompetitionActivityCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.mainui_open_comlete then
		GlobalEventSystem:UnBind(self.mainui_open_comlete)
		self.mainui_open_comlete = nil
	end

	if self.pass_day then
		GlobalEventSystem:UnBind(self.pass_day)
		self.pass_day = nil
	end

	if self.act_time_countdown then
		GlobalTimerQuest:CancelQuest(self.act_time_countdown)
		self.act_time_countdown = nil
	end

	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function CompetitionActivityCtrl:GetView()
	return self.view
end

function CompetitionActivityCtrl:FlushView(...)
	if self.view then
		self.view:Flush(...)
	end
end

function CompetitionActivityCtrl:RegisterAllProtocols()
end

function CompetitionActivityCtrl:SetPlayDataEvent()
	if not self.data_listen then
		self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.data_listen)
	end
end

function CompetitionActivityCtrl:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "level" then
		self:MainuiOpenCreate()
	end
end

function CompetitionActivityCtrl:MainuiOpenCreate()
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local bipin_cfg = CompetitionActivityData.Instance:GetBiPinActTypeList()
	if nil == bipin_cfg or nil == bipin_cfg[day] then
		return
	end
	
	local cfg = ActivityData.Instance:GetActivityConfig(bipin_cfg[day].activity_type)
	local level = GameVoManager.Instance:GetMainRoleVo().level

	local can_show = day <= 7 and (cfg and cfg.min_level <= level and level <= cfg.max_level) or false
	MainUIView.Instance:ChangeBiPinBtn(can_show) 

	if can_show then
		self.act_time_countdown = GlobalTimerQuest:AddRunQuest(function()
			local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
			local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
			local reset_time_s = 24 * 3600 - cur_time

			MainUIView.Instance:SetBiPinTimeCountDown(reset_time_s)
			end, 1)
	end

	for k, v in pairs(bipin_cfg) do
		if ActivityData.Instance:GetActivityIsOpen(v.activity_type) then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
		end
	end
end

function CompetitionActivityCtrl:SendGetBipinInfo()
	local day = TimeCtrl.Instance:GetCurOpenServerDay()
	local bipin_cfg = CompetitionActivityData.Instance:GetBiPinActTypeList()
	if nil == bipin_cfg or nil == bipin_cfg[day] then
		return
	end

	local cfg = ActivityData.Instance:GetActivityConfig(bipin_cfg[day].activity_type)
	if cfg == nil then return end
	for k, v in pairs(bipin_cfg) do
		if ActivityData.Instance:GetActivityIsOpen(v.activity_type) then
			KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(v.activity_type, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
		end
	end
end