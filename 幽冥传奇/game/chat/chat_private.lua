
require("scripts/game/chat/chat_private_obj_item")

function ChatView:InitPrivate()
	self.curr_index = 0
	self.select_effect_index = 0

	self.content_list_view_list = {}                -- 聊天内容listview列表，每个对象一个listview

	-- 初始化隐藏关闭按钮
	self.node_tree.layout_private.btn_closecurrent.node:setVisible(false)

	-- 添加玩家查询框
	local name_path_add = ResPath.GetCommon("img9_110")
	self.edit_player = XUI.CreateEditBox(263, 553, 550 , 55, COMMON_CONSTS.FONT, 0, 3, name_path_add, true, cc.rect(0, 0, 0, 0))
	self.edit_player:setFontSize(CHAT_FONT_SIZE)
	self.edit_player:setPlaceHolder(Language.Chat.PleaseInputName)
	self.edit_player:registerScriptEditBoxHandler(BindTool.Bind2(ChatData.ExamineEditTextNum, self.edit_player, 12))

	self.node_tree.layout_private.node:addChild(self.edit_player, 100, 100)

	-- 创建正在聊天对象的label
	self.rich_private = XUI.CreateRichText(550, 495, 0, 0, true)
	self.rich_private:setHorizontalAlignment(1)
	self.rich_private:setAnchorPoint(0.5, 1)
	self.node_tree.layout_private.node:addChild(self.rich_private, 100, 100)

	-- 角色列表listview
	self.role_list_view = ListView.New()
	self.role_list_view:SetJumpDirection(ListView.Top)
	self.role_list_view:Create(112, 318, 240, 365, nil, ChatPrivateObjItem, nil, true)
	self.role_list_view:SetMargin(1)
	self.role_list_view:SetItemsInterval(5)
	self.node_t_list.layout_private.node:addChild(self.role_list_view:GetView(), 100, 100)
	self.role_list_view:SetSelectCallBack(BindTool.Bind1(self.OnClickListView, self))

	self.node_tree.layout_private.btn_add.node:addClickEventListener(BindTool.Bind1(self.OnAddChat, self))
	self.node_tree.layout_private.btn_closecurrent.node:addClickEventListener(BindTool.Bind1(self.CloseCurrentPrivate, self))
	self.node_tree.layout_private.btn_friendprivate.node:addClickEventListener(BindTool.Bind1(self.OpenFriendList, self))
end

function ChatView:IsPrivateOpen()
	return self:IsOpen() and self:IsPrivateIndex()
end

function ChatView:IsPrivateIndex()
	return self:GetShowIndex() == ChatViewIndex.Private
end

function ChatView:OpenPrivate(index)
	self.curr_index = index
	if self:IsOpen() then
		if self:IsPrivateIndex() then
			self:Flush(ChatViewIndex.Private)
		else
			self:ChangeToIndex(ChatViewIndex.Private)
		end
	else
		self:Open(ChatViewIndex.Private)
	end
end

function ChatView:PrivateReleaseCallBack()
	self.edit_player = nil
	self.rich_private = nil

	if nil ~= self.content_list_view_list then
		for k, v in pairs(self.content_list_view_list) do
			v:DeleteMe()
		end
		self.content_list_view_list = {}
	end

	if nil ~= self.role_list_view then
		self.role_list_view:DeleteMe()
		self.role_list_view = nil
	end
end

function ChatView:OnClickListView(item, index)
	self.select_effect_index = index
	self:OnChangePrivateIndex(index)
	self:UpdateContentVisible()
end

-- 切换聊天
function ChatView:OnChangePrivateIndex(index)
	if self.curr_index ~= index then
		self.curr_index = index
		self:UpdatePrivateView()
	end
end

-- 添加聊天
function ChatView:OnAddChat()
	if nil == self.edit_player then
		return
	end

	-- 判断等级是否足够
	if GameVoManager.Instance:GetMainRoleVo().level < CHANNEL_LV[CHANNEL_TYPE.PRIVATE] then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, CHANNEL_LV[CHANNEL_TYPE.PRIVATE]))
		self.edit_player:setText("")
		return
	end

	local role_name = self.edit_player:getText()
	if string.len(role_name) <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Chat.AddPrivate)
		return
	end

	self.edit_player:setText("")
	ChatCtrl.Instance:AddPrivateRequset(role_name)
end

function ChatView:UpdatePrivateView(is_list_change)
	if 0 == self.curr_index and ChatData.Instance:GetPrivateObjCount() > 0 then
		self.curr_index = 1
	end
	local obj_list = ChatData.Instance:GetPrivateObjList()
	local add_num = #obj_list - #self.content_list_view_list
	if add_num > 0 then
		for i = 1, add_num do
			self:CreateContentListView()
		end

		self:UpdateContentVisible()
	end

	local private_obj = ChatData.Instance:GetPrivateObjByIndex(self.curr_index)
	if nil ~= private_obj then
		self.node_tree.layout_private.btn_closecurrent.node:setVisible(true)
		self:UpdatePrivateRich(private_obj.sex, private_obj.username)
		self.input_view:SetPrivateRoleId(private_obj.role_id, private_obj.username)

		ChatView.UpdateContentListView(self.content_list_view_list[self.curr_index], private_obj.msg_list, private_obj.unread_num)
		private_obj.unread_num = 0

		ChatData.Instance:RemPrivateUnreadMsg(private_obj.role_id)
	else
		self.node_tree.layout_private.btn_closecurrent.node:setVisible(false)
		self:UpdatePrivateRich()
		self.input_view:SetPrivateRoleId(0, "")
	end

	local cur_item = self.role_list_view:GetItemAt(self.curr_index)
	if cur_item then
		cur_item:SetData(obj_list[self.curr_index])
	end
	
	if is_list_change then self:UpdateListView() end
	
	-- 更新选中特效
	if self.select_effect_index ~= self.curr_index then
		self.role_list_view:SelectIndex(self.curr_index)
		self:UpdateContentVisible()
	end
end

function ChatView:UpdateListView()
	local obj_list = ChatData.Instance:GetPrivateObjList()
	local old_count = self.role_list_view:GetCount()
	self.role_list_view:SetDataList(obj_list)
end

-- 刷新文字
function ChatView:UpdatePrivateRich(sex, name) 
	local content = "  "

	if nil ~= sex and nil ~= name then
		local sex_color_cfg = SEX_COLOR[sex] or SEX_COLOR[1]
		content = string.format(Language.Chat.PrivateDesc, sex_color_cfg[2], name)
	end

	RichTextUtil.ParseRichText(self.rich_private, content, 25, nil)
end

-- 关闭当前聊天
function ChatView:CloseCurrentPrivate()
	ChatData.Instance:RemovePrivateObjByIndex(self.curr_index)
	self.input_view:CleanInput()
	self:RemoveContentListView(self.curr_index)

	if nil == ChatData.Instance:GetPrivateObjByIndex(self.curr_index) then
		self.curr_index = self.curr_index - 1
	end
	self.select_effect_index = 0
	self:UpdatePrivateView(true)

	SysMsgCtrl.Instance:ErrorRemind(Language.Chat.CloseCurrentPrivate)
end

-- 打开好友列表
function ChatView:OpenFriendList()
	if GameVoManager.Instance:GetMainRoleVo().level < CHANNEL_LV[CHANNEL_TYPE.PRIVATE] then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Chat.LevelDeficient, CHANNEL_LV[CHANNEL_TYPE.PRIVATE]))
		return
	end

	SocietyCtrl.Instance:OpenFriendListView(9999, function (user_info)
		if nil == user_info then
			return
		end

		if nil == ChatData.Instance:GetPrivateObjByRoleId(user_info.user_id) then
			private_obj = ChatData.CreatePrivateObj()
			private_obj.role_id = user_info.user_id
			private_obj.username = user_info.gamename
			private_obj.sex = user_info.sex
			private_obj.camp = user_info.camp
			private_obj.prof = user_info.prof
			private_obj.avatar_key_small = user_info.avatar_key_small
			private_obj.level = user_info.level
			ChatData.Instance:AddPrivateObj(private_obj.role_id, private_obj)
		end

		self.curr_index = ChatData.Instance:GetPrivateIndex(user_info.user_id)
		self:UpdatePrivateView(true)
	end)
end

-- 创建聊天内容listview
function ChatView:CreateContentListView()
	local list_view = ChatListView.New()
	list_view:Create(577, 292, 600, 320)
	self.node_t_list.layout_private.node:addChild(list_view:GetView(), 100, 100)
	table.insert(self.content_list_view_list, list_view)
end

-- 移除聊天内容listview
function ChatView:RemoveContentListView(index)
	local list_view = self.content_list_view_list[index]
	if nil == list_view then
		return
	end

	list_view:DeleteMe()
	list_view:GetView():removeFromParent()
	table.remove(self.content_list_view_list, index)
end

function ChatView:UpdateContentVisible()
	for k, v in pairs(self.content_list_view_list) do
		v:GetView():setVisible(self.curr_index == k)
	end
end
