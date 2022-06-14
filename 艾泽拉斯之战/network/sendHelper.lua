

--邮件数量
function sendaskMailCount()
	sendAskMail(enum.MAIL_OPERATOR.MAIL_QUERY_COUNT,-1,-1)	
end

--邮件list
function sendaskMaillList()
	sendAskMail(enum.MAIL_OPERATOR.MAIL_QUERY_LIST,-1,-1)		
end	

--打开邮件
function sendaskMaillOpen(id)
	sendAskMail(enum.MAIL_OPERATOR.MAIL_READ_MAIL,id,-1)		
end	

--领取所有附件
function sendaskMaillGetItemAll(id)
	sendAskMail(enum.MAIL_OPERATOR.MAIL_GATHER_ATTACHMENTS,id,-1)		
end	

--删除邮件
function sendaskMaillDelete(id)
	sendAskMail(enum.MAIL_OPERATOR.MAIL_DELETE_MAIL,id,-1)		
end	