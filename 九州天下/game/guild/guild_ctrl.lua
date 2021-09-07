require("game/guild/guild_view")
require("game/guild/guild_boss_view")
require("game/guild/guild_apply_view")
require("game/guild/guild_data")
require("game/guild/guild_station_view")
require("game/guild/guild_territory_info_view")
require("game/guild/guild_roll_view")
require("game/guild/guild_check_donate_view")
require("game/guild/guild_signin_view")

GuildCtrl = GuildCtrl or  BaseClass(BaseController)
local old_guild_gongxian = nil
function GuildCtrl:__init()
	if GuildCtrl.Instance ~= nil then
		print_error("[GuildCtrl] attempt to create singleton twice!")
		return
	end
	GuildCtrl.Instance = self

	self:RegisterAllProtocols()
	--self:RegisterAllEvents()

	self.view = GuildView.New(ViewName.Guild)
	self.boss_view = GuildBossView.New(ViewName.GuildBoss)
	self.apply_view = GuildApplyView.New(ViewName.GuildApply)
	self.guild_data = GuildData.New()
	self.guild_station_view = GuildStationView.New()
	self.guild_territory_info = GuildTerritoryInfoView.New()
	self.guild_roll_view = GuildRollView.New()
	self.guild_signin_view = GuildSigninView.New()
	self.guild_check_donate_view = GuildCheckDonateView.New()

	self.create_model = {                                           -- 创建公会模式
		coin = 1,
		jianmengling = 2,
	}
	self.guild_info_type = {										-- 公会信息类型
		INVALID = 0,
		ALL_GUILD_BASE_INFO = 1,									-- 所有公会基本信息
		GUILD_APPLY_FOR_INFO = 2,									-- 公会申请列表
		GUILD_MEMBER_LIST = 3,										-- 公会成员列表
		GUILD_INFO = 4,												-- 公会信息
		GUILD_EVENT_LIST = 5,										-- 公会日志列表
		APPLY_FOR_JOIN_GUILD_LIST = 6,								-- 已申请加入的公会列表
		INVITE_LIST = 7,											-- 邀请列表
		MAX = 99,
	}
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
	self:BindGlobalEvent(OtherEventType.DAY_COUNT_CHANGE, BindTool.Bind(self.DayCountChange, self))
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.MainRoleInfo, self))

	if self.item_data_change_callback == nil then
		self.item_data_change_callback = BindTool.Bind(self.OnItemChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_callback)
	end
end

function GuildCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCreateGuild, "OnCreateGuild")
	self:RegisterProtocol(SCApplyForJoinGuild, "OnApplyForJoinGuild")
	self:RegisterProtocol(SCGuildBaseInfo, "OnGuildInfo")
	self:RegisterProtocol(SCAllGuildBaseInfo, "OnAllGuildInfoList")
	self:RegisterProtocol(SCApplyForJoinGuildAck, "OnApplyForJoinGuildAck")
	self:RegisterProtocol(SCGuildMemberList, "OnGuildMemberList")
	self:RegisterProtocol(SCChangeNotice, "OnChangeNotice")
	self:RegisterProtocol(SCQuitGuild, "OnQuitGuild")
	self:RegisterProtocol(SCGuildCheckCanDelateAck, "GuildCheckCanDelateAck")
	self:RegisterProtocol(SCAddGuildExpSucc, "OnJuanXianResult")
	self:RegisterProtocol(SCRoleGuildInfoChange, "OnRoleGuildInfoChange")
	self:RegisterProtocol(SCGuildRoleGuildInfo, "OnGuildRoleGuildInfo")
	self:RegisterProtocol(SCGuildGetApplyForList, "OnGuildApplyForList")
	self:RegisterProtocol(SCKickoutGuild, "OnKickoutGuild")
	self:RegisterProtocol(SCGuildBoxInfo, "OnGuildBoxInfo")
	self:RegisterProtocol(SCGuildBoxNeedAssistInfo, "OnGuildBoxNeedAssistInfo")
	self:RegisterProtocol(SCGuildMemberSos, "OnSCGuildMemberSos")
	self:RegisterProtocol(SCGuildBossInfo, "OnGuildBossInfo")
	self:RegisterProtocol(SCAppointGuild, "OnAppointGuild")
	self:RegisterProtocol(SCGuildStorgeInfo, "OnGuildStorgeInfo")
	self:RegisterProtocol(SCGuildStorgeChange, "OnGuildStorgeChange")
	self:RegisterProtocol(SCGuildResetName, "OnGuildResetName")
	self:RegisterProtocol(SCNotifyGuildSuper, "OnNotifyGuildSuper")
	self:RegisterProtocol(SCGuildBossActivityInfo, "OnGuildBossActivityInfo")
	self:RegisterProtocol(SCInviteNotify, "OnInviteNotify")
	self:RegisterProtocol(SCInviteGuild, "OnInviteGuild")
	self:RegisterProtocol(SCGuildOperaSucc, "OnGuildOperaSucc")
	-- self:RegisterProtocol(SCGuildMemberNum, "OnGuildMemberNum")
	-- self:RegisterProtocol(SCGulidReliveTimes, "OnGulidReliveTimes")
	-- self:RegisterProtocol(SCGulidBossRedbagInfo, "OnGulidBossRedbagInfo")
	self:RegisterProtocol(SCGuildEventList, "OnGuildEventList")
	self:RegisterProtocol(SCGuildBossEvent, "OnGuildBossEvent")
	-- 仙盟签到
	self:RegisterProtocol(CSGuildSinginReq)
	self:RegisterProtocol(SCGuildSinginAllInfo, "OnSCGuildSinginAllInfo")
	self:RegisterProtocol(SCGuildStorageFullNoticeInfo, "OnSCGuildStorageFull")
end

function GuildCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.boss_view ~= nil then
		self.boss_view:DeleteMe()
		self.boss_view = nil
	end

	if self.apply_view ~= nil then
		self.apply_view:DeleteMe()
		self.apply_view = nil
	end

	if self.guild_roll_view ~= nil then
		self.guild_roll_view:DeleteMe()
		self.guild_roll_view = nil
	end

	if self.guild_data ~= nil then
		self.guild_data:DeleteMe()
		self.guild_data = nil
	end

	if self.guild_station_view ~= nil then
		self.guild_station_view:DeleteMe()
		self.guild_station_view = nil
	end

	if self.guild_check_donate_view ~= nil then
		self.guild_check_donate_view:DeleteMe()
		self.guild_check_donate_view = nil
	end

	if self.scene_loaded then
		GlobalEventSystem:UnBind(self.scene_loaded)
		self.scene_loaded = nil
	end
	
	if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if self.item_data_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)
		self.item_data_change_callback = nil
	end
	self:RemoveCountDown()
	GuildCtrl.Instance = nil
end

function GuildCtrl:OnItemChangeCallback()
	--GuildChatData.Instance:CheckRedPoint()
	-- GuildData.Instance:CalculateRedPoint()
end

-- 关闭所有弹窗
function GuildCtrl:CloseAllWindow()
	self.view:CloseAllWindow()
end

function GuildCtrl:MainuiOpen()
	-- self:SendAllGuildInfoReq()
	-- local vo = GameVoManager.Instance:GetMainRoleVo()
	-- GuildData.Instance.guild_id = vo.guild_id
	-- if(vo.guild_id == 0) then
	-- 	return
	-- end
	-- self:SendGuildInfoReq()
	-- self:SendGuildApplyListReq()
	-- self:SendAllGuildMemberInfoReq()
	-- self:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF)
	-- self:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_NEED_ASSIST)
end

function GuildCtrl:DayCountChange(day_counter_id)
	if day_counter_id == -1 or day_counter_id == DAY_COUNT.DAYCOUNT_ID_GUILD_REWARD then
		local day_count = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_REWARD) or 0
		GuildData.Instance:SetGuildFuLiCount(day_count)
		if self.view then
			self.view:Flush()
		end
	end
end

function GuildCtrl:MainRoleInfo()
	if not IS_ON_CROSSSERVER then
		self:SendAllGuildInfoReq()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		GuildData.Instance.guild_id = vo.guild_id
		GuildData.Instance:SetLastLeaveGuildTime(vo.last_leave_guild_time)
		if(vo.guild_id == 0) then
			return
		end
		self:SendGuildInfoReq()
		self:SendGuildApplyListReq()
		self:SendAllGuildMemberInfoReq()
		self:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF)
		self:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_NEED_ASSIST)
	end
end

function GuildCtrl:GuildViewOpen()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	GuildData.Instance.guild_id = vo.guild_id
	if(guild_id == 0) then
		self:SendAllGuildInfoReq()
		return
	end
	self:SendGuildInfoReq()
	self:SendAllGuildMemberInfoReq()
end

function GuildCtrl:InitGuildView()
	if(self.view == nil) then
		return
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	GuildData.Instance.guild_id = vo.guild_id

	if(GuildData.Instance.guild_id <= 0) then -- 没有加入公会
		self:SendAllGuildInfoReq()
		self.view:InitViewCase1() --当没有加入公会时VIew面板的初始化
	else
		self:SendGuildInfoReq()
		self.view:InitViewCase2() --当加入公会后VIew面板的初始化
	end
end

-- 请求获得公会信息
function GuildCtrl:SendGuildInfoReq(guild_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildInfo)
	protocol.guild_info_type = self.guild_info_type.GUILD_INFO
	protocol.guild_id = guild_id or GameVoManager.Instance:GetMainRoleVo().guild_id
	protocol:EncodeAndSend()
end

-- 请求获得全部公会信息
function GuildCtrl:SendAllGuildInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildInfo)
	protocol.guild_info_type = self.guild_info_type.ALL_GUILD_BASE_INFO
	protocol.guild_id = GuildData.Instance.guild_id
	protocol:EncodeAndSend()
end

-- 请求获得申请加入自己公会的玩家列表
function GuildCtrl:SendGuildApplyListReq()
	if GuildData.Instance.guild_id <= 0 then return end
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildInfo)
	protocol.guild_info_type = self.guild_info_type.GUILD_APPLY_FOR_INFO
	protocol.guild_id = GuildData.Instance.guild_id
	protocol:EncodeAndSend()
end

-- 请求获得公会成员信息
function GuildCtrl:SendAllGuildMemberInfoReq(guild_id)
	if GuildData.Instance.guild_id <= 0 then return end
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildInfo)
	protocol.guild_info_type = self.guild_info_type.GUILD_MEMBER_LIST
	protocol.guild_id = guild_id or GuildData.Instance.guild_id
	protocol:EncodeAndSend()
end

-- 请求更改公会公告
function GuildCtrl:SendGuildChangeNoticeReq(notice)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildChangeNotice)
	protocol.guild_id = GuildData.Instance.guild_id
	protocol.notice = notice
	protocol:EncodeAndSend()
end

-- 请求获得公会成员信息
function GuildCtrl:SendGuildEventListReq(guild_id)
	if GuildData.Instance.guild_id <= 0 then return end
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildInfo)
	protocol.guild_info_type = self.guild_info_type.GUILD_EVENT_LIST
	protocol.guild_id = guild_id or GuildData.Instance.guild_id
	protocol:EncodeAndSend()
end

-- 签到请求
function GuildCtrl:SendCSGuildSinginReq(req_type, param1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildSinginReq)
	protocol.req_type = req_type or 0
	protocol.param1 = param1 or 0
	protocol:EncodeAndSend()
end

-- 签到
function GuildCtrl:OnSCGuildSinginAllInfo(protocol)
	-- 签到成功发一天文字
	local signin_data = self.guild_data:GetSigninData()
	if signin_data.is_signin_today == 0 and protocol.is_signin_today == 1 then
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		local main_role_name = main_vo.name
		local signin_cfg = self.guild_data:GetSigninCfg()
		local last_data_cfg = signin_cfg[#signin_cfg] or {}
		local signin_limit = last_data_cfg.need_count or 15
		local text = string.format(Language.Chat.GuildSigninText, main_role_name, protocol.guild_signin_count_today, signin_limit)
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, text, CHAT_CONTENT_TYPE.TEXT, SHOW_CHAT_TYPE.SYS)
	end

	self.guild_data:SetSigninData(protocol)
	self.guild_signin_view:Flush()

	RemindManager.Instance:Fire(RemindName.SignIn)
	GuildChatData.Instance:CheckRedPoint()
	GuildChatView.Instance:Flush("view")

	-- RemindManager.Instance:Fire(RemindName.Guild)
	self.view:Flush()

	-- 签到后请求下仙盟成员信息
	GuildCtrl.Instance:SendAllGuildMemberInfoReq()
end

-- 家族仓库是否满了
function GuildCtrl:OnSCGuildStorageFull(protocol)
	local is_full = false
	if protocol.is_full > 0 then
		is_full = true
	end
	MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.GUILD_STORAGE, {is_full})
end

-- 获得仙盟基本信息
function GuildCtrl:OnGuildInfo(protocol)
	local guildvo = {}
	guildvo.guild_id = protocol.guild_id
	guildvo.guild_name = protocol.guild_name
	guildvo.guild_avatar_key_big = protocol.guild_avatar_key_big
	guildvo.guild_avatar_key_small = protocol.guild_avatar_key_small
	guildvo.guild_level = protocol.guild_level
	guildvo.guild_exp = protocol.guild_exp
	guildvo.guild_max_exp = protocol.guild_max_exp
	guildvo.guild_totem_level = protocol.totem_level
	guildvo.guild_totem_exp = protocol.totem_exp
	guildvo.cur_member_count = protocol.cur_member_count
	guildvo.max_member_count = protocol.max_member_count
	guildvo.tuanzhang_uid = protocol.tuanzhang_uid
	guildvo.tuanzhang_name = protocol.tuanzhang_name
	guildvo.create_time = protocol.create_time
	guildvo.camp = protocol.camp
	guildvo.vip_level = protocol.vip_level
	guildvo.applyfor_setup = protocol.applyfor_setup
	guildvo.guild_notice = protocol.guild_notice
	guildvo.auto_kickout_setup = protocol.auto_kickout_setup
	guildvo.applyfor_need_capability = protocol.applyfor_need_capability
	guildvo.applyfor_need_level = protocol.applyfor_need_level
	guildvo.guild_callin_times = protocol.callin_times
	guildvo.my_lucky_color = protocol.my_lucky_color
	guildvo.active_degree = protocol.active_degree
	guildvo.total_capability = protocol.total_capability
	guildvo.rank = protocol.rank
	guildvo.totem_exp_today = protocol.totem_exp_today

	if protocol.guild_id == GameVoManager.Instance:GetMainRoleVo().guild_id then
		for k, v in pairs(guildvo) do
			GuildDataConst.GUILDVO[k] = v
		end
		-- GuildData.Instance:GetReminder(Guild_PANEL.totem)
		if self.view then
			self.view:Flush()
		end
		if GuildChatView.Instance:IsOpen() then
			GuildChatView.Instance:Flush("view")
		end
		AvatarManager.Instance:SetAvatarKey(protocol.guild_id, protocol.guild_avatar_key_big, protocol.guild_avatar_key_small)
	else
		local other_guild_info = GuildData.Instance:GetOtherGuildInfo()
		for k, v in pairs(guildvo) do
			other_guild_info[k] = v
		end
		if self.view then
			self.view:FlushRequest()
		end
	end

	if self.join_new_guild then
		CheckCtrl.Instance:SendQueryRoleInfoReq(protocol.tuanzhang_uid)
		self.join_new_guild = false
	end

	-- local scene_logic = Scene.Instance:GetSceneLogic()
	-- if scene_logic then
	-- 	if scene_logic:GetSceneType() == SceneType.GuildStation then
	-- 		scene_logic:ChangeQizhi(protocol.totem_level or 0)
	-- 	end
	-- end

	RemindManager.Instance:Fire(RemindName.GuildRoleInfoDonate)
	RemindManager.Instance:Fire(RemindName.GuildRoleSkill)
	RemindManager.Instance:Fire(RemindName.GuildTabBoss)
	RemindManager.Instance:Fire(RemindName.GuildTabBox)

end

-- 所有仙盟信息列表
function GuildCtrl:OnAllGuildInfoList(protocol)
	self.guild_data:SetGuildInfoList(protocol)
	GuildDataConst.GUILD_INFO_LIST.free_create_guild_times = protocol.free_create_guild_times
	GuildDataConst.GUILD_INFO_LIST.is_first = protocol.is_first
	GuildDataConst.GUILD_INFO_LIST.count = protocol.count
	local list = protocol.info_list
	if list then
		table.sort(list, function(a, b) return a.total_capability > b.total_capability end)
	end
	GuildDataConst.GUILD_INFO_LIST.list = list
	GuildDataConst.GUILD_INFO_LIST.is_server_backed = true

	if self.view then
		self.view:Flush()
	end
	if GuildChatView.Instance:IsOpen() then
		GuildChatView.Instance:Flush("view")
	end
end

-- 创建公会结果
function GuildCtrl:OnCreateGuild(protocol) -- 0 = 成功
	self.ret = protocol.ret
	if(self.ret ~= 0) then      -- 失败
		return
	end
	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Guild.Event_Type_1, GameVoManager.Instance:GetMainRoleVo().name))
	GuildData.Instance.guild_id = protocol.guild_id
	Scene.Instance:GetMainRole():SetAttr("guild_id", protocol.guild_id)
	self:CloseAllWindow()
	self:SendGuildApplyListReq()
	self:SendAllGuildMemberInfoReq()
	self:SendGuildInfoReq()
	self.view:InitViewCase2()
end

-- 申请加入公会结果
function GuildCtrl:OnApplyForJoinGuild(protocol)
	if 0 == protocol.ret then 						-- 0：成功 其它失败
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ApplyForJoinGuild)
	end
end

-- 请求创建公会
function GuildCtrl:SendGuildBaseInfoReq(name, guild_type, knapsack_index)
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CanNotCreateInCross)
		return
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSCreateGuild)
	protocol.guild_name = name
	protocol.create_guild_type = guild_type
	protocol.knapsack_index = knapsack_index
	protocol.guild_notice = ""
	protocol:EncodeAndSend()
end

--  请求加入公会 is_auto_join == 1 自动加入公会
function GuildCtrl:SendApplyForJoinGuildReq(guild_id, is_auto_join)
	local protocol = ProtocolPool.Instance:GetProtocol(CSApplyForJoinGuild)
	protocol.guild_id = guild_id or 0
	protocol.is_auto_join = is_auto_join or 0
	protocol:EncodeAndSend()
end

-- 公会变更通知
function GuildCtrl:OnRoleGuildInfoChange(protocol)
	AvatarManager.Instance:SetAvatarKey(protocol.guild_id, protocol.guild_avatar_key_big, protocol.guild_avatar_key_small)
	
	local obj = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if obj then
		obj:SetAttr("guild_id", protocol.guild_id)
		obj:SetAttr("guild_name", protocol.guild_name)
		obj:SetAttr("guild_post", protocol.guild_post)
		obj:SetAttr("last_leave_guild_time", protocol.last_leave_guild_time)
		obj:UpdateTitle()
		obj:ReloadUIGuildName()
		obj:ReloadUIGuildName()
		obj:SetGuildIcon()

		-- 退公会的时候隐藏公会头像
		if protocol.guild_id <= 0 then
			obj:SetRoleGuildIconValue()
		end

		if obj:IsMainRole() then
			if old_guild_gongxian then
				local delta_gongxian = protocol.guild_gongxian - old_guild_gongxian
				old_guild_gongxian = protocol.guild_gongxian
			    if delta_gongxian > 0 then
			        TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddGuildGX, delta_gongxian))
			    end
			end
			self.guild_data:SetGuildGongxian(protocol.guild_gongxian)
			self.guild_data:SetLastLeaveGuildTime(protocol.last_leave_guild_time)
			if GuildData.Instance.guild_id ~= protocol.guild_id then
				GuildData.Instance.guild_id = protocol.guild_id
				-- 加入了新公会
				self:SendGuildApplyListReq()
				self:SendAllGuildMemberInfoReq()
				self:SendGuildInfoReq()
				if(GuildData.Instance.guild_id ~= 0) then
					self.view:InitViewCase2()
					self.join_new_guild = true
					SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Guild.Event_Type_2, GameVoManager.Instance:GetMainRoleVo().name))
				else
					-- 离开了公会
					SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Guild.TuiChuGuild, GameVoManager.Instance:GetMainRoleVo().name))
					GuildData.Instance.guild_id = 0
					GuildData.Instance:ClearCache()
					self:InitGuildView()
				end
			end
		end
	end

	if nil ~= obj and protocol.guild_id == GuildData.Instance.guild_id and protocol.guild_id ~= 0 then
		local vo = obj:GetVo()
		local role_id = vo.role_id
		local role_name = vo.name
		local post = GuildData.Instance:GetGuildPost(role_id)
		if post ~= protocol.guild_post and protocol.guild_post ~= GuildDataConst.GUILD_POST.CHENG_YUAN then
			local str = string.format(Language.Guild.Event_Type_5, role_name, GuildData.Instance:GetGuildPostNameByPostId(protocol.guild_post))
			SysMsgCtrl.Instance:ErrorRemind(str)
			if protocol.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG then
				if self.view then
					self.view:CloseAllWindow()
				end
			end
		end
		self.guild_data:SetGuildTotalGongxian(protocol.guild_total_gongxian)
		-- GuildData.Instance:GetReminder(Guild_PANEL.totem)
		self:SendGuildApplyListReq()
		self:SendAllGuildMemberInfoReq()
		self:SendGuildInfoReq()
		self:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF)
		self:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_NEED_ASSIST)
		if self.view then
			self.view:Flush()
		end
		if GuildChatView.Instance:IsOpen() then
			GuildChatView.Instance:Flush("view")
		end
	end
	if ViewManager.Instance:IsOpen(ViewName.Main) and MainUICtrl.Instance:IsLoaded() then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if vo.guild_id > 0 then
			MainUIViewChat.Instance:ShowGuildChatIcon(true)
		else
			MainUIViewChat.Instance:ShowGuildChatIcon(false)
		end
	end
end

-- 公会成员列表
function GuildCtrl:OnGuildMemberList(protocol)
	self.guild_data:SetMemberNumList(protocol)
	local list = protocol.member_list
	table.sort(list, function(a, b)
			if a.is_online == b.is_online then
				if a.is_online == 1 then
					if a.post == b.post then
						if a.gongxian == b.gongxian then
							if a.level == b.level then
								return a.capability > b.capability
							else
								return a.level > b.level
							end
						else
							return a.gongxian > b.gongxian
						end
					else
						if GuildDataConst.GUILD_POST_WEIGHT[a.post] and GuildDataConst.GUILD_POST_WEIGHT[b.post] then
							return GuildDataConst.GUILD_POST_WEIGHT[a.post] > GuildDataConst.GUILD_POST_WEIGHT[b.post]
						end
					end
				else
					return a.last_login_time > b.last_login_time
				end
			else
				return a.is_online > b.is_online
			end
		end)

	local member_list = GuildDataConst.GUILD_MEMBER_LIST
	member_list.count = protocol.count
	member_list.list = list

	for k, v in pairs(member_list.list) do
		AvatarManager.Instance:SetAvatarKey(v.uid, v.avatar_key_big, v.avatar_key_small)
		AvatarManager.Instance:SetAvatarFrameKey(v.uid, v.avatar_window)
	end

	-- GuildData.Instance:GetReminder(Guild_PANEL.totem)

	if self.view then
		self.view:Flush()
	end
	local post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		self:SendGuildApplyListReq()
	end

	if GuildChatView.Instance:IsOpen() then
		GuildChatView.Instance:Flush("view")
	end
	self.view:ShowMemberMyInfo()
	GlobalEventSystem:Fire(OtherEventType.GUILD_MEMBER_INFO_CHANGE)
end

-- 修改仙盟公告结果返回
function GuildCtrl:OnChangeNotice(protocol)
	if(protocol.ret == 0) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ModNoticeResult)
		self:SendGuildInfoReq()
		self.view.info_view:CloseAllWindow()
	end
end

-- 捐献请求
-- times捐献铜钱次数
-- item_list捐献物品列表[{item_id:100, item_num:1}, ....]
function GuildCtrl:SendAddGuildExpReq(juanxian_type, num, times, item_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSAddGuildExp)
	send_protocol.type = juanxian_type
	send_protocol.value = num
	send_protocol.times = times
	send_protocol.item_list = item_list or {}
	send_protocol:EncodeAndSend()
end

-- 仙盟捐献结果返回
function GuildCtrl:OnJuanXianResult(protocol)
	self.view:Flush()
	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Guild.AddGongXianVal, protocol.add_gongxian, protocol.add_gongxian / 10))
	self:SendGuildEventListReq()
end

-- 请求退出公会
function GuildCtrl:SendQuitGuildReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSQuitGuild)
	if(GuildData.Instance.guild_id <= 0) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoGuild)
		return
	end
	protocol.guild_id = GuildData.Instance.guild_id
	protocol:EncodeAndSend()
end

-- 请求退出公会结果返回
function GuildCtrl:OnQuitGuild(protocol)
	if protocol.ret == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.QuitGuild)
		GuildData.Instance.guild_id = 0
		Scene.Instance:GetMainRole():SetAttr("guild_id", 0)
		Scene.Instance:GetMainRole():GetFollowUi():SetRoleGuildIconValue()
		self:InitGuildView()
	end
end

-- 检查能否弹劾会长
function GuildCtrl:SendGuildCheckCanDelateReq()
	if(GuildData.Instance.guild_id <= 0) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoGuild)
		return
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildCheckCanDelate)
	protocol.guild_id = GuildData.Instance.guild_id
	protocol:EncodeAndSend()
end

-- 检查是否能够弹劾盟主结果返回 0 不能 1能
function GuildCtrl:GuildCheckCanDelateAck(protocol)
	if(protocol.can_delate == 0) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.DontDelate)
		return
	end
	self:SendGuildDelateReq()
end

-- 弹劾请求
function GuildCtrl:SendGuildDelateReq()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if(guild_id <= 0) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoGuild)
		return
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildDelate)
	protocol.guild_id = guild_id
	local delete_id = GuildData.Instance:GetGuildDeleteId()
	local index = ItemData.Instance:GetItemIndex(delete_id)
	protocol.knapsack_index = index
	protocol:EncodeAndSend()
end

-- 管理员收到的申请加入仙盟列表
function GuildCtrl:OnGuildApplyForList(protocol)
	local apply_list = GuildDataConst.GUILD_APPLYFOR_LIST
	apply_list.count = protocol.count
	apply_list.list = protocol.apply_list
	if self.view then
		self.view:SetWindowSwitch(false)
		self.view:Flush()
	end
	if GuildChatView.Instance:IsOpen() then
		GuildChatView.Instance:Flush("view")
	end
	if self.apply_view then
		self.apply_view:Flush()
	end
	local post = GuildData.Instance:GetGuildPost()
	if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
		if MainUICtrl.Instance.view then
			if protocol.count > 0 then
				MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.GUILD_YAO, {true})
			else
				MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.GUILD_YAO, {false})
			end
		end
	end
	RemindManager.Instance:Fire(RemindName.GuildOperation)
end

-- 请求获得兑换内容信息
function GuildCtrl:SendGuildExchangeReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildExchange)
	protocol:EncodeAndSend()
end

-- 角色的公会信息
function GuildCtrl:OnGuildRoleGuildInfo(protocol)
	if old_guild_gongxian == nil and protocol.guild_gongxian then
		old_guild_gongxian = protocol.guild_gongxian
	end
	self.guild_data:SetGuildRoleGuildInfo(protocol)
	if self.view then
		self.view:CheckLevelUp()
	end
	self.view:Flush()
	if GuildChatView.Instance:IsOpen() then
		GuildChatView.Instance:Flush("view")
	end
end

-- 请求升级公会技能
function GuildCtrl:SendGuildSkillUplevelReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildSkillUplevel)
	protocol.skill_index = index
	protocol:EncodeAndSend()
end

-- 仙盟设置请求
function GuildCtrl:SendSettingGuildReq(guild_id, applyfor_setup, need_capability, need_level)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSApplyforSetup)
	send_protocol.guild_id = guild_id
	send_protocol.applyfor_setup = applyfor_setup
	send_protocol.need_capability = need_capability
	send_protocol.need_level = need_level
	send_protocol:EncodeAndSend()
end

-- 回复加入申请通知
function GuildCtrl:OnApplyForJoinGuildAck(protocol)
	if 1 == protocol.result then 						-- 1：拒绝 0：失败
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Guild.RefuseJoinGuild, protocol.guild_name))
	end
end

-- 审批申请加入仙盟请求
function GuildCtrl:SendGuildApplyforJoinReq(guild_id, result, count, list)
	if nil == list then
		return
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSApplyForJoinGuildAck)
	send_protocol.guild_id = guild_id
	send_protocol.result = result
	send_protocol.count = count
	send_protocol.list = list
	send_protocol:EncodeAndSend()
end

-- 请求升级公会图腾
function GuildCtrl:SendGuildTotemUplevelReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildUpTotemLevel)
	protocol:EncodeAndSend()
end

-- 发送返回驻地请求
function GuildCtrl:SendGuildBackToStationReq(guild_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildBackToStation)
	send_protocol.guild_id = guild_id
	send_protocol:EncodeAndSend()
end

-- 发送解散仙盟请求
function GuildCtrl:SendDismissGuildReq(guild_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSDismissGuild)
	send_protocol.guild_id = guild_id
	send_protocol:EncodeAndSend()
end

-- 发送踢人请求
function GuildCtrl:SendKickoutGuildReq(guild_id, bekicker_count, list)
	if nil == list then
		return
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSKickoutGuild)
	send_protocol.guild_id = guild_id
	send_protocol.bekicker_count = bekicker_count
	send_protocol.list = list
	send_protocol:EncodeAndSend()
end

-- 踢人结果(0是成功)
function GuildCtrl:OnKickoutGuild(protocol)
	if protocol.ret == 0 then
		for k,v in pairs(GuildDataConst.GUILD_MEMBER_LIST.list) do
			if v.uid == protocol.bekick_uid then
				table.remove(GuildDataConst.GUILD_MEMBER_LIST.list, k)
				GuildDataConst.GUILD_MEMBER_LIST.count = GuildDataConst.GUILD_MEMBER_LIST.count - 1
				break
			end
		end
		self.view:Flush()
	end
end

-- 宝箱信息
function GuildCtrl:OnGuildBoxInfo(protocol)
	local switch = false
	self:RemoveCountDown()
	local other_config = GuildData.Instance:GetOtherConfig()
	local now_time = TimeCtrl.Instance:GetServerTime()
	if other_config and now_time then
		local rest_assist_count = other_config.box_assist_max_count - protocol.assist_count
		if rest_assist_count > 0 then
			local box_assist_cd_limit = other_config.box_assist_cd_limit
			if box_assist_cd_limit then
				if protocol.assist_cd_end_time - now_time <= box_assist_cd_limit then
					switch = true
				else
					self:StartCountDown(protocol.assist_cd_end_time - now_time - box_assist_cd_limit)
				end
			end
		end
		local time_zone = TimeUtil.GetTimeZone()
		now_time = (now_time + time_zone) % 86400
		local box_start_time = other_config.box_start_time
		if now_time >= box_start_time then
			GuildData.Instance:SetGuildBoxStart(true)
		else
			GuildData.Instance:SetGuildBoxStart(false)
			self.count_down2 = GlobalTimerQuest:AddDelayTimer(function() self:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF) end,
				box_start_time - now_time + 1)
		end
	end
	GuildData.Instance:SetBoxInfo(protocol)
	GuildData.Instance:SetIsCanAssistBox(switch)

	RemindManager.Instance:Fire(RemindName.GuildTabBoxWaBao)
	RemindManager.Instance:Fire(RemindName.GuildTabBoxXieZu)
	RemindManager.Instance:Fire(RemindName.GuildTabBox)

	if self.view then
		self.view:Flush()
	end
end

-- 宝箱协助信息
function GuildCtrl:OnGuildBoxNeedAssistInfo(protocol)
	GuildData.Instance:SetAssistInfo(protocol)
	if self.view then
		self.view:Flush()
	end
	-- GuildData.Instance:CalculateRedPoint()
	RemindManager.Instance:Fire(RemindName.GuildTabBoxXieZu)
end

-- 仙盟宝箱操作
function GuildCtrl:SendGuildBoxOperateReq(operate_type, param1, param2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildBoxOperate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 2
	send_protocol:EncodeAndSend()
	RemindManager.Instance:Fire(RemindName.GuildTabBoxWaBao)
end

-- 帮派求救
function GuildCtrl:SendSendGuildSosReq(sos_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendGuildSosReq)
	protocol.sos_type = sos_type
	protocol:EncodeAndSend()
end

-- 帮派求救
function GuildCtrl:OnSCGuildMemberSos(protocol)
	if protocol.sos_type == 0 then
		if MainUICtrl.Instance.view and MainUICtrl.Instance.view.reminding_view then
			MainUICtrl.Instance.view.reminding_view:SetQiuJiuGray()
		end
	end
	if protocol.member_uid == GameVoManager.Instance:GetMainRoleVo().role_id then
		SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.SosToGuildSuc)
		return
	end
	if Scene.Instance:GetSceneType() ~= SceneType.Common then
		return
	end

	-- local icon_list = MainuiCtrl.Instance:GetTipIconList(MAINUI_TIP_TYPE.YUAN)
	-- if icon_list ~= nil then
	-- 	for k,v in pairs(icon_list) do
	-- 		if v:GetData() and v:GetData().param and v:GetData().param.member_uid == protocol.member_uid and v:IsVisible() then --不重复添加
	-- 			return
	-- 		end
	-- 	end
	-- end

	local data = {}
	data.x = protocol.member_pos_x
	data.y = protocol.member_pos_y
	data.member_uid = protocol.member_uid
	data.scene_id = protocol.member_scene_id
	data.name = protocol.member_name
	data.camp = GameVoManager.Instance:GetMainRoleVo().camp
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.SOS_REQ, {data})
	end
end

function GuildCtrl:OnClickSos(info)
	local yes_func = function()
		GuajiCtrl.Instance:FlyToScenePos(info.scene_id, info.x, info.y)
		MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
	end
	local describe = string.format(Language.Guild.QIUYUAN, info.name)
	TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

-- boss信息返回
function GuildCtrl:OnGuildBossInfo(protocol)
	self.guild_data:SetBossInfo(protocol)
	if self.boss_view then
		self.boss_view:Flush()
	end
	if self.view then
		self.view:Flush()
	end
	if self.guild_station_view then
		self.guild_station_view:Flush()
	end
	ViewManager.Instance:FlushView(ViewName.FbIconView, "guild_boss")
	RemindManager.Instance:Fire(RemindName.GuildTabBoss)
end

-- Boss操作
function GuildCtrl:SendGuildBossReq(boss_type, is_super_call)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildBossOperate)
	protocol.oper_type = boss_type
	protocol.param = is_super_call and 1 or 0
	protocol:EncodeAndSend()
end

-- 任命请求
function GuildCtrl:SendGuildAppointReq(guild_id, beappoint_uid, post)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSAppointGuild)
	send_protocol.guild_id = guild_id
	send_protocol.beappoint_uid = beappoint_uid
	send_protocol.post = post
	send_protocol:EncodeAndSend()
end

-- 管理员任命玩家结果返回
function GuildCtrl:OnAppointGuild(protocol)
	if 0 == protocol.ret then 			
        self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.ShowTipError, self), 1)			-- 0：成功 其它失败
		if self.view and self.view.member_view then
			self.view.member_view.transfer_window:SetActive(false)
		end
	end
end
function GuildCtrl:ShowTipError()
	SysMsgCtrl.Instance:ErrorRemind(Language.Guild.AppointSuccess)
    if self.timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end
-- 领取每日奖励
function GuildCtrl:SendGuildFetchRewardReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildFetchReward)
	protocol:EncodeAndSend()
end

-- 仓库信息
function GuildCtrl:OnGuildStorgeInfo(protocol)
	GuildData.Instance:SetGuildStorgeInfo(protocol)
	if self.view then
		self.view:Flush()
	end
end

-- 仓库变更
function GuildCtrl:OnGuildStorgeChange(protocol)
	GuildData.Instance:SetGuildStorgeChange(protocol)
	if self.view then
		self.view:Flush()
	end
end

-- 公会名字改变
function GuildCtrl:OnGuildResetName(protocol)
	Scene.Instance:GetMainRole():SetAttr("guild_name", protocol.new_name)
	GuildDataConst.GUILDVO.guild_name = protocol.new_name
	if self.view then
		self.view:Flush()
	end
end

-- 公会消息通知
function GuildCtrl:OnNotifyGuildSuper(protocol)
	local notify_type_list = GuildDataConst.GUILD_NOTIFY_TYPE
	local notify_type = protocol.notify_type
	if notify_type == notify_type_list.APPLYFOR then
		local post = GuildData.Instance:GetGuildPost()
		if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
			self:SendGuildApplyListReq()
		end
	end
	RemindManager.Instance:Fire(RemindName.GuildOperation)
end

-- 公会仓库操作
function GuildCtrl:SendStorgeOperate(operate_type, param1, param2, param3, param4)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildStorgeOperate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0
	send_protocol:EncodeAndSend()
end

-- 放进仓库
function GuildCtrl:SendStorgetPutItem(bag_index, num)
	self:SendStorgeOperate(GUILD_STORGE_OPERATE.GUILD_STORGE_OPERATE_PUTON_ITEM, bag_index, num)
end

-- 取出仓库
function GuildCtrl:SendStorgetOutItem(storge_index, num, item_id)
	self:SendStorgeOperate(GUILD_STORGE_OPERATE.GUILD_STORGE_OPERATE_TAKE_ITEM, storge_index, num, item_id)
end

-- 销毁物品
function GuildCtrl:SendStorgetDestoryItem(storge_index, item_id)
	self:SendStorgeOperate(GUILD_STORGE_OPERATE.GUILD_STORGE_OPERATE_DISCARD_ITEM, storge_index, item_id)
end

-- 公会仓库批量操作
function GuildCtrl:SendStorgeOneKeyOperate(operate_type, item_count, item_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildStorgeOneKeyOperate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.item_count = item_count or 0
	send_protocol.item_list = item_list or {}
	send_protocol:EncodeAndSend()
end

function GuildCtrl:StartCountDown(delay_time)
	self.count_down = GlobalTimerQuest:AddDelayTimer(function() GuildData.Instance:SetIsCanAssistBox(true)
	if self.view then self.view:Flush() end end, delay_time)
end

function GuildCtrl:RemoveCountDown()
	if self.count_down then
		GlobalTimerQuest:CancelQuest(self.count_down)
		self.count_down = nil
	end
	if self.count_down2 then
		GlobalTimerQuest:CancelQuest(self.count_down2)
		self.count_down2 = nil
	end
end

-- 公会领地领取奖励
function GuildCtrl:SendGuildTerritoryWelfOperate(operate_type, param1)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildTerritoryWelfOperate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol:EncodeAndSend()
end

function GuildCtrl:FlushTerritort()
	if self.view then
		self.view:Flush()
	end
	local guild_id = Scene.Instance:GetMainRole().vo.guild_id
    local rank, has_territory = ClashTerritoryData.Instance:GetTerritoryRankById(guild_id)
    self.guild_data:SetTerritoryRank(rank, has_territory)
end

function GuildCtrl:FlushBonFire(openstatus)
	GuildData.Instance:SetBonFireState(openstatus)
	if openstatus == 1 then
		if self.bon_fire then
			ViewManager.Instance:Close(ViewName.Guild)
			self.bon_fire = false
			return
		end
	end
	if self.view then
		self.view:Flush()
	end
end

-- 公会篝火是否是本人开启
function GuildCtrl:SetBonFireOperation(state)
	self.bon_fire = state
end

function GuildCtrl:FlushMiJing(openstatus)
	GuildData.Instance:SetMiJingState(openstatus)
	if self.view then
		self.view:Flush()
	end
end

function GuildCtrl:SendResetNameReq(guild_id, new_name)
	if not guild_id or not new_name or new_name == "" then return end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildResetName)
	send_protocol.guild_id = guild_id
	send_protocol.new_name = new_name
	send_protocol:EncodeAndSend()
end

function string.utf8len(input)
	local len  = string.len(input)
	local left = len
	local cnt  = 0
	local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	while left ~= 0 do
		local tmp = string.byte(input, -left)
		local i   = #arr
		while arr[i] do
			if tmp >= arr[i] then
				left = left - i
				break
			end
			i = i - 1
		end
		cnt = cnt + 1
	end
	return cnt
end

-- 踢人操作
function GuildCtrl:OnClickKickout(uid, name)
    local describe = string.format(Language.Guild.KickoutMemberBundleTip1, name)
    local function yes_func()
		self:SendKickoutGuildReq(GuildDataConst.GUILDVO.guild_id, 1, {uid})
	end
    TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

-- 弹劾会长
function GuildCtrl:OnClickTransfer(uid, name)
    local describe = string.format(Language.Guild.ConfirmTransferMengZhuTip, name)
    TipsCtrl.Instance:ShowCommonAutoView("", describe,
        function()
            self:SendGuildAppointReq(GuildDataConst.GUILDVO.guild_id, uid, GuildDataConst.GUILD_POST.TUANGZHANG)
        end)
end

function GuildCtrl:OpenStationView()
	if self.guild_station_view then
		self.guild_station_view:Open()
	end
end

function GuildCtrl:CloseStationView()
	if self.guild_station_view then
		self.guild_station_view:Close()
	end
end

function GuildCtrl:OnGuildBossActivityInfo(protocol)
	GuildData.Instance:SetBossActivityInfo(protocol)
	local scene_type = Scene.Instance:GetSceneType()
 	if scene_type == SceneType.GuildStation then
 		if protocol.boss_id > 0 then
 			if self.guild_station_view and not self.guild_station_view:IsOpen() then
 				self:OpenStationView()
 			end
 		else
 			local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.GUILD_BOSS)
			if act_info then
				if act_info.status == ACTIVITY_STATUS.CLOSE then
 					self:CloseStationView()
 				end
 			else
 				self:CloseStationView()
 			end
 		end
 	end
	if self.guild_station_view then
		self.guild_station_view:Flush()
	end
end

function GuildCtrl:OnInviteNotify(protocol)
	if GameVoManager.Instance:GetMainRoleVo().guild_id > 0 then
		return
	end

	local data = {}
	data.guild_id = protocol.guild_id
	data.invite_uid = protocol.invite_uid
	data.invite_name = protocol.invite_name
	data.guild_name = protocol.guild_name
	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.GUILD_INVITE, {data})
	end
end

function GuildCtrl:OnInviteGuild(protocol)
	if protocol.ret == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.InviteSucc)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.InviteFail)
	end
end

-- 回复邀请
function GuildCtrl:OnInviteGuildAck(guild_id, invite_uid, result)
	if nil == guild_id or nil == invite_uid or nil == result then
		return
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSInviteGuildAck)
	send_protocol.guild_id = guild_id
	send_protocol.invite_uid = invite_uid
	send_protocol.result = result
	send_protocol:EncodeAndSend()
end

-- 邀请加入军团
function GuildCtrl:SendInviteGuildReq(beinvite_uid)
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if nil == beinvite_uid or guild_id <= 0 then
		return
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSInviteGuild)
	send_protocol.guild_id = guild_id
	send_protocol.beinvite_uid = beinvite_uid
	send_protocol:EncodeAndSend()
end

-- 仙盟招募请求
function GuildCtrl:SendGuildCallInReq()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id <= 0 then
		return
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildCallIn)
	send_protocol.guild_id = guild_id
	send_protocol:EncodeAndSend()
end

function GuildCtrl:OnGuildOperaSucc(protocol)
	-- 招募成功
	if protocol.opera_type == GHILD_OPERA_TYPE.OPERA_TYPE_CALL_IN then
		GuildData.Instance:SetLastCallinTime(Status.NowTime)
	end
end

function GuildCtrl:SetTerritoryInfo(data)
	if self.guild_territory_info then
		self.guild_territory_info:SetInfo(data)
		self.guild_territory_info:Open()
	end
end

-- 公会扩展成员请求
function GuildCtrl:SendGuildExtendMemberReq(operate_type, can_use_gold, num)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildExtendMemberReq)
	send_protocol.operate_type = operate_type or 0
	send_protocol.can_use_gold = can_use_gold or 0
	send_protocol.num = num or 0
	send_protocol:EncodeAndSend()
end

-- 公会当前最大成员数量
-- function GuildCtrl:OnGuildMemberNum(protocol)
-- 	GuildDataConst.GUILDVO.max_member_count = protocol.max_guild_member_num
-- 	local info = GuildData.Instance:GetGuildInfoById(GameVoManager.Instance:GetMainRoleVo().guild_id)
-- 	if info then
-- 		info.max_member_count = protocol.max_guild_member_num
-- 	end
-- 	if self.view then
-- 		self.view:Flush()
-- 	end
-- end

-- 领公会杀boss红包
function GuildCtrl:SendFetchGuildBossRedbagReq(index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFetchGuildBossRedbag)
	send_protocol.index = index or 0
	send_protocol:EncodeAndSend()
end

-- 公会复活次数信息
-- function GuildCtrl:OnGulidReliveTimes(protocol)
-- 	GuildDataConst.GUILDVO.daily_relive_times = protocol.daily_guild_all_relive_times
-- 	GuildDataConst.GUILDVO.daily_kill_boss_times = protocol.daily_guild_all_kill_boss_times
-- 	ViewManager.Instance:FlushView(ViewName.ChatGuild, "hongbao")
-- 	GuildChatData.Instance:CheckRedPoint()
-- end

-- 公会领取boss红包信息
-- function GuildCtrl:OnGulidBossRedbagInfo(protocol)
-- 	GuildData.Instance:SetDailyUseGuildReliveTimes(protocol.daily_use_guild_relive_times)
-- 	GuildData.Instance:SetDailyBossRedbagFlag(protocol.daily_boss_redbag_reward_fetch_flag)
-- 	ViewManager.Instance:FlushView(ViewName.ChatGuild, "hongbao")
-- 	GuildChatData.Instance:CheckRedPoint()
-- end

function GuildCtrl:OnGuildEventList(protocol)
	self.guild_data:SetGuildEventList(protocol)
	if self.view then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.GuildDonate)
end

function GuildCtrl:OnGuildBossEvent(protocol)
	self.guild_data:SetGuildBossEvent(protocol)
	
	if self.scene_loaded then
		GlobalEventSystem:UnBind(self.scene_loaded)
		self.scene_loaded = nil
	end
	if MainUICtrl.Instance.view then
		self:OnGuildBossBtnShow(protocol.event)
	else
		self.scene_loaded = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.OnGuildBossBtnShow, self, protocol.event))
	end
end

function GuildCtrl:OnGuildBossBtnShow(event)
	MainUICtrl.Instance:FlushView(MainUIViewChat.IconList.GUILD_BOSS, {event < 1})	
end

-- 公会日常转盘任务请求
function GuildCtrl:SendRiChangTaskRollReq(operate_type, param1)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSReqCommonOpreate)
	send_protocol.operate_type = operate_type
	send_protocol.param1 = param1 or 0
	send_protocol:EncodeAndSend()
end

function GuildCtrl:GuildRollViewOpen()
	-- if self.guild_station_view then
		self.guild_roll_view:Open()
	-- end
end


function GuildCtrl:GuildCheckDonateViewOpen()
	-- if self.guild_check_donate_view then
		self.guild_check_donate_view:Open()
	-- end
end

function GuildCtrl:ShowOpList()
	self.view:ShowOpList()
end

function GuildCtrl:FlushMemberScroller()
	self.view:FlushMemberScroller()
end

-- 修改头像
function GuildCtrl:SendSetAvatarTimeStamp(avatar_key_big, avatar_key_small)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildChangeAvatar)
	protocol.avatar_key_big = avatar_key_big
	protocol.avatar_key_small = avatar_key_small
	protocol:EncodeAndSend()
end

function GuildCtrl:OpenHighLight(Value)
	self.guild_roll_view:OpenHighLight(Value)
end

function GuildCtrl:FlushName()
	if self.boss_view:IsOpen() then
		self.boss_view:FlushName()
	end
	self.view:FlushName()
end

function GuildCtrl:OpenSigninView()
	self.guild_signin_view:Open()
end
