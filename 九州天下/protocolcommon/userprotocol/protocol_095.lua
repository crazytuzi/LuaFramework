
MailStruct = MailStruct or {}

function MailStruct.ReadMailContentParam(param)
	local stu = param or {}

	stu.coin = MsgAdapter.ReadInt()
	stu.coin_bind = MsgAdapter.ReadInt()
	stu.gold = MsgAdapter.ReadInt()
	stu.gold_bind = MsgAdapter.ReadInt()

	stu.subject = MsgAdapter.ReadStrN(128)
	stu.contenttxt = MsgAdapter.ReadStrN(512)
	stu.resvered = MsgAdapter.ReadInt()

	stu.item_list = {}
	for i = 1, 3 do
		stu.item_list[i] = ProtocolStruct.ReadItemDataWrapper()
	end

	stu.virtual_item_list = MailStruct.ReadMailVirtualItemList()
	return stu
end

function MailStruct.ReadMailVirtualItemList()
	local stu = {}

	for i = 1, 18 do
		stu[i] = MsgAdapter.ReadInt()
	end
	return stu
end

function MailStruct.ReadMailBrief()
	local stu = {}
		stu.mail_index = MsgAdapter.ReadInt()
		stu.has_attachment = MsgAdapter.ReadInt() --是否有附件
		stu.mail_status = MailStruct.ReadMailStatus()
		stu.subject = MsgAdapter.ReadStrN(128)
	return stu
end

function MailStruct.ReadMailStatus()
	local stu = {}
	stu.sender_uid = MsgAdapter.ReadInt()
	stu.sender_name = MsgAdapter.ReadStrN(32)
	stu.recv_time = MsgAdapter.ReadUInt()
	stu.kind = MsgAdapter.ReadChar()
	stu.is_read = MsgAdapter.ReadChar()
	stu.is_lock = MsgAdapter.ReadChar()
	stu.resvered = MsgAdapter.ReadChar()
	stu.vip_level = MsgAdapter.ReadInt()
	return stu
end

--9500 发邮件返回
SCMailSendAck = SCMailSendAck or BaseClass(BaseProtocolStruct)

function SCMailSendAck:__init()
	self.msg_type = 9500
	self.ret = 0
end

function SCMailSendAck:Decode()
	self.ret = MsgAdapter.ReadInt()
end

--9501删除邮件返回
SCMailDeleteAck = SCMailDeleteAck or BaseClass(BaseProtocolStruct)

function SCMailDeleteAck:__init()
	self.msg_type = 9501
	self.mail_index = 0
	self.ret = 0
end

function SCMailDeleteAck:Decode()
	self.mail_index = MsgAdapter.ReadInt()
	self.ret = MsgAdapter.ReadInt()
end

--9502锁邮件返回
SCMailLockAck = SCMailLockAck or BaseClass(BaseProtocolStruct)

function SCMailLockAck:__init()
	self.msg_type = 9502
	self.mail_index = 0
	self.ret = 0
end

function SCMailLockAck:Decode()
	self.mail_index = MsgAdapter.ReadInt()
	self.ret = MsgAdapter.ReadInt()
end

--9503解锁邮件返回
SCMailUnlockAck = SCMailUnlockAck or BaseClass(BaseProtocolStruct)

function SCMailUnlockAck:__init()
	self.msg_type = 9503
	self.mail_index = 0
	self.ret = 0
end

function SCMailUnlockAck:Decode()
	self.mail_index = MsgAdapter.ReadInt()
	self.ret = MsgAdapter.ReadInt()
end

--9504邮件列表返回
SCMailListAck = SCMailListAck or BaseClass(BaseProtocolStruct)

function SCMailListAck:__init()
	self.msg_type = 9504
	self.is_first = 0
	self.count = 0
	self.mails = {}
end

function SCMailListAck:Decode()
	self.is_first = MsgAdapter.ReadInt()
	local count = MsgAdapter.ReadInt()
	if 1 == self.is_first then
		self.mails = {}
	end
	for i = 1, count do
		local mail_item = MailStruct.ReadMailBrief()
		table.insert(self.mails, mail_item)
	end
	self.count = #self.mails
end

--9505邮件详细信息
SCMailDetailAck = SCMailDetailAck or BaseClass(BaseProtocolStruct)

function SCMailDetailAck:__init()
	self.msg_type = 9505
	self.mail_index = 0
	self.content_param = nil
end

function SCMailDetailAck:Decode()
	self.mail_index = MsgAdapter.ReadInt()
	self.content_param = MailStruct.ReadMailContentParam()
end

--9506提取邮件附件返回
SCFetchAttachmentAck = SCFetchAttachmentAck or BaseClass(BaseProtocolStruct)

function SCFetchAttachmentAck:__init()
	self.msg_type = 9506
	self.mail_index = 0
	self.item_index = 0
	self.ret = 0
end

function SCFetchAttachmentAck:Decode()
	self.mail_index = MsgAdapter.ReadInt()
	self.item_index = MsgAdapter.ReadInt()
	self.ret = MsgAdapter.ReadInt()
end

--9507新邮件通知
SCRecvNewMail = SCRecvNewMail or BaseClass(BaseProtocolStruct)

function SCRecvNewMail:__init()
	self.msg_type = 9507
	self.mail_brief = nil
end

function SCRecvNewMail:Decode()
	self.mail_brief = MailStruct.ReadMailBrief()
end

-- 上线时有未读邮件通知
SCHasUnReadMail = SCHasUnReadMail or BaseClass(BaseProtocolStruct)
function SCHasUnReadMail:__init()
	self.msg_type = 9508
	self.unread_num = 0
	self.chongzhi_mail_num = 0
end

function SCHasUnReadMail:Decode()
	self.unread_num = MsgAdapter.ReadShort()
	self.chongzhi_mail_num = MsgAdapter.ReadShort()
end
