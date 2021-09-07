ChatNoticeView = ChatNoticeView or BaseClass(BaseView)

function ChatNoticeView:__init()
	self.ui_config = {"uis/views/chatview","ChatNoticeView"}
	self.view_layer = UiLayer.Pop
	self.chat_type = QUICK_CHAT_TYPE.NORMAL
	self:SetMaskBg(true)
end

function ChatNoticeView:__delete()

end

function ChatNoticeView:LoadCallBack()
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.Close, self))
	self.cell_list = {}

	self.list_data = {}

	self.scroller = self:FindObj("Scroller")
	self.list_view_delegate = self.scroller.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = function() return #self.list_data end
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function ChatNoticeView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.list_view_delegate = nil
	self.scroller = nil
	self.call_back = nil
end

function ChatNoticeView:OpenCallBack()
	self.list_data = {}
	if self.chat_type == QUICK_CHAT_TYPE.NORMAL then
		self.list_data = Language.Chat.QuickChatList
	elseif self.chat_type == QUICK_CHAT_TYPE.GUILD then
		self.list_data = Language.Chat.QuickGuildChatList
	end

	self.scroller.scroller:ReloadData(0)
end

function ChatNoticeView:CloseCallBack()

end

function ChatNoticeView:SetQuickType(chat_type)
	self.chat_type = chat_type
end

function ChatNoticeView:SetCallBack(call_back)
	self.call_back = call_back
end

function ChatNoticeView:RefreshView(cell, data_index)
	local chat_cell = self.cell_list[cell]
	if chat_cell == nil then
		chat_cell = QuickChatCell.New(cell.gameObject)
		chat_cell:SetClickCallBack(BindTool.Bind(self.ClickCell, self))
		self.cell_list[cell] = chat_cell
	end
	local data = self.list_data[data_index + 1] or ""
	chat_cell:SetData(data)
end

function ChatNoticeView:ClickCell(cell)
	if self.chat_type == QUICK_CHAT_TYPE.NORMAL then
		if ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
			local str = cell.data or ""
			if self.call_back then
				self.call_back(str)
			end
			self:Close()
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Chat.WorldChatCD)
		end
	elseif self.chat_type == QUICK_CHAT_TYPE.GUILD then
		local str = cell.data or ""
		ChatCtrl.SendChannelChat(CHANNEL_TYPE.GUILD, str, CHAT_CONTENT_TYPE.TEXT)
		self:Close()
	end
end

--------------------------------------QuickChatCell------------------------------------------

QuickChatCell = QuickChatCell or BaseClass(BaseCell)

function QuickChatCell:__init()
	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))
	self.text = self:FindVariable("Text")
end

function QuickChatCell:__delete()

end

function QuickChatCell:OnFlush()
	self.text:SetValue(self.data or "")
end