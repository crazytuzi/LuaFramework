local chatRoom = class( "chatRoom", layout );

global_event.CHATROOM_SHOW = "CHATROOM_SHOW";
global_event.CHATROOM_HIDE = "CHATROOM_HIDE";

 


function chatRoom:ctor( id )
	chatRoom.super.ctor( self, id );
	self:addEvent({ name = global_event.CHATROOM_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CHATROOM_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.CHATROOM_RECV_ONE_RECORD, eventHandler = self.onReciveOneRecord});
	self:addEvent({ name = global_event.CHATROOM_PRIVET_CHAT, eventHandler = self.onBeginpRrivetChat});
end

function chatRoom:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.chatRoom_chatPane = LORD.toScrollPane(self:Child( "chatRoom-chatPane" ));
	self.chatRoom_chatPane:init();
	
	self.chatRoom_privateChatListPane = LORD.toScrollPane(self:Child( "chatRoom-whisper-sp" ));
	self.chatRoom_privateChatListPane:init();
	
	
	function onChatRoomSend()
		self:onSend();
	end
		
	self.chatRoom_send = self:Child( "chatRoom-send" );
	self.chatRoom_send:subscribeEvent("ButtonClick", "onChatRoomSend");
	
	self.chatRoom_input_edit = self:Child( "chatRoom-input-edit" );
	self.chatRoom_close = self:Child("chatRoom-close");
	self.chatRoom_input_edit:SetText("");
	
	self.chatRoom_whisper_point = self:Child( "chatRoom-whisper-point" );
	self.chatRoom_whisper_point:SetVisible(false)
	
	function onChatRoomClose()
		self:onHide();
	end
	
	self.chatRoom_close:subscribeEvent("ButtonClick", "onChatRoomClose");
	
	
	function onChatRoomTab(args)
		
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		local userdata =  window:GetUserData();
		if window:IsSelected() then
			self:onSelectChannel(userdata);
		end
				
	end
	
	self.chatRoom_Tab = {};
	self.chatRoom_Tab[enum.CHANNEL.CHANNEL_WORLD] = LORD.toRadioButton(self:Child( "chatRoom-world" ));
	self.chatRoom_Tab[enum.CHANNEL.CHANNEL_WORLD]:SetUserData(enum.CHANNEL.CHANNEL_WORLD);
	self.chatRoom_Tab[enum.CHANNEL.CHANNEL_WORLD]:subscribeEvent("RadioStateChanged", "onChatRoomTab");
	
	self.chatRoom_Tab[enum.CHANNEL.CHANNEL_GUILD] = LORD.toRadioButton(self:Child( "chatRoom-union" ));
	self.chatRoom_Tab[enum.CHANNEL.CHANNEL_GUILD]:SetUserData(enum.CHANNEL.CHANNEL_GUILD);
	self.chatRoom_Tab[enum.CHANNEL.CHANNEL_GUILD]:subscribeEvent("RadioStateChanged", "onChatRoomTab");
	
	self.chatRoom_Tab[enum.CHANNEL.CHANNEL_FRIEND] = LORD.toRadioButton(self:Child( "chatRoom-whisper" ));
	self.chatRoom_Tab[enum.CHANNEL.CHANNEL_FRIEND]:SetUserData(enum.CHANNEL.CHANNEL_FRIEND);
	self.chatRoom_Tab[enum.CHANNEL.CHANNEL_FRIEND]:subscribeEvent("RadioStateChanged", "onChatRoomTab");

  
	self.chatRoom_Tab[enum.CHANNEL.CHANNEL_GUILD]:SetVisible(dataManager.guildData:isHaveGuildMyself());
	
	function onChatRoomCheckPlayer()
		self:onCheckPlayer();
	end
	 
	function onChatRoomAddPlayer()
		self:onAddPlayer();
	end
	 
		
	-- 默认发的就是文本内容
	self.chatType = enum.CHAT_TYPE.CHAT_TYPE_TEXT;
		
	self.chatRoom_Tab[enum.CHANNEL.CHANNEL_WORLD]:SetSelected(true);
	
end

function chatRoom:onHide(event)
	self:Close();
	
	eventManager.dispatchEvent( {name = global_event.PVPTIPS_HIDE});
	
end

function chatRoom:onSend()

	local content = self.chatRoom_input_edit:GetText();
	local params = {};
	
	self.chatRoom_input_edit:SetText("");
	
	-- gm
	if content ~= "" then
		local temp = string.find( content,"!!!")
		if( temp~= nil)then
			local file = string.gsub( content,"!!!","")
			return 		BUG_REPORT.replayBattle(file)	
		end
		sendGm(content);
		
	end
		
	if dataManager.playerData:getLevel() < 10 then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
			messageType = enum.MESSAGE_BOX_TYPE.COMMON, 
			textInfo = "10级开启聊天"});
			
		return;	
	end
		
	if content ~= "" then
			if(enum.CHANNEL.CHANNEL_FRIEND   == self.channel  )then
				if(  not self.privateChatPlayer  )then
					eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "请选择一个玩家然后私聊"})
					return 
				end
				table.insert(params,self.privateChatPlayer ) 
			end
		local guistring = global.filterText(content);
		
		content = guistring:c_str();
		
		local result = dataManager.chatData:askChat(self.channel, self.chatType, content, params);
		
		if result then
			self.chatRoom_input_edit:SetText("");
		end
	 
	end
			
end

function chatRoom:onSelectChannel(channel,playerid)
	

	if(playerid == nil and self.privateChatPlayer == nil )then
		for i,v in pairs (dataManager.chatData:getPriveChatList())do
			if(v)then
				self.privateChatPlayer = self.privateChatPlayer  or  i
				break
			end
		end
	end
	
	self.YPosition = 0;
	self.channel = channel;	
	self.chatRoom_privateChatListPane:SetVisible(enum.CHANNEL.CHANNEL_FRIEND   == 	self.channel)
	self.infoback = self:Child( "chatRoom-back" );
	self.infobacksmall = self:Child( "chatRoom-backsmall" );
	self.infobacksmall:SetVisible(enum.CHANNEL.CHANNEL_FRIEND   == 	self.channel)
	self.infoback:SetVisible(enum.CHANNEL.CHANNEL_FRIEND   ~= 	self.channel)
	if(enum.CHANNEL.CHANNEL_FRIEND   == 	self.channel)then
		self:onSelectPriveteChannel()
	else
		-- 更新所有的数据
		self.chatRoom_chatPane:ClearAllItem();
		local records = dataManager.chatData:getRecord();
		for k,v in ipairs(records) do
			if v:getChannel() == channel then
				self:insertOneRecord(v);
			end
		end
	end
	self.chatRoom_whisper_point:SetVisible(dataManager.chatData:hasUnreadPrivateMsg())
end


function chatRoom:buildChatPlayerList()
		self.chatRoom_privateChatListPane:ClearAllItem();
		local list = dataManager.chatData:getPriveChatList();
		local ypos = 0
		local heightOffset = 2
		function onPrivatePlayerChatHeadIcon(args)
			local window =  (LORD.toWindowEventArgs(args).window);
			local userdata =  window:GetUserData();
			self.privateChatPlayer = userdata
			--self:onSelectChannel(enum.CHANNEL.CHANNEL_FRIEND,userdata)
			
			self.chatRoom_Tab[enum.CHANNEL.CHANNEL_FRIEND]:SetSelected(false);
			self.chatRoom_Tab[enum.CHANNEL.CHANNEL_FRIEND]:SetSelected(true);
			 
		end	
		
		function onPrivatePlayerChatCloseed(args)
			local window =  (LORD.toWindowEventArgs(args).window);
			local userdata =  window:GetUserData();
			
			dataManager.chatData:delPriveChatList(userdata);
			if(self.privateChatPlayer == userdata )then
				self.privateChatPlayer = nil
			end
			self.chatRoom_Tab[enum.CHANNEL.CHANNEL_FRIEND]:SetSelected(false);
			self.chatRoom_Tab[enum.CHANNEL.CHANNEL_FRIEND]:SetSelected(true);
		end	
		
		for i,v in  pairs (list) do
			if(v)then
				local recordItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("chatroom-"..i, "whisperitem.dlg");
				local icon = LORD.toStaticImage(self:Child("chatroom-"..i.."_whisperitem-image"));
				local name = self:Child("chatroom-"..i.."_whisperitem-name");
				local level = self:Child("chatroom-"..i.."_whisperitem-lv-num");
				local vip = self:Child("chatroom-"..i.."_whisperitem-vip");
				local close = self:Child("chatroom-"..i.."_whisperitem-close");
				local point = self:Child("chatroom-"..i.."_whisperitem-point");
				local chose = self:Child("chatroom-"..i.."_whisperitem-chose");
				chose:SetVisible(i == self.privateChatPlayer )
				name:SetText(v.name)
				level:SetText(v.level)
				icon:SetImage( global.getHeadIcon(v.icon))
				
				vip:SetText("")
				point:SetVisible(v.newMsg == true)
				recordItem:SetXPosition(LORD.UDim(0, 20));
				recordItem:SetYPosition(LORD.UDim(0, ypos));
				local height = recordItem:GetHeight().offset;
				ypos = ypos +  height  +  heightOffset 
				recordItem:SetHeight(recordItem:GetHeight() + LORD.UDim(0, heightOffset));
				self.chatRoom_privateChatListPane:additem(recordItem);
				recordItem:subscribeEvent("WindowTouchUp", "onPrivatePlayerChatHeadIcon");
				
				close:subscribeEvent("ButtonClick", "onPrivatePlayerChatCloseed");
				recordItem:SetUserData(i);
				close:SetUserData(i);
			end
		end	
	
end	

--enum.CHANNEL.CHANNEL_FRIEND
function chatRoom:onSelectPriveteChannel()
		self.chatRoom_chatPane:ClearAllItem();
		self:buildChatPlayerList()
		if(self.privateChatPlayer == nil)then
			return 
		end
		dataManager.chatData:syncPriveChatList(self.privateChatPlayer,false)
 
		
		local records = dataManager.chatData:getRecord();
		for k,v in ipairs(records) do
			if v:getChannel() == self.channel and   (v:getPlayerID() == self.privateChatPlayer   or  v:getTarget() == self.privateChatPlayer  )  then
				self:insertOneRecord(v);
			end
		end
	
end

function chatRoom:onBeginpRrivetChat(event)
		 self:onShow()
		 dataManager.chatData:addPriveChatList(event.id,event.playeInfo);
		 self.privateChatPlayer = event.id
		 self.chatRoom_Tab[enum.CHANNEL.CHANNEL_FRIEND]:SetSelected(false);
		 self.chatRoom_Tab[enum.CHANNEL.CHANNEL_FRIEND]:SetSelected(true);
		 --self:onSelectChannel(enum.CHANNEL.CHANNEL_FRIEND,event.id)
end

function chatRoom:onReciveOneRecord(event)
	
	if not self._show then
		return;	
	end
	
	local record = event.record;
	
	if self.channel == event.channel then
		
		if(enum.CHANNEL.CHANNEL_FRIEND == self.channel  )then
			dataManager.chatData:syncPriveChatList(self.privateChatPlayer,false)
			self:buildChatPlayerList()
			if(self.privateChatPlayer == record:getPlayerID() or self.privateChatPlayer == record:getTarget()) then
				self:insertOneRecord(record);	
			end
		else
			self:insertOneRecord(record);	
		end
				
	end
	self.chatRoom_whisper_point:SetVisible(	 dataManager.chatData:hasUnreadPrivateMsg())
end

function chatRoom:insertOneRecord(record)

	local recordItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("chatroom-"..record:getGUID(), "chatRoomItem.dlg");
	local icon = LORD.toStaticImage(self:Child("chatroom-"..record:getGUID().."_chatRoomItem-icon"));
	local name = self:Child("chatroom-"..record:getGUID().."_chatRoomItem-name");
	local content = self:Child("chatroom-"..record:getGUID().."_chatRoomItem-chattext");
	local contentBack = self:Child("chatroom-"..record:getGUID().."_chatRoomItem-dialog");
	local time = self:Child("chatroom-"..record:getGUID().."_chatRoomItem-time");
	
	local headL = self:Child("chatroom-"..record:getGUID().."_chatRoomItem-headL-dw");
	
	local headR = self:Child("chatroom-"..record:getGUID().."_chatRoomItem-headR-dw");
	local vip = self:Child("chatroom-"..record:getGUID().."_chatRoomItem-vip");

	local iconme = LORD.toStaticImage(self:Child("chatroom-"..record:getGUID().."_chatRoomItem-icon_0"));
	
	local headFrame = LORD.toStaticImage(self:Child("chatroom-"..record:getGUID().."_chatRoomItem-head"));
	local headFrameRight = LORD.toStaticImage(self:Child("chatroom-"..record:getGUID().."_chatRoomItem-head_0"));
	
	headFrame:SetImage(global.getMythsIcon(record:getMiracle()));
	headFrameRight:SetImage(global.getMythsIcon(record:getMiracle()));
	
	-- info
	local nameColor = "^AF15AF";
	if dataConfig.configs.iconConfig[record:getIcon()] then
		icon:SetImage(dataConfig.configs.iconConfig[record:getIcon()].icon);
		iconme:SetImage(dataConfig.configs.iconConfig[record:getIcon()].icon);
	end
	

 
	local nameLevelText = "Lv"..record:getLevel().."  "..nameColor..record:getTalker();
	name:SetText(nameLevelText);
	
	local contentText = record:getContent();
	content:SetText(contentText);
	
	local chatTime = record:getTime();
	dump(chatTime);
	
	time:SetText(chatTime.h..":"..chatTime.m..":"..chatTime.s);
	
	function onChatRoomHeadIcon(args)

		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		local userdata =  window:GetUserData();
		
		local chatRecord = dataManager.chatData:getRecordByGUID(userdata);
		
		if chatRecord and chatRecord:getPlayerID() ~= dataManager.playerData:getPlayerId()  then
			self:onClickChatHeadIcon(chatRecord, window);
		end
	end
	if(vip)then
		vip:SetText(record:getVip())
	end
	icon:SetUserData(record:getGUID());
	icon:subscribeEvent("WindowTouchUp", "onChatRoomHeadIcon");
	
	--iconme:SetUserData(record:getGUID());
	--iconme:subscribeEvent("WindowTouchUp", "onChatRoomHeadIcon");
	
	function onChatRoomContent(args)
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		local userdata =  window:GetUserData();
		
		local chatRecord = dataManager.chatData:getRecordByGUID(userdata);
		
		if chatRecord then
			self:onClickChatContent(chatRecord);
		end
	end
	
	content:SetUserData(record:getGUID());
	content:subscribeEvent("WindowTouchUp", "onChatRoomContent");
	
	if record:getChatType() == enum.CHAT_TYPE.CHAT_TYPE_TEXT then
		
	elseif record:getChatType() == enum.CHAT_TYPE.CHAT_TYPE_REPLAY then
		
		local replayInfo = record:getContent();
 
		content:SetText(replayInfo);
		
	elseif record:getChatType() == enum.CHAT_TYPE.CHAT_TYPE_NOTIFY then
		icon:SetImage("set:pvp1.xml image:win");
		name:SetText("系统");
	end
	
	----------- 下面是计算位置
	recordItem:SetXPosition(LORD.UDim(0, 20));
	recordItem:SetYPosition(LORD.UDim(0, self.YPosition));
	
	-- 计算动态文本大小
	local textHeight = content:GetHeight();	
	--local font = LORD.GUIFontManager:Instance():GetFont("HT-26");
	local font = content:GetFont();
	
	local textWidth = font:GetTextExtent(contentText) + 190;
	
	contentBack:SetHeight(textHeight + LORD.UDim(0, 40));
	local contentBackWidth = contentBack:GetWidth();
	--[[local infobackW = infoback:GetWidth();
	local wsp = self.chatRoom_privateChatListPane:GetWidth();--]]
	if textWidth < contentBackWidth.offset then
		contentBack:SetWidth(LORD.UDim(0, textWidth));
	end
	
	local heightOffset = contentBack:GetUnclippedOuterRect().bottom - recordItem:GetUnclippedOuterRect().bottom;
	
	local height = recordItem:GetHeight().offset;
	self.YPosition = self.YPosition + height + heightOffset;
	
	recordItem:SetHeight(recordItem:GetHeight() + LORD.UDim(0, heightOffset));
	if(record:getPlayerID() == dataManager.playerData:getPlayerId())then
	    local x = 287 - textWidth;
        if x < 0 then
           x = 0;
        end
	    contentBack:SetXPosition(LORD.UDim(0, x));
		headL:SetVisible(false)
		headR:SetVisible(true)
		recordItem:SetXPosition(LORD.UDim(0, 210));
		--content:SetProperty("TextHorzAlignment","Right");
		--recordItem:SetProperty("HorizontalAlignment","right");
		
		if(enum.CHANNEL.CHANNEL_FRIEND   == self.channel  )then
	    recordItem:SetXPosition(LORD.UDim(0, 20));
		
		end
	else
		headL:SetVisible(true)
		headR:SetVisible(false)
		--content:SetProperty("TextHorzAlignment","Left");
		--recordItem:SetProperty("HorizontalAlignment","left");
	end
	self.chatRoom_chatPane:additem(recordItem);

	-- 设置滚动条到底部
	
	local scrollOffset = self.chatRoom_chatPane:GetVertScrollOffset();
	
	if self.YPosition > self.chatRoom_chatPane:GetPixelSize().y then
		
		local newoffset = self.chatRoom_chatPane:GetPixelSize().y - self.YPosition;
		
		if scrollOffset - newoffset <= height + heightOffset then
			self.chatRoom_chatPane:SetVertScrollOffset(self.chatRoom_chatPane:GetPixelSize().y - self.YPosition);
		end
	end
end

function chatRoom:onClickChatHeadIcon(record, icon)
	if record:getChatType() ~= enum.CHAT_TYPE.CHAT_TYPE_NOTIFY then
 
		
		self.currentSelectRecord = record;
		
		local rect = icon:GetUnclippedOuterRect();
		eventManager.dispatchEvent({name = global_event.CONTACTLAYOUT_SHOW, rect = rect, id =  record:getPlayerID(),from = "CHAT_MSG",userdate = record })
		
		--dataManager.chatData:setClickPosition(LORD.Vector2(rect.right + 300 , rect.top + 300));
	end
	
	eventManager.dispatchEvent( {name = global_event.PVPTIPS_HIDE});
end

-- 查看好友
function chatRoom:onCheckPlayer()

	--self.currentSelectRecord
	
	sendAskInspect(self.currentSelectRecord:getPlayerID());
  	
end

-- 添加好友
function chatRoom:onAddPlayer()
		
		--self.currentSelectRecord
		dataManager.buddyData:applyFriend(self.currentSelectRecord:getPlayerID());
  
end

-- 点击聊天内容
function chatRoom:onClickChatContent(record)
	if record:getChatType() == enum.CHAT_TYPE.CHAT_TYPE_REPLAY then
		-- 点击录像的处理
		
		local params = record:getParams();
		sendAskReplay(params[1]);
	end
	
	eventManager.dispatchEvent( {name = global_event.PVPTIPS_HIDE});
end

return chatRoom;
