-----------------------------------聊天对象列表---------------------------------
ChatTargetItem = ChatTargetItem or BaseClass(BaseCell)
function ChatTargetItem:__init()
	self.raw_image = self:FindObj("RawImage")

	self.name = self:FindVariable("Name")
	self.normal_img_res = self:FindVariable("ImgRes")
	-- self.custom_img_res = self:FindVariable("RawImgRes")
	self.is_online = self:FindVariable("IsOnline")
	self.show_normal_img = self:FindVariable("ShowImage")
	self.show_remind = self:FindVariable("ShowRemind")
	self.can_close = self:FindVariable("CanClose")
	self.remind_text = self:FindVariable("RemindText")
	self.channel_type = self:FindVariable("ChannelType")
	self.head_frame_res = self:FindVariable("head_frame_res")
	self.show_default_frame = self:FindVariable("show_default_frame")

	self:ListenEvent("ClickClose", BindTool.Bind(self.ClickClose, self))
	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))

	self.remind_change = BindTool.Bind(self.GuildRemindChangeCallBack, self)
end

function ChatTargetItem:__delete()
	self.show_normal_img = nil

	self:UnBindIsOnlineEvent()
	self:UnBindRemind()
	self:RemoveDelayTime()
end

function ChatTargetItem:UnBindRemind()
	if RemindManager.Instance and self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function ChatTargetItem:RoleIsOnlineChange(role_id, is_online)
	if role_id == self.data.role_id then
		if self.is_online then
			self.is_online:SetValue(is_online == 1)
		end
	end
end

function ChatTargetItem:ClickClose()
	local role_id = self.data.role_id

	if role_id ~= SPECIAL_CHAT_ID.GUILD and role_id ~= SPECIAL_CHAT_ID.TEAM then
		local index = ChatData.Instance:GetPrivateIndex(role_id)
		ChatCtrl.Instance:DelPriviteObjOnLocal(role_id)
		ChatData.Instance:RemovePrivateObjByIndex(index)
	end
	if self.root_node.toggle.isOn then
		ChatData.Instance:SetCurrentId(-1)
	end

	--当前删除的频道类型
	local channel_type = CHANNEL_TYPE.PRIVITE
	if role_id == SPECIAL_CHAT_ID.GUILD then
		channel_type = CHANNEL_TYPE.GUILD
	elseif role_id == SPECIAL_CHAT_ID.TEAM then
		channel_type = CHANNEL_TYPE.TEAM
	end
	
	ViewManager.Instance:FlushView(ViewName.ChatGuild, "select_traget", {false, channel_type})
end

function ChatTargetItem:SetToggleIsOn(ison)
	local now_ison = self.root_node.toggle.isOn
	if ison == now_ison then
		return
	end
	self.root_node.toggle.isOn = ison
end

function ChatTargetItem:SetRemind(state)
	self.show_remind:SetValue(state)
end

function ChatTargetItem:LoadAvatarCallBack(role_id, path)
	if self:IsNil() then
		return
	end

	if role_id ~= self.data.role_id then
		self.show_normal_img:SetValue(true)
		return
	end

	if path == nil then
		path = AvatarManager.GetFilePath(role_id, false)
	end
	self.show_normal_img:SetValue(false)
	self:RemoveDelayTime()
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
		self.custom_img_res:SetValue(path)
	end, 0)
end

function ChatTargetItem:RemoveDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function ChatTargetItem:UnBindIsOnlineEvent()
	if self.role_event_system then
		GlobalEventSystem:UnBind(self.role_event_system)
		self.role_event_system = nil
	end
end

function ChatTargetItem:BindIsOnlineEvent()
	--监听玩家上下线
	self.role_event_system = GlobalEventSystem:Bind(OtherEventType.ROLE_ISONLINE_CHANGE, BindTool.Bind(self.RoleIsOnlineChange, self))
end

function ChatTargetItem:GuildRemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.GuildChatRed or remind_name == RemindName.GuildSignin then
		local guild_unread_msg = ChatData.Instance:GetGuildUnreadMsg()
		local guild_chat_remind = GuildChatData.Instance:GetGuildChatRemind()
		local guild_sing_remind = GuildData.Instance:GetSigninRemind()
		local is_show = nil ~= guild_unread_msg or guild_chat_remind > 0 or guild_sing_remind > 0
		
		self:SetRemind(is_show)
	end
end

--刷新红点
function ChatTargetItem:FlushRemind()
	local role_id = self.data.role_id

	if role_id == SPECIAL_CHAT_ID.GUILD then
		local guild_unread_msg = ChatData.Instance:GetGuildUnreadMsg()
		local guild_remind = RemindManager.Instance:GetRemind(RemindName.GuildChatRed)
		self:SetRemind(guild_unread_msg ~= nil or guild_remind > 0)
	elseif role_id == SPECIAL_CHAT_ID.TEAM then
		local unread_msg_count = ChatData.Instance:GetTeamUnreadCount()
		self:SetRemind(unread_msg_count > 0)
	elseif role_id > SPECIAL_CHAT_ID.ALL then
		local unread_msg_count = ChatData.Instance:GetPrivateUnreadMsgCountById(role_id)
		self:SetRemind(unread_msg_count > 0)
	end
end

function ChatTargetItem:OnFlush()
	self:UnBindRemind()
	
	if not self.data then
		return
	end
	if nil ~= self.data.is_online then
		self.is_online:SetValue(self.data.is_online == 1)
	else
		self.is_online:SetValue(true)
	end
	local name = ""
	self.can_close:SetValue(false)
	local role_id = self.data.role_id
	if role_id == SPECIAL_CHAT_ID.GUILD then
		--增加红点绑定
		RemindManager.Instance:Bind(self.remind_change, RemindName.GuildChatRed)
		RemindManager.Instance:Bind(self.remind_change, RemindName.GuildSignin)
		
		self.show_normal_img:SetValue(false)
		self.channel_type:SetValue(1)
		name = GameVoManager.Instance:GetMainRoleVo().guild_name
	elseif role_id == SPECIAL_CHAT_ID.TEAM then
		--队伍
		self.show_normal_img:SetValue(false)
		self.channel_type:SetValue(2)
		name = Language.Society.TeamDes
	else
		self.can_close:SetValue(true)
		self.channel_type:SetValue(3)	

		local function download_callback(path)
			if nil == self.raw_image or IsNil(self.raw_image.gameObject) then
				return
			end
			if self.data.role_id ~= role_id then
				return
			end
			local avatar_path = path or AvatarManager.GetFilePath(role_id, true)
			self.raw_image.raw_image:LoadSprite(avatar_path,
			function()
				if self.data.role_id ~= role_id then
					return
				end
			 	if self.show_normal_img then
					self.show_normal_img:SetValue(false)
				end
			end)
		end
		CommonDataManager.NewSetAvatar(role_id, self.show_normal_img, self.normal_img_res, self.raw_image, self.data.sex, self.data.prof, true, download_callback)
		CommonDataManager.SetAvatarFrame(role_id, self.head_frame_res, self.show_default_frame)
		name = self.data.username
	end
	self.name:SetValue(name)
end