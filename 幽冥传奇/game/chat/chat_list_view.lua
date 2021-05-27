-----------------------------------------------------
-- 聊天列表
----------------------------------------------------
ChatListView = ChatListView or BaseClass()
function ChatListView:__init()
	self.list_view = nil
	self.items = {}
	self.data_list = {}

	self.width = 0
	self.is_pressed = false
	self.is_suoping = false
	self.is_step = true
end

function ChatListView:__delete()
	for i, v in ipairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
end

function ChatListView:GetView()
	return self.list_view
end

function ChatListView:Create(x, y, w, h)
	if nil ~= self.list_view then
		return
	end

	self.width = w
	self.list_view = XUI.CreateListView(x, y, w, h, ScrollDir.Vertical)
	self.list_view:setGravity(ListViewGravity.CenterHorizontal)
	self.list_view:setBounceEnabled(true)
	self.list_view:setMargin(5)
	self.list_view:setItemsInterval(5)

	self.list_view:addListEventListener(BindTool.Bind1(self.ListEventCallback, self))

	return self.list_view
end

-- 获得数据源
function ChatListView:GetDataList()
	return self.data_list
end

-- 设置数据源
function ChatListView:SetDataList(data_list)
	self.data_list = data_list
	self:RefreshItems()
end

function ChatListView:RefreshItems()
	if self.data_list == nil or self.list_view == nil then
		return
	end

	local item_count = #self.items
	local data_count = #self.data_list

	if item_count > data_count then					-- item太多 删掉
		for i = item_count, data_count + 1, -1 do
			self:RemoveAt(i)
		end
	elseif item_count < data_count then				-- item不足 创建
		local item = nil
		for i = item_count + 1, data_count do
			item = ChatItemRender.New(self, self.width)
			item:SetIsUseStepCalc(self.is_step)
			table.insert(self.items, item)
			self.list_view:pushBackItem(item:GetView())
		end
	end

	for i = data_count, 1, -1 do
		if self.items[i]:GetMsgId() ~= self.data_list[i].msg_id then
			self.items[i]:SetData(self.data_list[i])
		end
	end
	local p = self.list_view:getInnerPosition()

	if not self.is_pressed and not self.is_suoping and p.y >= 0 then
		self.list_view:refreshView()
		self.list_view:jumpToBottom()
		-- local connent = self.list_view:getInnerContainer()
		-- connent:setPositionY(connent:getPositionY() - 80)
	end
end

function ChatListView:SetIsSuoping(flage)
	self.is_step = not flage
	self.is_suoping = flage
end

function ChatListView:RemoveAt(index)
	if index <= 0 then
		return
	end

	local item = self:GetItemAt(index)
	if nil == item then
		return
	end

	self.list_view:removeItemByIndex(index - 1)
	item:DeleteMe()

	table.remove(self.items, index)
end

function ChatListView:GetItemAt(index)
	return self.items[index]
end

function ChatListView:GetAllItems()
	return self.items
end

function ChatListView:RemoveAllItem()
	for k, v in pairs(self.items) do
		v:DeleteMe()
	end
	self.items = {}
	self.list_view:removeAllItems()
end

function ChatListView:GetCount()
	return #self.items
end

-- 移动第一条到最后
function ChatListView:MoveFrontToLast(move_count)
	if move_count <= 0 then
		return
	end

	local item_count = #self.items
	if item_count <= 1 or move_count >= item_count then
		return
	end

	for i = 1, move_count do
		self.list_view:moveFrontToLast()

		local item = table.remove(self.items, 1)
		item:ClearContent()
		table.insert(self.items, item)
	end
end

function ChatListView:ListEventCallback(sender, event_type, index)
	if XuiListEventType.Began == event_type then
		self.is_pressed = true
	elseif XuiListEventType.Ended == event_type or XuiListEventType.Canceled == event_type then
		self.is_pressed = false
	elseif XuiListEventType.Refresh == event_type then

	end
end

function ChatListView:OnItemHeightChange()
	self.list_view:requestRefreshView()
end

----------------------------------------------------
-- 聊天item
----------------------------------------------------
ChatItemRender = ChatItemRender or BaseClass(BaseRender)
ChatItemRender.DefH = 20

function ChatItemRender:__init(list_view, w)
	self.list_view = list_view
	self.msg_id = 0

	self.layout_w = w
	self.layout_h = ChatItemRender.DefH
	self.max_text_w = w - 10

	self.text_channel = nil
	self.rich_content = nil
	self.record_item = nil 

	self.view:setContentWH(self.layout_w, ChatItemRender.DefH)
end

function ChatItemRender:__delete()
	if self.record_item then
		self.record_item:DeleteMe()
		self.record_item = nil
	end
end

function ChatItemRender:GetMsgId()
	return self.msg_id
end

function ChatItemRender:CreateChild()
	BaseRender.CreateChild(self)

	-- 频道
	-- self.text_channel = XText:create(self.data.username, COMMON_CONSTS.FONT, 20)
	-- self.text_channel:setAnchorPoint(0, 1)
	-- self.view:addChild(self.text_channel)

	-- 内容
	self.rich_content = XUI.CreateRichText(20, 15, self.max_text_w, 10, false)
	self.rich_content:setAnchorPoint(0, 1)
	self.view:addChild(self.rich_content)

	self.eff = RenderUnit.CreateEffect(915, self.view, nil, nil, nil, 15, self.layout_h / 2)
	self.eff:setVisible(false)
end

function ChatItemRender:ClearContent()
	if self.rich_content then
		self.rich_content:removeAllElements()
	end
end

function ChatItemRender:OnFlush()
	if self.msg_id == self.data.msg_id then
		return
	end
	self.msg_id = self.data.msg_id

	self:ParseContent()
	self:UpdataLayout()
	self:UpDataChatRecordLayout()
end

-- 是否语音消息
function ChatItemRender:IsAudio()
	local is_audio = false
	if self.data and self.data.content_type == CHAT_CONTENT_TYPE.AUDIO then
		is_audio = true
	end
	return is_audio
end

-- 是否自己发送的
function ChatItemRender:IsOwn()
	return self.data.name == GameVoManager.Instance:GetMainRoleVo().name
end

function ChatItemRender:ParseContent()
	-- local vip = bit:_and(self.data.flag, 1) == 1
	-- local vip_str = vip and string.format("{wordcolor;ff0000;[VIP%d]}", self.data.vip) or 0
	local guild_pos = ""
	local role_id = self.data.role_id or 0
	if self.data.channel_type == CHANNEL_TYPE.GUILD 
		and self.data.sbk_occupation ~= SOCIAL_MASK_DEF.GUILD_COMMON 
		and Language.Guild.PositionName[self.data.sbk_occupation] then
		guild_pos = string.format("{wordcolor;ffeef00;[%s]}", Language.Guild.PositionName[self.data.sbk_occupation])
	end

	local zs_vip_str = "" 
	if self.data.vip > 0 then
		zs_vip_str = "{ZsVip;" .. tostring(self.data.vip) .. "}"
	end

	local channel_content = "【" .. (Language.Chat.Channel[self.data.channel_type] or "null") .. "】 " .. zs_vip_str
	-- self.text_channel:setString("[" .. (Language.Chat.Channel[self.data.channel_type] or "null") .. "]")
	-- self.text_channel:setColor(CHANNEL_COLOR[self.data.channel_type])
	local chat_content = self:IsAudio() and "" or self.data.content

	if self.data.to_name then
		local content = string.format("%s {wordcolor;e6dfb9;您对}{rolename;00ff00;%s;%d}{wordcolor;e6dfb9;说}：%s", channel_content, self.data.to_name, role_id, chat_content)
		-- if vip then
		-- 	content = string.format("%s {wordcolor;e6dfb9;您对}{rolename;00ff00;%s;%d}%s{wordcolor;e6dfb9;说}：%s", channel_content, self.data.to_name, role_id, vip_str, chat_content)
		-- end
		RichTextUtil.ParseRichText(self.rich_content, content, 20, CHANNEL_COLOR[self.data.channel_type])
	elseif "" ~= self.data.name then
		local content = string.format("%s {rolename;e6dfb9;%s;%d}：%s", channel_content, self.data.name, role_id, chat_content)
		-- if vip then
		-- 	content = string.format("%s {rolename;e6dfb9;%s;%d}%s%s：%s", channel_content, self.data.name, role_id, vip_str, guild_pos, chat_content)
		-- end
		RichTextUtil.ParseRichText(self.rich_content, content, 20, CHANNEL_COLOR[self.data.channel_type])
	else
		local content = string.format("%s %s", channel_content, chat_content)
		RichTextUtil.ParseRichText(self.rich_content, content, 20, CHANNEL_COLOR[self.data.channel_type])
	end


	self.rich_content:refreshView()

	self.eff:setVisible(self.data.channel_type == CHANNEL_TYPE.SPEAKER)
end

-- 更新布局
function ChatItemRender:UpdataLayout()
	-- 计算大小
	local final_h = 0

	local content_render_size = self.rich_content:getInnerContainerSize()
	final_h = final_h + content_render_size.height

	if final_h < ChatItemRender.DefH then final_h = ChatItemRender.DefH end

	if self.layout_h ~= final_h then
		self.layout_h = final_h
		self.view:setContentWH(self.layout_w, self.layout_h)
		self.list_view:OnItemHeightChange()
	end

	-- self.text_channel:setPosition(10, self.layout_h)
	self.rich_content:setPosition(self.data.channel_type == CHANNEL_TYPE.SPEAKER and 25 or 10, self.layout_h)
end

-- 语音处理
function ChatItemRender:UpDataChatRecordLayout()
	if self.record_item and self.record_item:GetSoundKey() then
		ChatRecordMgr.Instance:RemoveRecordItem(self.record_item:GetSoundKey())
	end
	if self:IsAudio() then
		if self.record_item == nil then
			self.record_item = ChatMsgItemRecord.New(0)
			self.view:addChild(self.record_item:GetView())
			self.record_item:GetView():setVisible(false)
		end
		local content_render_size = self.rich_content:getInnerContainerSize()
		local x, y = content_render_size.width, 0
		self.record_item:SetPosition(x, y)
		self.record_item:SetDirection(self:IsOwn() and 0 or 1)

		self.record_item:SetData(self.data)
	end
	if self.record_item then
		self.record_item:GetView():setVisible(self:IsAudio())
	end
end

function ChatItemRender:CreateSelectEffect()
end
