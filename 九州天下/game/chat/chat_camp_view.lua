ChatCampView = ChatCampView or BaseClass(BaseRender)

function ChatCampView:__init()
	self.cell_list = {}
	self.camp_list = {}
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
end

function ChatCampView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.chat_list_view = nil
end

function ChatCampView:GetPosIsBottom()
	local disable_height = self.chat_list_view.scroller.ScrollSize 				-- 画布不可见长度
	if self.chat_list_view.scroller.ScrollPosition >= disable_height then
		self.chat_list_view.scroller:ReloadData(1)
		return true
	else
		return false
	end
end

function ChatCampView:FlushCampView()
	local chat_list = ChatData.Instance:GetChannel(CHANNEL_TYPE.CAMP) or {}
	self.camp_list = chat_list.msg_list or {}
	local is_lock = ChatData.Instance:GetIsLockState()
	if is_lock then
		self.chat_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	else
		self.chat_list_view.scroller:ReloadData(1)
	end
end

function ChatCampView:GoToChatButtom()
	self.chat_list_view.scroller:ReloadData(1)
end

function ChatCampView:GetCellSizeDel(data_index)
	data_index = data_index + 1
	local guild_list = self.camp_list[data_index]

	local height = ChatData.Instance:GetChannelItemHeight(CHANNEL_TYPE.CAMP, guild_list.msg_id)
	if height > 0 then
		return height
	end
	local scroller_delegate = self.chat_list_view.list_simple_delegate

	local chat_measuring = ChatCtrl.Instance:GetChatMeasuring(scroller_delegate) or ChatCtrl.Instance:GetGuildMeasuring(scroller_delegate)
	chat_measuring:SetData(guild_list)
	height = chat_measuring:GetContentHeight()
	ChatData.Instance:SetChannelItemHeight(CHANNEL_TYPE.CAMP, guild_list.msg_id, height)
	return height
end

function ChatCampView:GetNumberOfCells()
	return #self.camp_list or 0
end

function ChatCampView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local chat_cell = self.cell_list[cell]
	if chat_cell == nil then
		chat_cell = ChatCell.New(cell.gameObject)
		chat_cell.parent = self
		self.cell_list[cell] = chat_cell
	end

	chat_cell:SetIndex(data_index)
	chat_cell:SetData(self.camp_list[data_index])
end

function ChatCampView:PlayOrStopVoice(sound_name, index)
	if not sound_name then
		return
	end
	local path = ChatRecordMgr.GetCacheSoundPath(sound_name)
	if ChatRecordMgr.Instance:GetIsDownLoad(sound_name) then
		AudioPlayer.Play(path)
	else
		local function call_back()
			AudioPlayer.Play(path)
		end
		ChatRecordMgr.Instance:DownloadVoice(sound_name, call_back)
	end
end

function ChatCampView:OnFlush()
	self:FlushCampView()
end