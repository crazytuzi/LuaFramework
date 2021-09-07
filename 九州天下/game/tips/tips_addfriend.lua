TipsAddFriendView = TipsAddFriendView or BaseClass(BaseView)

function TipsAddFriendView:__init()
	self.ui_config = {"uis/views/tips/addfriendtip", "AddFriendTip"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)

	self.name = ""
	self.play_audio = true
end

function TipsAddFriendView:__delete()
end

function TipsAddFriendView:LoadCallBack()
	self.chat_input = self:FindObj("Input")

	self:ListenEvent("Close",BindTool.Bind(self.CloseWindow, self))
	-- self:ListenEvent("Rename",BindTool.Bind(self.RenameOnChange, self))
	self:ListenEvent("SureBtn",BindTool.Bind(self.SureBtnOnClick, self))
end

function TipsAddFriendView:ReleaseCallBack()
	self.chat_input = nil
end

function TipsAddFriendView:RenameOnChange()
	local text = self.chat_input.input_field.text
	self.chat_input.input_field.text = ""
	self.name = text
end

function TipsAddFriendView:SureBtnOnClick()
	local name = self.chat_input.input_field.text
	local main_role = Scene.Instance:GetMainRole()
	local main_role_name = main_role.name
	if "" == name or ChatFilter.Instance:IsIllegal(name, true) then	-- 判断是否非法
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.AddPrivate)
	elseif main_role_name == name then						-- 判断是否自己
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.NotAddSelf)
	elseif ScoietyData.Instance:IsFriend(name) then		-- 判断是否好友
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.AlreadyYouFriend)
	else
		self.check_name = name
		PlayerCtrl.Instance:CSFindRoleByName(name)
	end
end

function TipsAddFriendView:OpenCallBack()
	self.check_name = ""
	self.role_name_info = GlobalEventSystem:Bind(OtherEventType.ROLE_NAME_INFO, BindTool.Bind(self.ReqRoleInfo, self))
end

function TipsAddFriendView:CloseCallBack()
	self.check_name = ""
	if self.role_name_info then
		GlobalEventSystem:UnBind(self.role_name_info)
		self.role_name_info = nil
	end
end

function TipsAddFriendView:CloseWindow()
	self.chat_input.input_field.text = ""
	self.name = ""
	self:Close()
end

function TipsAddFriendView:ReqRoleInfo(info)
	if info.role_name ~= "" and self.check_name ~= info.role_name then
		return
	end
	self.check_name = ""
	local role_id = info.role_id
	local is_online = info.is_online
	if role_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Society.UserNotExist)
		return
	elseif is_online ~= 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.OnlineLimitDes)
		return
	end

	ScoietyCtrl.Instance:AddFriendReq(role_id)
	self:Close()
end