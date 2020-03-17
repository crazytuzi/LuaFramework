--[[
聊天,公告
lizhuangzhuang
2014年9月17日10:28:49
]]
_G.classlist['ChatController'] = 'ChatController'
_G.ChatController = setmetatable({},{__index=IController})
ChatController.objName = 'ChatController'
ChatController.name = "ChatController";

function ChatController:Create()
	CControlBase:RegControl(self, true);
	MsgManager:RegisterCallBack(MsgType.WC_Notice,self,self.OnNotice);
	MsgManager:RegisterCallBack(MsgType.WC_Chat,self,self.OnReceiveChat);
	MsgManager:RegisterCallBack(MsgType.WC_PrivateChatNotice,self,self.OnPrivateChatNotice);
	MsgManager:RegisterCallBack(MsgType.WC_ChatSysNotice,self,self.OnChatSysNotice);
	MsgManager:RegisterCallBack(MsgType.WC_AlwaysNotice,self,self.OnAlwaysNotice);
	MsgManager:RegisterCallBack(MsgType.WC_BanChat,self,self.OnBanGuildChat);
end

function ChatController:OnKeyDown(keyCode)
	if keyCode == _System.KeyReturn then
		UIChat:SetFocus(true);
	end
end

function ChatController:Update(interval)
	local channel = ChatModel:GetChannel(ChatConsts.Channel_Horn);
	if channel then
		channel:Update(interval);
	end
end

--收到公告
function ChatController:OnNotice(msg)
	--平台公告
	if msg.id==10000 and msg.param~="" then
		self:OnContentNotice(msg.param);
		return;
	end
	--
	local cfg = t_notice[msg.id];
	if not cfg then return; end
	local posArr = split(cfg.pos,",");
	for i,pos in ipairs(posArr) do
		if toint(pos) == ChatConsts.NoticePos_Chat then
			self:AddNotice(cfg.channel,msg.id,msg.param);
		else
			local noticeStr = NoticeUtil:GetNoticeStr(msg.id,msg.param);
			if noticeStr and noticeStr~="" then
				if toint(pos) == ChatConsts.NoticePos_AllServer then
					FloatManager:AddAllServerAnn(noticeStr);
				elseif toint(pos) == ChatConsts.NoticePos_Server then
					FloatManager:AddAnn(noticeStr);
				elseif toint(pos) == ChatConsts.NoticePos_Activity then
					FloatManager:AddActivity(noticeStr);
				end
			end
		end
	end
end

--自定义公告
function ChatController:OnContentNotice(content)
	content = "<font color='#cc0000'>" .. content .. "</font>"
	--飘
	local text = NoticeUtil:ParseContentNotice("<font color='#cc0000'>【公告】</font>"..content,false);
	FloatManager:AddAnn(text);
	--加入聊天
	local channelVO = ChatModel:GetChannel(ChatConsts.Channel_All);
	if not channelVO then return; end
	local text = NoticeUtil:ParseContentNotice("<img src='img://resfile/icon/chat_ch_gg.png'/>"..content,true);
	local chatVO = ChatVO:new();
	chatVO.type = 1;
	chatVO.noticeId = 0;
	chatVO.channel = ChatConsts.Channel_All;
	chatVO:SetText(text);
	channelVO:AddChat(chatVO);
end

--往聊天添加公告(客户端不要用)
--拆分函数,没有continue的语言,代码自己看着都蛋疼,fuck
function ChatController:AddNotice(channel,id,param)
	local channelVO = ChatModel:GetChannel(channel);
	if not channelVO then return; end
	local chatStr = NoticeUtil:GetNoticeStrAtChat(id,param);
	if not chatStr then return; end
	if chatStr == "" then return; end
	local chatVO = ChatVO:new();
	chatVO.type = 1;
	chatVO.noticeId = id;
	chatVO.channel = channel;
	chatVO:SetText(chatStr);
	channelVO:AddChat(chatVO);
	if channel~=ChatConsts.Channel_All then
		local channelAll = ChatModel:GetChannel(ChatConsts.Channel_All);
		if channelAll then
			channelAll:AddChat(chatVO);
		end
	end
end

function ChatController:SendCrossChat(channel,text)
	if text == "" then return; end
	local msg = ReqCrossChatMsg:new();
	msg.channel = channel;
	msg.text = ChatUtil:FilterSend(text);
	MsgManager:Send(msg);
end

--发送聊天
function ChatController:SendChat(channel,text)
	if text == "" then return; end
	
	if self:CheckGM(text) then
		return;
	end
	
	local msg = ReqChatMsg:new();
	msg.channel = channel;
	msg.toID = 0;
	msg.text = ChatUtil:FilterSend(text);
	MsgManager:Send(msg);
	if ChatModel.chatSetting.channel[channel] then
		ChatController:AddSysNotice(channel,2001414,"",true);
	end
	
end

function ChatController:CheckGM(text)
	if not _G.DebugActived then
		return;
	end
	
	local params = GetSlantedTable(text);
	if #params <2 then
		return;
	end
	
	local input = GMInput[params[2]];
	if not input then
		return;
	end
	input.execute(params);
	return true;
end

--发送喇叭
function ChatController:SendHorn(text,hornId,autoMoney,bag,pos)
	if text == "" then 
		FloatManager:AddCenter(StrConfig["chat113"]);
		return false; 
	end
	if not bag then bag=-1; end
	if not pos then pos=-1; end
	local hornCfg = t_horn[hornId];
	if not hornCfg then return false; end
	--取数量
	local hornNum = 0;
	if bag==-1 and pos==-1 then
		hornNum = BagModel:GetItemNumInBag(hornCfg.needItem);
	else
		local bagVO = BagModel:GetBag(bag);
		if bagVO then
			local bagItem = bagVO:GetItemByPos(pos);
			if bagItem then
				hornNum = bagItem:GetCount();
			end
		end
	end
	--判断
	if hornNum <= 0 then
		if autoMoney then
			if MainPlayerModel.humanDetailInfo.eaUnBindMoney < hornCfg.money then
				FloatManager:AddCenter(StrConfig["chat115"]);
				return false;
			end
		else
			FloatManager:AddCenter(StrConfig["chat114"]);
			return false;
		end
	end
	local msg = ReqHornMsg:new();
	msg.hornId = hornId;
	msg.item_bag = bag;
	msg.item_idx = pos;
	msg.autoMoney = autoMoney and 1 or 0;
	msg.text = ChatUtil:FilterSend(text);
	MsgManager:Send(msg);
	return true;
end

--收到聊天
function ChatController:OnReceiveChat(msg)
	if ChatModel.chatSetting.channel[msg.channel] then
		return;
	end

	--检查是否在黑名单里,如果不是喇叭频道的说话。那么说话这个人是当前玩家的黑名单之一，则忽略
	if msg.channel ~= ChatConsts.Channel_Horn then
		if FuncManager:GetFuncIsOpen(FuncConsts.Friend) then
			if FriendModel:GetIsBlack(msg.senderID) then
				return;
			end
		end
	end

	msg.text = ChatUtil:FilterReceive(msg.text);
	--私聊不用解析参数 
	if msg.channel == ChatConsts.Channel_Private then
		local channelVO = ChatModel:GetPrivateChannel(msg.senderID);
		if not channelVO then
			channelVO = ChatModel:AddPrivateChannel(msg.senderID,msg.senderName);
		end
		local chatVO = ChatPrivateVO:new();
		local paramStr = string.format("0,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,0,"..ChatConsts.Channel_Private,
						msg.senderID,msg.senderName,msg.senderTeamId,msg.senderGuildId,msg.senderGuildPos,
						msg.senderVIP,msg.senderLvl,msg.senderIcon,msg.senderCityPos,msg.senderVflag,msg.senderIsGM);
		local senderVO = ChatRoleVO:new();
		senderVO:ParseStr(paramStr);
		chatVO:SetSenderInfo(senderVO);
		chatVO.senderFlag = msg.senderFlag;
		chatVO.sendTime = msg.sendTime;
		chatVO.channel = msg.channel;
		chatVO:SetText(msg.text);
		channelVO:AddChat(chatVO);
		Version:DuoWanCollectMsg(msg.senderName,MainPlayerModel.humanDetailInfo.eaName,msg.text,1);
		return;
	end
	--
	local chatVO = ChatUtil:ParseChatMsg(msg);
	local channelVO = ChatModel:GetChannel(msg.channel);
	if channelVO then
		channelVO:AddChat(chatVO);
	end
	if msg.channel~=ChatConsts.Channel_All and msg.channel~=ChatConsts.Channel_Private 
		and msg.channel~=ChatConsts.Channel_Horn and msg.channel~=ChatConsts.Channel_Cross_Map 
		and msg.channel~=ChatConsts.Channel_Cross_Server then
		local channelAll = ChatModel:GetChannel(ChatConsts.Channel_All);
		if channelAll then
			channelAll:AddChat(chatVO);
		end
	end
	if msg.channel == ChatConsts.Channel_Guild then
		if not UIChatGuild:IsShow() then
			UIChatGuildNotice:PlayEffect();
		end
	end
	if msg.senderID ~= MainPlayerModel.mainRoleID then
		Version:DuoWanCollectMsg(msg.senderName,MainPlayerModel.humanDetailInfo.eaName,msg.text,2);
	end
end

--收到系统通知
function ChatController:OnChatSysNotice(msg)
	local cfg = t_sysnotice[msg.id];
	if not cfg then return; end
	if ChatModel.chatSetting.notice[cfg.filter] then
		return;
	end
	FloatManager:AddSysNotice(msg.id,msg.param);
end

--往聊天添加一条系统通知
function ChatController:AddSysNotice(channel,id,param,unShowAtAll)
	local channelVO = nil;
	if channel == ChatConsts.Channel_Private then
		channelVO = ChatModel:GetPrivateChannel(ChatModel.currPrivateChat);
	else
		channelVO = ChatModel:GetChannel(channel);
	end
	if not channelVO then return; end
	if not param then param=""; end
	local chatStr = NoticeUtil:GetSysNoticeStrAtChat(id,param);
	chatStr = "<img src='img://resfile/icon/chat_ch_xt.png'/>" .. chatStr;
	local chatVO = ChatVO:new();
	chatVO.type = 2;
	chatVO.noticeId = id;
	chatVO.channel = channel;
	chatVO:SetText(chatStr);
	channelVO:AddChat(chatVO);
	if unShowAtAll then return; end
	if channel~=ChatConsts.Channel_All and channel~=ChatConsts.Channel_Private then
		local channelAll = ChatModel:GetChannel(ChatConsts.Channel_All);
		if channelAll then
			channelAll:AddChat(chatVO);
		end
	end
end

--往聊天中添加收益信息
function ChatController:AddUserInfo(text)
	local channel = ChatModel:GetChannel(ChatConsts.Channel_System);
	if not channel then return; end
	text = "<img src='img://resfile/icon/chat_ch_sy.png'/>" .. text;
	local chatVO = ChatVO:new();
	chatVO.type = 2;
	chatVO.channel = ChatConsts.Channel_System;
	chatVO:SetText(text);
	channel:AddChat(chatVO);
end

--收到私聊通知
function ChatController:OnPrivateChatNotice(msg)
	if ChatModel.chatSetting.channel[ChatConsts.Channel_Private] then
		return;
	end
	--添加到私聊通知
	SoundManager:PlaySfx(2002);
	ChatModel:AddPrivateNotice(msg.senderID,msg.senderName,msg.num,msg.senderIcon,msg.senderLvl,msg.senderVIP);
	if not UIChatPrivateNotice:IsShow() then
		UIChatPrivateNotice:Show();
	end
	self:sendNotification(NotifyConsts.ChatPrivateNotice);
end

--清空私聊通知
function ChatController:ClearPrivateChatNotice()
	if #ChatModel.privateNoticeList <= 0 then
		return;
	end
	ChatModel.privateNoticeList = {};
	self:sendNotification(NotifyConsts.ChatPrivateNotice);
end

--移除一条私聊通知
function ChatController:RemovePrivateChatNotice(roleId)
	if ChatModel:RemovePrivateNotice(roleId) then
		self:sendNotification(NotifyConsts.ChatPrivateNotice);
	end
end

--发送私聊
function ChatController:SendPrivateChat(text,toID)
	if text == "" then return; end
	--本地添加进频道
	local channelVO = ChatModel:GetPrivateChannel(toID);
	if not channelVO then return; end
	local chatVO = ChatPrivateVO:new();
	local senderVO = ChatRoleVO:new();
	senderVO:CopyMeInfo();
	chatVO:SetSenderInfo(senderVO);
	chatVO.sendTime = GetServerTime();
	chatVO.channel = ChatConsts.Channel_Private;
	text = ChatUtil:FilterSend(text);
	chatVO:SetText(ChatUtil:FilterReceive(text));
	channelVO:AddChat(chatVO);
	--
	local msg = ReqChatMsg:new();
	msg.channel = ChatConsts.Channel_Private;
	msg.toID = toID;
	msg.text = text;
	MsgManager:Send(msg);
	if ChatModel.chatSetting.channel[ChatConsts.Channel_Private] then
		ChatController:AddSysNotice(ChatConsts.Channel_Private,2001414,"",true);
	end
end

--开启对某人的私聊
function ChatController:OpenPrivateChat(roleId,roleName,icon,lvl,vipLvl)
	self:RemovePrivateChatNotice(roleId);
	ChatModel:AddPrivateChat(roleId,roleName,icon,lvl,vipLvl);
	ChatModel:SetCurrPrivateChat(roleId,roleName);
	if not UIChatPrivate:IsShow() then
		UIChatPrivate:Show();
	else
		self:sendNotification(NotifyConsts.ChatPrivateListRefresh);
	end
	UIChatPrivateMin:Hide();
end

--关闭对某人的私聊
function ChatController:ClosePrivateChat(roleId)
	if not ChatModel:RemovePrivateChat(roleId) then
		return;
	end
	--判断是否还有人
	if #ChatModel.privateChatList <= 0 then
		UIChatPrivate:Hide();
		ChatModel:SetCurrPrivateChat(0);
		return;
	end
	--判断是否主聊天
	if roleId == ChatModel.currPrivateChat then
		ChatModel:SetCurrPrivateChat(ChatModel.privateChatList[1].roleId,ChatModel.privateChatList[1].roleName);
	end
	self:sendNotification(NotifyConsts.ChatPrivateListRefresh);
end

--关闭所有私聊
function ChatController:CloseAllPrivateChat()
	ChatModel.privateChatList = {};
	ChatModel:SetCurrPrivateChat(0);
	UIChatPrivate:Hide();
end

--关闭接收某人的私聊
function ChatController:CloseReceivePrivateChat(roleID)
	local msg = ReqPrivateChatStateMsg:new();
	msg.roleID = roleID;
	msg.state = 0;
	MsgManager:Send(msg);
end

--开启接收某人的私聊
function ChatController:OpenReceivePrivateChat(roleID)
	local msg = ReqPrivateChatStateMsg:new();
	msg.roleID = roleID;
	msg.state = 1;
	MsgManager:Send(msg);
end

--开启阵营聊天
function ChatController:OpenCampChat()
	ChatModel.campOpen = true;
	UIChat:ShowChannels();
	UIChat:ShowDropDownChannels();
end

--关闭阵营聊天
function ChatController:CloseCampChat()
	ChatModel.campOpen = false;
	UIChat:ShowChannels();
	UIChat:ShowDropDownChannels();
end

--常置公告
function ChatController:OnAlwaysNotice(msg)
	if msg.content == "" then
		ChatModel.alwaysNotice = "";
	else
		if msg.link_name == "" then
			ChatModel.alwaysNotice = msg.content;
		else
			local link = string.format("<a href='asfunction:hrefevent,%s'><u>%s</u></a>",msg.link,msg.link_name);
			ChatModel.alwaysNotice = string.format(msg.content,link);
		end
	end
	if UIChat:IsShow() then
		UIChat:SetAlwaysNotice();
	end
end

--请求发送世界notice	CS
function ChatController:OnSendWorldNotice(_type)
	local msg = ReqWorldNoticeMsg:new();
	msg.type = _type;
	MsgManager:Send(msg);
end
--请求发送世界notice	CW
function ChatController:OnSendCWWorldNotice(_type)
	local msg = ReqWCWorldNoticeMsg:new();
	msg.type = _type;
	MsgManager:Send(msg);
end

--举报帮派聊天
function ChatController:BanGuildChat(roleId)
	local msg = ReqBanChatMsg:new();
	msg.roleId = roleId;
	MsgManager:Send(msg);
end

function ChatController:OnBanGuildChat(msg)
	if msg.result == 0 then
		FloatManager:AddNormal(StrConfig["chat119"]);
	else
		FloatManager:AddNormal("举报失败")
	end
end