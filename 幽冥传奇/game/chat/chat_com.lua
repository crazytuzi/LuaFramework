ChatView = ChatView or BaseClass(BaseView)

function ChatView:InitCom()
	self.list_view_list = {}
	local ph = self.ph_list.ph_chat_list
	for i, v in ipairs({CHANNEL_TYPE.ALL, CHANNEL_TYPE.NEAR, CHANNEL_TYPE.WORLD, CHANNEL_TYPE.GUILD, CHANNEL_TYPE.TEAM, CHANNEL_TYPE.PRIVATE}) do
		local list_view = ChatListView.New()
		list_view:Create(ph.x, ph.y, ph.w, ph.h)
		self.node_t_list.layout_chat.node:addChild(list_view:GetView(), 100)
		self.list_view_list[i] = list_view
	end
	
	local ph2 = self.ph_list.ph_chat_list2
	self.com_title_view_w = ph2.w
	self.com_title_view = XUI.CreateLayout(ph2.x, ph2.y, ph2.w, ph2.h)
	self.com_title_view:setClippingEnabled(true)
	self.node_t_list.layout_chat.node:addChild(self.com_title_view, 100)

	self.transmit_list =  ChatListView.New()
	self.transmit_list:Create(ph2.w / 2, ph2.h / 2, ph2.w - 25, ph2.h)
	self.com_title_view:addChild(self.transmit_list:GetView(), 100)

	local ph_near_list = self.ph_list.ph_chat_near_list

	self.chat_role_list = ListView.New()
	self.chat_role_list:Create(ph_near_list.x-10, ph_near_list.y, ph_near_list.w, ph_near_list.h, nil, ChatNearlistRender, nil, true, self.ph_list.ph_chat_near_reander)
	self.node_t_list.layout_chat.node:addChild(self.chat_role_list:GetView(), 100)
	self.chat_role_list:SetJumpDirection(ListView.Top)
	self.chat_role_list:SetItemsInterval(5)
	self.chat_role_list:SetSelectCallBack(BindTool.Bind(self.SelectNearChatRoleCallBack, self))

	self.rich_text = XUI.CreateRichText(0, 0, 800, 24, true)
	self.rich_text:setAnchorPoint(0, 0.5)
	self.com_title_view:addChild(self.rich_text, 999)
	self.rich_text:setPositionY(30)

	self.roll_now = false							-- 是否有滚动字幕
	self.left_bound = 400

end

function ChatView:ComReleaseCallBack()
	self.rich_text = nil
	if nil ~= self.roll_timer then
		GlobalTimerQuest:CancelQuest(self.roll_timer)
		self.roll_timer = nil
	end

	for k, v in pairs(self.list_view_list) do
		v:DeleteMe()
	end
	self.list_view_list = nil

	if self.transmit_list then
		self.transmit_list:DeleteMe()
		self.transmit_list = nil
	end
end

function ChatView:SetComTitleVisible(is_visible)
	self.com_title_view:setVisible(is_visible)
	if is_visible then
		self:UpdateRollTransmit()
	end
end

function ChatView:UpdateRollTransmit()
	if self.roll_now then							-- 当前有滚动的字幕
		return
	end

	if nil == self.rich_text then
		return
	end

	local roll_transmit = ChatData.Instance:PopTransmit()
	if nil ~= roll_transmit then
		local content
		if roll_transmit.speaker_type == SPEAKER_TYPE.SPEAKER_TYPE_CROSS then
			content = string.format("{wordcolor;ffff00;%d%s-%s}:%s", roll_transmit.server_id, Language.Login.Fu, roll_transmit.username, roll_transmit.content)
		else
			content = string.format("{wordcolor;ffff00;%s}:%s", roll_transmit.username, roll_transmit.content)
		end
		RichTextUtil.ParseRichText(self.rich_text, content)
		self.rich_text:setPositionX(self.com_title_view_w - 200)

		self.roll_now = true
		if nil == self.roll_timer then
			self.roll_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateRoll, self), 0.01)
		end
	end
	self.rich_text:setVisible(self.roll_now)
end

function ChatView:UpdateRoll()
	local new_x = self.rich_text:getPositionX() - 3
	if new_x < self.left_bound - self.rich_text:getInnerContainerSize().width * 2.5 then
		new_x = self.com_title_view_w + 1

		GlobalTimerQuest:CancelQuest(self.roll_timer)
		self.roll_timer = nil

		self.roll_now = false
		self:UpdateRollTransmit()
	end

	self.rich_text:setPositionX(new_x)
end

function ChatView:SelectNearChatRoleCallBack(item)
	if nil == item or nil == item:GetData() then return end 
	if self.input_view then
		self.input_view:SetPrivateRoleName(item:GetData().name)
	end
	if self.role_head_menu == nil then
		self.role_head_menu = RoleHeadCell.New(false, false)
	end
	if self.add_private_name then
		self.add_private_name = nil
	else
		self.role_head_menu:SetRoleInfo(item:GetData().role_id, item:GetData().name)
		self.role_head_menu:OpenMenu()
	end
end

----------------------------------------------------------------------------------------------------
-- 最近聊天的人物列表item
----------------------------------------------------------------------------------------------------
ChatNearlistRender = ChatNearlistRender or BaseClass(BaseRender)
function ChatNearlistRender:__init()
	self.cache_select = false
end

function ChatNearlistRender:__delete()
	
end

function ChatNearlistRender:CreateChild()
	BaseRender.CreateChild(self)
end

function ChatNearlistRender:OnFlush()
	self.node_tree.lbl_role_name.node:setString(self.data.name)
	if self.cache_select then
		self:SetSelect(self.is_select)
	end
end

function ChatNearlistRender:SetSelect(is_select)
	if self.cache_select and is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
	BaseRender.SetSelect(self, is_select)
	if self.node_tree.lbl_role_name then
		self.node_tree.lbl_role_name.node:setColor(is_select and Str2C3b("fae6bf") or Str2C3b("9e9688"))
	end

end

-- 创建选中特效
function ChatNearlistRender:CreateSelectEffect()
	if nil == self.node_tree.img_bg then
		self.cache_select = true
		return
	end
	local size = self.node_tree.img_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("btn_108_select"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.node_tree.img_bg.node:addChild(self.select_effect, 999)
end
