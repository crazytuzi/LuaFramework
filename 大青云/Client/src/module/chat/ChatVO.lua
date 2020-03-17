--[[
聊天中的每句话
lizhuangzhuang
2014年9月19日17:14:19
]]
_G.classlist['ChatVO'] = 'ChatVO'
_G.ChatVO = {};
ChatVO.objName = 'ChatVO'
ChatVO.senderVO = nil;--发送者信息
ChatVO.channel = 0;--原始频道
ChatVO.text = "";
ChatVO.sendTime = 0;
ChatVO.hornId = 0;--喇叭id

function ChatVO:new()
	local obj = setmetatable({},{__index=self});
	obj.type = 0;
	return obj;
end

--类型,0聊天,1公告,2系统通知
function ChatVO:GetType()
	return self.type;
end

--该聊天为公告或通知时，返回id
function ChatVO:GetNoticeId()
	if self.noticeId then
		return self.noticeId;
	end
	return 0;
end

--设置发送者信息
function ChatVO:SetSenderInfo(vo)
	self.senderVO = vo;
end

--发送时间
function ChatVO:GetTime()
	return self.sendTime;
end

--设置文本
function ChatVO:SetText(text)
	local str = "<font color='"..ChatConsts:GetChannelColor(self.channel).."'>";
	if self.type==0 and self.channel~=ChatConsts.Channel_Horn then
		str = str .. "<img src='img://resfile/icon/chat_ch_" ..self.channel.. ".png'/>";
	end
	self.text = str ..text.."</font>";
end
--获取文本内容
function ChatVO:GetText()
	return self.text;
end