require("game/chat/chat_team_view")
require("game/chat/chat_world_view")
require("game/chat/chat_system_view")
require("game/chat/chat_compre_view")
require("game/chat/chat_question_view")

ChatView = ChatView or BaseClass(BaseView)

local SPEED = 50
local UILayer = GameObject.Find("GameRoot/UILayer")

function ChatView:__init()
	self.ui_config = {"uis/views/chatview_prefab","ChatView"}

	self.close_mode = CloseMode.CloseVisible
	self.curr_send_channel = CHANNEL_TYPE.ALL	-- 发送频道
	self.curr_show_channel = CHANNEL_TYPE.ALL	-- 显示频道

	self.last_flush_redpoint_time = 0
    self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function ChatView:ReleaseCallBack()
	if self.team_view then
		self.team_view:DeleteMe()
		self.team_view = nil
	end
	if self.world_view then
		self.world_view:DeleteMe()
		self.world_view = nil
	end
	if self.system_view then
		self.system_view:DeleteMe()
		self.system_view = nil
	end
	if self.compre_view then
		self.compre_view:DeleteMe()
		self.compre_view = nil
	end
	if self.question_view then
		self.question_view:DeleteMe()
		self.question_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.chat_measuring then
		GameObject.Destroy(self.chat_measuring.root_node.gameObject)
		self.chat_measuring:DeleteMe()
		self.chat_measuring = nil
	end
	self:RemoveDelayTime()

	-- 清理变量和对象
	self.world_red = nil
	self.team_red = nil
	self.cool_time = nil
	self.button_text = nil
	self.is_send_cool = nil
	self.show_listen_trigger = nil
	self.show_quick_speak = nil
	self.chat_input = nil
	self.tab_world = nil
	self.tab_team = nil
	self.tab_system = nil
	self.tab_compre = nil
	self.tab_question = nil
	self.listen_trigger = nil
	self.red_point_list = nil
	self.right_bar_bg = nil
	self.show_horn = nil
	self.show_speaker = nil
end

function ChatView:LoadCallBack()
	--获取变量
	self.world_red = self:FindVariable("WorldRed")
	self.team_red = self:FindVariable("TeamRed")
	self.cool_time = self:FindVariable("CoolTime")

	self.button_text = self:FindVariable("ButtonText")
	self.is_send_cool = self:FindVariable("IsSendCool")

	self.show_listen_trigger = self:FindVariable("ShowListenTrigger")

	self.show_quick_speak = self:FindVariable("ShowQuickSpeak")

	self.show_horn = self:FindVariable("ShowHorn")

	self.show_speaker = self:FindVariable("ShowSpeaker")

	-- 查找组件
	self.chat_input = self:FindObj("ChatInput")

	self.tab_world = self:FindObj("TabWorld")
	self.tab_team = self:FindObj("TabTeam")
	self.tab_system = self:FindObj("TabSystem")
	self.tab_compre = self:FindObj("TabAll")
	self.tab_question = self:FindObj("TabQuestion")
	self.right_bar_bg = self:FindObj("RightBarBg")

	--监听滑动事件
	self.listen_trigger = self:FindObj("ListenTrigger")
	local event_trigger = self.listen_trigger:GetComponent(typeof(EventTriggerListener))
	event_trigger:AddDragListener(BindTool.Bind(self.OnTriggerChange, self))

	self.red_point_list = {
		[RemindName.CoolChat] = self:FindVariable("BubbleRedPoint"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	-- 监听UI事件
	self:ListenEvent("Close",
		BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("OpenSpeaker",
		BindTool.Bind(self.HandleOpenSpeaker, self))
	self:ListenEvent("OpenBlackList",
		BindTool.Bind(self.HandleOpenBlackList, self))
	self:ListenEvent("OpenItem",
		BindTool.Bind(self.HandleOpenItem, self))
	self:ListenEvent("OpenShop",
		BindTool.Bind(self.HandleOpenShop, self))
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
	self:ListenEvent("InputUp",
		BindTool.Bind(self.HandleInputUp, self))
	self:ListenEvent("InputDown",
		BindTool.Bind(self.HandleInputDown, self))
	self:ListenEvent("VoiceSettingClick",
		BindTool.Bind(self.VoiceSettingClick, self))
	self:ListenEvent("OpenNotice",
		BindTool.Bind(self.OpenNotice, self))

	self:ListenEvent("SwitchAll",
		BindTool.Bind(self.HandleSwitchCompre, self))
	self:ListenEvent("SwitchWorld",
		BindTool.Bind(self.HandleSwitchWorld, self))
	self:ListenEvent("SwitchTeam",
		BindTool.Bind(self.HandleSwitchTeam, self))
	self:ListenEvent("SwitchSystem",
		BindTool.Bind(self.HandleSwitchSystem, self))
	self:ListenEvent("SwitchQuestion",
		BindTool.Bind(self.HandleSwitchQuestion, self))

	self.team_view = ChatTeamView.New(self:FindObj("ContentTeam"))
	self.world_view = ChatWorldView.New(self:FindObj("ContentWorld"))
	self.system_view = ChatSystemView.New(self:FindObj("ContentSystem"))
	self.compre_view = ChatCompreView.New(self:FindObj("ContentAll"))
	self.question_view = ChatQuestionView.New(self:FindObj("ContentQuestion"))

	self.world_text = Language.Chat.Send

	-- 根据平台配置显示聊天快捷
	local is_show_quick_speak = ChatData.Instance:SetNormalQuickSpeak()
	self.show_quick_speak:SetValue(is_show_quick_speak)
end

function ChatView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
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
end

function ChatView:GetChatMeasuring(delegate)
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

function ChatView:ChangeLockState(state)

end

--改变right_bar_bg长度
function ChatView:ChangePanelHeightMin()
	local panel_width = self.right_bar_bg.rect.rect.width
	self.right_bar_bg.rect.sizeDelta = Vector2(panel_width, 200)
end

--改变right_bar_bg长度
function ChatView:ChangePanelHeightMax()
	local panel_width = self.right_bar_bg.rect.rect.width
	self.right_bar_bg.rect.sizeDelta = Vector2(panel_width, 292)
end

function ChatView:CloseCallBack()
	self.str_list = {}
	AudioPlayer.Stop()		--停止播放语音
	AudioService.Instance:SetMasterVolume(1.0)
	self:ClearBtnCountDown()
	ChatData.Instance:SetIsLockState(false)

	if self.role_attr_change_event then
		PlayerData.Instance:UnlistenerAttrChange(self.role_attr_change_event)
		self.role_attr_change_event = nil
	end

	if self.voice_switch then
		GlobalEventSystem:UnBind(self.voice_switch)
		self.voice_switch = nil
	end
end

function ChatView:AddNotice(str)
	self.total_count = self.total_count + 1
	self.str_list[self.total_count] = str
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

function ChatView:ChangeButtonEnable()
	self:ClearBtnCountDown()
	local function timer_func(elapse_time, total_time)
		local is_show_button
		if elapse_time >= total_time then
			-- self:ClearBtnCountDown()
			self.world_text = Language.Chat.Send
			is_show_button = false
		else
			self.world_text = string.format(Language.Chat.ResetTimes, total_time - math.floor(elapse_time))
			is_show_button = true
		end
		if self.curr_send_channel == CHANNEL_TYPE.TEAM then
			is_show_button = false
		end
		self.is_send_cool:SetValue(is_show_button)
		self:SetSendButtonText()

	end
	if (self.tab_world.toggle.isOn or self.tab_compre.toggle.isOn or self.tab_system.toggle.isOn or self.tab_question.toggle.isOn) and
		(self.curr_send_channel == CHANNEL_TYPE.WORLD or self.curr_send_channel == CHANNEL_TYPE.ALL) then
		if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
			local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
			time = math.ceil(time)
			self.is_send_cool:SetValue(true)
			self.world_text = string.format(Language.Chat.ResetTimes, time)
			self.button_count_down = CountDown.Instance:AddCountDown(time, 1, timer_func)
		else
			self.world_text = Language.Chat.Send
			self.is_send_cool:SetValue(false)
		end
	else
		self.world_text = Language.Chat.Send
		self.is_send_cool:SetValue(false)
	end
	self:SetSendButtonText(self.curr_send_channel)
end

function ChatView:SetSendButtonText()
	if self.curr_send_channel == CHANNEL_TYPE.TEAM then
		self.button_text:SetValue(Language.Chat.Send)
	else
		self.button_text:SetValue(self.world_text)
	end
end

function ChatView:OpenCallBack()
	self:ChangeButtonEnable()

	local is_lock = ChatData.Instance:GetIsLockState()
	self:ChangeLockState(is_lock)
	self.role_attr_change_event = BindTool.Bind1(self.OnRoleAttrValueChange, self)
	PlayerData.Instance:ListenerAttrChange(self.role_attr_change_event)
	self:OpenLevelLimitHorn()
	self.voice_switch = GlobalEventSystem:Bind(ChatEventType.VOICE_SWITCH,
		BindTool.Bind(self.UpdateVoiceSwitch, self))
	self:UpdateVoiceSwitch()
end

-- 喇叭开启
function ChatView:OpenLevelLimitHorn()
	local level = PlayerData.Instance:GetRoleLevel()
	local is_can_speaker = ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.SPEAKER, true)
	if self.show_horn then
		self.show_horn:SetValue(is_can_speaker)
		if is_can_speaker then
			self:ChangePanelHeightMax()
		else
			self:ChangePanelHeightMin()
		end
	end
end

function ChatView:OnRoleAttrValueChange(key, new_value, old_value)
	if key == "level" or key == "vip_level" then
		self:OpenLevelLimitHorn()
	end
end

function ChatView:ShowIndexCallBack(index)
	if index == TabIndex.chat_world then
		self.tab_world.toggle.isOn = true
		self:HandleSwitchWorld()
	elseif index == TabIndex.chat_team then
		self.tab_team.toggle.isOn = true
		self:HandleSwitchTeam()
	elseif index == TabIndex.chat_system then
		self.tab_system.toggle.isOn = true
		self:HandleSwitchSystem()
	elseif index == TabIndex.chat_compre then
		self.tab_compre.toggle.isOn = true
		self:HandleSwitchCompre()
	elseif index == TabIndex.chat_question then
		self.tab_question.toggle.isOn = true
		self:HandleSwitchQuestion()
	else
		self:ShowIndex(TabIndex.chat_compre)
	end
end

function ChatView:HandleClose()
	if AutoVoiceCtrl.Instance.view:IsOpen() then
		return
	end
	ViewManager.Instance:Close(ViewName.Chat)
end

function ChatView:HandleSwitchTeam()
	self.curr_show_channel = CHANNEL_TYPE.TEAM
	self.curr_send_channel = CHANNEL_TYPE.TEAM
	self:ChangeChannelRedPoint(self.curr_show_channel, false)
	self.team_view:FlushTeamView()
	self:SetSendButtonText()
end

function ChatView:HandleSwitchWorld()
	self.curr_show_channel = CHANNEL_TYPE.WORLD
	self.curr_send_channel = CHANNEL_TYPE.WORLD
	self:ChangeChannelRedPoint(self.curr_show_channel, false)
	self.world_view:FlushWorldView()
	self:SetSendButtonText()
end

function ChatView:HandleSwitchSystem()
	self.curr_show_channel = CHANNEL_TYPE.SYSTEM
	self.curr_send_channel = CHANNEL_TYPE.WORLD
	self.system_view:FlushSystemView()
	self:SetSendButtonText()
end

function ChatView:HandleSwitchCompre()
	self.curr_show_channel = CHANNEL_TYPE.ALL
	self.curr_send_channel = CHANNEL_TYPE.WORLD
	self.compre_view:FlushCompreView()
	self:SetSendButtonText()
end

function ChatView:HandleSwitchQuestion()
	self.curr_show_channel = CHANNEL_TYPE.WORLD_QUESTION
	self.curr_send_channel = CHANNEL_TYPE.WORLD
	self.question_view:FlushQuestionView()
	self:SetSendButtonText()
end

function ChatView:HandleOpenSpeaker()
	TipsCtrl.Instance:ShowSpeakerView()
end

function ChatView:HandleOpenBlackList()
	ScoietyCtrl.Instance:ShowBlackListView()
end

function ChatView:HandleOpenItem()
	TipsCtrl.Instance:ShowPropView()
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
		--直接发出去
		if self.curr_send_channel == CHANNEL_TYPE.WORLD then
			if not ChatData.Instance:GetChannelCdIsEnd(self.curr_send_channel) then
				local time = ChatData.Instance:GetChannelCdEndTime(self.curr_send_channel) - Status.NowTime
				SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
				return
			end

			local level = GameVoManager.Instance:GetMainRoleVo().level

			if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
				return
			else
				self:ShowIndex(TabIndex.chat_world)
			end
			ChatData.Instance:SetChannelCdEndTime(self.curr_send_channel)
			self:ChangeButtonEnable()
		elseif self.curr_send_channel == CHANNEL_TYPE.TEAM then
			--是否组队
			if not ScoietyData.Instance.have_team then
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
				return
			else
				self.tab_team.toggle.isOn = true
				self:HandleSwitchTeam()
			end
		end

		local scene_id = Scene.Instance:GetSceneId()
		local msg = "{point;".. Scene.Instance:GetSceneName() .. ";" .. x .. ";" .. y .. ";" .. scene_id .. ";" .. scene_key .. "}"
		ChatCtrl.SendChannelChat(self.curr_send_channel, msg, CHAT_CONTENT_TYPE.TEXT)
	end
end

function ChatView:HandleInsertLocation()
	self:GetMainRolePos()
end

function ChatView:HandleVoiceStart()
	if self.curr_send_channel == CHANNEL_TYPE.WORLD then
		if not ChatData.Instance:GetChannelCdIsEnd(self.curr_send_channel) then
			local time = ChatData.Instance:GetChannelCdEndTime(self.curr_send_channel) - Status.NowTime
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.CanNotChat, math.ceil(time)))
			return
		end

		local level = PlayerData.Instance:GetRoleLevel()

		if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
			return
		else
			self:ShowIndex(TabIndex.chat_world)
		end
	elseif self.curr_send_channel == CHANNEL_TYPE.TEAM then
		--是否组队
		if not ScoietyData.Instance:GetTeamState() then
			SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
			return
		else
			self.tab_team.toggle.isOn = true
			self:HandleSwitchTeam()
		end
	else
		print_error("HandleChangeChannel with unknow index:", self.curr_send_channel)
		return
	end
	ChatData.Instance:SetCanSendVoice(true)
	AutoVoiceCtrl.Instance:ShowVoiceView(self.curr_send_channel)
end

function ChatView:HandleVoiceStop()
	if AutoVoiceCtrl.Instance.view:IsOpen() then
		AutoVoiceCtrl.Instance.view:Close()
	end
end

function ChatView:ShowListenTrigger(state)
	self.show_listen_trigger:SetValue(state)
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

function ChatView:OpenNotice()
	local function callback(str)
		local level = GameVoManager.Instance:GetMainRoleVo().level

		if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
			return
		else
			self:ShowIndex(TabIndex.chat_world)
		end
		--设置世界聊天冷却时间
		ChatData.Instance:SetChannelCdEndTime(self.curr_send_channel)
		self:ChangeButtonEnable()
		ChatCtrl.SendChannelChat(self.curr_send_channel, str, CHAT_CONTENT_TYPE.TEXT)
	end
	ChatCtrl.Instance:OpenQuickChatView(QUICK_CHAT_TYPE.NORMAL, callback)
end

local input_text_list = {}
local input_index = 0
local input_cur_text = ""
function ChatView:HandleSend()
	local text = self.chat_input.input_field.text
	--清除文本
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

	if text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		ChatData.Instance:ClearInput()
		return
	end

	local content_type = CHAT_CONTENT_TYPE.TEXT
	local len = string.len(text)
	if len >= 1 and string.sub(text, 1, 1) == "/" then
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
		end
	else
		--格式化字符串
		text = ChatData.Instance:FormattingMsg(text, content_type)

		--有非法字符直接不让发
		if ChatFilter.Instance:IsIllegal(text, false) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent)
			ChatData.Instance:ClearInput()
			return
		end

		if self.curr_send_channel == CHANNEL_TYPE.WORLD then
			local level = GameVoManager.Instance:GetMainRoleVo().level

			if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.WORLD) then
				ChatData.Instance:ClearInput()
				return
			else
				self:ShowIndex(TabIndex.chat_world)
			end

			--设置世界聊天冷却时间
			ChatData.Instance:SetChannelCdEndTime(self.curr_send_channel)
			self:ChangeButtonEnable()
		elseif self.curr_send_channel == CHANNEL_TYPE.TEAM then
			--是否组队
			if not ScoietyData.Instance.have_team then
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.CreateTeam)
				ChatData.Instance:ClearInput()
				return
			else
				self.tab_team.toggle.isOn = true
				self:HandleSwitchTeam()
			end
		else
			print_error("HandleChangeChannel with unknow index:", self.curr_send_channel)
			ChatData.Instance:ClearInput()
			return
		end

		-- 发送文字信息
		self:ChangeLockState(false)
		ChatCtrl.SendChannelChat(self.curr_send_channel, text, content_type)
	end

	ChatData.Instance:ClearInput()
	-- self.chat_input.input_field:ActivateInputField()
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

--添加物品
function ChatView:SetData(data, is_equip)
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
function ChatView:SetFace(index)
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

function ChatView:ChangeChannelRedPoint(channel_type, value)
	if channel_type == CHANNEL_TYPE.WORLD then
		self.world_red:SetValue(value)
	elseif channel_type == CHANNEL_TYPE.TEAM then
		self.team_red:SetValue(value)
	end
end

function ChatView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == CHANNEL_TYPE.WORLD then
			if self.tab_world.toggle.isOn then
				self.world_view:FlushWorldView()
			end
		elseif k == CHANNEL_TYPE.TEAM then
			if self.tab_team.toggle.isOn then
				self.team_view:FlushTeamView()
			end
		elseif k == CHANNEL_TYPE.SYSTEM then
			if self.tab_system.toggle.isOn then
				self.system_view:FlushSystemView()
			end
		elseif k == CHANNEL_TYPE.WORLD_QUESTION then
			if self.tab_question.toggle.isOn then
				self.question_view:FlushQuestionView()
			end
		elseif k == CHANNEL_TYPE.ALL then
			if self.tab_compre.toggle.isOn then
				self.compre_view:FlushCompreView()
			end
		end
	end
end

-- 根据渠道开启语音聊天
function ChatView:UpdateVoiceSwitch()
	self.show_speaker:SetValue(not SHIELD_VOICE)
end