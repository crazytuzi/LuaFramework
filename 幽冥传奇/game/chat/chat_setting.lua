ChatView = ChatView or BaseClass(BaseView)

function ChatView:InitSetting()
	self.node_tree.layout_setting.img_hook_0.node:setVisible(false)
	self.node_tree.layout_setting.img_hook_3.node:setVisible(false)
	self.node_tree.layout_setting.img_hook_4.node:setVisible(false)
	self.node_tree.layout_setting.img_hook_6.node:setVisible(false)

	self.node_t_list.layout_setting.node:setTouchEnabled(true)

	self:ShowIsPingbi(CHANNEL_TYPE.WORLD)
	self:ShowIsPingbi(CHANNEL_TYPE.TEAM)
	self:ShowIsPingbi(CHANNEL_TYPE.GUILD)
	self:ShowIsPingbi(CHANNEL_TYPE.SYSTEM)

	self:RegisterSettingEvent()
end

function ChatView:RegisterSettingEvent()
	self.node_tree.layout_setting.btn_close.node:addClickEventListener(BindTool.Bind1(self.CloseSetting, self))
	self.node_tree.layout_setting.btn_maskworld.node:addClickEventListener(BindTool.Bind2(self.MaskChannelMsg, self, CHANNEL_TYPE.WORLD))
	self.node_tree.layout_setting.btn_maskteam.node:addClickEventListener(BindTool.Bind2(self.MaskChannelMsg, self, CHANNEL_TYPE.TEAM))
	self.node_tree.layout_setting.btn_maskguild.node:addClickEventListener(BindTool.Bind2(self.MaskChannelMsg, self, CHANNEL_TYPE.GUILD))
	self.node_tree.layout_setting.btn_masksystem.node:addClickEventListener(BindTool.Bind2(self.MaskChannelMsg, self, CHANNEL_TYPE.SYSTEM))
end

function ChatView:OpenSetting()
	if not self:IsLoadedIndex(ChatViewIndex.Setting) then
		self:Load(ChatViewIndex.Setting)
	else
		self.node_t_list.layout_setting.node:setVisible(true)
	end
end

function ChatView:CloseSetting()
	self.node_t_list.layout_setting.node:setVisible(false)
end

function ChatView:MaskChannelMsg(channel_type, sender)
	local channel = ChatData.Instance:GetChannel(channel_type)
	if nil == channel then
		return
	end

	channel.is_pingbi = not channel.is_pingbi
	self:ShowIsPingbi(channel_type)
end

function ChatView:ShowIsPingbi(channel_type)
	local channel = ChatData.Instance:GetChannel(channel_type)
	if nil == channel or nil == self.node_tree.layout_setting["img_hook_" .. channel_type] then
		return
	end
	self.node_tree.layout_setting["img_hook_" .. channel_type].node:setVisible(channel.is_pingbi)
end