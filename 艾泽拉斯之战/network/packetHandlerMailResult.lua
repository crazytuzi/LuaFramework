function MailResultHandler( mailResult, param1, param2 )
		if(mailResult  == enum.MAIL_RESULT_TYPE.MAIL_RESULT_TYPE_QUERY_COUNT)then	-- 邮件总数请求结果 param代表所有邮件数量 param2代表未读数量
			dataManager.mailData:setCount(param1,param2)	
			eventManager.dispatchEvent({name = global_event.MAILBOX_NUM_UPDATE});
			eventManager.dispatchEvent({name = global_event.MAIN_UI_MAIL_STATE});
		end		
		if(mailResult  == enum.MAIL_RESULT_TYPE.MAIL_RESULT_TYPE_DELETE_MAIL)then	-- 删除邮件成功	
			dataManager.mailData:delMail(param1)	
			sendaskMailCount()
			eventManager.dispatchEvent({name = global_event.MAILBOX_UPDATE});
		end				
end
