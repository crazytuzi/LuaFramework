require("game/chat/chat_data")
require("game/chat/chat_view")
require("game/chat/guild_chat_view")
require("game/chat/guild_chat_data")
require("game/chat/chat_filter")
require("game/chat/voice_setting_view")
require("game/chat/chat_notice_view")

ChatCtrl = ChatCtrl or BaseClass(BaseController)

function ChatCtrl:__init()
	if ChatCtrl.Instance then
		print_error("[ChatCtrl]:Attempt to create singleton twice!")
	end
	ChatCtrl.Instance = self

	self.data = ChatData.New()
	self.view = ChatView.New(ViewName.Chat)
	self.filter = ChatFilter.New()
	self.guild_chat_view = GuildChatView.New(ViewName.ChatGuild)
	self.guild_chat_data = GuildChatData.New()
	self.chat_notice_view = ChatNoticeView.New()
	self.voice_setting_view = VoiceSettingView.New(ViewName.VoiceSetting)

	self.interval = 1							--添加消息间隔
	self.next_send_system_time = 0 				--下次发系统送消息时间
	self.next_send_world_time = 0 				--下次发世界送消息时间

	self.world_time_quest = nil				--世界聊天计时器
	self.system_time_quest = nil			--系统聊天计时器
	self.cross_server_flag = false

	self.auto_play_voice_list = {}			--自动播放语音队列
	self.item_change = BindTool.Bind1(self.ItemDataChangeCallback, self)

	self.hear_say_event = GlobalEventSystem:Bind(SettingEventType.CLOSE_HEARSAY, BindTool.Bind(self.ChangeHearSayState, self))
	RemindManager.Instance:Register(RemindName.PlayerChat, BindTool.Bind(self.ChatChangeRemind, self))

	self.role_attr_change_callback = BindTool.Bind(self.ListenRoleAttrChange, self)
	PlayerData.Instance:ListenerAttrChange(self.role_attr_change_callback)

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
	self:RegisterAllProtocols()
end

function ChatCtrl:GetView()
	return self.view
end

function ChatCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	ChatCtrl.Instance = nil
	if self.hear_say_event then
		GlobalEventSystem:UnBind(self.hear_say_event)
		self.hear_say_event = nil
	end

	if self.filter then
		self.filter:DeleteMe()
		self.filter = nil
	end

	if self.guild_chat_view then
		self.guild_chat_view:DeleteMe()
		self.guild_chat_view = nil
	end

	if self.guild_chat_data then
		self.guild_chat_data:DeleteMe()
		self.guild_chat_data = nil
	end

	if self.voice_setting_view then
		self.voice_setting_view:DeleteMe()
		self.voice_setting_view = nil
	end

	if self.item_change then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end

	if self.chat_notice_view then
		self.chat_notice_view:DeleteMe()
		self.chat_notice_view = nil
	end
	RemindManager.Instance:UnRegister(RemindName.PlayerChat)
	PlayerData.Instance:UnlistenerAttrChange(self.role_attr_change_callback)
	self.role_attr_change_callback = nil
	--清空所有语音缓存
	ChatRecordMgr.Instance:RemoveAllRecord()

	self:ClearWorldTimeQuest()
	self:ClearSystemTimeQuest()
end

function ChatCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSChannelChatReq)					--请求频道聊天
	self:RegisterProtocol(CSSingleChatReq)					--请求私人聊天
	self:RegisterProtocol(CSSpeaker)						--发送喇叭

	self:RegisterProtocol(SCChannelChatAck, "OnChannelChat")
	self:RegisterProtocol(SCSingleChatAck, "OnSingleChat")
	self:RegisterProtocol(SCSingleChatUserNotExist, "OnSingleChatUserNotExist")
	self:RegisterProtocol(SCFakePrivateChat, "OnFakePrivateChat")
	self:RegisterProtocol(SCSpeaker, "OnSpeaker")
	self:RegisterProtocol(SCSystemMsg, "OnSystemMsg")
	self:RegisterProtocol(SCOpenLevelLimit, "OnOpenLevelLimit")

	ItemData.Instance:NotifyDataChangeCallBack(self.item_change)
end

function ChatCtrl:SetCrossServerFlag(flag)
	self.cross_server_flag = flag
end

function ChatCtrl:GetCrossServerFlag()
	return self.cross_server_flag
end

function ChatCtrl:SetStartPlayVoiceState(state)
	self.start_play_voice = state
end

function ChatCtrl:ClearPlayVoiceList()
	self.auto_play_voice_list = {}
end

function ChatCtrl:OnOpenLevelLimit(protocol)
	self.data:SetChatOpenLevelLimit(protocol)
end

--开始自动播放语音
function ChatCtrl:StartAutoPlayVoice()
	if self.start_play_voice then
		return
	end
	self.start_play_voice = true
	if not next(self.auto_play_voice_list) then
		self.start_play_voice = false
		return
	end

	local function paly_call_back()
		if not next(self.auto_play_voice_list) then
			self.start_play_voice = false
			return
		end

		local play_world = self.data:GetAutoWorldVoice()
		local play_team = self.data:GetAutoTeamVoice()
		local play_guild = self.data:GetAutoGuildVoice()
		local play_privite = self.data:GetAutoPriviteVoice()

		if not play_world and not play_team and not play_guild and not play_privite then
			self.auto_play_voice_list = {}
			self.start_play_voice = false
			return
		end

		local max_count = #self.auto_play_voice_list

		for i = max_count, 1, -1 do
			local data = self.auto_play_voice_list[i]
			if not play_world and data.channel_type == CHANNEL_TYPE.WORLD then
				table.remove(self.auto_play_voice_list, i)
			elseif not play_team and data.channel_type == CHANNEL_TYPE.TEAM then
				table.remove(self.auto_play_voice_list, i)
			elseif not play_guild and data.channel_type == CHANNEL_TYPE.GUILD then
				table.remove(self.auto_play_voice_list, i)
			elseif not play_privite and data.channel_type == CHANNEL_TYPE.PRIVATE then
				table.remove(self.auto_play_voice_list, i)
			end
		end

		if not next(self.auto_play_voice_list) then
			self.start_play_voice = false
			return
		end

		local new_voice_path = self.auto_play_voice_list[1].path
		table.remove(self.auto_play_voice_list, 1)
		GlobalTimerQuest:AddDelayTimer(function()
			ChatRecordMgr.Instance:PlayVoice(new_voice_path, nil, paly_call_back)
		end, 0)
	end

	paly_call_back()
end

function ChatCtrl:ClearWorldTimeQuest()
	if self.world_time_quest then
		GlobalTimerQuest:CancelQuest(self.world_time_quest)
		self.world_time_quest = nil
	end
end

function ChatCtrl:CheckToPlayVoice(msg_info)
	--判断是否自动播放语音
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if msg_info.content_type == CHAT_CONTENT_TYPE.AUDIO and msg_info.from_uid ~= role_id then
		local data = {}
		local function add_data()
			data.from_uid = msg_info.from_uid
			data.msg_id = msg_info.msg_id
			data.channel_type = msg_info.channel_type
			data.path = msg_info.content
		end
		if msg_info.channel_type == CHANNEL_TYPE.WORLD and self.data:GetAutoWorldVoice() then
			--自动播放世界语音
			add_data()
		elseif msg_info.channel_type == CHANNEL_TYPE.TEAM and self.data:GetAutoTeamVoice() then
			--自动播放队伍语音
			add_data()
		elseif msg_info.channel_type == CHANNEL_TYPE.GUILD and self.data:GetAutoGuildVoice() then
			--自动播放公会语音
			add_data()
		elseif msg_info.channel_type == CHANNEL_TYPE.PRIVATE and self.data:GetAutoPriviteVoice() then
			--自动播放私聊语音
			add_data()
		end
		if next(data) then
			table.insert(self.auto_play_voice_list, data)
			self:StartAutoPlayVoice()
		end
	end
end

-- 频道消息处理
function ChatCtrl:OnChannelChat(protocol)
	local server_time = TimeCtrl.Instance:GetServerTime()
	if self.next_send_world_time < server_time then
		self.next_send_world_time = server_time + self.interval
	end
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if self.data:IsPingBiChannel(protocol.channel_type) and main_role_id ~= protocol.from_uid then
		return
	end

	if ScoietyData.Instance:IsBlack(protocol.from_uid) then
		return
	end

	local msg_info = ChatData.CreateMsgInfo()
	msg_info.from_uid = protocol.from_uid
	msg_info.from_origin_uid = protocol.from_origin_uid
	msg_info.username = protocol.username
	msg_info.sex = protocol.sex
	msg_info.camp = protocol.camp
	msg_info.prof = protocol.prof
	msg_info.authority_type = protocol.authority_type
	msg_info.content_type = protocol.content_type
	msg_info.tuhaojin_color = protocol.tuhaojin_color
	msg_info.bigchatface_status = protocol.bigchatface_status
	msg_info.channel_window_bubble_type = protocol.personalize_window_bubble_type
	msg_info.personalize_window_avatar_type = protocol.personalize_window_avatar_type
	msg_info.level = protocol.level
	msg_info.vip_level = protocol.vip_level
	msg_info.channel_type = protocol.channel_type
	msg_info.content = protocol.content
	msg_info.from_type =protocol.from_type
	msg_info.msg_timestamp = os.date("*t", protocol.msg_timestamp)
	msg_info.send_time_str = TimeUtil.FormatTable2HMS(msg_info.msg_timestamp)
	AvatarManager.Instance:SetAvatarKey(protocol.from_origin_uid or protocol.from_uid, protocol.avatar_key_big, protocol.avatar_key_small)
	AvatarManager.Instance:SetAvatarFrameKey(protocol.from_uid, protocol.personalize_window_avatar_type)

	-- if msg_info.from_uid ~= 0 and msg_info.content_type ~= CHAT_CONTENT_TYPE.AUDIO then
	-- 	msg_info.content = self.filter:Filter(msg_info.content)
	-- end

	-- 缓存世界聊天
	if msg_info.channel_type == CHANNEL_TYPE.WORLD then
		local temp_world_list = self.data:GetTempWorldList()
		if next(temp_world_list) or (self.next_send_world_time - server_time > 0 and self.next_send_world_time - server_time < self.interval) then
			self.data:AddTempWorldList(msg_info)
			if self.world_time_quest then
				return
			end
			self.world_time_quest = GlobalTimerQuest:AddRunQuest(function()
				local new_server_time = TimeCtrl.Instance:GetServerTime()
				if self.next_send_world_time > new_server_time then
					return
				end
				if not next(temp_world_list) then
					self:ClearWorldTimeQuest()
					return
				end
				local new_msg_info = temp_world_list[1]
				self.data:AddChannelMsg(new_msg_info)
				self:CheckToPlayVoice(new_msg_info)

				if msg_info.from_type == SHOW_CHAT_TYPE.ANSWER then
					-- if MainUIViewChat and MainUIViewChat.Instance then
					-- 	MainUIViewChat.Instance:ShowMainPopChat(true, 2)
					-- end
					MainUICtrl.Instance.view:Flush("flush_popmain_view")
				end

				if self.view:IsOpen() then
					if self.view.curr_show_channel ~= new_msg_info.channel_type then
						if self.view:IsLoaded() then
							self.view:ChangeChannelRedPoint(new_msg_info.channel_type, true)
						end
						if self.view.curr_show_channel == CHANNEL_TYPE.ALL then
							self.view:Flush(CHANNEL_TYPE.ALL)
						end
					else
						self.view:Flush(new_msg_info.channel_type)
					end
				end
				GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, new_msg_info)
				--移除表头
				self.data:RemoveTempWorldList(1)
				--重新记录下次发送时间
				self.next_send_world_time = new_server_time + self.interval
			end, 0.1)
			return
		end
	end

	self.data:AddChannelMsg(msg_info)
	self:CheckToPlayVoice(msg_info)

	-- if msg_info.channel_type == CHANNEL_TYPE.WORLD then
	-- 	if msg_info.from_type == SHOW_CHAT_TYPE.ANSWER then
	-- 		MainUIViewChat.Instance:ShowMainPopChat(true, 6)
	-- 		MainUICtrl.Instance.view:Flush("flush_popmain_view")

	-- 		if self.view:IsOpen() then
	-- 			self.view:Flush(msg_info.channel_type)
	-- 		end
	-- 	end
	-- end

	if msg_info.channel_type == CHANNEL_TYPE.TEAM then
		self.data:AddTeamUnreadMsg(msg_info)
		if self.guild_chat_view:IsOpen() then
			self.guild_chat_view:Flush("new_chat", {false, SPECIAL_CHAT_ID.TEAM})
		end
		MainUICtrl.Instance.view:Flush("show_guild_popchat", {true})
		MainUICtrl.Instance.view:Flush("flush_popchat_view", {msg_info})
	end

	if msg_info.channel_type == CHANNEL_TYPE.CAMP then
		if self.guild_chat_view:IsOpen() then
			self.guild_chat_view:Flush("new_chat", {false, SPECIAL_CHAT_ID.CAMP})
		end
		MainUICtrl.Instance.view:Flush("show_guild_popchat", {true})
		MainUICtrl.Instance.view:Flush("flush_popchat_view", {msg_info})
	end

	if msg_info.channel_type == CHANNEL_TYPE.SCENE then
		if Scene.Instance:GetSceneType() == SceneType.HotSpring then
			HotStringChatCtrl.Instance.view:Flush("chat_list")
		end
	else--if msg_info.channel_type ~= CHANNEL_TYPE.GUILD then
		if self.view:IsOpen() then
			if self.view.curr_show_channel ~= msg_info.channel_type then
				if self.view:IsLoaded() then
					self.view:ChangeChannelRedPoint(msg_info.channel_type, true)
				end
				if self.view.curr_show_channel == CHANNEL_TYPE.ALL then
					self.view:Flush(CHANNEL_TYPE.ALL)
				end
			else
				self.view:Flush(msg_info.channel_type)
			end
		end
		GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
	end

	if msg_info.channel_type == CHANNEL_TYPE.GUILD then
		local uservo = GameVoManager.Instance:GetMainRoleVo()
		if ViewManager.Instance:IsOpen(ViewName.Main) and MainUICtrl.Instance:IsLoaded() and msg_info.from_uid ~= uservo.role_id then
			if not self.guild_chat_view:IsOpen() then
				if not self.guild_chat_data:GetIsHidePopRect() then
					ChatData.Instance:SetIsPopChat(true)
					-- MainUIViewChat.Instance:ShowGuildPopChat(true)
					-- MainUIViewChat.Instance:FlushPopChatView()
					MainUICtrl.Instance.view:Flush("show_guild_popchat", {true})
					MainUICtrl.Instance.view:Flush("flush_popchat_view")
				end
				ChatData.Instance:SetGuildChatDaTi(true)
				-- MainUIViewChat.Instance:ShowGuildChatRedPt(true)
			end
			-- if self.guild_chat_view:IsOpen() and not ChatGuildView.Instance:GetPosIsBottom() then
			-- 	GuildChatData.Instance:AddChatNum(1)
			-- 	self.guild_chat_view:FlushShowTips(true)
			-- end
		end
		if self.guild_chat_view:IsOpen() then
			if msg_info.from_uid ~= uservo.role_id then
				self.guild_chat_data:SetIsLock(true)
			else
				self.guild_chat_data:SetIsLock(false)
			end
			self.guild_chat_view:Flush("new_chat")
		end
		ViewManager.Instance:FlushView(ViewName.ChatGuild, "new_chat")
	end
end

-- 私聊消息处理
function ChatCtrl:OnSingleChat(protocol)
	if SettingData.Instance:GetSettingData(SETTING_TYPE.STRANGER_CHAT) and
		not ScoietyData.Instance:IsFriendById(protocol.from_uid) then		-- 拒绝陌生私聊
		return
	end

	if ScoietyData.Instance:IsBlack(protocol.from_uid) then
		return
	end
	local msg_info = ChatData.CreateMsgInfo()
	msg_info.from_uid = protocol.from_uid
	msg_info.username = protocol.username
	msg_info.guildname = protocol.guildname
	msg_info.sex = protocol.sex
	msg_info.camp = protocol.camp
	msg_info.prof = protocol.prof
	msg_info.authority_type = protocol.authority_type
	msg_info.content_type = protocol.content_type
	msg_info.level = protocol.level
	msg_info.vip_level = protocol.vip_level
	msg_info.tuhaojin_color = protocol.tuhaojin_color
	msg_info.bigchatface_status = protocol.bigchatface_status
	msg_info.channel_window_bubble_type = protocol.personalize_window_bubble_type
	msg_info.personalize_window_avatar_type = protocol.personalize_window_avatar_type
	msg_info.channel_type = CHANNEL_TYPE.PRIVATE
	msg_info.content = protocol.content
	msg_info.msg_timestamp = protocol.msg_timestamp or 0
	local time = msg_info.msg_timestamp > 0 and os.date("*t", msg_info.msg_timestamp) or TimeCtrl.Instance:GetServerTimeFormat()
	msg_info.send_time_str = TimeUtil.FormatTable2HMS(time)

	AvatarManager.Instance:SetAvatarKey(protocol.from_uid, protocol.avatar_key_big, protocol.avatar_key_small)
	AvatarManager.Instance:SetAvatarFrameKey(protocol.from_uid, protocol.personalize_window_avatar_type)

	-- if msg_info.from_uid ~= 0 and msg_info.content_type ~= CHAT_CONTENT_TYPE.AUDIO then
	-- 	msg_info.content = ChatFilter.Instance:Filter(msg_info.content)
	-- end
	self.data:AddPrivateMsg(protocol.from_uid, msg_info)
	self:CheckToPlayVoice(msg_info)

	self.data:SetHavePriviteChat(true)
	self.data:SetRedChat(true)
	-- 如果没有加入公会来私信
	if GameVoManager.Instance:GetMainRoleVo().guild_id <= 0 then
		MainUIViewChat.Instance:ShowGuildChatIcon(true)
	end
	if not self.view:IsOpen() then
		MainUICtrl.Instance.view:ShowPriviteRemind(msg_info)
	else
		if self.view:IsLoaded() then
			self.view:SetPriviteRedVisible()
		end
		local curr_id = ChatData.Instance:GetCurrentRoleId()
		if curr_id == 0 then
			ChatData.Instance:SetCurrentRoleId(protocol.from_uid)
		end
		self.view:Flush(CHANNEL_TYPE.PRIVATE, {1})
	end
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:Flush("new_chat")
	end

	self.data:AddPrivateUnreadMsg(msg_info)
	MainUICtrl.Instance:ChangeMainUiChatIconList(string.lower(ViewName.ChatGuild), MainUIViewChat.IconList.CHAT_INFO, protocol ~= nil)
	self.data:SetChatInfoList(protocol)
end

function ChatCtrl:OnSingleChatUserNotExist(protocol)
end

--偶遇消息处理
function ChatCtrl:OnFakePrivateChat(protocol)
end

-- 喇叭消息处理
function ChatCtrl:OnSpeaker(protocol)
	local msg_info = ChatData.CreateMsgInfo()

	msg_info.from_uid = protocol.from_uid
	msg_info.username = protocol.username
	msg_info.sex = protocol.sex
	msg_info.camp = protocol.camp
	msg_info.prof = protocol.prof
	msg_info.authority_type = protocol.authority_type
	msg_info.content_type = protocol.content_type
	msg_info.level = protocol.level
	msg_info.vip_level = protocol.vip_level
	msg_info.plat_name = protocol.plat_name
	msg_info.server_id =  protocol.server_id
	msg_info.speaker_type =  protocol.speaker_type
	msg_info.tuhaojin_color = protocol.tuhaojin_color
	msg_info.bigchatface_status = protocol.bigchatface_status
	msg_info.personalize_window_type = protocol.personalize_window_type
	msg_info.channel_window_bubble_type = protocol.personalize_window_bubble_type
	msg_info.personalize_window_avatar_type = protocol.personalize_window_avatar_type
	msg_info.channel_type = CHANNEL_TYPE.SPEAKER
	if msg_info.speaker_type == SPEAKER_TYPE.SPEAKER_TYPE_CROSS then
		msg_info.channel_type = CHANNEL_TYPE.CROSS
	end
	msg_info.content = protocol.speaker_msg
	msg_info.send_time_str = TimeUtil.FormatTable2HMS(TimeCtrl.Instance:GetServerTimeFormat())

	AvatarManager.Instance:SetAvatarKey(protocol.from_uid, protocol.avatar_key_big, protocol.avatar_key_small)
	AvatarManager.Instance:SetAvatarFrameKey(protocol.from_uid, protocol.personalize_window_avatar_type)

	-- if msg_info.from_uid ~= 0 then
	-- 	msg_info.content = ChatFilter.Instance:Filter(msg_info.content)
	-- end

	self.data:AddChannelMsg(msg_info)

	self.data:AddTransmitInfo(msg_info)

	if self.view:IsOpen() then
		if self.view.curr_show_channel ~= CHANNEL_TYPE.WORLD then
			if self.view:IsLoaded() then
				self.view:ChangeChannelRedPoint(CHANNEL_TYPE.WORLD, true)
			end
			if self.view.curr_show_channel == CHANNEL_TYPE.ALL then
				self.view:Flush(CHANNEL_TYPE.ALL)
			end
		else
			self.view:Flush(CHANNEL_TYPE.WORLD)
		end
	end

	local str = string.format("{wordcolor;ffff00;%s}: {wordcolor;00ff00;%s}", msg_info.username, msg_info.content)
	TipsCtrl.Instance:ShowSpeakerNotice(str)

	GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
end

function ChatCtrl:IsShieldSystemMsg(content)
	local is_shield = false
	local i, j = string.find(content, "({.-})")
	if i and j then
		local str = string.sub(content, i+1, j-1)
		local tbl = Split(str, ";")
		if tbl[1] == "visible_level" then
			--等级限制
			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			if main_role_vo.level < tonumber(tbl[2] or 0) then
				is_shield = true
			end
		end
	end
	return is_shield
end

--发口令红包
function ChatCtrl:SendCreateCommandRedPaper(hb_msg)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCreateCommandRedPaper)
	protocol.hb_msg = hb_msg
	protocol:EncodeAndSend()

	-- 准备上报聊天记录，或者服务器来记录
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	ReportManager:Step(Report.CHAT_PRIVATE,
		main_role_vo.level,
		main_role_vo.gold,
		CHANNEL_TYPE.SPEAKER,
		tostring(mime.b64(hb_msg)),
		nil)

	-- 上报给神起
	ReportManager:ReportChatMsgToSQ(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, main_role_vo.gold,
									CHANNEL_TYPE.SPEAKER, hb_msg, "")
end

-- 系统消息处理
function ChatCtrl:OnSystemMsg(protocol)
	--屏蔽一些对应限制的传闻
	if self:IsShieldSystemMsg(protocol.content) then
		return
	end
	
	if protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_GUILD or protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_GUILD_3 then	--服务端不好做。5代只在仙盟聊天里显示系统消息。前台自己构建
		local msg_info = ChatData.CreateMsgInfo()
		msg_info.from_uid = 0
		msg_info.username = ""
		msg_info.sex = 0
		msg_info.camp = 0
		msg_info.prof = 0
		msg_info.authority_type = 0
		msg_info.level = 0
		msg_info.vip_level = 0
		msg_info.channel_type = CHANNEL_TYPE.GUILD
		msg_info.content = protocol.content
		msg_info.send_time_str = TimeUtil.FormatTable2HMS(os.date("*t", protocol.send_time))
		if protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_GUILD_3 then
			msg_info.from_type = SHOW_CHAT_TYPE.SYS
		end

		self.data:AddChannelMsg(msg_info)
		GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
		if self.guild_chat_view:IsOpen() then
			self.guild_chat_view:Flush("new_chat")
		end
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_GUILD_2 then		--仙盟聊天和仙盟汽泡
		local msg_info = ChatData.CreateMsgInfo()
		msg_info.from_uid = 0
		msg_info.username = ""
		msg_info.sex = 0
		msg_info.camp = 0
		msg_info.prof = 0
		msg_info.authority_type = 0
		msg_info.level = 0
		msg_info.vip_level = 0
		msg_info.channel_type = CHANNEL_TYPE.GUILD
		msg_info.content = protocol.content
		msg_info.send_time_str = TimeUtil.FormatTable2HMS(os.date("*t", protocol.send_time))

		self.data:AddChannelMsg(msg_info)
		if self.guild_chat_view:IsOpen() then
			self.guild_chat_view:Flush("new_chat")
		end

		if MainUIViewChat and MainUIViewChat.Instance then
			MainUIViewChat.Instance:ShowGuildPopChat(true, 6)
		end
		-- MainUIViewChat.Instance:SetContent(msg_info.content, color)
		--MainUICtrl.Instance.view:Flush("show_guild_popchat", {true})
		MainUICtrl.Instance.view:Flush("flush_popchat_view")

	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ACTIVE_NOTICE then			-- 活动公告
		--TipsCtrl.Instance:ShowActivityNoticeMsg(protocol.content)
		TipsCtrl.Instance:ShowSystemMsg(protocol.content)
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE then			-- 屏幕中央弹出消息
		self:AddSystemMsg(protocol.content, protocol.send_time)
		if not self.data:GetHeadSayState() then
			TipsCtrl.Instance:ShowNewSystemNotice(protocol.content)
		end
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_AND_ROLL then		-- 屏幕中央滚动消息
		self:AddSystemMsg(protocol.content, protocol.send_time)
		if not self.data:GetHeadSayState() then
			--TipsCtrl.Instance:ShowSystemNotice(protocol.content)
			SysMsgCtrl.Instance:ErrorRemind(protocol.content, nil, true)
		end
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_WORLD then		-- 只添加到聊天世界频道
		self:AddSystemMsg(protocol.content, protocol.send_time)
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_PERSONAL_NOTICE then
		TipsCtrl.Instance:ShowSystemMsg(protocol.content)
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_ONLY_CHAT_CAMP then		-- 国家频道
		local msg_info = ChatData.CreateMsgInfo()
		msg_info.channel_type = CHANNEL_TYPE.CAMP
		msg_info.content = protocol.content
		msg_info.send_time_str = TimeUtil.FormatTable2HMS(os.date("*t", protocol.send_time))

		self.data:AddChannelMsg(msg_info)

		self.view:Flush(CHANNEL_TYPE.CAMP)
		GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, msg_info)
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_ROLL_2 then
		self:AddSystemMsg(protocol.content, protocol.send_time, true)
		if not self.data:GetHeadSayState() then
			--TipsCtrl.Instance:ShowSystemNotice(protocol.content)
			SysMsgCtrl.Instance:ErrorRemind(protocol.content, nil, true)
		end
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_CENTER_NOTICE_2 then
		self:AddSystemMsg(protocol.content, protocol.send_time, true)
		if not self.data:GetHeadSayState() then
			TipsCtrl.Instance:ShowNewSystemNotice(protocol.content)
		end
	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_WORLD_QUEST then
		-- if MainUIViewChat and MainUIViewChat.Instance then
		-- 	MainUIViewChat.Instance:ShowMainPopChat(true, 2)
		-- end
		MainUICtrl.Instance.view:Flush("flush_popmain_view")
		self:AddSystemMsg(protocol.content, protocol.send_time, false, SHOW_CHAT_TYPE.ANSWER, CHANNEL_TYPE.WORLD)

	elseif protocol.msg_type == SYS_MSG_TYPE.SYS_MSG_GUILD_QUEST then
		local msg_info = ChatData.CreateMsgInfo()
		msg_info.from_uid = 0
		msg_info.username = ""
		msg_info.sex = 0
		msg_info.camp = 0
		msg_info.prof = 0
		msg_info.authority_type = 0
		msg_info.level = 0
		msg_info.vip_level = 0
		msg_info.channel_type = CHANNEL_TYPE.GUILD
		msg_info.from_type = SHOW_CHAT_TYPE.ANSWER
		msg_info.content = protocol.content
		msg_info.send_time_str = TimeUtil.FormatTable2HMS(os.date("*t", protocol.send_time))

		self.data:AddChannelMsg(msg_info)
		if self.guild_chat_view:IsOpen() then
			self.guild_chat_view:Flush("new_chat")
		end

		if MainUIViewChat and MainUIViewChat.Instance then
			MainUIViewChat.Instance:ShowGuildPopChat(true, 6)
		end
		-- MainUIViewChat.Instance:SetContent(msg_info.content, color)
		--MainUICtrl.Instance.view:Flush("show_guild_popchat", {true})
		MainUICtrl.Instance.view:Flush("flush_popchat_view")
	end
end

function ChatCtrl:ClearSystemTimeQuest()
	if self.system_time_quest then
		GlobalTimerQuest:CancelQuest(self.system_time_quest)
		self.system_time_quest = nil
	end
end

-- 添加一条系统消息
function ChatCtrl:AddSystemMsg(content, time, is_spec, from_type, channel_type)
	local server_time = TimeCtrl.Instance:GetServerTime()
	if self.next_send_system_time < server_time then
		self.next_send_system_time = server_time + self.interval
	end
	time = time or server_time
	local msg_info = ChatData.CreateMsgInfo()
	msg_info.channel_type = channel_type or CHANNEL_TYPE.SYSTEM
	msg_info.username = ""
	msg_info.content = content
	msg_info.send_time_str = TimeUtil.FormatTable2HMS(os.date("*t", time))
	msg_info.is_spec = is_spec or false
	msg_info.from_type = from_type or SHOW_CHAT_TYPE.SYS

	local function AddMsgInfo(new_msg_info)
		self.data:AddChannelMsg(new_msg_info)
		if self.view:IsOpen() then
			if self.view.curr_show_channel == CHANNEL_TYPE.ALL then
				self.view:Flush(CHANNEL_TYPE.ALL)
			elseif self.view.curr_show_channel == CHANNEL_TYPE.WORLD then
				self.view:Flush(CHANNEL_TYPE.WORLD)
			else
				self.view:Flush(CHANNEL_TYPE.SYSTEM)
			end
		end
		GlobalEventSystem:Fire(MainUIEventType.CHAT_CHANGE, new_msg_info)
	end

	local temp_system_list = self.data:GetTempSystemList()
	if next(temp_system_list) or (self.next_send_system_time - server_time > 0 and self.next_send_system_time - server_time < self.interval) then
		self.data:AddTempSystemList(msg_info)
		if self.system_time_quest then
			return
		end
		self.system_time_quest = GlobalTimerQuest:AddRunQuest(function()
			local new_server_time = TimeCtrl.Instance:GetServerTime()
			if self.next_send_system_time > new_server_time then
				return
			end
			if not next(temp_system_list) then
				self:ClearSystemTimeQuest()
				return
			end
			local new_msg_info = temp_system_list[1]
			AddMsgInfo(new_msg_info)
			--移除表头
			self.data:RemoveTempSystemList(1)
			--重新记录下次发送时间
			self.next_send_system_time = new_server_time + self.interval
		end, 0.1)
	else
		AddMsgInfo(msg_info)
	end
end

-- 发送频道消息
function ChatCtrl.SendChannelChat(channel_type, content, content_type, from_type)
	if "" == content then
		return
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSChannelChatReq)
	protocol.content_type = content_type or 0
	protocol.channel_type = channel_type
	protocol.from_type = from_type or 0

	protocol.content = content
	protocol:EncodeAndSend()

	-- 准备上报聊天记录，或者服务器来记录
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	ReportManager:Step(Report.CHAT_PRIVATE,
		main_role_vo.level,
		main_role_vo.gold,
		channel_type,
		tostring(mime.b64(content)),
		nil)

	ReportManager:ReportChatMsgToSQ(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, main_role_vo.gold,
									channel_type, content, "")
end

-- 发送私聊消息
function ChatCtrl.SendSingleChat(to_uid, content, content_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSingleChatReq)
	protocol.to_uid = to_uid
	protocol.content = content
	protocol.content_type = content_type or 0
	protocol:EncodeAndSend()

	-- 准备上报聊天记录，或者服务器来记录
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	ReportManager:Step(Report.CHAT_PRIVATE,
		main_role_vo.level,
		main_role_vo.gold,
		CHANNEL_TYPE.PRIVATE,
		tostring(mime.b64(content)),
		to_uid)

	-- 上报给神起
	ReportManager:ReportChatMsgToSQ(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, main_role_vo.gold,
									CHANNEL_TYPE.PRIVATE, content, to_uid)
end

function ChatCtrl:SendCurrentTransmit(is_auto_buy, speaker_msg, content_type, speaker_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSpeaker)
	protocol.is_auto_buy = is_auto_buy
	protocol.content_type = content_type or 0
	protocol.speaker_msg = speaker_msg
	protocol.speaker_type = speaker_type or 0
	protocol:EncodeAndSend()

	-- 准备上报聊天记录，或者服务器来记录
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	ReportManager:Step(Report.CHAT_PRIVATE,
		main_role_vo.level,
		main_role_vo.gold,
		CHANNEL_TYPE.SPEAKER,
		tostring(mime.b64(speaker_msg)),
		nil)

	-- 上报给神起
	ReportManager:ReportChatMsgToSQ(main_role_vo.server_id, main_role_vo.role_name, main_role_vo.role_id, main_role_vo.level, main_role_vo.gold,
									CHANNEL_TYPE.SPEAKER, speaker_msg, "")
end

function ChatCtrl:SetChatViewData(data, is_equip)
	if self.view:IsLoaded() then
		self.view:SetData(data, is_equip)
	end
end

function ChatCtrl:SetGuildViewData(data, is_equip)
	if self.guild_chat_view:IsLoaded() then
		self.guild_chat_view:SetData(data, is_equip)
	end
end

function ChatCtrl:SetFace(index)
	if self.view:IsLoaded() then
		self.view:SetFace(index)
	end
end

function ChatCtrl:ChangePriviteTab(tab_index)
	if self.view:IsLoaded() then
		self.view:ChangePriviteTab(tab_index)
	end
end

function ChatCtrl:ChangeHearSayState(value)
	self.data:SetHeadSayState(value)
end

function ChatCtrl:ChangeLockState(state)
	ChatData.Instance:SetIsLockState(state)
	if self.view:IsLoaded() then
		self.view:ChangeLockState(state)
	end
end

function ChatCtrl:GetChatMeasuring(delegate)
	if self.view:IsOpen() then
		return self.view:GetChatMeasuring(delegate)
	end
end

function ChatCtrl:GetGuildMeasuring(delegate)
	if self.guild_chat_view:IsOpen() then
		return self.guild_chat_view:GetChatMeasuring(delegate)
	end
end

function ChatCtrl:AddTextToInput(text)
	if self.view:IsLoaded() then
		self.view:AddTextToInput(text)
	end
end

function ChatCtrl:ShowListenTrigger(state)
	if self.view:IsLoaded() then
		self.view:ShowListenTrigger(state)
	end
end

function ChatCtrl:FlushPawnView()
	if self.guild_chat_view:IsOpen() then
		self.guild_chat_view:FlushPawnScoreView()
	end
end

function ChatCtrl:ListenRoleAttrChange(key, value, old_value)
	if key == "guild_id" then
		if value <= 0 and old_value > 0 then
			--退出了公会
			-- self.data:RemoveNormalChatList(SPECIAL_CHAT_ID.GUILD)
			GlobalEventSystem:Fire(ChatEventType.SPECIAL_CHAT_TARGET_CHANGE, SPECIAL_CHAT_ID.GUILD, false)
			self.data:RemoveMsgToChannel(CHANNEL_TYPE.GUILD)
			self.data:ClearGuildUnreadMsg()
			MainUICtrl.Instance.view:Flush("show_guildchat_redpt", {false})
		elseif value > 0 and old_value <= 0 then
			--加入了公会
			-- self.data:AddNormalChatList({role_id = SPECIAL_CHAT_ID.GUILD})
			GlobalEventSystem:Fire(ChatEventType.SPECIAL_CHAT_TARGET_CHANGE, SPECIAL_CHAT_ID.GUILD, true)
		end
	end
end

-- 主界面创建
function ChatCtrl:MainuiOpenCreate()
	--判断是否有特殊聊天对象
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id > 0 then
		-- self.data:AddNormalChatList({role_id = SPECIAL_CHAT_ID.GUILD})
		GlobalEventSystem:Fire(ChatEventType.SPECIAL_CHAT_TARGET_CHANGE, SPECIAL_CHAT_ID.GUILD, true)
	end
	local have_team = ScoietyData.Instance:GetTeamState()
	if have_team then
		self.data:AddNormalChatList({role_id = SPECIAL_CHAT_ID.TEAM})
		GlobalEventSystem:Fire(ChatEventType.SPECIAL_CHAT_TARGET_CHANGE, SPECIAL_CHAT_ID.TEAM, true)
	end
	self:CreateClientRichTex()
end

--刷新群聊界面
function ChatCtrl:FlushGuildChatView( ... )
	self.guild_chat_view:Flush( ... )
	if not self.guild_chat_view:IsOpen() then
		local param = {...}
		if param[1] == "guild_answer" then
			MainUICtrl.Instance:FlushView("GuildShake", {[1] = true})
		elseif param[1] == "guild_qustion_result" then
			MainUICtrl.Instance:FlushView("GuildShake", {[1] = false})
			WorldQuestionData.Instance:ClearGuildList()
		end
	end
end

function ChatCtrl:OpenQuickChatView(chat_type, call_back)
	self.chat_notice_view:SetQuickType(chat_type)
	self.chat_notice_view:SetCallBack(call_back)
	self.chat_notice_view:Open()
end
function ChatCtrl:ItemDataChangeCallback(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num, old_data)
	local big_face_level = CoolChatData.Instance:GetBigFaceLevel() or 0 -- 当前等级
	local big_face_cfg = CoolChatData.Instance:GetBigFaceConfig()
	local level_cfg = big_face_cfg.level_cfg
	local cfg = level_cfg[big_face_level + 1]
	local has_num = ItemData.Instance:GetItemNumInBagById(cfg.prof_four_item.item_id) or 0
	if cfg then
		if change_item_id == cfg.prof_four_item.item_id then
			RemindManager.Instance:Fire(RemindName.PlayerChat)
		end
	end
end

function ChatCtrl:ChatChangeRemind()
	return self.data:GetShowRed()
end

local RichList = {
	CHAT_LINK_TYPE.GODDESS_INFO,
	CHAT_LINK_TYPE.WO_CHONGZHI
}

-- 假传闻
function ChatCtrl:CreateClientRichTex()
	-- if self.delay_rich_text_timer then
	-- 	GlobalTimerQuest:CancelQuest(self.delay_rich_text_timer)
	-- 	self.delay_rich_text_timer = nil	
	-- end
		
	-- if TimeCtrl.Instance:GetCurOpenServerDay() > 7 then
	-- 	return
	-- end
	-- self.delay_rich_text_timer = GlobalTimerQuest:AddDelayTimer(function()
	-- 	-- 随即名
	-- 	local rand_num = math.floor(math.random(1, 200))
	-- 	local rand_name = CommonDataManager.GetRandomName(rand_num)
	-- 	-- 随机传闻
	-- 	local rich_list_index = math.floor(math.random(1, #RichList))
	-- 	local rich_line = RichList[rich_list_index] or 0
	-- 	local rich_text = Language.ClientRichText[rich_line]
	-- 	local content = ""
	-- 	if rich_line == CHAT_LINK_TYPE.GODDESS_INFO then
	-- 		local xiannv_id_list = {1, 2, 4}
	-- 		local index = math.floor(math.random(1, #xiannv_id_list))
	-- 		local id = xiannv_id_list[index]
	-- 		content = string.format(rich_text, rand_name, id, rich_line)
	-- 	else
	-- 		content = string.format(rich_text, rand_name, rich_line)
	-- 	end
		
	-- 	TipsCtrl.Instance:ShowNewSystemNotice(content)
	-- 	self:AddSystemMsg(content, TimeCtrl.Instance:GetServerTime())

	-- 	self:CreateClientRichTex()
	-- end, 300)
end