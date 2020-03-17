--[[
聊天频道
lizhuangzhuang
2014年9月19日17:34:48
]]

_G.ChatChannel = {};

function ChatChannel:new(type)
	local obj = setmetatable({},{__index=self});
	obj.type = type;
	obj.chatList = {};
	return obj;
end

function ChatChannel:GetType()
	return self.type;
end

--添加聊天
function ChatChannel:AddChat(chatVO)
	local maxNum = self:GetMaxNum();
	while #self.chatList >= maxNum do
		table.remove(self.chatList,1);
	end
	table.push(self.chatList,chatVO);
	Notifier:sendNotification(NotifyConsts.ChatChannelRefresh, {channel=self:GetType()});
	--下面几个频道显示提醒特效
	if self.type==ChatConsts.Channel_World or self.type==ChatConsts.Channel_Map or self.type==ChatConsts.Channel_Camp
		or self.type==ChatConsts.Channel_Guild or self.type==ChatConsts.Channel_Team or self.type==ChatConsts.Channel_Cross
		or self.type==ChatConsts.Channel_System or self.type==ChatConsts.Channel_Cross_Map or self.type==ChatConsts.Channel_Cross_Server then
		if chatVO:GetType()==0 and chatVO.senderVO:GetID()~=MainPlayerModel.mainRoleID then
			Notifier:sendNotification(NotifyConsts.ChatChannelNewMsg, {channel=self:GetType()});
		end
	end
end

--获取最后一个聊天内容
function ChatChannel:GetLastChat()
	if #self.chatList <= 0 then return; end
	return self.chatList[#self.chatList];
end

--聊天上限
function ChatChannel:GetMaxNum()
	if self.type == ChatConsts.Channel_All then
		return ChatConsts.MaxNum_All;
	else 
		return ChatConsts.MaxNum_Channel;
	end
end

--添加过滤提示
function ChatChannel:AddFilterTips()
	if #self.chatList > 0 then
		local lastChatVO = self.chatList[#self.chatList];
		if lastChatVO:GetType()==2 and lastChatVO:GetNoticeId()==1 then
			return;
		end
	end
	ChatController:AddSysNotice(self.type,1,"",true)
end