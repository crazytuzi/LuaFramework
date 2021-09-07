ChatGuildView = ChatGuildView or BaseClass(BaseRender)

function ChatGuildView:__init()
	ChatGuildView.Instance = self
	self.cell_list = {}
	self.guild_list = {}
	self.chat_list_view = self:FindObj("CharList")
	local scroller_delegate = self.chat_list_view.list_simple_delegate
	scroller_delegate.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.chat_list_view.scroller.scrollerScrolled = function()
		local position = self.chat_list_view.scroller.ScrollPosition
		position = position < 0 and 0 or position
		position = math.floor(position)
		local scroll_size = self.chat_list_view.scroller.ScrollSize
		if scroll_size < 10 then
			return
		end
		if position >= scroll_size then
			ChatCtrl.Instance:ChangeLockState(false)
		else
			ChatCtrl.Instance:ChangeLockState(true)
		end
	end

	self:ListenEvent("ClickChat", BindTool.Bind(self.ChangeShowMsg, self, SHOW_CHAT_TYPE.CHAT))
	self:ListenEvent("ClickSys", BindTool.Bind(self.ChangeShowMsg, self, SHOW_CHAT_TYPE.SYS))
	self:ListenEvent("ClickAnswer", BindTool.Bind(self.ChangeShowMsg, self, SHOW_CHAT_TYPE.ANSWER))

	--self.btn_chat = self:FindObj("BtnChat")
	--self.btn_sys = self:FindObj("BtnSys")

	self.show_chat_type = SHOW_CHAT_TYPE.CHAT
	self.chat_select = self:FindVariable("ChatSelect")
	self.sys_select = self:FindVariable("SysSelect")
	self.answer_select = self:FindVariable("AnswerSelect")
end

function ChatGuildView:ChangeShowMsg(chat_type)
	self.show_chat_type = chat_type
	self:FlushGuildView()
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

	ChatGuildView.Instance = nil

	self.chat_select = nil
	self.sys_select = nil
	self.answer_select = nil
end

function ChatGuildView:FlushGuildView(is_privite)
	local chat_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.GUILD) or {}
	if is_privite then
		local privite_id = ChatData.Instance:GetCurrentRoleId()
		local private_obj = ChatData.Instance:GetPrivateObjByRoleId(privite_id)
		if nil == private_obj then
			chat_list = {}
		else
			chat_list = private_obj
		end
	end

	local check_list = {}
	if chat_list.msg_list then
		for k,v in pairs(chat_list.msg_list) do
			if self.show_chat_type == v.from_type then
				table.insert(check_list, v)
			end
		end
	end


	if self.chat_select ~= nil then
		self.chat_select:SetValue(self.show_chat_type == SHOW_CHAT_TYPE.CHAT)
	end

	if self.sys_select ~= nil then
		self.sys_select:SetValue(self.show_chat_type == SHOW_CHAT_TYPE.SYS)
	end

	if self.answer_select ~= nil then
		self.answer_select:SetValue(self.show_chat_type == SHOW_CHAT_TYPE.ANSWER)
	end

	self.guild_list = check_list
	self.chat_list_view.scroller:ReloadData(1)
end

function ChatGuildView:FlushGuildTeamView()
 	self.guild_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.TEAM).msg_list
	self.chat_list_view.scroller:ReloadData(1)
	-- self.show_new_tips:SetValue(false)
end

function ChatGuildView:FlushGuildCampView()
 	self.guild_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.CAMP).msg_list
	self.chat_list_view.scroller:ReloadData(1)
	-- self.show_new_tips:SetValue(false)
end

function ChatGuildView:GoToChatButtom()
	self.chat_list_view.scroller:ReloadData(1)
end

function ChatGuildView:GetCellSizeDel(data_index)
	data_index = data_index + 1
	local guild_list = self.guild_list[data_index]

	local height = ChatData.Instance:GetChannelItemHeight(CHANNEL_TYPE.GUILD, guild_list.msg_id)
	if height > 0 then
		return height
	end
	local scroller_delegate = self.chat_list_view.list_simple_delegate

	local chat_measuring = ChatCtrl.Instance:GetChatMeasuring(scroller_delegate) or ChatCtrl.Instance:GetGuildMeasuring(scroller_delegate)
	-- chat_measuring:SetEasy(true)
	if chat_measuring ~= nil then
		chat_measuring:SetData(guild_list)
		height = chat_measuring:GetContentHeight()
		ChatData.Instance:SetChannelItemHeight(CHANNEL_TYPE.GUILD, guild_list.msg_id, height)
	end

	return height
end

function ChatGuildView:GetNumberOfCells()
	return #self.guild_list or 0
end

function ChatGuildView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local chat_cell = self.cell_list[cell]
	if chat_cell == nil then
		chat_cell = ChatCell.New(cell.gameObject)
		self.cell_list[cell] = chat_cell
	end
	chat_cell:SetIndex(data_index)
	chat_cell:SetData(self.guild_list[data_index])
end