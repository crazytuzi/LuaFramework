ChatMsgInput = ChatMsgInput or BaseClass(BaseRender)

ChatMsgInput.record_state = RecordState.Free		-- 录音状态

function ChatMsgInput:__init(x, y, w, h, send_callback)
	self.width = w
	self.height = h

	self.view:setPosition(x, y)
	self.view:setContentWH(w, h)

	self.send_callback = send_callback

	self.input_mode_is_text = true
	self.cd_timer = nil
	self.record_timer = nil
	self.record_start_time = 0
	self.curr_send_channel = -1 					-- 频道
	self.sound_name = ""

	self.private_role_id = 0
	self.private_role_name = ""
end

function ChatMsgInput:__delete()
	self:ClearCdTimer()
	self:ClearRecordTimer()
	self.edit_input = nil
end

function ChatMsgInput:GetView()
	return self.view
end

function ChatMsgInput:CreateEditView()
	if nil == self.edit_view then
		self.edit_view = XUI.CreateLayout(self.width / 2, self.height / 2, self.width, self.height)
		self.view:addChild(self.edit_view)
	end
end

-- 创建发送按钮
function ChatMsgInput:CreateSendBtn(x, y)
	self:CreateEditView()

	x = x or self.width - 20
	y = y or y or self.height / 2 + 3

	self.btn_send = XUI.CreateButton(x, y, 0, 0, false, ResPath.GetCommon("btn_151"), "", "", true)
	self.btn_send:setTitleFontSize(26)
	self.btn_send:setTitleFontName(COMMON_CONSTS.FONT)
	self.btn_send:setTitleText(Language.Chat.Send)
	self.btn_send:setTitleColor(cc.c3b(250, 230, 191))
	self.edit_view:addChild(self.btn_send)
	self.btn_send:addClickEventListener(BindTool.Bind1(self.SendTextMsg, self))
end

-- 创建输入框
function ChatMsgInput:CreateInputEdit(x, y, w, h)
	self:CreateEditView()

	x = x or (self.width - 210) / 2
	y = y or y or self.height / 2
	w = w or self.width - 210
	h = h or 53

	self.edit_input = XUI.CreateEditBox(x, y, w, h, COMMON_CONSTS.FONT, 0, 3, ResPath.GetChat("img_key_bg"), true)
	self.edit_input:setFontSize(CHAT_FONT_SIZE)
	self.edit_input:setPlaceHolder(Language.Chat.PleaseInput)
	self.edit_view:addChild(self.edit_input)
	self.edit_input:registerScriptEditBoxHandler(BindTool.Bind2(ChatData.ExamineEditTextNum, self.edit_input, CHAT_EDIT_MAX))

	local face = XUI.CreateImageView(w - 20, h / 2, ResPath.GetChat("img_chat_face"))
	self.edit_input:addChild(face, 100)
	XUI.AddClickEventListener(face, function ()
		ChatCtrl.Instance:OpenFace()
	end, true)
end

-- 创建录音按钮
function ChatMsgInput:CreateRecordBtn(x, y, w, h)
	x = x or self.width / 2 - 105
	y = y or y or self.height / 2
	local record_w = w or 260
	self.record_btn_h = h or 40

	self.record_btn_view = XUI.CreateLayout(x, y, record_w, self.record_btn_h)
	self.record_btn_view:setVisible(false)
	self.view:addChild(self.record_btn_view)

	self.record_btn_view:setTouchEnabled(true)
	self.record_btn_view:setIsHittedScale(true)
	self.record_btn_view:setHittedScale(1.03)
	self.record_btn_view:addTouchEventListener(BindTool.Bind1(self.OnBtnTouch, self))

	self.img_record = XUI.CreateImageView(record_w / 2, self.record_btn_h / 2, ResPath.GetChat("img_sound_bg"), true)
	self.record_btn_view:addChild(self.img_record)
	-- self.img_text = XUI.CreateImageView(record_w / 2, self.record_btn_h / 2, ResPath.GetChat("img_text_1"), true)
	-- self.record_btn_view:addChild(self.img_text)

	self.text_record_cd = XUI.CreateText(300, self.record_btn_h / 2, 100, 26, nil, "", nil, 26)
	self.record_btn_view:addChild(self.text_record_cd)
end

-- 创建录音状态界面
function ChatMsgInput:CreateRecordState(x, y, w, h, has_bg)
	x = x or 0
	y = y or 150
	w = w or 260
	h = h or 208

	self.record_state_view = XUI.CreateLayout(x, y, w, h)
	if has_bg then
		self.record_state_view:setBackGroundColor(COLOR3B.BLACK)
		self.record_state_view:setBackGroundColorOpacity(128)
	end
	self.record_state_view:setVisible(false)
	self.record_state_view:setAnchorPoint(0, 0)
	self.view:addChild(self.record_state_view)

	local img_state_bg = XUI.CreateImageView(100, 100, ResPath.GetMainui("chat_record_bg"), true)
	self.record_state_view:addChild(img_state_bg)

	self.line_list = {}
	for i = 1, 4 do
		local item_y = i * 30 + 30
		local item_w = (i - 1) * 13 + 38
		local line = XUI.CreateImageViewScale9(200, item_y, item_w, 21, ResPath.GetMainui("chat_record_bg2"), true)
		self.record_state_view:addChild(line)
		table.insert(self.line_list, line)
	end

	local record_tips = XUI.CreateText(120, 0, item_w, 30, cc.TEXT_ALIGNMENT_CENTER, Language.Chat.RecordTips, nil, 26)
	self.record_state_view:addChild(record_tips)

	self.text_record_state = XUI.CreateText(200, 30, 100, 30, nil, "", nil, 26)
	self.record_state_view:addChild(self.text_record_state)
end

function ChatMsgInput:GetInputEdit()
	return self.edit_input
end

-- 设置当前频道
function ChatMsgInput:SetChannel(value)
	self.curr_send_channel = value
	self:ShowBtnCd()
	self:SetInputTextPlaceHolder()
end

function ChatMsgInput:SetInputTextPlaceHolder()
	if self.curr_send_channel == CHANNEL_TYPE.PRIVATE and self.private_role_name ~= "" then
		self.edit_input:setPlaceHolder(string.format(Language.Chat.InPutdefTxt2, self.private_role_name))
	else
		self.edit_input:setPlaceHolder(string.format(Language.Chat.InPutdefTxt, Language.Chat.Channel[self.curr_send_channel] or "", CHANNEL_LV[self.curr_send_channel] or 0))
	end
end

function ChatMsgInput:IsInputText()
	return self.input_mode_is_text
end

function ChatMsgInput:SetIsInputText(is_text)
	self.input_mode_is_text = is_text
	self.edit_view:setVisible(is_text)
	self.record_btn_view:setVisible(not is_text)
	self:CleanInput()
end

function ChatMsgInput:SetPrivateRoleName(private_role_name)
	self.private_role_name = private_role_name
	self:SetInputTextPlaceHolder()
end

function ChatMsgInput:ClearCdTimer()
	if nil ~= self.cd_timer then
		GlobalTimerQuest:CancelQuest(self.cd_timer)
		self.cd_timer = nil
	end
end

-- 聊天CD
function ChatMsgInput:GetCdTime()
	local end_time = ChatData.Instance:GetChannelCdEndTime(self.curr_send_channel) or Status.NowTime
	return math.floor(end_time - Status.NowTime)
end

function ChatMsgInput:SetCdTime()
    local ten_second = ChatData.Instance:GetChatLimitData("ten_second")
	if self.curr_send_channel == CHANNEL_TYPE.WORLD or self.curr_send_channel == CHANNEL_TYPE.CAMP or 
    (ten_second ~= nil and "1" == ten_second) then
		ChatData.Instance:SetChannelCdEndTime(self.curr_send_channel)
		self:ShowBtnCd()
	end
end

function ChatMsgInput:ShowBtnCd()
	if nil == self.text_record_cd and nil == self.record_btn_view and nil == self.btn_send then
		return
	end

	self:ClearCdTimer()
	local cd_time = self:GetCdTime()
	if nil ~= self.record_btn_view then
		self.record_btn_view:setTouchEnabled(cd_time <= 0)
	end

	self:UpdateBtnCd()
	if cd_time > 0 then
		self.cd_timer = GlobalTimerQuest:AddTimesTimer(BindTool.Bind1(self.UpdateBtnCd, self), 1, cd_time)
	end
end

function ChatMsgInput:UpdateBtnCd()
	local cd_time = self:GetCdTime()
	if cd_time <= 0 then
		if nil ~= self.record_btn_view then
			self.record_btn_view:setTouchEnabled(true)
		end
		if nil ~= self.text_record_cd then
			self.text_record_cd:setString("")
		end
		if nil ~= self.btn_send then
			self.btn_send:setTitleText(Language.Chat.Send)
		end
		self:ClearCdTimer()
	else
		if nil ~= self.text_record_cd then
			self.text_record_cd:setString(string.format("(%d)", cd_time))
		end
		if nil ~= self.btn_send then
			self.btn_send:setTitleText(Language.Chat.Wait .. "(" .. cd_time .. ")")
		end
	end
end

-- 打开录音面板
function ChatMsgInput:OpenStateView()
	if self.record_state_view:isVisible() then
		return 
	end
	self.record_state_view:setVisible(true)

	local state_index = 1
	local function state_update()
		for i, v in ipairs(self.line_list) do
			v:setVisible(i <= state_index)

			local residue_time = 8 - math.floor(Status.NowTime - self.record_start_time)
			self.text_record_state:setString(string.format("(%d)", residue_time))
			if residue_time <= 0 then
				self:Finish(true)
			end
		end

		state_index = state_index + 1
		if state_index > #self.line_list then state_index = 1 end
	end

	state_update()
	self:ClearRecordTimer()
	self.record_timer = GlobalTimerQuest:AddTimesTimer(state_update, 1, 100)
end

-- 关闭录音面板
function ChatMsgInput:CloseStateView()
	self.record_state_view:setVisible(false)
	self:ClearRecordTimer()
end

function ChatMsgInput:ClearRecordTimer()
	if nil ~= self.record_timer then
		GlobalTimerQuest:CancelQuest(self.record_timer)
		self.record_timer = nil
	end
end

-- 录音处理
function ChatMsgInput:OnBtnTouch(sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		self:Start()
	elseif event_type == XuiTouchEventType.Moved then
		local move_position = sender:convertToNodeSpace(touch:getLocation())
		if math.abs(move_position.y - self.record_btn_h / 2) > 100 then
			self:Finish(false)
		end
	else
		local end_position = sender:convertToNodeSpace(touch:getLocation())
		if math.abs(end_position.y - self.record_btn_h / 2) > 100 then
			self:Finish(false)
		else
			self:Finish(true)
		end
	end
end

-- 开始录音
function ChatMsgInput:Start()
	if ChatData.ExamineChannelRule(self.curr_send_channel) == false then 
		return 
	end

	if self:IsPrivate() and "" == self.private_role_name then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.CorrentObj)
		return
	end

	if self:GetCdTime() > 0 then
		return
	end

	if ChatMsgInput.record_state == RecordState.Free then
		if AudioManager.Instance:StartMediaRecord() then
			ChatMsgInput.record_state = RecordState.Recording
			self.record_start_time = Status.NowTime
			self:OpenStateView()
		else
			if cc.PLATFORM_OS_IPHONE == PLATFORM or cc.PLATFORM_OS_IPAD == PLATFORM then
				SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NotRecordPermissionIOS)
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.Chat.RecordFail)
			end
		end
	end
end

-- 完成录音
function ChatMsgInput:Finish(is_send)
	if ChatMsgInput.record_state == RecordState.Recording then
		self:CloseStateView()
		if is_send then
			ChatMsgInput.record_state = RecordState.Uploading
			self:OnSoundUpLoadingHandler()
		else
			ChatMsgInput.record_state = RecordState.Free
			AudioManager.Instance:StopMediaRecord()
		end
	end
end

-- 上传声音处理
function ChatMsgInput:OnSoundUpLoadingHandler()
	local path = AudioManager.Instance:StopMediaRecord()
	if "" == path then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.RecordFail)
		ChatMsgInput.record_state = RecordState.Free
		return
	end

	local duration = math.floor((Status.NowTime - self.record_start_time) * 10)
	if duration < 10 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.RecordToShort)
		ChatMsgInput.record_state = RecordState.Free
		return
	end

	local role_id = RoleData.Instance.role_vo.role_id
	local time = math.floor(TimeCtrl.Instance:GetServerTime())

	self.sound_name = string.format("sound_%s_%s_%s.amr", time, role_id, duration)
	self.sound_url = ChatRecordMgr.GetUrlSoundPath(self.sound_name)

	local callback = BindTool.Bind1(self.UploadCallback, self)
	if not HttpClient:Upload(self.sound_url, path, callback) then
		ChatMsgInput.record_state = RecordState.Free
	end
end

-- 上传回调
function ChatMsgInput:UploadCallback(url, path, size)
	ChatMsgInput.record_state = RecordState.Free
	if size > 0 then
		self:SendSoundMsg(self.sound_name)
		local sound_path = ChatRecordMgr.GetCacheSoundPath(self.sound_name)
		PlatformAdapter.MoveFile(path, sound_path)
	end
end

function ChatMsgInput:IsPrivate()
	return CHANNEL_TYPE.PRIVATE == self.curr_send_channel
end

-- 发送语音消息
function ChatMsgInput:SendSoundMsg(message)
	if self:IsPrivate() then
		ChatCtrl.Instance:SendPrivateChatMsg(self.private_role_id, self.private_role_name, message, CHAT_CONTENT_TYPE.AUDIO)
	else
		ChatCtrl.Instance:SendChannelChat(self.curr_send_channel, message, CHAT_CONTENT_TYPE.AUDIO)
	end

	self:SetCdTime()

	if nil ~= self.send_callback then
		self.send_callback()
	end
end

-- 发送文字消息
function ChatMsgInput:SendTextMsg()
	local text = self.edit_input:getText()
	local len = string.len(text)

	--判断是否是是gm命令
	if len >= 3 and string.sub(text, 1 , 3) == "/gm" then
		local blank_begin, blank_end = string.find(text, " ")
		local colon_begin, colon_end = string.find(text, ":")
		if blank_begin and blank_end and colon_begin and colon_end then
			local type = string.sub(text, blank_end + 1, colon_begin - 1)
			local command = string.sub(text, colon_end + 1, -1)
			SysMsgCtrl.SendGmCommand(type, command)
		end
		self:CleanInput()
		return
	elseif len >= 4 and string.sub(text, 1 , 4) == "/cmd" then
		local blank_begin, blank_end = string.find(text, " ")
		if blank_begin and blank_end then
			ClientCmdCtrl.Instance:Cmd(string.sub(text, blank_end + 1, len))
		end
		self:CleanInput()
		return
	end

	if self:IsPrivate() then
		if "" == self.private_role_name then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.CorrentObj)
			return
		end
	else
		local channel = ChatData.Instance:GetChannel(self.curr_send_channel)
		if nil == channel or channel.cd_end_time > Status.NowTime then
			return
		elseif self.curr_send_channel == CHANNEL_TYPE.SYSTEM then
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NoChatChannel)
			self:CleanInput()
			return
		end
	end

	if len <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		return
	end
	if len >= COMMON_CONSTS.MAX_CHAT_MSG_LEN then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.ContentToLong)
		return
	end

	if ChatData.ExamineEditText(text, 0) == false then return end

	-- 聊天内容检测
	local message = ChatData.Instance:FormattingMsg(text, CHAT_CONTENT_TYPE.TEXT)
	if "" == message then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.NilContent)
		return
	end

	if self:IsPrivate() then
		ChatCtrl.Instance:SendPrivateChatMsg(self.private_role_id, self.private_role_name, message, CHAT_CONTENT_TYPE.TEXT)
	else
		ChatCtrl.Instance:SendChannelChat(self.curr_send_channel, message, CHAT_CONTENT_TYPE.TEXT)
	end

	self:CleanInput()
	self:SetCdTime()

	if nil ~= self.send_callback then
		self.send_callback()
	end
end

function ChatMsgInput:CleanInput()
	if self.edit_input then
		self.edit_input:setText("")
	end
	ChatData.Instance:ClearInput()
end
