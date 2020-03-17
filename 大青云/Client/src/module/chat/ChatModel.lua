--[[
聊天
lizhuangzhuang
2014年9月19日17:17:00
]]
_G.ChatModel = Module:new();

--频道列表
ChatModel.channels = {
	[ChatConsts.Channel_All] = ChatChannel:new(ChatConsts.Channel_All),
	[ChatConsts.Channel_World] = ChatChannel:new(ChatConsts.Channel_World),
	[ChatConsts.Channel_Map] = ChatChannel:new(ChatConsts.Channel_Map),
	[ChatConsts.Channel_Camp] = ChatChannel:new(ChatConsts.Channel_Camp),
	[ChatConsts.Channel_Guild] = ChatChannel:new(ChatConsts.Channel_Guild),
	[ChatConsts.Channel_Team] = ChatChannel:new(ChatConsts.Channel_Team),
	[ChatConsts.Channel_Horn] = ChatHornChannel:new(ChatConsts.Channel_Horn),
	[ChatConsts.Channel_Cross] = ChatChannel:new(ChatConsts.Channel_Cross),
	[ChatConsts.Channel_System] = ChatChannel:new(ChatConsts.Channel_System),
	-- kua fu
	[ChatConsts.Channel_Cross_Map] = ChatChannel:new(ChatConsts.Channel_Cross_Map),
	[ChatConsts.Channel_Cross_Server] = ChatChannel:new(ChatConsts.Channel_Cross_Server),
};
--私人频道列表
ChatModel.privateChannels = {};
--聊天设置,true表示要过滤
ChatModel.chatSetting = {
	notice = {
		[1] = false,--1.好友上下线提示
		[2] = false,--2.帮派成员上下线提示
		[3] = false,--3.仇人上下线提示
		[4] = false,--4.帮派成员被击杀提示
		[5] = false,--5.好友被击杀提示
	},
	channel = {
		[ChatConsts.Channel_World] = false;--过滤世界聊天
		[ChatConsts.Channel_Team] = false;--过滤队伍聊天
		[ChatConsts.Channel_Guild] = false;--过滤帮派聊天
		[ChatConsts.Channel_Private] = false;--过滤私聊
	}
}
--私聊通知列表
ChatModel.privateNoticeList = {};
--当前私聊列表
ChatModel.privateChatList = {};
--当前私聊对象
ChatModel.currPrivateChat = 0;
--阵营聊天是否打开
ChatModel.campOpen = false;

--常置公告
ChatModel.alwaysNotice = "";

--获取频道
function ChatModel:GetChannel(channel)
	return self.channels[channel];
end

--获取私人频道
function ChatModel:GetPrivateChannel(roleId)
	return self.privateChannels[roleId];
end

--添加私人频道
function ChatModel:AddPrivateChannel(roleId,roleName)
	if self.privateChannels[roleId] then
		return self.privateChannels[roleId];
	end
	local channel = ChatPrivateChannel:new(ChatConsts.Channel_Private);
	channel:SetRoleId(roleId);
	channel:SetRoleName(roleName);
	self.privateChannels[roleId] = channel;
	return channel;
end

--设置当前私聊对象
function ChatModel:SetCurrPrivateChat(roleId,roleName)
	self.currPrivateChat = roleId;
	if roleId~="" and (not self.privateChannels[roleId]) then
		self:AddPrivateChannel(roleId,roleName);
	end
	for i,channel in pairs(self.privateChannels) do
		if channel:GetRoleId() == roleId then
			channel:Open();
		else
			channel:Close();
		end
	end
end

--添加私聊通知
function ChatModel:AddPrivateNotice(roleId,roleName,num,icon,lvl,vipLvl)
	for i,vo in ipairs(self.privateNoticeList) do
		if vo.roleId == roleId then
			vo.num = num;
			return;
		end
	end
	local vo = {};
	vo.roleId = roleId;
	vo.num = num;
	vo.roleName = roleName;
	vo.icon = icon;
	vo.iconUrl = ResUtil:GetHeadIcon(icon);
	vo.lvl = lvl;
	vo.vipLvl = vipLvl;
	table.push(self.privateNoticeList,vo);
end

--清除某个人的私聊通知
function ChatModel:RemovePrivateNotice(roleId)
	for i=#self.privateNoticeList,1,-1 do
		local vo = self.privateNoticeList[i];
		if vo.roleId == roleId then
			table.remove(self.privateNoticeList,i);
			return true;
		end
	end
	return false;
end

--获取是否有某人的私聊通知
function ChatModel:GetHasPrivateNotice(roleId)
	for i,vo in ipairs(self.privateNoticeList) do
		if vo.roleId == roleId then
			return true;
		end
	end
	return false;
end

--添加到私聊列表
function ChatModel:AddPrivateChat(roleId,roleName,icon,lvl,vipLvl)
	for i,vo in ipairs(self.privateChatList) do
		if vo.roleId == roleId then
			return;
		end
	end
	local vo = {};
	vo.roleId = roleId;
	vo.roleName = roleName;
	vo.icon = icon;
	vo.iconUrl = ResUtil:GetHeadIcon(icon);
	vo.lvl = lvl;
	vo.vipLvl = vipLvl;
	table.push(self.privateChatList,vo);
	while #self.privateChatList > ChatConsts.MaxPrivateChat do
		table.remove(self.privateChatList,1);
	end
end

--获取私聊信息
function ChatModel:GetPrivateInfo(roleId)
	for i,vo in ipairs(self.privateChatList) do
		if vo.roleId == roleId then
			return vo;
		end
	end
	return nil;
end

--将某人从私聊列表中移除
function ChatModel:RemovePrivateChat(roleId)
	for i=#self.privateChatList,1,-1 do
		local vo = self.privateChatList[i];
		if vo.roleId == roleId then
			table.remove(self.privateChatList,i);
			return true;
		end
	end
	return false;
end

--获取某人是否在私聊列表
function ChatModel:GetPrivateChat(roleId)
	for i,vo in ipairs(self.privateChatList) do
		if vo.roleId == roleId then
			return vo;
		end
	end
	return nil;
end