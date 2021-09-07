require("game/chat/chat_friend_view")
ChatPrivateView = ChatPrivateView or BaseClass(BaseRender)

function ChatPrivateView:__init()
	self.select_index = 0
	self.privite_red_point = self:FindVariable("PriviteRedPoint")

	self.tab_chat = self:FindObj("TabChat")
	self.tab_friend = self:FindObj("TabFriendList")
	self.top_title = self:FindObj("TopTitle")
	self.title_position = self.top_title.transform.localPosition

	self.cell_list = {}
	self.role_cell_list = {}

	self.private_list = {}
	self.role_list = {}

	self.chat_list_view = self:FindObj("CharList")
	local scroller_delegate = self.chat_list_view.list_simple_delegate
	scroller_delegate.CellSizeDel = BindTool.Bind(self.GetCellSizeDel, self)
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.role_list_view = self:FindObj("LeftRoleList")
	local delegate = self.role_list_view.list_simple_delegate
	delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoleNumberOfCells, self)
	delegate.CellRefreshDel = BindTool.Bind(self.RefreshRoleCell, self)

	self.friend_view = ChatFriendView.New(self:FindObj("FindFriendList"))

	self.tab_chat.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, 1))
	self.tab_friend.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, 2))

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

function ChatPrivateView:__delete()
	print("ChatPrivateView.Release")
	if self.friend_view then
		self.friend_view:DeleteMe()
		self.friend_view = nil
	end

	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for k, v in pairs(self.role_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.role_cell_list = {}
	self.select_index = 0
end

function ChatPrivateView:OnToggleChange(index, ison)
	if ison then
		if index == 1 then
			-- self.top_title.transform.localPosition = self.title_position
			ChatData.Instance:SetHavePriviteChat(false)
			self:SetPriviteRedPoint(false)
			ChatCtrl.Instance.view:SetPriviteRedVisible()
			self:FlushPrivateView()
		else
			-- self.top_title.transform.localPosition = Vector3(0, self.title_position.y, self.title_position.z)
			self:FlushFriendView()
		end
	end
end

function ChatPrivateView:SetPriviteRedPoint(state)
	if state then
		if self.tab_friend.toggle.isOn then
			self.privite_red_point:SetValue(true)
		else
			self.privite_red_point:SetValue(false)
		end
	else
		self.privite_red_point:SetValue(false)
	end
end

function ChatPrivateView:SetSelectIndex(index)
	self.select_index = index
end

function ChatPrivateView:ChangePriviteTab(tab_index)
	if tab_index == 1 then
		if self.tab_chat.toggle.isOn then
			ChatData.Instance:SetHavePriviteChat(false)
			self:SetPriviteRedPoint(false)
			ChatCtrl.Instance.view:SetPriviteRedVisible()
			self:FlushPrivateView()
		else
			self.tab_chat.toggle.isOn = true
		end
	else
		if self.tab_friend.toggle.isOn then
			self:FlushFriendView()
		else
			self.tab_friend.toggle.isOn = true
		end
	end
end

function ChatPrivateView:FlushView(index)
	if index == 1 then
		if self.tab_chat.toggle.isOn then
			ChatData.Instance:SetHavePriviteChat(false)
			self:FlushPrivateView()
		end
	else
		if self.tab_friend.toggle.isOn then
			self:FlushFriendView()
		end
	end
end

function ChatPrivateView:FlushPrivateView()
	local curr_id = ChatData.Instance:GetCurrentRoleId()
	local msg_list = {}
	if curr_id then
		local privateobj = ChatData.Instance:GetPrivateObjByRoleId(curr_id) or {}
		if next(privateobj) then
			msg_list = privateobj.msg_list
			privateobj.unread_num = 0
		end
	end
	self:FlushMsgList(msg_list)

	if self.role_list_view.scroller.isActiveAndEnabled then
		self.role_list = ChatData.Instance:GetPrivateObjList()
		self.role_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end

	self:RefreshSelect(curr_id)
end

function ChatPrivateView:FlushMsgList(data)
	self.private_list = data
	if self.chat_list_view.scroller.isActiveAndEnabled then
		local is_lock = ChatData.Instance:GetIsLockState()
		if is_lock then
			self.chat_list_view.scroller:RefreshAndReloadActiveCellViews(true)
		else
			self.chat_list_view.scroller:ReloadData(1)
		end
	end

end

function ChatPrivateView:FlushFriendView()
	if not IsNil(self.friend_view.root_node.gameObject) then
		self.friend_view:FlushFriendView()
	end
end

function ChatPrivateView:GetCellSizeDel(data_index)
	data_index = data_index + 1
	local private_list = self.private_list[data_index]

	local height = ChatData.Instance:GetChannelItemHeight(CHANNEL_TYPE.PRIVATE, private_list.msg_id)
	if height > 0 then
		return height
	end

	local scroller_delegate = self.chat_list_view.list_simple_delegate
	local chat_measuring = ChatCtrl.Instance:GetChatMeasuring(scroller_delegate)
	chat_measuring:SetData(private_list)
	height = chat_measuring:GetContentHeight()
	ChatData.Instance:SetChannelItemHeight(CHANNEL_TYPE.PRIVATE, private_list.msg_id, height)
	return height
end

function ChatPrivateView:GetNumberOfCells()
	return #self.private_list or 0
end

function ChatPrivateView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local chat_cell = self.cell_list[cell]
	if chat_cell == nil then
		chat_cell = ChatCell.New(cell.gameObject)
		self.cell_list[cell] = chat_cell
	end

	chat_cell:SetIndex(data_index)
	chat_cell:SetData(self.private_list[data_index])
end


function ChatPrivateView:GetRoleNumberOfCells()
	return #self.role_list or 0
end

function ChatPrivateView:RefreshRoleCell(cell, data_index)
	data_index = data_index + 1
	local role_cell = self.role_cell_list[cell]
	if role_cell == nil then
		role_cell = LeftRoleCell.New(cell.gameObject)
		role_cell.root_node.toggle.group = self.role_list_view.toggle_group
		role_cell.private_view = self
		self.role_cell_list[cell] = role_cell
	end

	role_cell:SetIndex(data_index)
	role_cell:SetData(self.role_list[data_index])
end

function ChatPrivateView:RefreshSelect(role_id)
	if not role_id then
		return
	end
	for k, v in pairs(self.role_cell_list) do
		if v then
			local data = v:GetData()
			if data and next(data) then
				if data.role_id == role_id then
					v:ClickItem()
				end
			end
		end
	end
end

function ChatPrivateView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ChatPrivateView:GetSelectIndex()
	return self.select_index or 0
end

--人物列表格子
LeftRoleCell = LeftRoleCell or BaseClass(BaseCell)

function LeftRoleCell:__init()
	self.avatar_key = 0
	
	self.name = self:FindVariable("RoleName")
	self.lev = self:FindVariable("Level")
	self.red_point = self:FindVariable("RedPoint")

	--头像UI
	self.raw_image_obj = self:FindObj("RawImage")
	self.show_image = self:FindVariable("ShowImage")
	self.image_res = self:FindVariable("ImageRes")

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
	self:ListenEvent("ClickDelete", BindTool.Bind(self.ClickDelete, self))
end

function LeftRoleCell:__delete()
	self.avatar_key = 0
end

function LeftRoleCell:DataLoadCallBack(role_id, raw_image_obj, path)
	if self:IsNil() then
		return
	end

	if role_id ~= self.data.role_id then
		self.show_image:SetValue(true)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(self.data.role_id, false)
	end
	raw_image_obj.raw_image:LoadSprite(path, function ()
		if role_id ~= self.data.role_id then
			self.show_image:SetValue(true)
			return
		end
		self.show_image:SetValue(false)
	end)
end

function LeftRoleCell:OnFlush()
	if not self.data or not next(self.data) then return end

	self.name:SetValue(self.data.username)
	self.lev:SetValue(self.data.level)

	--头像的相关操作
	local avatar_key = AvatarManager.Instance:GetAvatarKey(self.data.role_id)
	if avatar_key == 0 then
		--展示默认头像
		self.avatar_key = 0
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		self.image_res:SetAsset(bundle, asset)
		self.show_image:SetValue(true)
	else
		if avatar_key ~= self.avatar_key then
			self.avatar_key = avatar_key
			AvatarManager.Instance:GetAvatar(self.data.role_id, false, BindTool.Bind(self.DataLoadCallBack, self, self.data.role_id, self.raw_image_obj))
		end
	end

	-- 有未读消息显示红点
	if self.data.unread_num > 0 then
		self.red_point:SetValue(true)
	else
		self.red_point:SetValue(false)
	end

	-- 刷新选中特效
	local select_index = self.private_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index then
		self.root_node.toggle.isOn = true
	end
end

function LeftRoleCell:ClickItem()
	self.root_node.toggle.isOn = true
	self.private_view:SetSelectIndex(self.index)

	local curr_id = ChatData.Instance:GetCurrentRoleId()
	if curr_id == self.data.role_id then
		return
	end
	self.red_point:SetValue(false)
	ChatData.Instance:SetCurrentRoleId(self.data.role_id)
	self.private_view:FlushMsgList(self.data.msg_list)
	self.data.unread_num = 0
end

function LeftRoleCell:ClickDelete()
	local cur_role_id = ChatData.Instance:GetCurrentRoleId()
	if cur_role_id == self.data.role_id then
		--清除选中
		self.private_view:SetSelectIndex(0)
		ChatData.Instance:SetCurrentRoleId(0)
	end

	--清除私聊对象
	local index = ChatData.Instance:GetPrivateIndex(self.data.role_id)
	ChatData.Instance:RemovePrivateObjByIndex(index)
	self.private_view:FlushPrivateView()
	self.private_view:FlushMsgList({})
end