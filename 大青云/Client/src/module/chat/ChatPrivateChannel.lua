--[[
聊天私人频道
lizhuangzhuang
2014年9月23日11:57:21
]]
_G.classlist['ChatPrivateChannel'] = 'ChatPrivateChannel'
_G.ChatPrivateChannel = setmetatable({},{__index=ChatChannel});
ChatPrivateChannel.objName = 'ChatPrivateChannel'
ChatPrivateChannel.isOpen = false;

--发送者id
function ChatPrivateChannel:SetRoleId(id)
	self.roleId = id;
end
function ChatPrivateChannel:GetRoleId()
	return self.roleId;
end

--发送者名字
function ChatPrivateChannel:SetRoleName(name)
	self.roleName = name;
end
function ChatPrivateChannel:GetRoleName()
	return self.roleName;
end


--添加聊天
function ChatPrivateChannel:AddChat(chatVO)
	table.push(self.chatList,chatVO);
	local maxNum = self:GetMaxNum();
	while #self.chatList > maxNum do
		table.remove(self.chatList,1);
	end
	if self.isOpen then
		Notifier:sendNotification(NotifyConsts.ChatPrivateRefresh, {roleId=self:GetRoleId()});
	else
		Debug("Error:Private Chat received msg.But Channel is Closed");
	end
end

--打开频道
function ChatPrivateChannel:Open()
	if self.isOpen then
		return;
	end
	ChatController:OpenReceivePrivateChat(self.roleId);
	self.isOpen = true;
end

--关闭频道
function ChatPrivateChannel:Close()
	if not self.isOpen then
		return;
	end
	ChatController:CloseReceivePrivateChat(self.roleId);
	self.isOpen = false;
end
