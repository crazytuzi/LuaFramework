ChatRecordView = ChatRecordView or BaseClass()

ChatRecord_OffY = 150

function ChatRecordView:__init(record_btn, send_callback, x, y)
	self.record_btn = record_btn 									-- 关联的按钮
	self.send_callback = send_callback								-- 发送回调

	self.view = XUI.CreateLayout(0, 0, 286, 208)
	self.view:setPosition(x, y)

	self.bg = XUI.CreateImageView(0, 0, ResPath.GetMainui("chat_record_bg"), true)
	self.view:addChild(self.bg)
	self.line_list = {}

	for i = 1, 4 do
		local y = i * 30 - 80
		local w = (i-1) * 13 + 38
		local line = XUI.CreateImageViewScale9(100, y, w, 21, ResPath.GetMainui("chat_record_bg2"), true)
		self.view:addChild(line)
		table.insert(self.line_list, line)
	end

	self.out_time_text = XUI.CreateText(57, -80, 100, 30, nil, "", nil, 26, COLOR3B.RED)
	self.view:addChild(self.out_time_text)

	self.cd_time_text = XUI.CreateText(380, 28, 100, 30, nil, "", nil, 30)
	self.record_btn:addChild(self.cd_time_text, 999)

	self.view:setVisible(false)

	self.timer = nil
	self.eff_index = 1

	self.finish_time = 8
	self.start_time = 0

	self.record_state = 2							-- 0 开始录音 1 结束录音上传 2 上传完成

	self.curr_send_channel = -1 					-- 频道
	self.sound_name = ""

	self.record_btn:addTouchEventListener(BindTool.Bind1(self.OnBtnTouch, self))
end

function ChatRecordView:__delete()
	self:ClearCdTimer()
end

function ChatRecordView:GetView()
	return self.view
end

-- 设置当前频道
function ChatRecordView:SetChannel(value)
	self.curr_send_channel = value
	self:ShowBtnCd()
end

-- 录音面板
function ChatRecordView:OpenView()
	if self.view:isVisible() then
		return 
	end
	self.view:setVisible(true)
	self:ClearCdTimer()
	self:Update()
	self.timer = GlobalTimerQuest:AddTimesTimer(BindTool.Bind1(self.Update, self), 1, 100)
end

function ChatRecordView:CloseView()
	self.view:setVisible(false)
	self:ClearCdTimer()
end

-- 播动画倒计时
function ChatRecordView:Update()
	for i,v in ipairs(self.line_list) do
		v:setVisible(i <= self.eff_index)
	end
	local n = self.eff_index + 1
	self.eff_index = n > #self.line_list and 1 or n

	local t = math.floor(Status.NowTime - self.start_time)
	self.out_time_text:setString(string.format("(%d)", self.finish_time - t))
	if t >= self.finish_time then
		self:Finish(true)
	end
end

function ChatRecordView:ClearCdTimer()
	if nil ~= self.cd_timer then
		GlobalTimerQuest:CancelQuest(self.cd_timer)
		self.cd_timer = nil
	end
end

-- 聊天CD
function ChatRecordView:GetCdTime()
	local i = ChatData.Instance:GetChannelCdEndTime(self.curr_send_channel) or Status.NowTime
	return math.floor(i - Status.NowTime)
end

function ChatRecordView:SetCdTime()
	if self.curr_send_channel == CHANNEL_TYPE.WORLD or self.curr_send_channel == CHANNEL_TYPE.CAMP then
		ChatData.Instance:SetChannelCdEndTime(self.curr_send_channel)
		ChatCtrl.Instance.view:StartChannelCd()
		self:ShowBtnCd()
	end	
end

function ChatRecordView:ShowBtnCd()
	self:ClearCdTimer()
	local cd_time = self:GetCdTime()
	self.record_btn:setTouchEnabled(cd_time <= 0)
	self:UpdateBtnCd()
	self.cd_timer = GlobalTimerQuest:AddTimesTimer(BindTool.Bind1(self.UpdateBtnCd, self), 1, cd_time)
end

function ChatRecordView:UpdateBtnCd()
	local cd_time = self:GetCdTime()
	self.cd_time_text:setString(string.format("(%d)", cd_time))

	if cd_time <= 0 then
		XUI.SetButtonEnabled(self.record_btn, true)
		self.cd_time_text:setString("")

		self:ClearCdTimer()
	end
end

-- 录音处理
function ChatRecordView:OnBtnTouch(sender, event_type, touch)
	local rec_btn_h = self.record_btn:getContentSize().height or 0
	if event_type == XuiTouchEventType.Began then
		self:Start()
	elseif event_type == XuiTouchEventType.Moved then
		local move_position = sender:convertToNodeSpace( touch:getLocation())
		if math.abs(move_position.y - rec_btn_h / 2) > ChatRecord_OffY then
			self:Finish(false)
		end
	else
		local end_position = sender:convertToNodeSpace( touch:getLocation())
		if math.abs(end_position.y - rec_btn_h / 2) > ChatRecord_OffY then
			self:Finish(false)
		else
			self:Finish(true)
		end
	end
end

-- 开始录音
function ChatRecordView:Start()
	if ChatData.ExamineChannelRule(self.curr_send_channel) == false then 
		return 
	end

	if self.record_state == 2 then
		if AudioManager.Instance:StartMediaRecord() then
			self.record_state = 0
			self.start_time = Status.NowTime
			self:OpenView()
			print("开始录音--------", self.record_state)
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
function ChatRecordView:Finish(is_send)
	if self.record_state == 0 then
		self:CloseView()
		if is_send then
			self.record_state = 1
			self:OnSoundUpLoadingHandler()
		else
			self.record_state = 2
			AudioManager.Instance:StopMediaRecord()
		end
		print("结束录音--------", self.record_state)
	end
end

-- 上传声音处理
function ChatRecordView:OnSoundUpLoadingHandler()
	local path = AudioManager.Instance:StopMediaRecord()
	if "" == path then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.RecordFail)
		self.record_state = 2
		return
	end

	local duration = math.floor((Status.NowTime - self.start_time) * 10)
	if duration < 10 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.RecordToShort)
		self.record_state = 2
		return
	end

	local role_id = RoleData.Instance.role_vo.role_id
	local time = math.floor(TimeCtrl.Instance:GetServerTime())

	self.sound_name = string.format("sound_%s_%s_%s.amr", time, role_id, duration)
	self.sound_url = ChatRecordMgr.GetUrlSoundPath(self.sound_name)

	print("上传录音--------:", self.sound_name)
	
	local callback = BindTool.Bind1(self.UploadCallback, self)
	if not HttpClient:Upload(self.sound_url, path, callback) then
		self.record_state = 2
	end
end

-- 上传回调
function ChatRecordView:UploadCallback(url, path, size)
	print("上传回调--------:", url, path, size)
	self.record_state = 2
	if size > 0 then
		self:SendMsg(self.sound_name)
		local sound_path = ChatRecordMgr.GetCacheSoundPath(self.sound_name)
		PlatformAdapter.MoveFile(path, sound_path)
	end
end

-- 向服务端发消息
function ChatRecordView:SendMsg(msg)
	if self.send_callback then
		print("向服务端发消息--------")
		self.send_callback(msg)
		self:SetCdTime()
	end
end
