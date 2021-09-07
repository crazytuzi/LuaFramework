require("game/chat/chat_private_view")
require("game/chat/chat_team_view")
require("game/chat/chat_world_view")
require("game/chat/chat_guild_view")
require("game/chat/chat_camp_view")
require("game/chat/chat_system_view")
require("game/chat/chat_compre_view")
require("game/chat/chat_answer_view")
require("game/chat/chat_cell")

ChatView = ChatView or BaseClass(BaseView)

local SPEED = 50
local UILayer = GameObject.Find("GameRoot/UILayer")

function ChatView:__init()
	self.ui_config = {"uis/views/chatview","ChatView"}

	self.close_mode = CloseMode.CloseVisible
	self.curr_send_channel = CHANNEL_TYPE.ALL	-- 发送频道
	self.curr_show_channel = CHANNEL_TYPE.ALL	-- 显示频道
	-- self.view_layer = UiLayer.Pop

	self.last_flush_redpoint_time = 0
end

function ChatView:ReleaseCallBack()
	if self.private_view then
		self.private_view:DeleteMe()
		self.private_view = nil
	end
	if self.team_view then
		self.team_view:DeleteMe()
		self.team_view = nil
	end
	if self.world_view then
		self.world_view:DeleteMe()
		self.world_view = nil
	end
	if self.guild_view then
		self.guild_view:DeleteMe()
		self.guild_view = nil
	end
	if self.camp_view then
		self.camp_view:DeleteMe()
		self.camp_view = nil
	end
	if self.system_view then
		self.system_view:DeleteMe()
		self.system_view = nil
	end
	if self.compre_view then
		self.compre_view:DeleteMe()
		self.compre_view = nil
	end
	ChatData.Instance:SetCurrentRoleId(0)

	if self.chat_measuring then
		GameObject.Destroy(self.chat_measuring.root_node.gameObject)
		self.chat_measuring:DeleteMe()
		self.chat_measuring = nil
	end

	if self.answer_view then
		self.answer_view:DeleteMe()
		self.answer_view = nil
	end

	self:RemoveDelayTime()

	-- 清理变量和对象
	self.world_red = nil
	self.team_red = nil
	self.guild_red = nil
	self.privite_red = nil
	self.cool_time = nil
	self.button_text = nil
	self.is_send_cool = nil
	self.bubble_red_point = nil
	self.show_listen_trigger = nil
	self.chat_input = nil
	self.channel = nil
	self.tab_world = nil
	self.tab_team = nil
	self.tab_guild = nil
	self.tab_camp = nil
	self.tab_system = nil
	self.tab_compre = nil
	self.tab_private = nil
	self.tab_chat = nil
	self.listen_trigger = nil
	self.lock_view = nil
	self.lock_animator = nil
	self.slide_btn = nil
	self.slide_btn_animator = nil
	self.tab_answer = nil
	self.show_send_btn = nil

	UnityEngine.PlayerPrefs.DeleteKey("aoto_buy_world_chat")
end

function ChatView:LoadCallBack()
	self.now_index = TabIndex.chat_compre

	--获取变量
	self.world_red = self:FindVariable("WorldRed")
	self.team_red = self:FindVariable("TeamRed")
	self.guild_red = self:FindVariable("GuildRed")
	self.privite_red = self:FindVariable("PriviteRed")
	self.cool_time = self:FindVariable("CoolTime")

	self.button_text = self:FindVariable("ButtonText")
	self.is_send_cool = self:FindVariable("IsSendCool")

	self.bubble_red_point = self:FindVariable("BubbleRedPoint")

	self.show_listen_trigger = self:FindVariable("ShowListenTrigger")

	-- 查找组件
	self.chat_input = self:FindObj("ChatInput")
	self.channel = self:FindObj("Channel")
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

	self.tab_world = self:FindObj("TabWorld")
	self.tab_team = self:FindObj("TabTeam")
	self.tab_guild = self:FindObj("TabGuild")
	self.tab_camp = self:FindObj("TabCamp")
	self.tab_system = self:FindObj("TabSystem")
	self.tab_compre = self:FindObj("TabAll")
	self.tab_answer = self:FindObj("TabAnswer")

	self.tab_private = self:FindObj("TabPrivate")
	self.tab_chat = self:FindObj("TabChat")

	self.show_send_btn = self:FindVariable("ShowSendBtn")

	--监听滑动事件
	self.listen_trigger = self:FindObj("ListenTrigger")
	local event_trigger = self.listen_trigger:GetComponent(typeof(EventTriggerListener))
	event_trigger:AddDragListener(BindTool.Bind(self.OnTriggerChange, self))

	-- 监听UI事件
	self:ListenEvent("Close", BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("OpenSpeaker", BindTool.Bind(self.HandleOpenSpeaker, self))
	self:ListenEvent("OpenBlackList", BindTool.Bind(self.HandleOpenBlackList, self))
	self:ListenEvent("OpenItem", BindTool.Bind(self.HandleOpenItem, self))
	self:ListenEvent("OpenShop", BindTool.Bind(self.HandleOpenShop, self))
	self:ListenEvent("InsertLocation", BindTool.Bind(self.HandleInsertLocation, self))
	self:ListenEvent("VoiceStart", BindTool.Bind(self.HandleVoiceStart, self))
	self:ListenEvent("VoiceStop", BindTool.Bind(self.HandleVoiceStop, self))
	self:ListenEvent("OpenRedPackage", BindTool.Bind(self.HandleOpenRedPackage, self))
	self:ListenEvent("ChangeChannel", BindTool.Bind(self.HandleChangeChannel, self))
	self:ListenEvent("OpenEmoji", BindTool.Bind(self.HandleOpenEmoji, self))
	self:ListenEvent("Send", BindTool.Bind(self.HandleSend, self))
	self:ListenEvent("InputUp", BindTool.Bind(self.HandleInputUp, self))
	self:ListenEvent("InputDown", BindTool.Bind(self.HandleInputDown, self))
	self:ListenEvent("VoiceSettingClick", BindTool.Bind(self.VoiceSettingClick, self))
	self:ListenEvent("InptuValueChange", BindTool.Bind(self.InptuValueChange, self))

	self.tab_compre.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.chat_compre))
	self.tab_world.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.chat_world))
	self.tab_team.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.chat_team))
	self.tab_guild.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.chat_guild))
	self.tab_camp.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.chat_camp))
	self.tab_system.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.chat_system))
	self.tab_private.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.chat_private))
	self.tab_chat.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.chat))
	self.tab_answer.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.chat_answer))

	-- 获取子控件
	self.private_view = ChatPrivateView.New(self:FindObj("PrivateView"))

	self.team_view = ChatTeamView.New(self:FindObj("ContentTeam"))
	self.world_view = ChatWorldView.New(self:FindObj("ContentWorld"))
	self.guild_view = ChatGuildView.New(self:FindObj("ContentGuild"))
	self.camp_view = ChatCampView.New(self:FindObj("ContentCamp"))
	self.system_view = ChatSystemView.New(self:FindObj("ContentSystem"))
	self.compre_view = ChatCompreView.New(self:FindObj("ContentAll"))
	self.answer_view = ChatAnswerView.New(self:FindObj("ContentAnswer"))

	self.lock_view = self:FindObj("LockAni")
	self.lock_animator = self.lock_view.animator
	self.slide_btn = self:FindObj("SlideBtn")
	self.slide_btn_animator = self.slide_btn.animator
	if self.lock_animator then
		self.lock_animator:ListenEvent("LockState", BindTool.Bind(self.LockState, self))
	end
end

function ChatView:OnTriggerChange(data)
	if data.delta.y > 0 then
		ChatData.Instance:SetCanSendVoice(false)
	end
end

function ChatView:VoiceSettingClick()
	ViewManager.Instance:Open(ViewName.VoiceSetting)
end

function ChatView:LockState(value)
	local is_lock = tonumber(value) == 1 and true or false
	ChatData.Instance:SetIsLockState(is_lock)
	-- if is_lock == false then
	-- 	self:FlushNowView()
	-- end
end

function ChatView:InptuValueChange()
	local max = self.chat_input.input_field.characterLimit
	local length = StringUtil.GetCharacterCount(self.chat_input.input_field.text)
	if length > max then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.TooLong)
	end
end

function ChatView:GetChatMeasuring(delegate)
	if not delegate then
		return nil
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

function ChatView:ChangeLockState(state)
	-- if self.lock_view.gameObject.activeInHierarchy then
	-- 	self.lock_view.toggle.isOn = state
	-- end
	--self.lock_animator:SetBool("isOn", state)
	--self.slide_btn_animator:SetBool("toright", state)
end

function ChatView:CloseCallBack()
	if self.item_call_back then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_call_back)
		self.item_call_back = nil
	end

	-- self.chat_input.input_field.text = ""
	-- ChatData.Instance:ClearInput()
	self.str_list = {}
	AudioPlayer.Stop()		--停止播放语音
	AudioService.Instance:SetMasterVolume(1.0)
	self:ClearBtnCountDown()
	if self.private_view then
		self.private_view:SetSelectIndex(0)
	end
	ChatData.Instance:SetIsLockState(false)
end

function ChatView:AddNotice(str)
	self.total_count = self.total_count + 1
	self.str_list[self.total_count] = str
end

function ChatView:ItemChangeCallBack(item_id)
	if self.last_flush_redpoint_time + 0.5 <= Status.NowTime then
		self:ChangeBubbleRedPoint()
		self.last_flush_redpoint_time = Status.NowTime
	else
		self:RemoveDelayTime()
		self.delay_time = GlobalTimerQuest:AddDelayTimer(function() self:ChangeBubbleRedPoint() end, 0.5)
	end
	-- local bubble_cfg = CoolChatData.Instance:GetBubbleCfg()
	-- for k, v in ipairs(bubble_cfg) do
	-- 	if v.item1 and v.item1.item_id == item_id then
	-- 		self:ChangeBubbleRedPoint()
	-- 		return
	-- 	end
	-- end
end

function ChatView:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

--清除按钮倒计时
function ChatView:ClearBtnCountDown()
	if self.button_count_down then
		CountDown.Instance:RemoveCountDown(self.button_count_down)
		self.button_count_down = nil
	end
end

function ChatView:ChangeBubbleRedPoint()
	--设置气泡红点
	if self.bubble_red_point then
		local state = CoolChatData.Instance:GetCoolChatRedPoint()
		self.bubble_red_point:SetValue(state)
	end
end

function ChatView:ChangeButtonEnable()
	self:ClearBtnCountDown()
	local function timer_func(elapse_time, total_time)
		if elapse_time >= total_time or self.tab_team.toggle.isOn then
			self:ClearBtnCountDown()
			self.button_text:SetValue(Language.Chat.Send)
			self.is_send_cool:SetValue(false)
			return
		end
		self.button_text:SetValue(string.format(Language.Chat.ResetTimes, total_time - math.floor(elapse_time)))
		self.is_send_cool:SetValue(true)
	end

	if not self.tab_team.toggle.isOn and self:CheckShowCd() then
		if not ChatData.Instance:GetChannelCdIsEnd(self.curr_send_channel) then
			local time = ChatData.Instance:GetChannelCdEndTime(self.curr_send_channel) - Status.NowTime
			time = math.ceil(time)
			self.is_send_cool:SetValue(true)
			self.button_text:SetValue(string.format(Language.Chat.ResetTimes, time))
			self.button_count_down = CountDown.Instance:AddCountDown(time, 1, timer_func)
		else
			self.button_text:SetValue(Language.Chat.Send)
			self.is_send_cool:SetValue(false)
		end
	else
		self.button_text:SetValue(Language.Chat.Send)
		self.is_send_cool:SetValue(false)
	end
end

function ChatView:OpenCallBack()
	-- self.show_listen_trigger:SetValue(false)
	self:ChangeButtonEnable()

	local is_lock = ChatData.Instance:GetIsLockState()
	self:ChangeLockState(is_lock)

	self:ChangeBubbleRedPoint()

	--监听物品变化
	if self.item_call_back == nil then
		self.item_call_back = BindTool.Bind(self.ItemChangeCallBack, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_call_back)
	end

	if self.tab_private.toggle.isOn then
		self:HandleSwitchPrivate()
	elseif self.tab_world.toggle.isOn then
		self:HandleSwitchWorld()
	elseif self.tab_team.toggle.isOn then
		self:HandleSwitchTeam()
	elseif self.tab_guild.toggle.isOn then
		self:HandleSwitchGuild()
	elseif self.tab_camp.toggle.isOn then
		self:HandleSwitchCamp()
	elseif self.tab_system.toggle.isOn then
		self:HandleSwitchSystem()
	elseif self.tab_compre.toggle.isOn then
		self:HandleSwitchCompre()
	end
end

function ChatView:ShowIndexCallBack(index)
	if index == TabIndex.chat_world then
		self.tab_world.toggle.isOn = true
	elseif index == TabIndex.chat_team then
		self.tab_team.toggle.isOn = true
	elseif index == TabIndex.chat_guild then
		self.tab_guild.toggle.isOn = true
	elseif index == TabIndex.chat_camp then
		self.tab_camp.toggle.isOn = true
	elseif index == TabIndex.chat_system then
		self.tab_system.toggle.isOn = true
	elseif index == TabIndex.chat_private then
		self.tab_private.toggle.isOn = true
	elseif index == TabIndex.chat_compre then
		self.tab_compre.toggle.isOn = true
	elseif index == TabIndex.chat_answer then
		self.tab_answer.toggle.isOn = true
	end
end

function ChatView:OnToggleChange(index, ison)
	if ison and index ~= self.now_index then
		self.now_index = index
		self:ChangeLockState(false)

		if self.private_view then
			self.private_view:SetSelectIndex(0)
		end

		if index == TabIndex.chat_world then
			self:HandleSwitchWorld()
		elseif index == TabIndex.chat_team then
			self:HandleSwitchTeam()
		elseif index == TabIndex.chat_guild then
			self:HandleSwitchGuild()
		elseif index == TabIndex.chat_camp then
			self:HandleSwitchCamp()
		elseif index == TabIndex.chat_system then
			self:HandleSwitchSystem()
		elseif index == TabIndex.chat_private then
			self:HandleSwitchPrivate()
		elseif index == TabIndex.chat then
			self:HandleSwitchChat()
		elseif index == TabIndex.chat_compre then
			self:HandleSwitchCompre()
		elseif index == TabIndex.chat_answer then
			self:HandleSwitchAnswer()
		end

		if self.show_send_btn ~= nil then
			self.show_send_btn:SetValue(not (index == TabIndex.chat_answer))
		end
	end
end

function ChatView:HandleClose()
	if AutoVoiceCtrl.Instance.view:IsOpen() then
		return
	end
	ViewManager.Instance:Close(ViewName.Chat)
end

function ChatView:HandleSwitchPrivate()
	GlobalTimerQuest:AddDelayTimer(function()
		self.show_index = TabIndex.chat_private
		self.now_index = TabIndex.chat_private
		self.curr_show_channel = CHANNEL_TYPE.PRIVATE
		self.curr_send_channel = CHANNEL_TYPE.PRIVATE
		self.channel.dropdown.captionText.text = Language.Channel[self.curr_show_channel]
		self.channel.dropdown.interactable = false
		self:SetPriviteRedVisible()
		MainUICtrl.Instance.view:SetPriviteRemindVisible(false)
		self.private_view:ChangePriviteTab(1)
	end, 0)
end

function ChatView:HandleSwitchTeam()
	self.show_index = TabIndex.chat_team
	self.now_index = TabIndex.chat_team
	self.curr_show_channel = CHANNEL_TYPE.TEAM
	self.curr_send_channel = CHANNEL_TYPE.TEAM
	self.channel.dropdown.value = 3
	self:ChangeChannelRedPoint(self.curr_show_channel, false)
	-- self.team_view:FlushTeamView()
	self.team_view:Flush()
end

function ChatView:HandleSwitchWorld()
	self.show_index = TabIndex.chat_world
	self.now_index = TabIndex.chat_world
	self.curr_show_channel = CHANNEL_TYPE.WORLD
	self.curr_send_channel = CHANNEL_TYPE.WORLD
	self.channel.dropdown.value = 0
	if self.channel.dropdown.captionText.text == Language.Channel[CHANNEL_TYPE.PRIVATE] then
		self.channel.dropdown.captionText.text = Language.Channel[self.curr_show_channel]
	end
	self:ChangeChannelRedPoint(self.curr_show_channel, false)
	-- self.world_view:FlushWorldView()
	self.world_view:Flush()
end

function ChatView:HandleSwitchGuild()
	self.show_index = TabIndex.chat_guild
	self.now_index = TabIndex.chat_guild
	self.curr_show_channel = CHANNEL_TYPE.GUILD
	self.curr_send_channel = CHANNEL_TYPE.GUILD
	self.channel.dropdown.value = 2
	self:ChangeChannelRedPoint(self.curr_show_channel, false)
	self.guild_view:FlushGuildView()
end

function ChatView:HandleSwitchCamp()
	self.show_index = TabIndex.chat_camp
	self.now_index = TabIndex.chat_camp
	self.curr_show_channel = CHANNEL_TYPE.CAMP
	self.curr_send_channel = CHANNEL_TYPE.CAMP
	self.channel.dropdown.value = 1
	self:ChangeChannelRedPoint(self.curr_show_channel, false)
	-- self.camp_view:FlushCampView()
	self.camp_view:Flush()
end

function ChatView:HandleSwitchSystem()
	self.show_index = TabIndex.chat_system
	self.now_index = TabIndex.chat_system
	self.curr_show_channel = CHANNEL_TYPE.SYSTEM
	self.curr_send_channel = CHANNEL_TYPE.WORLD
	self.channel.dropdown.value = 0
	-- self.system_view:FlushSystemView()
	self.system_view:Flush()
end

function ChatView:HandleSwitchChat()
	GlobalTimerQuest:AddDelayTimer(function()
		self.channel.dropdown.interactable = true
		self.tab_compre.toggle.isOn = true

		self:HandleSwitchCompre()
	end, 0)
end

function ChatView:HandleSwitchCompre()
	self.show_index = TabIndex.chat_compre
	self.now_index = TabIndex.chat_compre
	self.curr_show_channel = CHANNEL_TYPE.ALL
	self.curr_send_channel = CHANNEL_TYPE.WORLD
	self.channel.dropdown.value = 0
	if self.channel.dropdown.captionText.text == Language.Channel[CHANNEL_TYPE.PRIVATE] then
		self.channel.dropdown.captionText.text = Language.Channel[CHANNEL_TYPE.WORLD]
	end
	self.compre_view:FlushCompreView()
end

function ChatView:HandleSwitchAnswer()
	self.show_index = TabIndex.chat_answer
	self.now_index = TabIndex.chat_answer
	self.curr_show_channel = CHANNEL_TYPE.WORLD
	self.curr_send_channel = CHANNEL_TYPE.WORLD
	self.channel.dropdown.value = 0
	-- self.world_view:FlushWorldView()
	if self.answer_view then
		self.answer_view:Flush()
	end
end

function ChatView:HandleOpenSpeaker()
	TipsCtrl.Instance:ShowSpeakerView()
end

function ChatView:HandleOpenBlackList()
	ScoietyCtrl.Instance:ShowBlackListView()
end

function ChatView:HandleOpenItem()
	TipsCtrl.Instance:ShowPropView(TipsShowProViewFrom.FROM_CHAT)
end

function ChatView:HandleOpenShop()
	ViewManager.Instance:Open(ViewName.CoolChat)
end

--获取人物当前坐标
function ChatView:GetMainRolePos()
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

function ChatView:HandleInsertLocation()
	self:GetMainRolePos()
end

function ChatView:HandleVoiceStart()
	local level = PlayerData.Instance:GetRoleLevel()
	if self.curr_send_channel == CHANNEL_TYPE.WORLD then
		if not ChatData.Instance:GetChannelCdIsEnd(self.curr_send_channel) then
			local time = ChatData.Instance:GetChannelCdEndTime(self.curr_send_channel) - Status.NowTime
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
			return
		end

		--等级限制
		if level < COMMON_CONSTS.CHAT_LEVEL_LIMIT then
			local level_str = PlayerData.GetLevelString(COMMON_CONSTS.CHAT_LEVEL_LIMIT)
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, level_str))
			return
		else
			self.tab_world.toggle.isOn = true
		end
	elseif self.curr_send_channel == CHANNEL_TYPE.CAMP then
		if not ChatData.Instance:GetChannelCdIsEnd(self.curr_send_channel) then
			local time = ChatData.Instance:GetChannelCdEndTime(self.curr_send_channel) - Status.NowTime
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
			return
		end

		if level < COMMON_CONSTS.CHAT_LEVEL_LIMIT then
			local level_str = PlayerData.GetLevelString(COMMON_CONSTS.CHAT_LEVEL_LIMIT)
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, level_str))
			return
		else
			self.tab_camp.toggle.isOn = true
		end
	elseif self.curr_send_channel == CHANNEL_TYPE.GUILD then
		if GuildData.Instance.guild_id <= 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
			return
		else
			self.tab_guild.toggle.isOn = true
		end
	elseif self.curr_send_channel == CHANNEL_TYPE.TEAM then
		--是否组队
		if not ScoietyData.Instance:GetTeamState() then
			SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
			return
		else
			self.tab_team.toggle.isOn = true
		end
	elseif self.curr_send_channel == CHANNEL_TYPE.PRIVATE then
		local private_role_id = ChatData.Instance:GetCurrentRoleId()
		if not private_role_id then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.CorrentObj)
			return
		end
	else
		print_error("HandleChangeChannel with unknow index:", self.curr_send_channel)
		return
	end
	ChatData.Instance:SetCanSendVoice(true)
	-- self.show_listen_trigger:SetValue(true)
	AutoVoiceCtrl.Instance:ShowVoiceView(self.curr_send_channel)
end

function ChatView:HandleVoiceStop()
	-- self.show_listen_trigger:SetValue(false)
	if AutoVoiceCtrl.Instance.view:IsOpen() then
		AutoVoiceCtrl.Instance.view:Close()
	end
end

function ChatView:ShowListenTrigger(state)
	self.show_listen_trigger:SetValue(state)
end

function ChatView:HandleOpenRedPackage()
	local main_role = GameVoManager.Instance:GetMainRoleVo()
	if main_role.guild_id <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
		return
	end
	HongBaoCtrl.Instance:ShowHongBaoView(GameEnum.HONGBAO_SEND, RED_PAPER_TYPE.RED_PAPER_TYPE_COMMON)
end

function ChatView:HandleChangeChannel(index)
	if index == 0 then
		self.curr_send_channel = CHANNEL_TYPE.WORLD
	elseif index == 1 then
		self.curr_send_channel = CHANNEL_TYPE.CAMP
	elseif index == 2 then
		self.curr_send_channel = CHANNEL_TYPE.GUILD
	elseif index == 3 then
		self.curr_send_channel = CHANNEL_TYPE.TEAM
	else
		print_error("HandleChangeChannel with unknow index:", index)
	end
	self:ChangeButtonEnable()
end

function ChatView:AddTextToInput(text)
	if text and self.chat_input and self.chat_input.gameObject.activeInHierarchy then
		local edit_text = self.chat_input.input_field.text
		self.chat_input.input_field.text = edit_text .. text
	end
end

function ChatView:HandleOpenEmoji()
	local function callback(face_id)
		self:SetFace(face_id)
	end
	TipsCtrl.Instance:ShowExpressView(callback)
end

local input_text_list = {}
local input_index = 0
local input_cur_text = ""
function ChatView:HandleSend()
	local text = self.chat_input.input_field.text
	local content_type = CHAT_CONTENT_TYPE.TEXT
	if text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		self.chat_input.input_field.text = ""
		ChatData.Instance:ClearInput()
		return
	end

	local function SendChannelChat()
		--格式化字符串
		text = ChatData.Instance:FormattingMsg(text, content_type, 1)
		--屏蔽敏感词
		--if ChatFilter.Instance:IsIllegal(text) then
			--SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.ContentIsIllegal)
			--return
		--end
		text = ChatFilter.Instance:Filter(text)
		-- 发送文字信息
		self:ChangeLockState(false)
		ChatCtrl.SendChannelChat(self.curr_send_channel, text, content_type)
		self.chat_input.input_field.text = ""
		ChatData.Instance:ClearInput()

		--设置聊天冷却时间
		ChatData.Instance:SetChannelCdEndTime(self.curr_send_channel)
		self:ChangeButtonEnable()
		return
	end

	local len = string.len(text)
	if len >= 3 and string.sub(text, 1, 3) == "/gm" then
		local blank_begin, blank_end = string.find(text, " ")
		local colon_begin, colon_end = string.find(text, ":")
		if blank_begin and blank_end and colon_begin and colon_end then
			local cmd_type = string.sub(text, blank_end + 1, colon_begin - 1)
			local command = string.sub(text, colon_end + 1, -1)
			SysMsgCtrl.SendGmCommand(cmd_type, command)
		end
	elseif len >= 4 and string.sub(text, 1 , 5) == "/cmd " then
		local blank_begin, blank_end = string.find(text, " ")
		if blank_begin and blank_end then
			ClientCmdCtrl.Instance:Cmd(string.sub(text, blank_end + 1, len))
		end
	else
		if self.curr_send_channel == CHANNEL_TYPE.WORLD then
			-- if not ChatData.Instance:GetChannelCdIsEnd(self.curr_send_channel) then
			-- 	local time = ChatData.Instance:GetChannelCdEndTime(self.curr_send_channel) - Status.NowTime
			-- 	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
			-- 	-- ChatData.Instance:ClearInput()
			-- 	return
			-- end

			local level = GameVoManager.Instance:GetMainRoleVo().level
			--等级限制
			if level < COMMON_CONSTS.CHAT_LEVEL_LIMIT then
				local level_str = PlayerData.GetLevelString(COMMON_CONSTS.CHAT_LEVEL_LIMIT)
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, level_str))
				self.chat_input.input_field.text = ""
				ChatData.Instance:ClearInput()
				return
			else
				self.tab_world.toggle.isOn = true

				local other_config = ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1]
				local free_times = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_WORLD_CHANNEL_CHAT_FREE_TIMES)
				local total_times = VipPower.Instance:GetParam(VIPPOWER.WORLD_CHAT_FREE_TIMES)

				if total_times - free_times > 0 then
					SendChannelChat()
					return
				else
					if UnityEngine.PlayerPrefs.GetInt("aoto_buy_world_chat") == 1 then
						SendChannelChat()
						return
					else
						local vo = GameVoManager.Instance:GetMainRoleVo()
						local count = vo.gold
						if count < other_config.world_chat_need_gold then
							self.chat_input.input_field.text = ""
							ChatData.Instance:ClearInput()
							SendChannelChat()
							--SysMsgCtrl.Instance:ErrorRemind(Language.Common.NoEnoughGold)
							return
						end

						TipsCtrl.Instance:ShowCommonTip(SendChannelChat, nil, string.format(Language.Chat.WorldChatCost, other_config.world_chat_need_gold), nil, nil, true, false, "aoto_buy_world_chat")
						return
					end
				end
			end

		elseif self.curr_send_channel == CHANNEL_TYPE.TEAM then
			--是否组队
			if not ScoietyData.Instance.have_team then
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
				self.chat_input.input_field.text = ""
				ChatData.Instance:ClearInput()
				return
			else
				self.tab_team.toggle.isOn = true
			end
		elseif self.curr_send_channel == CHANNEL_TYPE.GUILD then
			--是否有公会
			if GuildData.Instance.guild_id <= 0 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotEnterGuild)
				self.chat_input.input_field.text = ""
				ChatData.Instance:ClearInput()
				return
			else
				self.tab_guild.toggle.isOn = true
			end
		elseif self.curr_send_channel == CHANNEL_TYPE.CAMP then
			local level = GameVoManager.Instance:GetMainRoleVo().level
			--等级限制
			if level < COMMON_CONSTS.CHAT_LEVEL_LIMIT then
				local level_str = PlayerData.GetLevelString(COMMON_CONSTS.CHAT_LEVEL_LIMIT)
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, level_str))
				self.chat_input.input_field.text = ""
				ChatData.Instance:ClearInput()
				return
			else
				self.tab_camp.toggle.isOn = true
			end
		elseif self.curr_send_channel == CHANNEL_TYPE.PRIVATE then
			local private_role_id = ChatData.Instance:GetCurrentRoleId()
			if not private_role_id or private_role_id == 0 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Chat.CorrentObj)
				self.chat_input.input_field.text = ""
				ChatData.Instance:ClearInput()
				return
			end
			--格式化字符串
			text = ChatData.Instance:FormattingMsg(text, content_type, 1)
			--屏蔽敏感词
			text = ChatFilter.Instance:Filter(text)

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

			ChatData.Instance:AddPrivateMsg(private_role_id, msg_info)
			self:Flush(CHANNEL_TYPE.PRIVATE, {1})
			ChatCtrl.SendSingleChat(private_role_id, text, content_type)
			self.chat_input.input_field.text = ""
			ChatData.Instance:ClearInput()
			return
		else
			print_error("HandleChangeChannel with unknow index:", self.curr_send_channel)
			self.chat_input.input_field.text = ""
			ChatData.Instance:ClearInput()
			return
		end
		
		SendChannelChat()
	end

	self.chat_input.input_field.text = ""
	input_index = 0

	if text ~= "" and text ~= input_text_list[1] then
		for i,v in ipairs(input_text_list) do
			if text == v then
				table.remove(input_text_list, i)
				break
			end
		end
		table.insert(input_text_list, 1, text)
	end

	if #input_text_list > 10 then
		table.remove(input_text_list)
	end

	-- 取消选中，不然输入聊天后又重新打开输入框
	-- self.chat_input.input_field:ActivateInputField()
	ChatData.Instance:ClearInput()
end

function ChatView:HandleInputUp()
	if input_index == 0 then
		input_cur_text = self.chat_input.input_field.text
	end

	if nil ~= input_text_list[input_index + 1] then
		input_index = input_index + 1
		self.chat_input.input_field.text = input_text_list[input_index]
	end
end

function ChatView:HandleInputDown()
	if nil ~= input_text_list[input_index - 1] then
		input_index = input_index - 1
		self.chat_input.input_field.text = input_text_list[input_index]
	else
		input_index = 0
		self.chat_input.input_field.text = input_cur_text
	end
end

function ChatView:IsPrivateOpen()
	return self:IsOpen() and self.curr_show_channel == CHANNEL_TYPE.PRIVATE
end

--添加物品
function ChatView:SetData(data, is_equip)
	if not data or not next(data) then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then
		return
	end

	local text = self.chat_input.input_field.text
	if ChatData.ExamineEditText(text, 2) then
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
		ChatData.Instance:InsertItemTab(cell_data, 1)
	end
end

-- 添加表情
function ChatView:SetFace(index)
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

function ChatView:FlushNowView()
	if self.tab_world.toggle.isOn then
		-- self.world_view:FlushWorldView()
		self.world_view:Flush()
	elseif self.tab_team.toggle.isOn then
		-- self.team_view:FlushTeamView()
		self.team_view:Flush()
	elseif self.tab_guild.toggle.isOn then
		self.guild_view:FlushGuildView()
	elseif self.tab_camp.toggle.isOn then
		self.camp_view:Flush()
		-- self.camp_view:FlushCampView()
	elseif self.tab_system.toggle.isOn then
		-- self.system_view:FlushSystemView()
		self.system_view:Flush()
	elseif self.tab_private.toggle.isOn then
		self.private_view:ChangePriviteTab(1)
	elseif self.tab_compre.toggle.isOn then
		self.compre_view:FlushCompreView()
	elseif self.tab_answer.toggle.isOn then
		self.answer_view:Flush()
	end
end

function ChatView:ChangeChannelRedPoint(channel_type, value)
	if channel_type == CHANNEL_TYPE.WORLD then
		self.world_red:SetValue(value)
	elseif channel_type == CHANNEL_TYPE.TEAM then
		self.team_red:SetValue(value)
	elseif channel_type == CHANNEL_TYPE.GUILD then
		self.guild_red:SetValue(value)
	end
end

function ChatView:SetPriviteRedVisible()
	local state = ChatData.Instance:GetHavePriviteChat()
	if state then
		if self.tab_private.toggle.isOn then
			-- self.privite_red:SetValue(false)
			self.private_view:SetPriviteRedPoint(true)
		else
			self.privite_red:SetValue(true)
		end
	else
		self.privite_red:SetValue(false)
	end
end

function ChatView:ChangePriviteTab(tab_index)
	self.private_view:ChangePriviteTab(tab_index)
end

function ChatView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if self.private_view then
			self.private_view:FlushFriendView()
		end
		if self.tab_private.toggle.isOn then
			if k == CHANNEL_TYPE.PRIVATE then
				if v[1] then
					self.private_view:FlushView(v[1])
				end
			end
		else
			if k == CHANNEL_TYPE.WORLD and self.tab_world.toggle.isOn then
				--self.world_view:FlushWorldView()
				self.world_view:Flush()
			elseif k == CHANNEL_TYPE.TEAM and self.tab_team.toggle.isOn then
				self.team_view:Flush()
				-- self.team_view:FlushTeamView()
			elseif k == CHANNEL_TYPE.GUILD and self.tab_guild.toggle.isOn then
				self.guild_view:FlushGuildView()
			elseif k == CHANNEL_TYPE.CAMP and self.tab_camp.toggle.isOn then
				-- self.camp_view:FlushCampView()
				self.camp_view:Flush()
			elseif k == CHANNEL_TYPE.SYSTEM and self.tab_system.toggle.isOn then
				self.system_view:Flush()
				-- self.team_view:FlushSystemView()
			elseif k == CHANNEL_TYPE.ALL and self.tab_compre.toggle.isOn then
				self.compre_view:FlushCompreView()
			elseif k == CHANNEL_TYPE.WORLD and self.tab_answer.toggle.isOn then
				self.answer_view:Flush()
			end
		end
	end

	if self.show_send_btn ~= nil and self.tab_answer then
		self.show_send_btn:SetValue(not self.tab_answer.toggle.isOn)
	end
end

function ChatView:FlushPrivateRoleList()
	if self.private_view then
		self.private_view:FlushFriendView()
	end
end

function ChatView:CheckShowCd()
	for k,v in pairs(CHANNEL_CD) do
		if k == self.curr_send_channel then 
			return true
		end
	end
	return false
end