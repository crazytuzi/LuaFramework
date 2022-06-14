function NotifyHandler( notifyType, text, wildCardParams )
	if(enum.NOTIFY_TYPE.NOTIFY_TYPE_SYSTEM == notifyType)then
		dataManager.chatData:NotifySystemMsg(text, wildCardParams, true, enum.CHANNEL.CHANNEL_WORLD )
	elseif(enum.NOTIFY_TYPE.NOTIFY_TYPE_NEW_MAIL == notifyType)then	
		 
		--sendaskMaillList()
		sendaskMailCount()
	elseif(enum.NOTIFY_TYPE.NOTIFY_TYPE_GUILD == notifyType)then	
	
		dataManager.chatData:NotifySystemMsg(text, wildCardParams, false, enum.CHANNEL.CHANNEL_GUILD )
		
	end
end
