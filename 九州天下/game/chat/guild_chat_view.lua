	require("game/chat/chat_guild_view")
require("game/chat/team_member_cell")
local GUILD_TOP_TOGGLE_NAME =
{
	SHAI_ZI = 1,
	QUESTION = 2,
}

GuildChatView = GuildChatView or BaseClass(BaseView)

local OperaCount = 6				--聊天操作按钮最大个数
local ANSWER_TIME_LIMIT = 5  --上线时剩余5s答题则不打开界面
local UILayer = GameObject.Find("GameRoot/UILayer")
-- 一页显示的红包数量
local HongBaoCount = 3
local FIX_EXIT_TIME = 3
function GuildChatView:__init()
	GuildChatView.Instance = self
	self.ui_config = {"uis/views/chatview", "ChatGuildView"}
    self:SetMaskBg()
	self.role_list_data = {}
	self.select_target_index = 1
	self.is_send_chat = false
end

function GuildChatView:__delete()
	GuildChatView.Instance = nil
end

function GuildChatView:CloseCallBack()
	ChatData.Instance:SetRedChat(false)
end

function GuildChatView:LoadCallBack()
	self.role_info_callback = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfoCallBack, self))

	self.select_target_index = 1

	-- 变量
	self.button_text = self:FindVariable("ButtonText")
	self.is_send_cool = self:FindVariable("IsSendCool")
	self.is_show_tips = self:FindVariable("is_show_tips")
	self.tips_text = self:FindVariable("tips_text")
	self.hong_bao_value = self:FindVariable("HongBaoValue")
	self.self_revive_num = self:FindVariable("SelfReviveNum")
	self.guild_revive_num = self:FindVariable("GuildReviveNum")
	self.show_right_arrow = self:FindVariable("ShowRightArrow")
	self.show_left_arrow = self:FindVariable("ShowLeftArrow")
	self.show_single_chat = self:FindVariable("ShowSingleChat")
	self.show_private_chat = self:FindVariable("ShowPrinvateChat")
	self.show_team_chat = self:FindVariable("ShowTeamChat")
	self.show_camp_chat = self:FindVariable("ShowCampChat")
	self.add_friend_text = self:FindVariable("AddFriendText")
	self.role_level = self:FindVariable("RoleLevel")
	self.role_prof = self:FindVariable("RoleProf")
	self.role_guild = self:FindVariable("Role_Guild")
	self.pawn_rank_list = self:FindVariable("PawnRankList")
	self.rank_list = self:FindVariable("RankList")
	self.guild_pawn_text = self:FindVariable("GuildPawnText")
 	self.play_pawn_btn = self:FindVariable("PlayPawnBtnBool")
 	self.RoleName = self:FindVariable("RoleName")
 	self.RoleRank = self:FindVariable("RoleRank")
 	self.RoleCount = self:FindVariable("RoleCount")
 	self.flower_img_pawn = self:FindVariable("flower_img_pawn")
 	self.item_text_pawn = self:FindVariable("item_text_pawn")
 	self.ShowPlayBtn = self:FindVariable("ShowPlayBtn")
 	self.ShowQuilkLiao = self:FindVariable("ShowQuilkLiao")
 	self.show_camp_quick = self:FindVariable("ShowCampQuick")
 	self.TimePawnText = self:FindVariable("TimePawnText")
 	self.ShowTisPawn = self:FindVariable("ShowTisPawn")
 	self.show_guild_name = self:FindVariable("Show_Guild_Name")
	self.is_leader = self:FindVariable("IsLeader")
	self.add_exp = self:FindVariable("AddExp")
	self.can_enter_member_count = self:FindVariable("CanEnterMemberCount")
	self.show_qiandao = self:FindVariable("ShowQianDao")
	self.CampGoldNum = self:FindVariable("CampGoldNum")
	self.CampFuHuoNum = self:FindVariable("CampFuHuoNum")
	self.CampYunBiao = self:FindVariable("CampYunBiao")
	self.CampBanZhuan = self:FindVariable("CampBanZhuan")
	self.CampQiYunTa = self:FindVariable("CampQiYunTa")
	self.CampNotive = self:FindVariable("CampNotive")
	self.chat_cd = self:FindVariable("ChatCD")
	self.show_pawn_rp = self:FindVariable("show_pawn_rp")
	--公会答题
	self.show_guild_question = self:FindVariable("ShowGuildQuestion")
	self.question_title = self:FindVariable("GuildQuestionTitle")
	self.time_text = self:FindVariable("TimeText")
	self.answer_list = {}
	for i=1,4 do
		self.answer_list[i] = {}
		self.answer_list[i].answer_text = self:FindVariable("AnswerText" .. i)
		self.answer_list[i].answer_right = self:FindVariable("AnswerRight" .. i)  --是否正确
		self.answer_list[i].show_answer = self:FindVariable("ShowAnswer" .. i) 	--显示 正确与错误图标
		--self:ListenEvent("answer_click" .. i, BindTool.Bind2(self.OnAnswerClick, self, i))
	end

	--头像
	self.normal_img_res = self:FindVariable("ImgRes")
	self.custom_img_res = self:FindVariable("RawImgRes")
	self.show_normal_img = self:FindVariable("ShowImage")

	-- 查找组件
	self.chat_input = self:FindObj("ChatInput")
	self.chat_input.input_field.characterLimit = COMMON_CONSTS.CHAT_SIZE_LIMIT
	local spid = GLOBAL_CONFIG.package_info.config.agent_id
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").chat_limit
	if agent_cfg ~= nil then
		for k,v in pairs(agent_cfg) do
			if v.spid == spid then
				self.chat_input.input_field.characterLimit = v.size_limit or COMMON_CONSTS.CHAT_SIZE_LIMIT
				break
			end
		end
	end

	self.tips_pop_bt = self:FindObj("tips_pop_bt")
	self.slider = self:FindObj("Slider")
	self.scroller_rect = self:FindObj("ScrollerRect")
	self.scroller_content = self:FindObj("ScrollerContent")
	self.hong_bao_panel = self:FindObj("HongBaoPanel")
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
	self.scroller_rect:GetComponent(typeof(UnityEngine.UI.ScrollRect)).onValueChanged:AddListener(BindTool.Bind(self.OnValueChange, self))

	--左边聊天对象列表
	self.role_list = self:FindObj("RoleList")
	self.target_cell_list = {}
	local list_delegate = self.role_list.list_simple_delegate
	self.list_view_height = self.role_list.rect.rect.height
	self.role_cell_height = list_delegate:GetCellViewSize(self.role_list.scroller, 0)			--单个cell的大小（根据排列顺序对应高度或宽度）
	self.role_list_spacing = self.role_list.scroller.spacing									--间距
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetTargetRoleNumOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.TargetRoleRefreshCell, self)
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
	self:ListenEvent("OpenRedPackage",
		BindTool.Bind(self.HandleOpenRedPackage, self))
	self:ListenEvent("OpenEmoji",
		BindTool.Bind(self.HandleOpenEmoji, self))
	self:ListenEvent("Send",
		BindTool.Bind(self.HandleSend, self))
	self:ListenEvent("GoBottomClick",
		BindTool.Bind(self.GoBottomClick, self))
	self:ListenEvent("TipsPopClick",
		BindTool.Bind(self.OnTipsPopClick, self))
	self:ListenEvent("OpenCoolShop",
		BindTool.Bind(self.GoCoolShop, self))
	self:ListenEvent("OnClickHelp",
		BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickRight",
		BindTool.Bind(self.OnClickRight, self))
	self:ListenEvent("OnClickLeft",
		BindTool.Bind(self.OnClickLeft, self))
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
	self:ListenEvent("OpenSingInBtn",
		BindTool.Bind(self.OpenSingInBtn, self))
	self:ListenEvent("ClickQuick",
		BindTool.Bind(self.ClickQuick, self))
	self:ListenEvent("ClickLeaveTeam",
		BindTool.Bind(self.ClickLeaveTeam, self))
	self:ListenEvent("ClickInvite",
		BindTool.Bind(self.ClickInvite, self))
	self:ListenEvent("ClickQuickChat",
		BindTool.Bind(self.ClickQuickChat, self))
	for i = 1,2 do
		self:ListenEvent("TopTab" .. i,
		 BindTool.Bind2(self.OnTopTabClick, self, i))
	end

	for i = 1,4 do
		self:ListenEvent("AnswerClick" .. i,
		 BindTool.Bind2(self.OnAnswerClick, self, i))
	end
	self.guild_view = ChatGuildView.New(self:FindObj("ContentGuild"))

	self.red_point_list = {
		[RemindName.CoolChat] = self:FindVariable("ShowCoolChatRedPoint"),
		[RemindName.SignIn]   = self:FindVariable("showSigninRedPoint"),

	}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	--队伍列表
	self.team_member_list = self:FindObj("TeamMemberList")
	self.team_cell_list = {}
	self.team_data = {}
	local team_simple_delegate = self.team_member_list.list_simple_delegate
	team_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetTeamMemberNum, self)
	team_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTeamMenberList, self)

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
	self:InitHongBao()
	self:InitPawnListView()
	self:FlushCanPawnNextTime()
	self:ShowPawnUpade()
end

function GuildChatView:ReleaseCallBack()
	if self.guild_view then
		self.guild_view:DeleteMe()
	end

	if self.chat_measuring then
		GameObject.Destroy(self.chat_measuring.root_node.gameObject)
		self.chat_measuring:DeleteMe()
		self.chat_measuring = nil
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

	for k,v in pairs(self.info_table) do
		v:DeleteMe()
	end
	self.info_table = {}
	self.red_point_list = {}

	if RemindManager.Instance and self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	for k, v in pairs(self.target_cell_list) do
		v:DeleteMe()
	end
	self.target_cell_list = {}

	for k,v in pairs(self.guild_rank_cell_list) do
		v:DeleteMe()
	end
	self.guild_rank_cell_list = {}

	-- 清理变量和对象
	self.button_text = nil
	self.is_send_cool = nil
	self.is_show_tips = nil
	self.tips_text = nil
	self.hong_bao_value = nil
	self.self_revive_num = nil
	self.guild_revive_num = nil
	self.chat_input = nil
	self.tips_pop_bt = nil
	self.slider = nil
	self.activitty_scroller_list_view = nil
	self.member_scroller_list_view = nil
	self.show_cool_chat_red_point = nil
	self.show_right_arrow = nil
	self.show_left_arrow = nil
	self.show_pawn_rp = nil

	self.scroller_rect = nil
	self.scroller_content = nil
	self.hong_bao_panel = nil
	self.guild_pawn_text = nil
	self.role_list = nil
	self.show_single_chat = nil
	self.show_private_chat = nil
	self.show_team_chat = nil
	self.show_camp_chat = nil
	self.add_friend_text = nil
	self.normal_img_res = nil
	self.custom_img_res = nil
	self.show_normal_img = nil
	self.role_level = nil
	self.role_prof = nil
	self.role_guild = nil
	self.pawn_rank_list = nil
	self.rank_list = nil
	self.pwan_rank_list_view = nil
	self.play_pawn_btn = nil
	self.show_qiandao = nil
 	self.RoleName = nil
 	self.RoleRank = nil
 	self.RoleCount = nil
 	self.flower_img_pawn = nil
 	self.item_text_pawn = nil
 	self.ShowPlayBtn = nil
 	self.ShowQuilkLiao = nil
	self.show_guild_question = nil
	self.question_title = nil
	self.time_text = nil
	self.TimePawnText = nil
	self.ShowTisPawn = nil
	self.show_guild_name = nil
	self.team_member_list = nil
	self.is_leader = nil
	self.add_exp = nil
	self.CampGoldNum = nil
	self.CampFuHuoNum = nil
	self.CampYunBiao = nil
	self.CampBanZhuan = nil
	self.CampQiYunTa = nil
	self.CampNotive = nil
	self.can_enter_member_count = nil
	self.show_camp_quick = nil
	self.chat_cd = nil

	for i=1,4 do
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

	-- if self.pawn_show_time then
	-- 	GlobalTimerQuest:CancelQuest(self.pawn_show_time)
	-- 	self.pawn_show_time = nil
	-- end

	if self.delay_shou_qipao then
		GlobalTimerQuest:CancelQuest(self.delay_shou_qipao)
		self.delay_shou_qipao = nil
	end

	if self.role_info_callback then
		GlobalEventSystem:UnBind(self.role_info_callback)
		self.role_info_callback = nil
	end
end

function GuildChatView:GetTargetRoleNumOfCells()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	local teap_list = ChatData.Instance:GetNormalChatList()
	local open_camp = OpenFunData.Instance:CheckIsHide("camp")
	local chat_num = 0
	if guild_id > 0 then
		chat_num = chat_num + 1
	end

	if open_camp then
		chat_num = chat_num + 1
	end

	if teap_list[1] then
		chat_num = chat_num + 1
	end

	if teap_list[1] then
		if guild_id > 0 and open_camp then
			return #self.role_list_data + chat_num
		else
			return #self.role_list_data + chat_num
		end
	else
		if guild_id > 0 and open_camp then
			return #self.role_list_data + chat_num
		else
			return #self.role_list_data + chat_num
		end
	end
end

function GuildChatView:TargetRoleRefreshCell(cell, data_index)
	data_index = data_index + 1
	local target_cell = self.target_cell_list[cell]
	if nil == target_cell then
		target_cell = ChatTargetItem.New(cell.gameObject)
		target_cell.root_node.toggle.group = self.role_list.toggle_group
		target_cell:SetClickCallBack(BindTool.Bind(self.TargetCellClick, self))
		self.target_cell_list[cell] = target_cell
	end

	target_cell:SetIndex(data_index)
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	local data = nil
 
	local teap_list = ChatData.Instance:GetNormalChatList()
	local open_camp = OpenFunData.Instance:CheckIsHide("camp")

	if guild_id > 0 then
		local other_index = 1
		if open_camp then
			other_index = other_index + 1
		end

		if teap_list[1] then
			other_index = other_index + 1
		end

		if data_index == 1 then
			data = {is_guild = true}
		elseif data_index == 2 and open_camp then
			data = {role_id = 3}
		elseif data_index == 3 then
			if teap_list[1] and other_index == 3 then
				data = teap_list[1]
			else
				data = self.role_list_data[data_index - 2]
			end
		else
			-- if teap_list[1] then
			-- 	--data = self.role_list_data[data_index - 3]
			-- 	--data = teap_list[1]
			-- else
			-- 	data = self.role_list_data[data_index - 2]
			-- end
			if data_index > other_index then
				data = self.role_list_data[data_index - other_index]
			else
				if teap_list[1] then
					--data = self.role_list_data[data_index - 3]
					data = teap_list[1]		
				else
					data = self.role_list_data[data_index - other_index]
				end		
			end
		end
	else
		if data_index == 1 and open_camp then
			data = {role_id = 3}
		elseif data_index == 2 then
			if teap_list[1] then
				data = teap_list[1]
			else
				data = self.role_list_data[data_index - 1]
			end
		else

			local chat_num = 0
			if teap_list[1] then
				chat_num = chat_num + 1
			end

			if open_camp then
				chat_num = chat_num + 1
			end

			data = self.role_list_data[data_index - chat_num]
		end
	end
	 

	--设置高亮展示
	if data_index == self.select_target_index then
		if data and data.role_id then
			ChatData.Instance:RemPrivateUnreadMsg(data.role_id)
		else
			ChatData.Instance:ClearGuildUnreadMsg()
		end
		target_cell:SetToggleIsOn(true)
	else
		target_cell:SetToggleIsOn(false)
	end
 
	target_cell:SetData(data)
	target_cell:UnBindIsOnlineEvent()
	target_cell:BindIsOnlineEvent()
end

function GuildChatView:TargetCellClick(cell)
	local data = cell:GetData()
	if not data then
		return
	end

	cell.root_node.toggle.isOn = true
	local index = cell:GetIndex()
	if self.select_target_index == index then
		return
	end

	self.select_target_index = index

	--选中就把红点去掉
	if data.role_id then
		ChatData.Instance:RemPrivateUnreadMsg(data.role_id)
	end
	cell:SetRemind(false)

	if data.is_guild then
		ChatData.Instance:SetCurrentRoleId(0)
	else
		ChatData.Instance:SetCurrentRoleId(data.role_id)
	end
	self:FlushRightView(true)
	self:FlushRoleInfo()
	local current_id = ChatData.Instance:GetCurrentRoleId()
	local is_start_answer = true
	--self.show_guild_question:SetValue(is_start_answer and current_id <= 0)
	self.show_qiandao:SetValue(is_start_answer and current_id <= 0 and not IS_ON_CROSSSERVER)

	self:Flush("guild_answer")
	self:Flush("guild_question_rank")
	self.show_single_chat:SetValue(not data.is_guild)
	self.show_team_chat:SetValue(current_id == 2)
	self.show_camp_chat:SetValue(current_id == 3)
	self.show_private_chat:SetValue(current_id > 3)
end

function GuildChatView:CallRemindInit()
	ClickOnceRemindList[RemindName.PlayPawn] = 0
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.PlayPawn)
end

function GuildChatView:OpenCallBack()
	if self.guild_view ~= nil then
		local show_way = ChatData.Instance:GetGuildChatType()
		self.guild_view.show_chat_type = show_way or SHOW_CHAT_TYPE.CHAT
		ChatData.Instance:SetGuildChatType(nil)
	end

	--把主界面私聊头像隐藏
	ChatData.Instance:SetHavePriviteChat(false)
	MainUICtrl.Instance.view:Flush("privite_visible", {false})
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_GET_REBORN_TIMES_LIST)
	CampCtrl.Instance:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_GET_CAMP_ROLE_INFO)
	CampCtrl.Instance:SendCampWarCommonOpera(CAMP_WAR_OPERA_TYPE.OPERA_TYPE_QUERY_QIYUN_STATUS)
	CampCtrl.Instance:SendCampWarCommonOpera(CAMP_WAR_OPERA_TYPE.OPERA_TYPE_QUERY_QIYUN_REPORT)
	self.button_text:SetValue(Language.Guild.Send)
	GuildCtrl.Instance:SendGuildInfoReq()
	GuildCtrl.Instance:SendAllGuildMemberInfoReq()
	MainUICtrl.Instance.view:Flush("show_guildchat_redpt", {false})
	self:OnValueChange(self.scroller_rect:GetComponent(typeof(UnityEngine.UI.ScrollRect)).normalizedPosition)
	self:FlushHongBao()
	RemindManager.Instance:Fire(RemindName.CoolChat)
	RemindManager.Instance:Fire(RemindName.SignIn)
	self.role_list_data = ChatData.Instance:GetPrivateObjList()
	local current_id = ChatData.Instance:GetCurrentRoleId()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id

	if guild_id <= 0 and current_id == 0 then
		ChatData.Instance:SetCurrentRoleId(3)
		current_id = ChatData.Instance:GetCurrentRoleId()
	else
		self.select_target_index = 1
	end

	local open_camp = OpenFunData.Instance:CheckIsHide("camp")
	local camp_num = open_camp and 1 or 0
	local teap_list = ChatData.Instance:GetNormalChatList()

	local chat_num = 0
	if guild_id > 0 then
		chat_num = chat_num + 1
	end

	if open_camp then
		chat_num = chat_num + 1
	end

	if teap_list[1] then
		chat_num = chat_num + 1
	end
 

	if current_id > 3 then
		self.guild_view:FlushGuildView(true)
		for k, v in ipairs(self.role_list_data) do
			if v.role_id == current_id then
				if guild_id > 0 then
					if teap_list[1] then
						self.select_target_index = k + chat_num
					else
						self.select_target_index = k + chat_num
					end
				else
					if teap_list[1] then
						self.select_target_index = k + chat_num
					else
						self.select_target_index = k + chat_num
					end
				end
				break
			end
		end
	elseif current_id == 2 then
		self.guild_view:FlushGuildTeamView()
		if guild_id > 0 then
 			-- 有家族
 			self.select_target_index = chat_num
		else
			self.select_target_index = chat_num
		end
	elseif current_id == 3 then
		self.guild_view:FlushGuildCampView()
		self:FlushCampAttr()
		if guild_id > 0 then
 			-- 有家族
 			self.select_target_index = chat_num
		else
			self.select_target_index = chat_num
		end
	else
		ChatData.Instance:ClearGuildUnreadMsg()
		self.guild_view:FlushGuildView(false)
	end

	self:FlushRoleInfo()
	--设置聊天列表
	local max_hight = (self.role_cell_height + self.role_list_spacing) * (#self.role_list_data + 1) - self.role_list_spacing
	local not_see_height = math.max(max_hight - self.list_view_height, 0)
	local bili = 0
	if not_see_height > 0 then
		bili = math.min(((self.role_cell_height + self.role_list_spacing) * (self.select_target_index - 1)) / not_see_height, 1)
	end
	self.role_list.scroller:ReloadData(bili)
	--监听好友列表改变
	self.friend_callback = GlobalEventSystem:Bind(OtherEventType.FRIEND_INFO_CHANGE, BindTool.Bind(self.FriendListChange, self))
	--监听黑名单列表变化
	self.black_callback = GlobalEventSystem:Bind(OtherEventType.BLACK_LIST_CHANGE, BindTool.Bind(self.BlackListChange, self))
	self.top_toggle_list[1].toggle.isOn = true
	-- 不知道干嘛的，先屏蔽
	-- MainUICtrl.Instance:GetView():ShakeGuildChatBtn(false)
	local guild_answer_list = WorldQuestionData.Instance:GetGuildAnswerList()

	self:Flush("guild_answer")
	self:Flush("guild_question_rank")
	for k,v in pairs(self.guild_rank_cell_list) do
		v:Flush()
	end
	if GameVoManager.Instance:GetMainRoleVo().guild_id > 0 then
		-- self:OnTopTabClick(2,true)
		self.show_single_chat:SetValue(current_id > 0)
	else
		self.show_single_chat:SetValue(true)
	end

	self:FlushPawnScoreView()
	self:FlushRolePwanPank()
end

function GuildChatView:CountDown(elapse_time, total_time)
	self.time_text:SetValue(total_time - elapse_time)
	if elapse_time >= total_time then
		self.show_guild_question:SetValue(false)
		self.show_qiandao:SetValue(not IS_ON_CROSSSERVER)
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


function GuildChatView:CloseCallBack()
	self:UnBindFriend()
	self:UnBindBlack()
	for _, v in pairs(self.target_cell_list) do
		v:UnBindIsOnlineEvent()
	end

	self:CancelQuestionCountDown()
	local guild_result_list = WorldQuestionData.Instance:GetGuildResultList()
	if guild_result_list and next(guild_result_list) then
		WorldQuestionData.Instance:ClearGuildList()
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

function GuildChatView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function GuildChatView:OnTipsPopClick()
	GuildChatData.Instance:SetIsHidePopRect(self.tips_pop_bt.toggle.isOn)
end

function GuildChatView:GoCoolShop()
	-- ViewManager.Instance:Open(ViewName.CoolChat)
	ViewManager.Instance:Open(ViewName.Player, TabIndex.role_cool_chat)
end

function GuildChatView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(163)
end

function GuildChatView:OnClickHongBao(index)
	if GuildData.Instance:IsGetGuildHongBao(index) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.HasGetHongBao)
		return
	end
	if not GuildData.Instance:IsCanGetGuildHongBao(index) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.CannotGetHongBao)
		return
	end
	GuildCtrl.Instance:SendFetchGuildBossRedbagReq(index)
end

function GuildChatView:GoBottomClick()
	self.is_show_tips:SetValue(false)
	GuildChatData.Instance:SetChatNum(0)
	if ChatGuildView.Instance then
		ChatGuildView.Instance:GoToChatButtom()
	end
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

function GuildChatView:FlushShowTips(is_show)
	self.is_show_tips:SetValue(is_show)
	if is_show then
		self.tips_text:SetValue(GuildChatData.Instance:GetChatNum())
	end
end

function GuildChatView:FlushRoleTargetList()
	if self.role_list.scroller.isActiveAndEnabled then
		self.role_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function GuildChatView:FlushView()
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
	ChatData.Instance:SetRedChat(false)
	ChatData.Instance:SetGuildChatDaTi(false)
	MainUIViewChat.Instance:SetChatinfo(false)
	if GameVoManager.Instance:GetMainRoleVo().guild_id <= 0 then
		MainUIViewChat.Instance:ShowGuildChatIcon(false)
	end
end

function GuildChatView:HandleOpenItem()
	TipsCtrl.Instance:ShowPropView(TipsShowProViewFrom.FROM_GUILD)
end

--获取人物当前坐标
function GuildChatView:GetMainRolePos()
	local main_role = Scene.Instance.main_role

	if nil ~= main_role then
		local x, y = main_role:GetLogicPos()
		local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
		local open_line = PlayerData.Instance:GetAttr("open_line") or 0
		-- 如果此场景不能分线
		if open_line <= 0 then
			scene_key = -1
		end
		local pos_msg = string.format(Language.Chat.PosFormat, Scene.Instance:GetSceneName(), x, y)
		local edit_text = self.chat_input.input_field.text
		if ChatData.ExamineEditText(edit_text, 1) then
			self.chat_input.input_field.text = edit_text .. pos_msg
			local scene_id = Scene.Instance:GetSceneId()
			ChatData.Instance:InsertPointTab(Scene.Instance:GetSceneName(), x, y, scene_id, scene_key)
		end
	end
end

function GuildChatView:HandleInsertLocation()
	self:GetMainRolePos()
end

function GuildChatView:HandleVoiceStart()
	--是否有公会
	-- local main_vo = GameVoManager.Instance:GetMainRoleVo()
	-- if main_vo.guild_id <= 0 then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
	-- 	return
	-- end
	local channel_type = CHANNEL_TYPE.GUILD
	local current_id = ChatData.Instance:GetCurrentRoleId()
	if current_id == SPECIAL_CHAT_ID.TEAM then
		channel_type = CHANNEL_TYPE.TEAM
	elseif current_id == SPECIAL_CHAT_ID.CAMP then
		channel_type = CHANNEL_TYPE.CAMP
		if not ChatData.Instance:GetChannelCdIsEnd(channel_type) then
			local time = ChatData.Instance:GetChannelCdEndTime(channel_type) - Status.NowTime
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
			return
		end
	elseif current_id >= SPECIAL_CHAT_ID.ALL then
		channel_type = CHANNEL_TYPE.PRIVATE
	end
	ChatData.Instance:SetChannelCdEndTime(channel_type)
	AutoVoiceCtrl.Instance:ShowVoiceView(channel_type)
end

function GuildChatView:HandleVoiceStop()
	if AutoVoiceCtrl.Instance.view:IsOpen() then
		AutoVoiceCtrl.Instance.view:Close()
	end
end

--添加物品
function GuildChatView:SetData(data, is_equip)
	if not data or not next(data) then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then
		return
	end

	local text = self.chat_input.input_field.text
	if ChatData.ExamineEditText(text, 4) then
		local max = self.chat_input.input_field.characterLimit
		if StringUtil.GetCharacterCount(text .. "[" .. item_cfg.name .. "]") > max then
			self.chat_input.input_field.text = text
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.TooLong)
		else
			self.chat_input.input_field.text = text .. "[" .. item_cfg.name .. "]"
		end
		local cell_data = {}
		if is_equip then
			cell_data = EquipData.Instance:GetGridData(data.index)
		else
			cell_data = ItemData.Instance:GetGridData(data.index)
		end
		ChatData.Instance:InsertItemTab(cell_data, 2)
	end
end

function GuildChatView:HandleOpenRedPackage()
	local main_role = GameVoManager.Instance:GetMainRoleVo()
	if main_role.guild_id <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
		return
	end
	HongBaoCtrl.Instance:ShowHongBaoView(GameEnum.HONGBAO_SEND, RED_PAPER_TYPE.RED_PAPER_TYPE_COMMON)
end

-- 添加表情
function GuildChatView:SetFace(index)
	local face_id = string.format("%03d", index)
	local edit_text = self.chat_input.input_field
	if edit_text and ChatData.ExamineEditText(edit_text.text, 3) then
		local max = self.chat_input.input_field.characterLimit
		if StringUtil.GetCharacterCount(edit_text.text .. "/" .. face_id) > max then
			self.chat_input.input_field.text = edit_text.text
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.TooLong)
		else
			self.chat_input.input_field.text = edit_text.text .. "/" .. face_id
		end
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
	local current_id = ChatData.Instance:GetCurrentRoleId()
	local text = self.chat_input.input_field.text
	if text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		self.chat_input.input_field.text = ""
		return
	end
	local text = self.chat_input.input_field.text
	local content_type = CHAT_CONTENT_TYPE.TEXT
	--格式化字符串
	text = ChatData.Instance:FormattingMsg(text, content_type, 2)

	--屏蔽敏感词
	text = ChatFilter.Instance:Filter(text)
	if current_id <= 0 then
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, text, content_type)
		self.chat_input.input_field.text = ""
		ChatData.Instance:ClearInput()
	elseif current_id == SPECIAL_CHAT_ID.TEAM then
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.TEAM, text, content_type)
		self.chat_input.input_field.text = ""
		ChatData.Instance:ClearInput()
	elseif current_id == SPECIAL_CHAT_ID.CAMP then
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.CAMP, text, content_type)
		self.chat_input.input_field.text = ""
		ChatData.Instance:ClearInput()
	else
		self.is_send_chat = true
		CheckCtrl.Instance:SendQueryRoleInfoReq(current_id)
	end
end

function GuildChatView:RoleInfoCallBack(role_id, protocol)
	if not self.is_send_chat then return end
	self.is_send_chat = false
	local current_id = ChatData.Instance:GetCurrentRoleId()
	if role_id ~= current_id then
		return 
	end
	local text = self.chat_input.input_field.text
	local content_type = CHAT_CONTENT_TYPE.TEXT
	

	--格式化字符串
	text = ChatData.Instance:FormattingMsg(text, content_type, 2)
	-- if ChatFilter.Instance:IsIllegal(text) then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.ContentIsIllegal)
	-- 	return
	-- end
	--屏蔽敏感词
	text = ChatFilter.Instance:Filter(text)

	if protocol.role_is_online == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NotOnline)
		return
	end

	if role_id > 2 then
		local msg_info = ChatData.CreateMsgInfo()
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		msg_info.from_uid = main_vo.role_id
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

		ChatData.Instance:AddPrivateMsg(role_id, msg_info)
		ChatCtrl.SendSingleChat(role_id, text, content_type)
		self.guild_view:FlushGuildView(true)
	-- else
		-- ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, text, content_type)
	end
 
	-- 发送文字信息
	self.chat_input.input_field.text = ""
	ChatData.Instance:ClearInput()
end

function GuildChatView:FlushChatView(is_flush_view)
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	self.role_list_data = ChatData.Instance:GetPrivateObjList()
	--如果没有任何聊天对象则关闭界面
	-- 默认有国家聊天
	-- if guild_id <= 0 and #self.role_list_data <= 0 then
	-- 	self:Close()
	-- 	return
	-- end

	local open_camp = OpenFunData.Instance:CheckIsHide("camp")
	local camp_num = open_camp and 1 or 0

	local current_id = ChatData.Instance:GetCurrentRoleId()
	if current_id == 0 then
		self.select_target_index = 1
	elseif is_flush_view == "black_callback" then
		self.select_target_index = 1
		ChatData.Instance:SetCurrentRoleId(0)
	else

		local teap_list = ChatData.Instance:GetNormalChatList()
		for k, v in ipairs(self.role_list_data) do
			if current_id == v.role_id then
				if guild_id > 0 then
					if teap_list[1] then
						self.select_target_index = k + 2 + camp_num
					else
						self.select_target_index = k + 2
					end
				else
					if teap_list[1] then
						self.select_target_index = k + 1 + camp_num
					else
						self.select_target_index = k + 1
					end
				end
				break
			end
		end
	end


	self:FlushRightView(is_flush_view)
	if is_flush_view then
		self:FlushRoleInfo()
	end
	self:FlushRoleTargetList()
end

function GuildChatView:FlushRightView(is_flush_view)
	local current_id = ChatData.Instance:GetCurrentRoleId()
	if current_id == 0 then
		self.guild_view:FlushGuildView(false)
		if is_flush_view then
			self:FlushView()
			self:FlushHongBao()
		end
	elseif current_id == 2 then
		self.guild_view:FlushGuildTeamView()
	elseif current_id == 3 then
		self.guild_view:FlushGuildCampView()
		self:FlushCampAttr()
	else
		if is_flush_view or ChatData.Instance:GetIsHavePrivateUnreadMsg(current_id) then
			self.guild_view:FlushGuildView(true)
		end
	end
	self.show_single_chat:SetValue(current_id > 0)
	self.show_team_chat:SetValue(current_id == 2)
	self.show_camp_chat:SetValue(current_id == 3)
	self.show_private_chat:SetValue(current_id > 3)
	self.tips_pop_bt.toggle.isOn = GuildChatData.Instance:GetIsHidePopRect()
end

function GuildChatView:FlushCampAttr()
	local camp_info = CampData.Instance:GetCampInfo()
	if camp_info == nil or next(camp_info) == nil then
		return
	end
	if IS_ON_CROSSSERVER then
		camp_info = CampData.Instance:GetKeepCampInfoNotice()
	end

	local item_info = CampData.Instance:GetCampSaleItemList()
	local yunbiao = CampData.Instance:GetCampYunbiaoIsOpen()
	local banzhuan = NationalWarfareData.Instance:GetCampBanZhuanIsOpen()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	if yunbiao then
		self.CampYunBiao:SetValue(Language.Activity.KaiQiZhong)
	else
		self.CampYunBiao:SetValue(Language.Activity.YiJieShu)
	end
	if banzhuan then
		self.CampBanZhuan:SetValue(Language.Activity.KaiQiZhong)
	else
		self.CampBanZhuan:SetValue(Language.Activity.YiJieShu)
	end
	self.CampGoldNum:SetValue(item_info.camo_gold)
	self.CampFuHuoNum:SetValue(camp_info.reborn_dan_num)
	self.CampNotive:SetValue(camp_info.notice)
	local fate_tower_status_info = CampData.Instance:GetCampQiyunTowerStatus()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local item_list = fate_tower_status_info.item_list[role_vo.camp] -- 单个国家的状态
	if item_list then
		-- 衰弱/正常状态
		local time_reduce = 0
		for j = 1, GameEnum.MAX_CAMP_NUM do
			local time_reduce_tmp = item_list.speed_reduce_end_timestamp[j] - server_time
			if time_reduce_tmp > time_reduce then
				time_reduce = time_reduce_tmp
			end
		end

		local content = ""
		if time_reduce > 0 then
			-- content = string.format(Language.Camp.FateTopText[3], TimeUtil.FormatSecond2Str(time_reduce, 1))
			content = Language.Camp.FateTopText[3]
		else
			content = Language.Camp.FateTopText[1]
		end
			
		local time_increase = item_list.speed_increase_end_timestmap[role_vo.camp] - server_time
		if time_increase > 0 then
			content = string.format(Language.Camp.FateTopText[2], Language.Common.CampNameAbbr[role_vo.camp], TimeUtil.FormatSecond2Str(time_increase, 1))
		end
		self.CampQiYunTa:SetValue(content)
	end
end
function GuildChatView:FriendListChange(role_id)
	local current_id = ChatData.Instance:GetCurrentRoleId()
	if role_id and current_id == role_id then
		self:FlushRoleInfo()
	end
end

function GuildChatView:BlackListChange(role_id)
	local current_id = ChatData.Instance:GetCurrentRoleId()
	if current_id == role_id then
		ChatData.Instance:SetCurrentRoleId(0)
	end
	self:Flush("new_chat")
end

function GuildChatView:SetGuildSiLiaoRed(Value)
	if self:IsOpen() then
		self.show_guildchat_res:SetValue(false)
	end
end

--刷新队伍相关信息
function GuildChatView:FlushTeamView(is_init)
	self.team_data = ScoietyData.Instance:GetTeamUserList()
	self:FlushTeamList(is_init)

	local is_leader = ScoietyData.Instance:IsLeaderById(GameVoManager.Instance:GetMainRoleVo().role_id)
	if self.is_leader ~= nil then
		self.is_leader:SetValue(is_leader)
	end

	local can_enter_count = ScoietyData.Instance:GetCanEnterCount()
	if self.can_enter_member_count ~= nil then
		self.can_enter_member_count:SetValue(can_enter_count)
	end

	local add_exp = ScoietyData.Instance:GetTeamAddExp()
	if self.add_exp ~= nil then
		self.add_exp:SetValue(add_exp)
	end
end

function GuildChatView:FlushTeamList(is_init)
	if self.team_member_list and self.team_member_list.scroller.isActiveAndEnabled then
		if is_init then
			self.team_member_list.scroller:ReloadData(0)
		else
			self.team_member_list.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

--刷新私聊对象数据
function GuildChatView:FlushRoleInfo()
	local current_id = ChatData.Instance:GetCurrentRoleId()
	self.show_private_chat:SetValue(current_id > 3)
	self.show_team_chat:SetValue(current_id == 2)
	self.show_camp_chat:SetValue(current_id == 3)
	if current_id > 3 then
		local private_obj = ChatData.Instance:GetPrivateObjByRoleId(current_id)
		--设置头像
		local avatar_key_small = AvatarManager.Instance:GetAvatarKey(current_id)
		if avatar_key_small == 0 then
			self.show_normal_img:SetValue(true)
			if private_obj then
				local bundle, asset = AvatarManager.GetDefAvatar(private_obj.prof, false, private_obj.sex)
				self.normal_img_res:SetAsset(bundle, asset)
			end
		else
			AvatarManager.Instance:GetAvatar(current_id, false, BindTool.Bind(self.LoadAvatarChatCallBack, self, current_id))
		end

		--设置等级
		local lv, zhuan = PlayerData.GetLevelAndRebirth(private_obj.level)
		local level_des = string.format(Language.Common.LevelFormat, lv, zhuan)
		self.role_level:SetValue(level_des)
		self.role_prof:SetValue(ToColorStr(PlayerData.GetProfNameByType(private_obj.prof), PROF_COLOR[private_obj.prof]))
		-- self.show_guild_name:SetValue(private_obj.guildname ~= "")
		if private_obj.guildname ~= "" then 
			self.role_guild:SetValue(private_obj.guildname)
		else
			self.role_guild:SetValue(Language.Guild.NoOpponentGuild)
		end
		local btn_text = Language.Menu.AddFriend
		if ScoietyData.Instance:IsFriendById(current_id) then
			btn_text = Language.Menu.GiveFlower
		end
		self.add_friend_text:SetValue(btn_text)
		self.ShowPlayBtn:SetValue(false)
		self.ShowTisPawn:SetValue(false)
		self.ShowQuilkLiao:SetValue(false)
		self.show_camp_quick:SetValue(false)
		self.show_qiandao:SetValue(false)
		-- if self.pawn_show_time then
		-- 	GlobalTimerQuest:CancelQuest(self.pawn_show_time)
		-- 	self.pawn_show_time = nil
		-- end
	elseif current_id == 2 then
		ChatData.Instance:RemTeamUnreadMsg()
		self.ShowTisPawn:SetValue(false)
		self.ShowPlayBtn:SetValue(false)
		self.ShowQuilkLiao:SetValue(false)
		self.show_camp_quick:SetValue(false)
		self.show_qiandao:SetValue(false)
		self:FlushTeamView(true)
	elseif current_id == 3 then
		self.ShowTisPawn:SetValue(false)
		self.ShowPlayBtn:SetValue(false)
		self.ShowQuilkLiao:SetValue(false)
		self.show_qiandao:SetValue(false)
		self.show_camp_quick:SetValue(true)
	else
		self.ShowPlayBtn:SetValue(not IS_ON_CROSSSERVER)
		self.show_qiandao:SetValue(not IS_ON_CROSSSERVER)
		self.ShowQuilkLiao:SetValue(true)
		self.show_camp_quick:SetValue(false)
		--请求骰子信息
		PlayPawnCtrl.Instance:SendGetPaoSaiziInfo()
		--添加定时出现的骰子信息提示
		-- if self.pawn_show_time then
		-- 	GlobalTimerQuest:CancelQuest(self.pawn_show_time)
		-- 	self.pawn_show_time = nil
		-- end
		-- self:ShowPawnUpade()
		-- self.pawn_show_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.ShowPawnUpade, self), 10)
	end
end

function GuildChatView:LoadAvatarChatCallBack(role_id, path)
	if not self:IsOpen() then
		return
	end
	local current_id = ChatData.Instance:GetCurrentRoleId()
	if role_id ~= current_id then
		self.show_normal_img:SetValue(true)
		return
	end
	if path == nil then
		path = AvatarManager.GetFilePath(role_id, false)
	end
	self.show_normal_img:SetValue(false)
	GlobalTimerQuest:AddDelayTimer(function()
 		self.custom_img_res:SetValue(path)
 	end, 0)
end

-- 公会骰子气泡提示
function GuildChatView:ShowPawnUpade()
	-- 玩家是否剩余抛骰子次数
	local can_play = PlayPawnData.Instance:CanPlayPwan()
	-- 抛骰子冷却时间是否足够
	-- local play_cd = PlayPawnData.Instance:GetPlayCDTime()
	if can_play then
		if self.delay_shou_qipao then
			GlobalTimerQuest:CancelQuest(self.delay_shou_qipao)
			self.delay_shou_qipao = nil
		end
		self.ShowTisPawn:SetValue(true)
		self.delay_shou_qipao = GlobalTimerQuest:AddDelayTimer(function ()
			self.ShowTisPawn:SetValue(false)
		end, 5)
	else
		-- if self.pawn_show_time then
		-- 	GlobalTimerQuest:CancelQuest(self.pawn_show_time)
		-- 	self.pawn_show_time = nil
		-- end
		self.ShowTisPawn:SetValue(false)
	end
end

function GuildChatView:OnFlush(params_t)
	local current_id = ChatData.Instance:GetCurrentRoleId()
	for k, v in pairs(params_t) do
		if k == "view" and current_id <= 0 then
			self:FlushView()
		elseif k == "hongbao" and current_id <= 0 then
			self:FlushHongBao()
		elseif k == "new_chat" then
			if v[1] == "all" then
				self:FlushChatView()
			else
				self:FlushChatView(v[1])
			end
		elseif k == "guild_answer" or k == "guild_qustion_result" then
			--self:FlushAnswer()
		elseif k == "guild_question_rank" then
			self:FlushQuestionRank()
		elseif current_id <= 0 then
			self:FlushView()
		end
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

function GuildChatView:FlushAnswer()
	local question_data = WorldQuestionData.Instance
	local guild_answer_list = question_data:GetGuildAnswerList()
	local guild_result_list = question_data:GetGuildResultList()
	local is_had_guild_answer = next(guild_answer_list) ~= nil
	local is_had_guild_result = next(guild_result_list) ~= nil
	local current_id = ChatData.Instance:GetCurrentRoleId()
	local select_index = WorldQuestionData.Instance:GetSelectQuestion(WORLD_GUILD_QUESTION_TYPE.GUILD)
	local role_info = GameVoManager.Instance:GetMainRoleVo()

	--是否显示公会答题
	self.show_guild_question:SetValue((is_had_guild_answer or is_had_guild_result) and current_id <= 0 and role_info.guild_id > 0)
	--没有答题任何信息时
	if not is_had_guild_answer and not is_had_guild_result then
		return
	end

	--显示答案状态
	if guild_result_list and is_had_guild_result then
		--进入已完成状态时
		if self.complete_flag == true then
			WorldQuestionData.Instance:ClearGuildList()
			self.show_guild_question:SetValue(false)
			-- self.show_qiandao:SetValue(false)
			return
		end

		--时间小于0
		local time = guild_answer_list.cur_question_end_time - TimeCtrl.Instance:GetServerTime()
		if time <= 0 then
			self:CancelQuestionCountDown()
			self.show_guild_question:SetValue(false)
			-- self.show_qiandao:SetValue(false)
			WorldQuestionData.Instance:ClearGuildList()
			return
		end

		for i=1,4 do
			self.answer_list[i].show_answer:SetValue(select_index == i or guild_result_list.result + 1 == i)
		end

		--显示正确与错误
		self.answer_list[select_index].answer_right:SetValue(guild_result_list.result + 1 == select_index)
		self.answer_list[guild_result_list.result + 1].answer_right:SetValue(true)

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
		self.show_guild_question:SetValue(remain_time >= ANSWER_TIME_LIMIT and current_id <= 0)
		if remain_time < ANSWER_TIME_LIMIT then
			return
		end

		--显示题目和选项
		self.question_title:SetValue(guild_answer_list.question)
		for i=1,4 do
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

function GuildChatView:FlushQuestionRank()
	for k,v in pairs(self.guild_rank_cell_list) do
		v:Flush()
	end
end

function GuildChatView:FlushHongBao()
	local daily_kill_boss_times = GuildDataConst.GUILDVO.daily_kill_boss_times or 0
	if self.slider and self.slider.slider then
		self.slider.slider.value = math.min(1, daily_kill_boss_times / self.max_boss_count)
	end

	if self.hong_bao_value then
		self.hong_bao_value:SetValue(daily_kill_boss_times .. "/" .. self.max_boss_count)
	end
	
	for k,v in pairs(self.info_table) do
		v:Flush()
	end
	local max_boss_count = GuildData.Instance:GetMaxHongBaoCount() or 0
	for i = 0, max_boss_count - 1 do
		local has_get = GuildData.Instance:IsGetGuildHongBao(i)
		if not has_get and GuildData.Instance:IsCanGetGuildHongBao(i) then
			local value = self.percent_table[i + 1] or 0
			self:JumpToValue(value)
			break
		end
	end
end

function GuildChatView:InitHongBao()
	self.info_table = {}
	self.percent_table = {}
	self.original_width = self.scroller_rect.rect.sizeDelta.x
	self.original_hight = self.scroller_content.rect.sizeDelta.y
	local distance = self.original_width / HongBaoCount
	local count = GuildData.Instance:GetMaxHongBaoCount() or 0
	local width = self.original_width
	if count > HongBaoCount then
		width = self.original_width * count / HongBaoCount
    	self.scroller_content.rect.sizeDelta = Vector2(width, self.original_hight)
    end

    if count > HongBaoCount then
    	for i = count, 1, -1 do
    		if count - i < HongBaoCount then
    			self.percent_table[i] = 1
    		else
    			self.percent_table[i] = (i - 1) / (count - HongBaoCount)
    		end
    	end
    end

	PrefabPool.Instance:Load(AssetID("uis/views/chatview_prefab", "GuildHongBao"), function(prefab)
        if nil == prefab then
            return
        end
        local offset = (width - 20) / count
        for i = 1, count do
            local obj = GameObject.Instantiate(prefab)
            local obj_transform = obj.transform
            if self.hong_bao_panel then
	            obj_transform:SetParent(self.hong_bao_panel.transform, false)
	        end
	            obj_transform.localPosition = Vector3(width + (1 - i) * offset, 0, 0)
            self.info_table[i] = GuildChatHongBaoCell.New(U3DObject(obj))
            self.info_table[i]:SetIndex(count - i)
            self.info_table[i]:ListenClick(BindTool.Bind(self.OnClickHongBao, self))
        end

        PrefabPool.Instance:Free(prefab)
        self:FlushHongBao()
    end)
end

function GuildChatView:OnValueChange(value)
	local x = value.x
	if x <= 0.01 then
		self.show_left_arrow:SetValue(false)
	else
		self.show_left_arrow:SetValue(true)
	end
	if x >= 0.99 then
		self.show_right_arrow:SetValue(false)
	else
		self.show_right_arrow:SetValue(true)
	end
end

function GuildChatView:JumpTo()
	local count = GuildData.Instance:GetMaxHongBaoCount() or 0
	local index = 0
	for i = 0, count - 1 do
		if GuildData.Instance:IsCanGetGuildHongBao(i) and not GuildData.Instance:IsGetGuildHongBao(i) then
			index = i
			break
		end
	end
	index = 6
	if index + HongBaoCount > count then
		index = math.max(count - HongBaoCount, 0)
	end
	self.scroller_rect:GetComponent(typeof(UnityEngine.UI.ScrollRect)).normalizedPosition = Vector2(index / count, 1)
end

function GuildChatView:JumpToValue(value)
	self.scroller_rect:GetComponent(typeof(UnityEngine.UI.ScrollRect)).normalizedPosition = Vector2(value, 1)
end

function GuildChatView:OnClickLeft()
	local x = self.scroller_rect:GetComponent(typeof(UnityEngine.UI.ScrollRect)).normalizedPosition.x
	x = math.max(0, x)
	x = math.min(1, x)
	local value = x - 0.01
	for i = #self.percent_table, 1, -1 do
		if self.percent_table[i] < value then
			value = self.percent_table[i]
			break
		end
	end
	self:JumpToValue(value)
end

function GuildChatView:FriendClick()
	local current_id = ChatData.Instance:GetCurrentRoleId()
	if current_id > 0 then
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
	local current_id = ChatData.Instance:GetCurrentRoleId()
	if current_id > 0 then
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
	local current_id = ChatData.Instance:GetCurrentRoleId()
	if current_id > 0 then
		CheckData.Instance:SetCurrentUserId(current_id)
		CheckCtrl.Instance:SendQueryRoleInfoReq(current_id)
		ViewManager.Instance:Open(ViewName.CheckEquip)
	end
end

function GuildChatView:TradeClick()
	local current_id = ChatData.Instance:GetCurrentRoleId()
	if current_id > 0 then
		TradeCtrl.Instance:SendTradeRouteReq(current_id)
	end
end

function GuildChatView:BlackClick()
	local current_id = ChatData.Instance:GetCurrentRoleId()
	if current_id > 0 then
		local private_obj = ChatData.Instance:GetPrivateObjByRoleId(current_id) or {}
		local function yes_func()
			ScoietyCtrl.Instance:AddBlackReq(current_id)
		end

		local describe = string.format(Language.Society.AddBlackDes, private_obj.username or "")
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	end
end

function GuildChatView:TrackClick()
	local current_id = ChatData.Instance:GetCurrentRoleId()
	if current_id > 0 then
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
	self:CallRemindInit()
	local current_id = ChatData.Instance:GetCurrentRoleId()
	if current_id == 0 then
		self.play_pawn_btn:SetValue(false)
		self.show_pawn_rp:SetValue(false)
		PlayPawnCtrl.Instance:OpenPlayPawnView()
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Guild.PawnTips)
	end
end

function GuildChatView:OpenSingInBtn()
	GuildCtrl.Instance:OpenSigninView()
end

function GuildChatView:ClickQuick()
	ChatCtrl.Instance:OpenQuickChatView(QUICK_CHAT_TYPE.GUILD)
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
			local item_cfg = ItemData.Instance:GetItemConfig(guild_rank_reward.item_id or 0)
			if item_cfg and next(item_cfg) then
				self.flower_img_pawn:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
			end
			self.item_text_pawn:SetValue(guild_rank_reward.num or 0)
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
	--玩家是否剩余抛骰子次数
	local can_play = PlayPawnData.Instance:CanPlayPwan()
	local remind_tag = GuildChatData.Instance:GetPlayPawnRemind()
	--抛骰子冷却时间是否足够
	local play_cd = PlayPawnData.Instance:GetPlayCDTime()
	--冷却中
	if play_cd > 0  then
		if can_play then
			self.guild_pawn_text:SetValue("")
			self.TimePawnText:SetValue(TimeUtil.FormatSecond(play_cd,2))
		else
			self.TimePawnText:SetValue("")
			self.guild_pawn_text:SetValue("")
		end
		self.play_pawn_btn:SetValue(false)
		self.show_pawn_rp:SetValue(false)
	else
		if self.next_timer then
			GlobalTimerQuest:CancelQuest(self.next_timer)
			self.next_timer = nil
		end
		if can_play then
			local play_num = PlayPawnData.Instance:GetCanPlayPwanNum()
			self.guild_pawn_text:SetValue(string.format(Language.Chat.CanPlayNum,play_num))
			self.play_pawn_btn:SetValue(true)
			if 1 == remind_tag then
				self.show_pawn_rp:SetValue(true)
			end
			self.TimePawnText:SetValue("")
		else
			self.guild_pawn_text:SetValue("")
			self.play_pawn_btn:SetValue(false)
			self.show_pawn_rp:SetValue(false)
		end
	end
end

function GuildChatView:OnClickRight()
	local x = self.scroller_rect:GetComponent(typeof(UnityEngine.UI.ScrollRect)).normalizedPosition.x
	x = math.max(0, x)
	x = math.min(1, x)
	local value = x + 0.01
	for k,v in ipairs(self.percent_table) do
		if v > value then
			value = v
			break
		end
	end
	self:JumpToValue(value)
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

function GuildChatView:ClickQuickChat()
	if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.CAMP) then
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Chat.WorldChatCD)
		return
	end
	local function callback(str)
		local level = GameVoManager.Instance:GetMainRoleVo().level
		--等级限制
		if level < ChatData.Instance:GetChatOpenLevel(CHAT_OPENLEVEL_LIMIT_TYPE.CAMP) then
			local level_str = PlayerData.GetLevelString(ChatData.Instance:GetChatOpenLevel(CHAT_OPENLEVEL_LIMIT_TYPE.CAMP))
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, level_str))
			return
		end
		--设置世界聊天冷却时间
		ChatData.Instance:SetChannelCdEndTime(CHANNEL_TYPE.CAMP)
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.CAMP, str, CHAT_CONTENT_TYPE.TEXT)
		self:UpdateChatCD()
	end
	ChatCtrl.Instance:OpenQuickChatView(QUICK_CHAT_TYPE.NORMAL, callback)
end

-- 刷新快捷聊天冷却时间显示
function GuildChatView:UpdateChatCD()
	self:ClearChatCD()
	local function timer_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self:ClearChatCD()
			self.chat_cd:SetValue("")
			return
		end
		self.chat_cd:SetValue(math.ceil(total_time - elapse_time))
	end
	local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.CAMP) - Status.NowTime
	time = math.ceil(time)
	self.chat_cd:SetValue(time)
	self.chat_cd_count_down = CountDown.Instance:AddCountDown(time, 1, timer_func)
end

function GuildChatView:ClearChatCD()
	if self.chat_cd_count_down then
		CountDown.Instance:RemoveCountDown(self.chat_cd_count_down)
		self.chat_cd_count_down = nil
	end
end

-------------------------------------
-- member_list_view 逻辑
-------------------------------------
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

--------------------------------------------------------------------------
-- MemberCell 	成员格子
--------------------------------------------------------------------------
MemberCell = MemberCell or BaseClass(BaseCell)

function MemberCell:__init(instance)
	self.avatar_key = 0
	self:IconInit()
end

function MemberCell:__delete()
	self.avatar_key = 0
end

function MemberCell:IconInit()
	self.name = self:FindVariable("Name")
	self.post = self:FindVariable("Post")
	self.is_online = self:FindVariable("is_online")
	self.image_res = self:FindVariable("ImageRes")
	self.show_image = self:FindVariable("ShowImage")
	self.raw_img_obj = self:FindObj("RawImageObj")
	self.gray_bg = self:FindObj("GrayNotLinkBg")
	self.name_obj = self:FindObj("NameObj")
	self.name_obj_component = self.name_obj:GetComponent(typeof(UnityEngine.UI.Text))
	self.active_str = self:FindVariable("ActiveStr")
	self.head_frame_res = self:FindVariable("head_frame_res")

	self:ListenEvent("ClickItem",BindTool.Bind(self.OnClickItem, self))
end

-- 选择成员
function MemberCell:OnSelectMember()
    if GuildDataConst.GUILD_MEMBER_LIST.list and GuildDataConst.GUILD_MEMBER_LIST.list[self.index].uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
        local info = GuildData.Instance:GetGuildMemberInfo()
        if info then
            local detail_type = ScoietyData.DetailType.Default
            if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
                detail_type = ScoietyData.DetailType.GuildTuanZhang
            elseif info.post == GuildDataConst.GUILD_POST.FU_TUANGZHANG or info.post == GuildDataConst.GUILD_POST.ZHANG_LAO then
                detail_type = ScoietyData.DetailType.Guild
            end

			local function canel_callback()
				if self.root_node ~= nil and self.root_node.toggle ~= nil and self.root_node.toggle.isOn ~= nil then
					self.root_node.toggle.isOn = false
				end
			end
            ScoietyCtrl.Instance:ShowOperateList(detail_type, GuildDataConst.GUILD_MEMBER_LIST.list[self.index].role_name, nil, canel_callback)
        end
    end
end

function MemberCell:OnClickItem()
	self:OnSelectMember()
end

function MemberCell:OnFlush()
	if not next(self.data) then return end

	if self.data.month_sign_day then
		local signin_title_cfg = GuildData.Instance:GetSigninTitleOneCfg(self.data.month_sign_day)
		if signin_title_cfg ~= nil and signin_title_cfg.name ~= nil then
			self.active_str:SetValue(signin_title_cfg.name)
		end
	end

	self.name:SetValue(self.data.role_name)
	local post_str = GuildData.Instance:GetGuildPostNameByPostId(self.data.post)
	self.post:SetValue(post_str)
	self:SetIconImage()
	if #self.data.role_name > 15 then  
		self.name_obj_component.alignment = UnityEngine.TextAnchor.MiddleLeft
	else
		self.name_obj_component.alignment = UnityEngine.TextAnchor.MiddleCenter
	end

	if self.data.is_online ~= 0 then
		self.is_online:SetValue(true)
		self.gray_bg.grayscale.GrayScale = 0
	else
		self.is_online:SetValue(false)
		self.gray_bg.grayscale.GrayScale = 200
	end

	local role_id = GuildDataConst.GUILD_MEMBER_LIST.list[self.index].uid
	CommonDataManager.SetAvatarFrame(role_id, self.head_frame_res)
end

function MemberCell:MemberLoadCallBack(uid, raw_img_obj, path)
	if self:IsNil() then
		return
	end
	if uid ~= self.data.uid then
		self.show_image:SetValue(true)
		return
	end
	if path == nil then
		path = AvatarManager.GetFilePath(self.data.uid, false)
	end
	raw_img_obj.raw_image:LoadSprite(path, function ()
		if uid ~= self.data.uid then
			self.show_image:SetValue(true)
			return
		end
		self.show_image:SetValue(false)
	end)
end

function MemberCell:SetIconImage()
	local avatar_key = AvatarManager.Instance:GetAvatarKey(self.data.uid)
	if avatar_key == 0 then
		self.avatar_key = 0
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		self.image_res:SetAsset(bundle, asset)
		self.show_image:SetValue(true)
	else
		if avatar_key ~= self.avatar_key then
			self.avatar_key = avatar_key
			AvatarManager.Instance:GetAvatar(self.data.uid, false, BindTool.Bind(self.MemberLoadCallBack, self, self.data.uid, self.raw_img_obj))
		end
	end
end


-------------------公会骰子---------------------

function GuildChatView:InitPawnListView()
	self.pwan_rank_list_view = self:FindObj("PwanRankListView")
	local list_delegate = self.pwan_rank_list_view.list_simple_delegate
	--有有多少个cell
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCurrScoreOfCells, self)
	--更新cell
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
--------------------------------------------------------------------------
-- GuildPawnRankCell 	骰子积分排名
--------------------------------------------------------------------------
GuildPawnRankCell = GuildPawnRankCell or BaseClass(BaseCell)

function GuildPawnRankCell:__init(instance)

	self:RankInit()
end

function GuildPawnRankCell:__delete()
 	self.RoleName  = nil
 	self.RoleScore  = nil
 	self.RoleRankNum  = nil
 	self.Flower  = nil
 	self.FlowerCount  = nil
end

function GuildPawnRankCell:RankInit()
	self.RoleName    = self:FindVariable("RoleName")
	self.RoleScore   = self:FindVariable("RoleScore")
	self.RoleRankNum = self:FindVariable("RoleRankNum")
	self.Flower      = self:FindVariable("Flower")
	self.FlowerCount = self:FindVariable("FlowerCount")
end

function GuildPawnRankCell:OnFlush()
	if not next(self.data) then return end
	self.RoleName:SetValue(self.data.name)
	self.RoleScore:SetValue(self.data.score)
	self.RoleRankNum:SetValue(self:GetIndex())

	local guild_rank_reward = PlayPawnData.Instance:GetRankReward(self:GetIndex())
	if guild_rank_reward and next(guild_rank_reward) then
		local item_cfg = ItemData.Instance:GetItemConfig(guild_rank_reward.item_id or 0)
		if item_cfg and next(item_cfg) then
			self.Flower:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
		end
		self.FlowerCount:SetValue(guild_rank_reward.num or 0)
	end
end

function GuildPawnRankCell:SetSorceToggleIsOn(ison)
	local now_ison = self.root_node.toggle.isOn
	if ison == now_ison then
		return
	end
	self.root_node.toggle.isOn = ison
end

function GuildPawnRankCell:LoadCallBack(uid, raw_img_obj, path)
end



-------------------------------------------------红包------------------------------------------------

GuildChatHongBaoCell = GuildChatHongBaoCell or BaseClass(BaseCell)

function GuildChatHongBaoCell:__init()
	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))
	self.show_effect = self:FindVariable("ShowEffect")
	self.gray = self:FindVariable("Gray")
	self.boss_count = self:FindVariable("BossCount")
end

function GuildChatHongBaoCell:__delete()
	self.callback = nil
end

function GuildChatHongBaoCell:OnFlush()
	local has_get = GuildData.Instance:IsGetGuildHongBao(self.index)
	if GuildData.Instance:IsCanGetGuildHongBao(self.index) and not has_get then
		self.show_effect:SetValue(true)
	else
		self.show_effect:SetValue(false)
	end
	if has_get then
		self.gray:SetValue(true)
	else
		self.gray:SetValue(false)
	end
	local need_count = GuildData.Instance:GetGuildHongBaoKillCount(self.index) or 0
	self.boss_count:SetValue(need_count)
end

function GuildChatHongBaoCell:ListenClick(callback)
	self.callback = callback
end

function GuildChatHongBaoCell:OnClick()
	if self.callback then
		self.callback(self.index)
	end
end

-----------------------------------ChatTargetItem----------------------------------
ChatTargetItem = ChatTargetItem or BaseClass(BaseCell)
function ChatTargetItem:__init()
	self.name = self:FindVariable("Name")
	self.normal_img_res = self:FindVariable("ImgRes")
	self.custom_img_res = self:FindVariable("RawImgRes")
	self.is_online = self:FindVariable("IsOnline")
	self.show_normal_img = self:FindVariable("ShowImage")
	self.show_remind = self:FindVariable("ShowRemind")
	self.can_close = self:FindVariable("CanClose")
	self.remind_text = self:FindVariable("RemindText")
	self.show_red = self:FindVariable("ShowPointRed")

	self:ListenEvent("ClickClose", BindTool.Bind(self.ClickClose, self))
	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function ChatTargetItem:__delete()
	self:UnBindIsOnlineEvent()
end

function ChatTargetItem:RoleIsOnlineChange(role_id, is_online)
	if role_id == self.data.role_id then
		if self.is_online then
			self.is_online:SetValue(is_online == 1)
		end
	end
end

function ChatTargetItem:ClickClose()
	if self.data.is_guild then
		ChatData.Instance:SetIsShowGuild(false)
	else
		ChatData.Instance:SetCurrentRoleId(0)
		local index = ChatData.Instance:GetPrivateIndex(self.data.role_id)
		ChatData.Instance:RemovePrivateObjByIndex(index)
	end
	ViewManager.Instance:FlushView(ViewName.ChatGuild, "new_chat")
end

function ChatTargetItem:SetToggleIsOn(ison)
	local now_ison = self.root_node.toggle.isOn
	if ison == now_ison then
		return
	end
	self.root_node.toggle.isOn = ison
end

function ChatTargetItem:SetRemind(state)
	self.show_remind:SetValue(state)
end

function ChatTargetItem:LoadAvatarCallBack(role_id, path)
	if self:IsNil() then
		return
	end

	if role_id ~= self.data.role_id then
		self.show_normal_img:SetValue(true)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(role_id, false)
	end
	self.show_normal_img:SetValue(false)
	GlobalTimerQuest:AddDelayTimer(function()
 		self.custom_img_res:SetValue(path)
 	end, 0)
end

function ChatTargetItem:UnBindIsOnlineEvent()
	if self.role_event_system then
		GlobalEventSystem:UnBind(self.role_event_system)
		self.role_event_system = nil
	end
end

function ChatTargetItem:BindIsOnlineEvent()
	--监听玩家上下线
	self.role_event_system = GlobalEventSystem:Bind(OtherEventType.ROLE_ISONLINE_CHANGE, BindTool.Bind(self.RoleIsOnlineChange, self))
end

function ChatTargetItem:OnFlush()
	if not self.data then
		return
	end
	if nil ~= self.data.is_online then
		self.is_online:SetValue(self.data.is_online == 1)
	else
		self.is_online:SetValue(true)
	end
	local name = ""
	if self.data.is_guild then
		local guild_unread_msg = ChatData.Instance:GetGuildUnreadMsg()
		local red_flag = GuildChatData.Instance:GetGuildChatRemind()
		if nil == guild_unread_msg then
			self:SetRemind(false)
		else
			self:SetRemind(true)
			self.remind_text:SetValue(#guild_unread_msg)
		end
		self.can_close:SetValue(false)
		self.normal_img_res:SetAsset(ResPath.GetChatRes("icon_avtar_guild"))
		self.show_normal_img:SetValue(true)
		name = GameVoManager.Instance:GetMainRoleVo().guild_name
		self.show_red:SetValue(red_flag)
	elseif self.data.role_id == SPECIAL_CHAT_ID.TEAM then
		--队伍
		self.show_normal_img:SetValue(true)
		self.normal_img_res:SetAsset(ResPath.GetChatRes("icon_avtar_team"))
		name = Language.Society.TeamDes
		self.can_close:SetValue(false)
	elseif self.data.role_id == SPECIAL_CHAT_ID.CAMP then
		self.show_normal_img:SetValue(true)
		self.normal_img_res:SetAsset(ResPath.GetChatRes("icon_avtar_camp"))
		name = Language.Society.CampDes
		self.can_close:SetValue(false)
	else
		local role_id = self.data.role_id
		local unread_msg_count = ChatData.Instance:GetPrivateUnreadMsgCountById(role_id)
		if unread_msg_count > 0 then
			self:SetRemind(true)
			self.remind_text:SetValue(unread_msg_count)
		else
			self:SetRemind(false)
		end
		self.can_close:SetValue(true)
		local avatar_key_small = AvatarManager.Instance:GetAvatarKey(role_id)
		if avatar_key_small == 0 then
			self.show_normal_img:SetValue(true)
			if self.data.prof and self.data.sex then
				local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
				self.normal_img_res:SetAsset(bundle, asset)
			end
		else
			AvatarManager.Instance:GetAvatar(role_id, false, BindTool.Bind(self.LoadAvatarCallBack, self, role_id))
		end
		name = self.data.username
	end
	self.name:SetValue(name)
end

-----------------------------------GuildRankCell----------------------------------
GuildRankCell = GuildRankCell or BaseClass(BaseCell)
function GuildRankCell:__init(instance, parent)
	self.parent = parent
	self.rank_text = self:FindVariable("rank_text")
	self.name = self:FindVariable("name")
	self.count = self:FindVariable("count")
	self.item_text = self:FindVariable("item_text")
	self.flower_img = self:FindVariable("flower_img")
end

function GuildRankCell:__delete()
	self.parent = nil
end

function GuildRankCell:OnFlush()
	local cur_index = self.parent:GetCurIndex()
	if cur_index == GUILD_TOP_TOGGLE_NAME.QUESTION then
		local reward_cfg = {}
		local reward_num = reward_cfg.num
		local rank_list = WorldQuestionData.Instance:GetGuildQuestionRank()
		self.root_node.gameObject:SetActive(true)
		if self.index < 4 then
			reward_cfg = WorldQuestionData.Instance:GetGuildRankRewardCfgByRank(self.index)
			if rank_list and next(rank_list) then
				if rank_list[self.index] and next(rank_list[self.index]) and rank_list[self.index].uid ~= 0 then
					self.root_node.gameObject:SetActive(true)
					self.rank_text:SetValue(self.index)
					self.name:SetValue(rank_list[self.index].name)
					self.count:SetValue(rank_list[self.index].right_answer_num)
				else
					self.root_node.gameObject:SetActive(false)
				end
			else
				self.root_node.gameObject:SetActive(false)
			end
		else
			--自己排名
			local role_name = GameVoManager.Instance:GetMainRoleVo().role_name
			local my_answer = WorldQuestionData.Instance:GetMyQustionNum(WORLD_GUILD_QUESTION_TYPE.GUILD)
			local my_rank = WorldQuestionData.Instance:GetMyRank()
			reward_cfg = WorldQuestionData.Instance:GetMyReward(my_rank)
			local rank_text = my_rank == -1 and "-" or tostring(my_rank)
			self.rank_text:SetValue(rank_text)
			self.name:SetValue(role_name)
			self.count:SetValue(my_answer)
		end

		local reward_str = reward_cfg.num
		if reward_cfg.is_coin ~= nil and reward_cfg.is_coin == 1 and reward_cfg.coin_str ~= nil then
			reward_str = reward_cfg.coin_str
		end
		self.item_text:SetValue(reward_str)
		local item_cfg = ItemData.Instance:GetItemConfig(reward_cfg.item_id)
		if item_cfg and next(item_cfg) then
			self.flower_img:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
		end
	elseif cur_index == GUILD_TOP_TOGGLE_NAME.SHAI_ZI then --骰子

	end
end
