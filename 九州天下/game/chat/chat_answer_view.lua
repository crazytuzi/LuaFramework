ChatAnswerView = ChatAnswerView or BaseClass(BaseRender)

function ChatAnswerView:__init()
	self.cell_list = {}
	self.answer_list = {}
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
		-- print(position, scroll_size, self.chat_list_view.scroller.ScrollRectSize)
	end
end

function ChatAnswerView:__delete()
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function ChatAnswerView:OnFlush()
	local chat_answer_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.WORLD) or {}

	local msg_list = chat_answer_list.msg_list or {}
	local data = {}
	for k,v in pairs(msg_list) do
		if v ~= nil and v.from_type == SHOW_CHAT_TYPE.ANSWER then
			table.insert(data, v)
		end
	end

	self.answer_list = data
	local is_lock = ChatData.Instance:GetIsLockState()
	if is_lock then
		self.chat_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	else
		self.chat_list_view.scroller:ReloadData(1)
	end
end

function ChatAnswerView:GetCellSizeDel(data_index)
	data_index = data_index + 1
	local answer_list = self.answer_list[data_index]

	local height = ChatData.Instance:GetChannelItemHeight(answer_list.channel_type, answer_list.msg_id)
	if height > 0 then
		return height
	end
	local scroller_delegate = self.chat_list_view.list_simple_delegate

	local chat_measuring = ChatCtrl.Instance:GetChatMeasuring(scroller_delegate)
	if chat_measuring ~= nil then
		chat_measuring:SetData(answer_list)
		height = chat_measuring:GetContentHeight()
		ChatData.Instance:SetChannelItemHeight(answer_list.channel_type, answer_list.msg_id, height)
	end

	return height or 0
end

function ChatAnswerView:GetNumberOfCells()
	return #self.answer_list or 0
end

function ChatAnswerView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local chat_cell = self.cell_list[cell]
	if chat_cell == nil then
		chat_cell = ChatCell.New(cell.gameObject)
		self.cell_list[cell] = chat_cell
	end

	chat_cell:SetIndex(data_index)
	chat_cell:SetData(self.answer_list[data_index])
end