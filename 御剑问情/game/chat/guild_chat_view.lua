require("game/chat/chat_guild_view")
require("game/chat/guild_rank_cell")
require("game/chat/guild_member_cell")
require("game/chat/guild_pawn_rank_cell")
require("game/chat/chat_target_item_cell")
require("game/chat/team_member_cell")

GUILD_TOP_TOGGLE_NAME = {
	SHAI_ZI = 1,
	QUESTION = 2,
}

GuildChatView = GuildChatView or BaseClass(BaseView)

local OperaCount = 6		 --聊天操作按钮最大个数
local ANSWER_TIME_LIMIT = 5  --剩余5s答题则不打开界面
local UILayer = GameObject.Find("GameRoot/UILayer")

local FIX_EXIT_TIME = 3

function GuildChatView:__init()
	GuildChatView.Instance = self
	self.ui_config = {"uis/views/chatview_prefab", "ChatGuildView"}
end

function GuildChatView:__delete()
	GuildChatView.Instance = nil
end

function GuildChatView:ReleaseCallBack()
	if self.guild_view then
		self.guild_view:DeleteMe()
		self.guild_view = nil
	end

	if self.chat_measuring then
		GameObject.Destroy(self.chat_measuring.root_node.gameObject)
		self.chat_measuring:DeleteMe()
		self.chat_measuring = nil
	end

	if self.voice_switch then
		GlobalEventSystem:UnBind(self.voice_switch)
		self.voice_switch = nil
	end

	for k, v in pairs(self.activity_cell_list) do
		v:DeleteMe()
	end
	self.activity_cell_list = {}

	for k, v in pairs(self.member_list_view) do
		v:DeleteMe()
	end
	self.member_list_view = {}

	for k, v in pairs(self.pwan_score_list_view) do
		v:DeleteMe()
	end
	self.pwan_score_list_view = {}

	self.red_point_list = {}

	if RemindManager.Instance and self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	for _, v in pairs(self.static_cell_list) do
		v:DeleteMe()
	end
	self.static_cell_list = {}

	for _, v in pairs(self.dynamic_cell_list) do
		v:DeleteMe()
	end
	self.dynamic_cell_list = {}

	for k,v in pairs(self.guild_rank_cell_list) do
		v:DeleteMe()
	end
	self.guild_rank_cell_list = {}

	for k, v in pairs(self.team_cell_list) do
		v:DeleteMe()
	end
	self.team_cell_list = {}

	for i=1,2 do
		self.answer_list[i].answer_text = nil
		self.answer_list[i].answer_right = nil
		self.answer_list[i].show_answer = nil
		self.answer_list[i] = {}
	end
	self.answer_list = {}

	for i=1,2 do
		self.top_toggle_list[i] = nil
		self.top_toggle_hl_list[i] = nil
	end
	self.top_toggle_hl_list = {}

	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end

	self:StopPawnTimes()

	if self.delay_shou_qipao then
		GlobalTimerQuest:CancelQuest(self.delay_shou_qipao)
		self.delay_shou_qipao = nil
	end

	-- 清理变量和对象
	self.button_text = nil
	self.is_send_cool = nil
	self.chat_input = nil
	self.tips_pop_bt = nil
	self.activitty_scroller_list_view = nil
	self.member_scroller_list_view = nil
	self.show_cool_chat_red_point = nil

	self.guild_pawn_text = nil
	self.add_friend_text = nil
	self.normal_img_res = nil
	self.raw_image = nil
	self.show_normal_img = nil
	self.role_level = nil
	self.role_prof = nil
	self.pawn_rank_list = nil
	self.rank_list = nil
	self.pwan_rank_list_view = nil
	self.play_pawn_btn = nil
	self.play_pawn_red_point = nil
 	self.RoleName = nil
 	self.RoleRank = nil
 	self.RoleCount = nil
 	self.flower_img_pawn = nil
 	self.item_text_pawn = nil
	self.show_guild_question = nil
	self.question_title = nil
	self.time_text = nil
	self.TimePawnText = nil
	self.ShowTisPawn = nil
	self.is_leader = nil
	self.can_enter_member_count = nil
	self.add_exp = nil
	self.channel_type = nil
	self.team_member_list = nil
	self.show_signin_red_point = nil
	self.is_open_maze = nil
	self.can_pawn_remind = nil
	self.is_kuafu = nil
	self.dynamic_list = nil
	self.dynamic_list_view = nil
	self.static_list = nil
	self.static_list_view = nil
	self.target_list_content = nil
	self.have_guild = nil
	self.show_speaker = nil
	self.head_frame_res = nil
	self.show_default_frame = nil
end

function GuildChatView:LoadCallBack()
	self.select_dynamic_index = 1
	self.record_top_toggle_state = {}
	-- 变量
	self.button_text = self:FindVariable("ButtonText")
	self.is_send_cool = self:FindVariable("IsSendCool")
	self.add_friend_text = self:FindVariable("AddFriendText")
	self.role_level = self:FindVariable("RoleLevel")
	self.role_prof = self:FindVariable("RoleProf")
	self.pawn_rank_list = self:FindVariable("PawnRankList")
	self.rank_list = self:FindVariable("RankList")
	self.guild_pawn_text = self:FindVariable("GuildPawnText")
 	self.play_pawn_btn = self:FindVariable("PlayPawnBtnBool")
 	self.play_pawn_red_point = self:FindVariable("PlayPawnRedPoint")
 	self.RoleName = self:FindVariable("RoleName")
 	self.RoleRank = self:FindVariable("RoleRank")
 	self.RoleCount = self:FindVariable("RoleCount")
 	self.flower_img_pawn = self:FindVariable("flower_img_pawn")
 	self.item_text_pawn = self:FindVariable("item_text_pawn")
 	self.TimePawnText = self:FindVariable("TimePawnText")
 	self.ShowTisPawn = self:FindVariable("ShowTisPawn")
 	self.is_leader = self:FindVariable("IsLeader")
 	self.is_kuafu = self:FindVariable("IsKuaFu")
 	self.can_enter_member_count = self:FindVariable("CanEnterMemberCount")
 	self.add_exp = self:FindVariable("AddExp")
 	self.channel_type = self:FindVariable("ChannelType")					--聊天频道
 	self.show_signin_red_point = self:FindVariable("ShowSigninRedPoint")	-- 签到小红点
 	self.is_open_maze = self:FindVariable("GuildMazeIsOpen")		-- 迷宫功能开启
 	self.have_guild = self:FindVariable("HaveGuild")				-- 是否有仙盟
 	self.show_speaker = self:FindVariable("ShowSpeaker")

 	--self.can_pawn_remind = self:FindVariable("CanPawnRemind")
	--公会答题
	self.show_guild_question = self:FindVariable("ShowGuildQuestion")
	self.question_title = self:FindVariable("GuildQuestionTitle")
	self.time_text = self:FindVariable("TimeText")
	self.answer_list = {}
	for i=1,2 do
		self.answer_list[i] = {}
		self.answer_list[i].answer_text = self:FindVariable("AnswerText" .. i)
		self.answer_list[i].answer_right = self:FindVariable("AnswerRight" .. i)  --是否正确
		self.answer_list[i].show_answer = self:FindVariable("ShowAnswer" .. i) 	--显示 正确与错误图标
		self:ListenEvent("answer_click" .. i, BindTool.Bind2(self.OnAnswerClick, self, i))
	end

	--头像
	self.raw_image = self:FindObj("RawImage")
	self.normal_img_res = self:FindVariable("ImgRes")
	self.show_normal_img = self:FindVariable("ShowImage")
	self.head_frame_res = self:FindVariable("head_frame_res")
	self.show_default_frame = self:FindVariable("show_default_frame")

	-- 查找组件
	self.chat_input = self:FindObj("ChatInput")
	self.tips_pop_bt = self:FindObj("tips_pop_bt")
	self.guild_rank_cell_list = {}
	for i=1,4 do
		self.guild_rank_cell_list[i] = GuildRankCell.New(self:FindObj("Rank"..i), self)
		self.guild_rank_cell_list[i]:SetIndex(i)
	end

	self.top_toggle_list = {}
	self.top_toggle_hl_list = {}
	for i=1,2 do
		self.top_toggle_list[i] = self:FindObj("GuildToggle"..i)
		self.top_toggle_hl_list[i] = self:FindVariable("toggle_hl_"..i)
	end

	--总消息列表
	self.normal_chat_list = ChatData.Instance:GetNormalChatList()

	--左边静态聊天对象列表
	self.static_list = self:FindObj("StaticList")
	self.static_list_width = self.static_list.rect.rect.width
	self.static_list_data = {}
	self.static_list_view = self:FindObj("StaticListView")
	self.static_cell_list = {}
	local list_delegate = self.static_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetStaticTargetNum, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.StaticListRefreshCell, self)

	--左边动态聊天对象列表
	self.dynamic_list = self:FindObj("DynamicList")
	self.dynamic_list_width = self.dynamic_list.rect.rect.width
	self.dynamic_list_data = {}
	self.dynamic_list_view = self:FindObj("RoleList")
	self.dynamic_cell_list = {}
	list_delegate = self.dynamic_list_view.list_simple_delegate
	self.dynamic_cell_height = list_delegate:GetCellViewSize(self.dynamic_list_view.scroller, 0)					--单个cell的大小（根据排列顺序对应高度或宽度）
	self.dynamic_list_view_spacing = self.dynamic_list_view.scroller.spacing										--间距
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetDynamicTargetNum, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.DynamicListRefreshCell, self)

	self.target_list_content = self:FindObj("TargetListContent")

	--队伍列表
	self.team_member_list = self:FindObj("TeamMemberList")
	self.team_cell_list = {}
	self.team_data = {}
	local team_simple_delegate = self.team_member_list.list_simple_delegate
	team_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetTeamMemberNum, self)
	team_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTeamMenberList, self)

	-- 监听UI事件
	self:ListenEvent("Close",
		BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("OpenItem",
		BindTool.Bind(self.HandleOpenItem, self))
	self:ListenEvent("InsertLocation",
		BindTool.Bind(self.HandleInsertLocation, self))
	self:ListenEvent("VoiceStart",
		BindTool.Bind(self.HandleVoiceStart, self))
	self:ListenEvent("VoiceStop",
		BindTool.Bind(self.HandleVoiceStop, self))
	self:ListenEvent("OpenEmoji",
		BindTool.Bind(self.HandleOpenEmoji, self))
	self:ListenEvent("Send",
		BindTool.Bind(self.HandleSend, self))
	self:ListenEvent("TipsPopClick",
		BindTool.Bind(self.OnTipsPopClick, self))
	self:ListenEvent("OpenCoolShop",
		BindTool.Bind(self.GoCoolShop, self))
	self:ListenEvent("FriendClick",
		BindTool.Bind(self.FriendClick, self))
	self:ListenEvent("TeamClick",
		BindTool.Bind(self.TeamClick, self))
	self:ListenEvent("CheckClick",
		BindTool.Bind(self.CheckClick, self))
	self:ListenEvent("TradeClick",
		BindTool.Bind(self.TradeClick, self))
	self:ListenEvent("BlackClick",
		BindTool.Bind(self.BlackClick, self))
	self:ListenEvent("TrackClick",
		BindTool.Bind(self.TrackClick, self))
	self:ListenEvent("PlayPawn",
		BindTool.Bind(self.PlayPawn, self))
	self:ListenEvent("ClickQuick",
		BindTool.Bind(self.ClickQuick, self))
	self:ListenEvent("ClickLeaveTeam",
		BindTool.Bind(self.ClickLeaveTeam, self))
	self:ListenEvent("ClickInvite",
		BindTool.Bind(self.ClickInvite, self))
	self:ListenEvent("OnClickSignin",
		BindTool.Bind(self.OnClickSignin, self))
	self:ListenEvent("OpenGuildMaze",
		BindTool.Bind(self.OpenGuildMaze, self))
	self:ListenEvent("OpenWantEquip",
		BindTool.Bind(self.OpenWantEquip, self))
	self:ListenEvent("OpenMarket",
		BindTool.Bind(self.OpenMarket, self))
	for i=1,2 do
		self:ListenEvent("AnswerClick" .. i,
		 BindTool.Bind2(self.OnAnswerClick, self, i))
		self:ListenEvent("TopTab" .. i,
		 BindTool.Bind2(self.OnTopTabClick, self, i))
	end
	self.guild_view = ChatGuildView.New(self:FindObj("ContentGuild"))

	self.red_point_list = {
		[RemindName.CoolChat] = self:FindVariable("ShowCoolChatRedPoint"),
		[RemindName.GuildMaze] = self:FindVariable("ShowGuildMazeRedPoint"), -- 迷宫小红点
	}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self.voice_switch = GlobalEventSystem:Bind(ChatEventType.VOICE_SWITCH,
		BindTool.Bind(self.UpdateVoiceSwitch, self))

	-- 活动list
	self.activity_cell_list = {}

	-- 成员list
	self.member_list_view = {}

	-- 骰子积分list
	self.pwan_score_list_view = {}

	self.max_boss_count = GuildData.Instance:GetMaxGuildBossCount()
	if nil == self.max_boss_count or self.max_boss_count <= 0 then
		self.max_boss_count = 1
	end
	self.percent = 1 / self.max_boss_count
	self:InitMemberListView()
	self:InitPawnListView()
	self:FlushCanPawnNextTime()
	self:UpdateVoiceSwitch()
end

function GuildChatView:OpenCallBack()
	self.open_trigger = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
	--把主界面私聊头像隐藏
	ChatData.Instance:SetHavePriviteChat(false)
	MainUICtrl.Instance.view:Flush("privite_visible", {false})

	self.button_text:SetValue(Language.Guild.Send)
	if not IS_ON_CROSSSERVER then
		GuildCtrl.Instance:SendGuildInfoReq()
		GuildCtrl.Instance:SendAllGuildMemberInfoReq()
	end
	MainUICtrl.Instance.view:Flush("show_guildchat_redpt", {false})
	RemindManager.Instance:Fire(RemindName.CoolChat)

	self:FlushSelectTarget(true)

	--监听好友列表改变
	self.friend_callback = GlobalEventSystem:Bind(OtherEventType.FRIEND_INFO_CHANGE, BindTool.Bind(self.FriendListChange, self))

	--监听黑名单列表变化
	self.black_callback = GlobalEventSystem:Bind(OtherEventType.BLACK_LIST_CHANGE, BindTool.Bind(self.BlackListChange, self))

	--监听特殊聊天对象变化
	self.special_change_callback = GlobalEventSystem:Bind(ChatEventType.SPECIAL_CHAT_TARGET_CHANGE, BindTool.Bind(self.SpecialTargetChange, self))

	--停止主界面聊天按钮抖动效果
	MainUICtrl.Instance:GetView():ShakeGuildChatBtn(false)
	self:ShowOrHideTab()
end

-- function GuildChatView:PlayerDataChangeCallback(attr_name, value, old_value)
-- 	if attr_name == "level" then
-- 		self.can_pawn_remind:SetValue(value >= 150)
-- 	end
-- end

function GuildChatView:ShowOrHideTab()
	local maze_is_open = OpenFunData.Instance:CheckIsHide("guild_maze")
	self.is_open_maze:SetValue(maze_is_open)
end

function GuildChatView:CloseCallBack()
	self:UnBindFriend()
	self:UnBindBlack()
	self:UnBindSpecialTarget()
	if nil ~= self.dynamic_cell_list then
		for _, v in pairs(self.dynamic_cell_list) do
			v:UnBindIsOnlineEvent()
			v:UnBindRemind()
		end
	end

	if nil ~= self.static_cell_list then
		for _, v in pairs(self.static_cell_list) do
			v:UnBindIsOnlineEvent()
			v:UnBindRemind()
		end
	end

	self:CancelQuestionCountDown()
	local guild_result_list = WorldQuestionData.Instance:GetGuildResultList()
	if guild_result_list and next(guild_result_list) then
		WorldQuestionData.Instance:ClearGuildList()
	end

	if self.open_trigger then
		GlobalEventSystem:UnBind(self.open_trigger)
		self.open_trigger = nil
	end

	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function GuildChatView:GetTeamMemberNum()
	return #self.team_data
end

function GuildChatView:RefreshTeamMenberList(cell, data_index)
	data_index = data_index + 1
	local member_cell = self.team_cell_list[cell]
	if nil == member_cell then
		member_cell = ChatTeamMemberCell.New(cell.gameObject)
		member_cell:SetToggleGroup(self.team_member_list.toggle_group)
	end
	member_cell:SetIndex(data_index)
	member_cell:SetData(self.team_data[data_index])
end

function GuildChatView:FlushTeamList(is_init)
	if self.team_member_list.scroller.isActiveAndEnabled then
		if is_init then
			self.team_member_list.scroller:ReloadData(0)
		else
			self.team_member_list.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

--设置选择的对象位置
function GuildChatView:RefreshDynamicSelectIndex()
	self.select_dynamic_index = 1

	local current_id = ChatData.Instance:GetCurrentId()
	for k, v in ipairs(self.dynamic_list_data) do
		if v.role_id == current_id then
			self.select_dynamic_index = k
			break
		end
	end
end

--刷新选择的对象
function GuildChatView:FlushSelectTarget(is_init, n_channel_type)
	--如果没有任何聊天对象则关闭界面
	self.normal_chat_list = ChatData.Instance:GetNormalChatList()
	if #self.normal_chat_list <= 0 then
		ChatData.Instance:SetCurrentId(-1)
		self:Close()
		return
	end

	local current_id = ChatData.Instance:GetCurrentId()
	local t_channel_type = self.guild_view:GetChannelType()

	--判断该聊天对象是否有效
	local target_data = ChatData.Instance:GetTargetDataByRoleId(current_id)
	if nil == target_data then
		--重新选择第一个聊天对象
		current_id = self.normal_chat_list[1].role_id
		--记录当前聊天对象
		ChatData.Instance:SetCurrentId(current_id)
	end
	self.channel_type:SetValue(current_id)

	self.have_guild:SetValue(ChatData.Instance:GetTargetDataByRoleId(SPECIAL_CHAT_ID.GUILD) ~= nil)

	--重新获取静态列表数据
	self.static_list_data = ChatData.Instance:GetStaticChatList()

	--刷新静态列表
	self:FlushStaticListView()

	--重新获取动态列表数据
	self.dynamic_list_data = ChatData.Instance:GetDynamicChatList()

	--刷新动态列表选中index
	self:RefreshDynamicSelectIndex()

	--改变左边列表的高度
	self:ChangeListHeight()

	if is_init or nil == target_data then
		self:StopPawnTimes()
		local channel_type = CHANNEL_TYPE.GUILD
		if current_id == SPECIAL_CHAT_ID.GUILD then
			ChatData.Instance:ClearGuildUnreadMsg()
			ChatData.Instance:SetNewLockState(false)

			self:Flush("guild_answer")
			self:Flush("guild_question_rank")
			self:StartPawnTimes()
			self:FlushPawnScoreView()
			self:SetTopToggleIsOn(1, true)
		elseif current_id == SPECIAL_CHAT_ID.TEAM then
			channel_type = CHANNEL_TYPE.TEAM
			ChatData.Instance:ClearTeamUnreadMsg()
			ChatData.Instance:SetNewLockState(false)

			self.ShowTisPawn:SetValue(false)
			self:FlushTeamView(true)
		else
			channel_type = CHANNEL_TYPE.PRIVATE
			ChatData.Instance:RemPrivateUnreadMsg(current_id)
			self.ShowTisPawn:SetValue(false)
			self:FlushPriviteRoleInfo()
		end
		--刷新聊天信息
		self:FlushChatList(channel_type)

		self:InitDynamicListView()
	else
		self:FlushDynamicListView()
		if t_channel_type == n_channel_type then
			self:FlushChatList()

			--私聊直接清除对应未读消息
			if n_channel_type == CHANNEL_TYPE.PRIVATE then
				ChatData.Instance:RemPrivateUnreadMsg(current_id)
			end
		end
	end

	self:FlushAllRemind()
end

function GuildChatView:ChangeListHeight()
	local static_list_height = #self.static_list_data * (self.dynamic_cell_height + self.dynamic_list_view_spacing)
	self.static_list.rect.sizeDelta = Vector2(self.static_list_width, static_list_height)
	--强制刷新
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.static_list.rect)

	local dynamic_list_height = self.target_list_content.rect.rect.height - static_list_height
	self.dynamic_list.rect.sizeDelta = Vector2(self.dynamic_list_width, dynamic_list_height)
	--强制刷新
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.dynamic_list.rect)
end

function GuildChatView:FlushAllRemind()
	for _, v in pairs(self.static_cell_list) do
		v:FlushRemind()
	end

	for _, v in pairs(self.dynamic_cell_list) do
		v:FlushRemind()
	end
end

function GuildChatView:GetStaticTargetNum()
	return #self.static_list_data
end

function GuildChatView:StaticListRefreshCell(cell, data_index)
	data_index = data_index + 1
	local static_cell = self.static_cell_list[cell]
	if nil == static_cell then
		static_cell = ChatTargetItem.New(cell.gameObject)
		static_cell.root_node.toggle.group = self.target_list_content.toggle_group
		static_cell:SetClickCallBack(BindTool.Bind(self.TargetCellClick, self))
		self.static_cell_list[cell] = static_cell
	end

	static_cell:SetIndex(data_index)

	local data = self.static_list_data[data_index]

	local current_id = ChatData.Instance:GetCurrentId()

	--设置高亮展示
	local role_id = data.role_id
	if role_id == current_id then
		static_cell:SetToggleIsOn(true)
	else
		static_cell:SetToggleIsOn(false)
	end

	static_cell:SetData(data)

	static_cell:FlushRemind()

	static_cell:UnBindIsOnlineEvent()
end

function GuildChatView:GetDynamicTargetNum()
	return #self.dynamic_list_data
end

function GuildChatView:DynamicListRefreshCell(cell, data_index)
	data_index = data_index + 1
	local target_cell = self.dynamic_cell_list[cell]
	if nil == target_cell then
		target_cell = ChatTargetItem.New(cell.gameObject)
		target_cell.root_node.toggle.group = self.target_list_content.toggle_group
		target_cell:SetClickCallBack(BindTool.Bind(self.TargetCellClick, self))
		self.dynamic_cell_list[cell] = target_cell
	end

	target_cell:SetIndex(data_index)

	local data = self.dynamic_list_data[data_index]

	local current_id = ChatData.Instance:GetCurrentId()

	--设置高亮展示
	local role_id = data.role_id
	if role_id == current_id then
		target_cell:SetToggleIsOn(true)
	else
		target_cell:SetToggleIsOn(false)
	end

	target_cell:SetData(data)

	target_cell:FlushRemind()

	target_cell:UnBindIsOnlineEvent()
	target_cell:BindIsOnlineEvent()
end

--点击聊天对象后回调
function GuildChatView:TargetCellClick(cell)
	local data = cell:GetData()
	if not data then
		return
	end

	cell.root_node.toggle.isOn = true

	local current_id = ChatData.Instance:GetCurrentId()
	if current_id == data.role_id then
		return
	end

	current_id = data.role_id

	--记录聊天id
	ChatData.Instance:SetCurrentId(current_id)
	self:RefreshDynamicSelectIndex()
	self.channel_type:SetValue(current_id)

	self:StopPawnTimes()
	local channel_type = CHANNEL_TYPE.GUILD
	if current_id == SPECIAL_CHAT_ID.GUILD then
		ChatData.Instance:ClearGuildUnreadMsg()
		ChatData.Instance:SetNewLockState(false)

		self:Flush("guild_answer")
		self:Flush("guild_question_rank")
		self:StartPawnTimes()
		self:FlushPawnScoreView()
		self:SetTopToggleIsOn(1, true)
	elseif current_id == SPECIAL_CHAT_ID.TEAM then
		channel_type = CHANNEL_TYPE.TEAM
		ChatData.Instance:ClearTeamUnreadMsg()
		ChatData.Instance:SetNewLockState(false)
		self.ShowTisPawn:SetValue(false)

		self:FlushTeamView(true)
	else
		channel_type = CHANNEL_TYPE.PRIVATE
		ChatData.Instance:RemPrivateUnreadMsg(current_id)
		self.ShowTisPawn:SetValue(false)

		self:FlushPriviteRoleInfo()
	end

	cell:FlushRemind()

	--刷新聊天信息
	self:FlushChatList(channel_type)
end

function GuildChatView:FlushStaticListView()
	self.static_list_view.scroller:ReloadData(0)
end

function GuildChatView:InitDynamicListView()
	local list_view_height = self.dynamic_list.rect.rect.height
	local max_hight = (self.dynamic_cell_height + self.dynamic_list_view_spacing) * #self.dynamic_list_data - self.dynamic_list_view_spacing
	local not_see_height = math.max(max_hight - list_view_height, 0)
	local bili = 0
	if not_see_height > 0 then
		bili = math.min(((self.dynamic_cell_height + self.dynamic_list_view_spacing) * (self.select_dynamic_index - 1)) / not_see_height, 1)
	end
	self.dynamic_list_view.scroller:ReloadData(bili)
end

function GuildChatView:CountDown(elapse_time, total_time)
	self.time_text:SetValue(total_time - elapse_time)
	if elapse_time >= total_time then
		self.show_guild_question:SetValue(false)
	end
end

function GuildChatView:UnBindFriend()
	if self.friend_callback then
		GlobalEventSystem:UnBind(self.friend_callback)
		self.friend_callback = nil
	end
end

function GuildChatView:UnBindBlack()
	if self.black_callback then
		GlobalEventSystem:UnBind(self.black_callback)
		self.black_callback = nil
	end
end

function GuildChatView:UnBindSpecialTarget()
	if self.special_change_callback then
		GlobalEventSystem:UnBind(self.special_change_callback)
		self.special_change_callback = nil
	end
end

function GuildChatView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function GuildChatView:OnTipsPopClick()
	GuildChatData.Instance:SetIsHidePopRect(self.tips_pop_bt.toggle.isOn)
end

function GuildChatView:GoCoolShop()
	ViewManager.Instance:Open(ViewName.CoolChat)
end

function GuildChatView:FlushShowTips(is_show)

end

--刷新聊天对象列表
function GuildChatView:FlushDynamicListView()
	if self.dynamic_list_view.scroller.isActiveAndEnabled then
		self.dynamic_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function GuildChatView:FlushMemberList()
	if self.member_scroller_list_view.scroller.isActiveAndEnabled then
		self.member_scroller_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function GuildChatView:FlushPawnScoreView()
	if self.pwan_rank_list_view.scroller.isActiveAndEnabled then
		self.pwan_rank_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self:OnFlushPawnTime()
	self:FlushRolePwanPank()
end
function GuildChatView:GetChatMeasuring(delegate)
	if not delegate then
		return
	end
	if not self.chat_measuring then
		local cell = delegate:CreateCell()
		cell.transform:SetParent(UILayer.transform, false)
		cell.transform.localPosition = Vector3(9999, 0, 0)			--直接放在界面外
		GameObject.DontDestroyOnLoad(cell.gameObject)
		self.chat_measuring = ChatCell.New(cell.gameObject)
	end
	return self.chat_measuring
end

function GuildChatView:HandleClose()
	self:Close()
end

function GuildChatView:HandleOpenItem()
	TipsCtrl.Instance:ShowPropView()
end

--获取人物当前坐标
function GuildChatView:GetMainRolePos()
	local main_role = Scene.Instance.main_role

	local msg = ""
	if nil ~= main_role then
		local x, y = main_role:GetLogicPos()
		local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
		local open_line = PlayerData.Instance:GetAttr("open_line") or 0
		-- 如果此场景不能分线
		if open_line <= 0 then
			scene_key = -1
		end
		--直接发出去
		local scene_id = Scene.Instance:GetSceneId()
		msg = "{point;".. Scene.Instance:GetSceneName() .. ";" .. x .. ";" .. y .. ";" .. scene_id .. ";" .. scene_key .. "}"
	end

	if msg == "" then
		return
	end

	local current_id = ChatData.Instance:GetCurrentId()
	if current_id == SPECIAL_CHAT_ID.GUILD then
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, msg, CHAT_CONTENT_TYPE.TEXT)
	elseif current_id == SPECIAL_CHAT_ID.TEAM then
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.TEAM, msg, CHAT_CONTENT_TYPE.TEXT)
	elseif current_id > SPECIAL_CHAT_ID.ALL then
		--有私聊对象
		if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.SINGLE) then
			return
		end

		local msg_info = ChatData.CreateMsgInfo()
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		msg_info.from_uid = main_vo.role_id
		local real_role_id = CrossServerData.Instance:GetRoleId()				--获取真实id，防止在跨服聊天出问题
		real_role_id = real_role_id > 0 and real_role_id or main_vo.role_id
		msg_info.role_id = real_role_id
		msg_info.username = main_vo.name
		msg_info.sex = main_vo.sex
		msg_info.camp = main_vo.camp
		msg_info.prof = main_vo.prof
		msg_info.authority_type = main_vo.authority_type
		msg_info.avatar_key_small = main_vo.avatar_key_small
		msg_info.level = main_vo.level
		msg_info.vip_level = main_vo.vip_level
		msg_info.channel_type = CHANNEL_TYPE.PRIVATE
		msg_info.content = msg
		msg_info.send_time_str = TimeUtil.FormatTable2HMS(TimeCtrl.Instance:GetServerTimeFormat())
		msg_info.content_type = CHAT_CONTENT_TYPE.TEXT
		msg_info.tuhaojin_color = CoolChatData.Instance:GetTuHaoJinCurColor() or 0			--土豪金
		msg_info.channel_window_bubble_type = CoolChatData.Instance:GetSelectSeq()					--气泡框
		msg_info.is_read = 1

		ChatData.Instance:AddPrivateMsg(current_id, msg_info)
		ChatCtrl.SendSingleChat(current_id, msg, CHAT_CONTENT_TYPE.TEXT)
		self:FlushChatList(CHANNEL_TYPE.PRIVATE)
	end
end

function GuildChatView:HandleInsertLocation()
	self:GetMainRolePos()
end

function GuildChatView:HandleVoiceStart()
	--先判断是否在私聊
	local private_id = ChatData.Instance:GetCurrentId()
	if private_id > SPECIAL_CHAT_ID.ALL then
		AutoVoiceCtrl.Instance:ShowVoiceView()
	else
		--是否有公会
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_vo.guild_id <= 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
			return
		end
		AutoVoiceCtrl.Instance:ShowVoiceView(CHANNEL_TYPE.GUILD)
	end
end

function GuildChatView:HandleVoiceStop()
	if AutoVoiceCtrl.Instance.view:IsOpen() then
		AutoVoiceCtrl.Instance.view:Close()
	end
end

--添加物品
function GuildChatView:SetData(data, is_equip)
	if ChatData.CheckLinkIsOverLimit(2) then
		return
	end

	if not data or not next(data) then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then
		return
	end

	local text = self.chat_input.input_field.text
	self.chat_input.input_field.text = text .. "[" .. item_cfg.name .. "]"
	local cell_data = {}
	if is_equip then
		cell_data = EquipData.Instance:GetGridData(data.index)
	else
		cell_data = ItemData.Instance:GetGridData(data.index)
	end
	ChatData.Instance:InsertItemTab(cell_data)
end

-- 添加表情
function GuildChatView:SetFace(index)
	if ChatData.CheckLinkIsOverLimit(3) then
		return
	end

	local edit_text = self.chat_input.input_field
	if edit_text then
		local face_id = string.format("%03d", index)
		self.chat_input.input_field.text = edit_text.text .. "#" .. face_id
		ChatData.Instance:InsertFaceTab(face_id)
	end
end

function GuildChatView:HandleOpenEmoji()
	local function callback(face_id)
		self:SetFace(face_id)
	end
	TipsCtrl.Instance:ShowExpressView(callback)
end

function GuildChatView:HandleSend()
	local text = self.chat_input.input_field.text
	self.chat_input.input_field.text = ""

	if text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		ChatData.Instance:ClearInput()
		return
	end

	--开头“/”不发送
	local len = string.len(text)
	if len >= 1 and string.sub(text, 1, 1) == "/" then
		ChatData.Instance:ClearInput()
		return
	end

	local content_type = CHAT_CONTENT_TYPE.TEXT
	--格式化字符串
	text = ChatData.Instance:FormattingMsg(text, content_type)

	--有非法字符直接不让发
	if ChatFilter.Instance:IsIllegal(text, false) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent)
		ChatData.Instance:ClearInput()
		return
	end

	local current_id = ChatData.Instance:GetCurrentId()
	if current_id == SPECIAL_CHAT_ID.GUILD then
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, text, content_type)
	elseif current_id == SPECIAL_CHAT_ID.TEAM then
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.TEAM, text, content_type)
	elseif current_id > SPECIAL_CHAT_ID.ALL then
		if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.SINGLE) then
			return
		end
		local msg_info = ChatData.CreateMsgInfo()
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		msg_info.from_uid = main_vo.role_id
		local real_role_id = CrossServerData.Instance:GetRoleId()				--获取真实id，防止在跨服聊天出问题
		real_role_id = real_role_id > 0 and real_role_id or main_vo.role_id
		msg_info.role_id = real_role_id
		msg_info.username = main_vo.name
		msg_info.sex = main_vo.sex
		msg_info.camp = main_vo.camp
		msg_info.prof = main_vo.prof
		msg_info.authority_type = main_vo.authority_type
		msg_info.avatar_key_small = main_vo.avatar_key_small
		msg_info.level = main_vo.level
		msg_info.vip_level = main_vo.vip_level
		msg_info.channel_type = CHANNEL_TYPE.PRIVATE
		msg_info.content = text
		msg_info.send_time_str = TimeUtil.FormatTable2HMS(TimeCtrl.Instance:GetServerTimeFormat())
		msg_info.content_type = content_type
		msg_info.tuhaojin_color = CoolChatData.Instance:GetTuHaoJinCurColor() or 0			--土豪金
		msg_info.channel_window_bubble_type = CoolChatData.Instance:GetSelectSeq()					--气泡框
		msg_info.is_read = 1

		ChatData.Instance:AddPrivateMsg(current_id, msg_info)
		ChatCtrl.SendSingleChat(current_id, text, content_type)
		self:FlushChatList(CHANNEL_TYPE.PRIVATE)
	end
	ChatData.Instance:ClearInput()
	-- self.chat_input.input_field:ActivateInputField()
end

--刷新聊天信息（此方法是直接改变聊天频道，刷新聊天消息的，所以在调用之前得进行相应判断）
function GuildChatView:FlushChatList(channel_type)
	self.guild_view:FlushChatView(channel_type)
end

function GuildChatView:FriendListChange(role_id)
	local current_id = ChatData.Instance:GetCurrentId()
	if role_id and current_id == role_id then
		self:FlushPriviteRoleInfo()
	end
end

function GuildChatView:BlackListChange(role_id)
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id == role_id then
		self:FlushSelectTarget(false, CHANNEL_TYPE.PRIVITE)
	end
end

--特殊聊天对象状态改变
function GuildChatView:SpecialTargetChange(special_chat_id, is_in)
	local channel_type = CHANNEL_TYPE.TEAM
	if special_chat_id == SPECIAL_CHAT_ID.GUILD then
		channel_type = CHANNEL_TYPE.GUILD
	end
	self:FlushSelectTarget(false, channel_type)
end

function GuildChatView:LoadAvatarCallBack(role_id, path)
	if not self:IsOpen() then
		return
	end
	local current_id = ChatData.Instance:GetCurrentId()
	if role_id ~= current_id then
		self.show_normal_img:SetValue(true)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(role_id, false)
	end
	self.show_normal_img:SetValue(false)
	self.custom_img_res:SetValue(path)
end

--刷新私聊对象数据
function GuildChatView:FlushPriviteRoleInfo()
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id > SPECIAL_CHAT_ID.ALL then
		local private_obj = ChatData.Instance:GetPrivateObjByRoleId(current_id)
		--设置头像
		CommonDataManager.NewSetAvatar(current_id, self.show_normal_img, self.normal_img_res, self.raw_image, private_obj.sex, private_obj.prof, true)
		CommonDataManager.SetAvatarFrame(current_id, self.head_frame_res, self.show_default_frame)
		--设置等级
		local level_des = PlayerData.GetLevelString(private_obj.level)
		self.role_level:SetValue(level_des)

		self.role_prof:SetValue(PlayerData.GetProfNameByType(private_obj.prof))

		local btn_text = Language.Menu.AddFriend
		if ScoietyData.Instance:IsFriendById(current_id) then
			btn_text = Language.Menu.GiveFlower
		end
		self.add_friend_text:SetValue(btn_text)
		self:StopPawnTimes()
	end
end

--刷新队伍相关信息
function GuildChatView:FlushTeamView(is_init)
	self.team_data = ScoietyData.Instance:GetTeamUserList()
	self:FlushTeamList(is_init)

	local is_leader = ScoietyData.Instance:IsLeaderById(GameVoManager.Instance:GetMainRoleVo().role_id)
	self.is_leader:SetValue(is_leader)

	local can_enter_count = ScoietyData.Instance:GetCanEnterCount()
	self.can_enter_member_count:SetValue(can_enter_count)

	local add_exp = ScoietyData.Instance:GetTeamAddExp()
	self.add_exp:SetValue(add_exp)
end

function GuildChatView:StopPawnTimes()
	if self.pawn_show_time then
		GlobalTimerQuest:CancelQuest(self.pawn_show_time)
		self.pawn_show_time = nil
	end
end

function GuildChatView:StartPawnTimes()
	-- 添加定时出现的骰子信息提示
	self:StopPawnTimes()
	self:ShowPawnUpade()
	if self.pawn_show_time then
		GlobalTimerQuest:CancelQuest(self.pawn_show_time)
		self.pawn_show_time = nil
	end
	self.pawn_show_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ShowPawnUpade, self), 10)
end

-- 公会骰子气泡提示
function GuildChatView:ShowPawnUpade()
	-- 玩家是否剩余抛骰子次数
	local can_play = PlayPawnData.Instance:CanPlayPwan()
	-- 抛骰子冷却时间是否足够
	local play_cd = PlayPawnData.Instance:GetPlayCDTime()
	if can_play then
		if self.delay_shou_qipao then
			GlobalTimerQuest:CancelQuest(self.delay_shou_qipao)
			self.delay_shou_qipao = nil
		end
		self.ShowTisPawn:SetValue(true)
		self.delay_shou_qipao = GlobalTimerQuest:AddDelayTimer(function ()
			self.ShowTisPawn:SetValue(false)
		end,5)
	else
		self:StopPawnTimes()
		self.ShowTisPawn:SetValue(false)
	end
end

function GuildChatView:OnAnswerClick(index)
	local guild_result_list = WorldQuestionData.Instance:GetGuildResultList()
	if not next(guild_result_list) then
		local select_index = WorldQuestionData.Instance:GetSelectQuestion(WORLD_GUILD_QUESTION_TYPE.GUILD)
		if select_index == 0 then
			WorldQuestionData.Instance:SetSelectQuestion(index, WORLD_GUILD_QUESTION_TYPE.GUILD)
			WorldQuestionCtrl.SendQuestionAnswerReq(WORLD_GUILD_QUESTION_TYPE.GUILD, index - 1)
		end
	end
end

function GuildChatView:AddTextToInput(text)
	if text and self.chat_input then
		local edit_text = self.chat_input.input_field.text
		self.chat_input.input_field.text = edit_text .. text
	end
end


function GuildChatView:FlushAnswer()
	local question_data = WorldQuestionData.Instance
	local guild_answer_list = question_data:GetGuildAnswerList()
	local guild_result_list = question_data:GetGuildResultList()
	local is_had_guild_answer = next(guild_answer_list) ~= nil
	local is_had_guild_result = next(guild_result_list) ~= nil
	local current_id = ChatData.Instance:GetCurrentId()
	local select_index = WorldQuestionData.Instance:GetSelectQuestion(WORLD_GUILD_QUESTION_TYPE.GUILD)
	--是否显示公会答题
	self.show_guild_question:SetValue((is_had_guild_answer or is_had_guild_result) and current_id == SPECIAL_CHAT_ID.GUILD)

	self:CheckSetTopToggle(current_id)
	--没有答题任何信息时
	if not is_had_guild_answer and not is_had_guild_result and current_id ~= SPECIAL_CHAT_ID.GUILD then
		return
	end
	--显示答案状态
	if guild_result_list and is_had_guild_result then
		--进入已完成状态时
		if self.complete_flag == true then
			WorldQuestionData.Instance:ClearGuildList()
			self.show_guild_question:SetValue(false)
			return
		end

		--时间小于5
		local time = guild_answer_list.cur_question_end_time - TimeCtrl.Instance:GetServerTime()
		if time <= ANSWER_TIME_LIMIT then
			self:CancelQuestionCountDown()
			self.show_guild_question:SetValue(false)
			WorldQuestionData.Instance:ClearGuildList()
			return
		end

		self.answer_list[1].show_answer:SetValue(select_index == 1)
		self.answer_list[2].show_answer:SetValue(select_index == 2)

		--显示正确与错误
		self.answer_list[select_index].answer_right:SetValue(guild_result_list.result + 1 == select_index)
		self.answer_list[3-select_index].answer_right:SetValue(guild_result_list.result + 1 == 3-select_index)

		--提前结束答题
		if time > FIX_EXIT_TIME and self.complete_flag == false then
			self.complete_flag = true
			self.time_text:SetValue(FIX_EXIT_TIME)
			self:CancelQuestionCountDown()
			self.count_down = CountDown.Instance:AddCountDown(FIX_EXIT_TIME, 1, BindTool.Bind(self.CountDown, self))
		end

		--弹出正确或错误提示
		if guild_result_list.result + 1 == select_index then
			TipsCtrl.Instance:ShowSystemMsg(Language.Answer.Correct)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Answer.Wrong)
		end

		return
	end

	--显示答题状态
	if guild_answer_list and is_had_guild_answer then
		self.complete_flag = false
		--结束时间少于5秒,不显示答题
		local sever_time = TimeCtrl.Instance:GetServerTime()
		local remain_time = guild_answer_list.cur_question_end_time - sever_time
		self.show_guild_question:SetValue(remain_time >= ANSWER_TIME_LIMIT and current_id == SPECIAL_CHAT_ID.GUILD)
		if remain_time < ANSWER_TIME_LIMIT then
			return
		end

		--显示题目和选项
		self.question_title:SetValue(guild_answer_list.question)
		for i=1,2 do
			self.answer_list[i].show_answer:SetValue(false)
			self.answer_list[i].answer_text:SetValue(guild_answer_list.question_list[i])
		end

		local time = guild_answer_list.cur_question_end_time - sever_time - 2  --提早2s关闭
		self.time_text:SetValue(time)

		--答题倒计时
		self:CancelQuestionCountDown()
		self.count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.CountDown, self))
	end
end

function GuildChatView:CancelQuestionCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

--打开界面时设置一遍
function GuildChatView:SetTopToggleIsOn(index, is_on)
	if self.top_toggle_list[index].gameObject.activeInHierarchy then
		self.top_toggle_list[index].toggle.isOn = is_on
		self.record_top_toggle_state[index] = nil
	else
		self.record_top_toggle_state[index] = is_on
	end

	for i=1,2 do
		if i ~= index then
			self.record_top_toggle_state[i] = nil
		end
	end
end

--防止从私聊进入界面 设置toggle失效
function GuildChatView:CheckSetTopToggle(current_id)
	if current_id == SPECIAL_CHAT_ID.GUILD then
		for i=1,2 do
			if self.record_top_toggle_state[i] ~= nil then
				self.top_toggle_list[i].toggle.isOn = not self.record_top_toggle_state[i]
				self:SetTopToggleIsOn(1, self.record_top_toggle_state[i])
			end
		end
		return
	end
end

function GuildChatView:FlushQuestionRank()
	for k,v in pairs(self.guild_rank_cell_list) do
		v:Flush()
	end
end

function GuildChatView:FriendClick()
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id > SPECIAL_CHAT_ID.ALL then
		if ScoietyData.Instance:IsFriendById(current_id) then
			local friend_info = ScoietyData.Instance:GetFriendInfoById(current_id)
			FlowersCtrl.Instance:SetFriendInfo(friend_info)
			ViewManager.Instance:Open(ViewName.Flowers)
		else
			ScoietyCtrl.Instance:AddFriendReq(current_id)
		end
	end
end

function GuildChatView:TeamClick()
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id > SPECIAL_CHAT_ID.ALL then
		if not ScoietyData.Instance:GetTeamState() then
			if ViewManager.Instance:IsOpen(ViewName.Scoiety) then
				ScoietyCtrl.Instance.scoiety_view:ChangeToIndex(TabIndex.society_team)
			else
				ViewManager.Instance:Open(ViewName.Scoiety, TabIndex.society_team)
			end
			local param_t = {}
			param_t.must_check = 0
			param_t.assign_mode = 2
			ScoietyCtrl.Instance:CreateTeamReq(param_t)
		end
		ScoietyCtrl.Instance:InviteUserReq(current_id)
	end
end

function GuildChatView:CheckClick()
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id > SPECIAL_CHAT_ID.ALL then
		CheckData.Instance:SetCurrentUserId(current_id)
		CheckCtrl.Instance:SendQueryRoleInfoReq(current_id)
		ViewManager.Instance:Open(ViewName.CheckEquip)
	end
end

function GuildChatView:TradeClick()
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id > SPECIAL_CHAT_ID.ALL then
		TradeCtrl.Instance:SendTradeRouteReq(current_id)
	end
end

function GuildChatView:BlackClick()
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id > SPECIAL_CHAT_ID.ALL then
		local private_obj = ChatData.Instance:GetPrivateObjByRoleId(current_id) or {}
		local function yes_func()
			ScoietyCtrl.Instance:AddBlackReq(current_id)
		end

		local describe = string.format(Language.Society.AddBlackDes, private_obj.username or "")
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function GuildChatView:TrackClick()
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id > SPECIAL_CHAT_ID.ALL then
		local private_obj = ChatData.Instance:GetPrivateObjByRoleId(current_id) or {}
		--当前场景无法传送
		local scene_type = Scene.Instance:GetSceneType()
		if scene_type ~= SceneType.Common then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
			return
		end

		local function ok_func()
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			local need_item_data = ShopData.Instance:GetShopItemCfg(27582)
			if not need_item_data then
				return
			end
			local item_num = ItemData.Instance:GetItemNumInBagById(27582)
			if main_vo.gold < need_item_data.gold then
				--元宝不足
				TipsCtrl.Instance:ShowLackDiamondView()
				return
			elseif item_num <= 0 then
				--材料不足，弹出购买
				local function close_call_back()
					PlayerCtrl.Instance:SendSeekRoleWhere(private_obj.username or "")
				end
				TipsCtrl.Instance:ShowShopView(27582, 2, close_call_back)
			else
				PlayerCtrl.Instance:SendSeekRoleWhere(private_obj.username or "")
			end
		end

		local str = string.format(Language.Role.TraceConfirm, private_obj.username or "")
		TipsCtrl.Instance:ShowCommonAutoView("", str, ok_func)
	end
end

-- 公会骰子
function GuildChatView:PlayPawn()
	ClickOnceRemindList[RemindName.GuildChatRed] = 0
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.GuildChatRed)
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
		return
	end
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id == SPECIAL_CHAT_ID.GUILD then
		self.play_pawn_btn:SetValue(false)
		PlayPawnCtrl.Instance:OpenPlayPawnView()
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Guild.PawnTips)
	end
end

function GuildChatView:ClickQuick()
	ChatCtrl.Instance:OpenQuickChatView(QUICK_CHAT_TYPE.GUILD)
end

function GuildChatView:ClickLeaveTeam()
	local function ok_func()
		ScoietyCtrl.Instance:ExitTeamReq()
	end
	local des = Language.Society.ExitTeam

	TipsCtrl.Instance:ShowCommonAutoView("leave_team", des, ok_func)
end

function GuildChatView:ClickInvite()
	local main_role_id = Scene.Instance:GetMainRole():GetRoleId()
	local team_state = ScoietyData.Instance:GetTeamState()
	if not team_state then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
		return
	end
	if not ScoietyData.Instance:IsLeaderById(main_role_id) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.DontInviety)
		return
	end
	TipsCtrl.Instance:ShowInviteView()
end

-- 刷新玩家公会骰子排名
function GuildChatView:FlushRolePwanPank()
	local role_info = PlayPawnData.Instance:CanCurrRoleInfo()
	if role_info then
	 	self.RoleName:SetValue(role_info.name)
	 	if role_info.rank_num == 0 then
			self.RoleRank:SetValue(Language.Guild.NotRankStr)
		else
			self.RoleRank:SetValue(role_info.rank_num)
	 	end
	 	self.RoleCount:SetValue(role_info.score)
	 	local guild_rank_reward = PlayPawnData.Instance:GetRankReward(role_info.rank_num)
		if guild_rank_reward and next(guild_rank_reward) then
			-- 奖励物品
			if guild_rank_reward.item_id then
				local item_cfg = ItemData.Instance:GetItemConfig(guild_rank_reward.item_id)
				if item_cfg and next(item_cfg) then
					self.flower_img_pawn:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
				end
			end
			if guild_rank_reward.num then
				self.item_text_pawn:SetValue(guild_rank_reward.num)
			end
		end
	end
end

-- 下次抛骰子倒计时间
function GuildChatView:OnFlushPawnTime()
	if self.next_timer then
		GlobalTimerQuest:CancelQuest(self.next_timer)
		self.next_timer = nil
	end
	self.next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushCanPawnNextTime, self), 1)
end

function GuildChatView:FlushCanPawnNextTime()
	-- 玩家是否剩余抛骰子次数
	local can_play = PlayPawnData.Instance:CanPlayPwan()
	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local level = game_vo.level
	-- 抛骰子冷却时间是否足够
	local play_cd = PlayPawnData.Instance:GetPlayCDTime()
	-- 冷却中
	if play_cd > 0 then
		if can_play then
			self.guild_pawn_text:SetValue("")
			self.TimePawnText:SetValue(TimeUtil.FormatSecond(play_cd,2))
		else
			self.TimePawnText:SetValue("")
			self.guild_pawn_text:SetValue("")
		end
		self.play_pawn_btn:SetValue(false)
	else
		if self.next_timer then
			GlobalTimerQuest:CancelQuest(self.next_timer)
			self.next_timer = nil
		end
		if can_play then
			local play_num = PlayPawnData.Instance:GetCanPlayPwanNum()
			self.guild_pawn_text:SetValue(string.format(Language.Chat.CanPlayNum,play_num))
			self.play_pawn_btn:SetValue(true)
			if level >= 150 then
				self.play_pawn_red_point:SetValue(true)
			else
				self.play_pawn_red_point:SetValue(false)
			end
			self.is_kuafu:SetValue(not IS_ON_CROSSSERVER)
			self.TimePawnText:SetValue("")
		else
			self.guild_pawn_text:SetValue("")
			self.play_pawn_btn:SetValue(false)
		end
	end
end

function GuildChatView:OnTopTabClick(i,is_click)
	if is_click then
		if i == GUILD_TOP_TOGGLE_NAME.QUESTION then
			-- 公会答题
			self.pawn_rank_list:SetValue(true)
			self.rank_list:SetValue(false)

		elseif i == GUILD_TOP_TOGGLE_NAME.SHAI_ZI then
			-- 公会骰子
			self.rank_list:SetValue(true)
			self.pawn_rank_list:SetValue(false)
			if self.pwan_rank_list_view.scroller.isActiveAndEnabled then
				self.pwan_rank_list_view.scroller:RefreshAndReloadActiveCellViews(true)
			end
		end
		self.index = i

		for i=1,4 do
			self.guild_rank_cell_list[i]:Flush()
		end

		for i=1,2 do
			self.top_toggle_hl_list[i]:SetValue(self.index == i)
		end
	end
end

function GuildChatView:GetCurIndex()
	return self.index
end

function GuildChatView:InitMemberListView()
	self.member_scroller_list_view = self:FindObj("member_list_view")
	local list_delegate = self.member_scroller_list_view.list_simple_delegate
	-- 有有多少个cell
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMemberNumberOfCells, self)
	-- 更新cell
	list_delegate.CellRefreshDel = BindTool.Bind(self.MemberRefreshCell, self)
end

function GuildChatView:GetMemberNumberOfCells()
	return GuildDataConst.GUILD_MEMBER_LIST.count
end

function GuildChatView:MemberRefreshCell(cell, data_index)
	data_index = data_index + 1
	local icon_cell = self.activity_cell_list[cell]
	if icon_cell == nil then
		icon_cell = MemberCell.New(cell.gameObject)
		icon_cell.root_node.toggle.group = self.member_scroller_list_view.toggle_group
		self.activity_cell_list[cell] = icon_cell
	end
	local data = {}
	data = GuildDataConst.GUILD_MEMBER_LIST.list[data_index]
	icon_cell:SetIndex(data_index)
	icon_cell:SetData(data)
end

function GuildChatView:InitPawnListView()
	self.pwan_rank_list_view = self:FindObj("PwanRankListView")
	local list_delegate = self.pwan_rank_list_view.list_simple_delegate
	-- 有有多少个cell
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCurrScoreOfCells, self)
	-- 更新cell
	list_delegate.CellRefreshDel = BindTool.Bind(self.ScoreRefreshCell, self)
end

function GuildChatView:GetCurrScoreOfCells()
	return PlayPawnData.Instance:GetGuildPawnRankNum()
end

function GuildChatView:ScoreRefreshCell(cell, data_index)
	data_index = data_index + 1
	local score_cell = self.pwan_score_list_view[cell]
	if score_cell == nil then
		score_cell = GuildPawnRankCell.New(cell.gameObject)
		score_cell.root_node.toggle.group = self.pwan_rank_list_view.toggle_group
		score_cell:SetClickCallBack(BindTool.Bind(self.ScoreCellClick, self))
		self.pwan_score_list_view[cell] = score_cell
	end

	local rank_info = PlayPawnData.Instance:GetGuildPawnRankInfoByScore()
	if rank_info then
		local data = rank_info[data_index]
		score_cell:SetIndex(data_index)
		score_cell:SetData(data)
	end

	--设置高亮展示
	if data_index == self.select_score_index then
		score_cell:SetSorceToggleIsOn(true)
	else
		score_cell:SetSorceToggleIsOn(false)
	end
end

function GuildChatView:ScoreCellClick(cell)
	local index = cell:GetIndex()
	self.select_score_index = index
end

function GuildChatView:OnFlush(params_t)
	local current_id = ChatData.Instance:GetCurrentId()
	local channel_type = self.guild_view:GetChannelType()
	for k, v in pairs(params_t) do
		if k == "view" then
			if current_id == SPECIAL_CHAT_ID.GUILD then
				self:FlushMemberList()
			end

			local remind_num = GuildData.Instance:GetSigninRemind()
			self.show_signin_red_point:SetValue(remind_num >= 1)
		elseif k == "new_chat" then
			if v[2] and v[2] ~= current_id or v[1] ~= channel_type then
				self:FlushAllRemind()
			else
				self:FlushChatList(v[1])
			end
		elseif k == "force_new_chat" then
			--此参数是强制改变聊天列表的
			if v[2] and v[2] == current_id then
				self:FlushChatList(v[1])
			end
		elseif k == "guild_answer" or k == "guild_qustion_result" then
			if current_id == SPECIAL_CHAT_ID.GUILD then
				self:FlushAnswer()
			end
		elseif k == "guild_question_rank" then
			if current_id == SPECIAL_CHAT_ID.GUILD then
				self:FlushQuestionRank()
			end
		elseif k == "flush_pawn_scoreview" then
			self:FlushPawnScoreView()
		elseif k == "select_traget" then
			self:FlushSelectTarget(v[1], v[2])
		elseif k == "flush_team_view" then
			if current_id == SPECIAL_CHAT_ID.TEAM then
				self:FlushTeamView()
			end
		elseif current_id == SPECIAL_CHAT_ID.GUILD then
			self:FlushMemberList()
		end
	end
end

function GuildChatView:OnClickSignin()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CantOpenInCross)
		return
	end
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id <= 0  then
		local shake_state = GuildData.Instance:GetGuildChatShakeState()
		if shake_state == true then
			self:ShakeGuildChatBtn(false)
		end
		ViewManager.Instance:Open(ViewName.Guild)
	else
		GuildCtrl.Instance:OpenSigninView()
	end
end

function GuildChatView:OpenGuildMaze()
	ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_maze)
end

function GuildChatView:OpenWantEquip()
	ChatCtrl.Instance:OpenWantEquipView()
end

function GuildChatView:OpenMarket()
	ViewManager.Instance:Open(ViewName.Market)
end

-- 根据渠道开启语音聊天
function GuildChatView:UpdateVoiceSwitch()
	self.show_speaker:SetValue(not SHIELD_VOICE)
end