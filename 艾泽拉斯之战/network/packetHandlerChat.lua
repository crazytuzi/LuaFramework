function ChatHandler( channel, chatType, playerID, level, icon,vip, miracle, talker, content, params )

	local record = dataManager.chatData:addRecord(channel, chatType, playerID, level, icon,vip, talker, content, params, miracle);
	
	eventManager.dispatchEvent({name = global_event.CHATROOM_RECV_ONE_RECORD, channel = channel, record = record });
	
end
