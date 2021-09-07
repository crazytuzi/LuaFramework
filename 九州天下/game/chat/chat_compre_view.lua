ChatCompreView = ChatCompreView or BaseClass(BaseRender)

function ChatCompreView:__init()
	self.cell_list = {}
	self.compre_list = {}
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

function ChatCompreView:__delete()
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function ChatCompreView:FlushCompreView()
	local chat_compre_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.ALL) or {}

	local msg_list = chat_compre_list.msg_list or {}
	self.compre_list = msg_list
	local is_lock = ChatData.Instance:GetIsLockState()
	if is_lock then
		self.chat_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	else
		self.chat_list_view.scroller:ReloadData(1)
	end
end

function ChatCompreView:GetCellSizeDel(data_index)
	data_index = data_index + 1
	local compre_list = self.compre_list[data_index]

	local height = ChatData.Instance:GetChannelItemHeight(compre_list.channel_type, compre_list.msg_id)
	if height > 0 then
		return height
	end
	local scroller_delegate = self.chat_list_view.list_simple_delegate

	local chat_measuring = ChatCtrl.Instance:GetChatMeasuring(scroller_delegate)
	chat_measuring:SetData(compre_list)
	height = chat_measuring:GetContentHeight()
	ChatData.Instance:SetChannelItemHeight(compre_list.channel_type, compre_list.msg_id, height)
	return height
end

function ChatCompreView:GetNumberOfCells()
	return #self.compre_list or 0
end

function ChatCompreView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local chat_cell = self.cell_list[cell]
	if chat_cell == nil then
		chat_cell = ChatCell.New(cell.gameObject)
		self.cell_list[cell] = chat_cell
	end

	chat_cell:SetIndex(data_index)
	chat_cell:SetData(self.compre_list[data_index])
end