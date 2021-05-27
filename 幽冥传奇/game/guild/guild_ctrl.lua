require("scripts/game/guild/guild_protocol")
require("scripts/game/guild/guild_data")
require("scripts/game/guild/guild_main_view")
require("scripts/game/guild/guild_child_view/guild_impeach_view")

-- 行会
GuildCtrl = GuildCtrl or BaseClass(BaseController)

function GuildCtrl:__init()
	if GuildCtrl.Instance then
		ErrorLog("[GuildCtrl]:Attempt to create singleton twice!")
	end
	GuildCtrl.Instance = self

	self.data = GuildData.New()
	self.view = GuildMainView.New(ViewDef.Guild)
	self.guild_impeach = GuildImpeachView.New(ViewDef.GuildImpeach)

	self:RegisterAllProtocals()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.InitGuild, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.GuildRedEnvelope)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.GuildOfferReward)
end

function GuildCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil

	if self.invite_alert then
		self.invite_alert:DeleteMe()
		self.invite_alert = nil
	end

	if self.call_alert then
		self.call_alert:DeleteMe()
		self.call_alert = nil
	end

	if self.league_req_alert then
		self.league_req_alert:DeleteMe()
		self.league_req_alert = nil
	end

	if self.guild_impeach then
		self.guild_impeach:DeleteMe()
		self.guild_impeach = nil
	end

	if self.role_data_listener_h and RoleData.Instance then
		RoleData.Instance:RemoveEventListener(self.role_data_listener_h)
	end

	if nil ~= self.hongbao_left_timer then
		GlobalTimerQuest:CancelQuest(self.hongbao_left_timer)
		self.hongbao_left_timer = nil
	end

	GuildCtrl.Instance = nil
end

function GuildCtrl:RoleDataChangeCallBack(vo)
	if vo.key == OBJ_ATTR.ACTOR_GUILD_ID then
		if vo.value > 0 then
			GuildCtrl.GetAllGuildInfo()
		else
			self.data:InitGuildData()
		end
	end
	self.data:RoleDataChangeCallBack(vo)
end

-- 提醒
function GuildCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.GuildRedEnvelope then
		local num = self.data:GetGuildRedEnvelopeNum()
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.GUILD_HONGBAO, num, function ()
			ViewManager.Instance:OpenViewByDef(ViewDef.Guild.GuildRobRedEnvelope)
		end)

		local left_time = self.data:GetRedEnvelopeLeftTime()
		if nil ~= self.hongbao_left_timer then
			GlobalTimerQuest:CancelQuest(self.hongbao_left_timer)
		end
		if 0 < left_time then
			RemindManager.Instance:DoRemindDelayTime(RemindName.GuildRedEnvelope, left_time)
		end
		return num
	elseif remind_name == RemindName.GuildOfferReward then
		return self.data:GetOfferRemind()
	end
end

-- 行会初始化
function GuildCtrl:InitGuild()
	GlobalTimerQuest:AddDelayTimer(function()
		self.GetAllGuildInfo()
		if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID) > 0 then
			GuildCtrl.GetJoinGuildReqInfo()
		end
	end, math.random() * 2)

	self.role_data_listener_h = RoleData.Instance:AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallBack, self))
end

-- 从服务端获取所有数据
function GuildCtrl.GetAllGuildInfo()
	GuildCtrl.GetGuildDetailedInfo()
	GuildCtrl.GetGuildMemberList()
	GuildCtrl.GetGuildList()
	GuildCtrl.GetGuildStorageList()
	GuildCtrl.GetGuildEvents()
	GuildCtrl.SendGuildOfferReq(1, 0)
	-- GuildCtrl.GetGuildStorageRecord()
end
