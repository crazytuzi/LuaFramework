require("scripts/game/chat/chat_transmit")
require("scripts/game/chat/chat_msg_item_record")
require("scripts/game/chat/chat_com")
require("scripts/game/chat/chat_face")
require("scripts/game/chat/chat_setting")
require("scripts/game/chat/chat_item")
require("scripts/game/chat/chat_list_view")

ChatView = ChatView or BaseClass(BaseView)

CHAT_FONT_SIZE = 20

ChatViewIndex = {
	All = 1,
	Near = 2,
	World = 3,
	Guild = 4,
	Team = 5,
	Private = 6,
}

function ChatView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.def_index = 1
	self.last_view = 1
	-- self.title_img_path = ResPath.GetWord("word_chat")	
	self.texture_path_list[1] = "res/xui/chat.png"
	self.texture_path_list[2] = "res/xui/face.png"
	self.config_tab = {
		-- {"common_ui_cfg", 1, {0}},
		{"chat_ui_cfg", 1, {0}},
		{"chat_ui_cfg", 2, {0}},
		-- {"common_ui_cfg", 2, {0}},
	}
	self.transmit_pop_view = ChatTransmitPopView.New()
	self.is_any_click_close = true
	self.tabbar = nil
	self.tab_index = 1
	-- self.curr_channel = CHANNEL_TYPE.ALL			-- 当前频道
	
	self.input_view = nil
	
	self.top_icon_view = nil
	self.icon_right_list = {}
	
	self.is_suoping = false
	self.last_msg_len = 0
	self.record_btn_h = 40

end

function ChatView:__delete()
	self.transmit_pop_view:DeleteMe()
	self.transmit_pop_view = nil
end

function ChatView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		-- self:CreateTopTitle()
		self.root_node:setPosition(0,-6)
		self.root_node:setAnchorPoint(0,0)
		-- 语音
		self:CreateRecordState(0, 150, 260, 209)
		
		self:InitTableBar()
		self:InitCom()
		self:InitBottomIcon()
		-- self:InitTopIcon()
		local ph = self.ph_list.ph_chat_input
		self.input_view = ChatMsgInput.New(ph.x, ph.y, ph.w - 35, ph.h, BindTool.Bind1(self.SendMsgCallback, self))
		self.input_view:CreateSendBtn()
		self.input_view:CreateInputEdit(ph.x +100, ph.y + 30, ph.w / 2 + 30, ph.h/2+10)
		-- self.input_view:CreateRecordBtn(ph.x - 50, ph.y +40, ph.w / 2, ph.h)
		self.input_view:CreateRecordState()
		self.node_t_list.layout_chat.node:addChild(self.input_view:GetView(), 100)
		self:RefreshSpeakerChannel()

		self.node_t_list.btn_speak.node:addTouchEventListener(BindTool.Bind(self.OnTouchSpeaking, self))
	end
end

-- 创建录音状态界面
function ChatView:CreateRecordState(x, y, w, h, has_bg)
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
	self.node_t_list.layout_chat.node:addChild(self.record_state_view)

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

-- 录音处理
function ChatView:OnTouchSpeaking(sender, event_type, touch)
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

function ChatView:IsPrivate()
	return CHANNEL_TYPE.PRIVATE == self.curr_send_channel
end

-- 聊天CD
function ChatView:GetCdTime()
	local end_time = ChatData.Instance:GetChannelCdEndTime(self.curr_send_channel) or Status.NowTime
	return math.floor(end_time - Status.NowTime)
end

-- 关闭录音面板
function ChatView:CloseStateView()
	self.record_state_view:setVisible(false)
	self:ClearRecordTimer()
end

function ChatView:ClearRecordTimer()
	if nil ~= self.record_timer then
		GlobalTimerQuest:CancelQuest(self.record_timer)
		self.record_timer = nil
	end
end

-- 开始录音
function ChatView:Start()
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

-- 打开录音面板
function ChatView:OpenStateView()
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

-- 完成录音
function ChatView:Finish(is_send)
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
function ChatView:OnSoundUpLoadingHandler()
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

function ChatView:InitTableBar()
	if nil == self.tabbar then
		self.tabbar = Tabbar.New()
		-- self.tabbar:SetTabbtnTxtOffset(- 10, 0)
		self.tabbar:CreateWithNameList(self.root_node, 12, 760,
		function(index) self:ChangeToIndex(index) end,
		Language.Chat.TabGroup, true, ResPath.GetCommon("toggle_121"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
		self.tabbar:SetSpaceInterval(5)
	end
	
	
	
	if not ChatData.Instance:IsCanChat() then
		self.tabbar:SetToggleVisible(2, false)
		self.tabbar:SetToggleVisible(3, false)
		self.tabbar:SetToggleVisible(4, false)
		self.tabbar:SetToggleVisible(5, false)
		self.tabbar:SetToggleVisible(6, false)
	end
end

-- function ChatView:Open(index)
-- 	index = self.last_view or index
-- 	XuiBaseView.Open(self, index)
-- end
function ChatView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:InitTableBar()
	if not self:IsLoading() then
		self:RefreshChannel()
	end
end

function ChatView:ShowIndexCallBack(index)
	self.transmit_pop_view:Close()
	self.tabbar:SetRemindByIndex(index, false)
	GlobalEventSystem:Fire(MainUIEventType.CHAT_REMIND_CHANGE, index, false)
	
	self.tab_index = index
	self.tabbar:ChangeToIndex(index)
	if ChatViewIndex.All == index then
		self.curr_channel = CHANNEL_TYPE.ALL
		self.input_channel = CHANNEL_TYPE.NEAR
	elseif ChatViewIndex.Near == index then
		self.curr_channel = CHANNEL_TYPE.NEAR
		self.input_channel = CHANNEL_TYPE.NEAR
	elseif ChatViewIndex.World == index then
		self.curr_channel = CHANNEL_TYPE.WORLD
		self.input_channel = CHANNEL_TYPE.WORLD
	elseif ChatViewIndex.Guild == index then
		self.curr_channel = CHANNEL_TYPE.GUILD
		self.input_channel = CHANNEL_TYPE.GUILD
	elseif ChatViewIndex.Team == index then
		self.curr_channel = CHANNEL_TYPE.TEAM
		self.input_channel = CHANNEL_TYPE.TEAM
	elseif ChatViewIndex.Private == index then
		self.curr_channel = CHANNEL_TYPE.PRIVATE
		self.input_channel = CHANNEL_TYPE.PRIVATE
	end
	self.input_view:SetChannel(self.input_channel)
	self:ChangeChanelBtnNum()
	self.input_view:SetPrivateRoleName(ChatData.Instance.private_select_name)
	self:RefreshChannel()
	-- self.node_t_list.btn_cur_channel.node:setTitleText(Language.Chat.Channel[self.input_channel])
	if nil ~= self.list_view_list then
		for k, v in pairs(self.list_view_list) do
			v:GetView():setVisible(index == k)
		end
	end
	
	-- self.top_icon_view:setVisible(self.curr_channel ~= CHANNEL_TYPE.PRIVATE)
	-- self:SetComTitleVisible(self.curr_channel ~= CHANNEL_TYPE.PRIVATE)
	-- self:RefreshSuoping()
end

function ChatView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChatView:ReleaseCallBack()
	if nil ~= self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	
	if nil ~= self.input_view then
		self.input_view:DeleteMe()
		self.input_view = nil
	end
	
	if self.chat_role_list then
		self.chat_role_list:DeleteMe()
		self.chat_role_list = nil
	end
	
	self.top_icon_view = nil
	self.icon_right_list = {}
	
	self:ComReleaseCallBack()
	self.horn_remind = nil
end

function ChatView:OnFlush(param_list, index)
	for k, v in pairs(param_list) do
		if k == "all" then
			self:RefreshChannel()
		elseif k == "add_chat" then
			for k1, v1 in pairs(v) do
				if self.curr_channel ~= k1 then
					if k1 == CHANNEL_TYPE.PRIVATE then
						self.tabbar:SetRemindByIndex(ChatViewIndex.Private, true)
						GlobalEventSystem:Fire(MainUIEventType.CHAT_REMIND_CHANGE, ChatViewIndex.Private, true)
					elseif k1 == CHANNEL_TYPE.TEAM then
						self.tabbar:SetRemindByIndex(ChatViewIndex.Team, true)
						GlobalEventSystem:Fire(MainUIEventType.CHAT_REMIND_CHANGE, ChatViewIndex.Team, true)
					end
				end
			end
			self:RefreshChannel()
		elseif k == "speaker" then
			self:RefreshSpeakerChannel()
		elseif k == "add_private" then
			self.add_private_name = v.name
			self:FlushChatRoleList(CHANNEL_TYPE.PRIVATE, v.name)
		elseif k == "input_channel" then
			self.input_channel = v.input_channel
			self.input_view:SetChannel(self.input_channel)
			self:ChangeChanelBtnNum()
			-- self.node_t_list.btn_cur_channel.node:setTitleText(Language.Chat.Channel[self.input_channel])
		elseif k == "horn_count" then
			self:ChangeChanelBtnNum()
        elseif k == "select_role" then
			self.input_view:SetPrivateRoleName(v.name)
		end
	end
	self.tabbar:SelectIndex(self.tab_index)
end

------------------------------------------------------------------------------
function ChatView:ChatViewShowIndex()
	local show_index = 1
	if ViewManager.Instance:IsOpen(ViewDef.Chat.Synthesize) then
		show_index = 1
	elseif ViewManager.Instance:IsOpen(ViewDef.Chat.Nearby) then
		show_index = 2
	elseif ViewManager.Instance:IsOpen(ViewDef.Chat.World) then
		show_index = 3
	elseif ViewManager.Instance:IsOpen(ViewDef.Chat.Guild) then
		show_index = 4
	elseif ViewManager.Instance:IsOpen(ViewDef.Chat.Troops) then
		show_index = 5
	elseif ViewManager.Instance:IsOpen(ViewDef.Chat.PrivateChat) then
		show_index = 6
	end
	return show_index
end

function ChatView:ReleaseHelper()
	self.view_manager:AddReleaseObj(self)
end

function ChatView:Close(...)
	if not ViewManager.Instance:IsOpen(ViewDef.Chat) then
		ChatView.super.Close(self, ...)
	end
end

function ChatView:Open(index)
	self.tab_index = self:ChatViewShowIndex()
	ChatView.super.Open(self, self.tab_index)
end
------------------------------------------------------------------------------

function ChatView:SendMsgCallback()
	
end

-- 当前频道
function ChatView:GetChannel()
	return self.curr_channel
end

function ChatView:GetInputEdit()
	if nil ~= self.input_view then
		return self.input_view:GetInputEdit()
	end
	return nil
end

function ChatView:IsTransmitOpen()
	return self.transmit_pop_view:IsTransmitOpen()
end

function ChatView:GetTransmitInputEdit()
	return self.transmit_pop_view:GetEditText()
end

--获取大喇叭按钮
function ChatView:GetLayoutBigHornBtn()
	if nil == self.icon_right_list[2] then
		return nil
	end
	return self.icon_right_list[2]:GetView()
end

-- 刷新频道
function ChatView:RefreshChannel()
	if not self:IsOpen() or nil == self.list_view_list then
		return
	end
	local channel = ChatData.Instance:GetChannel(self.curr_channel)
	
	if nil == channel then
		return
	end
	local is_change = false
	
	if self.last_view ~= self.tab_index then
		self.last_view = self.tab_index
		is_change = false
		self.last_msg_len = 0
	else
		if self.last_msg_len < #channel.msg_list and self.is_suoping == true then
			self.last_msg_len = #channel.msg_list
			is_change = true
		else
			is_change = false
		end
	end
	ChatView.UpdateContentListView(self.list_view_list[self.tab_index], channel.msg_list, channel.unread_num, is_change)
	channel.unread_num = 0
	self:FlushChatRoleList(self.curr_channel)
end

-- 刷新频道
function ChatView:RefreshSpeakerChannel()
	if not self:IsOpen() or nil == self.transmit_list then
		return
	end
	local channel = ChatData.Instance:GetChannel(CHANNEL_TYPE.SPEAKER)
	if nil == channel then
		return
	end
	
	ChatView.UpdateContentListView(self.transmit_list, channel.msg_list, channel.unread_num, false)
	channel.unread_num = 0
end
function ChatView:FlushChatRoleList(channel, name)
	self.chat_role_list:SetDataList({}) 					--ChatData.Instance:GetChatRoleList(channel)
	for k, v in pairs(ChatData.Instance:GetChatRoleList(channel)) do
		if v.name == name then
			self.chat_role_list:SelectIndex(k)
			return
		end
	end
end

--获取人物当前坐标
function ChatView:GetMainRolePos()
	local main_role = Scene.Instance.main_role
	
	if nil ~= main_role then
		local x, y = main_role:GetLogicPos()
		local pos_msg = string.format(Language.Chat.PosFormat, Scene.Instance:GetSceneName(), x, y)
		local edit_text = self.input_view:GetInputEdit()
		if ChatData.ExamineEditText(edit_text:getText(), 1) then
			edit_text:setText(edit_text:getText() .. pos_msg)
			local scene_id = Scene.Instance:GetSceneId()
			ChatData.Instance:InsertPointTab(Scene.Instance:GetSceneName(), x, y, scene_id)
		end
	end
end

function ChatView:InitBottomIcon()
	self.node_t_list.btn_chat_bag.node:addClickEventListener(BindTool.Bind(self.OnBottomIconClick, self, 3))
	self.node_t_list.btn_pos.node:addClickEventListener(BindTool.Bind(self.OnBottomIconClick, self, 4))
	self.node_t_list.btn_input.node:addClickEventListener(BindTool.Bind(self.OnBottomIconClick, self, 5))
	self.node_t_list.btn_chat_back.node:addClickEventListener(BindTool.Bind(self.CloseChat, self))
end

function ChatView:CloseChat()
	ViewManager.Instance:CloseViewByDef(ViewDef.Chat)
end

function ChatView:OpenChangeChannel()
	ChannelSelectView.Instance:OpenSelectChannel(BindTool.Bind(self.ChangeChannelCallBack, self))
end


function ChatView:ChangeChannelCallBack(channel)
	self.input_channel = channel
	self:Flush(0, "input_channel", {input_channel = channel})
end

function ChatView:OnBottomIconClick(index)
	if 1 == index then
		ChatCtrl.Instance:OpenFace()
	elseif 3 == index then
		ChatCtrl.Instance:OpenItem()
	elseif 4 == index then
		self:GetMainRolePos()
	elseif 5 == index then
		-- local is_text = self.input_view:IsInputText()
		-- local path = is_text and ResPath.GetChat("img_input0") or ResPath.GetChat("img_input1")
		-- self.node_t_list.btn_input.node:loadTextures(path)
		-- self.input_view:SetIsInputText(not is_text)
	end
end

function ChatView:InitTopIcon()
	self.top_icon_view = XUI.CreateLayout(130, 505, 900, 100)
	self.top_icon_view:setAnchorPoint(0, 0)
	self.root_node:addChild(self.top_icon_view, 100)
	
	local icon_right_cfg_list = {
		{icon_path = ResPath.GetMainui("horn_1"), word_path = ResPath.GetChat("word_smallhorn")},
		{icon_path = ResPath.GetChat("img_chat_setting"), word_path = ResPath.GetChat("word_chatsetting")},		
		--{icon_path = ResPath.GetMainui("horn_2"), word_path = ResPath.GetChat("word_bighorn")},
		{icon_path = ResPath.GetChat("img_blacklist"), word_path = ResPath.GetChat("word_blacklist")},
	-- {icon_path = ResPath.GetChat("img_chat_kaiping"), word_path = ResPath.GetChat("word_suoping")},
	}
	
	self.icon_right_list = {}
	for i, v in ipairs(icon_right_cfg_list) do
		local icon = ChatViewIcon.New()
		icon:SetPosition(i * 100 + 500, 50)
		icon:SetData(v)
		if i ~= 1 then
			icon:SetImgBg(ResPath.GetCommon("bg_120"))
		end
		icon:AddClickEventListener(BindTool.Bind2(self.OnRightIconClick, self, i), true)
		self.top_icon_view:addChild(icon:GetView())
		table.insert(self.icon_right_list, icon)
	end
	self.icon_right_list[1]:SetPosition(0, 50)
end

function ChatView:OnRightIconClick(index)
	if 1 == index then
		self.transmit_pop_view:OpenTransmitPop(1)
	elseif 3 == index then
		ChatCtrl.Instance:OpenBlacklistView()
	elseif 4 == index then
		self.is_suoping = not self.is_suoping
		-- self:RefreshSuoping()
	end
end

-- 刷新聊天列表
function ChatView.UpdateContentListView(list_view, msg_list, unread_num, is_change)
	if nil == list_view or nil == msg_list then
		return
	end
	
	is_change = is_change or false
	
	local msg_count = #msg_list
	if unread_num > 0 and unread_num < msg_count then
		list_view:MoveFrontToLast(unread_num -(msg_count - list_view:GetCount()))
	end
	
	
	list_view:SetIsSuoping(is_change)
	list_view:SetDataList(msg_list)
	
	if is_change and nil ~= list_view:GetItemAt(2) then
		-- local item_height = list_view:GetItemAt(1):GetView():getPositionY() - list_view:GetItemAt(2):GetView():getPositionY()
		local last_item = list_view:GetItemAt(list_view:GetCount())
		local item_height = last_item:GetView():getContentSize().height
		local item_interval = list_view:GetView():getItemsInterval()
		connent = list_view:GetView():getInnerContainer()
		connent:setPositionY(connent:getPositionY() - item_height - item_interval)
	end
end

function ChatView:ChangeChanelBtnNum()
	local count = ChatData.Instance:GetSurplusHorn()
	local vis = self.input_channel == CHANNEL_TYPE.SPEAKER and count > 0
	if vis and nil == self.horn_remind then
		self.horn_remind = XUI.CreateImageView(100, 45, ResPath.GetCommon("remind_bg_1"))
		-- self.node_t_list.btn_cur_channel.node:addChild(self.horn_remind)
		self.horn_remind_txt = XUI.CreateText(11, 10, 30, 30, cc.TEXT_ALIGNMENT_CENTER, "", nil, 20, COLOR3B.WHITE)
		self.horn_remind:addChild(self.horn_remind_txt)
	end
	if vis then
		self.horn_remind:setVisible(true)
		self.horn_remind_txt:setString(count)
	elseif self.horn_remind then
		self.horn_remind:setVisible(false)
	end
end


ChatViewIcon = ChatViewIcon or BaseClass(BaseRender)
function ChatViewIcon:__init()
	self.img_icon = nil
	self.img_word = nil
	self:SetIsUseStepCalc(false)
end

function ChatViewIcon:__delete()
	
end

function ChatViewIcon:CreateChild()
	BaseRender.CreateChild(self)
	self.view:setContentWH(80, 80)
	self.view:setAnchorPoint(0.5, 0.5)
	
	self.img_bg = XUI.CreateImageView(40, 40, ResPath.GetCommon("bg_106"), true)
	self.view:addChild(self.img_bg)
	
	self.img_icon = XUI.CreateImageView(40, 40, self.data.icon_path, true)
	self.view:addChild(self.img_icon)
	
	self.img_word = XUI.CreateImageView(40, 15, self.data.word_path, true)
	self.view:addChild(self.img_word)
end

function ChatViewIcon:SetIcon(path)
	self.img_icon:loadTexture(path)
end

function ChatViewIcon:SetImgBg(path)
	self.img_bg:loadTexture(path)
end

function ChatViewIcon:SetWord(path)
	self.img_word:loadTexture(path)
end

function ChatViewIcon:SetImgWordPos(pos_x, pos_y)
	self.img_word:setPosition(pos_x, pos_y)
end

function ChatViewIcon:SetImgIconPos(pos_x, pos_y)
	self.img_icon:setPosition(pos_x, pos_y)
end

function ChatViewIcon:SetImgBgIsVisible(flag)
	self.img_bg:setVisible(flag)
end 