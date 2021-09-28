AutoVoiceView = AutoVoiceView or BaseClass(BaseView)

function AutoVoiceView:__init()
	self.ui_config = {"uis/views/autovoiceview_prefab", "AutoVioceView"}
	self.time_value = 10
end

function AutoVoiceView:ReleaseCallBack()
	self.time = nil
end

function AutoVoiceView:LoadCallBack()
	self.time = self:FindVariable("Time")
end

function AutoVoiceView:ChangeTime()
	if self.time_value <= 0 then
		if self.quest then
			CountDown.Instance:RemoveCountDown(self.quest)
			self.quest = nil
		end
		self:Close()
		return
	end

	self.time_value = self.time_value - 1
	self.time:SetValue(self.time_value)
end

function AutoVoiceView:SetChannelType(channel_type)
	self.curr_send_channel = channel_type
end

function AutoVoiceView:OpenCallBack()
	self.time_value = 10
	self.time:SetValue(self.time_value)
	self.quest = CountDown.Instance:AddCountDown(12, 1, BindTool.Bind(self.ChangeTime, self))
	if AudioGVoice then
		GVoiceManager.Instance:StartRecord()
	else
		AudioRecorder.Start()
	end
	--关闭所有声音
	AudioService.Instance:SetMasterVolume(0.0)
end

function AutoVoiceView:CloseCallBack()
	--还原所有声音
	AudioService.Instance:SetMasterVolume(1.0)

	if self.quest then
		CountDown.Instance:RemoveCountDown(self.quest)
		self.quest = nil
	end

	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local time = math.floor(TimeCtrl.Instance:GetServerTime())
	local duration = 10 - self.time_value

	-- GVoice
	if AudioGVoice then
		local callback = function (succ, file_id, str)
			if succ then
				--最短录音时间1S
				if self.time_value >= 9 then
					SysMsgCtrl.Instance:ErrorRemind(Language.Chat.RecordToShort)
					return
				end
				self:SendSoundMsg(string.format("gvoice;%s;%s;%s;%s;%s", file_id, str, duration, role_id, time))
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.Chat.RecordFail)
			end
		end
		GVoiceManager.Instance:StopRecord(callback)
		return
	end

	local path = AudioRecorder.Stop()
	--最短录音时间1S
	if self.time_value >= 9 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.RecordToShort)
		return
	end

	if path == nil or path == "" then
		return
	end

	self.sound_name = string.format("sound_%s_%s_%s.amr", time, role_id, duration)
	self.sound_url = ChatRecordMgr.GetUrlSoundPath(self.sound_name)

	local callback = BindTool.Bind1(self.UploadCallback, self)

	--上传失败
	local function CancelUpload()
		HttpClient:CancelUpload(self.sound_url, callback)
	end

	if not HttpClient:Upload(self.sound_url, path, callback) then
		CancelUpload()
		print_error("上传失败", self.sound_url, path)
		return
	end
end

--上传语音回调
function AutoVoiceView:UploadCallback(url, path, is_succ)
	if is_succ then
		if self.curr_send_channel == CHANNEL_TYPE.WORLD then
			--设置世界聊天冷却时间
			ChatData.Instance:SetChannelCdEndTime(self.curr_send_channel)
		end
		self:SendSoundMsg(self.sound_name)
	end
end

-- 发送语音消息
function AutoVoiceView:SendSoundMsg(message)
	local content_type = CHAT_CONTENT_TYPE.AUDIO
	if nil ~= self.curr_send_channel then
		ChatCtrl.SendChannelChat(self.curr_send_channel, message, content_type)
	else
		local private_role_id = ChatData.Instance:GetCurrentId()
		if private_role_id > SPECIAL_CHAT_ID.ALL then
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
			msg_info.content = message
			msg_info.send_time_str = TimeUtil.FormatTable2HMS(TimeCtrl.Instance:GetServerTimeFormat())
			msg_info.content_type = content_type
			msg_info.tuhaojin_color = CoolChatData.Instance:GetTuHaoJinCurColor() or 0			--土豪金
			msg_info.channel_window_bubble_type = CoolChatData.Instance:GetSelectSeq()					--气泡框
			msg_info.is_read = 1

			ChatData.Instance:AddPrivateMsg(private_role_id, msg_info)
			ChatCtrl.SendSingleChat(private_role_id, message, content_type)
			if ViewManager.Instance:IsOpen(ViewName.ChatGuild) then
				ViewManager.Instance:FlushView(ViewName.ChatGuild, "new_chat", {CHANNEL_TYPE.PRIVATE, private_role_id})
			end
		else
			print_error("channel is nil!!!!!!!!!!!!!")
		end
	end
end