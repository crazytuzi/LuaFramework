function MailHandler( id, caption, text, time, wildCardParams, attachements )
	local mail = dataManager.mailData:getMail(id)
	mail:setId(id)
	mail:setTitle(caption)
	mail:setTime(time)	
	mail:setText(text)	
	mail:setWildCardParams(wildCardParams)	
	local numIndex =1
	for i,v in ipairs (attachements) do	
		mail:addATTACHMENT(v,numIndex)
		numIndex = numIndex + 1
	end		
	sendaskMailCount()
	eventManager.dispatchEvent({name = global_event.MAILBOX_OPEN_MAIL});
	
end
