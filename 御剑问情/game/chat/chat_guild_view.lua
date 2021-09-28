ChatGuildView = ChatGuildView or BaseClass(BaseRender)

function ChatGuildView:__init()
	self.channel_type = CHANNEL_TYPE.GUILD

	self.toggle_chat = self:FindObj("ToggleChat")
	self.toggle_system = self:FindObj("ToggleSystem")
	self.toggle_question = self:FindObj("ToggleQuestion")

	self.show_new_tips = self:FindVariable("ShowNewTips")
	self.unread_num = self:FindVariable("UnreadNum")

	self.cell_list = {}
	self.chat_list = {}
	self.chat_list_view = self:FindObj("CharList")
	local scroller_delegate = self.chat_list_view.list_simple_delegate
	scroller_delegate.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ListenEvent("ClickTips", BindTool.Bind(self.ClickTips, self))
	self:ListenEvent("ClickChat", BindTool.Bind(self.ClickChat, self))
	self:ListenEvent("ClickSystem", BindTool.Bind(self.ClickSystem, self))
	self:ListenEvent("ClickQuestion", BindTool.Bind(self.ClickQuestion, self))

	self.chat_list_view.scroller.scrollerScrolled = function()
		local disable_height = self.chat_list_view.scroller.ScrollSize 				-- 列表不可见总长度
		if disable_height >= 0 then
			local normalized_position = self.chat_list_view.scroller.NormalizedScrollPosition
			if normalized_position < 1 then
				ChatData.Instance:SetNewLockState(true)
			else
				ChatData.Instance:SetNewLockState(false)
			end
		else
			ChatData.Instance:SetNewLockState(false)
		end
	end
end

function ChatGuildView:ClickTips()
	ChatData.Instance:SetNewLockState(false)
	self:RefreshTips()

	self.chat_list_view.scroller:ReloadData(1)
end

function ChatGuildView:SetChannelType(channel_type)
	self.channel_type = channel_type
end

function ChatGuildView:GetChannelType()
	return self.channel_type
end

function ChatGuildView:ClickChat()
	if self.channel_type == CHANNEL_TYPE.GUILD then
		return
	end
	self.channel_type = CHANNEL_TYPE.GUILD
	ChatData.Instance:ClearGuildUnreadMsg()
	ChatData.Instance:SetNewLockState(false)

	self:FlushChatView()
end

function ChatGuildView:ClickSystem()
	if self.channel_type == CHANNEL_TYPE.GUILD_SYSTEM then
		return
	end
	self.channel_type = CHANNEL_TYPE.GUILD_SYSTEM
	ChatData.Instance:SetNewLockState(false)

	self:FlushChatView()
end

function ChatGuildView:ClickQuestion()
	if self.channel_type == CHANNEL_TYPE.GUILD_QUESTION then
		return
	end
	self.channel_type = CHANNEL_TYPE.GUILD_QUESTION
	ChatData.Instance:SetNewLockState(false)

	self:FlushChatView()
end

function ChatGuildView:FlushHighLight()
	if self.channel_type == CHANNEL_TYPE.GUILD then
		self.toggle_chat.toggle.isOn = true
	elseif self.channel_type == CHANNEL_TYPE.GUILD_SYSTEM then
		self.toggle_system.toggle.isOn = true
	elseif self.channel_type == CHANNEL_TYPE.GUILD_QUESTION then
		self.toggle_question.toggle.isOn = true
	end
end

function ChatGuildView:FlushChatView(channel_type)
	self.channel_type = channel_type or self.channel_type

	if self.channel_type == CHANNEL_TYPE.GUILD then
		self.chat_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.GUILD).msg_list
		local lock_state = ChatData.Instance:GetNewLockState()
		if lock_state then
			self.chat_list_view.scroller:RefreshAndReloadActiveCellViews(true)
		else
			self.chat_list_view.scroller:ReloadData(1)
		end

	elseif self.channel_type == CHANNEL_TYPE.TEAM then
		self.chat_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.TEAM).msg_list
		local lock_state = ChatData.Instance:GetNewLockState()
		if lock_state then
			self.chat_list_view.scroller:RefreshAndReloadActiveCellViews(true)
		else
			self.chat_list_view.scroller:ReloadData(1)
		end

	elseif self.channel_type == CHANNEL_TYPE.GUILD_SYSTEM then
		self.chat_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.GUILD_SYSTEM).msg_list
		self.chat_list_view.scroller:ReloadData(1)

	elseif self.channel_type == CHANNEL_TYPE.GUILD_QUESTION then
		self.chat_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.GUILD_QUESTION).msg_list
		self.chat_list_view.scroller:ReloadData(1)

	elseif self.channel_type == CHANNEL_TYPE.PRIVATE then
		local privite_obj = ChatData.Instance:GetPrivateObjByRoleId(ChatData.Instance:GetCurrentId()) or {}
		self.chat_list = privite_obj.msg_list or {}
		self.chat_list_view.scroller:ReloadData(1)
	end
	self:FlushHighLight()
end

function ChatGuildView:GetPosIsBottom()
	local disable_height = self.chat_list_view.scroller.ScrollSize 				-- 画布不可见长度
	if self.chat_list_view.scroller.ScrollPosition >= disable_height then
		self.chat_list_view.scroller:ReloadData(1)
		return true
	else
		return false
	end
end

function ChatGuildView:__delete()
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function ChatGuildView:GoToChatButtom()
	self.chat_list_view.scroller:ReloadData(1)
end

function ChatGuildView:GetCellSizeDel(data_index)
	data_index = data_index + 1
	local guild_list = self.chat_list[data_index]
	local channel_type = 0
	local current_id = ChatData.Instance:GetCurrentId()
	if current_id == SPECIAL_CHAT_ID.GUILD then
		channel_type = CHANNEL_TYPE.GUILD
	elseif current_id == SPECIAL_CHAT_ID.TEAM then
		channel_type = CHANNEL_TYPE.TEAM
	else
		channel_type = CHANNEL_TYPE.PRIVATE
	end
	local height = ChatData.Instance:GetChannelItemHeight(channel_type, guild_list.msg_id)
	if height <= 0 then
		height = ChatCtrl.Instance:CaleChatHeight(channel_type, guild_list)
	end
	return height
end

function ChatGuildView:RefreshTips()
	local unread_msg = {}

	if self.channel_type == CHANNEL_TYPE.GUILD then
		unread_msg = ChatData.Instance:GetGuildUnreadMsg() or {}
	elseif self.channel_type == CHANNEL_TYPE.TEAM then
		unread_msg = ChatData.Instance:GetTeamUnreaList() or {}
	end

	local count = #unread_msg
	if count <= 0 then
		self.show_new_tips:SetValue(false)
	else
		self.show_new_tips:SetValue(true)
		self.unread_num:SetValue(count)
	end
end

function ChatGuildView:GetNumberOfCells()
	return #self.chat_list or 0
end

function ChatGuildView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local chat_cell = self.cell_list[cell]
	if chat_cell == nil then
		chat_cell = ChatCell.New(cell.gameObject)
		self.cell_list[cell] = chat_cell
	end

	chat_cell:SetIndex(data_index)

	local data = self.chat_list[data_index]
	if data.channel_type == CHANNEL_TYPE.GUILD then
		ChatData.Instance:RemoveGuildUnreadMsgByMsgId(data.msg_id)
	elseif data.channel_type == CHANNEL_TYPE.TEAM then
		ChatData.Instance:ClearTeamUnreadMsgByMsgId(data.msg_id)
	end
	self:RefreshTips()
	chat_cell:SetData(data)
end