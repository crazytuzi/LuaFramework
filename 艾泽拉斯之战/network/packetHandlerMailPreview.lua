function MailPreviewHandler( beginIndex, mailPreviews )
	for i,v in ipairs (mailPreviews) do
		local mail = dataManager.mailData:createMail(i)
		mail:setId(v.id)
		mail:setTitle(v.caption)
		mail:setTime(v.time)		
		mail:setReadFlag(v.isReaded)				
	end		
	eventManager.dispatchEvent({name = global_event.MAILBOX_UPDATE});
end
