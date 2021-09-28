require("game/guild/guild_view")
require("game/guild/guild_boss_view")
require("game/guild/guild_apply_view")
require("game/guild/guild_data")
require("game/guild/guild_station_view")
require("game/guild/guild_territory_info_view")
require("game/guild/guild_redpacket")
require("game/guild/guild_redpacket_tips")
require("game/guild/guild_maze_reward_view")
require("game/guild/guild_signin_view")
require("game/guild/guild_view_tip")
require("game/guild/tips_guild_portrait_view")

GuildCtrl = GuildCtrl or  BaseClass(BaseController)
local old_guild_gongxian = nil
local member_full_reminder_time = 20 * 60

local GUILD_SCENE_ID = 9060

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
	self.guild_redpacket_tips = GuildRedPacketTips.New()
	self.guild_redpacket_view = GuildRedPacketView.New(ViewName.GuildRedPacket)
	self.guild_maze_reward_view = GuildMazeRewardView.New()
	self.guild_signin_view = GuildSigninView.New()
	self.guild_box_tips_view = GuildViewTips.New()
	self.guild_portrait_view = TipsGuildPortraitView.New()

	-- self.member_view = GuildApplyView.New(ViewName.GuildApply)
	self.list_view = GuildListView.New()
	self.member1_view = GuildMemberView.New()

	self.last_reminder_time = -99999
	self.maze_has_answered_list = {}
	self.clean_list = {count = 0, list = {}}

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
	self:BindGlobalEvent(OtherEventType.PASS_DAY, BindTool.Bind1(self.DayChange, self))
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.MainRoleInfo, self))

	self.item_data_change_callback = BindTool.Bind(self.OnItemChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_change_callback)
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
	self:RegisterProtocol(SCGuildMemberNum, "OnGuildMemberNum")
	self:RegisterProtocol(SCGulidReliveTimes, "OnGulidReliveTimes")
	self:RegisterProtocol(SCGulidBossRedbagInfo, "OnGulidBossRedbagInfo")
	self:RegisterProtocol(SCGuildTianCiTongBiRankInfo, "SCGuildTianCiTongBiRankInfo")
	self:RegisterProtocol(SCGuildSyncTianCiTongBi,"SCGuildSyncTianCiTongBi")
	self:RegisterProtocol(SCGuildTianCiTongBiUserGatherChange,"SCGuildTianCiTongBiUserGatherChange")
	self:RegisterProtocol(SCGuildTianCiTongBiResult,"SCGuildTianCiTongBiResult")
	self:RegisterProtocol(SCGuildTianCiTongBiNpcinfo,"SCGuildTianCiTongBiNpcinfo")
	-- self:RegisterProtocol(SCVisibleObjEnterBigCoin,"SCVisibleObjEnterBigCoin")

	--仙盟红包
	self:RegisterProtocol(SCGuildRedPocketListInfo, "OnGuildRedPocketListInfo")
	self:RegisterProtocol(SCNoticeGuildPaperInfo, "OnNoticeGuildPaperInfo")
	self:RegisterProtocol(CSGuildRedPaperListInfoReq)
	self:RegisterProtocol(CSCreateGuildRedPaperReq)
	self:RegisterProtocol(CSSingleChatRedPaperRole)
	self:RegisterProtocol(CSReplyGuildSosReq)

	-- 公会迷宫
	self:RegisterProtocol(CSGuildMazeOperate)
	self:RegisterProtocol(SCGuildMemberMazeInfo, "OnGuildMemberMazeInfo")
	self:RegisterProtocol(SCGuildMazeRankInfo, "OnGuildMazeRankInfo")

	-- 仙盟签到
	self:RegisterProtocol(CSGuildSinginReq)
	self:RegisterProtocol(SCGuildSinginAllInfo, "OnSCGuildSinginAllInfo")
end

function GuildCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.guild_redpacket_view ~= nil then
		self.guild_redpacket_view:DeleteMe()
		self.guild_redpacket_view = nil
	end

	self.guild_redpacket_tips:DeleteMe()
	self.guild_redpacket_tips = nil

	if self.boss_view ~= nil then
		self.boss_view:DeleteMe()
		self.boss_view = nil
	end

	if self.apply_view ~= nil then
		self.apply_view:DeleteMe()
		self.apply_view = nil
	end

	if self.member1_view ~= nil then
		self.member1_view:DeleteMe()
		self.member1_view = nil
	end

	if self.list_view ~= nil then
		self.list_view:DeleteMe()
		self.list_view = nil
	end

	if self.guild_signin_view ~= nil then
		self.guild_signin_view:DeleteMe()
		self.guild_signin_view = nil
	end

	if self.guild_data ~= nil then
		self.guild_data:DeleteMe()
		self.guild_data = nil
	end

	if self.guild_station_view ~= nil then
		self.guild_station_view:DeleteMe()
		self.guild_station_view = nil
	end

	if nil ~= self.guild_territory_info then
		self.guild_territory_info:DeleteMe()
		self.guild_territory_info = nil
	end

	if nil ~= self.guild_portrait_view then
		self.guild_portrait_view:DeleteMe()
		self.guild_portrait_view = nil
	end

	if self.guild_maze_reward_view then
		self.guild_maze_reward_view:DeleteMe()
	end

	if self.role_online_change then
		GlobalEventSystem:UnBind(self.role_online_change)
		self.role_online_change = nil
	end

	if self.guild_maze_time_quest then
		GlobalTimerQuest:CancelQuest(self.guild_maze_time_quest)
		self.guild_maze_time_quest = nil
	end

	self.guild_box_tips_view:DeleteMe()
	self.guild_box_tips_view = nil

	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_change_callback)
	self:RemoveCountDown()
	self:CancelQuest()
	GuildCtrl.Instance = nil
end

function GuildCtrl:ShowGuildPortraitView()
	self.guild_portrait_view:Open()
end

function GuildCtrl:OnItemChangeCallback()
	GuildChatData.Instance:CheckRedPoint()
	GuildData.Instance:CalculateRedPoint()
end

-- 关闭所有弹窗
function GuildCtrl:CloseAllWindow()
	self.view:CloseAllWindow()
end

function GuildCtrl:MainuiOpen()
	self:CancelQuest()
	self.time_quest = GlobalTimerQuest:AddRunQuest(function()
		if TimeCtrl.Instance:GetCurOpenServerDay() > 1 then
			if self.role_online_change then
				GlobalEventSystem:UnBind(self.role_online_change)
				self.role_online_change = nil
			end
			self:CancelQuest()
			return
		end
		self:CheckMemberFull()
	end, 60)
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
		self:SendGuildMazeOperate(GUILD_MAZE_OPERATE_TYPE.GUILD_MAZE_OPERATE_TYPE_GET_INFO)
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
	local vo = GameVoManager.Instance:GetMainRoleVo()
	GuildData.Instance.guild_id = vo.guild_id
	if (GuildData.Instance.guild_id <= 0) then -- 没有加入公会
		self:SendAllGuildInfoReq()
		if self.view:IsOpen() and self.view:IsLoaded() then
			self.view:InitViewCase1() --当没有加入公会时VIew面板的初始化
		end
	else
		self:SendGuildInfoReq()
		if self.view:IsOpen() and self.view:IsLoaded() then
			self.view:InitViewCase2() --当加入公会后VIew面板的初始化
		end
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

-- 获得仙盟基本信息
function GuildCtrl:OnGuildInfo(protocol)
	local guildvo = {}
	guildvo.guild_id = protocol.guild_id
	guildvo.guild_name = protocol.guild_name
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
	guildvo.is_auto_clear = protocol.is_auto_clear
	guildvo.guild_avatar_key_big = protocol.guild_avatar_key_big
	guildvo.guild_avatar_key_small = protocol.guild_avatar_key_small

	if protocol.guild_id == GameVoManager.Instance:GetMainRoleVo().guild_id then
		for k, v in pairs(guildvo) do
			GuildDataConst.GUILDVO[k] = v
		end
		GuildData.Instance:GetReminder(Guild_PANEL.totem)
		if self.view then
			self.view:Flush()
		end
		if GuildChatView.Instance:IsOpen() then
			GuildChatView.Instance:Flush("view")
		end
		AvatarManager.Instance:SetAvatarKey(protocol.guild_id, protocol.guild_avatar_key_big, protocol.guild_avatar_key_small, true)
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

	local scene_logic = Scene.Instance:GetSceneLogic()
 	if scene_logic then
 		if scene_logic:GetSceneType() == SceneType.GuildStation then
 			scene_logic:ChangeQizhi(protocol.totem_level or 0)
  		end
  	end
  	Scene.Instance:GetMainRole():ReloadGuildIcon()
  	self:CheckMemberFull()
end

-- 所有仙盟信息列表
function GuildCtrl:OnAllGuildInfoList(protocol)
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
	if self.list_view then
		self.list_view:Flush()
	end

	-- if self.member1_view then
	-- 	self.member1_view:Flush()
	-- end

	if CityCombatCtrl.Instance.view:IsOpen() then
		CityCombatCtrl.Instance.view:Flush("view")
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
	local obj = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if obj then
		obj:SetAttr("guild_name", protocol.guild_name)
		obj:SetAttr("guild_id", protocol.guild_id)
		obj:SetAttr("guild_post", protocol.guild_post)
		obj:SetAttr("last_leave_guild_time", protocol.last_leave_guild_time)
		obj:UpdateTitle()
		obj:ReloadUIGuildName()
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
			if(GuildData.Instance.guild_id ~= protocol.guild_id) then
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
					MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.GuildHongBao, {false})
				end
			end
			-- 加入公会后请求下签到信息
			GuildCtrl.Instance:SendCSGuildSinginReq(GUILD_SINGIN_REQ_TYPE.GUILD_SINGIN_REQ_ALL_INFO)
		end
	end

	if nil ~= obj and protocol.guild_id == GuildData.Instance.guild_id and protocol.guild_id ~= 0 then
		local vo = obj:GetVo()
		local role_id = vo.role_id
		local role_name = vo.name
		local post = GuildData.Instance:GetGuildPost(role_id)
		if post ~= protocol.guild_post and protocol.guild_post ~= GuildDataConst.GUILD_POST.CHENG_YUAN then
			if protocol.guild_post == GuildDataConst.GUILD_POST.TUANGZHANG then
				if self.view then
					self.view:CloseAllWindow()
				end
			end
		end
		self.guild_data:SetGuildTotalGongxian(protocol.guild_total_gongxian)
		GuildData.Instance:GetReminder(Guild_PANEL.totem)
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
	GuildCtrl.Instance:SendGuildRedPocketOperate()
end

-- 公会成员列表
function GuildCtrl:OnGuildMemberList(protocol)
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
						return GuildDataConst.GUILD_POST_WEIGHT[a.post] > GuildDataConst.GUILD_POST_WEIGHT[b.post]
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
		AvatarManager.Instance:SetAvatarFrameKey(v.uid, v.use_head_frame)
	end

	GuildData.Instance:GetReminder(Guild_PANEL.totem)

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
	self:CheckRemindMemberFull()
	GlobalEventSystem:Fire(OtherEventType.GUILD_MEMBER_INFO_CHANGE)

	--刷新职位
	if self.member1_view:IsOpen() then
		self.member1_view:Flush()
	end
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
	if(protocol.ret == 0) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.QuitGuild)
		GuildData.Instance.guild_id = 0
		Scene.Instance:GetMainRole():SetAttr("guild_id", 0)
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
		self.view:OnFlushInfo()
		self.member1_view:Flush()
		GuildChatView.Instance:Flush("view")
	end
end

-- 宝箱信息
function GuildCtrl:OnGuildBoxInfo(protocol)
	local switch = false
	self:RemoveCountDown()
	local other_config = GuildData.Instance:GetOtherConfig()
	local now_time = TimeCtrl.Instance:GetServerTime()
	if other_config then
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

		local box_start_time = other_config.box_start_time
		if now_time >= box_start_time then
			GuildData.Instance:SetGuildBoxStart(true)
		else
			GuildData.Instance:SetGuildBoxStart(false)
		end
	end

	local open_time = 0
	for k, v in ipairs(protocol.info_list) do
		if v.open_time and v.open_time > now_time then
			open_time = v.open_time
			break
		end
	end

	local cd = open_time - now_time
	if cd > 0 then
		--开始计算宝箱时间（到了发协议）
		self.count_down2 = GlobalTimerQuest:AddDelayTimer(
			function()
				self:SendGuildBoxOperateReq(GUILD_BOX_OPERATE_TYPE.GBOT_QUERY_SELF)
			end, cd + 1)
	end

	GuildData.Instance:SetBoxInfo(protocol)
	GuildData.Instance:SetIsCanAssistBox(switch)
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
	GuildData.Instance:CalculateRedPoint()
end

-- 仙盟宝箱操作
function GuildCtrl:SendGuildBoxOperateReq(operate_type, param1, param2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildBoxOperate)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 2
	send_protocol:EncodeAndSend()
end

-- 帮派求救
function GuildCtrl:SendSendGuildSosReq(sos_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendGuildSosReq)
	protocol.sos_type = sos_type
	protocol:EncodeAndSend()
end

-- 帮派求救
function GuildCtrl:OnSCGuildMemberSos(protocol)
	if protocol.member_uid == GameVoManager.Instance:GetMainRoleVo().role_id then
		SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.SosToGuildSuc)
		return
	end

	if Scene.Instance:GetSceneType() == SceneType.GongChengZhan then
		local func = function ()
			self:SendSoSReq(GUILD_SOS_TYPE.GUILD_SOS_TYPE_GONGCHENGZHAN, protocol.member_pos_x, protocol.member_pos_y)
		end
		TipsCtrl.Instance:ShowCommonAutoView("", Language.CityCombat.BeCalled, func)
		return
	end

	if Scene.Instance:GetSceneType() == SceneType.LingyuFb then
		local yes_func = function()
			self:SendSoSReq(GUILD_SOS_TYPE.GUILD_SOS_TYPE_GUILD_BATTLE, protocol.member_pos_x, protocol.member_pos_y)
			MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_GUILD)
		end

		local describe = Language.Guild.ZhaoJiText or ""
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func, nil , Language.Guild.GoText)
		return
	end


	local data = {}
	data.x = protocol.member_pos_x or 0
	data.y = protocol.member_pos_y or 0
	data.member_uid = protocol.member_uid or 0
	data.scene_id = protocol.member_scene_id or 0
	data.name = protocol.member_name or ""
	data.camp = GameVoManager.Instance:GetMainRoleVo().camp

	if Scene.Instance:GetSceneType() ~= SceneType.Common then
		return
	end

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
end

function GuildCtrl:FlushCell()
	if self.view then
		if self.view.activity_view then
			self.view.activity_view:FlushCellData()
		end
	end
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
	if 0 == protocol.ret then 						-- 0：成功 其它失败
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.AppointSuccess)
		if self.view and self.view.member_view then
			self.view.member_view.transfer_window:SetActive(false)
		end
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
	elseif protocol.notify_type == notify_type_list.GUILD_MONEY_TREE then
		self.guild_data:SendMoneyTreeIcon(1)
		MainUIView.Instance:ShowGuildMoneyTree(true)
		MainUIView.Instance:ShowGuildMoneyTreeTime()
	end
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
	if self.count_down3 then
		GlobalTimerQuest:CancelQuest(self.count_down3)
		self.count_down3 = nil
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
    GuildData.Instance:CalculateRedPoint()
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
 				self.guild_data:SendMoneyTreeState(false)
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
function GuildCtrl:OnGuildMemberNum(protocol)
	GuildDataConst.GUILDVO.max_member_count = protocol.max_guild_member_num
	local info = GuildData.Instance:GetGuildInfoById(GameVoManager.Instance:GetMainRoleVo().guild_id)
	if info then
		info.max_member_count = protocol.max_guild_member_num
	end
	if self.view then
		self.view:Flush()
	end
end

-- 领公会杀boss红包
function GuildCtrl:SendFetchGuildBossRedbagReq(index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFetchGuildBossRedbag)
	send_protocol.index = index or 0
	send_protocol:EncodeAndSend()
end

-- 公会复活次数信息
function GuildCtrl:OnGulidReliveTimes(protocol)
	GuildDataConst.GUILDVO.daily_relive_times = protocol.daily_guild_all_relive_times
	GuildDataConst.GUILDVO.daily_kill_boss_times = protocol.daily_guild_all_kill_boss_times
	ViewManager.Instance:FlushView(ViewName.ChatGuild, "hongbao")
	GuildChatData.Instance:CheckRedPoint()
end

-- 公会领取boss红包信息
function GuildCtrl:OnGulidBossRedbagInfo(protocol)
	GuildData.Instance:SetDailyUseGuildReliveTimes(protocol.daily_use_guild_relive_times)
	GuildData.Instance:SetDailyBossRedbagFlag(protocol.daily_boss_redbag_reward_fetch_flag)
	ViewManager.Instance:FlushView(ViewName.ChatGuild, "hongbao")
	GuildChatData.Instance:CheckRedPoint()
end

----------------仙盟红包-------------------
function GuildCtrl:OnGuildRedPocketListInfo(protocol)
	self.guild_data:SetRedPocketListInfo(protocol)
	self.guild_redpacket_view:Flush()
	self.guild_redpacket_tips:Flush()
	GuildData.Instance:CalculateRedPoint()
	self.view:Flush()
end

function GuildCtrl:OnNoticeGuildPaperInfo(protocol)
	GuildCtrl.Instance:SendGuildRedPocketOperate()
end

function GuildCtrl:OnGuildRedPocketDistributeInfo(protocol)
	self.guild_data:SetRedPocketDistributeInfo(protocol)
	self.guild_redpacket_tips:Flush()
end

function GuildCtrl:SendGuildRedPocketOperate()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildRedPaperListInfoReq)
	send_protocol:EncodeAndSend()
end

function GuildCtrl:SendCreateGuildRedPaperReq(paper_seq, fetech_time, index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCreateGuildRedPaperReq)
	send_protocol.paper_seq = paper_seq or 0
	send_protocol.fetech_time = fetech_time or 0
	send_protocol.red_paper_index = index or 0
	send_protocol:EncodeAndSend()
end

function GuildCtrl:SendChatRedPaperReq(index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSSingleChatRedPaperRole)
	send_protocol.red_paper_index = index or 0
	send_protocol:EncodeAndSend()
end

function GuildCtrl:SendSoSReq(sos_type, pos_x, pos_y)
	send_protocol = ProtocolPool.Instance:GetProtocol(CSReplyGuildSosReq)
	send_protocol.sos_type = sos_type or 0
	send_protocol.pos_x = pos_x or 0
	send_protocol.pos_y = pos_y or 0
	send_protocol:EncodeAndSend()
end

function GuildCtrl:DayChange()
	GuildCtrl.Instance:SendGuildRedPocketOperate()
end

function GuildCtrl:OpenGuildRedPacketView()
	if not self.guild_redpacket_tips:IsOpen() then
		self.guild_redpacket_tips:Open()
	end
end

-- 检查公会是否满员
function GuildCtrl:CheckMemberFull()
	if self:IsShouldReminderFullMember() then
		self:SendAllGuildMemberInfoReq()
	end
end

-- 是否应该提醒满员
function GuildCtrl:IsShouldReminderFullMember()
	if Scene.Instance:GetMainRole().vo.guild_id > 0 then
		-- 如果满员且是开服第一天
		if GuildDataConst.GUILDVO.cur_member_count >= GuildDataConst.GUILDVO.max_member_count then
			if TimeCtrl.Instance:GetCurOpenServerDay() <= 1 then
				local post = GuildData.Instance:GetGuildPost()
				if post == GuildDataConst.GUILD_POST.TUANGZHANG or post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
					return true
				end
			end
		end
	end
	return false
end

-- 是否主界面提示满员
function GuildCtrl:CheckRemindMemberFull()
	local flag = false
	if self:IsShouldReminderFullMember() then
		local post = GuildData.Instance:GetGuildPost()
		if post == GuildDataConst.GUILD_POST.TUANGZHANG then
			flag = true
		-- 如果是副会长且会长不在线
		elseif post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
			local info = GuildData.Instance:GetGuildMemberInfo(GuildDataConst.GUILDVO.tuanzhang_uid)
			if info then
				if info.is_online == 0 then
					flag = true
				end
			end
		end
	end
	if flag then
		if self.last_reminder_time + member_full_reminder_time <= Status.NowTime then
			self:RecordCleanList()
			if self.clean_list.count > 0 then
				self.last_reminder_time = Status.NowTime
				MainUICtrl.Instance:ChangeMainUiChatIconList(ViewName.Guild, MainUIViewChat.IconList.GuildMemberFull, true)
			end
		end
	end
end

-- 点击清除成员
function GuildCtrl:CleanFullMember()
	self.last_reminder_time = Status.NowTime
	local auto_kickout_level = GuildData.Instance:GetGuildAutoKickOutLevel()
	local str = PlayerData.GetLevelString(auto_kickout_level)
	local describe = string.format(Language.Guild.CleanMember, str)
	-- 等服务端协议
    local yes_func = function() self:SendCleanReq() end
    TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

function GuildCtrl:CancelQuest()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function GuildCtrl:CheckCleanRule(info)
	local auto_kickout_level = GuildData.Instance:GetGuildAutoKickOutLevel()
	if info.level < auto_kickout_level and info.is_online == 0 and info.post == GuildDataConst.GUILD_POST.CHENG_YUAN then
		if TimeCtrl.Instance:GetServerTime() - info.last_login_time > 1800 then
			return true
		end
	end
	return false
end

-- 记录需要清除的成员
function GuildCtrl:RecordCleanList()
	self.clean_list = {count = 0, list = {}}
	for k,v in pairs(GuildDataConst.GUILD_MEMBER_LIST.list) do
		if self:CheckCleanRule(v) then
			self.clean_list.count = self.clean_list.count + 1
			self.clean_list.list[v.uid] = 1
		end
	end
	if not self.role_online_change then
		self.role_online_change = GlobalEventSystem:Bind(OtherEventType.ROLE_ISONLINE_CHANGE, BindTool.Bind(self.RoleOnlineChange, self))
	end
end

function GuildCtrl:RoleOnlineChange(role_id, is_online)
	if self.clean_list.list[role_id] then
		self.clean_list.list[role_id] = is_online and 0 or 1
	end
end

function GuildCtrl:SendCleanReq()
	local list = {}
	for k,v in pairs(self.clean_list.list) do
		if v == 1 then
			table.insert(list, k)
		end
	end
	self:SendKickoutGuildReq(GuildDataConst.GUILDVO.guild_id, #list, list)
	self.clean_list = {count = 0, list = {}}
end

-- 公会成员迷宫信息
function GuildCtrl:OnGuildMemberMazeInfo(protocol)
	GuildData.Instance:SetMazeInfo(protocol)
	RemindManager.Instance:Fire(RemindName.GuildMaze)
	GuildData.Instance:CalculateRedPoint()
	if self.count_down3 then
		GlobalTimerQuest:CancelQuest(self.count_down3)
		self.count_down3 = nil
	end
	if protocol.complete_time <= 0 then
		local cd = GuildData.Instance:GetMazeAnswerCD()
        if cd > 0 then
        	self.count_down3 = GlobalTimerQuest:AddDelayTimer(function()
        	 	self:SendGuildMazeOperate(GUILD_MAZE_OPERATE_TYPE.GUILD_MAZE_OPERATE_TYPE_GET_INFO)
        	end, cd + 1)
        end
    end
	self.view:Flush()
end

-- 公会迷宫排行信息
function GuildCtrl:OnGuildMazeRankInfo(protocol)
	GuildData.Instance:SetMazeRankInfo(protocol)
	self.view:Flush()
end

-- 公会迷宫操作
function GuildCtrl:SendGuildMazeOperate(operate_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildMazeOperate)
	protocol.operate_type = operate_type or 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

-- 公会迷宫回答
function GuildCtrl:SendGuildMazeAnswer(param1, param2, param3)
	if not self.maze_has_answered_list[param3] then
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, string.format(Language.Guild.MazeChose, param1, param2), CHAT_CONTENT_TYPE.TEXT)
		self.maze_has_answered_list[param3] = true
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.MazeHasAnswered)
	end
end

-- 公会迷宫回排名奖励面板
function GuildCtrl:OpenGuildMazeRankRewardView()
	self.guild_maze_reward_view:Open()
end

-- 自动清理3天不在线玩家
function GuildCtrl:SendGuildSetAutoClearReq(is_auto_clear, reserve)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildSetAutoClearReq)
	protocol.is_auto_clear = is_auto_clear or 0
	protocol.reserve = reserve or 0
	protocol:EncodeAndSend()
end

-- 打开公会列表
function GuildCtrl:OpenListView()
	if self.list_view then
		self.list_view:Open()
	end
end

function GuildCtrl:OpenMeberView()
	if self.member1_view then
		self.member1_view:Open()
	end
end

function GuildCtrl:ShowGuildBoxTipView(auto_str, des, ok_callback, cancel_callback, show_red_tip, ok_des, canel_des, the_red_text, is_special, is_on, uplevelpay_text, is_show_uplevelpay_text)
	auto_str = auto_str or ""
	local auto_view_str = self.guild_box_tips_view.auto_view_str
	local is_show = true
	if nil ~= is_on then
		is_show = is_on
	end
	if (self.guild_box_tips_view.is_auto and auto_str ~= "" and auto_str == auto_view_str) or TipsCommonAutoView.AUTO_VIEW_STR_T[auto_str] then
		if ok_callback then
			ok_callback(true)
		end
	else
		-- if auto_str ~= "" then
		-- 	self.guild_box_tips_view:SetShowAutoBuy(true)
		-- 	self.guild_box_tips_view:SetAutoStr(auto_str)		-- 替换自动购买唯一标示
		-- else
		-- 	self.guild_box_tips_view:SetShowAutoBuy(false)
		-- end
		self.guild_box_tips_view:SetShowRedTip(show_red_tip and true or false)
		self.guild_box_tips_view:SetDes(des)
		self.guild_box_tips_view:SetIsSpecial(is_special)
		self.guild_box_tips_view:SetOkCallBack(ok_callback)
		self.guild_box_tips_view:SetCanelCallBack(cancel_callback)
		self.guild_box_tips_view:SetBtnDes(ok_des, canel_des)
		self.guild_box_tips_view:SetRedText(the_red_text)
		self.guild_box_tips_view:SetToggleIsOn(is_show)
		self.guild_box_tips_view:SetIsShowPayText(is_show_uplevelpay_text)
		self.guild_box_tips_view:SetUplevelPayText(uplevelpay_text)
		self.guild_box_tips_view:Open()
	end
end

-- 签到
function GuildCtrl:OnSCGuildSinginAllInfo(protocol)
	-- 签到成功发一天文字
	-- local signin_data = self.guild_data:GetSigninData()
	-- if signin_data.is_signin_today == 0 and protocol.is_signin_today == 1 then
	-- 	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	-- 	local main_role_name = main_vo.name
	-- 	local signin_cfg = self.guild_data:GetSigninCfg()
	-- 	local last_data_cfg = signin_cfg[#signin_cfg] or {}
	-- 	local signin_limit = last_data_cfg.need_count or 15
	-- 	local text = string.format(Language.Chat.GuildSigninText, main_role_name, protocol.guild_signin_count_today, signin_limit)
	-- 	ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, text, CHAT_CONTENT_TYPE.TEXT)
	-- end
	self.guild_data:SetSigninData(protocol)
	self.guild_signin_view:Flush()

	RemindManager.Instance:Fire(RemindName.GuildSignin)
	GuildChatView.Instance:Flush("view")

	-- 签到后请求下仙盟成员信息
	GuildCtrl.Instance:SendAllGuildMemberInfoReq()
end

-- 签到请求
function GuildCtrl:SendCSGuildSinginReq(req_type, param1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildSinginReq)
	protocol.req_type = req_type or 0
	protocol.param1 = param1 or 0
	protocol:EncodeAndSend()
end

function GuildCtrl:OpenSigninView()
	self.guild_signin_view:Open()
end

-- 修改头像
function GuildCtrl:SendSetAvatarTimeStamp(avatar_key_big, avatar_key_small)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildChangeAvatar)
	protocol.avatar_key_big = avatar_key_big
	protocol.avatar_key_small = avatar_key_small
	protocol:EncodeAndSend()
end
-- 迷宫红点计时器
function GuildCtrl:GuildMazeTimeQuest()
	self.guild_data.guild_maze_remind = true
	RemindManager.Instance:Fire(RemindName.GuildMaze)
	self.view:FlushRedPoint()
	self.guild_maze_time_quest = nil
end

function GuildCtrl:StartGuildMazeTimeQuest()
	if not self.guild_maze_time_quest then
		self.guild_maze_time_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.GuildMazeTimeQuest, self), 10 * 60)  --10分钟后提醒
	end
end

function GuildCtrl:FlushGuildWarView()
	if self.view:IsOpen() then
		self.view:Flush("guild_war")
		self.view:FlushRedPoint()
	end
end

function GuildCtrl:SCGuildTianCiTongBiRankInfo(protocol)
	local scene_type = Scene.Instance:GetSceneType()
	self.guild_data:SendRankInfo(protocol)
	self.guild_data:SendMoneyTreeState(true)

	if self.guild_station_view:IsOpen() then
		self.guild_station_view:Flush()
	elseif scene_type == SceneType.GuildStation then
		self:OpenStationView()
	end

	FuBenCtrl.Instance:FlushGuildBossButton()
	FuBenCtrl.Instance:SendMoneyTreeTime()
	MainUIView.Instance:ShowGuildMoneyTree(true)
	self.guild_data:SendMoneyTreeIcon(1)
	MainUIView.Instance:ShowGuildMoneyTreeTime()
end

function GuildCtrl:SCGuildTianCiTongBiResult(protocol)
	self.guild_data:SendMoneyTreeState(false)
	self.guild_data:SendMoneyTreeReward(protocol)
	TipsCtrl.Instance:OpenMoneyTreeRewardTip()
	self:CloseStationView()
	self.guild_data:ClsoeMoneyTreeModel()
	MainUIView.Instance:ShowGuildMoneyTree(false)
end

function GuildCtrl:SCGuildSyncTianCiTongBi(protocol)
	self.guild_data:SendMoneyTreeIcon(protocol.is_open)
end

function GuildCtrl:SCGuildTianCiTongBiUserGatherChange(protocol)
	local scene_type = Scene.Instance:GetSceneType()
	self.guild_data:SendMoneyTreeInfo(protocol)
	self.guild_data:SendMoneyTreeGatherState(protocol.gather_type)

	if scene_type == SceneType.GuildStation then
		if protocol.gather_num == protocol.tianci_tongbi_max_gather_num and protocol.gather_type == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.FlushMoneyTreeTips)
		end
	end

	if self.guild_station_view:IsOpen() then
		self.guild_station_view:Flush()
	end
end

function GuildCtrl:SCGuildTianCiTongBiNpcinfo(protocol)
	self.guild_data:SendMoneyTreePosInfo(protocol)
	FuBenCtrl.Instance:SendMoneyTreeTime()
end

function GuildCtrl:SendTianCiTongBiGather()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildTianCiTongBiUseGather)
	protocol:EncodeAndSend()
end

function GuildCtrl:OpenGuildMoneyTree(guild_id, role_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildTianCiTongBiReq)
	protocol.guild_id = guild_id
	protocol.role_id = role_id
	protocol:EncodeAndSend()
end

function GuildCtrl:GoToMoneyTree()
	self.guild_data:MoveToMoneyTree()
end

function GuildCtrl:MoveToTreeState(state)
	self.guild_station_view:MoveToTreeState(state)
end