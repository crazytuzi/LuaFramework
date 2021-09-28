ChatFriendView = ChatFriendView or BaseClass(BaseRender)

function ChatFriendView:__init()
	self.cell_list = {}

	self.friend_list = {}

	self.input_name = self:FindObj("InPutField")

	self.friend_list_view = self:FindObj("RoleList")
	local delegate = self.friend_list_view.list_simple_delegate
	delegate.NumberOfCellsDel = BindTool.Bind(self.GetFriendNumberOfCells, self)
	delegate.CellRefreshDel = BindTool.Bind(self.RefreshFriendCell, self)

	self:ListenEvent("ClickFind", BindTool.Bind(self.ClickFind, self))
end

function ChatFriendView:__delete()
	print("ChatFriendView.Release")
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function ChatFriendView:FlushFriendView()
	self.friend_list = ScoietyData.Instance:GetIsOnLineFriendInfo()
	if self.friend_list_view.scroller.isActiveAndEnabled then
		self.friend_list_view.scroller:ReloadData(0)
	end
end

function ChatFriendView:ClickFind()
	local name = self.input_name.input_field.text

	if #self.friend_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotOnlineFriend)
		return
	end

	if name == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotChooseUser)
		return
	end

	for _, v in ipairs(self.friend_list) do
		if name == v.gamename then
			self.friend_list = {}
			table.insert(self.friend_list, v)
			if self.friend_list_view.scroller.isActiveAndEnabled then
				self.friend_list_view.scroller:ReloadData(0)
			end
			return
		end
	end
	SysMsgCtrl.Instance:ErrorRemind(Language.Society.UserNotExist)
end

function ChatFriendView:GetFriendNumberOfCells()
	return #self.friend_list or 0
end

function ChatFriendView:RefreshFriendCell(cell, data_index)
	data_index = data_index + 1
	local role_cell = self.cell_list[cell]
	if role_cell == nil then
		role_cell = ChatFriendCell.New(cell.gameObject)
		role_cell.friend_view = self
		self.cell_list[cell] = role_cell
	end

	role_cell:SetIndex(data_index)
	role_cell:SetData(self.friend_list[data_index])
end

function ChatFriendView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function ChatFriendView:GetSelectIndex()
	return self.select_index or 0
end

--好友列表格子
ChatFriendCell = ChatFriendCell or BaseClass(BaseCell)

function ChatFriendCell:__init()
	self.avatar_key = 0

	-- self.level = self:FindVariable("Level")
	self.name = self:FindVariable("Name")
	self.capability = self:FindVariable("Capability")
	self.online = self:FindVariable("Online")
	self.gray = self:FindVariable("Gray")

	--头像UI
	self.show_image = self:FindVariable("ShowImage")
	self.image_res = self:FindVariable("ImageRes")
	self.raw_image_obj = self:FindObj("RawImage")

	self:ListenEvent("SendMsg", BindTool.Bind(self.SendMsg, self))
end

function ChatFriendCell:__delete()
	self.avatar_key = 0
end

function ChatFriendCell:LoadCallBack(user_id, raw_image_obj, path)
	if self:IsNil() then
		return
	end

	if user_id ~= self.data.user_id then
		self.show_image:SetValue(true)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(self.data.user_id, false)
	end
	raw_image_obj.raw_image:LoadSprite(path, function ()
		if user_id ~= self.data.user_id then
			self.show_image:SetValue(true)
			return
		end
		self.show_image:SetValue(false)
	end)
end

function ChatFriendCell:OnFlush()
	if not self.data or not next(self.data) then return end

	--头像的相关操作
	local avatar_key = AvatarManager.Instance:GetAvatarKey(self.data.user_id)
	if avatar_key == 0 then
		--展示默认头像
		self.avatar_key = 0
		local bundle, asset = AvatarManager.GetDefAvatar(self.data.prof, false, self.data.sex)
		self.image_res:SetAsset(bundle, asset)
		self.show_image:SetValue(true)
	else
		if avatar_key ~= self.avatar_key then
			self.avatar_key = avatar_key
			AvatarManager.Instance:GetAvatar(self.data.user_id, false, BindTool.Bind(self.LoadCallBack, self, self.data.user_id, self.raw_image_obj))
		end
	end

	self.name:SetValue(self.data.gamename)
	self.capability:SetValue(self.data.capability)
	local online_txt = ""
	if self.data.is_online == 0 then
		online_txt = Language.Common.OutLine
	else
		online_txt = Language.Common.OnLine
	end
	self.online:SetValue(online_txt)
end

function ChatFriendCell:SendMsg()
	if not self.data or not next(self.data) then return end

	if not ChatData.Instance:IsCanChat(CHAT_OPENLEVEL_LIMIT_TYPE.SINGLE) then
		return
	end

	local private_obj = {}
	if nil == ChatData.Instance:GetPrivateObjByRoleId(self.data.user_id) then
		private_obj = ChatData.CreatePrivateObj()
		private_obj.role_id = self.data.user_id
		private_obj.username = self.data.gamename
		private_obj.sex = self.data.sex
		private_obj.camp = self.data.camp
		private_obj.prof = self.data.prof
		private_obj.avatar_key_small = self.data.avatar_key_small
		private_obj.level = self.data.level
		private_obj.create_time = TimeCtrl.Instance:GetServerTime()
		ChatData.Instance:AddPrivateObj(private_obj.role_id, private_obj)
	end
	ChatData.Instance:SetCurrentId(self.data.user_id)
end