MailEvent = MailEvent or {}

MailEvent.READ_MAIL_INFO = "MailEvent.READ_MAIL_INFO"

-----更新邮件的,包括删除和新增----
MailEvent.UPDATE_ITEM = "MailEvent.UPDATE_ITEM"

MailEvent.GET_ITEM_ASSETS = "MailEvent.GET_ITEM_ASSETS"

-----更新公告的,包括删除和新增----
MailEvent.UPDATE_NOTICE = "MailEvent.UPDATE_NOTICE"
--读取公告
MailEvent.READ_INFO_NOTICE = "MailEvent.READ_INFO_NOTICE"

-- 红点状态
MailEvent.UPDATEREDSTATUS = "MailEvent.UPDATEREDSTATUS"

--客服反馈状态
MailEvent.Customer_Service_Status = "MailEvent.Customer_Service_Status"

MailEvent.Guild_Mail_CONTENT = {
	subject = "欢迎来到梦幻世界",
	content = "亲爱的玩家，欢迎进入梦幻世界。游戏自从运营以来，一直受到大家的热情支持和鼓励，以后会努力做得更好",
	assets = {},
	items = {},
	mail_read = 0,
	time_out = 0,
}